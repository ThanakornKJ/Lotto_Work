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
  lotto_id: String,
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
  result_id: String,
  prize_amount: Number
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
app.post('/results', async (req, res) => {
  try {
    const { prize1, prize2, prize3 } = req.body;
    const draw_date = new Date();

    await Result.deleteMany({});
    await Prize.deleteMany({});

    // เลขท้าย 3 ตัว จากรางวัลที่ 1
    const last3 = prize1.slice(-3);

    // เลขท้าย 2 ตัว สุ่มจากล็อตโต้ 100 ตัว
    const allNumbers = await Lottery.find({});
    const randomNum = allNumbers[Math.floor(Math.random() * allNumbers.length)].number;
    const last2 = randomNum.slice(-2);

    const prizeAmounts = {
      prize1: 6000000,
      prize2: 200000,
      prize3: 80000,
      last3: 4000,
      last2: 2000
    };

    const results = [
      new Result({ result_id: 'R' + Date.now() + '1', draw_date, prize_type: '1st', winning_number: prize1 }),
      new Result({ result_id: 'R' + Date.now() + '2', draw_date, prize_type: '2nd', winning_number: prize2 }),
      new Result({ result_id: 'R' + Date.now() + '3', draw_date, prize_type: '3rd', winning_number: prize3 }),
      new Result({ result_id: 'R' + Date.now() + '4', draw_date, prize_type: 'last3', winning_number: last3 }),
      new Result({ result_id: 'R' + Date.now() + '5', draw_date, prize_type: 'last2', winning_number: last2 }),
    ];

    await Result.insertMany(results);

    // สร้าง prize entries สำหรับผู้เล่น (ถ้าต้องการ)
    const prizeDocs = results.map(r => new Prize({
      prize_id: 'P' + Date.now() + r.prize_type,
      result_id: r.result_id,
      prize_amount: prizeAmounts[r.prize_type === '1st' ? 'prize1'
                    : r.prize_type === '2nd' ? 'prize2'
                    : r.prize_type === '3rd' ? 'prize3'
                    : r.prize_type === 'last3' ? 'last3'
                    : 'last2'],
      purchase_id: null // ว่างตอนนี้ เพราะยังไม่มีผู้เล่นซื้อ
    }));

    await Prize.insertMany(prizeDocs);

    res.json({
      message: 'Results reset and saved successfully with prize amounts',
      results,
      prizeAmounts,
    });
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


// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
