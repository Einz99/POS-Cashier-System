const express = require('express');
const router = express.Router();
const transactionsController = require('../controllers/transactionsControllers');

// Get all transactions
router.get('/', transactionsController.getAllTransactions);

module.exports = router;