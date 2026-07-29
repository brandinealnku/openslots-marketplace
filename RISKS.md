# v0.2 risks

- The schema/RLS/RPC design has not been exercised against a live project in this environment; execute the representative SQL/JWT tests before production.
- The existing polished screens still primarily use explicit demo context; completing all connected UI wiring is outstanding and production must not enable demo mode.
- The lightweight REST/Auth adapter lacks official SDK refresh/realtime ergonomics. Session integration is not yet complete.
- Approval reservations need a deployed scheduler. No job is falsely claimed as active.
- Cancellation policy currently permits customer cancellation in the RPC without a time-window rule; configure the intended marketplace policy before launch.
- Client MIME/size checks are supplemental; Storage bucket constraints and RLS are authoritative, but malware scanning is absent.
- Payments, tax and payout estimates are simulations and are not accounting records.
