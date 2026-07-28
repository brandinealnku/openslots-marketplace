# Proposed Data Model

A `USER` owns exactly one role profile (customer or provider in the first release). Providers offer services and publish expiring openings. A customer books one opening; a booking snapshots price/scope and owns payments, a review, messages, and possible disputes. Openings require atomic status transitions to prevent double booking. Messages remain booking-scoped. Reviews require completed bookings.

```mermaid
erDiagram
  USER ||--o| CUSTOMER : has
  USER ||--o| PROVIDER : has
  PROVIDER }o--o{ SERVICE : offers
  PROVIDER ||--o{ OPENING : publishes
  SERVICE ||--o{ OPENING : classifies
  CUSTOMER ||--o{ BOOKING : places
  OPENING ||--o| BOOKING : reserved_as
  BOOKING ||--o{ PAYMENT : settles
  BOOKING ||--o| REVIEW : receives
  CUSTOMER ||--o{ REVIEW : writes
  PROVIDER ||--o{ REVIEW : receives
  BOOKING ||--o{ MESSAGE : contains
  USER ||--o{ MESSAGE : sends
  BOOKING ||--o{ DISPUTE : may_raise
  USER {
    uuid id PK
    string role
    string email
  }
  OPENING {
    uuid id PK
    uuid provider_id FK
    datetime starts_at
    datetime expires_at
    string status
    decimal fixed_price
  }
  BOOKING {
    uuid id PK
    uuid opening_id FK
    uuid customer_id FK
    string status
    decimal total
    int version
  }
```

Payments may have multiple attempts but one captured total. A review belongs to both booking and provider through foreign keys. A dispute references a booking and can reference payment evidence. PII and precise addresses require field-level access controls; immutable audit events record sensitive status changes.
