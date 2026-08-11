const path=require('node:path');
const express=require('express');
const cors=require('cors');
const helmet=require('helmet');
const {authRouter}=require('./auth/router');
const usersRouter=require('./users/router');
const {medicalRouter}=require('./medical/router');
const {contactsRouter}=require('./contacts/router');
const {propertiesRouter}=require('./properties/router');
const routesRouter=require('./routes/router');
const {incidentsRouter}=require('./incidents/router');
const operatorsRouter=require('./operators/router');

function createApp(){
  const app=express();
  app.use(helmet({contentSecurityPolicy:{directives:{defaultSrc:["'self'"],scriptSrc:["'self'",'https://unpkg.com'],styleSrc:["'self'","'unsafe-inline'",'https://unpkg.com','https://fonts.googleapis.com'],fontSrc:["'self'",'https://fonts.gstatic.com'],imgSrc:["'self'",'data:','https://tile.openstreetmap.org'],connectSrc:["'self'"]}}}));
  app.use(cors());app.use(express.json({limit:'3mb'}));
  app.get('/health',(_req,res)=>res.json({status:'ok',service:'sos-rural-api'}));
  app.use('/auth',authRouter);app.use('/users',usersRouter);app.use('/users',medicalRouter);
  app.use('/contacts',contactsRouter);app.use('/properties',propertiesRouter);app.use('/',routesRouter);
  app.use('/incidents',incidentsRouter);app.use('/operator',operatorsRouter);
  app.use('/dashboard',express.static(path.join(__dirname,'../public')));
  app.get('/',(_req,res)=>res.redirect('/dashboard'));
  app.use((req,res)=>res.status(404).json({message:'Recurso no encontrado',path:req.path}));
  app.use((error,_req,res,_next)=>{const status=error.status||500;if(status>=500)console.error(error);res.status(status).json({message:status===500?'Error interno':error.message,details:error.details});});
  return app;
}
module.exports={createApp};
