const db = require('../config/db');

// Controller to get all products
const getAllProducts = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM products');
        res.status(200).json(rows);
    } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}

// Controller to create a new product
const createProduct = async (req, res) => {
  try {
    const { bbID, name, category, price, stock, alert } = req.body;
    const picture = req.file ? req.file.filename : null; // store filename only

    const [result] = await db.query(
      `INSERT INTO products 
       (branch_brand_id, product_name, category, picture, price, stock, alert_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [bbID, name, category, picture, price, stock, alert]
    );

    res.status(201).json({ message: "Product created", productId: result.insertId });
  } catch (error) {
    console.error("Error creating product:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};


// Controller to update an existing product
const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { bbID, name, category, price, stock, alert, isActive } = req.body;
    const picture = req.file ? req.file.filename : null;

    let sql = `UPDATE products SET 
                 branch_brand_id=?, product_name=?, category=?, 
                 price=?, stock=?, alert_at=?, is_active=?, modified_at=CURRENT_TIMESTAMP`;

    const params = [bbID, name, category, price, stock, alert, isActive];

    if (picture) {
      sql += `, picture=?`;
      params.push(picture);
    }

    sql += ` WHERE id=?`;
    params.push(id);

    await db.query(sql, params);

    res.status(200).json({ message: "Product updated" });
  } catch (error) {
    console.error("Error updating product:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Controller to update product stock and status
const updateProductStock = async (req, res) => {
  try {
    const { id } = req.params;
    const { stock } = req.body;

    await db.query(
      'UPDATE products SET stock=?, modified_at=CURRENT_TIMESTAMP WHERE id=?',
      [stock, id]
    );

    res.status(200).json({ message: 'Product stock updated' });
  } catch (error) {
    console.error('Error updating stock:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

const updateProductStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    await db.query(
      'UPDATE products SET is_active=?, modified_at=CURRENT_TIMESTAMP WHERE id=?',
      [isActive, id]
    );

    res.status(200).json({ message: 'Product status updated' });
  } catch (error) {
    console.error('Error updating status:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Controller to delete a product
const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    await db.query('DELETE FROM products WHERE id=?', [id]);

    res.status(200).json({ message: 'Product deleted' });
  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = {
  getAllProducts,
  createProduct,
  updateProduct,
  updateProductStock,
  updateProductStatus,
  deleteProduct
};