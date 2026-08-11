const assert = require('node:assert/strict');
const { randomUUID } = require('node:crypto');

const base = process.env.API_URL || 'http://127.0.0.1:3000';
async function request(path, { method = 'GET', token, body } = {}) {
  const response = await fetch(`${base}${path}`, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = response.status === 204 ? null : await response.json();
  if (!response.ok) throw new Error(`${method} ${path}: ${response.status} ${data?.message}`);
  return { status: response.status, data };
}

async function run() {
  const auth = await request('/auth/verify-otp', { method: 'POST', body: { phone: '+5493415550110', otp: '123456' } });
  const userToken = auth.data.token;
  const medical = await request('/users/me/medical-profile', { method: 'PUT', token: userToken, body: {
    bloodType: '0', bloodFactor: '+', allergies: 'Penicilina', chronicConditions: '',
    medications: 'Enalapril 10 mg', hasDiabetes: false, hasEpilepsy: false,
    cardiovascularConditions: 'Hipertensión', notes: 'Perfil validado por E2E',
  } });
  assert.equal(medical.data.bloodFactor, '+');
  const clientIncidentId = randomUUID();
  const payload = { clientIncidentId, type: 'MEDICAL', latitude: -32.931, longitude: -60.995, accuracy: 5, timestamp: new Date().toISOString() };
  const created = await request('/incidents', { method: 'POST', token: userToken, body: payload });
  assert.equal(created.status, 201);
  assert.equal(created.data.status, 'PENDING_ATTENTION');
  const duplicate = await request('/incidents', { method: 'POST', token: userToken, body: payload });
  assert.equal(duplicate.data.id, created.data.id, 'el reintento debe devolver el mismo incidente');
  await request(`/incidents/${created.data.id}/location-points`, { method: 'POST', token: userToken, body: { points: [
    { latitude: -32.930, longitude: -60.994, accuracy: 6, timestamp: new Date(Date.now() - 60000).toISOString() },
    { latitude: -32.931, longitude: -60.995, accuracy: 5, timestamp: new Date().toISOString() },
  ] } });
  const operatorAuth = await request('/auth/operator/login', { method: 'POST', body: { email: 'operador@sosrural.ar', password: 'operador123' } });
  const operatorToken = operatorAuth.data.token;
  const detail = await request(`/operator/incidents/${created.data.id}`, { token: operatorToken });
  assert.equal(detail.data.trail.length, 2);
  assert.equal(detail.data.medicalProfile.allergies, 'Penicilina');
  await request(`/operator/incidents/${created.data.id}/attend`, { method: 'POST', token: operatorToken });
  const resolved = await request(`/operator/incidents/${created.data.id}/resolve`, { method: 'POST', token: operatorToken });
  assert.equal(resolved.data.status, 'RESOLVED');
  console.log(`E2E OK: incidente idempotente ${created.data.id}, recorrido, datos médicos y transiciones validados.`);
}

run().catch((error) => { console.error(error); process.exit(1); });
