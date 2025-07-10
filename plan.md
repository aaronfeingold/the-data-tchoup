# Tchoupitoulas Data Challenge Application - Build Specification

## Project Overview

Build a sophisticated data analysis application called "Tchoupitoulas Data Challenge".

## Tech Stack Requirements

- **Framework**: Next.js 15+ with App Router, src dir, turbo, pnpm
- **Language**: TypeScript
- **Node Version**: 22
- **Database**: PostgreSQL with Drizzle ORM -- connects to a NeonDB
- **Styling**: Tailwind CSS + shadcn/ui components
- **State Management**: React Query (TanStack Query)
- Table Libraries at your discrection
- Graph/Chart libs at your discrection

## Project Setup

- **use create-next-app, naming it 'tchoupitoulas-data-challenge' and building it in a folder named app**
- mobile first development

## Core Features to Implement

### 1. Database Schema (Prisma ORM)

- currently, we have 1 table in the db. this is what we will be querying from
- there is a also an lambda_function.py file in the creole-creamery-scraper that uses this sql

```typescript
// Core tables needed
                        hall_of_fame_entries (
                            id SERIAL PRIMARY KEY,
                            participant_number INTEGER UNIQUE NOT NULL,
                            name VARCHAR(255) NOT NULL,
                            date_str VARCHAR(50) NOT NULL,
                            parsed_date TIMESTAMP NOT NULL,
                            notes = EXCLUDED.notes,
                            age = EXCLUDED.age,
                            elapsed_time = EXCLUDED.elapsed_time,
                            completion_count = EXCLUDED.completion_count,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                        )
```

### 2. Data Dashboard

- **Data Table**: Paginated table (just load all the data from the query to the hall of fame entries table into state), with the ability to set number of rows in table
  - should be filterable and sortable on each column
  - should be able to search for anything in the dataset
- **Data Dashboard**
  - a number of server actions to query the data, aggregate, and return the data for the frontend to consume and display
  - Year Totals, compared in a bar chart: aggregate number of hall of fame entries records in the calendar year
  - Month by Month, compared in line chart
  - Date in Month: aggregate by plotting the number on each date in the month, or date in range
    - user can select months to view
  - Most Common people: unique names
  - most common name in general
  - longest time frame without a new entry to the hall of fame
  - longest streak: either most days in a row with entries, or most weeks in a row with entries

### 3. Random Forest Model

- Categorization: Predict date of next Hall of Famer

## Design System Requirements

### Visual Theme: Fun and Kid Friendly

- **Primary Colors**: White, some mint
- **Accent Colors**: Subtle pink; use polgy shapes with color gradients faded behind a blur for the background
- **Typography**: Poppins
- **Layout**: Clean, geometric layouts with strong contrast
- **Components**: Rounded edges, minimal shadows, high contrast, on hover effects
- **Inspiration**: An Ice Cream Shop

## Configuration Requirements

- Configure '@' path alias for clean imports; add shortcuts into barrel file
- Set up absolute imports from src directory
- Configure shadcn/ui with custom theme
  - for tailwind, define aliases in globals.css for reusable styles
- Set up React Query for data fetching
- Set up proper TypeScript configurations
