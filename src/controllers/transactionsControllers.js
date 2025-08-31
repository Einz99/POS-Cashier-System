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

// Create a new transaction
const createTransaction = async (req, res) => {
  const {
    payment_method, // 'Cash' or 'E-Wallet'
    ref_number,     // nullable for Cash
    promo_id,
    items,          // [{ product_id, quantity, price }]
    bogo_free_id,   // optional, product ID
    subtotal,
    discount,
    total
  } = req.body;

  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    // Insert transaction
    const [transactionResult] = await conn.query(
      `INSERT INTO transactions
      (promotion_id, payment_method, total_amount, discount_amount, net_amount, ref_number, status)
      VALUES (?, ?, ?, ?, ?, ?, 'Completed')`,
      [promo_id || null, payment_method, subtotal, discount, total, ref_number || null]
    );

    const transactionId = transactionResult.insertId;

    // Insert products and subtract stock
    for (const item of items) {
      await conn.query(
        `INSERT INTO transaction_products (transaction_id, product_id, quantity, price)
         VALUES (?, ?, ?, ?)`,
        [transactionId, item.product_id, item.quantity, item.price]
      );

      await conn.query(
        `UPDATE products SET stock = stock - ? WHERE id = ?`,
        [item.quantity, item.product_id]
      );
    }

    // Handle BOGO free item if exists
    if (bogo_free_id) {
      await conn.query(
        `INSERT INTO transaction_products (transaction_id, product_id, quantity, price)
         VALUES (?, ?, 1, 0)`,
        [transactionId, bogo_free_id]
      );

      await conn.query(
        `UPDATE products SET stock = stock - 1 WHERE id = ?`,
        [bogo_free_id]
      );
    }

    await conn.commit();
    res.status(201).json({ id: transactionId, message: "Transaction completed successfully" });
  } catch (error) {
    await conn.rollback();
    console.error("Transaction failed:", error);
    res.status(500).json({ error: "Transaction failed" });
  } finally {
    conn.release();
  }
};

module.exports = {
  getAllTransactions,
  createTransaction,
};