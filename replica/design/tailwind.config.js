/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ['class', '[data-theme="dark"]'],
  content: [
    './app/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
    './screens/**/*.{js,ts,jsx,tsx}',
    './replica/design/**/*.{js,ts,jsx,tsx,html}'
  ],
  theme: {
    extend: {
      colors: {
        bg: 'var(--color-bg)',
        surface: {
          DEFAULT: 'var(--color-surface)',
          elevated: 'var(--color-surface-elevated)'
        },
        border: {
          DEFAULT: 'var(--color-border)',
          input: 'var(--color-border-input)'
        },
        text: {
          DEFAULT: 'var(--color-text)',
          muted: 'var(--color-text-muted)'
        },
        accent: {
          DEFAULT: 'var(--color-accent)',
          foreground: 'var(--color-on-accent)'
        },
        danger: 'var(--color-danger)',
        warning: 'var(--color-warning)',
        success: 'var(--color-success)',
        macro: {
          protein: 'var(--color-macro-protein)',
          carbs: 'var(--color-macro-carbs)',
          fat: 'var(--color-macro-fat)',
          calories: 'var(--color-macro-calories)'
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['ui-monospace', 'SFMono-Regular', 'Menlo', 'monospace']
      },
      fontSize: {
        xs: ['0.75rem', { lineHeight: '1rem', fontWeight: '500' }],
        sm: ['0.875rem', { lineHeight: '1.25rem', fontWeight: '400' }],
        base: ['1rem', { lineHeight: '1.5rem', fontWeight: '400' }],
        md: ['1.125rem', { lineHeight: '1.625rem', fontWeight: '600' }],
        lg: ['1.25rem', { lineHeight: '1.75rem', fontWeight: '600' }],
        xl: ['1.5rem', { lineHeight: '2rem', fontWeight: '700' }],
        '2xl': ['1.875rem', { lineHeight: '2.25rem', fontWeight: '700' }],
        display: ['2.375rem', { lineHeight: '2.75rem', fontWeight: '800' }]
      },
      borderRadius: {
        xs: '4px',
        sm: '8px',
        md: '12px',
        lg: '16px',
        xl: '24px',
        pill: '9999px'
      },
      boxShadow: {
        subtle: 'var(--shadow-subtle)',
        card: 'var(--shadow-card)',
        floating: 'var(--shadow-floating)',
        'glow-accent': 'var(--shadow-glow-accent)',
        'glow-calories': 'var(--shadow-glow-calories)'
      },
      transitionTimingFunction: {
        spring: 'cubic-bezier(0.16, 1, 0.3, 1)',
        ease: 'cubic-bezier(0.2, 0.8, 0.2, 1)'
      },
      transitionDuration: {
        instant: '80ms',
        fast: '140ms',
        base: '220ms'
      }
    }
  },
  plugins: []
};
