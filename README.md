# Smart Retail Store Assistant — Storix

<p align="right">
  🇬🇧 English | <a href="README.vi.md">🇻🇳 Tiếng Việt</a>
</p>

**Smart Retail Store Assistant (Storix)** is a mobile-first inventory management platform for small and medium retail stores.

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.fourmonkeysstudio.storix">
    <img src="https://img.shields.io/badge/Google_Play-Storix-0F9D58?logo=googleplay&logoColor=green"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/AWS-232F3E?logo=amazonaws&logoColor=white" alt="AWS" />
  <img src="https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=white" alt="Terraform" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions&logoColor=white" alt="GitHub Actions" />
</p>

## Why Storix?

Managing inventory in small and medium-sized retail stores often involves repetitive data entry, manual stock tracking, and limited visibility into inventory changes.

Storix brings these workflows together in a mobile-first platform, allowing store operators to manage products, track inventory, record stock transactions, and receive alerts from a single application.

By combining barcode-first workflows, automated notifications, inventory insights, and AI-assisted features, Storix aims to make daily inventory operations faster, more consistent, and easier to manage.

## Screenshots / Demo

<p align="center">
  <img src="docs/images/dashboard.jpg" width="18%" alt="Home Dashboard" />
  <img src="docs/images/dashboard-2.jpg" width="18%" alt="Home Dashboard 2" />
  <img src="docs/images/inventory-hub.jpg" width="18%" alt="Inventory Hub" />
  <img src="docs/images/notifications.jpg" width="18%" alt="Inventory List" />
  <img src="docs/images/transaction-history.jpg" width="18%" alt="Transaction History" />
  <img src="docs/images/chatbot.jpg" width="18%" alt="Chatbot" />
  <img src="docs/images/inventory.jpg" width="18%" alt="Inventory" />
  <img src="docs/images/product.jpg" width="18%" alt="Product" />
  <img src="docs/images/restock.jpg" width="18%" alt="Restock" />
</p>

## Key Features

### Inventory Management
Provides essential tools to manage and monitor stock accurately across daily operations.

- Create import and export transactions
- Adjust inventory when discrepancies occur
- Track stock levels in real-time

### Product Management
Enables flexible and efficient product data management.

- Create, update, and delete products
- Create products quickly using barcode scanning
- Organize products with category management

### Barcode System
Optimizes data entry and product lookup using barcode-first workflows.

- Scan barcode to search or create products
- Cache external barcode API responses to reduce latency
- Map barcode values directly to product packages for fast reuse

### Notifications
Provides real-time alerts to help users respond proactively to inventory issues.

- Low stock warnings
- Reorder suggestions based on thresholds
- Detection of abnormal inventory discrepancies

### Smart Decision Support
Enhances decision-making with data-driven insights and AI-assisted features.

- Suggest optimal reorder quantities
- Identify fast-moving and slow-moving products
- Provide an inventory insights dashboard

### Chatbot:
Chatbot-ready mobile UI for future AI-assisted inventory queries and operational guidance.

- Answers inventory-related questions in natural language.
- Calls backend APIs to execute supported actions

## Tech Stack

| Area | Technologies |
| --- | --- |
| Mobile | Flutter, Dart |
| Backend | Node.js, TypeScript, Express.js |
| ORM | Prisma |
| Database | PostgreSQL, Supabase |
| Cache | Redis |
| Authentication | Supabase Auth |
| Push Notifications | Firebase Cloud Messaging |
| Cloud | AWS |
| Infrastructure | Terraform |
| CI/CD | GitHub Actions |
| Others | Bash |

## Deployment Infrastructure

<p align="center">
  <img src="docs/images/infrastructure.jpg" width="75%"/>
</p>

## Project Structure

