# RV Marketplace API

Rails 8 API-only application for listing RVs, managing bookings, and JWT authentication.

## Requirements

- Ruby 4.0.5 (see [`.ruby-version`](.ruby-version))
- PostgreSQL 16+
- Docker and Docker Compose (optional, for containerized local development)

## Local setup (without Docker)

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server
```

Health check: [http://localhost:3000/up](http://localhost:3000/up)

API docs (Swagger UI): [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

### Tests

```bash
bin/rails db:test:prepare
bundle exec rspec
```

## Docker Compose (local development)

Run the app and PostgreSQL with a single command. The production [`Dockerfile`](Dockerfile) is unchanged; development uses [`Dockerfile.dev`](Dockerfile.dev).

### 1. Configure environment

Copy the example env file and set your Rails master key (the value in `config/master.key`):

```bash
cp .env.example .env
```

Edit `.env`:

```
RAILS_MASTER_KEY=your_master_key_here
```

Docker Compose reads `.env` automatically.

### 2. Start services

```bash
docker compose up --build
```

On first boot, the web container runs `db:prepare` (creates and migrates the database) and starts the Rails server on port 3000.

### 3. Verify the API

- Health: [http://localhost:3000/up](http://localhost:3000/up)
- Listings: [http://localhost:3000/listings](http://localhost:3000/listings)
- Swagger UI: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

### Useful commands

```bash
# Run in the background
docker compose up -d --build

# View logs
docker compose logs -f web

# Open a Rails console
docker compose exec web bin/rails console

# Run the test suite
docker compose exec web bundle exec rspec

# Stop containers
docker compose down

# Stop and remove database volume (fresh DB)
docker compose down -v
```

### Services

| Service | Image / build | Port | Purpose |
|---------|---------------|------|---------|
| `web`   | `Dockerfile.dev` | 3000 | Rails API |
| `db`    | `postgres:16`    | (internal only) | PostgreSQL — not published to the host, so it won't conflict with a local Postgres on port 5432 |

The web service connects via `DATABASE_URL=postgres://postgres:postgres@db:5432/rv_marketplace_development` on the Docker network.

## Production Docker

The [`Dockerfile`](Dockerfile) targets production deployment (e.g. with Kamal). Build and run manually:

```bash
docker build -t rv_marketplace .
docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name rv_marketplace rv_marketplace
```
