# Member 4 Payment and Review Module

## Purpose

This module extends the existing `Payments` and `Reviews` tables without renaming their original columns or changing their assignment relationships. It supports payment-record status management, commission calculations, client/freelancer payment history, assignment reviews, and rating summaries. It is a database coursework ledger, not a live payment processor.

## Coursework requirements covered

| Member 4 requirement | Database support |
| --- | --- |
| Build payment recording and status management | `dbo.usp_RecordPayment`, `dbo.usp_TransitionPayment`, and payment validation triggers |
| Build client/freelancer reviews and ratings | `dbo.usp_CreateAssignmentReview`, review validation/rating trigger, and participant review summary view |
| Display payment history and review details/result summaries | `dbo.vw_PaymentHistory`, `dbo.vw_PaymentStatusHistory`, `dbo.vw_ReviewDetails`, and `dbo.vw_ParticipantReviewSummary` |
| Connect payment logic to the shared schema | Existing FKs to assignments, milestones, clients, and freelancers remain; payment participant consistency is checked against `ProjectAssignments` |
| Create SQL objects/queries where needed | Fee and rating UDFs, views, procedures, and triggers listed below |
| Provide test and report evidence | Rollback-only SQL smoke test is in `Database/tests/08_payment_review_smoke_test.sql`; capture actual SQL Server output after running it in the team's database environment |

The assessment brief asks for project payment recording/status, client and freelancer reviews, reporting, and database integrity through SQL objects. It identifies online payment integration as a possible future expansion rather than a required gateway in the current scope.

## Shared-schema relationships

- One `ProjectAssignment` can have many `Payments`; a payment may point to one optional `ProjectMilestone`.
- Payment `ClientID` and `FreelancerID` must match the selected assignment. The payment trigger validates this against the existing parent rows.
- One payment can have many `PaymentStatusHistory` events. Each history row references its payment and is append-only.
- A completed assignment can have at most one review in each direction, protected by the existing unique constraint on `(AssignmentID, ReviewerType)`.
- `ClientToFreelancer` reviews update `Freelancers.AverageRating`; `FreelancerToClient` reviews update `Clients.ClientRating`.

## Payment lifecycle

New payment requests start as `Pending`. Allowed transitions are:

| Current status | Allowed next statuses |
| --- | --- |
| `Pending` | `Held in Escrow`, `Failed`, `Cancelled` |
| `Held in Escrow` | `Released`, `Refunded`, `Disputed` |
| `Disputed` | `Held in Escrow`, `Released`, `Refunded` |
| `Released` | `Refunded` |
| `Refunded`, `Failed`, `Cancelled` | Terminal |

The transition procedure checks the actor type and participant ID for client/freelancer actions, requires a reason, and records the status event. Those actor IDs must come from verified server-side authentication; a value supplied directly by an untrusted browser is not proof of identity. `TR_Payments_UpdateAccountTotals` includes only `Released` payments in the cached totals: gross amount for client spending and net amount for freelancer earnings. A full refund reverses these totals. Payment rows are retained instead of deleted.

`Pending`, `Held in Escrow`, and `Disputed` are ledger labels only. They do not establish that money has been authorized, captured, protected in escrow, or paid out. That requires a trusted server-side integration with a payment provider.

## Commission

`PlatformFeeRate` is saved on each payment so a future rate change does not recalculate old payments. The stored procedure calculates:

```text
platform fee = round(gross amount × fee-rate snapshot, 2)
freelancer net = gross amount − platform fee
```

For example, a gross amount of 1,000.00 at the sample rate 0.1000 produces a fee of 100.00 and a freelancer net of 900.00. The sample rate is a coursework assumption only; it is not a commercial pricing policy. The record procedure also locks the assignment while checking outstanding totals, rejects payments exceeding the agreed assignment or milestone value, and uses a unique idempotency key so a retried request cannot create a duplicate.

## Reviews and result summaries

