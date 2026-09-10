/**
 * init-mysql.js
 * Utility to verify MySQL connection, execute schema.sql, and seed tables.
 * Run with: npm run db:init
 */
require('dotenv').config();
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function main() {
  console.log('--- KisanLink MySQL Database Initializer ---');
  
  const host = process.env.DB_HOST || 'localhost';
  const port = parseInt(process.env.DB_PORT || '3306', 10);
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const database = process.env.DB_NAME || 'kisanlink';

  console.log(`Connecting to MySQL at ${host}:${port} as user "${user}"...`);

  let connection;
  try {
    if (process.env.MYSQL_URL || process.env.DATABASE_URL) {
      connection = await mysql.createConnection(process.env.MYSQL_URL || process.env.DATABASE_URL);
    } else {
      connection = await mysql.createConnection({
        host,
        port,
        user,
        password,
        multipleStatements: true,
        ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined
      });
    }
  } catch (err) {
    console.error('❌ Failed to connect to MySQL:', err.message);
    console.error('\nPlease verify your environment variables in backend/.env:');
    console.error('  DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME (or MYSQL_URL)');
    process.exit(1);
  }

  try {
    console.log(`Creating database "${database}" if not exists...`);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
    await connection.query(`USE \`${database}\``);

    console.log('Reading and executing schema.sql...');
    const schemaPath = path.join(__dirname, '..', 'schema.sql');
    const sql = fs.readFileSync(schemaPath, 'utf-8');

    // Split statements
    const statements = sql
      .split(/;\s*$/m)
      .map(s => s.trim())
      .filter(s => s.length > 0 && !s.startsWith('--'));

    for (let i = 0; i < statements.length; i++) {
      const stmt = statements[i];
      if (stmt.toUpperCase().startsWith('CREATE DATABASE') || stmt.toUpperCase().startsWith('USE ')) continue;
      await connection.query(stmt);
    }

    // Verify row counts
    const [users] = await connection.query('SELECT COUNT(*) AS count FROM users');
    const [buyers] = await connection.query('SELECT COUNT(*) AS count FROM buyers');
    const [crops] = await connection.query('SELECT COUNT(*) AS count FROM crops');
    const [deals] = await connection.query('SELECT COUNT(*) AS count FROM deals');
    const [listings] = await connection.query('SELECT COUNT(*) AS count FROM listings');

    console.log('\n✅ Database initialized and seeded successfully!');
    console.log('--- Current Table Stats ---');
    console.log(`  Users:    ${users[0].count}`);
    console.log(`  Buyers:   ${buyers[0].count}`);
    console.log(`  Crops:    ${crops[0].count}`);
    console.log(`  Deals:    ${deals[0].count}`);
    console.log(`  Listings: ${listings[0].count}`);
    console.log('---------------------------');
  } catch (err) {
    console.error('❌ Error executing schema:', err.message);
    process.exit(1);
  } finally {
    await connection.end();
  }
}

main();
