 # Implementation: UI Components
 
 ## Overview
 
 High-level guide to UI components and business logic modules.
 
 ## 1. Layout Components
 
 ### AppLayout.tsx
 - Top navigation bar
 - Responsive sidebar (collapsible on mobile)
 - Main content area with breadcrumbs
 - Toast notification container
 
 ### AuthLayout.tsx
 - Centered card for login/register
 - Product logo and tagline
 - Background illustration/image
 
 ## 2. Core Feature Components
 
 ### WardrobeGrid.tsx
 - Displays items in a responsive grid
 - Virtualized for performance
 - Multi-select mode
 
 ### ItemCard.tsx
 - Image preview
 - Status badges (clean, dirty, favorite)
 - Quick actions (edit, delete, wear)
 
 ### OutfitCanvas.tsx
 - Visual representation of selected items
 - Layering controls
 - Background selection
 
 ### GenerationPreview.tsx
 - Loading state with AI tips
 - Comparison slider for variations
 - Download and share buttons
 
 ## 3. Shared/Common Components
 
 ### ImageWithFallback.tsx
 - Skeleton loader while image is loading
 - Default placeholder on error
 
 ### LoadingSpinner.tsx
 - Branded spinner for full-page or section loading
 
 ### ConfirmationModal.tsx
 - Standardized dialog for destructive actions
 
 ## Business Logic Modules
 
 ### 1. AI Orchestration Service (Backend)
 - Manages agent handoffs
 - Handles retries for transient AI failures
 - Image post-processing (cropping, resizing)
 
 ### 2. Recommendation Engine (Backend)
 - Vector similarity calculations
 - Preference weighting logic
 - Occasion-based filtering
 
 ### 3. Sync Service (Frontend)
 - Synchronizes local storage with Supabase
 - Handles offline conflict resolution
