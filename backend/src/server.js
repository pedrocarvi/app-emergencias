const {createApp}=require('./app');
const {port}=require('./config');
const pool=require('./database/pool');
const server=createApp().listen(port,()=>console.log(`SOS Rural API: http://localhost:${port} · dashboard: /dashboard`));
async function stop(){server.close();await pool.end();}
process.on('SIGTERM',stop);process.on('SIGINT',stop);

