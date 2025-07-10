# The Data Tchoup - Monorepo

A comprehensive data science and analytics platform for the Creole Creamery Hall of Fame challenge. This monorepo contains all components of the project: web application, ETL pipeline, machine learning models, and development tools.

## Project Structure

```
the-data-tchoup/
├── app/                    # Next.js web application
├── ETL/                    # AWS Lambda scraper & infrastructure
├── ml/                     # Machine learning models
├── dev/                    # Development tools & database
└── plan.md                 # Original project specification
```

## Quick Start

### Prerequisites

- Node.js 22+
- Python 3.11+
- Docker
- AWS CLI (for ETL deployment)
- pnpm (for app development)

### Development Setup

1. **Clone the repository with submodules:**

   ```bash
   git clone --recursive <repository-url>
   cd the-data-tchoup
   ```

2. **Set up the web application:**

   ```bash
   cd app
   pnpm install
   cp env.example .env.local
   # Configure your database URL
   pnpm dev
   ```

3. **Set up the ETL pipeline:**

   ```bash
   cd ETL
   poetry install
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   # Configure your AWS and database credentials
   ```

4. **Set up the ML models:**
   ```bash
   cd ml
   poetry install
   # Configure your database connection
   ```

## Component Details

### App (`/app`)

- **Next.js 15** web application with TypeScript
- **Drizzle ORM** for database operations
- **TailwindCSS + shadcn/ui** for styling
- **Recharts** for data visualizations
- **TanStack Query** for state management

**Features:**

- Interactive data dashboard
- Real-time analytics
- Beautiful visualizations
- Mobile-responsive design

### ETL (`/ETL`)

- **AWS Lambda** function for automated data collection
- **OpenAI GPT-4** powered web scraping
- **Terraform** for infrastructure as code
- **Docker** containerization
- **AWS EventBridge** for scheduling

**Features:**

- Daily automated scraping
- LLM-powered data extraction
- Infrastructure automation
- Monitoring and logging

### ML (`/ml`)

- **scikit-learn** for predictive modeling
- **pandas/numpy** for data processing
- **PostgreSQL** integration
- **Feature engineering** from sparse data

**Features:**

- Competition timing predictions
- Pattern analysis
- Model evaluation and validation

### Dev (`/dev`)

- Development tools and utilities
- Database migrations and setup
- Local development environment

## Running Components

### Web Application

```bash
cd app
pnpm dev
# Visit http://localhost:3000
```

### ETL Pipeline (Local Testing)

```bash
cd ETL
poetry shell
python tests/test_scraper.py
```

### ML Model

```bash
cd ml
poetry shell
python src/timing_model.py
```

## Deployment

### Web App (Vercel)

```bash
cd app
vercel --prod
```

### ETL Pipeline (AWS)

```bash
cd ETL
./CICD/deploy.sh
```

## Data Flow

1. **ETL Pipeline** scrapes data daily from Creole Creamery website
2. **ML Models** analyze patterns and make predictions
3. **Web App** visualizes data and provides insights
4. **Database** stores all historical competition data

## Development Workflow

### Adding New Features

1. Create feature branch in main repo
2. Make changes in relevant submodule
3. Commit and push submodule changes
4. Update submodule reference in main repo
5. Create pull request

### Updating Submodules

```bash
# Update all submodules to latest
git submodule update --remote

# Update specific submodule
git submodule update --remote app
```

## Environment Variables

### App Environment

```env
DATABASE_URL=postgresql://username:password@hostname:port/database
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### ETL Environment

```env
NEON_DATABASE_URL=postgresql://username:password@hostname:port/database
OPENAI_API_KEY=sk-your-openai-api-key-here
AWS_REGION=us-east-1
```

### ML Environment

```env
NEON_DATABASE_URL=postgresql://username:password@hostname:port/database
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test all components
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Acknowledgments

- Creole Creamery for the inspiration
- Next.js team for the amazing framework
- OpenAI for LLM capabilities
- AWS for cloud infrastructure
