const express = require('express');
const router = express.Router();
const transactionProductController = require('../controllers/transactionProductsControllers');

// Get all transaction products
router.get('/', transactionProductController.getAllTransactionProducts);

module.exports = router;