const { randomUUID } = require('node:crypto');
const express = require('express');
const { z } = require('zod');
const pool = require('../database/pool');
const { requireUser } = require('../auth/middleware');
const { asyncRoute } = require('../utils/http');
const { parse } = require('../utils/validation');

const router = express.Router();
router.use(requireUser);
const schema = z.object({
  bloodType: z.enum(['0', 'A', 'B', 'AB']).nullable().optional(),
  bloodFactor: z.enum(['+', '-']).nullable().optional(), allergies: z.string().nullable().optional(),
  chronicConditions: z.string().nullable().optional(), medications: z.string().nullable().optional(),
  hasDiabetes: z.boolean().default(false), hasEpilepsy: z.boolean().default(false),
  cardiovascularConditions: z.string().nullable().optional(), notes: z.string().nullable().optional(),
});

router.get('/me/medical-profile', asyncRoute(async (req, res) => {
  const [rows] = await pool.execute('SELECT * FROM medical_profiles WHERE user_id = ?', [req.auth.sub]);
  res.json(rows.length ? mapMedical(rows[0]) : null);
}));

router.put('/me/medical-profile', asyncRoute(async (req, res) => {
  const value = parse(schema, req.body);
  await pool.execute(
    `INSERT INTO medical_profiles
     (id,user_id,blood_type,blood_factor,allergies,chronic_conditions,medications,has_diabetes,has_epilepsy,cardiovascular_conditions,notes)
     VALUES (?,?,?,?,?,?,?,?,?,?,?) AS new
     ON DUPLICATE KEY UPDATE blood_type=new.blood_type,blood_factor=new.blood_factor,allergies=new.allergies,
     chronic_conditions=new.chronic_conditions,medications=new.medications,has_diabetes=new.has_diabetes,
     has_epilepsy=new.has_epilepsy,cardiovascular_conditions=new.cardiovascular_conditions,notes=new.notes`,
    [randomUUID(), req.auth.sub, value.bloodType || null, value.bloodFactor || null, value.allergies || null,
      value.chronicConditions || null, value.medications || null, value.hasDiabetes, value.hasEpilepsy,
      value.cardiovascularConditions || null, value.notes || null],
  );
  const [rows] = await pool.execute('SELECT * FROM medical_profiles WHERE user_id = ?', [req.auth.sub]);
  res.json(mapMedical(rows[0]));
}));

function mapMedical(row) {
  return {
    id: row.id, bloodType: row.blood_type, bloodFactor: row.blood_factor, allergies: row.allergies,
    chronicConditions: row.chronic_conditions, medications: row.medications,
    hasDiabetes: Boolean(row.has_diabetes), hasEpilepsy: Boolean(row.has_epilepsy),
    cardiovascularConditions: row.cardiovascular_conditions, notes: row.notes,
  };
}

module.exports = { medicalRouter: router, mapMedical };

