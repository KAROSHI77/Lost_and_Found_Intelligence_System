-- Lost & Found Item Intelligence System
-- Database triggers

USE lost_found_intelligence;

DROP TRIGGER IF EXISTS before_lost_item_insert;

DELIMITER $$

CREATE TRIGGER before_lost_item_insert
BEFORE INSERT ON lost_item
FOR EACH ROW
BEGIN
    IF NEW.title IS NULL OR TRIM(NEW.title) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lost item title cannot be empty';
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
        (user_id, action, entity_type, entity_id, details)
    VALUES
        (
            NEW.user_id,
            'CREATE_LOST_ITEM',
            'LOST_ITEM',
            NEW.lost_item_id,
            JSON_OBJECT('title', NEW.title, 'status', NEW.status)
        );
END$$

DELIMITER ;

-- To inspect the triggers:
-- SHOW TRIGGERS;
