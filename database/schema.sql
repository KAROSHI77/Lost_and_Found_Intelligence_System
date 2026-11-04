-- Lost & Found Item Intelligence System
-- Stored procedures and functions

USE lost_found_intelligence;

DROP PROCEDURE IF EXISTS GetLostItemsByStatus;
DELIMITER $$

CREATE PROCEDURE GetLostItemsByStatus(IN item_status VARCHAR(20))
BEGIN
    SELECT
        lost_item_id,
        title,
        description,
        status,
        lost_date_time
    FROM lost_item
    WHERE status = item_status;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS GetLostItems;
DELIMITER $$

CREATE PROCEDURE GetLostItems()
BEGIN
    SELECT
        lost_item_id,
        title,
        description,
        status,
        lost_date_time
    FROM lost_item;
END$$

DELIMITER ;

DROP FUNCTION IF EXISTS get_match_count;
DELIMITER $$

CREATE FUNCTION get_match_count(p_lost_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE n INT;

    SELECT COUNT(*)
    INTO n
    FROM item_match
    WHERE lost_item_id = p_lost_id;

    RETURN n;
END$$

DELIMITER ;
