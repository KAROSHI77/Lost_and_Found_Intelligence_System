-- Lost & Found Item Intelligence System
-- Stored procedures and functions

USE lost_found_intelligence;

DROP PROCEDURE IF EXISTS GetLostItemsByStatus;

DELIMITER //

CREATE PROCEDURE GetLostItemsByStatus(IN p_status VARCHAR(30))
BEGIN
    SELECT
        lost_item_id,
        title,
        description,
        status,
        lost_date_time
    FROM lost_item
    WHERE status = p_status
    ORDER BY lost_date_time DESC;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS GetLostItems;

DELIMITER //

CREATE PROCEDURE GetLostItems(IN p_limit INT, IN p_offset INT)
BEGIN
    SELECT
        lost_item_id,
        title,
        description,
        status,
        lost_date_time
    FROM lost_item
    ORDER BY lost_date_time DESC
    LIMIT p_limit OFFSET p_offset;
END //

DELIMITER ;


DROP FUNCTION IF EXISTS get_match_count;

DELIMITER //

CREATE FUNCTION get_match_count(p_lost_item_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE match_count INT;

    SELECT COUNT(*)
    INTO match_count
    FROM item_match
    WHERE lost_item_id = p_lost_item_id;

    RETURN match_count;
END //

DELIMITER ;


