require('dotenv').config();

module.exports = {
  port: Number(process.env.PORT || 3000),
  db: {
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT || 3306),
    database: process.env.DB_NAME || 'sos_rural',
    user: process.env.DB_USER || 'sos_user',
    password: process.env.DB_PASSWORD || 'sos_password',
    connectionLimit: 10,
    decimalNumbers: true,
  },
  jwtSecret: process.env.JWT_SECRET || 'local-development-secret',
  demoOtp: process.env.DEMO_OTP || '123456',
  isProduction: process.env.NODE_ENV === 'production',
  sms: {
    provider: process.env.SMS_PROVIDER || 'console',
    accountSid: process.env.TWILIO_ACCOUNT_SID,
    authToken: process.env.TWILIO_AUTH_TOKEN,
    from: process.env.TWILIO_FROM,
  },
};