```text
.
├── .agents/                         # Prompts to chatbot agent
│   ├── skills/
│   └── AGENTS.md
├── backend/
│   ├── src/
│   │   ├── app.ts                   # Express app factory and middleware setup
│   │   ├── server.ts                # HTTP server entry point
│   │   ├── express.d.ts
│   │   ├── common/                  # Shared backend utilities
│   │   ├── config/
│   │   ├── cron/                    # Scheduled cron jobs for push notification
│   │   ├── db/                      # Database connection instances
│   │   ├── lambda/                  # Handlers for Lambda functions
│   │   └── modules/                 # Feature modules (each follows route → controller → service → repository)
│   │       ├── alerts/
│   │       │   ├──controllers/  # Request handlers
│   │       │   ├──modules/      # Feature module definitions and dependency wiring
│   │       │   ├──repositories/ # Database access layer
│   │       │   ├──routes/       # Route registration
│   │       │   ├──services/     # Business logic
│   │       │   ├──dtos/         # Data transfer objects for request/response validation
│   │       │   ├──types/        # TypeScript types and interfaces
│   │       │   └──validators/   # Input validation schemas and rules
│   │       ├── audit-log/
│   │       ├── auth/
│   │       ├── barcode/
│   │       ├── categories/
│   │       ├── chat-bot/
│   │       └── ...
│   ├── prisma/                      # Prisma data model definitions
│   ├── supabase/                    # Supabase local development configuration
│   ├── tests/                       # Unit tests and intergration tests for backend modules
│   ├── Dockerfile                   # Docker image for EC2/container deployment
│   ├── Dockerfile.lambda            # Docker image optimized for AWS Lambda deployment
│   ├── package-lock.json
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart                # App entry point and initialization
│   │   ├── firebase_options.dart
│   │   ├── core/                    # Shared infrastructure used across all features
│   │   │   ├── infrastructure/
│   │   │   ├── state/
│   │   │   └── ui/
│   │   ├── features/                # Self-contained feature modules
│   │   │   ├── auth/
│   │   │   │   ├── bindings/    # Dependencie inject
│   │   │   │   ├── controllers/ # Handle screen logic
│   │   │   │   ├── models/      # Private models
│   │   │   │   ├── providers/   # Call API from backend
│   │   │   │   └── views/       # Main interface of the feature
│   │   │   ├── home/
│   │   │   ├── inventory/
│   │   │   ├── navigation/
│   │   │   ├── notification/
│   │   │   ├── transaction/
│   │   │   └── ...
│   │   └── routes/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── linux/
│   ├── macos/
│   ├── windows/
│   └── test/
│
├── terraform/                       # Infrastructure as Code (AWS)
│   ├── environments/                # Infrastructure environments
│   │   ├── production/
│   │   └── staging/
│   └── modules/                     # Reusable Terraform modules
│       ├── api_gateway/
│       ├── cloudwatch/
│       ├── ec2/
│       ├── ecr/
│       ├── event_bridge/
│       ├── iam/
│       ├── lambda/
│       ├── networking/
│       ├── route53/
│       ├── s3/
│       ├── sqs/
│       └── ssm_parameter/
│
├── opt-sis/                         # Self-hosted / on-premise deployment configuration
│   ├── nginx/
│   ├── scripts/
│   └── stacks/
│
└── .github/                         # GitHub Actions CI/CD configuration
    ├── workflows/
    │   ├── ci-backend.yml
    │   ├── ci-frontend.yml
    │   ├── cd-backend-ec2.yml
    │   ├── cd-backend-lambda.yml
    │   ├── backup.yml
    │   └── database-keep-alive.yml
    ├── actions/
    ├── ISSUE_TEMPLATE/
    └── CODEOWNERS
```

## Engineering Highlights

- Modular backend architecture with separated
  route, controller, service, and repository layers
- Type-safe backend development with strict TypeScript
- Prisma-based data access with PostgreSQL
- Barcode-first product workflows with API response caching
- Role-based store access control
- Infrastructure managed through Terraform
- Automated CI/CD with GitHub Actions
- Cloud-native deployment using AWS services
