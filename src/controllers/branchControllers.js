const db = require('../config/db');

// Controller to get all branches
const getAllBranches = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM branches');
        res.status(200).json(rows);
    } catch (error) {
        console.error('Error fetching branches:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}

module.exports = {
    getAllBranches,
}