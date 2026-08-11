const express = require('express');
const { z } = require('zod');
const pool = require('../database/pool');
const { requireUser } = require('../auth/middleware');
const { mapUser } = require('../auth/router');
const { asyncRoute, HttpError } = require('../utils/http');
const { parse } = require('../utils/validation');

const router = express.Router();
router.use(requireUser);

router.get('/me', asyncRoute(async (req, res) => {
  const [rows] = await pool.execute('SELECT * FROM users WHERE id = ?', [req.auth.sub]);
  if (!rows.length) throw new HttpError(404, 'Usuario no encontrado');
  res.json(mapUser(rows[0]));
}));

router.put('/me', asyncRoute(async (req, res) => {
  const input = parse(z.object({
    firstName: z.string().min(1).max(100), lastName: z.string().min(1).max(100),
    document: z.string().max(50).nullable().optional(), birthDate: z.string().nullable().optional(),
    backgroundLocationEnabled: z.boolean().optional(),
  }), req.body);
  await pool.execute(
    `UPDATE users SET first_name=?, last_name=?, document=?, birth_date=?,
     background_location_enabled=COALESCE(?, background_location_enabled) WHERE id=?`,
    [input.firstName, input.lastName, input.document || null, input.birthDate || null,
      input.backgroundLocationEnabled ?? null, req.auth.sub],
  );
  const [rows] = await pool.execute('SELECT * FROM users WHERE id = ?', [req.auth.sub]);
  res.json(mapUser(rows[0]));
}));

module.exports = router;

