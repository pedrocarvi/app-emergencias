const { randomUUID } = require('node:crypto');
const express = require('express');
const { z } = require('zod');
const pool = require('../database/pool');
const { requireUser } = require('../auth/middleware');
const { asyncRoute, HttpError } = require('../utils/http');
const { parse } = require('../utils/validation');

const router=express.Router();
const point=z.object({latitude:z.number().min(-90).max(90),longitude:z.number().min(-180).max(180)});
const schema=z.object({name:z.string().min(1).max(160),creationMethod:z.enum(['RECORDED','DRAWN']),notes:z.string().nullable().optional(),distance:z.number().nonnegative().nullable().optional(),points:z.array(point).min(2)});

router.get('/properties/:propertyId/routes',requireUser,asyncRoute(async(req,res)=>{
  await ownProperty(req.params.propertyId,req.auth.sub);
  const [rows]=await pool.execute('SELECT * FROM access_routes WHERE property_id=? ORDER BY created_at',[req.params.propertyId]);
  res.json(await Promise.all(rows.map(mapRouteWithPoints)));
}));
router.post('/properties/:propertyId/routes',requireUser,asyncRoute(async(req,res)=>{
  await ownProperty(req.params.propertyId,req.auth.sub); const v=parse(schema,req.body); const id=randomUUID(); const cx=await pool.getConnection();
  try{await cx.beginTransaction(); await cx.execute('INSERT INTO access_routes (id,property_id,name,creation_method,notes,distance) VALUES (?,?,?,?,?,?)',[id,req.params.propertyId,v.name,v.creationMethod,v.notes||null,v.distance||null]);
    for(let i=0;i<v.points.length;i++) await cx.execute('INSERT INTO access_route_points (id,route_id,latitude,longitude,sequence) VALUES (?,?,?,?,?)',[randomUUID(),id,v.points[i].latitude,v.points[i].longitude,i]);
    await cx.commit();
  }catch(e){await cx.rollback();throw e;}finally{cx.release();}
  res.status(201).json(await getRoute(id,req.auth.sub));
}));
router.get('/routes/:id',requireUser,asyncRoute(async(req,res)=>res.json(await getRoute(req.params.id,req.auth.sub))));
router.put('/routes/:id',requireUser,asyncRoute(async(req,res)=>{
  const old=await getRoute(req.params.id,req.auth.sub),v=parse(schema,req.body),cx=await pool.getConnection();
  try{await cx.beginTransaction();await cx.execute('UPDATE access_routes SET name=?,creation_method=?,notes=?,distance=? WHERE id=?',[v.name,v.creationMethod,v.notes||null,v.distance||null,old.id]);await cx.execute('DELETE FROM access_route_points WHERE route_id=?',[old.id]);
    for(let i=0;i<v.points.length;i++)await cx.execute('INSERT INTO access_route_points (id,route_id,latitude,longitude,sequence) VALUES (?,?,?,?,?)',[randomUUID(),old.id,v.points[i].latitude,v.points[i].longitude,i]);await cx.commit();
  }catch(e){await cx.rollback();throw e;}finally{cx.release();}res.json(await getRoute(old.id,req.auth.sub));
}));
router.delete('/routes/:id',requireUser,asyncRoute(async(req,res)=>{await getRoute(req.params.id,req.auth.sub);await pool.execute('DELETE FROM access_routes WHERE id=?',[req.params.id]);res.status(204).end();}));

async function ownProperty(id,userId){const [r]=await pool.execute('SELECT id FROM rural_properties WHERE id=? AND user_id=?',[id,userId]);if(!r.length)throw new HttpError(404,'Establecimiento no encontrado');}
async function getRoute(id,userId){const [r]=await pool.execute(`SELECT ar.* FROM access_routes ar JOIN rural_properties p ON p.id=ar.property_id WHERE ar.id=? AND p.user_id=?`,[id,userId]);if(!r.length)throw new HttpError(404,'Ruta no encontrada');return mapRouteWithPoints(r[0]);}
async function mapRouteWithPoints(r){const [points]=await pool.execute('SELECT latitude,longitude,sequence FROM access_route_points WHERE route_id=? ORDER BY sequence',[r.id]);return{id:r.id,propertyId:r.property_id,name:r.name,creationMethod:r.creation_method,notes:r.notes,distance:r.distance,points:points.map(p=>({latitude:p.latitude,longitude:p.longitude,sequence:p.sequence}))};}
module.exports=router;
