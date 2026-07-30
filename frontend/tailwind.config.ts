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
        ink: '#000000',
        body: '#33332e',
        charcoal: '#211922',
        mute: '#62625b',
        ash: '#91918c',
        stone: { ...colors.stone, DEFAULT: '#c8c8c1' },
        hairline: '#dadad3',
        'hairline-soft': '#ecece7',
        'surface-soft': '#fbfbf9',
        'surface-card': '#f6f6f3',
        'surface-elevated': 'hsl(var(--surface-elevated))',
        'surface-dark': '#262622',
        'on-dark': '#fbfbf9',
        'focus-outer': '#435ee5',
        'focus-inner': '#000000',
        'accent-purple': '#7e238b',
        success: { deep: '#103c25', pale: '#c7f0da' },
        error: { DEFAULT: '#9e0a0a', pale: '#f9e5e5' },
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
        'gradient-primary': 'linear-gradient(135deg, #e60023, #cc001f)',
        'gradient-accent': 'linear-gradient(135deg, #e60023, #cc001f)',
        'gradient-cool': 'linear-gradient(135deg, #f6f6f3, #ffffff)',
        'gradient-warm': 'linear-gradient(135deg, #f6f6f3, #ffffff)',
        'gradient-success': 'linear-gradient(135deg, #c7f0da, #103c25)',
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
