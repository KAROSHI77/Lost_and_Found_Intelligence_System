-- Lost & Found Item Intelligence System
-- Database indexes and query performance

USE lost_found_intelligence;


SHOW INDEX FROM lost_item;
SHOW INDEX FROM found_item;
SHOW INDEX FROM item_match;
SHOW INDEX FROM notification;


EXPLAIN
SELECT lost_item_id, title, status
FROM lost_item
WHERE status = 'OPEN';

EXPLAIN
SELECT match_id, lost_item_id, found_item_id, similarity_score
FROM item_match
WHERE similarity_score >= 0.90
ORDER BY similarity_score DESC;


EXPLAIN
SELECT notification_id, message, created_at
FROM notification
WHERE user_id = 1
  AND is_read = FALSE;
