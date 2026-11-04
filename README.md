# Lost & Found Item Intelligence System

A database-driven Lost & Found management system built with **Node.js, Express, and MySQL**. The system helps users report lost and found belongings, identify potential matches, submit claims, and manage item verification and returns.

## Overview

Finding a lost item can be difficult when reports are scattered across different places. This project provides a centralized system for managing lost and found records and connecting potentially matching items.

It is a **Database Management Systems (DBMS) mini-project** demonstrating relational database design, SQL queries, stored procedures, functions, views, triggers, and transaction management in a practical application.

## Features

- **User Authentication:** Register and log in with password hashing and database-backed sessions.
- **Lost Item Reporting:** Submit details about lost belongings.
- **Found Item Reporting:** Register found items.
- **Item Matching:** Identify potential matches using text similarity, category, and location.
- **Match Notifications:** Generate notifications when potential matches are identified.
- **Claim Management:** Allow eligible users to raise claims against matched items.
- **Claim Verification and Return:** Support administrator approval, verification records, and item-return records.
- **Search and Reporting:** Retrieve records using filters, joins, aggregate queries, and subqueries.
- **Role-Based Access:** Restrict selected operations to administrators.
- **Transaction Demonstrations:** Demonstrate COMMIT, ROLLBACK, and SAVEPOINT.

## Technology Stack

| Component | Technology |
|---|---|
| Backend | Node.js |
| Web framework | Express.js |
| Database | MySQL |
| Database driver | mysql2 |
| Password hashing | bcryptjs |
| Frontend | Static files served from `public/` |

## Database Design

The database is named `lost_found_intelligence` and contains 14 tables covering users, item reports, categories, locations, matches, claims, verification, returns, images, embedding references, notifications, audit logs, and user sessions.

### DBMS Concepts Implemented

- **Relational design:** Primary keys, foreign keys, unique constraints, and indexes.
- **Triggers:** Validate lost-item titles and automatically create audit-log entries.
- **Stored procedures:** `GetLostItems` and `GetLostItemsByStatus`.
- **Stored function:** `get_match_count`.
- **Views:** `lost_item_details`, `item_match_details`, and `claim_verification_details`.
- **Joins:** Combine item, user, category, location, claim, and match records.
- **Aggregate functions:** `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`.
- **Grouping:** `GROUP BY` and `HAVING`.
- **Subqueries:** Demonstrate operations using `IN`, `EXISTS`, `NOT EXISTS`, and aggregate subqueries.
- **Transactions:** Use transactional claim approval and administrator transaction demonstrations.

## 📁 Project Structure

```text
Lost_and_Found_Intelligence_System/
├── database/
│   ├── schema.sql
│   ├── seed.sql
│   ├── setup.js
│   ├── queries.sql
│   ├── views.sql
│   ├── procedures.sql
│   ├── triggers.sql
│   ├── transactions.sql
│   └── indexes.sql
├── docs/
│   └── ER_Diagram.md
├── public/
│   └── index.html
├── server.js
├── package.json
├── package-lock.json
├── .env.example
├── .gitignore
└── README.md
```


## Setup and Installation

### Prerequisites

- Node.js 22 or later
- MySQL 8 running locally
- npm

### Windows PowerShell

1. Clone or download this repository and open a terminal in the project directory.
2. Install the dependencies:

   ```powershell
   npm install
   ```

3. Configure your database connection using a `.env` file. If `.env.example` exists, copy it:

   ```powershell
   Copy-Item .env.example .env
   ```

   Set the appropriate values for `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME`. Keep your actual credentials private.

4. Initialize the database and sample data:

   ```powershell
   npm run setup
   ```

5. Start the application:

   ```powershell
   npm start
   ```

6. Open the local URL printed in the terminal. The configured port may differ depending on your environment.

**Alternative:** You can execute `database/schema.sql` and then `database/seed.sql` in MySQL Workbench instead of using the setup script.

## Demo Accounts

The current seed data includes these demonstration accounts:

| Role | Email |
|---|---|
| Administrator | `aarav@pes.edu` |
| User | `shreya@pes.edu` |
| User | `divya@pes.edu` |
| User | `rohan@pes.edu` |
| User | `ananya@pes.edu` |
| User | `meera@pes.edu` |

The existing project documentation specifies `password123` as the demo password. Confirm that the seeded password hashes correspond to this password before distributing the demo credentials.

To access the website, start the application locally using npm start and open the link in browser.
Local Website: http://localhost:3001


## Testing and Verification

The project can be evaluated using the following checks:

- User registration and login.
- Lost and found item creation.
- Matching and notification generation.
- Search and filtering queries.
- Claim submission, approval, verification, and return records.
- Trigger-based input validation and audit logging.
- Stored procedures, function, and views.
- Aggregate queries, grouping, joins, and subqueries.
- Transaction behavior using COMMIT, ROLLBACK, and SAVEPOINT.


## Academic Project

Developed as a Database Management Systems mini-project to apply relational database concepts to a practical Lost & Found use case.
