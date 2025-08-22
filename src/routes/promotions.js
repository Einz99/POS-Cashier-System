const express = require('express');
const router = express.Router();
const promotionsController = require('../controllers/promotionsControllers');

// Get all promotions
router.get('/', promotionsController.getAllPromotions);

// Create a new promotion
router.post('/', promotionsController.createPromotion);

// Update promotion details
router.put('/:id', promotionsController.updatePromotion);

// Delete a promotion
router.delete('/:id', promotionsController.deletePromotion);

module.exports = router;