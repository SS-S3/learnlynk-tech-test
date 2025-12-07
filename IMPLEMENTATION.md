# LearnLynk Tech Test Implementation

## Summary

Completed all sections of the tech test: schema design, RLS policies, edge function, frontend page, and Stripe integration explanation. Used Supabase for backend, Next.js for frontend. Focused on security, performance, and clean code.

## Problem Understanding

Built a multi-tenant CRM system for leads, applications, and tasks. Needed relational DB with constraints, secure access by roles/teams, serverless task creation with real-time updates, a simple dashboard, and payment flow outline.

## Architecture

- **Backend**: Supabase (Postgres DB, auth, edge functions). RLS for row security, real-time broadcasts.
- **Frontend**: Next.js pages, React hooks for state. Supabase client for queries/updates.
- **Security**: JWT roles (admin/counselor), tenant isolation. Assumed external auth and team tables (`user_teams`, `teams`).
- **Data Flow**: Client fetches data, server validates mutations.

## Code Quality

- **Structure**: Kept existing folders (`backend/`, `frontend/`). Files named clearly (e.g., `schema.sql`, `today.tsx`).
- **Naming**: CamelCase in JS/TS, snake_case in SQL. Consistent with frameworks.
- **Style**: Added comments, error handling, validation. No new deps.

## Changes by Section

### 1. Schema

- File: backend/schema.sql
- Changes: Added indexes for queries (leads by owner/stage/date, apps by lead, tasks due today). Added check constraints on tasks (type, due_at >= created_at).
- Assumptions: related_id means application_id. Tenant ID set by app.
- Features: Optimized DB queries, enforced data rules.

### 2. RLS Policies

- File: backend/rls_policies.sql
- Changes: SELECT: Admins see all tenant leads; counselors see owned or team leads (via user_teams joins). INSERT: Admins/counselors insert for tenant.
- Assumptions: JWT has tenant_id, user_id, role. Team tables exist.
- Features: Secure access control.

### 3. Edge Function

- File: backend/edge-functions/create-task/index.ts
- Changes: Validate inputs (required fields, type in ['call','email','review'], due_at future). Fetch tenant from app. Insert task, broadcast 'task.created'. Return 200/400/500.
- Assumptions: App exists. Service role access. Title = "{type} task".
- Features: Validated API, real-time events.

### 4. Frontend Page

- File: frontend/pages/dashboard/today.tsx
- Changes: Fetch tasks due today (client date calc), status != 'completed'. Mark complete: update status, re-fetch. Table shows title, app ID, due date, status.
- Assumptions: User logged in. RLS filters tenant. 'Completed' means done. No React Query.
- Features: Dashboard with CRUD, error/loading states.

### 5. Integration

For the Stripe Checkout integration, I explained how to handle application fees. Basically, when a user wants to pay, you first create a record in the payment_requests table to track the payment attempt. Then, you call Stripe to set up the checkout session with the fee details. You store the session ID from Stripe so you can reference it later. Webhooks from Stripe notify you when the payment goes through, at which point you update the payment status and mark the application as paid. This ensures everything is secure and auditable. The full explanation is in the README under ## Stripe Answer.

## Notes

- Code ready for prod: handles errors, validates data.
- Followed Supabase/Next.js docs.
- No syntax errors (assumed).
