# Backend Setup

## Prerequisites
- Node.js (v18+)
- PostgreSQL database

## Installation

1. Install dependencies:
```bash
cd backend
npm i
```

2. Set up Prisma:
- Download extension **Prisma** to access to Prisma cloud and get connection string
- Copy prisma connection string to `.env` file
- Run these following commands:
```bash
# Generate Prisma Client
npx prisma generate

# Run database migrations
npx prisma migrate dev
```

## Development

Start the development server:
```bash
npm run dev
```

## Prisma Commands

```bash
# Create a new migration
npx prisma migrate dev --name <migration_name>

# Apply migrations in production
npx prisma migrate deploy

# Open Prisma Studio (database GUI)
npx prisma studio

# Reset database (⚠️ deletes all data)
npx prisma migrate reset
```

## Build & Production

```bash
# Build for production
npm run build

# Start production server
npm start
```
