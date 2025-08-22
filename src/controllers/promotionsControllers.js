const db = require('../config/db');

// Controller to get all promotions
const getAllPromotions = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT 
        p.id,
        p.promotion_name AS name,
        p.description,
        p.type,
        p.value,
        p.start_date,
        p.end_date,
        p.start_time_frame,
        p.end_time_frame,
        p.minimum_spend,
        p.minimum_item,
        GROUP_CONCAT(pp.product_id) AS products
      FROM promotions p
      LEFT JOIN promotion_products pp ON p.id = pp.promotion_id
      GROUP BY p.id
      ORDER BY p.id DESC
    `);

    const formatted = rows.map(row => ({
      ...row,
      products: row.products 
        ? row.products.split(',').map(id => Number(id)) // 👈 convert to number[]
        : []
    }));

    res.status(200).json(formatted);
  } catch (error) {
    console.error('Error fetching promotions:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Controller to create a new promotion
const createPromotion = async (req, res) => {
  const conn = await db.getConnection(); // get connection for transaction
  try {
    const {
      name,
      description,
      type,
      value,
      start_date,
      end_date,
      start_time_frame,
      end_time_frame,
      minimum_spend,
      minimum_item,
      products = []
    } = req.body;

    await conn.beginTransaction();

    // insert into promotions
    const [result] = await conn.query(
      `INSERT INTO promotions 
        (promotion_name, description, type, value, start_date, end_date, start_time_frame, end_time_frame, minimum_spend, minimum_item) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, description, type, value, start_date, end_date, start_time_frame, end_time_frame, minimum_spend, minimum_item]
    );

    const promotionId = result.insertId;

    // bulk insert into promotion_products if products provided
    if (products.length > 0) {
      const values = products.map(pid => [promotionId, pid]);
      await conn.query(
        `INSERT INTO promotion_products (promotion_id, product_id) VALUES ?`,
        [values]
      );
    }

    await conn.commit();
    res.status(201).json({ id: promotionId, message: 'Promotion created successfully' });
  } catch (error) {
    await conn.rollback();
    console.error('Error creating promotion:', error);
    res.status(500).json({ message: 'Internal server error' });
  } finally {
    conn.release();
  }
};

// Controller to update an existing promotion
const updatePromotion = async (req, res) => {
  const conn = await db.getConnection();
  try {
    const { id } = req.params;
    const {
      name,
      description,
      type,
      value,
      start_date,
      end_date,
      start_time_frame,
      end_time_frame,
      minimum_spend,
      minimum_item,
      products = []
    } = req.body;

    await conn.beginTransaction();

    // update promotion itself
    await conn.query(
      `UPDATE promotions 
       SET promotion_name = ?, description = ?, type = ?, value = ?, start_date = ?, end_date = ?, 
           start_time_frame = ?, end_time_frame = ?, minimum_spend = ?, minimum_item = ?
       WHERE id = ?`,
      [name, description, type, value, start_date, end_date, start_time_frame, end_time_frame, minimum_spend, minimum_item, id]
    );

    // clear existing product links
    await conn.query(`DELETE FROM promotion_products WHERE promotion_id = ?`, [id]);

    // insert new product links if any
    if (products.length > 0) {
      const values = products.map(pid => [id, pid]);
      await conn.query(
        `INSERT INTO promotion_products (promotion_id, product_id) VALUES ?`,
        [values]
      );
    }

    await conn.commit();
    res.json({ id, message: "Promotion updated successfully" });
  } catch (error) {
    await conn.rollback();
    console.error("Error updating promotion:", error);
    res.status(500).json({ message: "Internal server error" });
  } finally {
    conn.release();
  }
};

// Controller to delete a promotion
const deletePromotion = async (req, res) => {
    try {
        const { id } = req.params;

        await db.query('DELETE FROM promotions WHERE id=?', [id]);

        res.status(200).json({ message: 'Promotion deleted' });
    } catch (error) {
        console.error('Error deleting promotion:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

module.exports = {
    getAllPromotions,
    createPromotion,
    updatePromotion,
    deletePromotion
};