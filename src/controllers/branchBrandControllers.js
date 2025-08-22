const db = require('../config/db');

// Controller to get all branch-brand associations
const getAllBranchBrands = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM branch_brand');
        res.status(200).json(rows);
    } catch (error) {
        console.error('Error fetching brands:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}

module.exports = {
    getAllBranchBrands,
}