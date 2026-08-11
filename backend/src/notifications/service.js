const { randomUUID } = require('node:crypto');
const pool = require('../database/pool');
const { sms } = require('../config');

function contactFilter(type) {
  return type === 'MEDICAL' ? 'notify_medical' : type === 'FIRE' ? 'notify_fire' : 'notify_police';
}

async function queueIncidentNotifications(incident) {
  const column = contactFilter(incident.type);
  const [contacts] = await pool.query(`SELECT * FROM emergency_contacts WHERE user_id=? AND ${column}=TRUE`, [incident.user_id]);
  for (const contact of contacts) {
    const id = randomUUID();
    const [inserted] = await pool.execute('INSERT IGNORE INTO incident_notifications (id,incident_id,contact_id,channel,status) VALUES (?,?,?,\'SMS\',\'PENDING\')',[id,incident.id,contact.id]);
    if (!inserted.affectedRows) continue;
    try {
      await sendSms(contact.phone, buildMessage(incident));
      await pool.execute("UPDATE incident_notifications SET status='SENT',sent_at=NOW(3) WHERE incident_id=? AND contact_id=? AND channel='SMS'",[incident.id,contact.id]);
    } catch (_) {
      await pool.execute("UPDATE incident_notifications SET status='FAILED' WHERE incident_id=? AND contact_id=? AND channel='SMS'",[incident.id,contact.id]);
    }
  }
  return contacts.length;
}
function buildMessage(incident) {
  const label = incident.type === 'MEDICAL' ? 'Médico' : incident.type === 'FIRE' ? 'Bomberos' : 'Policía';
  return `ALERTA DE EMERGENCIA\nSe generó un SOS ${label}.\nUbicación: https://maps.google.com/?q=${incident.latitude},${incident.longitude}\nEl centro de emergencias fue notificado.`;
}
async function sendSms(to, body) {
  if (sms.provider === 'console') return;
  if (sms.provider !== 'twilio' || !sms.accountSid || !sms.authToken || !sms.from) {
    throw new Error('Proveedor SMS incompleto');
  }
  const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${sms.accountSid}/Messages.json`, {
    method: 'POST',
    headers: { Authorization: `Basic ${Buffer.from(`${sms.accountSid}:${sms.authToken}`).toString('base64')}`, 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ To: to, From: sms.from, Body: body }),
  });
  if (!response.ok) throw new Error(`SMS provider ${response.status}`);
}
module.exports={queueIncidentNotifications};
