 # Feature Implementation: Authentication
 
 ## Overview
 
 This document details the implementation of authentication features, including UI components, state management, and Supabase integration.
 
 ## UI Components
 
 ### 1. LoginForm.tsx
 
 **Purpose:** Collect user credentials and authenticate.
 
 **Features:**
 - Email and password input fields
 - Show/hide password toggle
 - "Remember me" checkbox
 - "Forgot password?" link
 - Social login buttons (Google, Apple)
 - Form validation with Zod
 - Loading state handling
 
 **Validation:**
 - Email: Valid format required
 - Password: Required, min 8 characters
 
 ---
 
 ### 2. RegisterForm.tsx
 
 **Purpose:** Collect user information for new account creation.
 
 **Features:**
 - Full name, email, password, and confirm password fields
 - Password strength indicator
 - Terms of service checkbox
 - Email verification info
 - Form validation with Zod
 - Loading state handling
 
 **Validation:**
 - Full Name: Required, min 2 characters
 - Email: Valid format, unique
 - Password: Strong password required
 - Confirm Password: Must match password
 
 ---
 
 ### 3. ForgotPasswordForm.tsx
 
 **Purpose:** Allow users to request a password reset email.
 
 **Features:**
 - Email input field
 - Success/error message display
 - Back to login link
 - Loading state handling
 
 ---
 
 ### 4. ResetPasswordForm.tsx
 
 **Purpose:** Allow users to set a new password after following a reset link.
 
 **Features:**
 - New password and confirm password fields
 - Password strength indicator
 - Success/error message display
 - Redirect to login on success
 - Loading state handling
 
 ---
 
 ## State Management (Zustand)
 
 ### authStore.ts
 
 ```typescript
 import { create } from 'zustand';
 import { supabase } from '@/lib/supabase';
 import { User } from '@/types/user';
 
 interface AuthState {
   user: User | null;
   session: any | null;
   loading: boolean;
   initialized: boolean;
   setUser: (user: User | null) => void;
   setSession: (session: any | null) => void;
   signOut: () => Promise<void>;
   initialize: () => Promise<void>;
 }
 
 export const useAuthStore = create<AuthState>((set) => ({
   user: null,
   session: null,
   loading: true,
   initialized: false,
 
   setUser: (user) => set({ user }),
   setSession: (session) => set({ session }),
 
   signOut: async () => {
     await supabase.auth.signOut();
     set({ user: null, session: null });
   },
 
   initialize: async () => {
     const { data: { session } } = await supabase.auth.getSession();
     set({ 
       session, 
       user: session?.user as any, 
       loading: false,
       initialized: true 
     });
 
     supabase.auth.onAuthStateChange((_event, session) => {
       set({ session, user: session?.user as any });
     });
   }
 }));
 ```
 
 ---
 
 ## Protected Routes
 
 ### AuthGuard.tsx
 
 ```typescript
 import { useEffect } from 'react';
 import { useNavigate } from 'react-router-dom';
 import { useAuthStore } from '@/stores/authStore';
 
 export const AuthGuard = ({ children }: { children: React.ReactNode }) => {
   const { session, loading, initialized } = useAuthStore();
   const navigate = useNavigate();
 
   useEffect(() => {
     if (initialized && !loading && !session) {
       navigate('/login');
     }
   }, [session, loading, initialized, navigate]);
 
   if (!initialized || loading) {
     return <LoadingSpinner />;
   }
 
   return session ? <>{children}</> : null;
 };
 ```
 
 ---
 
 ## Supabase Integration
 
 ### supabase.ts
 
 ```typescript
 import { createClient } from '@supabase/supabase-js';
 
 const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
 const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
 
 export const supabase = createClient(supabaseUrl, supabaseAnonKey);
 ```
 
 ---
 
 ## Workflows
 
 ### 1. Signup Flow
 1. User submits registration form
 2. Frontend validates inputs with Zod
 3. Call `supabase.auth.signUp()`
 4. If successful, Supabase sends verification email
 5. Display "Check your email" message
 6. User clicks link in email
 7. Redirect to `/auth/callback`
 8. Callback handler completes session and redirects to `/dashboard`
 
 ### 2. Login Flow
 1. User submits login form
 2. Frontend validates inputs with Zod
 3. Call `supabase.auth.signInWithPassword()`
 4. If successful, store session in state and localStorage
 5. Redirect to `/dashboard` or previous intended route
 
 ### 3. Password Reset Flow
 1. User submits "Forgot Password" form
 2. Call `supabase.auth.resetPasswordForEmail()`
 3. User receives email with link
 4. User clicks link, redirects to `/auth/reset-password`
 5. User submits "Reset Password" form
 6. Call `supabase.auth.updateUser({ password })`
 7. Redirect to login with success message
 
 ---
 
 ## Security Considerations
 
 - Use `httpOnly` cookies for sessions when possible (Supabase handles this)
 - Always validate inputs on both frontend and backend
 - Implement rate limiting on auth endpoints (Supabase handles this)
 - Use secure passwords (minimum length, complexity)
 - Sanitize user input to prevent XSS
 - Implement CORS policies to restrict origins
 - Use Row-Level Security (RLS) to isolate user data
 
 ---
 
 ## Edge Cases & Error Handling
 
 - **Invalid Credentials:** Show clear "Invalid email or password" message
 - **Email Already Exists:** Supabase returns 400 error, show "Email already in use"
 - **Unverified Email:** Redirect to "Verify your email" page
 - **Expired Session:** AuthGuard redirects to login automatically
 - **Network Issues:** Show "Connection error, please try again" toast
 - **Weak Password:** Real-time feedback in registration form
