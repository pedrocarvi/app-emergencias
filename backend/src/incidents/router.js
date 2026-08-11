const { randomUUID } = require('node:crypto');
const express = require('express');
const { z } = require('zod');
const pool = require('../database/pool');
const { requireUser } = require('../auth/middleware');
const { asyncRoute, HttpError } = require('../utils/http');
const { parse } = require('../utils/validation');
const { recordIncidentEvent } = require('../audit/service');
const { queueIncidentNotifications } = require('../notifications/service');

const router=express.Router(); router.use(requireUser);
const createSchema=z.object({clientIncidentId:z.uuid(),type:z.enum(['MEDICAL','FIRE','POLICE']),latitude:z.number().min(-90).max(90),longitude:z.number().min(-180).max(180),accuracy:z.number().nonnegative().nullable().optional(),timestamp:z.iso.datetime(),propertyId:z.uuid().nullable().optional()});
const pointSchema=z.object({latitude:z.number().min(-90).max(90),longitude:z.number().min(-180).max(180),accuracy:z.number().nonnegative().nullable().optional(),speed:z.number().nullable().optional(),heading:z.number().nullable().optional(),timestamp:z.iso.datetime()});

router.post('/',asyncRoute(async(req,res)=>{
  const v=parse(createSchema,req.body);
  const [existing]=await pool.execute('SELECT * FROM incidents WHERE client_incident_id=? AND user_id=?',[v.clientIncidentId,req.auth.sub]);
  if(existing.length){await queueIncidentNotifications(existing[0]);return res.json(mapIncident(existing[0]));}
  if(v.propertyId){const [owned]=await pool.execute('SELECT id FROM rural_properties WHERE id=? AND user_id=?',[v.propertyId,req.auth.sub]);if(!owned.length)throw new HttpError(400,'El establecimiento no pertenece al usuario');}
  const id=randomUUID(),cx=await pool.getConnection();
  try{await cx.beginTransaction();await cx.execute(`INSERT INTO incidents (id,client_incident_id,user_id,property_id,type,latitude,longitude,accuracy,captured_at) VALUES (?,?,?,?,?,?,?,?,?)`,[id,v.clientIncidentId,req.auth.sub,v.propertyId||null,v.type,v.latitude,v.longitude,v.accuracy||null,new Date(v.timestamp)]);await recordIncidentEvent(id,'INCIDENT_CREATED',{source:'MOBILE'},null,cx);await cx.commit();}
  catch(e){await cx.rollback();if(e.code==='ER_DUP_ENTRY'){const [again]=await pool.execute('SELECT * FROM incidents WHERE client_incident_id=? AND user_id=?',[v.clientIncidentId,req.auth.sub]);if(again.length)return res.json(mapIncident(again[0]));}throw e;}finally{cx.release();}
  const [rows]=await pool.execute('SELECT * FROM incidents WHERE id=?',[id]);
  const notified=await queueIncidentNotifications(rows[0]);await recordIncidentEvent(id,'CONTACT_NOTIFICATIONS_QUEUED',{count:notified});
  res.status(201).json(mapIncident(rows[0]));
}));
router.get('/:id',asyncRoute(async(req,res)=>{const row=await ownIncident(req.params.id,req.auth.sub);res.json(mapIncident(row));}));
router.post('/:id/location-points',asyncRoute(async(req,res)=>{
  await ownIncident(req.params.id,req.auth.sub);const {points}=parse(z.object({points:z.array(pointSchema).max(5000)}),req.body);const cx=await pool.getConnection();
  try{await cx.beginTransaction();for(let i=0;i<points.length;i++){const p=points[i];await cx.execute(`INSERT IGNORE INTO incident_location_points (id,incident_id,latitude,longitude,accuracy,speed,heading,captured_at,sequence) VALUES (?,?,?,?,?,?,?,?,?)`,[randomUUID(),req.params.id,p.latitude,p.longitude,p.accuracy||null,p.speed||null,p.heading||null,new Date(p.timestamp),i]);}await recordIncidentEvent(req.params.id,'RECENT_TRAIL_ATTACHED',{pointCount:points.length},null,cx);await cx.commit();}
  catch(e){await cx.rollback();throw e;}finally{cx.release();}res.status(202).json({incidentId:req.params.id,accepted:points.length});
}));
router.post('/:id/cancel',asyncRoute(async(req,res)=>{const incident=await ownIncident(req.params.id,req.auth.sub);if(['RESOLVED','CANCELLED'].includes(incident.status))throw new HttpError(409,'La emergencia ya está cerrada');await pool.execute("UPDATE incidents SET status='CANCELLED',cancelled_at=NOW(3) WHERE id=?",[incident.id]);await recordIncidentEvent(incident.id,'INCIDENT_CANCELLED',{by:'USER'});res.json(mapIncident(await ownIncident(incident.id,req.auth.sub)));}));

async function ownIncident(id,userId){const [rows]=await pool.execute('SELECT * FROM incidents WHERE id=? AND user_id=?',[id,userId]);if(!rows.length)throw new HttpError(404,'Incidente no encontrado');return rows[0];}
function mapIncident(r){return{id:r.id,clientIncidentId:r.client_incident_id,type:r.type,status:r.status,latitude:r.latitude,longitude:r.longitude,accuracy:r.accuracy,timestamp:r.captured_at,createdAt:r.created_at,attendedAt:r.attended_at,resolvedAt:r.resolved_at,cancelledAt:r.cancelled_at};}
module.exports={incidentsRouter:router,mapIncident};
