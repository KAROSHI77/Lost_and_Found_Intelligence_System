
# Entity Relationship Diagram (ERD)

This diagram represents the main entities and foreign-key relationships in the Lost & Found Item Intelligence System.

```mermaid
erDiagram
    USER ||--o{ LOST_ITEM : reports
    USER ||--o{ FOUND_ITEM : reports
    USER ||--o{ CLAIM : submits
    USER ||--o{ NOTIFICATION : receives
    USER ||--o{ AUDIT_LOG : generates
    USER ||--o{ USER_SESSION : has
    USER ||--o{ VERIFICATION : performs
    USER ||--o{ ITEM_RETURN : verifies

    CATEGORY ||--o{ LOST_ITEM : classifies
    CATEGORY ||--o{ FOUND_ITEM : classifies
    LOCATION ||--o{ LOST_ITEM : located_at
    LOCATION ||--o{ FOUND_ITEM : located_at

    LOST_ITEM ||--o{ ITEM_MATCH : matched_in
    FOUND_ITEM ||--o{ ITEM_MATCH : matched_in

    LOST_ITEM o|--o{ CLAIM : referenced_by
    FOUND_ITEM ||--o{ CLAIM : claimed_in
    CLAIM ||--o| VERIFICATION : has
    CLAIM ||--o| ITEM_RETURN : results_in

    LOST_ITEM o|--o{ ITEM_IMAGE : has
    FOUND_ITEM o|--o{ ITEM_IMAGE : has
```

## Entities

- **USER:** Stores user accounts, roles, and authentication details.
- **CATEGORY:** Classifies reported items.
- **LOCATION:** Stores campus locations.
- **LOST_ITEM / FOUND_ITEM:** Stores lost and found reports.
- **ITEM_MATCH:** Records potential matches and similarity scores.
- **CLAIM:** Tracks claims made against found items.
- **VERIFICATION:** Stores claim verification details.
- **ITEM_RETURN:** Records item return information.
- **ITEM_IMAGE:** Stores image references for reported items.
- **ITEM_EMBEDDING:** Stores references to item embedding data.
- **NOTIFICATION:** Stores user notifications.
- **AUDIT_LOG:** Records selected system actions.
- **USER_SESSION:** Stores hashed session tokens and expiry details.
