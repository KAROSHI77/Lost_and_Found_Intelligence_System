-- Lost & Found Item Intelligence System
-- Transaction management demonstrations

USE lost_found_intelligence;

START TRANSACTION;

UPDATE lost_item
SET description = CONCAT(
    COALESCE(description, ''),
    ' [Transaction demo]'
)
WHERE lost_item_id = -1;

COMMIT;

START TRANSACTION;

UPDATE lost_item
SET status = 'CLOSED'
WHERE lost_item_id = -1;

ROLLBACK;



START TRANSACTION;

SAVEPOINT before_demo;

UPDATE lost_item
SET status = 'CLOSED'
WHERE lost_item_id = -1;

ROLLBACK TO SAVEPOINT before_demo;

COMMIT;

SELECT
    lost_item_id,
    title,
    status
FROM lost_item
ORDER BY lost_item_id;
