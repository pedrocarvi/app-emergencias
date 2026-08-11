const { randomUUID } = require('node:crypto');
const pool = require('../database/pool');

async function recordIncidentEvent(incidentId, type, metadata = null, operatorId = null, connection = pool) {
  await connection.execute(
    `INSERT INTO incident_events (id, incident_id, type, metadata, operator_id)
     VALUES (?, ?, ?, ?, ?)`,
    [randomUUID(), incidentId, type, metadata ? JSON.stringify(metadata) : null, operatorId],
  );
}

module.exports = { recordIncidentEvent };

