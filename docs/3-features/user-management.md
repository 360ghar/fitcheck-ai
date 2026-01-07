 # Feature Implementation: User Management
 
 ## Overview
 
 User Management covers profile editing, settings, preferences, and account maintenance.
 
 ## UI Components
 
 ### 1. ProfileView.tsx
 
 **Purpose:** Display user profile information and activity summary.
 
 **Features:**
 - Avatar display with edit option
 - Full name and email display
 - Wardrobe statistics summary (items, outfits)
 - Recent activity feed
 - Edit profile button
 
 ---
 
 ### 2. EditProfileForm.tsx
 
 **Purpose:** Allow users to update their profile information.
 
 **Features:**
 - Full name input
 - Avatar upload/change
 - Email update (requires verification)
 - Form validation with Zod
 - Success/error notifications
 
 ---
 
 ### 3. SettingsView.tsx
 
 **Purpose:** Manage application settings and account preferences.
 
 **Features:**
 - Theme toggle (Light/Dark)
 - Notification preferences (Email, Push)
 - Measurement units (Metric/Imperial)
 - Language selection
 - Privacy settings (Profile visibility)
 
 ---
 
 ### 4. PreferencesForm.tsx
 
 **Purpose:** Manage fashion preferences for better AI recommendations.
 
 **Features:**
 - Favorite colors selection (multi-select)
 - Preferred styles (Casual, Formal, etc.)
 - Liked/disliked brands
 - Body type profile link
 
 ---
 
 ## State Management (Zustand)
 
 ### userStore.ts
 
 ```typescript
 import { create } from 'zustand';
 import { supabase } from '@/lib/supabase';
 
 interface UserState {
   profile: any | null;
   settings: any | null;
   preferences: any | null;
   loading: boolean;
   fetchProfile: () => Promise<void>;
   updateProfile: (data: any) => Promise<void>;
   updateSettings: (data: any) => Promise<void>;
 }
 
 export const useUserStore = create<UserState>((set) => ({
   profile: null,
   settings: null,
   preferences: null,
   loading: false,
 
   fetchProfile: async () => {
     set({ loading: true });
     const { data: { user } } = await supabase.auth.getUser();
     if (user) {
       const { data: profile } = await supabase
         .from('users')
         .select('*')
         .eq('id', user.id)
         .single();
       set({ profile, loading: false });
     }
   },
 
   updateProfile: async (data) => {
     const { data: { user } } = await supabase.auth.getUser();
     if (user) {
       await supabase
         .from('users')
         .update(data)
         .eq('id', user.id);
       set((state) => ({ profile: { ...state.profile, ...data } }));
     }
   },
   
   updateSettings: async (data) => {
     // Similar implementation for settings
   }
 }));
 ```
 
 ---
 
 ## Workflows
 
 ### 1. Update Profile Photo
 1. User selects new photo
 2. Frontend compresses image with Putter.js
 3. Upload to Supabase Storage bucket `avatars`
 4. Get public URL
 5. Update `avatar_url` in `users` table
 6. Update local state
 
 ### 2. Delete Account
 1. User clicks "Delete Account"
 2. Display confirmation modal with warning
 3. User confirms with password
 4. Call `supabase.rpc('delete_user_data')` to clean up all data
 5. Call `supabase.auth.admin.deleteUser()` (via edge function)
 6. Sign out and redirect to home
 
 ---
 
 ## Security Considerations
 
 - Row-Level Security (RLS) ensures users only edit their own profile
 - Validate avatar file type and size on upload
 - Use signed URLs for private profile data if needed
 - Require password confirmation for sensitive changes
 
 ---
 
 ## Edge Cases & Error Handling
 
 - **Avatar Upload Failure:** Show error toast, allow retry
 - **Email Already Taken:** Show validation error on form
 - **Database Sync Issue:** Show "Changes could not be saved" warning
 - **Missing Profile Data:** Handle null states in UI with skeletons or placeholders
