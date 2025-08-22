const express = require('express');
const routes = express.Router();
const branchBrandController = require('../controllers/branchBrandControllers');

// Get all brands
routes.get('/', branchBrandController.getAllBranchBrands);

module.exports = routes;