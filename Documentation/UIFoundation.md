# UI route foundation

The UI in this branch is a minimal starting point. It reserves separate URLs for work owned by different roles/modules and uses only a small amount of shared CSS. It is not a finished product design.

## Route map

| Area | Workspace placeholder | Reserved sign-in placeholder |
| --- | --- | --- |
| Freelancer | `/Application/freelancer/` | `/Application/freelancer/login/` |
| Client | `/Application/client/` | `/Application/client/login/` |
| Admin | `/Application/admin/` | `/Application/admin/login/` |
| Proposals and assignments | `/Application/proposals/` | Access rules not decided |
| Payments and reviews | `/Application/payments/client/`, `/Application/payments/freelancer/`, `/Application/payments/admin/` | `/Application/payments/login/` (working module sign-in) |

The root `/Application/` page is only a link to these separate paths. It is not a shared dashboard. Proposal and payment/review pages are modules, not user identities; their eventual access should be authorized for the correct signed-in client, freelancer, or administrator.

## What is implemented

- A small shared stylesheet in `Shared/styles.css` for the navy, warm-white, butter-gold, and cyan palette, basic typography, page width, and links.
- A cyan neural-brain brand mark in `Shared/neurohire-mark.svg`, inspired by the team's reference image.
- Separate static HTML route placeholders for the areas listed above.
- Separate freelancer, client, and admin sign-in URLs which currently only say “Coming soon.”

Other members' pages remain placeholders. Member 4 implements login, role permissions, SQL-connected payment/review workflows, and a Node.js backend in its own directories. See [Payment preview setup](./PaymentPreview.md). It records a demonstration ledger without processing real money. Separate paths do not imply separate domains; deployment can map hostnames later if the team chooses.

## Contribution boundaries

Each member can build the assigned module in its directory and add module-specific styles locally. Keep the shared stylesheet small and coordinate changes to it with the team lead. Do not treat a placeholder sign-in route as secure access: implement and test real authentication and role authorization before exposing private data or admin operations.
