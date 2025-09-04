# Influencer Connect

Welcome to the Influencer Connect application! This guide will help you set up and run the project.

## Prerequisites

- **Ruby Version:** ruby-3.4.2

- **System Dependencies:**

## Setup Instructions

1. **Configuration**
    - Copy `.env.example` to `.env` and update environment variables as needed.

2. **Database Creation**
    - Run `rails db:create` to create the database.

3. **Database Initialization**
    - Run `rails db:migrate` to set up the database tables.
    - Run `rails db:seed` to populate initial data for testing or development purposes.

## Services

- Job queues: Sidekiq or ActiveJob
- Cache servers: Redis or Memcached


## Deployment

- Follow your deployment platform's instructions (e.g., Heroku, AWS).
- Ensure all environment variables and secrets are set.

---

For more details, refer to the documentation or contact the maintainers.
