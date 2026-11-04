# Lost & Found Intelligence System (Node + Express + MySQL)

## Run it (Windows PowerShell, Node 22+, MySQL 8 running)
1. `copy .env.example .env`, then edit `.env` and put your MySQL password in DB_PASSWORD
2. `npm install`
3. `npm run setup`   (runs database/schema.sql, then database/seed.sql once)
4. `npm start`  ->  http://localhost:3001   

You can run the two SQL files in MySQL Workbench instead of step 3 (schema.sql first, then seed.sql).

## Logins (password: password123)
aarav@pes.edu = ADMIN, shreya@pes.edu = USER (also divya / rohan / ananya / meera @pes.edu). New users can register.

## Where each DBMS concept lives
- 14 tables: your 13 + user_session (login sessions)   -> database/schema.sql
- Triggers before_lost_item_insert / after_lost_item_insert -> schema.sql (report a lost item with an empty title; audit_log fills automatically)
- Procedures GetLostItems, GetLostItemsByStatus; function get_match_count; 3 views -> schema.sql, runnable from the "DB lab" tab
- Joins, GROUP BY/HAVING, aggregates, IN / EXISTS / NOT EXISTS / MAX subqueries -> server.js (Q object) and the Dashboard / DB lab tabs
- Transactions: claim approval (START TRANSACTION ... COMMIT/ROLLBACK) and the COMMIT / ROLLBACK / SAVEPOINT demo buttons (admin)
