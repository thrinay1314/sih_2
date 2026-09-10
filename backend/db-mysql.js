/**
 * db-mysql.js — Production MySQL database adapter for KisanLink.
 * Uses mysql2/promise connection pooling with auto-reconnect.
 */
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

let pool = null;

function getPool() {
  if (!pool) {
    const config = process.env.MYSQL_URL || process.env.DATABASE_URL
      ? { uri: process.env.MYSQL_URL || process.env.DATABASE_URL }
      : {
          host: process.env.DB_HOST || 'localhost',
          port: parseInt(process.env.DB_PORT || '3306', 10),
          user: process.env.DB_USER || 'root',
          password: process.env.DB_PASSWORD || '',
          database: process.env.DB_NAME || 'kisanlink',
          waitForConnections: true,
          connectionLimit: 10,
          queueLimit: 0,
          ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined
        };

    pool = mysql.createPool(config);
  }
  return pool;
}

// ---------------- Health & Schema Init ----------------
async function testConnection() {
  try {
    const p = getPool();
    const [rows] = await p.query('SELECT 1 + 1 AS result');
    return { ok: true, result: rows[0].result };
  } catch (err) {
    return { ok: false, error: err.message };
  }
}

async function initSchema() {
  const p = getPool();
  const schemaPath = path.join(__dirname, 'schema.sql');
  const sql = fs.readFileSync(schemaPath, 'utf-8');
  
  // Split multiple SQL statements by semicolon
  const statements = sql
    .split(/;\s*$/m)
    .map(s => s.trim())
    .filter(s => s.length > 0 && !s.startsWith('--'));

  for (const statement of statements) {
    await p.query(statement);
  }
  return true;
}

// ---------------- Users ----------------
async function getUsers() {
  const p = getPool();
  const [rows] = await p.query('SELECT id, name, mobile, role, village, company, password_hash AS passwordHash, created_at AS createdAt FROM users ORDER BY id DESC');
  return rows;
}

async function findUser(mobile, role) {
  const p = getPool();
  let query = 'SELECT id, name, mobile, role, village, company, password_hash AS passwordHash, created_at AS createdAt FROM users WHERE mobile = ?';
  const params = [mobile];
  if (role) {
    query += ' AND role = ?';
    params.push(role);
  }
  const [rows] = await p.query(query, params);
  return rows[0] || null;
}

async function addUser(user) {
  const p = getPool();
  await p.query(
    'INSERT INTO users (id, name, mobile, role, village, company, password_hash, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
    [
      user.id,
      user.name,
      user.mobile,
      user.role,
      user.village || null,
      user.company || null,
      user.passwordHash,
      user.createdAt || new Date()
    ]
  );
  return user;
}

async function deleteUser(id) {
  const p = getPool();
  const [users] = await p.query('SELECT * FROM users WHERE id = ?', [id]);
  if (!users.length) return null;
  const user = users[0];

  await p.query('DELETE FROM users WHERE id = ?', [id]);
  if (user.role === 'buyer') {
    await p.query('DELETE FROM buyers WHERE id = ? OR mobile = ?', [id, user.mobile]);
  } else if (user.role === 'farmer') {
    await p.query('DELETE FROM crops WHERE farmer_id = ?', [id]);
  }
  return user;
}

// ---------------- Buyers ----------------
async function getBuyers() {
  const p = getPool();
  const [rows] = await p.query('SELECT id, name, type, contact_person AS contactPerson, mobile, location, dist_base AS distBase, price_mult AS priceMult, commission, verified, rating, deals, accepted_crops AS acceptedCrops, description FROM buyers ORDER BY rating DESC');
  return rows.map(b => ({
    ...b,
    verified: Boolean(b.verified),
    acceptedCrops: typeof b.acceptedCrops === 'string' ? JSON.parse(b.acceptedCrops) : (b.acceptedCrops || [])
  }));
}

async function addBuyer(buyer) {
  const p = getPool();
  await p.query(
    `INSERT INTO buyers (id, name, type, contact_person, mobile, location, dist_base, price_mult, commission, verified, rating, deals, accepted_crops, description)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      buyer.id,
      buyer.name,
      buyer.type || 'private',
      buyer.contactPerson || buyer.name,
      buyer.mobile,
      buyer.location || 'Warangal',
      buyer.distBase || 15.00,
      buyer.priceMult || 1.05,
      buyer.commission || 0.030,
      buyer.verified !== false,
      buyer.rating || 5.0,
      buyer.deals || 0,
      JSON.stringify(buyer.acceptedCrops || []),
      buyer.description || null
    ]
  );
  return buyer;
}

// ---------------- Crops ----------------
async function getCrops(farmerId) {
  const p = getPool();
  let query = 'SELECT id, farmer_id AS farmerId, farmer_name AS farmerName, farmer_mobile AS farmerMobile, village, crop, variety, qty, unit, ask_price AS askPrice, quality, harvest_date AS harvestDate, status, icon, notes, created_at AS createdAt, updated_at AS updatedAt FROM crops';
  const params = [];
  if (farmerId) {
    query += ' WHERE farmer_id = ?';
    params.push(farmerId);
  }
  query += ' ORDER BY created_at DESC';
  const [rows] = await p.query(query, params);
  return rows;
}

async function addCrop(crop) {
  const p = getPool();
  const [res] = await p.query(
    `INSERT INTO crops (id, farmer_id, farmer_name, farmer_mobile, village, crop, variety, qty, unit, ask_price, quality, harvest_date, status, icon, notes, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      crop.id || Date.now(),
      crop.farmerId,
      crop.farmerName,
      crop.farmerMobile,
      crop.village,
      crop.crop,
      crop.variety || null,
      crop.qty,
      crop.unit || 'quintal',
      crop.askPrice,
      crop.quality || 'Grade A',
      crop.harvestDate || null,
      crop.status || 'available',
      crop.icon || '🌾',
      crop.notes || null,
      crop.createdAt || new Date()
    ]
  );
  return crop;
}

