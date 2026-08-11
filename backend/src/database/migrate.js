const fs = require('node:fs/promises');
const path = require('node:path');
const pool = require('./pool');

async function migrate() {
  await waitForDatabase();
  const sqlDir = path.join(__dirname, '../../sql');
  const files = (await fs.readdir(sqlDir)).filter((name) => name.endsWith('.sql')).sort();
  for (const filename of files) {
    const [rows] = await pool.query(
      "SELECT COUNT(*) count FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = 'schema_migrations'",
    );
    if (rows[0].count) {
      const [done] = await pool.execute('SELECT filename FROM schema_migrations WHERE filename = ?', [filename]);
      if (done.length) continue;
    }
    const sql = await fs.readFile(path.join(sqlDir, filename), 'utf8');
    const connection = await pool.getConnection();
    try {
      const statements = sql.split(/;\s*(?:\r?\n|$)/).map((item) => item.trim()).filter(Boolean);
      for (const statement of statements) await connection.query(statement);
      await connection.execute('INSERT IGNORE INTO schema_migrations (filename) VALUES (?)', [filename]);
      console.log(`Migración aplicada: ${filename}`);
    } finally { connection.release(); }
  }
}

async function waitForDatabase() {
  let lastError;
  for (let attempt = 1; attempt <= 30; attempt += 1) {
    try {
      await pool.query('SELECT 1');
      return;
    } catch (error) {
      lastError = error;
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
  throw lastError;
}

if (require.main === module) {
  migrate().then(() => pool.end()).catch((error) => { console.error(error); process.exit(1); });
}

module.exports = { migrate };
