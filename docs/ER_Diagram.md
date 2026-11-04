
# Entity Relationship Diagram (ERD)

**Project:** Lost & Found Item Intelligence System  
**Database:** MySQL — `lost_found_intelligence`

The ER diagram represents the entities, attributes, primary keys (PK), foreign keys (FK), and relationships implemented in `database/schema.sql`.

```mermaid
erDiagram
    USER {
        int user_id PK
        varchar name
        varchar email UK
        varchar password_hash
        varchar phone
        varchar role
        boolean is_active
        timestamp created_at
    }

    CATEGORY {
        int category_id PK
        varchar name UK
        text description
    }

    LOCATION {
        int location_id PK
        varchar name
        varchar building
        varchar floor
        decimal latitude
        decimal longitude
    }

    LOST_ITEM {
        int lost_item_id PK
        int user_id FK
        int category_id FK
        int location_id FK
        varchar title
        text description
        datetime lost_date_time
        varchar status
        int embedding_id
        timestamp created_at
        timestamp updated_at
    }

    FOUND_ITEM {
        int found_item_id PK
        int user_id FK
        int category_id FK
        int location_id FK
        varchar title
        text description
        datetime found_date_time
        varchar status
        int embedding_id
        timestamp created_at
        timestamp updated_at
    }

    ITEM_MATCH {
        int match_id PK
        int lost_item_id FK
        int found_item_id FK
        decimal similarity_score
        text match_reason
        varchar status
        timestamp created_at
        timestamp updated_at
    }

    CLAIM {
        int claim_id PK
        int user_id FK
        int lost_item_id FK
        int found_item_id FK
        text claim_description
        varchar status
        timestamp created_at
        timestamp resolved_at
    }

    VERIFICATION {
        int verification_id PK
        int claim_id FK,UK
        int verified_by FK
        varchar verification_method
        varchar verification_result
        text notes
        timestamp verified_at
    }

    ITEM_RETURN {
        int return_id PK
        int claim_id FK,UK
        int verified_by FK
        timestamp return_date_time
        varchar status
        text notes
    }

    ITEM_IMAGE {
        int image_id PK
        int lost_item_id FK
        int found_item_id FK
        text image_url
        varchar image_type
        timestamp uploaded_at
    }

    ITEM_EMBEDDING {
        int embedding_id PK
        varchar item_type
        int item_id
        varchar embedding_reference
        varchar model_name
        timestamp created_at
    }

    NOTIFICATION {
        int notification_id PK
        int user_id FK
        varchar related_type
        int related_id
        text message
        varchar status
        timestamp created_at
        timestamp read_at
    }

    AUDIT_LOG {
        int log_id PK
        int user_id FK
        varchar action
        varchar entity_type
        int entity_id
        json details
        varchar ip_address
        timestamp created_at
    }

    USER_SESSION {
        int session_id PK
        int user_id FK
        char token_hash
        datetime expires_at
        boolean revoked
        timestamp created_at
    }

    USER ||--o{ LOST_ITEM : reports
    USER ||--o{ FOUND_ITEM : reports
    USER ||--o{ CLAIM : submits
    USER ||--o{ NOTIFICATION : receives
    USER o|--o{ AUDIT_LOG : generates
    USER ||--o{ USER_SESSION : has
    USER ||--o{ VERIFICATION : performs
    USER ||--o{ ITEM_RETURN : verifies

    CATEGORY ||--o{ LOST_ITEM : classifies
    CATEGORY ||--o{ FOUND_ITEM : classifies
    LOCATION ||--o{ LOST_ITEM : locates
    LOCATION ||--o{ FOUND_ITEM : locates

    LOST_ITEM ||--o{ ITEM_MATCH : participates_in
    FOUND_ITEM ||--o{ ITEM_MATCH : participates_in

    LOST_ITEM o|--o{ CLAIM : references
    FOUND_ITEM ||--o{ CLAIM : claimed_in

    CLAIM ||--o| VERIFICATION : has
    CLAIM ||--o| ITEM_RETURN : results_in

    LOST_ITEM o|--o{ ITEM_IMAGE : associated_with
    FOUND_ITEM o|--o{ ITEM_IMAGE : associated_with
```

## Relationship Notes

- One user can report multiple lost and found items.
- Each lost or found item belongs to one category and one location.
- A lost item and a found item can participate in multiple match records.
- A claim references a found item and can optionally reference a lost item.
- Each claim can have at most one verification record and one return record.
- An item image can reference a lost item, a found item, or both according to the current schema.
- `ITEM_EMBEDDING.item_id` is a general item reference, not a declared foreign key.
- `NOTIFICATION.related_id` and `AUDIT_LOG.entity_id` are not declared foreign keys in the current schema.

**Notation:** PK = Primary Key; FK = Foreign Key; UK = Unique Key.
