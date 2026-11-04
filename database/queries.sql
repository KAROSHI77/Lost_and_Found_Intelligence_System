-- Lost & Found Item Intelligence System
-- SQL queries for searching, matching and reporting

USE lost_found_intelligence;

SELECT lost_item_id, title, description, lost_date_time
FROM lost_item
WHERE status = 'ACTIVE'
ORDER BY lost_date_time DESC;

SELECT found_item_id, title, description, found_date_time
FROM found_item
WHERE status = 'AVAILABLE'
ORDER BY found_date_time DESC;

SELECT l.lost_item_id, l.title, c.name AS category,
       l.status, l.lost_date_time
FROM lost_item l
JOIN category c ON l.category_id = c.category_id
WHERE c.name = 'Electronics'
ORDER BY l.lost_date_time DESC;

SELECT im.match_id,
       l.title AS lost_item,
       f.title AS found_item,
       im.similarity_score,
       im.match_reason,
       im.status AS match_status
FROM item_match im
JOIN lost_item l ON im.lost_item_id = l.lost_item_id
JOIN found_item f ON im.found_item_id = f.found_item_id
ORDER BY im.similarity_score DESC;



SELECT l.title AS lost_item,
       f.title AS found_item,
       im.similarity_score,
       im.match_status
FROM (
    SELECT match_id, lost_item_id, found_item_id,
           similarity_score, status AS match_status
    FROM item_match
    WHERE similarity_score >= 0.90
) im
JOIN lost_item l ON im.lost_item_id = l.lost_item_id
JOIN found_item f ON im.found_item_id = f.found_item_id
ORDER BY im.similarity_score DESC;



SELECT c.name AS category,
       COUNT(l.lost_item_id) AS total_lost_items
FROM category c
LEFT JOIN lost_item l ON c.category_id = l.category_id
GROUP BY c.category_id, c.name
ORDER BY total_lost_items DESC, c.name;


SELECT status, COUNT(*) AS total_matches
FROM item_match
GROUP BY status
ORDER BY total_matches DESC;



SELECT l.lost_item_id, l.title, l.status
FROM lost_item l
WHERE NOT EXISTS (
    SELECT 1
    FROM item_match im
    WHERE im.lost_item_id = l.lost_item_id
);


SELECT cl.claim_id,
       u.name AS claimant,
       l.title AS lost_item,
       f.title AS found_item,
       cl.status AS claim_status,
       cl.created_at
FROM claim cl
JOIN user u ON cl.user_id = u.user_id
LEFT JOIN lost_item l ON cl.lost_item_id = l.lost_item_id
JOIN found_item f ON cl.found_item_id = f.found_item_id
ORDER BY cl.created_at DESC;



SELECT n.notification_id,
       u.name AS recipient,
       n.message,
       n.created_at
FROM notification n
JOIN user u ON n.user_id = u.user_id
WHERE n.status = 'UNREAD'
ORDER BY n.created_at DESC;

SELECT u.user_id, u.name,
       COUNT(DISTINCT l.lost_item_id) AS lost_items_reported,
       COUNT(DISTINCT f.found_item_id) AS found_items_reported
FROM user u
LEFT JOIN lost_item l ON u.user_id = l.user_id
LEFT JOIN found_item f ON u.user_id = f.user_id
GROUP BY u.user_id, u.name
ORDER BY lost_items_reported DESC, found_items_reported DESC;


SELECT c.name AS category,
       COUNT(l.lost_item_id) AS total_lost_items
FROM category c
JOIN lost_item l ON c.category_id = l.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(l.lost_item_id) >= 2
ORDER BY total_lost_items DESC;
