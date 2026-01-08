# Tech Stack

## Overview

This document details all technologies used in FitCheck AI, with justifications for each choice.

## Backend Technologies

### Framework: FastAPI

**Version:** 0.104+ (Python 3.12)

**Why FastAPI:**
- Modern, fast Python web framework
- Automatic OpenAPI documentation
- Async/await support for better performance
- Type hints with Pydantic for data validation
- Built-in dependency injection
- Easy testing with TestClient
- Great community and ecosystem

**Alternatives Considered:**
- Django: Too heavy, overkill for MVP
- Flask: Less modern, more boilerplate
- Node.js/Express: Better for JS-first teams, but Python has better AI support

---

### Database: Supabase (PostgreSQL)

**Version:** PostgreSQL 15+

**Why Supabase:**
- Managed PostgreSQL with automatic backups
- Built-in authentication (Auth)
- Real-time subscriptions
- Row-Level Security (RLS)
- Storage solution included
- Excellent TypeScript support
- Free tier available
- Easy migration from local to cloud

**Features Used:**
- PostgreSQL 15 for relational data
- Supabase Auth for user authentication
- Supabase Storage for image storage
- Row-Level Security for data isolation
- Real-time subscriptions (future)

**Alternatives Considered:**
- AWS RDS: More expensive, complex setup
- Google Cloud SQL: Similar cost, less integrated
- MongoDB: No relational joins needed, but PostgreSQL better for complex queries
- Firebase: Real-time focused, but NoSQL

---

### Vector Database: Pinecone

**Version:** Pinecone SDK 3.0+

**Why Pinecone:**
- Managed vector database (no devops)
- Excellent similarity search performance
- Auto-scaling
- Easy Python SDK
- Supports 768-dim embeddings (Gemini)
- Affordable pricing
- Low latency

**Use Case:**
- Store and search item embeddings
- Find visually similar items
- Style matching recommendations

**Alternatives Considered:**
- Weaviate: Self-hosted option, but more complex
- Milvus: Open source, but requires infrastructure
- Qdrant: Good option, but Pinecone has better managed experience
- PostgreSQL + pgvector: Viable option, but less performant for large datasets

---

### Schema Definition: Pydantic v2

**Version:** 2.5+

**Why Pydantic v2:**
- Data validation with type hints
- Fast performance (Rust backend in v2)
- Excellent integration with FastAPI
- Automatic JSON serialization
- Schema generation for OpenAPI
- Email validation, URL validation built-in
- Custom validators easy to write

**Use Case:**
- Validate all API request/response bodies
- Type safety across application
- Automatic OpenAPI schema generation

---

### Agentic System (Future): Pydantic AI

**Version:** 0.0.12+ (latest)

**Why Pydantic AI:**
- Python-native agent framework
- Built on Pydantic for type safety
- Easy integration with LLMs (Gemini, OpenAI)
- Tool calling support
- Streaming responses
- Great developer experience

**Use Case:**
- Orchestrate AI workflows
- (Future) Server-side agent workflows if we move generation/extraction off the client
- Manage recommendation agent

**Alternatives Considered:**
- LangChain: More complex, steeper learning curve
- AutoGen: Microsoft-focused, less Pythonic
- CrewAI: Good for multi-agent systems, but Pydantic AI is simpler for our use case

---

### HTTP Client: httpx

**Version:** 0.25+

**Why httpx:**
- Async/await support
- HTTP/2 support
- HTTP/1.1 fallback
- Connection pooling
- Timeout support
- Similar API to requests (familiar)

**Alternatives Considered:**
- aiohttp: Older, less modern
- requests: No async support

---

### AI Models: Google Gemini

**Gemini 3 Flash (gemini-3-flash-preview)**
- **Purpose:** Fast multimodal analysis (vision + text)
- **Why:** Low-latency, strong reasoning for structured extraction and tagging
- **Use Case:** Fallback/auxiliary analysis when needed (e.g., validation, quick classification)
- **Cost:** Usage-based pricing

