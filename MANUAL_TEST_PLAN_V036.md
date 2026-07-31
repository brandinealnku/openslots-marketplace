# Manual test plan — 0.3.6

Use email/password accounts: one admin, two approved/eligible providers, and two customers. Apply migrations and create default customer addresses.

1. Provider edits each public field, adds service/rate/service area, uploads/replaces/deletes valid JPEG/PNG/WebP images, and confirms size/type rejection and completeness checklist.
2. Anonymous user searches providers, opens an approved profile, sees no contact/private/billing/document fields, and receives sign-in prompt for actions. Suspended provider is absent.
3. Customer filters providers, saves/removes one, reloads saved page, requests a time and recurrence, acknowledges direct payment, and opens its conversation.
4. Provider receives notification, asks a question, accepts/declines, and proposes another time. Customer accepts; verify one booking and linked conversation. Repeat acceptance and verify the same booking.
5. With second customer/provider, confirm direct URLs and SQL cannot expose conversations, saves, requests, or proposals; spoofed sender/provider/customer actions fail.
6. Expire provider access: new custom requests and public opening publication fail, while existing conversations/bookings remain readable/manageable.
7. Repeat discovery, save, request, proposal and messaging at 320/375/390/430/768/1440 widths. On physical iPhone Safari verify keyboard/composer/safe area. Check keyboard, zoom, focus, headings, error announcements, long names/messages, and horizontal overflow.
