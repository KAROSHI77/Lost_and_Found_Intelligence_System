
-- Lost & Found Item Intelligence System
-- Database views

USE lost_found_intelligence;

CREATE OR REPLACE VIEW lost_item_details AS
SELECT
    l.lost_item_id,
    l.title,
    l.description,
    c.name AS category,
    loc.name AS location,
    l.status,
    l.lost_date_time
FROM lost_item l
JOIN category c ON l.category_id = c.category_id
JOIN location loc ON l.location_id = loc.location_id;

CREATE OR REPLACE VIEW item_match_details AS
SELECT
    im.match_id,
    l.title AS lost_item,
    f.title AS found_item,
    im.similarity_score,
    im.match_reason,
    im.status
FROM item_match im
JOIN lost_item l ON im.lost_item_id = l.lost_item_id
JOIN found_item f ON im.found_item_id = f.found_item_id;

CREATE OR REPLACE VIEW claim_verification_details AS
SELECT
    c.claim_id,
    c.user_id,
    c.lost_item_id,
    c.found_item_id,
    c.status AS claim_status,
    v.verification_method,
    v.verification_result,
    v.verified_at
FROM claim c
JOIN verification v ON c.claim_id = v.claim_id;

-- Example queries to test the views
SELECT * FROM lost_item_details;
SELECT * FROM item_match_details;
SELECT * FROM claim_verification_details;