**Gemini Nano Banana Pro (gemini-3-pro-preview)**
- **Purpose:** High-quality vision chat (image → structured JSON)
- **Why:** Strong multimodal understanding for extraction and tagging
- **Use Case:** Item Extraction Agent (server-side via Backend AI API)
- **Cost:** Usage-based pricing (API keys per user or system default)

**Gemini Nano Banana Pro (gemini-3-pro-image-preview)**
- **Purpose:** High-quality image generation (txt2img)
- **Why:** Strong fashion visualization quality; supports OpenAI-compatible API format
- **Use Case:** Outfit Generation Agent (server-side via Backend AI API)
- **Cost:** Usage-based pricing (API keys per user or system default)

**Gemini Embeddings (gemini-embedding-001)**
- **Purpose:** Generate text and image embeddings
- **Why:** 768-dim vectors, excellent similarity search
- **Use Case:** Item similarity, style matching
- **Cost:** Cheaper than generation models

**Why Google Gemini:**
- State-of-the-art performance
- Competitive pricing
- Good Python SDK
- Multi-modal (text + image)
- Continuous improvements

**Alternatives Considered:**
- OpenAI GPT-4 DALL-E: More expensive, comparable quality
- Stable Diffusion: Open source, but requires more infrastructure
- Midjourney: Great quality, but no official API

---

## Frontend Technologies

### Framework: React 18

**Version:** 18.2+

**Why React:**
- Industry standard
- Large ecosystem
- Great community support
- Flexible component architecture
- React Router for navigation
- Virtual DOM for performance

**Features Used:**
- Hooks for state management
- React Router for routing
- Context API for auth state

**Alternatives Considered:**
- Vue.js: Simpler, but smaller ecosystem
- Angular: Too opinionated, steep learning curve
- Svelte: Great performance, but newer ecosystem

---

### Language: TypeScript

**Version:** 5.3+

**Why TypeScript:**
- Type safety catches bugs early
- Excellent IDE support
- Better developer experience
- Self-documenting code
- Easier refactoring
- Industry standard for React

**Features Used:**
- Interface definitions
- Type inference
- Generic types
- Union types

**Alternatives Considered:**
- JavaScript: No type safety, more runtime errors
- Flow: Less popular, worse tooling

---

### Build Tool: Vite 5

**Version:** 5.0+

**Why Vite:**
- Fast development server (ESM)
- Instant hot module replacement (HMR)
- Optimized production builds (Rollup)
- Great plugin ecosystem
- TypeScript support out of the box
- Modern bundling approach

**Alternatives Considered:**
- Webpack: Slower, more complex configuration
- Parcel: Simpler, but less control
- Create React App: No longer recommended, less flexible

---

### UI Library: shadcn/ui + Tailwind CSS

**shadcn/ui Version:** Latest
**Tailwind CSS Version:** 3.4+

**Why shadcn/ui:**
- Built on Radix UI (accessible)
- Copy-and-paste components (full control)
- Highly customizable
- Beautiful, modern design
- Dark mode support
- TypeScript support

**Why Tailwind CSS:**
- Utility-first approach
- Small bundle size (tree-shake unused styles)
- Consistent design system
- Easy customization
- Great DX with IntelliSense

**Features Used:**
- shadcn/ui components (Button, Input, Card, Dialog, etc.)
- Tailwind utility classes for styling
- Custom theme configuration

**Alternatives Considered:**
- Material-UI: Heavy, less customizable
- Chakra UI: Good, but shadcn/ui is more modern
- Bootstrap: Dated, less flexible
- CSS-in-JS (Styled Components): More complex, larger bundles

---

### State Management: TanStack Query + Zustand

**TanStack Query Version:** 5.17+
**Zustand Version:** 4.4+

