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
  name:z.string().min(1).max(160), locality:z.string().max(160).nullable().optional(),
  areaHectares:z.number().nonnegative().nullable().optional(), latitude:z.number().min(-90).max(90),
  longitude:z.number().min(-180).max(180), entranceLatitude:z.number().min(-90).max(90).nullable().optional(),
  entranceLongitude:z.number().min(-180).max(180).nullable().optional(), notes:z.string().nullable().optional(),
});

router.get('/', asyncRoute(async (req,res)=>{
  const [rows]=await pool.execute(
    `SELECT p.*, COUNT(r.id) route_count FROM rural_properties p LEFT JOIN access_routes r ON r.property_id=p.id
     WHERE p.user_id=? GROUP BY p.id ORDER BY p.created_at`, [req.auth.sub]);
  res.json(rows.map(mapProperty));
}));
router.post('/', asyncRoute(async(req,res)=>{
  const v=parse(schema,req.body), id=randomUUID();
  await pool.execute(`INSERT INTO rural_properties
    (id,user_id,name,locality,area_hectares,latitude,longitude,entrance_latitude,entrance_longitude,notes)
    VALUES (?,?,?,?,?,?,?,?,?,?)`, [id,req.auth.sub,v.name,v.locality||null,v.areaHectares||null,v.latitude,v.longitude,v.entranceLatitude||null,v.entranceLongitude||null,v.notes||null]);
  res.status(201).json(await getProperty(id,req.auth.sub));
}));
router.get('/:id', asyncRoute(async(req,res)=>res.json(await getProperty(req.params.id,req.auth.sub))));
router.put('/:id', asyncRoute(async(req,res)=>{
  const v=parse(schema,req.body);
  const [result]=await pool.execute(`UPDATE rural_properties SET name=?,locality=?,area_hectares=?,latitude=?,longitude=?,entrance_latitude=?,entrance_longitude=?,notes=? WHERE id=? AND user_id=?`,
    [v.name,v.locality||null,v.areaHectares||null,v.latitude,v.longitude,v.entranceLatitude||null,v.entranceLongitude||null,v.notes||null,req.params.id,req.auth.sub]);
  if(!result.affectedRows) throw new HttpError(404,'Establecimiento no encontrado');
  res.json(await getProperty(req.params.id,req.auth.sub));
}));
router.delete('/:id', asyncRoute(async(req,res)=>{
  const [result]=await pool.execute('DELETE FROM rural_properties WHERE id=? AND user_id=?',[req.params.id,req.auth.sub]);
  if(!result.affectedRows) throw new HttpError(404,'Establecimiento no encontrado');
  res.status(204).end();
}));

async function getProperty(id,userId){
  const [rows]=await pool.execute(`SELECT p.*,COUNT(r.id) route_count FROM rural_properties p LEFT JOIN access_routes r ON r.property_id=p.id WHERE p.id=? AND p.user_id=? GROUP BY p.id`,[id,userId]);
  if(!rows.length) throw new HttpError(404,'Establecimiento no encontrado');
  return mapProperty(rows[0]);
}
function mapProperty(r){return {id:r.id,name:r.name,locality:r.locality,areaHectares:r.area_hectares,latitude:r.latitude,longitude:r.longitude,entranceLatitude:r.entrance_latitude,entranceLongitude:r.entrance_longitude,notes:r.notes,routeCount:Number(r.route_count||0)};}
module.exports={propertiesRouter:router,mapProperty};