`usp_CreateAssignmentReview` requires the assignment to be completed and derives the reviewee from the correct assignment participant. A client cannot review an unrelated freelancer, and a freelancer cannot review an unrelated client. Existing rating triggers recalculate both participant ratings after review insert/update/delete. An assignment with published reviews cannot be reopened.

The review-detail view includes project title, reviewer/reviewee names, score, comment, date, and a completed-assignment indicator. The participant summary includes stored rating, current average, and review count for both user types.

## SQL objects

- **UDFs:** `ufn_CalculatePlatformFee`, `ufn_CalculateFreelancerRating`, `ufn_CalculateClientRating`.
- **Views:** existing project payment summary plus payment history, payment status history, review details, and participant review summary.
- **Procedures:** payment recording, payment status transition, assignment review creation, client/freelancer payment history, and date-filtered payment revenue summary.
- **Triggers:** released-payment account totals; payment status validation/history; immutable payment audit history; review participant/completion/rating validation; and protection against reopening a reviewed assignment.
- **SQL permissions:** `NeuroHirePaymentReviewAppRole` receives only SELECT on the module views and EXECUTE on the module procedures; assign this role only to a trusted backend database principal, never to browser users.

## Password hashing and payment security

The request used “hashing” to refer to both payments and reviews. Those data should not be password-hashed: the platform needs to read amounts, statuses, scores, and review text to report them. A digest of a payment is not authorization, encryption, fraud detection, or proof that a provider transferred money.

Passwords are different. The implemented backend uses memory-hard scrypt (N=131072, r=8, p=1), a unique 16-byte salt, a 64-byte derived key, and timing-safe verification. Plain SHA-256 is unsuitable for password storage. The SQL sample password markers remain non-authenticating; the local preview setup creates dedicated accounts with usable scrypt hashes. See [runtime setup and security choices](./PaymentPreview.md).

Do not store card numbers, CVV/CVC values, bank passwords, or raw provider credentials in `Payments`, review comments, sample data, HTML, or Git. A real payment implementation should use a provider-hosted or tokenized payment flow over HTTPS and store only safe provider references. PCI SSC states that card verification codes must not be stored after authorization, even encrypted. The browser must not connect directly to SQL Server; a backend must authenticate/authorize the actor and issue parameterized procedure calls with secrets kept outside the repository.

Security references: [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html), [PCI SSC card verification code FAQ](https://www.pcisecuritystandards.org/faqs/1319/), and [Microsoft.Data.SqlClient parameter guidance](https://learn.microsoft.com/en-us/sql/connect/ado-net/configure-parameters?view=sql-server-ver15).

## Run and verify

On a clean SQL Server database, run scripts `setup_database.sql`, `01` through `07` in the documented order, then `08_payment_review_module.sql`. After loading the sample data and creating the Member 4 objects, run:

```text
Database/tests/08_payment_review_smoke_test.sql
```

The SQL smoke test uses an outer transaction and rolls back its sample changes. The SQL module is now used by the Member 4 Express API and local interface. Genuine browser screenshots and API checks are in [Payment preview evidence](./PaymentPreview.md#verification-and-screenshots). There is no real-money gateway integration.

### Local database validation

Validated on 24 November 2026 against SQL Server 2022 running in the local Linux test container. A clean run of `setup_database.sql`, scripts `01` through `08`, and synthetic sample loading completed. The sample load reported 10 payments and 10 reviews. The Member 4 migration was rerun to check that it can be applied again. The rollback-only smoke test passed its direct-status-update rejection, invalid-transition rejection, unfinished-assignment-review rejection, idempotency retry, commission/net calculation, payment-history audit, cached-total reconciliation, and verified-review display checks.

The SQL test above validates database objects. Subsequent API and browser checks verify local sign-in, role/ownership restrictions, payment workflows, and review publication; see [runtime verification and screenshots](./PaymentPreview.md#verification-and-screenshots). They do not demonstrate real escrow, payouts, or a payment gateway.
