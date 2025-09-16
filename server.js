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
    const { user_id, username, password, email } = req.body;
    const role = 'member';
    const register_date = new Date();
    const user = new User({ user_id, username, password, email, role, register_date });
    await user.save();

    // Create Wallet
    const wallet = new Wallet({ wallet_id: 'W'+user_id, user_id, balance: 5000 });
    await wallet.save();

    res.status(201).json({ message: 'Register success', user });
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
    if (!wallet || wallet.balance < amount_paid) return res.status(400).json({ error: 'Insufficient balance' });

    // Check lottery availability
    const lottery = await Lottery.findOne({ lotto_id });
    if (!lottery || lottery.status !== 'available') return res.status(400).json({ error: 'Lottery not available' });

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

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
