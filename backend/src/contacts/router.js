const { randomUUID } = require('node:crypto');
const express = require('express');
const { z } = require('zod');
const pool = require('../database/pool');
const { requireUser } = require('../auth/middleware');
const { asyncRoute, HttpError } = require('../utils/http');
const { parse } = require('../utils/validation');

const router = express.Router();
router.use(requireUser);
const schema = z.object({
  name: z.string().min(1).max(160), phone: z.string().min(8).max(40), relationship: z.string().min(1).max(60),
  notifyMedical: z.boolean().default(true), notifyFire: z.boolean().default(true), notifyPolice: z.boolean().default(true),
});

router.get('/', asyncRoute(async (req, res) => {
  const [rows] = await pool.execute('SELECT * FROM emergency_contacts WHERE user_id=? ORDER BY created_at', [req.auth.sub]);
  res.json(rows.map(mapContact));
}));

router.post('/', asyncRoute(async (req, res) => {
  const value = parse(schema, req.body); const id = randomUUID();
  await insertContact(id, req.auth.sub, value);
  const [rows] = await pool.execute('SELECT * FROM emergency_contacts WHERE id=?', [id]);
  res.status(201).json(mapContact(rows[0]));
}));

router.put('/:id', asyncRoute(async (req, res) => {
  const value = parse(schema, req.body);
  const [result] = await pool.execute(
    `UPDATE emergency_contacts SET name=?,phone=?,relationship=?,notify_medical=?,notify_fire=?,notify_police=?
     WHERE id=? AND user_id=?`,
    [value.name,value.phone,value.relationship,value.notifyMedical,value.notifyFire,value.notifyPolice,req.params.id,req.auth.sub],
  );
  if (!result.affectedRows) throw new HttpError(404, 'Contacto no encontrado');
  const [rows] = await pool.execute('SELECT * FROM emergency_contacts WHERE id=?', [req.params.id]);
  res.json(mapContact(rows[0]));
}));

router.delete('/:id', asyncRoute(async (req, res) => {
  const [result] = await pool.execute('DELETE FROM emergency_contacts WHERE id=? AND user_id=?', [req.params.id, req.auth.sub]);
  if (!result.affectedRows) throw new HttpError(404, 'Contacto no encontrado');
  res.status(204).end();
}));

function insertContact(id, userId, value) {
  return pool.execute(
    `INSERT INTO emergency_contacts (id,user_id,name,phone,relationship,notify_medical,notify_fire,notify_police)
     VALUES (?,?,?,?,?,?,?,?)`,
    [id,userId,value.name,value.phone,value.relationship,value.notifyMedical,value.notifyFire,value.notifyPolice],
  );
}
function mapContact(r) { return { id:r.id,name:r.name,phone:r.phone,relationship:r.relationship,notifyMedical:Boolean(r.notify_medical),notifyFire:Boolean(r.notify_fire),notifyPolice:Boolean(r.notify_police) }; }

module.exports = { contactsRouter: router, mapContact };