**Why TanStack Query (Server State):**
- Automatic caching and refetching
- Optimistic updates
- Background refetching
- Pagination support
- Great TypeScript support
- Built-in loading/error states

**Why Zustand (Client State):**
- Simple and lightweight
- No context provider required
- Great TypeScript support
- Easy to use
- No boilerplate

**State Split:**
- **TanStack Query:** API data (items, outfits, user profile)
- **Zustand:** UI state (modals, filters, theme)

**Alternatives Considered:**
- Redux: Too complex, too much boilerplate
- Context API: Too verbose, performance issues
- SWR: Good, but TanStack Query has more features

---

### Charts: Recharts + D3.js

**Recharts Version:** 2.10+
**D3.js Version:** 7.8+

**Why Recharts:**
- Built on D3 (powerful + easy to use)
- Declarative API (React components)
- Great TypeScript support
- Responsive by default
- Good documentation

**Why D3.js:**
- For custom visualizations beyond Recharts capabilities
- Powerful data visualization library
- Flexible and customizable

**Use Cases:**
- **Recharts:** Bar charts, line charts, pie charts
- **D3.js:** Custom visualizations, complex interactions

**Alternatives Considered:**
- Chart.js: Good, but less React-friendly
- ApexCharts: Good, but Recharts is more declarative

---

### Forms: React Hook Form + Zod

**React Hook Form Version:** 7.48+
**Zod Version:** 3.22+

**Why React Hook Form:**
- Excellent performance (minimized re-renders)
- Small bundle size
- Easy to use
- Great TypeScript support
- Integrates with validation libraries

**Why Zod:**
- TypeScript-first schema validation
- Excellent error messages
- Schema composition
- Works with Pydantic on backend (same schema language)
- Small bundle size

**Integration:**
- Use `@hookform/resolvers` for Zod integration
- Automatic validation on submit
- Client-side error messages

**Alternatives Considered:**
- Formik: More boilerplate, less performant
- Yup: Similar to Zod, but Zod has better TypeScript support

---

### Routing: React Router v6

**Version:** 6.21+

**Why React Router:**
- Industry standard for React routing
- Nested routes support
- Code splitting (lazy loading)
- Great TypeScript support
- Active development

**Features Used:**
- Route protection (require auth)
- Dynamic routes
- Query parameters
- Programmatic navigation

**Alternatives Considered:**
- Next.js: Full-stack framework, but we have separate backend
- Reach Router: Smaller, but less ecosystem support

---

### Server-Side AI & Image Processing: Backend AI API

**Version:** Latest

**Why Backend AI API:**
- Unified server-side AI processing via FastAPI
- Uses OpenAI-compatible API format for flexibility
- Supports multiple providers: Gemini, OpenAI, custom proxy
- Per-user provider configuration with system defaults
- API keys stored encrypted in database

**AI Inference Use Cases:**
- **Item Extraction (Vision → JSON):** Extract category/colors/material/brand from photos
- **Outfit Visualization (txt2img):** Generate try-on/flat-lay images for outfits
- **Product Image Generation:** Create clean e-commerce style product photos

**Image Optimization Use Cases:**
- Compress user uploads before storing
- Reduce bandwidth usage
- Lazy loading for image galleries
- Responsive image generation
- Format conversion (WebP, AVIF support)

**Benefits:**
- **Centralized AI Control:** Server manages all AI processing and credentials
- **Provider Flexibility:** Users can configure their own API keys or use system defaults
- **Better Security:** API keys encrypted and stored server-side
- **Consistent Experience:** Same AI behavior across all clients

**Alternatives Considered:**
- Client-side AI: Server-side provides better control and security
- TensorFlow.js: Heavier bundle size, more complex setup
- ONNX.js: Good performance, but less browser compatibility

---

## Infrastructure

### Containerization: Docker + Docker Compose (Optional)

**Docker Version:** 24.0+
**Docker Compose Version:** 2.20+

