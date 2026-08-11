const { randomUUID }=require('node:crypto');
const bcrypt=require('bcryptjs');
const pool=require('./pool');

async function seed(){
  const institutionId='10000000-0000-4000-8000-000000000001',operatorId='20000000-0000-4000-8000-000000000001',userId='30000000-0000-4000-8000-000000000001',propertyId='40000000-0000-4000-8000-000000000001',routeId='50000000-0000-4000-8000-000000000001';
  await pool.execute("INSERT IGNORE INTO institutions (id,name,type,phone) VALUES (?,'Centro Regional de Emergencias','MEDICAL','107')",[institutionId]);
  const hash=await bcrypt.hash('operador123',10);await pool.execute("INSERT IGNORE INTO operators (id,institution_id,name,email,password_hash) VALUES (?,?,'Operador Demo','operador@sosrural.ar',?)",[operatorId,institutionId,hash]);
  await pool.execute("INSERT IGNORE INTO users (id,first_name,last_name,document,phone,birth_date,background_location_enabled) VALUES (?, 'Juan','Pereyra','30111222','+5493415550110','1984-03-14',TRUE)",[userId]);
  await pool.execute("INSERT IGNORE INTO medical_profiles (id,user_id,blood_type,blood_factor,allergies,medications,cardiovascular_conditions) VALUES (?,?, '0','+','Penicilina','Enalapril 10 mg, una vez por día','Hipertensión')",[randomUUID(),userId]);
  const contacts=[['María Gómez','+5493415550182','Madre',1,1,1],['Julián Pérez','+5493415557741','Encargado',0,1,1],['Ana Ruiz','+5493464552290','Vecina',1,0,0]];
  for(const c of contacts)await pool.execute('INSERT IGNORE INTO emergency_contacts (id,user_id,name,phone,relationship,notify_medical,notify_fire,notify_police) VALUES (?,?,?,?,?,?,?,?)',[randomUUID(),userId,...c]);
  await pool.execute("INSERT IGNORE INTO rural_properties (id,user_id,name,locality,area_hectares,latitude,longitude,entrance_latitude,entrance_longitude,notes) VALUES (?,?,'Campo Las Palmeras','Roldán, Santa Fe',240,-32.9310,-60.9950,-32.9285,-60.9902,'Portón verde después del puente. Evitar entrada oeste cuando llueve.')",[propertyId,userId]);
  await pool.execute("INSERT IGNORE INTO access_routes (id,property_id,name,creation_method,notes,distance) VALUES (?,?,'Entrada norte','DRAWN','Desde RP 26',3.2)",[routeId,propertyId]);
  const pts=[[-32.9082,-60.9752],[-32.9130,-60.9789],[-32.9186,-60.9812],[-32.9240,-60.9856],[-32.9285,-60.9902],[-32.9310,-60.9950]];for(let i=0;i<pts.length;i++)await pool.execute('INSERT IGNORE INTO access_route_points (id,route_id,latitude,longitude,sequence) VALUES (?,?,?,?,?)',[randomUUID(),routeId,...pts[i],i]);
  console.log('Datos demo disponibles: OTP 123456; operador@sosrural.ar / operador123');
}
if(require.main===module)seed().then(()=>pool.end()).catch(e=>{console.error(e);process.exit(1);});
module.exports={seed};
