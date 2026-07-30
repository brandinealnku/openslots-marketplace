# Booking status transitions (0.3.4)

The schema's canonical lowercase enum values remain authoritative.

| From | To | Actor / condition |
|---|---|---|
| `requested` | `confirmed` | Owning approved/active provider, before response deadline |
| `requested` | `declined` | Owning approved/active provider, reason required |
| `requested` | `customer_cancelled` | Owning customer (legacy `transition_booking`) |
| `requested` | expired/released | Scheduled expiration function |
| `confirmed` | `provider_en_route` | Owning provider (legacy workflow) |
| `confirmed` | `customer_cancelled` / `provider_cancelled` | Participant (legacy workflow) |
| `provider_en_route` | `in_progress` | Owning provider |
| `in_progress` | `completed` | Owning provider |

The 0.3.4 UI exposes only provider accept/decline. Unsupported or payment-dependent actions are omitted. `respond_to_booking_request` locks the booking, validates ownership, current state, deadline and provider standing, then changes the opening, creates the customer notification and audit event in the same transaction.