**Why Docker:**
- Consistent development and production environments
- Easy deployment
- Dependency isolation
- Container orchestration ready

**Why Docker Compose:**
- Optional for deployment workflows that need containers
- Keeps API container configs reproducible

**Use Cases:**
- Run API in container
- Run Redis (future)

> Local development uses **hosted Supabase**. Do not run Supabase locally for this project.

---

### CI/CD: GitHub Actions

**Why GitHub Actions:**
- Free for public repositories
- Integrated with GitHub
- YAML configuration (easy to read)
- Great marketplace (actions)
- Fast startup

**Pipeline Steps:**
1. Run tests
2. Build Docker image
3. Push to container registry
4. Deploy to Railway

**Alternatives Considered:**
- GitLab CI: Good, but we use GitHub
- CircleCI: Good, but GitHub Actions is integrated

---

### Deployment: Railway

**Why Railway:**
- Simple deployment (connect GitHub repo)
- Automatic SSL certificates
- Auto-scaling
- Easy to use
- Good pricing
- Supports Docker containers
- Built-in monitoring

**Pricing:**
- Free tier available (for development)
- Pro tier: $5-20/month depending on usage

**Deployment Strategy:**
- Connect GitHub repo
- Automatic deployment on push to main
- Environment variables configured in Railway
- Domain: fitcheck-ai.railway.app

**Alternatives Considered:**
- Heroku: More expensive, removed free tier
- Vercel: Great for frontend, but we need Docker
- AWS: Too complex, expensive
- DigitalOcean: Good, but requires more devops

---

### Logging: Structured Logging

**Format:** JSON

**Why Structured Logging:**
- Easy to parse and query
- Better for log aggregation (ELK, Datadog)
- Consistent format
- Rich metadata

**Python Implementation:**
```python
import logging
import json

class JSONFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
            "service": "fitcheck-ai",
            "request_id": getattr(record, "request_id", None),
        })
```

**Log Levels:**
- DEBUG: Detailed debugging information
- INFO: Normal operations
- WARNING: Potential issues
- ERROR: Errors that don't stop service
- CRITICAL: Service-impacting errors

---

## Security Technologies

### Password Hashing: bcrypt (Supabase)

**Why bcrypt:**
- Industry standard
- Slow hashing (prevents brute force)
- Automatic salt
- Built into Supabase Auth

---

### Encryption: AES-256 (Supabase)

**Why AES-256:**
- Military-grade encryption
- Industry standard
- Supabase encrypts all data at rest

---

### HTTPS: Let's Encrypt (Railway)

**Why Let's Encrypt:**
- Free SSL certificates
- Automatic renewal
- Industry standard
- Integrated with Railway

---

## Third-Party Integrations

### Weather: OpenWeatherMap API

**Version:** 3.0

**Why OpenWeatherMap:**
- Free tier available (1,000 calls/day)
- Good data accuracy
- 7-day forecast
- Current weather
- Simple API

**Alternatives Considered:**
- WeatherAPI: More expensive, better accuracy
- AccuWeather: Expensive, corporate focus

---

### Email: Resend

**Why Resend:**
- Great developer experience
- Good API
- Competitive pricing
- React email templates

**Use Cases:**
- Transactional emails (signup, password reset)
- Notifications (price alerts, streak reminders)

**Alternatives Considered:**
- SendGrid: More expensive, larger
- Mailgun: Complex, pricing model confusing
- Postmark: More expensive

---

### Payment: Stripe

**Why Stripe:**
- Industry standard
- Excellent documentation
- Great API
- Webhooks for real-time updates
- Supports multiple payment methods

**Use Cases:**
- Stylist session payments
- Subscription payments (future)
- Marketplace payments (future)

---

## Development Tools

### Version Control: Git

**Platform:** GitHub

**Why Git:**
- Industry standard
- Excellent branching and merging
- Great tooling
- Integrates with GitHub Actions

---

### Code Quality: ESLint + Prettier

