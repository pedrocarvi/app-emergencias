const { randomUUID } = require('node:crypto');
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { z } = require('zod');
const pool = require('../database/pool');
const { demoOtp, jwtSecret, isProduction } = require('../config');
const { asyncRoute, HttpError } = require('../utils/http');
const { parse } = require('../utils/validation');

const router = express.Router();
const phoneSchema = z.object({ phone: z.string().min(8).max(40) });

router.post('/request-otp', asyncRoute(async (req, res) => {
  const { phone } = parse(phoneSchema, req.body);
  // El proveedor SMS se conecta detrás de esta frontera. En desarrollo el OTP es fijo.
  res.status(202).json({ requestId: randomUUID(), expiresInSeconds: 300, ...(isProduction ? {} : { demoOtp, phone }) });
}));

router.post('/verify-otp', asyncRoute(async (req, res) => {
  const input = parse(phoneSchema.extend({
    otp: z.string().length(6),
    firstName: z.string().min(1).max(100).optional(),
    lastName: z.string().min(1).max(100).optional(),
  }), req.body);
  if (input.otp !== demoOtp) throw new HttpError(401, 'Código incorrecto');
  let [users] = await pool.execute('SELECT * FROM users WHERE phone = ?', [input.phone]);
  if (!users.length) {
    const id = randomUUID();
    await pool.execute(
      'INSERT INTO users (id, first_name, last_name, phone) VALUES (?, ?, ?, ?)',
      [id, input.firstName || 'Juan', input.lastName || 'Pereyra', input.phone],
    );
    [users] = await pool.execute('SELECT * FROM users WHERE id = ?', [id]);
  }
  const user = users[0];
  const token = jwt.sign({ sub: user.id, role: 'user' }, jwtSecret, { expiresIn: '30d' });
  res.json({ token, user: mapUser(user) });
}));

router.post('/operator/login', asyncRoute(async (req, res) => {
  const { email, password } = parse(z.object({ email: z.email(), password: z.string().min(6) }), req.body);
  const [rows] = await pool.execute('SELECT * FROM operators WHERE email = ?', [email]);
  if (!rows.length || !(await bcrypt.compare(password, rows[0].password_hash))) {
    throw new HttpError(401, 'Credenciales incorrectas');
  }
  const operator = rows[0];
  const token = jwt.sign({ sub: operator.id, role: 'operator', institutionId: operator.institution_id }, jwtSecret, { expiresIn: '12h' });
  res.json({ token, operator: { id: operator.id, name: operator.name, email: operator.email } });
}));

function mapUser(row) {
  return {
    id: row.id, firstName: row.first_name, lastName: row.last_name,
    document: row.document, phone: row.phone, birthDate: row.birth_date,
    backgroundLocationEnabled: Boolean(row.background_location_enabled),
  };
}

module.exports = { authRouter: router, mapUser };

