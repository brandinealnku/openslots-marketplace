# Risk Register

Likelihood and impact are preliminary (`L`, `M`, `H`) and must be reassessed using pilot evidence. This is operational planning, **not legal advice**. Consult qualified legal, tax, security, accessibility, and insurance professionals before launch.

| Risk | Description | Likelihood | Impact | Mitigation | Owner | Address by |
|---|---|---:|---:|---|---|---|
| Marketplace liquidity | Too few matching openings/customers | H | H | Dense ZIP launch, concierge matching, supply targets | GM | Pre-pilot |
| Provider quality | Inconsistent work harms trust | M | H | Standard scopes, probation, review/QA sampling | Provider Ops | Pre-pilot |
| Customer safety | Unsafe encounter or conduct | L | H | Identity checks, reporting, emergency guidance, escalation | Trust lead | Pre-launch |
| Property damage | Service damages home/property | M | H | Insurance review, photos, claims process; consult broker | Risk lead | Pre-launch |
| Mispriced services | Fixed price mismatches actual scope | H | M | Size bands, photos, exception rules, price tests | Product | Pilot |
| Provider cancellations | Last-minute cancellation strands customers | M | H | Reliability score, backup matching, fair exceptions | Provider Ops | Pilot |
| Customer cancellations | Provider loses route income | M | M | Clear tiered policy, reminders, measured fees | Marketplace Ops | Pilot |
| Fraud | Fake identities, stolen cards, collusion | M | H | KYC, velocity limits, risk checks, manual review | Trust lead | Payments beta |
| Chargebacks | Disputed charges create loss | M | H | Evidence, descriptors, signed webhooks, reserve policy | Finance | Payments beta |
| Insurance | Coverage may exclude marketplace work | M | H | Specialist broker/counsel, certificates, renewal tracking | Risk lead | Pre-launch |
| Worker classification | Marketplace controls may create classification exposure | M | H | Counsel review of model, terms, controls and jurisdiction | Legal | Pre-launch |
| Licensing | Category/jurisdiction requires credentials | M | H | Category matrix, geo rules, license validation; counsel | Compliance | Pre-launch |
| Tax obligations | Sales, income, reporting duties missed | M | H | Tax adviser, Stripe Tax analysis, records and forms | Finance | Payments beta |
| Geographic density | Travel times erase slot value | H | H | Adjacent ZIPs, radius caps, density dashboards | GM | Pilot design |
| Route inefficiency | Suggested job causes lateness/cost | M | M | Driving-time buffers, provider confirmation, no guarantees | Product | Routing beta |
| Privacy | Addresses, photos or contact data exposed | M | H | Least privilege, retention, masking, consent, privacy counsel | Privacy | Pre-launch |
| Data security | Account/data compromise | M | H | Threat model, RLS, MFA, encryption, logs, incident plan | Security | Pre-launch |
| Accessibility | Disabled users cannot complete booking | M | H | WCAG 2.2 AA review, keyboard/screen-reader testing | Design | Every release |
| Discrimination | Providers/customers discriminate by location or traits | M | H | Conduct policy, monitoring, reporting, fair enforcement | Trust lead | Pre-launch |
| Algorithmic pricing | Pricing creates unfair/exploitative outcomes | M | H | Bounds, explanations, opt-out, bias tests, human review | Product/Risk | Before automation |
| Fake reviews | Manipulated ratings distort trust | M | M | Completed-booking gate, anomaly detection, appeals | Trust lead | Reviews launch |

Owners must maintain incident playbooks, decision logs, measurable triggers, and residual-risk acceptance. Marketplace terms or insurance language must be drafted and reviewed by appropriate professionals, not inferred from this prototype.
