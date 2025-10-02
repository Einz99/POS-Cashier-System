const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const mysql = require("mysql2/promise");
const os = require("os");
const path = require("path");
require('./transactionJob');

dotenv.config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use("/product_image", express.static(path.join(__dirname, "../src/product_image")));

// CORS configuration
app.use(cors({
  origin: [process.env.FRONTEND_URL, process.env.Staff_FRONTEND_URL],
  methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
}));

let db;

// Initialize DB connection before starting server
async function initDB() {
  db = await mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  });
  console.log("✅ MySQL connection pool created");
}

// Routes Configuration

const branchesRouter = require("./routes/branches");
app.use("/branches", branchesRouter);

const brandsRouter = require("./routes/brands");
app.use("/brands", brandsRouter);

const branchBrandRouter = require("./routes/branch_brand");
app.use("/branch-brand", branchBrandRouter);

const productsRouter = require("./routes/products");
app.use("/products", productsRouter);

const promotionsRouter = require("./routes/promotions");
app.use("/promotions", promotionsRouter);

const transactionsRouter = require("./routes/transactions");
app.use("/transactions", transactionsRouter);

const transactionProductsRouter = require("./routes/transaction_products");
app.use("/transaction-products", transactionProductsRouter);

const employeesRouter = require("./routes/employees");
app.use("/employees", employeesRouter);

let temporaryStorage = {};

app.post('/storeData', (req, res) => {
  const { key, data } = req.body;
  if (!key || !data) {
    return res.status(400).send('Key and data are required');
  }

  temporaryStorage[key] = data;
  console.log('Data stored in temporaryStorage:', temporaryStorage);  // Debugging log
  res.status(200).send({ message: 'Data stored successfully' });
});

// Endpoint to retrieve and delete data
app.get('/getData/:key', (req, res) => {
  const { key } = req.params;
  console.log(`Fetching data for key: ${key}`);  // Log the key being fetched

  const data = temporaryStorage[key];
  if (!data) {
    console.log(`No data found for key: ${key}`);  // Log if no data is found
    return res.status(404).send('Data not found');
  }

  res.status(200).send({ data });
  delete temporaryStorage[key]; // Delete data after retrieval
});


const getLocalIP = () => {
  const interfaces = os.networkInterfaces();
  for (const name in interfaces) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
};

// Start server AFTER DB connects
const PORT = process.env.PORT || 5000;
initDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port http://${getLocalIP()}:${PORT}`);
  });
}).catch(err => {
  console.error("❌ Failed to connect to DB:", err);
  process.exit(1);
});
