# FitCheck AI - Frontend

React + TypeScript frontend for the FitCheck AI wardrobe management application.

## Tech Stack

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite 5** - Build tool & dev server
- **Tailwind CSS** - Styling
- **shadcn/ui** - Component library
- **Zustand** - Client state management
- **TanStack Query** - Server state & caching
- **React Hook Form + Zod** - Form handling & validation
- **React Router v6** - Routing
- **Axios** - HTTP client
- **Recharts + D3** - Data visualization

## Quick Start

### Prerequisites
- Node.js 18+
- Backend API running on port 8000

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

Opens at http://localhost:3000

### Production Build

```bash
npm run build
npm run preview  # Preview the build
```

### Linting

```bash
npm run lint
```

## Project Structure

```
src/
├── api/                    # API client modules
│   ├── client.ts          # Axios instance with auth
│   ├── auth.ts            # Authentication endpoints
│   ├── items.ts           # Wardrobe item CRUD
│   ├── outfits.ts         # Outfit management
│   ├── ai.ts              # AI generation endpoints
│   ├── recommendations.ts # AI recommendations
│   ├── calendar.ts        # Calendar integration
│   └── gamification.ts    # Streaks & achievements
├── components/
│   ├── ui/                # shadcn/ui components
│   ├── layout/            # App layout, sidebar, nav
│   ├── wardrobe/          # Wardrobe-specific components
│   ├── outfits/           # Outfit creation & display
│   ├── calendar/          # Calendar views
│   ├── social/            # Sharing & feedback
│   ├── gamification/      # Streaks, achievements
│   ├── settings/          # User settings panels
│   └── navigation/        # Bottom nav (mobile)
├── pages/
│   ├── auth/              # Login, register, password reset
│   ├── wardrobe/          # Wardrobe management
│   ├── outfits/           # Outfit browser
│   ├── try-on/            # Virtual try-on
│   ├── calendar/          # Outfit planning
│   ├── recommendations/   # AI suggestions
│   ├── gamification/      # Stats & achievements
│   └── settings/          # User profile & settings
├── stores/                # Zustand state stores
│   ├── authStore.ts       # Authentication state
│   ├── wardrobeStore.ts   # Wardrobe items & filters
│   └── outfitStore.ts     # Outfit creation state
├── lib/                   # Utilities
│   ├── color-utils.ts     # Color harmony algorithms
│   ├── outfit-generator.ts # Client-side outfit matching
│   └── utils.ts           # General utilities
├── types/
│   └── index.ts           # TypeScript type definitions
├── hooks/                 # Custom React hooks
├── index.css              # Global styles & Tailwind
├── App.tsx                # App component with routes
└── main.tsx               # Entry point
```

## Key Features

### Wardrobe Management
- **Multi-item extraction**: Upload outfit photos, AI extracts individual items
- **Smart filtering**: Filter by category, color, condition, favorites
- **Grid/list views**: Multiple display modes
- **Batch operations**: Multi-select for bulk actions

### AI Integration
- **Item extraction**: `src/api/ai.ts` - extractItems, extractSingleItem
- **Image generation**: generateProductImage, generateOutfit
- **Virtual try-on**: generateTryOn with user avatar
- **Settings**: Configure AI provider (Gemini/OpenAI/Custom)

### State Management
- **Zustand stores** for client state (auth, wardrobe, outfits)
- **TanStack Query** for server state with caching
- **Form state** via React Hook Form

## Mobile Support

The app is fully responsive with:
- Bottom navigation on mobile (`src/components/navigation/BottomNav.tsx`)
- Touch-optimized targets (44px minimum)
- Safe area support for notched devices
- Horizontal scroll with snap for categories

## API Integration

All API calls go through `src/api/client.ts`:
- Automatic token refresh on 401
- Request/response interceptors
- Error handling with `getApiError()`

Base URL: Configured via `VITE_API_URL` environment variable (defaults to `/api/v1`)

## Environment Variables

Create `.env.local` for local overrides:

```env
VITE_API_URL=http://localhost:8000/api/v1
VITE_SUPABASE_URL=your-supabase-url
VITE_SUPABASE_ANON_KEY=your-anon-key
```

## Component Patterns

### UI Components (shadcn/ui)
Located in `src/components/ui/`:
- Button, Dialog, Input, Select
- Toast notifications
- Avatar, Progress, Tabs
- All customizable via Tailwind

### Feature Components
Follow the pattern:
```tsx
// src/components/wardrobe/ItemCard.tsx
export function ItemCard({ item, onSelect, onEdit }: ItemCardProps) {
  // Component logic
}
```

### Pages
Each page is a route component:
```tsx
// src/pages/wardrobe/WardrobePage.tsx
export default function WardrobePage() {
  // Page with data fetching, state, UI
}
```

## Development Tips

1. **Hot reload**: Vite provides fast HMR
2. **Type checking**: Run `npm run build` to catch type errors
3. **Component dev**: Use browser devtools React extension
4. **API debugging**: Check Network tab, backend logs

## Testing

No automated tests configured yet. Validate via:
- `npm run build` - Type checking
- Manual QA in browser
- Backend integration testing

## Deployment

Build outputs to `dist/`:

```bash
npm run build
```

Deploy the `dist/` folder to any static hosting (Vercel, Netlify, Railway).
