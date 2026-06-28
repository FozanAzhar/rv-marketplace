# RV Marketplace

A REST API for renting RVs. Owners post listings, renters request bookings, and owners approve or decline those requests.

Built with **Rails 8** (API-only), **PostgreSQL**, and **JWT** authentication.

## What you can do

- **Sign up / log in** — get a JWT token to use on protected routes
- **Browse listings** — anyone can view available RVs
- **Post a listing** — logged-in users can create, edit, and delete their own RVs
- **Book an RV** — renters request dates; owners confirm or reject the booking

There is also a simple landing page at [http://localhost:3000](http://localhost:3000) and interactive API docs at [http://localhost:3000/api-docs](http://localhost:3000/api-docs).

## Quick start (Docker)

**Requirements:** Docker and Docker Compose

1. Create a `.env` file with your Rails master key (copy the value from `config/master.key`):

   ```
   RAILS_MASTER_KEY=your_key_here
   ```

   Or copy the example: `cp .env.example .env`

2. Start everything:

   ```bash
   docker compose up --build
   ```

3. Open the app:

   | What | URL |
   |------|-----|
   | Landing page | http://localhost:3000 |
   | Health check | http://localhost:3000/up |
   | Browse listings (JSON) | http://localhost:3000/listings |
   | API docs (Swagger) | http://localhost:3000/api-docs |

On first boot, the app creates and migrates the database automatically.

### Handy Docker commands

```bash
docker compose up -d --build   # run in the background
docker compose logs -f web     # follow logs
docker compose exec web bin/rails console
docker compose exec web bundle exec rspec
docker compose down            # stop
docker compose down -v         # stop and wipe the database
```

## Local setup (without Docker)

**Requirements:** Ruby 4.0.5, PostgreSQL 16+

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

Then visit http://localhost:3000/up to confirm the server is running.

### Tests

```bash
bin/rails db:test:prepare
bundle exec rspec
```

## API overview

All responses are JSON. Protected routes need an `Authorization: Bearer <token>` header (returned on signup and login).

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/signup` | No | Create an account |
| POST | `/auth/login` | No | Log in |
| GET | `/listings` | No | List all RVs |
| GET | `/listings/:id` | No | Get one listing |
| POST | `/listings` | Yes | Create a listing |
| PATCH | `/listings/:id` | Yes | Update your listing |
| DELETE | `/listings/:id` | Yes | Delete your listing |
| POST | `/listings/:id/bookings` | Yes | Request a booking |
| GET | `/bookings` | Yes | Your bookings (as renter or owner) |
| PATCH | `/bookings/:id/confirm` | Yes | Owner confirms a pending booking |
| PATCH | `/bookings/:id/reject` | Yes | Owner rejects a pending booking |

For request/response examples, use the [Swagger UI](http://localhost:3000/api-docs).

### Example: sign up and create a listing

```bash
# Sign up
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane","email":"jane@example.com","password":"secret","password_confirmation":"secret"}'

# Use the token from the response
curl -X POST http://localhost:3000/listings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"rv_listing":{"title":"Cozy Camper","description":"Sleeps 4","location":"Denver, CO","price_per_day":120}}'
```

## Project structure

```
app/
  controllers/   # API endpoints (auth, listings, bookings)
  models/        # User, RvListing, Booking
public/
  index.html     # Landing page
swagger/         # OpenAPI spec for /api-docs
```

## Production

The [`Dockerfile`](Dockerfile) is for production (e.g. Kamal). The [`Dockerfile.dev`](Dockerfile.dev) and [`docker-compose.yml`](docker-compose.yml) are for local development only.

```bash
docker build -t rv_marketplace .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<your_key> --name rv_marketplace rv_marketplace
```
