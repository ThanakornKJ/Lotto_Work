require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Schema
const userSchema = new mongoose.Schema({
  user_id: String,
  username: String,
  password: String,
  email: { type: String, unique: true },
  role: String,
  register_date: Date
});
const walletSchema = new mongoose.Schema({
  wallet_id: String,
  user_id: String,
  balance: Number
});
const lotterySchema = new mongoose.Schema({
  lotto_id: String,
  number: String,
  price: Number,
  status: String
});
const purchaseSchema = new mongoose.Schema({
  purchase_id: String,
  user_id: String,
  lotto_id: { type: String, ref: 'Lottery' }, // ✅ เพิ่ม ref
  purchase_date: Date,
  amount_paid: Number
});

const resultSchema = new mongoose.Schema({
  result_id: String,
  draw_date: Date,
  prize_type: String,
  winning_number: String
});
const prizeSchema = new mongoose.Schema({
  prize_id: String,
  purchase_id: String,
  result_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Result' },
  prize_amount: Number,
  claimed: { type: Boolean, default: false }, // ✅ เพิ่ม field claimed
});



// Models
const User = mongoose.model('User', userSchema);
const Wallet = mongoose.model('Wallet', walletSchema);
const Lottery = mongoose.model('Lottery', lotterySchema);
const Purchase = mongoose.model('Purchase', purchaseSchema);
const Result = mongoose.model('Result', resultSchema);
const Prize = mongoose.model('Prize', prizeSchema);

// ---------------- ROUTES ---------------- //

