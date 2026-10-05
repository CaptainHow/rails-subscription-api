# Rails Subscription Billing API

A **Rails 8** JSON API for subscription billing: **PostgreSQL**, **ActiveRecord** domain models, **Stripe Checkout** (test mode), and **signed webhooks** that activate subscriptions and log events for idempotency.

Built as a portfolio project demonstrating REST design, validations, integration tests, and payment-provider integration.

## Features

- **Plans** — sellable products with Stripe Price IDs and amounts in cents
- **Users** — email + `has_secure_password` (bcrypt)
- **Subscriptions** — links users to plans (`pending` → `active` via Stripe)
- **Payment events** — webhook audit log with unique `stripe_event_id`
- **Stripe Checkout** — create a hosted checkout session for a pending subscription
- **Webhooks** — verify Stripe signatures (when configured) and handle `checkout.session.completed`

## Stack

- Ruby 3.x, Rails ~> 8.1
- PostgreSQL 16 (Docker)
- Stripe Ruby SDK
- Minitest integration tests

## Prerequisites

- [Ruby](https://rubyinstaller.org/) 3.3+ with Devkit (Windows)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (for Postgres)
- [Stripe](https://dashboard.stripe.com) account (free; use **Test mode**)
- Optional: [Stripe CLI](https://stripe.com/docs/stripe-cli) for local webhooks

## Quick start

```powershell
git clone https://github.com/YOUR_USER/rails-subscription-api.git
cd rails-subscription-api

docker compose up -d
bundle install

# Stripe test keys (Dashboard → Developers → API keys)
$env:STRIPE_SECRET_KEY = "sk_test_..."
$env:STRIPE_WEBHOOK_SECRET = "whsec_..."   # from `stripe listen` or Dashboard webhook

rails db:setup
rails test
rails server
```

API base URL: `http://localhost:3000`

Health check: `GET http://localhost:3000/up`

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `STRIPE_SECRET_KEY` | Yes (for Checkout) | Secret key starting with `sk_test_` |
| `STRIPE_WEBHOOK_SECRET` | Recommended | Webhook signing secret (`whsec_...`) |

Never commit real keys. Use test keys only while developing.

## Database

Postgres runs via Docker (`docker-compose.yml`). Development DB name: `billing_api_development`.

```powershell
docker compose up -d
rails db:create
rails db:migrate
rails db:seed
```

Seeds create **Starter** (£9.99/mo) and **Pro** (£19.99/mo) plans. Update `stripe_price_id` in `db/seeds.rb` to match **test** Prices you create in the Stripe Dashboard, then re-run `rails db:seed`.

Reset database (development):

```powershell
rails db:drop db:create db:migrate db:seed
```

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/v1/plans` | List active plans |
| `GET` | `/api/v1/plans/:id` | Show one plan |
| `POST` | `/api/v1/users` | Register user |
| `POST` | `/api/v1/subscriptions` | Create pending subscription |
| `GET` | `/api/v1/subscriptions/:id` | Show subscription |
| `POST` | `/api/v1/checkout_sessions` | Create Stripe Checkout session |
| `POST` | `/api/v1/webhooks/stripe` | Stripe webhook receiver |
| `GET` | `/success` | Post-checkout redirect (JSON message) |
| `GET` | `/cancel` | Checkout canceled (JSON message) |

List routes:

```powershell
rails routes -g api
```

## Example flow (PowerShell)

With `rails server` running:

```powershell
$base = "http://localhost:3000/api/v1"

# Plans
Invoke-RestMethod -Uri "$base/plans" -Method Get

# Register user
$userBody = @{
  user = @{
    email                 = "demo@example.com"
    password              = "secret123"
    password_confirmation = "secret123"
  }
} | ConvertTo-Json -Depth 3
$user = Invoke-RestMethod -Uri "$base/users" -Method Post -Body $userBody -ContentType "application/json"

# Pending subscription
$plans = Invoke-RestMethod -Uri "$base/plans" -Method Get
$subBody = @{ user_id = $user.id; plan_id = $plans[0].id } | ConvertTo-Json
$sub = Invoke-RestMethod -Uri "$base/subscriptions" -Method Post -Body $subBody -ContentType "application/json"

# Stripe Checkout URL
$checkoutBody = @{ subscription_id = $sub.id } | ConvertTo-Json
$checkout = Invoke-RestMethod -Uri "$base/checkout_sessions" -Method Post -Body $checkoutBody -ContentType "application/json"
$checkout.checkout_url
```

Open `checkout_url` in a browser. Use **Stripe test mode** (page shows **sandbox**). Pay with test card:

- **Number:** `4242 4242 4242 4242`
- **Expiry:** any future date
- **CVC:** any 3 digits

No real money is charged in test mode.

## Local Stripe webhooks

In a second terminal:

```powershell
stripe login
stripe listen --forward-to localhost:3000/api/v1/webhooks/stripe
```

Copy the **webhook signing secret** from the CLI output into `STRIPE_WEBHOOK_SECRET`, restart `rails server`, then complete checkout again.

Verify subscription became active:

```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/v1/subscriptions/$($sub.id)" -Method Get
```

## Tests

```powershell
rails db:test:prepare
rails test
```

Integration tests cover plans, users, subscriptions, and webhook storage.

## Project structure

```
app/models/          Plan, User, Subscription, PaymentEvent
app/controllers/     API v1 + Stripe Checkout + checkout result pages
db/migrate/          Schema migrations
db/seeds.rb          Sample plans
test/                Minitest integration tests + fixtures
config/routes.rb     API routing
```

## Stripe safety

- Keep the Dashboard toggle on **Test mode** while learning.
- Use `sk_test_` keys only in development.
- Do not use your real card on Checkout unless you intentionally switch to **Live** mode (not recommended for this project).

## License

MIT (or adjust as you prefer).
