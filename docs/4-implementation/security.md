 # Implementation: Security
 
 ## Overview
 
 Basic security practices and protections for public launch.
 
 ## 1. Authentication Security
 - **Supabase Auth:** Handles secure session management and password hashing (bcrypt).
 - **JWT Verification:** All API requests must include a valid JWT in the `Authorization` header.
 - **Row-Level Security (RLS):** Enabled on all tables. Users can only `SELECT`, `UPDATE`, or `DELETE` rows where `user_id == auth.uid()`.
 
 ## 2. Data Protection
 - **HTTPS:** Forced on all production environments (Railway/Vercel).
 - **Secrets Management:** Sensitive keys (Gemini API, Supabase Secret) are stored as Environment Variables, never committed to Git.
 - **Input Sanitization:** 
   - Frontend: React automatically escapes content.
   - Backend: Pydantic enforces strict types and patterns.
 
 ## 3. Web Protections
 - **XSS Prevention:** Content Security Policy (CSP) headers configured on the frontend.
 - **CSRF Protection:** Supabase Auth tokens are sent in headers, avoiding cookie-based CSRF vulnerabilities.
 - **SQL Injection:** Parameterized queries via Supabase client (PostgREST).
 
 ## 4. Infrastructure Security
 - **Private Networking:** Database is only accessible via Supabase API or direct connection from the Backend API (via IP allowlist).
 - **Minimal Permissions:** CI/CD tokens (GitHub Actions) have the minimum necessary scopes to deploy.
 
 ## 5. Monitoring
 - **Auth Logs:** Track failed login attempts via Supabase Auth dashboard.
 - **Error Logging:** Backend errors log user IDs to facilitate debugging without exposing PII.
