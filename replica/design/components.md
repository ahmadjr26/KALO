# Component Specifications: Cal AI Replica

Design system specifications for all UI primitives and composite widgets identified in the recon. Every component includes token mappings, responsive touch targets, states (default, active, focus, disabled, loading, error), and WCAG 2.2 accessibility rules.

---

### PrimaryButton
- **variants:** `primary` (accent emerald), `secondary` (surface with border), `ghost` (transparent), `danger` (destructive red)
- **sizes:** 
  - `sm`: height 36px, px 12px, font `sm/600`
  - `md`: height 48px, px 20px, font `base/600`
  - `lg`: height 56px, px 24px, font `md/700` (sticky onboarding and paywall CTA)
- **states:** `default`, `hover`, `active` (scale 0.98), `focus-visible` (2px ring accent with 2px offset), `disabled` (opacity 0.45, pointer-events none), `loading` (spinner with preserved accessible label)
- **tokens:** `bg-accent`, `text-accent-foreground` (`#000000` on `#10b981`), `radius-pill`, `font-sans`, `shadow-subtle`
- **a11y:** Native button role, minimum 48x48px touch target on mobile, `aria-busy="true"` when loading, screen-reader text retained during async operations.
- **used on:** S01, S02, S06, S11, S12, S14, S17, S21, S23, S25

---

### OptionCard
- **variants:** `single-select` (radio behavior), `multi-select` (checkbox behavior), `metric-card` (biometrics / workout frequency)
- **sizes:** 
  - `compact`: height 56px, px 16px, py 12px
  - `spacious`: min-height 72px, px 20px, py 16px (with subtitle and leading icon)
- **states:** `default` (`bg-surface border-border`), `hover` (`border-border-input`), `selected` (`bg-surface-elevated border-accent ring-1 ring-accent`), `disabled`
- **tokens:** `bg-surface`, `border-border`, `text`, `text-muted`, `radius-lg`, `shadow-subtle`
- **a11y:** `role="radio"` or `role="checkbox"`, `aria-checked="true/false"`, full keyboard navigation via arrow keys and spacebar activation.
- **used on:** S02, S03, S07, S08, S09

---

### ScrollWheelPicker
- **variants:** `numeric` (age, height, weight), `unit-selector` (metric/imperial, grams/florets/cups)
- **sizes:** viewport height 180px, row height 44px, 3 to 5 visible items with top/bottom fade gradient
- **states:** `idle`, `scrolling` (inertial physics), `snapped` (haptic tick on each item crossing center mark)
- **tokens:** center highlight `bg-surface-elevated radius-md`, active text `text-display font-bold text-accent`, inactive text `text-lg text-muted opacity-40`
- **a11y:** Keyboard steppers (`ArrowUp`, `ArrowDown`, `PageUp`, `PageDown`), `aria-valuemin`, `aria-valuemax`, `aria-valuenow`, `role="spinbutton"`.
- **used on:** S04, S05, S06, S18

---

### SegmentedToggle
- **variants:** `pill-toggle` (lbs/kg, ft/cm), `tab-toggle` (Day/Week/Month, Annual/Monthly)
- **sizes:** height 40px, padding 4px
- **states:** `default`, `active-tab` (animated sliding pill background), `hover`, `focus-visible`
- **tokens:** container `bg-surface border border-border radius-pill`, active thumb `bg-surface-elevated text radius-pill shadow-subtle`, inactive text `text-muted`
- **a11y:** `role="tablist"`, child `role="tab"`, `aria-selected="true/false"`, keyboard arrow navigation between segments.
- **used on:** S05, S14, S25, S27

---

### CalorieBudgetRing (The Hero Widget)
- **variants:** `hero-large` (dashboard center, diameter 220px, stroke 14px), `compact-widget` (diameter 100px, stroke 8px)
- **sizes:** responsive SVG viewBox with animated conic stroke
- **states:**
  - `empty`: background track visible (`stroke-border`), 0% fill
  - `normal-progress`: animated gradient fill (`stroke-accent`), remaining calories displayed in center
  - `budget-exceeded`: track fills red (`stroke-danger`), warning icon with negative calorie delta
- **tokens:** track `border`, progress `accent` (`#10b981`), over-budget `danger` (`#f87171`), inner text `text-display font-extrabold text`
- **a11y:** `role="progressbar"`, `aria-valuenow="{consumed}"`, `aria-valuemax="{budget}"`, `aria-valuetext="{remaining} calories remaining today"`.
- **used on:** S15, Home Widgets

---

### MacroProgressBar
- **variants:** `protein` (blue `#60a5fa`), `carbs` (orange `#fb923c`), `fat` (yellow `#facc15`)
- **sizes:** height 8px, track radius pill, accompanying value label `font-sm/600`
- **states:** `zero` (0%), `progress` (0–100%), `capped` (100% full with overflow badge)
- **tokens:** track `bg-border radius-pill`, fill `bg-macro-{name}`, label `text font-sm`, subtext `text-muted font-xs`
- **a11y:** `role="progressbar"`, `aria-label="{macro} progress"`, `aria-valuenow="{grams_consumed}"`, `aria-valuemax="{target_grams}"`.
- **used on:** S15, S17, S23, S27

