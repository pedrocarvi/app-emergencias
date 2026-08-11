CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  document VARCHAR(50),
  phone VARCHAR(40) NOT NULL UNIQUE,
  birth_date DATE,
  background_location_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS medical_profiles (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL UNIQUE,
  blood_type VARCHAR(4),
  blood_factor VARCHAR(2),
  allergies TEXT,
  chronic_conditions TEXT,
  medications TEXT,
  has_diabetes BOOLEAN NOT NULL DEFAULT FALSE,
  has_epilepsy BOOLEAN NOT NULL DEFAULT FALSE,
  cardiovascular_conditions TEXT,
  notes TEXT,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_medical_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS emergency_contacts (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  name VARCHAR(160) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  relationship VARCHAR(60) NOT NULL,
  notify_medical BOOLEAN NOT NULL DEFAULT TRUE,
  notify_fire BOOLEAN NOT NULL DEFAULT TRUE,
  notify_police BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  INDEX idx_contacts_user (user_id),
  CONSTRAINT fk_contact_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS rural_properties (
  id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  name VARCHAR(160) NOT NULL,
  locality VARCHAR(160),
  area_hectares DECIMAL(12,2),
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  entrance_latitude DECIMAL(10,7),
  entrance_longitude DECIMAL(10,7),
  notes TEXT,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  INDEX idx_properties_user (user_id),
  CONSTRAINT fk_property_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS access_routes (
  id CHAR(36) PRIMARY KEY,
  property_id CHAR(36) NOT NULL,
  name VARCHAR(160) NOT NULL,
  creation_method ENUM('RECORDED','DRAWN') NOT NULL,
  notes TEXT,
  distance DECIMAL(10,2),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  INDEX idx_routes_property (property_id),
  CONSTRAINT fk_route_property FOREIGN KEY (property_id) REFERENCES rural_properties(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS access_route_points (
  id CHAR(36) PRIMARY KEY,
  route_id CHAR(36) NOT NULL,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  sequence INT NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_route_sequence (route_id, sequence),
  CONSTRAINT fk_route_point FOREIGN KEY (route_id) REFERENCES access_routes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS institutions (
  id CHAR(36) PRIMARY KEY,
  name VARCHAR(180) NOT NULL,
  type ENUM('MEDICAL','FIRE','POLICE') NOT NULL,
  phone VARCHAR(40),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS operators (
  id CHAR(36) PRIMARY KEY,
  institution_id CHAR(36) NOT NULL,
  name VARCHAR(160) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT fk_operator_institution FOREIGN KEY (institution_id) REFERENCES institutions(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS incidents (
  id CHAR(36) PRIMARY KEY,
  client_incident_id CHAR(36) NOT NULL UNIQUE,
  user_id CHAR(36) NOT NULL,
  property_id CHAR(36),
  type ENUM('MEDICAL','FIRE','POLICE') NOT NULL,
  status ENUM('PENDING_ATTENTION','ATTENDED','RESOLVED','CANCELLED') NOT NULL DEFAULT 'PENDING_ATTENTION',
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  accuracy DECIMAL(10,2),
  captured_at DATETIME(3) NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  attended_at DATETIME(3),
  resolved_at DATETIME(3),
  cancelled_at DATETIME(3),
  INDEX idx_incidents_status_created (status, created_at),
  INDEX idx_incidents_user (user_id),
  CONSTRAINT fk_incident_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_incident_property FOREIGN KEY (property_id) REFERENCES rural_properties(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS incident_location_points (
  id CHAR(36) PRIMARY KEY,
  incident_id CHAR(36) NOT NULL,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  accuracy DECIMAL(10,2),
  speed DECIMAL(10,2),
  heading DECIMAL(10,2),
  captured_at DATETIME(3) NOT NULL,
  sequence INT NOT NULL,
  UNIQUE KEY uq_incident_sequence (incident_id, sequence),
  CONSTRAINT fk_incident_point FOREIGN KEY (incident_id) REFERENCES incidents(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS incident_notifications (
  id CHAR(36) PRIMARY KEY,
  incident_id CHAR(36) NOT NULL,
  contact_id CHAR(36) NOT NULL,
  channel ENUM('SMS','WHATSAPP') NOT NULL DEFAULT 'SMS',
  status ENUM('PENDING','SENT','DELIVERED','FAILED') NOT NULL DEFAULT 'PENDING',
  sent_at DATETIME(3),
  delivered_at DATETIME(3),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  UNIQUE KEY uq_incident_contact_channel (incident_id, contact_id, channel),
  CONSTRAINT fk_notification_incident FOREIGN KEY (incident_id) REFERENCES incidents(id) ON DELETE CASCADE,
  CONSTRAINT fk_notification_contact FOREIGN KEY (contact_id) REFERENCES emergency_contacts(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS incident_events (
  id CHAR(36) PRIMARY KEY,
  incident_id CHAR(36) NOT NULL,
  type VARCHAR(80) NOT NULL,
  metadata JSON,
  operator_id CHAR(36),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  INDEX idx_events_incident_created (incident_id, created_at),
  CONSTRAINT fk_event_incident FOREIGN KEY (incident_id) REFERENCES incidents(id) ON DELETE CASCADE,
  CONSTRAINT fk_event_operator FOREIGN KEY (operator_id) REFERENCES operators(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS schema_migrations (
  filename VARCHAR(190) PRIMARY KEY,
  applied_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
) ENGINE=InnoDB;

