const express=require('express');
const pool=require('../database/pool');
const {requireOperator}=require('../auth/middleware');
const {asyncRoute,HttpError}=require('../utils/http');
const {recordIncidentEvent}=require('../audit/service');
const {mapIncident}=require('../incidents/router');
const {mapMedical}=require('../medical/router');

const router=express.Router();router.use(requireOperator);
router.get('/incidents',asyncRoute(async(req,res)=>{
  const allowed=['PENDING_ATTENTION','ATTENDED','RESOLVED','CANCELLED'];const status=allowed.includes(req.query.status)?req.query.status:null;
  const [rows]=await pool.execute(`SELECT i.*,u.first_name,u.last_name,p.name property_name FROM incidents i JOIN users u ON u.id=i.user_id LEFT JOIN rural_properties p ON p.id=i.property_id WHERE (? IS NULL OR i.status=?) ORDER BY i.created_at DESC LIMIT 200`,[status,status]);
  res.json(rows.map(r=>({...mapIncident(r),userName:`${r.first_name} ${r.last_name}`,propertyName:r.property_name})));
}));
router.get('/incidents/:id',asyncRoute(async(req,res)=>{
  const incident=await getIncident(req.params.id);await recordIncidentEvent(incident.id,'OPERATOR_VIEWED',null,req.auth.sub);
  const [[users],[medical],[contacts],[trail],[events],[notifications]]=await Promise.all([
    pool.execute('SELECT id,first_name,last_name,document,phone,birth_date FROM users WHERE id=?',[incident.user_id]),
    pool.execute('SELECT * FROM medical_profiles WHERE user_id=?',[incident.user_id]),
    pool.execute('SELECT id,name,phone,relationship FROM emergency_contacts WHERE user_id=?',[incident.user_id]),
    pool.execute('SELECT latitude,longitude,accuracy,speed,heading,captured_at,sequence FROM incident_location_points WHERE incident_id=? ORDER BY sequence',[incident.id]),
    pool.execute('SELECT type,metadata,operator_id,created_at FROM incident_events WHERE incident_id=? ORDER BY created_at',[incident.id]),
    pool.execute(`SELECT n.status,n.channel,n.sent_at,c.name,c.phone FROM incident_notifications n JOIN emergency_contacts c ON c.id=n.contact_id WHERE n.incident_id=?`,[incident.id]),
  ]);
  let property=null,routes=[];if(incident.property_id){const [p]=await pool.execute('SELECT * FROM rural_properties WHERE id=?',[incident.property_id]);property=p[0]||null;if(property){const [rr]=await pool.execute('SELECT * FROM access_routes WHERE property_id=?',[property.id]);routes=await Promise.all(rr.map(async r=>{const [points]=await pool.execute('SELECT latitude,longitude,sequence FROM access_route_points WHERE route_id=? ORDER BY sequence',[r.id]);return{...r,points};}));}}
  const u=users[0];res.json({incident:mapIncident(incident),user:u?{id:u.id,firstName:u.first_name,lastName:u.last_name,document:u.document,phone:u.phone,birthDate:u.birth_date}:null,medicalProfile:medical.length?mapMedical(medical[0]):null,contacts,property,routes,trail,events,notifications});
}));
router.post('/incidents/:id/attend',asyncRoute(async(req,res)=>{const i=await getIncident(req.params.id);if(i.status!=='PENDING_ATTENTION')throw new HttpError(409,'Sólo se puede atender un SOS pendiente');await pool.execute("UPDATE incidents SET status='ATTENDED',attended_at=NOW(3) WHERE id=?",[i.id]);await recordIncidentEvent(i.id,'INCIDENT_ATTENDED',null,req.auth.sub);res.json(mapIncident(await getIncident(i.id)));}));
router.post('/incidents/:id/resolve',asyncRoute(async(req,res)=>{const i=await getIncident(req.params.id);if(!['PENDING_ATTENTION','ATTENDED'].includes(i.status))throw new HttpError(409,'La emergencia ya está cerrada');await pool.execute("UPDATE incidents SET status='RESOLVED',resolved_at=NOW(3),attended_at=COALESCE(attended_at,NOW(3)) WHERE id=?",[i.id]);await recordIncidentEvent(i.id,'INCIDENT_RESOLVED',null,req.auth.sub);res.json(mapIncident(await getIncident(i.id)));}));
async function getIncident(id){const [rows]=await pool.execute('SELECT * FROM incidents WHERE id=?',[id]);if(!rows.length)throw new HttpError(404,'Incidente no encontrado');return rows[0];}
module.exports=router;