async function updateCropStatus(id, status, farmerId) {
  const p = getPool();
  let query = 'UPDATE crops SET status = ?, updated_at = NOW() WHERE id = ?';
  const params = [status, id];
  if (farmerId) {
    query += ' AND farmer_id = ?';
    params.push(farmerId);
  }
  const [res] = await p.query(query, params);
  if (res.affectedRows === 0) return null;
  const [rows] = await p.query('SELECT * FROM crops WHERE id = ?', [id]);
  return rows[0] || null;
}

async function removeCrop(id, farmerId) {
  const p = getPool();
  const [rows] = await p.query('SELECT * FROM crops WHERE id = ?', [id]);
  if (!rows.length) return null;
  let query = 'DELETE FROM crops WHERE id = ?';
  const params = [id];
  if (farmerId) {
    query += ' AND farmer_id = ?';
    params.push(farmerId);
  }
  await p.query(query, params);
  return rows[0];
}

// ---------------- Deals ----------------
const DEAL_STAGES = ["Offer sent", "Buyer accepts", "Deal confirmed", "Dispatch", "Delivery", "Payment", "Rate buyer"];

async function getDeals() {
  const p = getPool();
  const [rows] = await p.query('SELECT id, farmer_id AS farmerId, farmer_name AS farmerName, farmer_mobile AS farmerMobile, buyer_id AS buyerId, buyer_name AS buyerName, buyer_contact AS buyerContact, crop, qty, unit, price_per_kg AS pricePerKg, total_amount AS totalAmount, stage_index AS stageIndex, stage_name AS stageName, status, notes, created_at AS createdAt, updated_at AS updatedAt FROM deals ORDER BY created_at DESC');
  return rows;
}

async function addDeal(deal) {
  const p = getPool();
  await p.query(
    `INSERT INTO deals (id, farmer_id, farmer_name, farmer_mobile, buyer_id, buyer_name, buyer_contact, crop, qty, unit, price_per_kg, total_amount, stage_index, stage_name, status, notes, created_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      deal.id,
      deal.farmerId,
      deal.farmerName,
      deal.farmerMobile,
      deal.buyerId,
      deal.buyerName,
      deal.buyerContact,
      deal.crop,
      deal.qty,
      deal.unit || 'quintal',
      deal.pricePerKg,
      deal.totalAmount,
      deal.stageIndex || 0,
      deal.stageName || 'Offer sent',
      deal.status || 'in_progress',
      deal.notes || null,
      deal.createdAt || new Date()
    ]
  );
  return deal;
}

async function advanceDealStage(id, userRole, userId) {
  const p = getPool();
  const [deals] = await p.query('SELECT * FROM deals WHERE id = ?', [id]);
  if (!deals.length) return null;
  const deal = deals[0];

  let newStageIndex = deal.stage_index;
  let newStatus = deal.status;
  if (deal.stage_index < DEAL_STAGES.length - 1) {
    newStageIndex += 1;
    if (newStageIndex === DEAL_STAGES.length - 1) {
      newStatus = 'completed';
    }
  } else {
    newStatus = 'completed';
  }
  const newStageName = DEAL_STAGES[newStageIndex];

  await p.query(
    'UPDATE deals SET stage_index = ?, stage_name = ?, status = ?, updated_at = NOW() WHERE id = ?',
    [newStageIndex, newStageName, newStatus, id]
  );

  return {
    ...deal,
    stageIndex: newStageIndex,
    stageName: newStageName,
    status: newStatus
  };
}

// ---------------- Listings (Moderation) ----------------
async function getListings() {
  const p = getPool();
  const [rows] = await p.query('SELECT id, buyer, crop, status, updated_at AS updated FROM listings ORDER BY id ASC');
  return rows;
}

async function updateListingStatus(id, status) {
  const p = getPool();
  await p.query('UPDATE listings SET status = ?, updated_at = NOW() WHERE id = ?', [status, id]);
  const [rows] = await p.query('SELECT id, buyer, crop, status, updated_at AS updated FROM listings WHERE id = ?', [id]);
  return rows[0] || null;
}

async function removeListing(id) {
  const p = getPool();
  const [rows] = await p.query('SELECT * FROM listings WHERE id = ?', [id]);
  if (!rows.length) return null;
  await p.query('DELETE FROM listings WHERE id = ?', [id]);
  return rows[0];
}

module.exports = {
  testConnection,
  initSchema,
  getUsers,
  findUser,
  addUser,
  deleteUser,
  getBuyers,
  addBuyer,
  getCrops,
  addCrop,
  updateCropStatus,
  removeCrop,
  getDeals,
  addDeal,
  advanceDealStage,
  getListings,
  updateListingStatus,
  removeListing
};
