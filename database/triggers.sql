-- Lost & Found Item Intelligence System
-- Database triggers

USE lost_found_intelligence;

DROP TRIGGER IF EXISTS before_lost_item_insert;

DELIMITER //

CREATE TRIGGER before_lost_item_insert
BEFORE INSERT ON lost_item
FOR EACH ROW
BEGIN
    IF NEW.status IS NULL OR NEW.status = '' THEN
        SET NEW.status = 'OPEN';
    END IF;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS after_lost_item_insert;

DELIMITER //

CREATE TRIGGER after_lost_item_insert
AFTER INSERT ON lost_item
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        user_id,
        action,
        table_name,
        record_id,
        action_time
    )
    VALUES (
        NEW.user_id,
        'INSERT',
        'lost_item',
        NEW.lost_item_id,
        CURRENT_TIMESTAMP
    );
END //

DELIMITER ;


