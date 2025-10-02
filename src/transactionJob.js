const cron = require('node-cron');
const db = require('./config/db');

// Function to delete transactions older than 3 years
const deleteOldTransactions = () => {
  const query = `
    DELETE FROM transactions
    WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 YEAR)
  `;

  db.query(query, (err, results) => {
    if (err) {
      console.error('Error deleting old transactions:', err);
    } else {
      console.log(`✅ Deleted ${results.affectedRows} old transactions.`);
    }
  });
};

// Schedule the task to run every day at midnight
cron.schedule('0 0 * * *', () => {
  console.log('🧹 Running daily cleanup job...');
  deleteOldTransactions();
});