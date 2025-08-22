const express = require('express');
const routes = express.Router();
const brandController = require('../controllers/brandControllers');

// Get all brands
routes.get('/', brandController.getAllBrands);

module.exports = routes;