// Register
app.post('/register', async (req, res) => {
  try {
    const { user_id, username, password, email, balance } = req.body; // เพิ่ม balance จาก request
    const role = 'member';
    const register_date = new Date();

    // สร้าง user
    const user = new User({ user_id, username, password, email, role, register_date });
    await user.save();

    // สร้าง wallet โดยใช้ balance ที่ส่งมาหรือ default 0
    const wallet = new Wallet({
      wallet_id: 'W' + user_id,
      user_id,
      balance: balance || 0, // ถ้าไม่ส่ง balance มาก็ให้เป็น 0
    });
    await wallet.save();

    res.status(201).json({ message: 'Register success', user, wallet });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Login
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email, password });
    if (!user) return res.status(400).json({ error: 'Invalid credentials' });

    res.json({
      message: 'Login success',
      user: {
        user_id: user.user_id,
        username: user.username,
        email: user.email,
        role: user.role,   
      },
    });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

app.get('/login', (req, res) => {
  res.send("Login API is working. Use POST instead.");
});


// Get all available lotteries
app.get('/lotteries', async (req, res) => {
  const lotteries = await Lottery.find({ status: 'available' });
  res.json(lotteries);
});

// Purchase lottery
app.post('/purchase', async (req, res) => {
  try {
    const { purchase_id, user_id, lotto_id, amount_paid } = req.body;

    // Check wallet
    const wallet = await Wallet.findOne({ user_id });
    if (!wallet || wallet.balance < amount_paid)
      return res.status(400).json({ error: 'Insufficient balance' });

    // Check lottery availability
    const lottery = await Lottery.findOne({ lotto_id });
    if (!lottery || lottery.status !== 'available')
      return res.status(400).json({ error: 'Lottery not available' });

    // Deduct money
    wallet.balance -= amount_paid;
    await wallet.save();

    // Update lottery status
    lottery.status = 'sold';
    await lottery.save();

    // Create purchase
    const purchase_date = new Date();
    const purchase = new Purchase({ purchase_id, user_id, lotto_id, purchase_date, amount_paid });
    await purchase.save();

    // Check if purchased number wins any current result
    const results = await Result.find({});
    for (const r of results) {
      let won = false;
      if (r.prize_type === '1st' && lottery.number === r.winning_number) won = true;
      if (r.prize_type === '2nd' && lottery.number === r.winning_number) won = true;
      if (r.prize_type === '3rd' && lottery.number === r.winning_number) won = true;
      if (r.prize_type === 'last3' && lottery.number.slice(-3) === r.winning_number) won = true;
      if (r.prize_type === 'last2' && lottery.number.slice(-2) === r.winning_number) won = true;

      if (won) {
        // map prize_amount จากรางวัล
        let prize_amount = 0;
        switch (r.prize_type) {
          case '1st': prize_amount = 6000000; break;
          case '2nd': prize_amount = 200000; break;
          case '3rd': prize_amount = 80000; break;
          case 'last3': prize_amount = 4000; break;
          case 'last2': prize_amount = 2000; break;
        }

        // สร้าง Prize document สำหรับผู้เล่น
        const prize = new Prize({
          prize_id: 'P' + Date.now() + r.prize_type + purchase_id,
          purchase_id,
          result_id: r.result_id,
          prize_amount,
        });
        await prize.save();
      }
    }

    res.json({ message: 'Purchase success', purchase, wallet });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Get purchased lotteries by user_id
app.get('/purchased/:user_id', async (req, res) => {
  try {
    const userId = req.params.user_id;

    // Join Purchase กับ Lottery เพื่อดึงเลขล็อตโต้
    const purchases = await Purchase.aggregate([
      { $match: { user_id: userId } },
      {
        $lookup: {
          from: "lotteries",       // collection ของเลขล็อตโต้
          localField: "lotto_id",  // field ใน Purchase
          foreignField: "lotto_id", // field ใน Lottery
          as: "lottoInfo"
        }
      },
      { $unwind: "$lottoInfo" }, // เอา lottoInfo ออกมาเป็น object
      {
        $project: {
          _id: 0,
          purchase_id: 1,
          lotto_number: "$lottoInfo.number",
          purchase_date: 1,
          amount_paid: 1
        }
      },
      { $sort: { purchase_date: -1 } } // เรียงจากล่าสุดไปเก่าสุด
    ]);

    res.json({ purchases });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// Check wallet balance
app.get('/wallet/:user_id', async (req, res) => {
  const wallet = await Wallet.findOne({ user_id: req.params.user_id });
  if (!wallet) return res.status(404).json({ error: 'Wallet not found' });
  res.json(wallet);
});

app.get('/api/admin/purchases', async (req, res) => {
  try {
    const purchases = await Purchase.aggregate([
      {
        $lookup: {
    from: "users",       // collection User
    localField: "user_id", // field ใน Purchase
    foreignField: "user_id", // field ใน User
    as: "userInfo"
  }

      },
      { $unwind: "$userInfo" }, // ดึง userInfo ออกมาเป็น object
      {
        $group: {
          _id: "$user_id",
          username: { $first: "$userInfo.username" },
          totalSets: { $sum: 1 },
          totalAmount: { $sum: "$amount_paid" }
        }
      },
      { $sort: { username: 1 } }
    ]);

    res.json(purchases);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// สร้างเลขล็อตโต้ใหม่ 100 ตัว
app.post('/generate-lotteries', async (req, res) => {
  try {
    // ลบของเก่า
    await Lottery.deleteMany({});

    const lottoSet = new Set();
    while (lottoSet.size < 100) {
      const randomNum = Math.floor(Math.random() * 1000000) // 0 - 999999
        .toString()
        .padStart(6, '0'); // เติม 0 ข้างหน้าให้ครบ 6 หลัก
      lottoSet.add(randomNum);
    }

    const lotteries = Array.from(lottoSet).map((num, i) => ({
      lotto_id: "L" + (i + 1).toString().padStart(3, '0'),
      number: num,
      price: 100,
      status: "available",
    }));

    await Lottery.insertMany(lotteries);

    res.json({ message: "Lotteries generated successfully", lotteries });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// บันทึกรางวัลใหม่และลบรางวัลเก่า + มีเงินรางวัลต่างกัน
// บันทึกรางวัลใหม่และสร้าง Prize ให้ผู้เล่น
app.post('/results', async (req, res) => {
  try {
    const { prize1, prize2, prize3, pool } = req.body;
    const draw_date = new Date();

    // ลบผลเก่า
    await Result.deleteMany({});
    await Prize.deleteMany({});

    // เลือก pool
    let poolLotteries = [];
    if (pool === 'sold') {
      const purchases = await Purchase.find({});
      poolLotteries = await Lottery.find({
        lotto_id: { $in: purchases.map(p => p.lotto_id) }
      });
    } else {
      poolLotteries = await Lottery.find({});
    }

    if (!poolLotteries.length) {
      return res.status(400).json({ error: 'No lotteries available in selected pool' });
    }

    // last3 ควรไม่ซ้ำกับเลขท้ายรางวัลใหญ่
    // last3 = เลขท้าย 3 ตัวจาก prize1 + เลขหน้า 3 ตัวสุ่ม
    let last3;
    do {
      // สุ่มเลขหน้า 3 ตัว
      const randomFront = Math.floor(Math.random() * 1000)
        .toString()
        .padStart(3, '0'); // 3 ตัวหน้า
      // รวมเลขหน้า + เลขท้ายจาก prize1
      last3 = randomFront + prize1.slice(-3);
      // ตรวจสอบไม่ให้ซ้ำกับรางวัลใหญ่
    } while ([prize1, prize2, prize3].includes(last3));


    // last2 ควรไม่ซ้ำกับเลขท้ายรางวัลใหญ่
    const takenLast2 = [prize1.slice(-2), prize2.slice(-2), prize3.slice(-2)];
    let last2;
    do {
      const randomLottery = poolLotteries[Math.floor(Math.random() * poolLotteries.length)];
      last2 = randomLottery.number.slice(-2);
    } while (takenLast2.includes(last2));

    const prizeAmounts = {
      prize1: 6000000,
      prize2: 200000,
      prize3: 80000,
      last3: 4000,
      last2: 2000
    };

    // สร้าง Result ใหม่
    const results = [
      new Result({ result_id: 'R' + Date.now() + '1', draw_date, prize_type: '1st', winning_number: prize1 }),
      new Result({ result_id: 'R' + Date.now() + '2', draw_date, prize_type: '2nd', winning_number: prize2 }),
      new Result({ result_id: 'R' + Date.now() + '3', draw_date, prize_type: '3rd', winning_number: prize3 }),
      new Result({ result_id: 'R' + Date.now() + '4', draw_date, prize_type: 'last3', winning_number: last3 }),
      new Result({ result_id: 'R' + Date.now() + '5', draw_date, prize_type: 'last2', winning_number: last2 }),
    ];
    await Result.insertMany(results);

    // สร้าง Prize ให้ผู้เล่นที่ซื้อเลขตรง
    for (const lot of poolLotteries) {
      const purchases = await Purchase.find({ lotto_id: lot.lotto_id });
      for (const p of purchases) {
        if (lot.number === prize1) await Prize.create({ prize_id: 'P' + Date.now() + '1' + p.purchase_id, purchase_id: p.purchase_id, result_id: results[0]._id, prize_amount: prizeAmounts.prize1 });
        if (lot.number === prize2) await Prize.create({ prize_id: 'P' + Date.now() + '2' + p.purchase_id, purchase_id: p.purchase_id, result_id: results[1]._id, prize_amount: prizeAmounts.prize2 });
        if (lot.number === prize3) await Prize.create({ prize_id: 'P' + Date.now() + '3' + p.purchase_id, purchase_id: p.purchase_id, result_id: results[2]._id, prize_amount: prizeAmounts.prize3 });
        if (lot.number.slice(-3) === last3 && lot.number !== prize1 && lot.number !== prize2 && lot.number !== prize3)
          await Prize.create({ prize_id: 'P' + Date.now() + '4' + p.purchase_id, purchase_id: p.purchase_id, result_id: results[3]._id, prize_amount: prizeAmounts.last3 });
        if (lot.number.slice(-2) === last2 && lot.number !== prize1 && lot.number !== prize2 && lot.number !== prize3)
          await Prize.create({ prize_id: 'P' + Date.now() + '5' + p.purchase_id, purchase_id: p.purchase_id, result_id: results[4]._id, prize_amount: prizeAmounts.last2 });
      }
    }

    res.json({
      message: 'Results saved successfully',
      results,
      prizeAmounts,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



app.get('/lotteries/sold', async (req, res) => {
  try {
    const purchases = await Purchase.find({});
    const soldLotteries = await Lottery.find({
      lotto_id: { $in: purchases.map(p => p.lotto_id) }
    });
    res.json(soldLotteries);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ตรวจสอบรางวัลของผู้ใช้แต่ละเลข
// API: Get all prizes ของผู้ใช้ (claimed หรือไม่ claimed)
app.get('/user/:user_id/prizes', async (req, res) => {
  try {
    const { user_id } = req.params;
    const purchases = await Purchase.find({ user_id });

    const result = [];
    for (const p of purchases) {
      const prize = await Prize.findOne({ purchase_id: p.purchase_id })
        .populate({ path: 'result_id', select: 'prize_type winning_number' });

      result.push({
        lotto_number: p.lotto_id, // เอาเลขจริงจาก Purchase
        claimed: prize ? prize.claimed : false,
        prize_type: prize?.result_id?.prize_type,
        winning_number: prize?.result_id?.winning_number,
      });
    }

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});





// รีเซ็ตระบบทั้งหมด เหลือแค่ admin
app.post('/reset-system', async (req, res) => {
  try {
    // ลบข้อมูลทั้งหมดใน collection ที่เกี่ยวข้อง
    await Wallet.deleteMany({});
    await Lottery.deleteMany({});
    await Purchase.deleteMany({});
    await Result.deleteMany({});
    await Prize.deleteMany({});

    // ลบผู้ใช้ทั้งหมดที่ไม่ใช่ admin
    await User.deleteMany({ role: { $ne: 'admin' } });

    res.json({ message: 'System reset successfully. Only admin remains.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update wallet balance
app.put('/wallet/:user_id', async (req, res) => {
  try {
    const { balance } = req.body;
    const wallet = await Wallet.findOne({ user_id: req.params.user_id });
    if (!wallet) return res.status(404).json({ error: 'Wallet not found' });

    wallet.balance = balance;
    await wallet.save();
    res.json(wallet);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
// Get all results
app.get('/results', async (req, res) => {
  try {
    const results = await Result.find({});
    res.json({ results });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/admin/user-prizes', async (req, res) => {
  try {
    const users = await User.find({ role: { $ne: 'admin' } });
    const result = [];

    for (const user of users) {
      const purchases = await Purchase.find({ user_id: user.user_id });
      const prizes = [];

      for (const p of purchases) {
        const userPrizes = await Prize.find({ 
          purchase_id: p.purchase_id,
          claimed: false, // ✅ แสดงเฉพาะรางวัลที่ยังไม่ขึ้นเงิน
        }).populate({ path: 'result_id', select: 'prize_type winning_number' });


        for (const up of userPrizes) {
          if (up.result_id) { // ป้องกัน null
            prizes.push({
              prize_type: up.result_id.prize_type,
              prize_amount: up.prize_amount,
              winning_number: up.result_id.winning_number, // ✅ ส่ง winning_number ด้วย
            });
          }
        }
      }

      result.push({
        user_id: user.user_id, // ✅ เพิ่ม user_id
        username: user.username,
        prizes,
      });
    }

    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ขึ้นเงินรางวัลแล้ว (mark prize as claimed)
// ขึ้นเงินรางวัลแล้ว (mark prize as claimed)
app.post('/claim-prize', async (req, res) => {
  try {
    const { user_id, prize_type } = req.body;

    // หาผู้ใช้
    const purchases = await Purchase.find({ user_id });

    // หารางวัลที่ยังไม่ claimed
    let prizeToClaim = null;

    for (const p of purchases) {
      const prize = await Prize.findOne({
        purchase_id: p.purchase_id,
        claimed: false, // ✅ เฉพาะที่ยังไม่ขึ้นเงิน
      }).populate({ path: 'result_id', select: 'prize_type' });

      if (prize && prize.result_id.prize_type === prize_type) {
        prizeToClaim = prize;
        break;
      }
    }

    if (!prizeToClaim) return res.status(404).json({ error: 'Prize not found or already claimed' });

    // mark ว่า claimed
    prizeToClaim.claimed = true;
    await prizeToClaim.save();

    // เพิ่มเงินเข้ากระเป๋า
    const wallet = await Wallet.findOne({ user_id });
    wallet.balance += prizeToClaim.prize_amount;
    await wallet.save();

    res.json({ message: 'Claimed successfully', balance: wallet.balance });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ตรวจสอบแล้วแต่ไม่ถูกรางวัล
app.post('/claim-no-prize', async (req, res) => {
  try {
    const { user_id, purchase_id } = req.body;

    // ตรวจสอบว่ามี Prize อยู่แล้วหรือไม่
    const existingPrize = await Prize.findOne({ purchase_id });
    if (existingPrize) return res.status(400).json({ error: 'Prize already exists for this purchase' });

    // สร้าง Prize แบบไม่ถูกรางวัล
    const prize = new Prize({
      prize_id: 'NP' + Date.now(),
      purchase_id,
      prize_amount: 0,
      claimed: true // mark ว่าเช็คแล้ว
    });
    await prize.save();

    res.json({ message: 'Recorded as no prize' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});



// Start server
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
