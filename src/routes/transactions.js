const express = require('express');
const router = express.Router();
const transactionsController = require('../controllers/transactionsControllers');

// Get all transactions
router.get('/', transactionsController.getAllTransactions);

// Create new transaction
router.post('/', transactionsController.createTransaction);

module.exports = router;