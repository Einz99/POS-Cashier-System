CREATE DATABASE Afflatus_POS;
USE Afflatus_POS;

# DROPPING
DROP DATABASE Afflatus_POS;

# TABLES

CREATE TABLE branches(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    branch_name VARCHAR(255),
    created_at DATETIME default CURRENT_TIMESTAMP NOT NULL,
    modified_at DATETIME default CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE brands(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    brand_name VARCHAR(255),
    created_at DATETIME default CURRENT_TIMESTAMP NOT NULL,
    modified_at DATETIME default CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE branch_brand(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    branch_id INT NOT NULL,
    brand_id INT NOT NULL,
    FOREIGN KEY (branch_id) references branches(id) ON DELETE CASCADE,
    FOREIGN KEY (brand_id) references brands(id) ON DELETE CASCADE
);

CREATE TABLE products(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    branch_brand_id INT NOT NULL,
    FOREIGN KEY (branch_brand_id) references branch_brand(id) ON DELETE CASCADE,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(225),
    picture VARCHAR(255),
    price DOUBLE NOT NULL,
    stock INT NOT NULL,
    alert_at INT NOT NULL,
    is_active BOOL NOT NULL default TRUE,
    created_at DATETIME default CURRENT_TIMESTAMP NOT NULL,
    modified_at DATETIME default CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE promotions(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    promotion_name VARCHAR(255),
    description TEXT,
    type ENUM('Percentage', 'Fixed', 'BOGO') NOT NULL,
    value DOUBLE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_time_frame TIME,
    end_time_frame TIME,
    minimum_spend INT,
    minimum_item INT,
    created_at DATETIME default CURRENT_TIMESTAMP NOT NULL,
    modified_at DATETIME default CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE promotion_products (
    promotion_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (promotion_id, product_id), -- prevents duplicates
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT PRIMARY KEY,
    promotion_id INT NULL, -- optional link if a promotion was applied
    FOREIGN KEY (promotion_id) REFERENCES promotions(id) ON DELETE SET NULL,
    payment_method ENUM('Cash', 'E-Wallet') NOT NULL,
    total_amount DOUBLE NOT NULL DEFAULT 0,
    discount_amount DOUBLE NOT NULL DEFAULT 0,
    net_amount DOUBLE NOT NULL DEFAULT 0,
    status ENUM('Pending', 'Completed', 'Cancelled', 'Refunded') DEFAULT 'Completed',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE transaction_products (
    transaction_id INT NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    product_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    price DOUBLE NOT NULL, -- unit price at transaction time
    subtotal DOUBLE GENERATED ALWAYS AS (quantity * price) STORED, -- auto compute
    PRIMARY KEY (transaction_id, product_id)
);

CREATE TABLE employees(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    branch_id INT,
    FOREIGN KEY (branch_id) references branches(id) ON DELETE CASCADE,
    added_at DATETIME default CURRENT_TIMESTAMP NOT NULL,
    modified_at DATETIME default CURRENT_TIMESTAMP NOT NULL
);

select * from employees;

# -------------------------------------------

# Mock Data Creation

INSERT INTO branches (branch_name)
VALUES ('Pasig'), ('Maysilo');


INSERT INTO brands (brand_name)
VALUES ('Bang Bang Bangus'), ('Carneneighbor'), ('Cuptolyo');

INSERT INTO branch_brand (branch_id, brand_id)
VALUES (1, 1), (1, 2), (1, 3), (2, 1);

INSERT INTO products (branch_brand_id, product_name, price, stock, alert_at, category)
VALUES
-- XL Bangus flavors (branch_brand_id 1 and 4)
(1, 'XL Bangus - Original', 325.00, 80, 10, 'Specials'),
(1, 'XL Bangus - Cheese', 340.00, 70, 8, 'Specials'),
(1, 'XL Bangus - Salted Egg', 350.00, 65, 7, 'Specials'),
(1, 'XL Bangus - Inasal', 335.00, 75, 9, 'Specials'),
(1, 'XL Bangus - Spicy Pares', 345.00, 60, 6, 'Specials'),
(4, 'XL Bangus - Original', 325.00, 80, 10, 'Specials'),
(4, 'XL Bangus - Cheese', 340.00, 70, 8, 'Specials'),
(4, 'XL Bangus - Salted Egg', 350.00, 65, 7, 'Specials'),
(4, 'XL Bangus - Inasal', 335.00, 75, 9, 'Specials'),
(4, 'XL Bangus - Spicy Pares', 345.00, 60, 6, 'Specials'),

-- L Bangus flavors (branch_brand_id 1 and 4)
(1, 'L Bangus - Original', 265.00, 100, 12, 'Specials'),
(1, 'L Bangus - Cheese', 275.00, 95, 10, 'Specials'),
(1, 'L Bangus - Salted Egg', 285.00, 90, 9, 'Specials'),
(1, 'L Bangus - Inasal', 270.00, 85, 8, 'Specials'),
(1, 'L Bangus - Spicy Pares', 280.00, 80, 8, 'Specials'),
(4, 'L Bangus - Original', 265.00, 100, 12, 'Specials'),
(4, 'L Bangus - Cheese', 275.00, 95, 10, 'Specials'),
(4, 'L Bangus - Salted Egg', 285.00, 90, 9, 'Specials'),
(4, 'L Bangus - Inasal', 270.00, 85, 8, 'Specials'),
(4, 'L Bangus - Spicy Pares', 280.00, 80, 8, 'Specials'),

-- Roast Bangus flavors (branch_brand_id 1 and 4)
(1, 'Roast Bangus - Kamatis at Sibuyas', 325.00, 60, 6, 'Specials'),
(1, 'Roast Bangus - Cheese', 335.00, 55, 5, 'Specials'),
(1, 'Roast Bangus - Inasal', 330.00, 65, 7, 'Specials'),
(4, 'Roast Bangus - Kamatis at Sibuyas', 325.00, 60, 6, 'Specials'),
(4, 'Roast Bangus - Cheese', 335.00, 55, 5, 'Specials'),
(4, 'Roast Bangus - Inasal', 330.00, 65, 7, 'Specials'),

-- 2-in-1 Category (branch_brand_id 1 and 4)
(1, 'Bangus Sisig', 350.00, 70, 7, '2in1'),
(1, 'Bangus Belly', 379.00, 60, 6, '2in1'),
(1, 'Bangus Relyeno', 340.00, 55, 5, '2in1'),
(1, 'Dinakdakan', 99.00, 120, 12, '2in1'),
(1, 'Laing', 65.00, 150, 15, '2in1'),
(1, 'Sinantulan', 60.00, 140, 14, '2in1'),
(4, 'Bangus Sisig', 350.00, 70, 7, '2in1'),
(4, 'Bangus Belly', 379.00, 60, 6, '2in1'),
(4, 'Bangus Relyeno', 340.00, 55, 5, '2in1'),
(4, 'Dinakdakan', 99.00, 120, 12, '2in1'),
(4, 'Laing', 65.00, 150, 15, '2in1'),
(4, 'Sinantulan', 60.00, 140, 14, '2in1'),

-- Meals (branch_brand_id 1 and 4)
(1, 'SOLO A', 129.00, 200, 20, 'Meals'),
(1, 'SOLO B', 129.00, 180, 18, 'Meals'),
(1, 'SOLO C', 139.00, 170, 17, 'Meals'),
(1, 'SOLO D', 149.00, 160, 16, 'Meals'),
(1, 'SOLO E', 179.00, 150, 15, 'Meals'),
(1, 'SOLO F', 230.00, 140, 14, 'Meals'),
(1, 'SOLO G', 240.00, 130, 13, 'Meals'),
(1, 'Pompano', 399.00, 80, 8, 'Meals'),
(1, 'Tilapia', 249.00, 90, 9, 'Meals'),
(1, 'Classic Daing with Itlog & Atsara', 99.00, 110, 11, 'Meals'),
(1, 'Classic Daing with Itlog na Maalat & Kamatis', 129.00, 100, 10, 'Meals'),
(1, 'Classic Daing with Talong at Bagoong & Atsara', 149.00, 95, 9, 'Meals'),
(4, 'SOLO A', 129.00, 200, 20, 'Meals'),
(4, 'SOLO B', 129.00, 180, 18, 'Meals'),
(4, 'SOLO C', 139.00, 170, 17, 'Meals'),
(4, 'SOLO D', 149.00, 160, 16, 'Meals'),
(4, 'SOLO E', 179.00, 150, 15, 'Meals'),
(4, 'SOLO F', 230.00, 140, 14, 'Meals'),
(4, 'SOLO G', 240.00, 130, 13, 'Meals'),
(4, 'Pompano', 399.00, 80, 8, 'Meals'),
(4, 'Tilapia', 249.00, 90, 9, 'Meals'),
(4, 'Classic Daing with Itlog & Atsara', 99.00, 110, 11, 'Meals'),
(4, 'Classic Daing with Itlog na Maalat & Kamatis', 129.00, 100, 10, 'Meals'),
(4, 'Classic Daing with Talong at Bagoong & Atsara', 149.00, 95, 9, 'Meals'),

-- Extras (branch_brand_id 1 and 4)
(1, 'Rice', 15.00, 500, 50, 'Extras'),
(1, 'Inasal Oil', 10.00, 300, 30, 'Extras'),
(1, 'Atsara', 15.00, 200, 20, 'Extras'),
(1, 'Toasted Garlic', 10.00, 250, 25, 'Extras'),
(1, 'Suka', 10.00, 280, 28, 'Extras'),
(4, 'Rice', 15.00, 500, 50, 'Extras'),
(4, 'Inasal Oil', 10.00, 300, 30, 'Extras'),
(4, 'Atsara', 15.00, 200, 20, 'Extras'),
(4, 'Toasted Garlic', 10.00, 250, 25, 'Extras'),
(4, 'Suka', 10.00, 280, 28, 'Extras'),

-- Shanghai (branch_brand_id 1 and 4)
(1, '5pcs Shanghai Ala Carte', 59.00, 150, 15, 'Shanghai'),
(1, '4pcs Shanghai Meal', 69.00, 140, 14, 'Shanghai'),
(1, '4pcs Shanghai Meal with Egg', 79.00, 130, 13, 'Shanghai'),
(1, '10pcs Shanghai Ala Carte', 99.00, 120, 12, 'Shanghai'),
(1, '15pcs Shanghai Ala Carte', 139.00, 100, 10, 'Shanghai'),
(4, '5pcs Shanghai Ala Carte', 59.00, 150, 15, 'Shanghai'),
(4, '4pcs Shanghai Meal', 69.00, 140, 14, 'Shanghai'),
(4, '4pcs Shanghai Meal with Egg', 79.00, 130, 13, 'Shanghai'),
(4, '10pcs Shanghai Ala Carte', 99.00, 120, 12, 'Shanghai'),
(4, '15pcs Shanghai Ala Carte', 139.00, 100, 10, 'Shanghai'),

-- Drinks (branch_brand_id 2)
(2, 'Cuptolyo Mango Shake', 89.00, 300, 30, 'Drinks'),
(2, 'Cuptolyo Buko Pandan', 85.00, 280, 28, 'Drinks'),
(2, 'Cuptolyo Chocolate Shake', 95.00, 250, 25, 'Drinks'),
(2, 'Cuptolyo Strawberry Shake', 99.00, 260, 26, 'Drinks'),
(2, 'Cuptolyo Avocado Shake', 109.00, 240, 24, 'Drinks'),

-- Carne Meals (branch_brand_id 3)
(3, 'Carne Tapsilog', 120.00, 180, 18, 'Carne'),
(3, 'Carne Longsilog', 110.00, 190, 19, 'Carne'),
(3, 'Carne Tocilog', 115.00, 170, 17, 'Carne'),
(3, 'Carne Porksilog', 130.00, 160, 16, 'Carne'),
(3, 'Carne Hotsilog', 100.00, 200, 20, 'Carne');

SELECT * FROM products
WHERE branch_brand_id = 3;

UPDATE products
SET stock = 200
WHERE ID = 83;

INSERT INTO promotions (promotion_name, description, type, value, start_date, end_date, start_time_frame, end_time_frame, minimum_spend, minimum_item)
VALUES
('Promo 1', 'Special promotion to boost sales.', 'bogo', 1, '2025-04-12', '2025-04-24', NULL, NULL, NULL, 4),
('Promo 2', 'Special promotion to boost sales.', 'percentage', 26, '2025-12-26', '2026-02-05', '13:00', '14:00', NULL, NULL),
('Promo 3', 'Special promotion to boost sales.', 'bogo', 1, '2025-04-24', '2025-05-26', NULL, NULL, NULL, 2),
('Promo 4', 'Special promotion to boost sales.', 'percentage', 7, '2026-01-16', '2026-01-23', '18:00', '19:00', NULL, NULL),
('Promo 5', 'Special promotion to boost sales.', 'fixed', 27, '2025-09-01', '2025-10-17', '12:00', '15:00', NULL, NULL),
('Promo 6', 'Special promotion to boost sales.', 'bogo', 1, '2025-08-25', '2025-10-16', NULL, NULL, NULL, 4),
('Promo 7', 'Special promotion to boost sales.', 'fixed', 37, '2025-08-10', '2025-08-31', '16:00', '22:00', NULL, NULL),
('Promo 8', 'Special promotion to boost sales.', 'fixed', 299, '2025-02-22', '2025-04-14', NULL, NULL, NULL, 2),
('Promo 9', 'Special promotion to boost sales.', 'percentage', 37, '2026-01-24', '2026-03-02', NULL, NULL, NULL, 2),
('Promo 10', 'Special promotion to boost sales.', 'fixed', 117, '2025-10-12', '2025-11-16', NULL, NULL, NULL, NULL),
('Promo 11', 'Special promotion to boost sales.', 'bogo', 1, '2025-07-06', '2025-08-01', '18:00', '21:00', NULL, 8),
('Promo 12', 'Special promotion to boost sales.', 'bogo', 1, '2025-12-02', '2026-01-29', NULL, NULL, NULL, 6),
('Promo 13', 'Special promotion to boost sales.', 'percentage', 16, '2025-11-26', '2025-12-23', NULL, NULL, NULL, NULL),
('Promo 14', 'Special promotion to boost sales.', 'percentage', 42, '2025-08-29', '2025-09-21', '14:00', '15:00', NULL, 5),
('Promo 15', 'Special promotion to boost sales.', 'bogo', 1, '2026-01-17', '2026-03-05', '12:00', '21:00', NULL, 3),
('Promo 16', 'Special promotion to boost sales.', 'percentage', 43, '2025-08-21', '2025-08-29', '14:00', '18:00', NULL, 3),
('Promo 17', 'Special promotion to boost sales.', 'bogo', 1, '2025-07-28', '2025-09-25', '11:00', '12:00', NULL, 3),
('Promo 18', 'Special promotion to boost sales.', 'fixed', 406, '2025-11-23', '2025-12-27', NULL, NULL, 800, NULL),
('Promo 19', 'Special promotion to boost sales.', 'bogo', 1, '2026-01-28', '2026-03-26', '17:00', '18:00', NULL, 8),
('Promo 20', 'Special promotion to boost sales.', 'bogo', 1, '2025-04-14', '2025-04-28', NULL, NULL, NULL, 6),
('Promo 21', 'Special promotion to boost sales.', 'bogo', 1, '2025-03-09', '2025-04-25', '15:00', '16:00', NULL, 8),
('Promo 22', 'Special promotion to boost sales.', 'bogo', 1, '2025-09-16', '2025-10-11', '10:00', '21:00', NULL, 2),
('Promo 23', 'Special promotion to boost sales.', 'fixed', 47, '2025-04-17', '2025-05-16', NULL, NULL, NULL, NULL),
('Promo 24', 'Special promotion to boost sales.', 'fixed', 121, '2025-10-08', '2025-10-24', NULL, NULL, NULL, NULL),
('Promo 25', 'Special promotion to boost sales.', 'bogo', 1, '2025-05-25', '2025-07-12', NULL, NULL, NULL, 8),
('Promo 26', 'Special promotion to boost sales.', 'bogo', 1, '2025-03-23', '2025-04-21', NULL, NULL, NULL, 3),
('Promo 27', 'Special promotion to boost sales.', 'percentage', 39, '2025-06-03', '2025-08-02', '11:00', '15:00', NULL, 3),
('Promo 28', 'Special promotion to boost sales.', 'percentage', 40, '2025-09-19', '2025-10-14', NULL, NULL, NULL, 2),
('Promo 29', 'Special promotion to boost sales.', 'fixed', 401, '2025-04-22', '2025-05-15', '11:00', '18:00', NULL, 6),
('Promo 30', 'Special promotion to boost sales.', 'bogo', 1, '2026-02-10', '2026-02-22', NULL, NULL, NULL, 6),
('Promo 31', 'Special promotion to boost sales.', 'fixed', 492, '2025-08-29', '2025-10-21', NULL, NULL, 800, NULL),
('Promo 32', 'Special promotion to boost sales.', 'fixed', 154, '2025-10-24', '2025-11-23', '20:00', '21:00', NULL, 3),
('Promo 33', 'Special promotion to boost sales.', 'fixed', 232, '2025-06-18', '2025-07-03', NULL, NULL, 1500, NULL),
('Promo 34', 'Special promotion to boost sales.', 'fixed', 166, '2025-05-11', '2025-07-04', '12:00', '18:00', NULL, 3),
('Promo 35', 'Special promotion to boost sales.', 'fixed', 428, '2025-07-15', '2025-08-20', '20:00', '21:00', NULL, 2),
('Promo 36', 'Special promotion to boost sales.', 'fixed', 425, '2025-05-09', '2025-06-19', '17:00', '19:00', 1000, NULL),
('Promo 37', 'Special promotion to boost sales.', 'percentage', 48, '2025-12-09', '2026-01-02', '17:00', '18:00', NULL, 5),
('Promo 38', 'Special promotion to boost sales.', 'percentage', 9, '2025-08-05', '2025-09-23', NULL, NULL, NULL, NULL),
('Promo 39', 'Special promotion to boost sales.', 'bogo', 1, '2025-05-07', '2025-07-02', '10:00', '22:00', NULL, 8),
('Promo 40', 'Special promotion to boost sales.', 'percentage', 18, '2025-02-21', '2025-03-23', NULL, NULL, NULL, NULL),
('Promo 41', 'Special promotion to boost sales.', 'fixed', 100, '2025-05-22', '2025-06-12', NULL, NULL, NULL, NULL),
('Promo 42', 'Special promotion to boost sales.', 'fixed', 427, '2025-04-20', '2025-06-18', NULL, NULL, NULL, 2),
('Promo 43', 'Special promotion to boost sales.', 'percentage', 12, '2025-09-03', '2025-10-11', NULL, NULL, NULL, NULL),
('Promo 44', 'Special promotion to boost sales.', 'percentage', 44, '2025-11-08', '2025-12-26', NULL, NULL, NULL, 4),
('Promo 45', 'Special promotion to boost sales.', 'bogo', 1, '2025-10-28', '2025-11-12', '20:00', '21:00', NULL, 8),
('Promo 46', 'Special promotion to boost sales.', 'percentage', 28, '2025-07-27', '2025-09-18', '19:00', '22:00', NULL, NULL),
('Promo 47', 'Special promotion to boost sales.', 'bogo', 1, '2025-07-25', '2025-09-04', NULL, NULL, NULL, 6),
('Promo 48', 'Special promotion to boost sales.', 'bogo', 1, '2025-11-18', '2026-01-16', '16:00', '18:00', NULL, 5),
('Promo 49', 'Special promotion to boost sales.', 'percentage', 25, '2025-03-15', '2025-05-05', NULL, NULL, NULL, NULL),
('Promo 50', 'Special promotion to boost sales.', 'bogo', 1, '2025-11-30', '2026-01-09', '20:00', '22:00', NULL, 4),
('Promo 51', 'Special promotion to boost sales.', 'fixed', 244, '2025-12-03', '2026-01-31', NULL, NULL, 1000, NULL),
('Promo 52', 'Special promotion to boost sales.', 'bogo', 1, '2025-09-01', '2025-09-22', '13:00', '14:00', NULL, 4),
('Promo 53', 'Special promotion to boost sales.', 'percentage', 23, '2025-11-23', '2025-12-12', NULL, NULL, NULL, NULL),
('Promo 54', 'Special promotion to boost sales.', 'bogo', 1, '2025-03-21', '2025-04-18', NULL, NULL, NULL, 3),
('Promo 55', 'Special promotion to boost sales.', 'percentage', 8, '2025-11-12', '2025-12-08', '13:00', '21:00', NULL, NULL),
('Promo 56', 'Special promotion to boost sales.', 'percentage', 32, '2025-04-20', '2025-06-19', NULL, NULL, NULL, 2),
('Promo 57', 'Special promotion to boost sales.', 'bogo', 1, '2025-07-12', '2025-08-13', '12:00', '16:00', NULL, 3),
('Promo 58', 'Special promotion to boost sales.', 'fixed', 352, '2025-05-11', '2025-05-23', '18:00', '20:00', 800, NULL),
('Promo 59', 'Special promotion to boost sales.', 'fixed', 498, '2025-04-10', '2025-04-29', '10:00', '18:00', 500, NULL),
('Promo 60', 'Special promotion to boost sales.', 'fixed', 259, '2025-09-14', '2025-10-10', NULL, NULL, NULL, 2),
('Promo 61', 'Special promotion to boost sales.', 'fixed', 408, '2025-05-22', '2025-07-16', NULL, NULL, 500, NULL),
('Promo 62', 'Special promotion to boost sales.', 'fixed', 254, '2025-03-14', '2025-03-25', NULL, NULL, NULL, 2),
('Promo 63', 'Special promotion to boost sales.', 'fixed', 309, '2025-11-02', '2025-11-10', '15:00', '20:00', NULL, 6),
('Promo 64', 'Special promotion to boost sales.', 'fixed', 359, '2025-04-22', '2025-05-12', '12:00', '18:00', NULL, 4),
('Promo 65', 'Special promotion to boost sales.', 'percentage', 19, '2025-08-30', '2025-09-10', NULL, NULL, NULL, NULL),
('Promo 66', 'Special promotion to boost sales.', 'percentage', 41, '2025-11-15', '2025-12-23', '11:00', '20:00', 1000, NULL),
('Promo 67', 'Special promotion to boost sales.', 'fixed', 303, '2025-03-06', '2025-04-13', '11:00', '22:00', NULL, 5),
('Promo 68', 'Special promotion to boost sales.', 'bogo', 1, '2025-03-04', '2025-04-14', NULL, NULL, NULL, 6),
('Promo 69', 'Special promotion to boost sales.', 'percentage', 47, '2025-12-25', '2026-01-14', NULL, NULL, 300, NULL),
('Promo 70', 'Special promotion to boost sales.', 'percentage', 35, '2025-11-02', '2025-11-28', '19:00', '21:00', NULL, 4),
('Promo 71', 'Special promotion to boost sales.', 'bogo', 1, '2026-01-04', '2026-01-12', '12:00', '18:00', NULL, 8),
('Promo 72', 'Special promotion to boost sales.', 'fixed', 288, '2025-08-23', '2025-10-10', NULL, NULL, 500, NULL),
('Promo 73', 'Special promotion to boost sales.', 'percentage', 5, '2025-08-15', '2025-09-02', '13:00', '18:00', NULL, NULL),
('Promo 74', 'Special promotion to boost sales.', 'fixed', 259, '2025-07-21', '2025-08-18', '14:00', '22:00', NULL, 2),
('Promo 75', 'Special promotion to boost sales.', 'fixed', 243, '2025-06-10', '2025-08-06', '15:00', '21:00', 800, NULL),
('Promo 76', 'Special promotion to boost sales.', 'bogo', 1, '2025-03-16', '2025-05-15', '17:00', '20:00', NULL, 2),
('Promo 77', 'Special promotion to boost sales.', 'bogo', 1, '2025-11-19', '2025-12-31', NULL, NULL, NULL, 4),
('Promo 78', 'Special promotion to boost sales.', 'bogo', 1, '2025-11-20', '2025-12-04', NULL, NULL, NULL, 6),
('Promo 79', 'Special promotion to boost sales.', 'percentage', 39, '2025-11-13', '2025-12-14', '11:00', '12:00', 1000, NULL),
('Promo 80', 'Special promotion to boost sales.', 'bogo', 1, '2025-08-30', '2025-09-09', NULL, NULL, NULL, 6),
('Promo 81', 'Special promotion to boost sales.', 'percentage', 23, '2025-09-13', '2025-10-14', '11:00', '14:00', NULL, NULL),
('Promo 82', 'Special promotion to boost sales.', 'percentage', 44, '2025-12-20', '2026-02-01', '18:00', '20:00', NULL, 2),
('Promo 83', 'Special promotion to boost sales.', 'fixed', 119, '2025-09-11', '2025-10-10', '15:00', '22:00', NULL, NULL),
('Promo 84', 'Special promotion to boost sales.', 'fixed', 409, '2026-02-01', '2026-02-27', NULL, NULL, NULL, 6),
('Promo 85', 'Special promotion to boost sales.', 'percentage', 44, '2025-04-22', '2025-05-27', '18:00', '19:00', NULL, 4),
('Promo 86', 'Special promotion to boost sales.', 'bogo', 1, '2025-09-12', '2025-09-24', '11:00', '14:00', NULL, 6),
('Promo 87', 'Special promotion to boost sales.', 'fixed', 146, '2026-01-04', '2026-01-31', '17:00', '20:00', NULL, NULL),
('Promo 88', 'Special promotion to boost sales.', 'fixed', 482, '2025-11-30', '2026-01-25', NULL, NULL, 800, NULL),
('Promo 89', 'Special promotion to boost sales.', 'bogo', 1, '2025-05-26', '2025-07-09', '13:00', '19:00', NULL, 8),
('Promo 90', 'Special promotion to boost sales.', 'bogo', 1, '2026-02-12', '2026-03-07', '19:00', '22:00', NULL, 4),
('Promo 91', 'Special promotion to boost sales.', 'fixed', 415, '2025-08-12', '2025-09-05', NULL, NULL, 800, NULL),
('Promo 92', 'Special promotion to boost sales.', 'percentage', 14, '2026-02-05', '2026-03-13', '14:00', '21:00', NULL, NULL),
('Promo 93', 'Special promotion to boost sales.', 'percentage', 47, '2025-12-13', '2026-02-03', '17:00', '21:00', NULL, 4),
('Promo 94', 'Special promotion to boost sales.', 'bogo', 1, '2025-12-04', '2026-01-08', NULL, NULL, NULL, 4),
('Promo 95', 'Special promotion to boost sales.', 'percentage', 11, '2025-09-01', '2025-10-30', NULL, NULL, NULL, NULL),
('Promo 96', 'Special promotion to boost sales.', 'percentage', 6, '2025-12-25', '2026-01-04', NULL, NULL, NULL, NULL),
('Promo 97', 'Special promotion to boost sales.', 'percentage', 49, '2025-09-04', '2025-10-06', NULL, NULL, 300, NULL),
('Promo 98', 'Special promotion to boost sales.', 'bogo', 1, '2025-04-07', '2025-05-03', NULL, NULL, NULL, 6),
('Promo 99', 'Special promotion to boost sales.', 'fixed', 373, '2025-04-15', '2025-05-18', '19:00', '20:00', 1000, NULL),
('Promo 100', 'Special promotion to boost sales.', 'fixed', 182, '2025-09-10', '2025-11-06', NULL, NULL, NULL, 3),
('Promo 101', 'Special promotion to boost sales.', 'bogo', 1, '2026-02-10', '2026-03-29', NULL, NULL, NULL, 8),
('Promo 102', 'Special promotion to boost sales.', 'percentage', 6, '2025-04-10', '2025-04-28', NULL, NULL, NULL, NULL),
('Promo 103', 'Special promotion to boost sales.', 'percentage', 32, '2025-05-04', '2025-06-27', '16:00', '21:00', 800, NULL),
('Promo 104', 'Special promotion to boost sales.', 'bogo', 1, '2025-09-16', '2025-10-27', NULL, NULL, NULL, 6),
('Promo 105', 'Special promotion to boost sales.', 'percentage', 48, '2025-11-19', '2025-12-18', '17:00', '18:00', NULL, 4),
('Promo 106', 'Special promotion to boost sales.', 'percentage', 16, '2025-03-13', '2025-04-17', NULL, NULL, NULL, NULL),
('Promo 107', 'Special promotion to boost sales.', 'percentage', 24, '2025-12-07', '2025-12-23', '17:00', '18:00', NULL, NULL),
('Promo 108', 'Special promotion to boost sales.', 'bogo', 1, '2025-08-08', '2025-10-02', '15:00', '20:00', NULL, 8),
('Promo 109', 'Special promotion to boost sales.', 'fixed', 471, '2026-01-31', '2026-02-23', '15:00', '19:00', NULL, 6),
('Promo 110', 'Special promotion to boost sales.', 'bogo', 1, '2025-03-21', '2025-04-24', '16:00', '19:00', NULL, 6),
('Promo 111', 'Special promotion to boost sales.', 'percentage', 9, '2025-09-28', '2025-11-19', '14:00', '21:00', NULL, NULL),
('Promo 112', 'Special promotion to boost sales.', 'percentage', 7, '2025-08-30', '2025-09-10', '12:00', '17:00', NULL, NULL),
('Promo 113', 'Special promotion to boost sales.', 'percentage', 36, '2025-04-04', '2025-05-08', '17:00', '22:00', 500, NULL),
('Promo 114', 'Special promotion to boost sales.', 'fixed', 66, '2025-10-19', '2025-12-12', '13:00', '16:00', NULL, NULL),
('Promo 115', 'Special promotion to boost sales.', 'percentage', 26, '2025-11-05', '2025-11-15', NULL, NULL, NULL, NULL),
('Promo 116', 'Special promotion to boost sales.', 'percentage', 6, '2025-05-13', '2025-06-23', '15:00', '17:00', NULL, NULL),
('Promo 117', 'Special promotion to boost sales.', 'bogo', 1, '2025-12-25', '2026-02-11', '19:00', '20:00', NULL, 3),
('Promo 118', 'Special promotion to boost sales.', 'fixed', 327, '2025-08-28', '2025-09-07', '19:00', '21:00', NULL, 4),
('Promo 119', 'Special promotion to boost sales.', 'fixed', 276, '2026-01-09', '2026-02-06', '19:00', '21:00', NULL, 3),
('Promo 120', 'Special promotion to boost sales.', 'fixed', 92, '2025-03-22', '2025-05-05', '17:00', '19:00', NULL, NULL),
('Promo 121', 'Special promotion to boost sales.', 'percentage', 10, '2025-10-27', '2025-11-12', '15:00', '16:00', NULL, NULL),
('Promo 122', 'Special promotion to boost sales.', 'bogo', 1, '2026-02-05', '2026-03-24', '15:00', '21:00', NULL, 2),
('Promo 123', 'Special promotion to boost sales.', 'fixed', 478, '2025-07-29', '2025-08-31', NULL, NULL, 1500, NULL),
('Promo 124', 'Special promotion to boost sales.', 'percentage', 29, '2026-01-29', '2026-02-14', '11:00', '22:00', NULL, NULL),
('Promo 125', 'Special promotion to boost sales.', 'bogo', 1, '2025-12-21', '2026-02-15', NULL, NULL, NULL, 8),
('Promo 126', 'Special promotion to boost sales.', 'fixed', 330, '2025-07-26', '2025-09-10', '20:00', '22:00', 800, NULL),
('Promo 127', 'Special promotion to boost sales.', 'percentage', 46, '2025-12-07', '2026-02-05', NULL, NULL, NULL, 2),
('Promo 128', 'Special promotion to boost sales.', 'fixed', 37, '2025-06-08', '2025-06-16', '12:00', '19:00', NULL, NULL),
('Promo 129', 'Special promotion to boost sales.', 'fixed', 122, '2025-12-11', '2025-12-30', NULL, NULL, NULL, NULL),
('Promo 130', 'Special promotion to boost sales.', 'bogo', 1, '2025-03-15', '2025-04-21', '10:00', '12:00', NULL, 2),
('Promo 131', 'Special promotion to boost sales.', 'bogo', 1, '2025-02-28', '2025-04-15', NULL, NULL, NULL, 2),
('Promo 132', 'Special promotion to boost sales.', 'bogo', 1, '2025-09-23', '2025-11-15', '20:00', '21:00', NULL, 2),
('Promo 133', 'Special promotion to boost sales.', 'bogo', 1, '2025-12-04', '2026-01-19', '13:00', '16:00', NULL, 6),
('Promo 134', 'Special promotion to boost sales.', 'bogo', 1, '2025-07-02', '2025-08-05', NULL, NULL, NULL, 2),
('Promo 135', 'Special promotion to boost sales.', 'bogo', 1, '2025-08-17', '2025-09-03', NULL, NULL, NULL, 8),
('Promo 136', 'Special promotion to boost sales.', 'percentage', 7, '2025-11-04', '2025-12-31', '10:00', '11:00', NULL, NULL),
('Promo 137', 'Special promotion to boost sales.', 'fixed', 448, '2025-12-17', '2026-01-21', NULL, NULL, NULL, 3),
('Promo 138', 'Special promotion to boost sales.', 'fixed', 454, '2025-09-02', '2025-10-12', NULL, NULL, 500, NULL),
('Promo 139', 'Special promotion to boost sales.', 'fixed', 155, '2025-10-27', '2025-12-22', NULL, NULL, NULL, 3),
('Promo 140', 'Special promotion to boost sales.', 'percentage', 42, '2025-09-30', '2025-10-15', '12:00', '14:00', NULL, 2),
('Promo 141', 'Special promotion to boost sales.', 'fixed', 220, '2025-06-17', '2025-07-26', '18:00', '19:00', NULL, 2),
('Promo 142', 'Special promotion to boost sales.', 'bogo', 1, '2025-07-10', '2025-08-13', '10:00', '14:00', NULL, 3),
('Promo 143', 'Special promotion to boost sales.', 'fixed', 294, '2025-06-04', '2025-07-07', '11:00', '15:00', 800, NULL),
('Promo 144', 'Special promotion to boost sales.', 'bogo', 1, '2025-06-09', '2025-07-11', NULL, NULL, NULL, 6),
('Promo 145', 'Special promotion to boost sales.', 'bogo', 1, '2025-07-20', '2025-08-05', NULL, NULL, NULL, 5),
('Promo 146', 'Special promotion to boost sales.', 'bogo', 1, '2025-10-26', '2025-11-13', '18:00', '21:00', NULL, 5),
('Promo 147', 'Special promotion to boost sales.', 'percentage', 37, '2025-04-05', '2025-04-12', '12:00', '13:00', 800, NULL),
('Promo 148', 'Special promotion to boost sales.', 'percentage', 6, '2025-07-07', '2025-09-04', '10:00', '19:00', NULL, NULL),
('Promo 149', 'Special promotion to boost sales.', 'fixed', 213, '2025-08-02', '2025-09-28', NULL, NULL, NULL, 3),
('Promo 150', 'Special promotion to boost sales.', 'percentage', 14, '2025-07-17', '2025-08-29', '10:00', '22:00', NULL, NULL);

DELIMITER $$

CREATE PROCEDURE generate_promotion_products()
BEGIN
    DECLARE promo_id INT;
    DECLARE prod_count INT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE promo_cursor CURSOR FOR SELECT id FROM promotions;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN promo_cursor;

    read_loop: LOOP
        FETCH promo_cursor INTO promo_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- assign between 3 and 10 products randomly
        SET prod_count = FLOOR(3 + (RAND() * 8));

        -- insert random products in ONE shot instead of looping
        INSERT IGNORE INTO promotion_products (promotion_id, product_id)
        SELECT promo_id, p.id
        FROM products p
        ORDER BY RAND()
        LIMIT prod_count;
    END LOOP;

    CLOSE promo_cursor;
END$$

DELIMITER ;

-- regenerate fresh sample data
TRUNCATE TABLE promotion_products;
CALL generate_promotion_products();

DROP procedure generate_promotion_products;

INSERT INTO transactions 
(promotion_id, payment_method, total_amount, discount_amount, net_amount, status, created_at) VALUES
(25, 'Cash', 1326.56, 224.88, 1101.6799999999998, 'Refunded', '2025-07-18 23:32:40'),
(NULL, 'Cash', 138.18, 0, 138.18, 'Completed', '2025-07-07 21:40:45'),
(NULL, 'Cash', 2068.9700000000003, 0, 2068.9700000000003, 'Completed', '2025-05-13 06:53:02'),
(NULL, 'E-Wallet', 3455.2599999999998, 0, 3455.2599999999998, 'Cancelled', '2025-03-12 15:20:58'),
(NULL, 'Cash', 492.02, 0, 492.02, 'Pending', '2025-06-14 13:08:06'),
(NULL, 'E-Wallet', 673.64, 0, 673.64, 'Completed', '2024-10-08 05:21:45'),
(NULL, 'Cash', 3437.1699999999996, 0, 3437.1699999999996, 'Refunded', '2024-11-16 23:02:22'),
(65, 'Cash', 2839.15, 772.18, 2066.9700000000003, 'Refunded', '2024-12-31 04:16:08'),
(NULL, 'E-Wallet', 2176.9399999999996, 0, 2176.9399999999996, 'Cancelled', '2025-02-21 16:29:01'),
(NULL, 'Cash', 1765.87, 0, 1765.87, 'Completed', '2025-05-26 05:35:28'),
(NULL, 'E-Wallet', 1325.77, 0, 1325.77, 'Completed', '2025-08-10 05:03:25'),
(NULL, 'Cash', 2680.8199999999997, 0, 2680.8199999999997, 'Pending', '2025-03-30 13:51:24'),
(NULL, 'E-Wallet', 1662.8, 0, 1662.8, 'Cancelled', '2024-09-03 10:27:15'),
(NULL, 'Cash', 2350.81, 0, 2350.81, 'Pending', '2024-09-14 12:07:45'),
(NULL, 'Cash', 448.46, 0, 448.46, 'Pending', '2024-08-19 11:47:18'),
(NULL, 'E-Wallet', 688.66, 0, 688.66, 'Refunded', '2024-08-20 23:05:24'),
(NULL, 'Cash', 1293.76, 0, 1293.76, 'Pending', '2025-06-26 12:13:49'),
(27, 'Cash', 1352.61, 178.47, 1174.1399999999999, 'Cancelled', '2024-11-21 12:44:04'),
(NULL, 'Cash', 2978.57, 0, 2978.57, 'Cancelled', '2025-05-29 05:52:26'),
(NULL, 'E-Wallet', 2359.74, 0, 2359.74, 'Refunded', '2025-02-07 07:53:03'),
(NULL, 'Cash', 514.06, 0, 514.06, 'Completed', '2024-12-12 19:20:38'),
(NULL, 'Cash', 1448.0900000000001, 0, 1448.0900000000001, 'Completed', '2025-04-13 18:15:27'),
(NULL, 'E-Wallet', 1935.5900000000001, 0, 1935.5900000000001, 'Completed', '2024-09-22 23:51:30'),
(NULL, 'E-Wallet', 876.26, 0, 876.26, 'Pending', '2024-11-07 17:15:40'),
(99, 'Cash', 315.22, 22.28, 292.94000000000005, 'Pending', '2024-09-25 00:52:23'),
(NULL, 'E-Wallet', 2429.16, 0, 2429.16, 'Completed', '2024-10-25 07:04:47'),
(53, 'E-Wallet', 3899.5499999999997, 1024.64, 2874.91, 'Completed', '2024-11-13 19:36:32'),
(NULL, 'E-Wallet', 1172.76, 0, 1172.76, 'Completed', '2024-12-16 11:24:45'),
(17, 'E-Wallet', 799.53, 187.9, 611.63, 'Pending', '2025-02-18 18:32:52'),
(NULL, 'E-Wallet', 568.46, 0, 568.46, 'Completed', '2024-08-24 07:00:32'),
(15, 'Cash', 3532.0599999999995, 304.16, 3227.8999999999996, 'Cancelled', '2024-12-28 00:47:10'),
(NULL, 'E-Wallet', 1556.4, 0, 1556.4, 'Completed', '2025-05-14 09:07:38'),
(NULL, 'E-Wallet', 2012.33, 0, 2012.33, 'Refunded', '2025-02-07 22:31:43'),
(NULL, 'Cash', 739.11, 0, 739.11, 'Pending', '2024-09-02 01:12:25'),
(NULL, 'E-Wallet', 1892.6399999999999, 0, 1892.6399999999999, 'Cancelled', '2024-11-24 02:46:56'),
(NULL, 'Cash', 245.38, 0, 245.38, 'Refunded', '2025-06-11 11:27:40'),
(NULL, 'Cash', 930.8900000000001, 0, 930.8900000000001, 'Cancelled', '2024-11-08 12:42:31'),
(NULL, 'Cash', 1810.79, 0, 1810.79, 'Cancelled', '2025-08-06 13:24:45'),
(NULL, 'E-Wallet', 2430.0, 0, 2430.0, 'Completed', '2025-03-31 23:35:40'),
(115, 'E-Wallet', 211.51, 59.49, 152.01999999999998, 'Refunded', '2024-10-27 06:32:29'),
(NULL, 'Cash', 2096.1800000000003, 0, 2096.1800000000003, 'Refunded', '2025-03-07 14:31:17'),
(NULL, 'Cash', 1952.46, 0, 1952.46, 'Completed', '2024-10-03 18:03:04'),
(131, 'E-Wallet', 1341.41, 118.07, 1223.3400000000001, 'Completed', '2024-09-05 23:08:34'),
(NULL, 'Cash', 3069.37, 0, 3069.37, 'Refunded', '2024-09-28 19:23:19'),
(NULL, 'E-Wallet', 1467.3400000000001, 0, 1467.3400000000001, 'Pending', '2024-12-10 13:43:31'),
(NULL, 'E-Wallet', 246.05, 0, 246.05, 'Cancelled', '2024-09-06 03:06:57'),
(77, 'E-Wallet', 533.24, 131.43, 401.81, 'Cancelled', '2024-12-13 01:33:28'),
(NULL, 'Cash', 2184.57, 0, 2184.57, 'Pending', '2025-03-30 23:11:57'),
(NULL, 'Cash', 447.84000000000003, 0, 447.84000000000003, 'Cancelled', '2025-06-09 06:12:30'),
(NULL, 'Cash', 954.91, 0, 954.91, 'Completed', '2024-08-21 20:22:08');

INSERT INTO transaction_products 
(transaction_id, product_id, quantity, price) VALUES
(1, 42, 1, 453.65),
(1, 17, 3, 290.97),
(2, 43, 2, 69.09),
(3, 14, 3, 229.78),
(3, 25, 2, 197.68),
(3, 21, 3, 328.09),
(4, 11, 2, 291.38),
(4, 36, 3, 417.32),
(4, 33, 3, 259.66),
(4, 5, 1, 179.79),
(4, 12, 3, 220.59),
(5, 33, 2, 246.01),
(6, 15, 2, 201.6),
(6, 22, 2, 135.22),
(7, 35, 2, 447.58),
(7, 33, 3, 428.45),
(7, 45, 2, 400.9),
(7, 24, 1, 454.86),
(8, 11, 1, 479.63),
(8, 16, 1, 481.65),
(8, 5, 3, 314.52),
(8, 32, 1, 193.75),
(8, 36, 2, 370.28),
(9, 27, 3, 342.13),
(9, 46, 1, 138.92),
(9, 1, 3, 337.21),
(10, 33, 1, 309.13),
(10, 20, 3, 485.58),
(11, 29, 2, 416.72),
(11, 13, 3, 164.11),
(12, 29, 2, 231.38),
(12, 32, 3, 299.83),
(12, 33, 3, 274.51),
(12, 1, 2, 247.52),
(13, 7, 2, 385.3),
(13, 5, 3, 297.4),
(14, 31, 2, 100.82),
(14, 16, 3, 469.51),
(14, 42, 1, 159.6),
(14, 45, 3, 193.68),
(15, 41, 2, 224.23),
(16, 43, 1, 341.01),
(16, 37, 1, 347.65),
(17, 13, 2, 260.94),
(17, 20, 1, 308.65),
(17, 32, 1, 463.23),
(18, 37, 1, 180.53),
(18, 45, 1, 446.53),
(18, 13, 3, 241.85),
(19, 45, 1, 384.18),
(19, 46, 2, 477.9),
(19, 33, 3, 156.12),
(19, 50, 1, 418.41),
(19, 38, 2, 375.91),
(20, 45, 2, 339.94),
(20, 36, 1, 409.62),
(20, 13, 1, 454.28),
(20, 47, 2, 407.98),
(21, 47, 1, 220.39),
(21, 29, 3, 97.89),
(22, 4, 1, 328.94),
(22, 49, 3, 373.05),
(23, 36, 2, 101.56),
(23, 39, 3, 251.8),
(23, 19, 3, 325.69),
(24, 19, 2, 326.63),
(24, 49, 1, 223.0),
(25, 21, 1, 315.22),
(26, 15, 2, 449.78),
(26, 42, 3, 162.42),
(26, 13, 2, 350.88),
(26, 41, 1, 340.58),
(27, 44, 2, 244.89),
(27, 13, 3, 446.16),
(27, 50, 3, 212.37),
(27, 35, 2, 468.39),
(27, 21, 3, 165.8),
(28, 41, 2, 206.77),
(28, 10, 2, 379.61),
(29, 10, 3, 266.51),
(30, 17, 2, 284.23),
(31, 44, 3, 422.63),
(31, 27, 2, 322.32),
(31, 48, 1, 318.77),
(31, 12, 1, 137.12),
(31, 41, 3, 387.88),
(32, 2, 3, 381.59),
(32, 43, 3, 137.21),
(33, 33, 1, 376.47),
(33, 22, 1, 279.44),
(33, 23, 2, 301.7),
(33, 24, 2, 376.51),
(34, 20, 3, 246.37),
(35, 19, 3, 317.78),
(35, 33, 2, 469.65),
(36, 1, 2, 122.69),
(37, 19, 1, 313.57),
(37, 47, 2, 308.66),
(38, 9, 2, 408.08),
(38, 32, 2, 336.31),
(38, 30, 1, 322.01),
(39, 26, 3, 80.15),
(39, 40, 2, 344.96),
(39, 3, 2, 413.38),
(39, 10, 1, 289.35),
(39, 43, 2, 191.76),
(40, 31, 1, 211.51),
(41, 41, 3, 306.07),
(41, 28, 3, 169.31),
(41, 18, 2, 125.77),
(41, 39, 1, 418.5),
(42, 12, 1, 366.72),
(42, 39, 3, 247.54),
(42, 15, 2, 367.13),
(42, 38, 1, 108.86),
(43, 4, 1, 444.23),
(43, 31, 3, 299.06),
(44, 38, 1, 183.46),
(44, 50, 3, 228.5),
(44, 24, 3, 356.34),
(44, 46, 3, 377.13),
(45, 41, 1, 197.18),
(45, 19, 3, 350.0),
(45, 24, 2, 110.08),
(46, 34, 1, 246.05),
(47, 46, 1, 407.66),
(47, 49, 1, 125.58),
(48, 27, 3, 469.23),
(48, 20, 2, 265.48),
(48, 3, 2, 122.96),
(49, 25, 3, 149.28),
(50, 26, 1, 234.75),
(50, 43, 2, 360.08);

INSERT INTO employees (role, branch_id, name, email, password) VALUES
('Owner', NULL, 'System Owner', 'owner@example.com', 'password123'),
('Super Admin', NULL, 'System SuperAdmin', 'superadmin@example.com', 'password123'),
('Admin', 1, 'Mark Torres', 'mark.torres4@example.com', 'password123'),
('Admin', 2, 'Mark Garcia', 'mark.garcia5@example.com', 'password123'),
('Staff', 1, 'Carmen Torres', 'carmen.torres7@example.com', 'password123'),
('Staff', 1, 'Rosa Torres', 'rosa.torres8@example.com', 'password123'),
('Staff', 2, 'Juan Mendoza', 'juan.mendoza9@example.com', 'password123'),
('Staff', 2, 'Maria Santos', 'maria.santos10@example.com', 'password123');


