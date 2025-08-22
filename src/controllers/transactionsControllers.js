const db = require('../config/db');

// Get all transactions
const getAllTransactions = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM transactions');
    res.status(200).json(rows);
  } catch (error) {
    console.error("Error fetching transactions:", error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
}

module.exports = {
  getAllTransactions,
};