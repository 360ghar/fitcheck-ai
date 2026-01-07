 # Development: Setup Guide
 
 ## Overview
 
 Instructions for setting up the local development environment.
 
 ## Prerequisites
 - **Node.js:** v20+
 - **Python:** v3.12+
 - **Docker:** For running Supabase locally (optional) or containerizing the API.
 - **Supabase Account:** For cloud database and auth.
 - **Google Cloud Account:** For Gemini API access.
 
 ## 1. Backend Setup
 
 ```bash
 cd backend
 python -m venv venv
 source venv/bin/activate
 pip install -r requirements.txt
 cp .env.example .env
 ```
 
 **Required Environment Variables:**
 - `SUPABASE_URL`
 - `SUPABASE_KEY`
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
 - `VITE_SUPABASE_ANON_KEY`
 
 ## 3. Database Setup
 1. Create a new project in Supabase.
 2. Run the migration scripts from `backend/db/migrations` in the SQL Editor.
 3. Configure Row-Level Security (RLS) policies.
 4. Create buckets in Storage: `items`, `outfits`, `avatars`.
 
 ## 4. Running Locally
 
 **Backend:**
 ```bash
 uvicorn app.main:app --reload
 ```
 
 **Frontend:**
 ```bash
 npm run dev
 ```
 
 ## 5. Testing
 - **Backend:** `pytest`
 - **Frontend:** `npm test`
