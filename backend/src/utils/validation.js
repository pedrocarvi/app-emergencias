const { HttpError } = require('./http');

function parse(schema, value) {
  const result = schema.safeParse(value);
  if (!result.success) {
    throw new HttpError(400, 'Datos inválidos', result.error.flatten());
  }
  return result.data;
}

module.exports = { parse };

