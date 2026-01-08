 # Development: Setup Guide
 
 ## Overview
 
 Instructions for setting up the local development environment.
 
## Prerequisites
- **Node.js:** v20+
- **Python:** v3.12+
- **Supabase Account:** Hosted database + auth (required).
- **Google Cloud Account:** For Gemini API access (optional; only needed for server-side embeddings/recommendations).
- **Pinecone Account:** For vector search (optional; only needed for recommendations).

> FitCheck AI uses **hosted Supabase**. Apply the schema migration in the Supabase SQL Editor — do not run Supabase locally.
 
 ## 1. Backend Setup
 
 ```bash
 cd backend
 python -m venv .venv
 source .venv/bin/activate
 pip install -r requirements.txt
 cp .env.example .env
 ```
 
 **Required Environment Variables:**
 - `SUPABASE_URL`
 - `SUPABASE_PUBLISHABLE_KEY`
 - `SUPABASE_SECRET_KEY`
 - `SUPABASE_JWT_SECRET`
 - `SUPABASE_STORAGE_BUCKET`
 - `GEMINI_API_KEY`
 - `PINECONE_API_KEY`
 
 ## 2. Frontend Setup
 
 ```bash
 cd frontend
 npm install
 cp .env.example .env.local
 ```
 
 **Required Environment Variables:**
 - `VITE_SUPABASE_URL`
 - `VITE_SUPABASE_PUBLISHABLE_KEY`
 - `VITE_API_BASE_URL`
 
## 3. Database Setup
 1. Create a new project in Supabase.
 2. Run the schema migration from `backend/db/supabase/migrations` in the Supabase SQL Editor:
    - `backend/db/supabase/migrations/001_full_schema.sql`
 3. Ensure a Storage bucket matching `SUPABASE_STORAGE_BUCKET` exists (default: `fitcheck-images`). The migration creates the default buckets, but if you change the bucket name you must create it.
 4. (Optional) For local/dev convenience, disable "Confirm email" in Supabase Auth settings or be prepared to confirm new accounts via email before logging in.
 
## 4. Running Locally
 
 **Backend:**
 ```bash
 uvicorn app.main:app --reload
 ```
 
**Frontend:**
```bash
npm run dev
```

## 4.1 Verify Schema + API
After starting the backend, confirm Supabase is initialized:

```bash
curl -sS http://localhost:8000/health
```

You should see `"schema_ready": true`. If it is `false`, apply `backend/db/supabase/migrations/001_full_schema.sql` in the Supabase SQL Editor for your project.

## 5. Testing
- **Backend:** `pytest`
- **Frontend:** `npm test`
