const express = require('express');
const router = express.Router();
const productController = require('../controllers/productControllers');
const multer = require('multer');
const path = require('path');

// Storage setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "src/product_image/"); // save here
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + ext); // unique filename
  }
});

const upload = multer({ storage });

// Get all products
router.get('/', productController.getAllProducts);

// create a new product
router.post("/", upload.single("picture"), productController.createProduct);

// update product details
router.put("/:id", upload.single("picture"), productController.updateProduct);

// update product stock and status
router.put('/stock/:id', productController.updateProductStock);
router.put('/status/:id', productController.updateProductStatus);

// delete a product
router.delete('/:id', productController.deleteProduct);

module.exports = router;