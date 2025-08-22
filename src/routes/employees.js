const express = require('express');
const router = express.Router();
const employeeController = require('../controllers/employeeControllers');

// Get all employees
router.get('/', employeeController.getAllEmployees);
router.post('/', employeeController.createEmployee);
router.put('/:id', employeeController.updateEmployee);
router.delete('/:id', employeeController.deleteEmployee);

// Auth Login
router.post('/login', employeeController.login);

module.exports = router;