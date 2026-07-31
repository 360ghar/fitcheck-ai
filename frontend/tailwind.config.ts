import type { Config } from 'tailwindcss'
import colors from 'tailwindcss/colors'

const config: Config = {
  darkMode: 'class',
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    boxShadow: {
      none: 'none',
      DEFAULT: 'none',
      sm: 'none',
      md: 'none',
      lg: 'none',
      xl: 'none',
      '2xl': 'none',
      inner: 'none',
    },
    borderRadius: {
      // DEFAULT is required for the bare `rounded` utility: without it the
      // class resolves to nothing and 15+ call sites silently lose radius.
      DEFAULT: '4px',
      none: '0px',
      sm: '8px',
      md: '16px',
      lg: '32px',
      // Compatibility aliases collapse legacy shapes into the documented large radius.
      xl: '32px',
      '2xl': '32px',
      '3xl': '32px',
      full: '9999px',
    },
    screens: {
      'xs': '375px',   // Small phones (iPhone SE)
      'sm': '640px',   // Large phones / small tablets
      'md': '768px',   // Tablets
      'lg': '1024px',  // Small laptops
      'xl': '1280px',  // Desktops
      '2xl': '1536px', // Large screens
      '3xl': '1920px', // Ultrawide masonry
    },
    extend: {
      spacing: {
        xxs: '4px',
        xs: '6px',
        sm: '8px',
        md: '12px',
        lg: '16px',
        xl: '24px',
        xxl: '32px',
        section: '64px',
        'touch': '44px',      // Minimum touch target (Apple HIG)
        'touch-lg': '48px',   // Comfortable touch target
        'safe-top': 'env(safe-area-inset-top)',
        'safe-bottom': 'env(safe-area-inset-bottom)',
        'safe-left': 'env(safe-area-inset-left)',
        'safe-right': 'env(safe-area-inset-right)',
      },
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
          pressed: 'hsl(var(--primary-pressed))',
        },
        // Wardrobe Studio semantic tokens. These MUST stay var-backed: a fixed
        // hex here has no `.dark` counterpart in the emitted CSS, which is how
        // dark mode broke (white search bars, white filter pills, white card
        // outlines, invisible black ghost-button labels). Values live in
        // src/index.css `:root` / `.dark`.
        ink: 'hsl(var(--foreground))',
        body: 'hsl(var(--body))',
        mute: 'hsl(var(--muted-foreground))',
        ash: 'hsl(var(--ash))',
        stone: { ...colors.stone, DEFAULT: '#c8c8c1' },
        hairline: 'hsl(var(--border))',
        'surface-soft': 'hsl(var(--surface-soft))',
        'surface-card': 'hsl(var(--card))',
        'surface-elevated': 'hsl(var(--surface-elevated))',
        'on-dark': 'hsl(var(--on-dark))',
        // Chrome over photography — same in both themes by design.
        'on-image': 'hsl(var(--on-image))',
        'on-image-foreground': 'hsl(var(--on-image-foreground))',
        // Calendar event-type index -- a quiet tonal family, not five accents.
        event: {
          work: 'hsl(var(--event-work))',
          social: 'hsl(var(--event-social))',
          casual: 'hsl(var(--event-casual))',
          formal: 'hsl(var(--event-formal))',
          other: 'hsl(var(--event-other))',
        },
        // Garment condition index -- same tonal family discipline.
        condition: {
          dirty: 'hsl(var(--condition-dirty))',
          laundry: 'hsl(var(--condition-laundry))',
          repair: 'hsl(var(--condition-repair))',
          donate: 'hsl(var(--condition-donate))',
          other: 'hsl(var(--condition-other))',
        },
        // Dead token: never referenced as a utility anywhere; the actual ring
        // color is the red `--ring` var (focus-visible ring on buttons/links).
        'focus-inner': 'hsl(var(--focus-inner))',
        'accent-purple': 'hsl(var(--accent-purple))',
        // `DEFAULT` was missing, so `bg-success`, `text-success` and
        // `bg-success/10` were never emitted and 11 call sites silently
        // rendered nothing. `deep` and `pale` are aliases of the same pair.
        success: {
          DEFAULT: 'hsl(var(--success))',
          deep: 'hsl(var(--success))',
          pale: 'hsl(var(--success-pale))',
        },
        error: { DEFAULT: 'hsl(var(--error))', pale: 'hsl(var(--error-pale))' },
        // Compatibility mappings migrate pre-existing utility usage to the
        // approved red/purple/warm-neutral system during the full route sweep.
        indigo: {
          50: '#fff1f2', 100: '#ffe4e6', 200: '#fecdd3', 300: '#fda4af',
          400: '#fb7185', 500: '#e60023', 600: '#cc001f', 700: '#9e0a0a',
          800: '#881337', 900: '#4c0519', 950: '#2a030e',
        },
        pink: {
          50: '#fff1f2', 100: '#ffe4e6', 200: '#fecdd3', 300: '#fda4af',
          400: '#fb7185', 500: '#e60023', 600: '#cc001f', 700: '#9e0a0a',
          800: '#881337', 900: '#4c0519', 950: '#2a030e',
        },
        violet: {
          50: '#f8eef9', 100: '#efd8f1', 200: '#dfb2e3', 300: '#ca80d0',
          400: '#a948ae', 500: '#7e238b', 600: '#681d73', 700: '#51165a',
          800: '#3b1042', 900: '#260a2c', 950: '#18051c',
        },
        purple: {
          50: '#f8eef9', 100: '#efd8f1', 200: '#dfb2e3', 300: '#ca80d0',
          400: '#a948ae', 500: '#7e238b', 600: '#681d73', 700: '#51165a',
          800: '#3b1042', 900: '#260a2c', 950: '#18051c',
        },
        gray: colors.stone,
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      fontFamily: {
        sans: [
          'Inter', 'ui-sans-serif', 'system-ui', '-apple-system', 'BlinkMacSystemFont', '"Segoe UI"', 'sans-serif',
        ],
        display: [
          'Manrope', 'Inter', 'ui-sans-serif', 'system-ui', 'sans-serif',
        ],
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        // Brand red is deliberately hex-locked (DESIGN.md 01) — it does not invert.
        'gradient-primary': 'linear-gradient(135deg, #e60023, #cc001f)',
        'gradient-accent': 'linear-gradient(135deg, #e60023, #cc001f)',
        // Neutral surface gradients follow the theme.
        'gradient-cool': 'linear-gradient(135deg, hsl(var(--card)), hsl(var(--background)))',
        'gradient-warm': 'linear-gradient(135deg, hsl(var(--card)), hsl(var(--background)))',
        'gradient-success': 'linear-gradient(135deg, hsl(var(--success-pale)), hsl(var(--success)))',
      },
      boxShadow: { glow: 'none', 'glow-sm': 'none', elevated: 'none', 'elevated-lg': 'none', 'card-hover': 'none' },
      animation: {
        'float': 'float 3s ease-in-out infinite',
        'fade-in': 'fadeIn 0.5s ease-out',
        'slide-up': 'slideUp 0.5s ease-out',
        'slide-down': 'slideDown 0.3s ease-out',
        'scale-in': 'scaleIn 0.2s ease-out',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'accordion-down': 'accordion-down 0.2s ease-out',
        'accordion-up': 'accordion-up 0.2s ease-out',
        'lift': 'lift 0.2s ease-out forwards',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' },
        },
        fadeIn: {
          from: { opacity: '0' },
          to: { opacity: '1' },
        },
        slideUp: {
          from: { opacity: '0', transform: 'translateY(20px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        'accordion-down': {
          from: { height: '0' },
          to: { height: 'var(--radix-collapsible-content-height)' },
        },
        'accordion-up': {
          from: { height: 'var(--radix-collapsible-content-height)' },
          to: { height: '0' },
        },
        slideDown: {
          from: { opacity: '0', transform: 'translateY(-10px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        scaleIn: {
          from: { opacity: '0', transform: 'scale(0.95)' },
          to: { opacity: '1', transform: 'scale(1)' },
        },
        lift: {
          to: { transform: 'translateY(-2px)', boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)' },
        },
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
}

export default config
