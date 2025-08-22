const db = require('../config/db');
const bcrypt = require('bcrypt')
const nodemailer = require('nodemailer')

// Get all employees
const getAllEmployees = async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT id, name, email, role, branch_id, added_at, modified_at
            FROM employees
        `);
        res.status(200).json(rows);
    } catch (error) {
        console.error('Error fetching employees:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

// Helper to generate random 10-character alphanumeric
const generatePassword = (length = 10) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let pwd = '';
  for (let i = 0; i < length; i++) {
    pwd += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return pwd;
};

const createEmployee = async (req, res) => {
  const { name, email, role, branch } = req.body;

  if (!name || !email || !role) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  let plainPassword;

  if (role === 'Staff') {
    // Fixed password for Staff
    plainPassword = 'Ca1sh2ie3r';
  } else {
    // Generate random password for other roles
    plainPassword = generatePassword(); // your random generator
  }

  try {
    // Encrypt password
    const hashedPassword = await bcrypt.hash(plainPassword, 10);

    const [result] = await db.query(
      `INSERT INTO employees (name, email, password, role, branch_id)
       VALUES (?, ?, ?, ?, ?)`,
      [name, email, hashedPassword, role, branch || null]
    );

    // Send email only if not Staff
    if (role !== 'Staff') {
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.Email,      // your Gmail
          pass: process.env.Password,   // app password
        },
      });

      await transporter.sendMail({
        from: `"Admin" <${process.env.Email}>`,
        to: email,
        subject: 'Your account has been created',
        text: `Hello ${name},\n\nYour account has been created.\nEmail: ${email}\nPassword: ${plainPassword}\n\nPlease change your password after logging in.`,
      });
    }

    res.status(201).json({ message: 'Employee created', id: result.insertId });
  } catch (error) {
    console.error('Error creating employee:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// Update an employee
const updateEmployee = async (req, res) => {
    const { id } = req.params;
    const { name, email, role, branch } = req.body;

    try {
        const [result] = await db.query(
            `UPDATE employees
             SET name = ?, email = ?, role = ?, branch_id = ?, modified_at = NOW()
             WHERE id = ?`,
            [name, email, role, branch, id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Employee not found' });
        }

        res.status(200).json({ message: 'Employee updated' });
    } catch (error) {
        console.error('Error updating employee:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

// Delete an employee
const deleteEmployee = async (req, res) => {
    const { id } = req.params;

    try {
        const [result] = await db.query('DELETE FROM employees WHERE id = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Employee not found' });
        }

        res.status(200).json({ message: 'Employee deleted' });
    } catch (error) {
        console.error('Error deleting employee:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

const login = async (req, res) => {
  const { email, password } = req.body
  console.log(req.body);

  if (!email || !password) {
    return res.status(400).json({ message: 'Missing email or password' })
  }

  try {
    const [rows] = await db.query('SELECT * FROM employees WHERE email = ?', [email])
    const employee = rows[0]

    if (!employee) {
      return res.status(401).json({ message: 'Invalid email or password' })
    }

    const match = employee.password === password
    // const match = await bcrypt.compare(password, employee.password)
    if (!match) {
      return res.status(401).json({ message: 'Invalid email or password' })
    }

    // Return employee data without password
    const { password: _, ...empData } = employee
    res.json(empData)
  } catch (err) {
    console.error(err)
    res.status(500).json({ message: 'Internal server error' })
  }
}

module.exports = {
    getAllEmployees,
    createEmployee,
    updateEmployee,
    deleteEmployee,
    login,
};