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
Lost & Found Item Intelligence System

An intelligent Lost & Found management system designed to help people report, search for, match, and recover lost belongings through organized records and intelligent item matching.

## Project Overview

The Lost & Found Item Intelligence System is a Database Management Systems (DBMS) mini-project that aims to simplify the process of managing lost and found items.

The system will allow users to report lost belongings, register found items, search for relevant records, and identify potential matches between lost and found reports. It aims to make item recovery more organized, efficient, and user-friendly.

##  Project Objectives

- Create a centralized system for managing lost and found items.
- Maintain structured records of items, categories, dates, and locations.
- Help identify potential matches between lost and found reports.
- Provide an organized process for item claims and verification.
- Apply database concepts to a practical, real-world problem.
- Improve the efficiency of searching for and recovering lost belongings.

## Key Features

The following features are planned for the system and will be updated as development progresses.

- **Lost Item Reporting:** Record details of lost belongings.
- **Found Item Reporting:** Register items that have been found.
- **Item Search:** Search and filter records using relevant details.
- **Intelligent Matching:** Identify potential matches between lost and found items.
- **Claim Management:** Support the process of claiming a recovered item.
- **Verification:** Help verify item ownership before return.
- **Database Management:** Maintain organized and consistent records.

## Technology Stack

The final technologies will be documented after the implementation is confirmed.

- **Frontend:** To be confirmed
- **Backend:** To be confirmed
- **Database:** To be confirmed
- **Development Tools:** To be confirmed

##  System Architecture

The planned system will connect users to the application through a frontend interface, application logic, and a database.

```text
              +------------------+
              |      Users       |
              +------------------+
                       |
                       v
              +------------------+
              | Frontend Interface|
              +------------------+
                       |
                       v
              +------------------+
              | Backend / API    |
              +------------------+
                       |
                       v
              +------------------+
              |    Database      |
              +------------------+
```

*The architecture will be updated to reflect the final implementation.*

## Database Management

The database component will organize information related to users, lost items, found items, and the item recovery process.

Database documentation will include the SQL components actually implemented by the team, such as:

- Database schema and table relationships
- Primary keys and foreign keys
- Data insertion, retrieval, and modification
- SQL queries and joins
- Aggregate functions and subqueries
- Views
- Stored procedures
- Triggers
- Transactions and integrity constraints

## Entity Relationship Diagram

The ER diagram will represent the entities, attributes, relationships, and constraints used in the system.

*The ER diagram will be added after the database design is finalized.*

## 📂 Project Structure

The repository will be organized as development progresses.

```text
Lost_and_Found_Intelligence_System/
├── README.md
├── database/
│   ├── schema.sql
│   ├── queries
│   ├── views.sql
│   ├── procedures.sql
│   └── triggers.sql
└── docs/
    └── ER_Diagram.png

 ##Testing

Testing documentation will describe the test cases used to verify database operations and application functionality, including:

Item registration and retrieval

Searching and filtering items

Matching lost and found records

Input validation

Database constraints and relationships

Claim and verification workflows




