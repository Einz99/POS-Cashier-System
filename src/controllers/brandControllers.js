const db = require('../config/db');

// Controller to get all brands
const getAllBrands = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM brands');
        res.status(200).json(rows);
    } catch (error) {
        console.error('Error fetching brands:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}

module.exports = {
    getAllBrands,
}