---

### CameraReticle
- **variants:** `food-scanner` (corner brackets framing central 70% of viewport), `barcode-scanner` (wide horizontal rectangle), `label-ocr` (portrait rectangle)
- **sizes:** responsive camera viewport overlay with blurred exterior letterboxing
- **states:** `searching` (subtle pulse animation), `target-detected` (brackets glow `accent` green, haptic tap), `low-light` (flash prompt tooltip)
- **tokens:** corner lines `2px solid accent`, corner radius 12px, overlay `rgba(0, 0, 0, 0.4)`
- **a11y:** Live region announcing camera status ("Camera ready. Point at food plate to scan.")
- **used on:** S16, S19, S20

---

### ShutterButton
- **variants:** `photo-shutter` (nested double ring), `voice-record` (microphone with audio waveform), `press-hold-commit` (pledge contract with circular fill)
- **sizes:** diameter 72px (photo/voice), diameter 84px (commit pledge)
- **states:** `idle` (white core with translucent border), `pressed` (core scales down to 85%), `recording` (pulsing red dot), `filling` (progress ring sweeps 360 deg over 1.5s hold)
- **tokens:** outer ring `border-2 border-text`, inner core `bg-text` (photo) or `bg-danger` (voice) or `bg-accent` (pledge)
- **a11y:** Minimum 72x72px touch target, labeled with `aria-label="Capture meal photo"` or `aria-label="Hold to pledge commitment"`.
- **used on:** S12, S16, S21

---

### HealthRatingBadge
- **variants:** `score-pill` (numeric rating 1 to 10), `factor-row` (added sugar, processing degree, net carbs, sodium)
- **sizes:** badge height 28px, factor row height 48px
- **states:** `good` (emerald green badge), `moderate` (amber badge), `poor` (crimson red badge)
- **tokens:** badge `bg-surface-elevated text-sm font-bold border border-border`, factor rating `text-success` or `text-danger`
- **a11y:** Expandable bottom sheet with text explanations ("Minimal processing: whole natural ingredients").
- **used on:** S17, S23

---

### IngredientRow
- **variants:** `summary-view` (read-only for scanned items), `editable-view` (with quantity steppers and portion unit dropdown), `removable-view` (swipe-to-delete)
- **sizes:** min-height 56px, py 10px, px 16px
- **states:** `default`, `editing`, `swiping`, `removed` (smooth collapse animation)
- **tokens:** `bg-surface`, `border-b border-border`, title `text font-base/600`, portion `text-muted font-sm`, macro values `text-accent font-sm/600`
- **a11y:** Accessible action buttons ("Edit {item name}", "Remove {item name}"), screen-reader announcement on item deletion.
- **used on:** S17, S18, S23

---

### WaterQuickAddButton
- **variants:** `glass` (+250ml), `bottle` (+500ml), `jug` (+1000ml), `custom` (modal input)
- **sizes:** min-height 64px, flex column with icon and volume text
- **states:** `default` (`bg-surface`), `pressed` (haptic ripple with water wave fill), `target-reached` (confetti burst)
- **tokens:** `bg-surface border border-border radius-lg`, icon `text-blue-400`, text `text-sm font-semibold`
- **a11y:** `aria-label="Add 250 milliliters of water"`, announce updated daily fluid total.
- **used on:** S15, S24

---

### PaywallCard
- **variants:** `featured-annual` (prominent banner "3 Days Free, then $29.99/yr - Save 65%"), `standard-monthly` ($9.99/mo)
- **sizes:** min-height 96px, px 20px, py 16px
- **states:** `default` (`bg-surface border-border`), `selected` (`bg-surface-elevated border-accent ring-2 ring-accent shadow-glow-accent`)
- **tokens:** badge `bg-accent text-accent-foreground font-xs/700 radius-pill`, price `text-xl font-extrabold text`, trial subtext `text-muted font-sm`
- **a11y:** `role="radio"`, `aria-checked="true/false"`, clear legal disclosure of billing cycle and cancellation terms.
- **used on:** S14

---

### BottomNavigationBar
- **variants:** 4 tabs (Home, Analytics, Groups, Settings) + central elevated floating scan button
- **sizes:** bar height 64px + safe area inset bottom; floating button diameter 56px
- **states:** `active-tab` (icon and label `text-accent`), `inactive-tab` (`text-muted`), `floating-button-pressed` (scale 0.94)
- **tokens:** bar `bg-surface/90 backdrop-blur-md border-t border-border`, floating button `bg-accent text-accent-foreground shadow-glow-accent`
- **a11y:** `role="navigation"`, `aria-label="Main navigation"`, tab items with `aria-current="page"`.
- **used on:** S15, S27, S28, S29
