const express = require('express');
const routers = express.Router();
const branchController = require('../controllers/branchControllers');

// Get all branches
routers.get('/', branchController.getAllBranches);

module.exports = routers;