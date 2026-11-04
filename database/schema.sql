CREATE DATABASE IF NOT EXISTS lost_found_intelligence;
USE lost_found_intelligence;

CREATE TABLE IF NOT EXISTS user (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  phone VARCHAR(15),
  role VARCHAR(20) NOT NULL DEFAULT 'USER',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT);

CREATE TABLE IF NOT EXISTS location (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  building VARCHAR(100), floor VARCHAR(50),
  latitude DECIMAL(9,6), longitude DECIMAL(9,6));

CREATE TABLE IF NOT EXISTS lost_item (
  lost_item_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, category_id INT NOT NULL, location_id INT NOT NULL,
  title VARCHAR(150) NOT NULL, description TEXT NOT NULL,
  lost_date_time DATETIME NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  embedding_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (category_id) REFERENCES category(category_id),
  FOREIGN KEY (location_id) REFERENCES location(location_id),
  INDEX (lost_date_time), INDEX (status));

CREATE TABLE IF NOT EXISTS found_item (
  found_item_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, category_id INT NOT NULL, location_id INT NOT NULL,
  title VARCHAR(150) NOT NULL, description TEXT NOT NULL,
  found_date_time DATETIME NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',
  embedding_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (category_id) REFERENCES category(category_id),
  FOREIGN KEY (location_id) REFERENCES location(location_id),
  INDEX (found_date_time), INDEX (status));

CREATE TABLE IF NOT EXISTS item_match (
  match_id INT AUTO_INCREMENT PRIMARY KEY,
  lost_item_id INT NOT NULL, found_item_id INT NOT NULL,
  similarity_score DECIMAL(5,4), match_reason TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (lost_item_id) REFERENCES lost_item(lost_item_id),
  FOREIGN KEY (found_item_id) REFERENCES found_item(found_item_id),
  INDEX (similarity_score), INDEX (status));

CREATE TABLE IF NOT EXISTS claim (
  claim_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, lost_item_id INT, found_item_id INT NOT NULL,
  claim_description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  FOREIGN KEY (lost_item_id) REFERENCES lost_item(lost_item_id),
  FOREIGN KEY (found_item_id) REFERENCES found_item(found_item_id));

CREATE TABLE IF NOT EXISTS verification (
  verification_id INT AUTO_INCREMENT PRIMARY KEY,
  claim_id INT NOT NULL UNIQUE, verified_by INT NOT NULL,
  verification_method VARCHAR(50) NOT NULL,
  verification_result VARCHAR(20) NOT NULL,
  notes TEXT,
  verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id),
  FOREIGN KEY (verified_by) REFERENCES user(user_id));

CREATE TABLE IF NOT EXISTS item_return (
  return_id INT AUTO_INCREMENT PRIMARY KEY,
  claim_id INT NOT NULL UNIQUE, verified_by INT NOT NULL,
  return_date_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'RETURNED',
  notes TEXT,
  FOREIGN KEY (claim_id) REFERENCES claim(claim_id),
  FOREIGN KEY (verified_by) REFERENCES user(user_id));

CREATE TABLE IF NOT EXISTS item_image (
  image_id INT AUTO_INCREMENT PRIMARY KEY,
  lost_item_id INT, found_item_id INT,
  image_url TEXT NOT NULL, image_type VARCHAR(20) NOT NULL,
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (lost_item_id) REFERENCES lost_item(lost_item_id),
  FOREIGN KEY (found_item_id) REFERENCES found_item(found_item_id));

CREATE TABLE IF NOT EXISTS item_embedding (
  embedding_id INT AUTO_INCREMENT PRIMARY KEY,
  item_type VARCHAR(10) NOT NULL, item_id INT NOT NULL,
  embedding_reference VARCHAR(255), model_name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE IF NOT EXISTS notification (
  notification_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL, related_type VARCHAR(20) NOT NULL, related_id INT,
  message TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'UNREAD',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES user(user_id));

CREATE TABLE IF NOT EXISTS audit_log (
  log_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT, action VARCHAR(100) NOT NULL, entity_type VARCHAR(50) NOT NULL,
  entity_id INT, details JSON, ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(user_id));

CREATE TABLE IF NOT EXISTS user_session (
  session_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES user(user_id),
  INDEX (token_hash));

DROP TRIGGER IF EXISTS before_lost_item_insert;
DELIMITER $$
CREATE TRIGGER before_lost_item_insert
BEFORE INSERT ON lost_item
FOR EACH ROW
BEGIN
    IF NEW.title IS NULL OR TRIM(NEW.title)='' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Lost item title cannot be empty';
    END IF;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS after_lost_item_insert;
DELIMITER $$
CREATE TRIGGER after_lost_item_insert
AFTER INSERT ON lost_item
FOR EACH ROW
BEGIN
    INSERT INTO audit_log
    (user_id,action,entity_type,entity_id,details)
    VALUES
    (NEW.user_id,'CREATE_LOST_ITEM','LOST_ITEM',NEW.lost_item_id,
     JSON_OBJECT('title',NEW.title,'status',NEW.status));
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetLostItems;
DELIMITER $$
CREATE PROCEDURE GetLostItems()
BEGIN
    SELECT lost_item_id,title,description,status,lost_date_time
    FROM lost_item;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetLostItemsByStatus;
DELIMITER $$
CREATE PROCEDURE GetLostItemsByStatus(IN item_status VARCHAR(20))
BEGIN
    SELECT lost_item_id,title,description,status,lost_date_time
    FROM lost_item
    WHERE status=item_status;
END$$
DELIMITER ;

DROP FUNCTION IF EXISTS get_match_count;
DELIMITER $$
CREATE FUNCTION get_match_count(p_lost_id INT) RETURNS INT
READS SQL DATA
BEGIN
    DECLARE n INT;
    SELECT COUNT(*) INTO n FROM item_match WHERE lost_item_id=p_lost_id;
    RETURN n;
END$$
DELIMITER ;

CREATE OR REPLACE VIEW lost_item_details AS
SELECT l.lost_item_id,l.title,l.description,c.name AS category,
       loc.name AS location,l.status,l.lost_date_time
FROM lost_item l
JOIN category c ON l.category_id=c.category_id
JOIN location loc ON l.location_id=loc.location_id;

CREATE OR REPLACE VIEW item_match_details AS
SELECT im.match_id,l.title AS lost_item,f.title AS found_item,
       im.similarity_score,im.match_reason,im.status
FROM item_match im
JOIN lost_item l ON im.lost_item_id=l.lost_item_id
JOIN found_item f ON im.found_item_id=f.found_item_id;

CREATE OR REPLACE VIEW claim_verification_details AS
SELECT c.claim_id,c.user_id,c.lost_item_id,c.found_item_id,
       c.status AS claim_status,v.verification_method,
       v.verification_result,v.verified_at
FROM claim c JOIN verification v ON c.claim_id=v.claim_id;
