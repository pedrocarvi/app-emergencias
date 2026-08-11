const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../config');
const { HttpError } = require('../utils/http');

function readToken(req) {
  const value = req.headers.authorization || '';
  if (!value.startsWith('Bearer ')) throw new HttpError(401, 'Falta autenticación');
  try {
    return jwt.verify(value.slice(7), jwtSecret);
  } catch (_) {
    throw new HttpError(401, 'Token inválido o vencido');
  }
}

function requireUser(req, _res, next) {
  try {
    const payload = readToken(req);
    if (payload.role !== 'user') throw new HttpError(403, 'Acceso de usuario requerido');
    req.auth = payload;
    next();
  } catch (error) { next(error); }
}

function requireOperator(req, _res, next) {
  try {
    const payload = readToken(req);
    if (payload.role !== 'operator') throw new HttpError(403, 'Acceso de operador requerido');
    req.auth = payload;
    next();
  } catch (error) { next(error); }
}

module.exports = { requireUser, requireOperator };