**ESLint Version:** 8.56+
**Prettier Version:** 3.1+

**Why ESLint:**
- Lint JavaScript/TypeScript
- Catch errors early
- Enforce coding standards
- Great community rules

**Why Prettier:**
- Consistent code formatting
- No configuration needed
- Integrates with ESLint

---

### Type Checking: mypy (Python)

**Version:** 1.8+

**Why mypy:**
- Static type checking for Python
- Catch type errors before runtime
- Better IDE support

---

## Technology Summary Table

| Category | Technology | Version | Purpose |
|----------|-------------|----------|---------|
| **Backend Framework** | FastAPI | 0.104+ | API server |
| **Language** | Python | 3.12+ | Backend logic |
| **Database** | Supabase | PostgreSQL 15+ | Relational data |
| **Vector DB** | Pinecone | 3.0+ | Similarity search |
| **Schema Validation** | Pydantic | 2.5+ | Data validation |
| **AI Framework** | (Future) Pydantic AI | 0.0.12+ | Server-side AI orchestration |
| **AI Models** | Google Gemini | - | Image generation & extraction |
| **Frontend Framework** | React | 18.2+ | UI |
| **Language** | TypeScript | 5.3+ | Type safety |
| **Build Tool** | Vite | 5.0+ | Bundling |
| **UI Library** | shadcn/ui | Latest | Components |
| **CSS** | Tailwind CSS | 3.4+ | Styling |
| **State Management** | TanStack Query | 5.17+ | Server state |
| **State Management** | Zustand | 4.4+ | Client state |
| **Routing** | React Router | 6.21+ | Navigation |
| **Forms** | React Hook Form | 7.48+ | Form handling |
| **Validation** | Zod | 3.22+ | Schema validation |
| **Charts** | Recharts | 2.10+ | Data visualization |
| **Charts** | D3.js | 7.8+ | Custom visualizations |
| **Server-Side AI** | Backend AI API | Latest | AI extraction & generation |
| **Containerization** | Docker | 24.0+ | Containers |
| **Orchestration** | Docker Compose | 2.20+ | Multi-container |
| **CI/CD** | GitHub Actions | - | Automated deployments |
| **Deployment** | Railway | - | Cloud hosting |
| **Logging** | Structured (JSON) | - | Log aggregation |
| **Weather API** | OpenWeatherMap | 3.0 | Weather data |
| **Email** | Resend | - | Transactional emails |
| **Payment** | Stripe | - | Payment processing |
| **Version Control** | Git | - | Code management |
| **Code Quality** | ESLint | 8.56+ | Linting |
| **Code Formatting** | Prettier | 3.1+ | Formatting |

---

## Justification Summary

### Backend Choices

1. **Python:** Best AI/ML ecosystem, easy to learn, great performance
2. **FastAPI:** Modern, fast, async support, great DX
3. **Supabase:** All-in-one solution (DB, Auth, Storage), great DX
4. **Pinecone:** Managed vector DB, excellent performance
5. **Backend AI API:** Server-side AI processing with multi-provider support

### Frontend Choices

1. **React:** Industry standard, great ecosystem
2. **TypeScript:** Type safety, better DX
3. **Vite:** Fast development, optimized builds
4. **shadcn/ui:** Beautiful, accessible, customizable
5. **Tailwind CSS:** Utility-first, small bundles
6. **TanStack Query + Zustand:** Best of both worlds for state management

### Infrastructure Choices

1. **Docker:** Consistent environments, easy deployment
2. **GitHub Actions:** Integrated with GitHub, free
3. **Railway:** Simple, scalable, affordable

### Future Considerations

**Phase 2 (6 months):**
- Add Redis for caching
- Add Celery for task queues
- Move to microservices if needed

**Phase 3 (12 months):**
- Consider Kubernetes for orchestration
- Add CDN (Cloudflare) for static assets
- Add monitoring (Datadog, New Relic)
