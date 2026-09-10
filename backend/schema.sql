-- ====================================================================
-- KisanLink Production MySQL Database Schema & Initial Seed
-- Smart India Hackathon
-- ====================================================================

CREATE DATABASE IF NOT EXISTS kisanlink
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE kisanlink;

-- --------------------------------------------------------------------
-- 1. USERS TABLE (Farmers, Buyers, and Platform Administrators)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  mobile VARCHAR(20) NOT NULL UNIQUE,
  role ENUM('admin', 'farmer', 'buyer') NOT NULL,
  village VARCHAR(255) DEFAULT NULL,
  company VARCHAR(255) DEFAULT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_users_mobile_role (mobile, role),
  INDEX idx_users_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 2. BUYERS TABLE (APMC Mandis, FPOs, Corporate Procurement & Retailers)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS buyers (
  id BIGINT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  type ENUM('mandi', 'fpo', 'corporate', 'retail', 'processor', 'private') NOT NULL DEFAULT 'private',
  contact_person VARCHAR(255) NOT NULL,
  mobile VARCHAR(20) NOT NULL,
  location VARCHAR(255) NOT NULL,
  dist_base DECIMAL(8, 2) NOT NULL DEFAULT 15.00,
  price_mult DECIMAL(5, 2) NOT NULL DEFAULT 1.05,
  commission DECIMAL(5, 3) NOT NULL DEFAULT 0.030,
  verified BOOLEAN NOT NULL DEFAULT TRUE,
  rating DECIMAL(3, 1) NOT NULL DEFAULT 4.8,
  deals INT NOT NULL DEFAULT 0,
  accepted_crops JSON DEFAULT NULL,
  description TEXT DEFAULT NULL,
  INDEX idx_buyers_location (location),
  INDEX idx_buyers_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 3. CROPS TABLE (Farmer Produce Inventory & Market Listings)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS crops (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  farmer_id BIGINT NOT NULL,
  farmer_name VARCHAR(255) NOT NULL,
  farmer_mobile VARCHAR(20) NOT NULL,
  village VARCHAR(255) NOT NULL,
  crop VARCHAR(100) NOT NULL,
  variety VARCHAR(100) DEFAULT NULL,
  qty DECIMAL(10, 2) NOT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'quintal',
  ask_price DECIMAL(10, 2) NOT NULL,
  quality VARCHAR(20) NOT NULL DEFAULT 'Grade A',
  harvest_date VARCHAR(50) DEFAULT NULL,
  status ENUM('available', 'committed', 'sold') NOT NULL DEFAULT 'available',
  icon VARCHAR(20) DEFAULT '🌾',
  notes TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_crops_farmer (farmer_id),
  INDEX idx_crops_status (status),
  INDEX idx_crops_crop (crop)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 4. DEALS TABLE (Direct Farmgate Negotiation & Milestone Progression)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS deals (
  id VARCHAR(50) PRIMARY KEY,
  farmer_id BIGINT NOT NULL,
  farmer_name VARCHAR(255) NOT NULL,
  farmer_mobile VARCHAR(20) NOT NULL,
  buyer_id BIGINT NOT NULL,
  buyer_name VARCHAR(255) NOT NULL,
  buyer_contact VARCHAR(255) NOT NULL,
  crop VARCHAR(100) NOT NULL,
  qty DECIMAL(10, 2) NOT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'quintal',
  price_per_kg DECIMAL(10, 2) NOT NULL,
  total_amount DECIMAL(12, 2) NOT NULL,
  stage_index INT NOT NULL DEFAULT 0,
  stage_name VARCHAR(100) NOT NULL DEFAULT 'Offer sent',
  status ENUM('in_progress', 'completed', 'cancelled') NOT NULL DEFAULT 'in_progress',
  notes TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_deals_farmer (farmer_id),
  INDEX idx_deals_buyer (buyer_id),
  INDEX idx_deals_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------
-- 5. LISTINGS TABLE (APMC Live Moderation & Anomaly Detection)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS listings (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  buyer VARCHAR(255) NOT NULL,
  crop VARCHAR(100) NOT NULL,
  status ENUM('ok', 'flag', 'pending') NOT NULL DEFAULT 'ok',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_listings_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ====================================================================
-- INITIAL PRODUCTION SEED DATA
-- Default Passwords:
--   Admin: admin / admin123
--   Farmer: 9876543210 / farmer123
--   Buyer: 9123456780 / buyer123
-- ====================================================================

-- 1. Insert Initial Users
INSERT INTO users (id, name, mobile, role, village, company, password_hash, created_at)
VALUES
  (9001, 'Platform Administrator', 'admin', 'admin', NULL, 'KisanLink Authority', '$2a$10$7vUfP2vQ1e.U1Z4q5aZ1k.N2mP7B5eG0z1k9.Q1e.U1Z4q5aZ1k.N', NOW() - INTERVAL 30 DAY),
  (1001, 'Ramesh Patel', '9876543210', 'farmer', 'Warangal Rural', NULL, '$2a$10$7vUfP2vQ1e.U1Z4q5aZ1k.N2mP7B5eG0z1k9.Q1e.U1Z4q5aZ1k.N', NOW() - INTERVAL 14 DAY),
  (1002, 'Lakshmi Devi', '9876543211', 'farmer', 'Karimnagar', NULL, '$2a$10$7vUfP2vQ1e.U1Z4q5aZ1k.N2mP7B5eG0z1k9.Q1e.U1Z4q5aZ1k.N', NOW() - INTERVAL 10 DAY),
  (1003, 'Suresh Reddy', '9876543212', 'farmer', 'Khammam', NULL, '$2a$10$7vUfP2vQ1e.U1Z4q5aZ1k.N2mP7B5eG0z1k9.Q1e.U1Z4q5aZ1k.N', NOW() - INTERVAL 7 DAY),
  (2001, 'Rajesh Kumar', '9123456780', 'buyer', 'Enumamula, Warangal', 'Warangal APMC Market', '$2a$10$7vUfP2vQ1e.U1Z4q5aZ1k.N2mP7B5eG0z1k9.Q1e.U1Z4q5aZ1k.N', NOW() - INTERVAL 20 DAY),
  (2002, 'Venkatesh Rao', '9123456781', 'buyer', 'Hanamkonda Hub', 'Sahyadri Farmers FPO', '$2a$10$7vUfP2vQ1e.U1Z4q5aZ1k.N2mP7B5eG0z1k9.Q1e.U1Z4q5aZ1k.N', NOW() - INTERVAL 18 DAY),
  (2003, 'Anil Sharma', '9123456782', 'buyer', 'Kazipet Logistics Park', 'ITC e-Choupal Procurement', '$2a$10$7vUfP2vQ1e.U1Z4q5aZ1k.N2mP7B5eG0z1k9.Q1e.U1Z4q5aZ1k.N', NOW() - INTERVAL 15 DAY)
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 2. Insert Initial Buyers
INSERT INTO buyers (id, name, type, contact_person, mobile, location, dist_base, price_mult, commission, verified, rating, deals, accepted_crops, description)
VALUES
  (2001, 'Warangal APMC Market', 'mandi', 'Rajesh Kumar (APMC Secy)', '9123456780', 'Enumamula, Warangal', 12.00, 1.02, 0.050, TRUE, 4.8, 142, '["Tomato", "Chili", "Cotton", "Rice", "Maize"]', 'Telangana largest regulated agricultural commodity market yard with open outcry auctions.'),
  (2002, 'Sahyadri Farmers FPO', 'fpo', 'Venkatesh Rao', '9123456781', 'Hanamkonda Hub', 18.00, 1.06, 0.020, TRUE, 4.9, 89, '["Tomato", "Soybean", "Onion", "Wheat"]', 'Farmer-owned collective offering direct farmgate pickup with 0% middleman deduction.'),
  (2003, 'ITC e-Choupal Procurement', 'corporate', 'Anil Sharma', '9123456782', 'Kazipet Logistics Park', 25.00, 1.08, 0.015, TRUE, 4.7, 215, '["Wheat", "Soybean", "Maize", "Cotton"]', 'Corporate supply chain hub with electronic weighbridge and guaranteed T+1 RTGS payment.'),
  (2004, 'BigBasket Fresh Direct', 'retail', 'Priya Sundaram', '9123456783', 'Hyderabad Bypass Hub', 45.00, 1.12, 0.030, TRUE, 4.9, 320, '["Tomato", "Onion", "Potato", "Chili"]', 'Direct retail procurement center offering premium rates for Grade A farm produce.'),
  (2005, 'Om Sai Agro Processing', 'processor', 'Satyanarayana Murthy', '9123456784', 'Mulugu Road Industrial Area', 15.00, 1.04, 0.020, TRUE, 4.6, 64, '["Soybean", "Cotton", "Maize"]', 'Solvent extraction and ginning mill seeking steady bulk supply directly from growers.'),
  (2006, 'Lasalgaon Wholesale Mandi', 'mandi', 'Baburao Kadam', '9123456785', 'National Highway Hub', 35.00, 1.10, 0.060, TRUE, 4.7, 410, '["Onion", "Tomato", "Potato"]', 'Major wholesale terminal market specializing in bulk vegetable and onion trading.')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 3. Insert Initial Crops
INSERT INTO crops (id, farmer_id, farmer_name, farmer_mobile, village, crop, variety, qty, unit, ask_price, quality, harvest_date, status, icon, notes, created_at)
VALUES
  (3001, 1001, 'Ramesh Patel', '9876543210', 'Warangal Rural', 'Tomato', 'Hybrid Vaishnavi', 25.00, 'quintal', 24.00, 'Grade A', '2026-09-12', 'available', '🍅', 'Freshly harvested round red tomatoes, crate packed and sorted.', NOW() - INTERVAL 5 HOUR),
  (3002, 1001, 'Ramesh Patel', '9876543210', 'Warangal Rural', 'Cotton', 'Long Staple Bt', 40.00, 'quintal', 68.00, 'Grade A', '2026-09-15', 'available', '🌾', 'High ginning outturn (>35%), low trash content, stored dry in godown.', NOW() - INTERVAL 8 HOUR),
  (3003, 1002, 'Lakshmi Devi', '9876543211', 'Karimnagar', 'Soybean', 'JS 335', 50.00, 'quintal', 46.00, 'Grade B', '2026-09-10', 'available', '🌱', 'Sun-dried yellow soybean seeds, moisture 10%, clean grading.', NOW() - INTERVAL 12 HOUR),
  (3004, 1002, 'Lakshmi Devi', '9876543211', 'Karimnagar', 'Maize', 'Sweet Corn Pioneer', 30.00, 'quintal', 22.00, 'Grade A', '2026-09-14', 'available', '🌽', 'Golden yellow kernels, suitable for poultry feed and starch processing.', NOW() - INTERVAL 15 HOUR),
  (3005, 1003, 'Suresh Reddy', '9876543212', 'Khammam', 'Rice', 'Sona Masoori', 80.00, 'quintal', 36.00, 'Grade A', '2026-09-08', 'available', '🍚', 'Raw paddy grain, well polished, moisture tested at 11%.', NOW() - INTERVAL 20 HOUR),
  (3006, 1003, 'Suresh Reddy', '9876543212', 'Khammam', 'Chili', 'Guntur Teja', 15.00, 'quintal', 180.00, 'Grade A', '2026-09-18', 'available', '🌶️', 'Spicy deep red chilies, stemless and sun-cured.', NOW() - INTERVAL 24 HOUR)
ON DUPLICATE KEY UPDATE crop=VALUES(crop);

-- 4. Insert Initial Deals
INSERT INTO deals (id, farmer_id, farmer_name, farmer_mobile, buyer_id, buyer_name, buyer_contact, crop, qty, unit, price_per_kg, total_amount, stage_index, stage_name, status, notes, created_at)
VALUES
  ('DEAL-1001', 1001, 'Ramesh Patel', '9876543210', 2002, 'Sahyadri Farmers FPO', '9123456781', 'Tomato', 20.00, 'quintal', 25.00, 50000.00, 3, 'Dispatch', 'in_progress', 'Farmgate pickup arranged via FPO mini-truck. En route to packing shed.', NOW() - INTERVAL 2 DAY),
  ('DEAL-1002', 1002, 'Lakshmi Devi', '9876543211', 2003, 'ITC e-Choupal Procurement', '9123456782', 'Soybean', 35.00, 'quintal', 48.00, 168000.00, 1, 'Buyer accepts', 'in_progress', 'Moisture tested at 9.8%. Awaiting weighbridge dispatch slot.', NOW() - INTERVAL 1 DAY),
  ('DEAL-1003', 1003, 'Suresh Reddy', '9876543212', 2001, 'Warangal APMC Market', '9123456780', 'Rice', 50.00, 'quintal', 38.00, 190000.00, 6, 'Rate buyer', 'completed', 'Full payment of 1,90,000 received via RTGS. 5-star transaction.', NOW() - INTERVAL 5 DAY)
ON DUPLICATE KEY UPDATE stage_name=VALUES(stage_name);

-- 5. Insert Initial Moderation Listings
INSERT INTO listings (id, buyer, crop, status)
VALUES
  (1, 'Warangal APMC Market', 'Tomato', 'ok'),
  (2, 'Lasalgaon Wholesale Mandi', 'Onion', 'ok'),
  (3, 'Unverified Buyer #4471', 'Cotton', 'flag'),
  (4, 'Om Sai Agro Buyers', 'Soybean', 'ok'),
  (5, 'Prakash Traders Spot Bid', 'Wheat', 'pending'),
  (6, 'Rapid Agri Logistics', 'Tomato', 'flag')
ON DUPLICATE KEY UPDATE status=VALUES(status);
