 # Implementation: File Structure
 
 ## Overview
 
 Complete project directory layout for FitCheck AI.
 
 ## Directory Tree
 
 ```text
 fitcheck-ai/
 ├── backend/                # FastAPI Application
 │   ├── app/
 │   │   ├── api/            # API Route handlers
 │   │   │   ├── v1/         # Versioned endpoints
 │   │   │   └── deps.py     # Dependencies (Auth, DB)
 │   │   ├── core/           # Config, Security, Logging
 │   │   ├── models/         # Pydantic schemas
 │   │   ├── services/       # Business logic (AI, DB, Mail)
 │   │   ├── agents/         # Pydantic AI Agents
 │   │   ├── db/             # Database migrations & seeds
 │   │   └── main.py         # Entry point
 │   ├── tests/              # Pytest suite
 │   ├── Dockerfile
 │   ├── requirements.txt
 │   └── .env.example
 ├── frontend/               # React Application
 │   ├── src/
 │   │   ├── api/            # Axios instance & API calls
 │   │   ├── components/     # Reusable UI components
 │   │   │   ├── ui/         # shadcn/ui components
 │   │   │   ├── layout/     # Nav, Sidebar, Footer
 │   │   │   └── common/     # Modals, Buttons, Inputs
 │   │   ├── hooks/          # Custom React hooks
 │   │   ├── lib/            # Utilities (Supabase, Utils)
 │   │   ├── pages/          # Page components
 │   │   ├── stores/         # Zustand state stores
 │   │   ├── types/          # TypeScript interfaces
 │   │   ├── App.tsx
 │   │   └── main.tsx
 │   ├── public/
 │   ├── tests/              # Vitest suite
 │   ├── vite.config.ts
 │   ├── tailwind.config.ts
 │   └── package.json
 ├── docker-compose.yml      # Local dev orchestration
 ├── README.md
 └── .gitignore
 ```
 
 ## Key Directories Explained
 
 ### Backend
 - **api/**: Contains route definitions. Logic should be delegated to services.
 - **services/**: Heavy lifting like interacting with Supabase, Stripe, or Weather APIs.
 - **agents/**: Pydantic AI agent definitions and prompt templates.
 - **models/**: All Pydantic v2 models for request validation and response serialization.
 
 ### Frontend
 - **components/ui/**: Managed by shadcn/ui. Don't edit directly unless customizing base styles.
 - **lib/**: Configuration for external SDKs (Supabase, Pinecone).
 - **stores/**: Each file represents a domain (auth, wardrobe, planning).
 - **pages/**: Follows the routing structure.
