# Recon map: Cal AI – Food Calorie Tracker (Android & iOS)

Scope: Full vertical slice of AI-first calorie tracking: Personalized metabolic onboarding, hard paywall & subscription funnel, multimodal food logging (camera AI vision, barcode scanning, nutrition label OCR, voice and text description, manual database), real-time portion/ingredient adjustment with health ratings, daily macro & calorie deficit dashboard, hydration tracking, weight tracking, fasting tracker, and community groups.
For: Founders and engineering teams rebuilding Cal AI as a high-converting, cross-platform mobile nutrition application.
Date: 2026-10-18

## Sources

| # | source | URL | notes |
| --- | --- | --- | --- |
| 1 | Google Play Store Listing | `https://play.google.com/store/apps/details?id=com.viraldevelopment.calai` | Full metadata, target SDK 36, Android permissions, feature highlights, and user reviews |
| 2 | Official Website & Product Portal | `https://calai.app` | Core value proposition, marketing positioning, feature breakdowns, and pricing architecture |
| 3 | Shipped Android Package (XAPK) | `C:\Users\ahmad\Downloads\cal-ai-food-calorie-tracker.xapk` | App manifest, raw JSON scan cache schemas (`/v6/scanImage/preview`), and reference UI assets |
| 4 | Apple App Store Listing | `https://apps.apple.com/us/app/cal-ai-calorie-tracker/id6472652285` | Screenshots, iOS nutrition tracking flows, subscription options, and feature tiers |
| 5 | Growth & Funnel Deconstructions | `https://onbo-hub.com` / `https://realgoodflows.com` | Micro-survey onboarding quiz mechanics, psychological sunk cost patterns, and exit-intent paywalls |
| 6 | Founder & Industry Interviews | TechCrunch / Forbes / Stork coverage on Zach Yadegari & Blake Anderson | Monetization economics, UGC acquisition funnels, and multimodal vision API integration |

## Core loop

Snap a photo of any meal to instantly estimate calories, macros, and portion sizes with AI, adjust ingredients with one tap, and track progress against a personalized daily caloric budget.

## Screens

| ID | screen | route / how to reach | purpose | key components | states seen |
| --- | --- | --- | --- | --- | --- |
| S01 | Splash & Value Proposition | App launch (`/onboarding/welcome`) | Hook user immediately with camera demonstration and frictionless value promise | Dynamic hero animation, camera reticle illustration, social proof badge, primary CTA button ("Get Started") | default, loading |
| S02 | Goal Selector | Tap "Get Started" (`/onboarding/goal`) | Establish primary motivation to customize caloric targets | 4 option cards (Lose Weight, Build Muscle, Maintain Weight, Eat Healthier) with icons, Next CTA | default, selected |
| S03 | Friction & Barrier Survey | S02 selection (`/onboarding/barrier`) | Solicit emotional pain points with traditional manual calorie counting apps | Multi-select checkable list (Manual search takes too long, Forgotten logs, Complicated interfaces, Inaccurate estimates), Continue button | default, multi-selected |
| S04 | Biometric Profile - Gender & Age | S03 selection (`/onboarding/gender-age`) | Capture foundational metabolic calculation factors | Gender selector pills (Male, Female, Other), horizontal/vertical age wheel picker | default, filled, error (age < 13) |
| S05 | Biometric Profile - Height & Weight | S04 completion (`/onboarding/height-weight`) | Baseline stats for BMI and Basal Metabolic Rate (BMR) calculations | Imperial/Metric segmented toggle (lbs/kg, ft-in/cm), dual scroll-wheel pickers, BMI indicator helper | default, active scrolling, toggled units |
| S06 | Target Weight & Desired Pace | S05 completion (`/onboarding/target-weight`) | Define target outcome and calculate required daily calorie deficit | Target weight wheel, pace selector with animal speed metaphors (Sloth: slow & steady, Rabbit: balanced, Panther: aggressive deficit), projected milestone date | default, selected, out-of-range warning |
| S07 | Activity Level & Workouts | S06 completion (`/onboarding/activity`) | Determine Total Daily Energy Expenditure (TDEE) multiplier | 4 activity level cards (Sedentary, Lightly Active, Moderately Active, Athlete) with weekly workout counts (0-2, 3-5, 6+), Continue button | default, selected |
| S08 | Dietary Style & Restrictions | S07 completion (`/onboarding/diet`) | Tailor macro ratios (e.g. higher protein or lower carb) | Selectable diet chips (Classic Balanced, High Protein, Keto, Vegetarian, Vegan, Pescatarian, Intermittent Fasting) | default, multi-selected |
| S09 | Calorie Budget Logic Toggles | S08 completion (`/onboarding/budget-rules`) | Configure exercise calories and rollover behavior | Interactive switches ("Eat back burned workout calories?", "Rollover unused calories to weekends?"), explanation tooltips | default, toggled |
| S10 | Health Platform Sync Prompt | S09 completion (`/onboarding/health-sync`) | Connect Apple Health / Google Health Connect for step & burn sync | System integration card, permission explanation graphic, "Connect Health" CTA and "Skip for now" link | default, permission prompt, denied, connected |
| S11 | Social Proof & Projection Chart | S10 completion (`/onboarding/projection`) | Build conviction and perceived value before payment | Interactive target weight timeline graph, user transformation stats, press logos (Forbes, TechCrunch, NYT) | default, animated |
| S12 | Commitment Pledge Contract | S11 completion (`/onboarding/pledge`) | Psychological sunk cost lock-in via physical micro-interaction | Personal commitment agreement text, tactile "Press & Hold to Commit" button with progress ring filling | default, pressing, completed |
| S13 | AI Plan Calculation Loading | S12 completion (`/onboarding/calculating`) | Create anticipation while computing personalized calorie/macro targets | Circular progress animation with cycling step status ("Analyzing metabolism...", "Formulating macro ratios...", "Finalizing your plan...") | loading, completed transition |
| S14 | Hard Paywall & Plan Selection | S13 completion (`/paywall`) | Primary monetization gate; locks AI features behind subscription | Annual plan anchor card ($29.99/yr with 3-day free trial), monthly alternative card, feature checklist, "Start 3-Day Free Trial" button, terms/privacy links | default, annual selected, monthly selected, processing, exit-intent modal (spin-wheel discount) |
| S15 | Main Home Dashboard | Bottom Tab 1 (`/dashboard`) | Daily command center showing calorie budget, macros, and meal logs | Calorie ring widget (Remaining = Budget - Food + Burn), Macro horizontal progress bars (Protein, Carbs, Fat), 4 meal section cards (Breakfast, Lunch, Dinner, Snacks) with (+) buttons, floating camera trigger, water card, fasting card, streak counter | empty (morning), partially logged, budget exceeded, offline |
| S16 | Camera Scanner Viewfinder | Tap Floating Action Button or (+) on S15 (`/scanner`) | Real-time camera viewfinder to capture meal photos | Full-screen live camera feed, alignment frame reticle, flash toggle, gallery image picker button, capture shutter button, mode carousel (Food, Barcode, Label, Voice) | camera active, scanning animation, low light warning, permission denied |
| S17 | AI Scan Result & Breakdown | Photo capture on S16 (`/scanner/result`) | Present instant AI recognition of foods, calories, macros, and health scores | Photo preview banner, detected dish title, total calories & macro badges, overall Health Rating card (added sugar, processing score, net carbs, sodium), itemized ingredients list with grams/servings, "Log Meal" button, "Retake" button | analyzing, success, partial confidence, network error |
| S18 | Ingredient & Portion Edit Modal | Tap any ingredient on S17 (`/scanner/edit-item`) | Fine-tune recognized items or tweak gram weights and serving units | Item name input, numeric quantity field, serving unit selector dropdown (florets, grams, ounces, cups, slices), real-time macro recalculation, "Update" button, "Remove" button | default, editing, deleted |
| S19 | Barcode Scanner View | Select Barcode mode on S16 (`/scanner/barcode`) | Scan UPC/EAN barcodes on packaged foods | Live viewfinder with rectangular barcode overlay, flash button, auto-detect haptic feedback, recent scans shortcut | scanning, product found, barcode unrecognized |
| S20 | Nutrition Facts Label OCR Scanner | Select Label mode on S16 (`/scanner/label`) | Scan nutrition facts panels on packaging | Reticle optimized for nutrition fact boxes, OCR bounding boxes, auto-extracted macro preview sheet | scanning, text recognized, parsing error |
| S21 | Voice & Text Natural Language Log | Select Voice mode on S16 (`/scanner/voice`) | Allow natural voice dictation or typed freeform meal descriptions | Audio waveform visualizer, record/stop button, speech-to-text transcript field, manual text box, AI parsing loader | listening, transcribing, parsing, failure |
| S22 | Manual Food Search & Database | Tap (+) -> Manual on S15 (`/food/search`) | Search food items from global nutrition database or create custom food | Search bar with instant autocomplete, Recent foods tab, Frequent meals tab, Custom food creator button, serving size calculator | empty query, search results, no results, loading |
| S23 | Logged Meal Detail View | Tap logged meal item on S15 (`/meal/:id`) | Inspect, edit, re-categorize, or delete an existing logged meal | Meal photo (if captured), timestamp, category dropdown (Breakfast/Lunch/Dinner/Snack), ingredients list, total macros, "Edit Meal" button, "Delete Meal" destructive action | default, editing, confirming delete |
| S24 | Hydration Tracker Screen | Tap Water widget on S15 (`/water`) | Monitor daily fluid intake against hydration target | Large water volume progress circle/cylinder, preset quick-log buttons (+250ml glass, +500ml bottle, +1000ml jug), custom entry input, intake history timeline | empty, goal reached, exceeded |
| S25 | Weight & Body Progress Screen | Tap Weight card on S15 (`/progress/weight`) | Track scale weight, milestone progress, and visual body photos | Interactive weight trend line chart against target goal line, "Log Weight" bottom sheet modal, progress photo gallery with side-by-side compare slider | empty (no logs), logged, new milestone |
| S26 | Intermittent Fasting Tracker | Tap Fasting card on S15 (`/fasting`) | Manage intermittent fasting windows and stages | Fasting countdown ring, protocol selector (16:8, 18:6, 20:4, OMAD), current metabolic stage indicator (Digestion, Fat Burning, Ketosis, Autophagy), "Start Fast" / "End Fast" button | fasting active, eating window open, target reached |
| S27 | Analytics & Nutrition Trends | Bottom Tab 2 (`/analytics`) | Weekly and monthly nutritional performance and deficit consistency | Calorie deficit bar chart by day, macro split donut chart, daily streak calendar, average deficit metric, "Export Nutrition Summary (PDF/Email)" button | loading, current week, historical weeks |
| S28 | Community & Challenge Groups | Bottom Tab 3 (`/groups`) | Social motivation via group challenges and leaderboards | Joined groups list, "Create Group" button, "Join with Code" button, group leaderboard ranked by streak and calorie adherence, group activity feed | empty state (no groups), active challenge, completed |
| S29 | Settings & Preferences | Bottom Tab 4 (`/settings`) | Account settings, goal recalculation, units, and subscription control | Profile section (name, email), Goals & Nutrition editor (recalculate BMR/macros), Metric/Imperial toggle, Health Connect sync toggle, Meal notification reminders, Subscription status & Restore purchases, Support link | default, updating goals, restoring purchase |

## Flows

```
F01 First-Time User Onboarding to Paywall Conversion
    S01 Splash -> S02 Goal -> S03 Barriers -> S04 Gender & Age -> S05 Height & Weight -> S06 Target Weight & Pace -> S07 Activity -> S08 Diet -> S09 Calculation Rules -> S10 Health Sync -> S11 Projection -> S12 Commitment Pledge -> S13 Calculating -> S14 Paywall
    happy path clicks: 14
    edge: User dismisses S14 paywall -> triggers Exit-Intent Discount Wheel modal offering 80% discount before closing; user denies health permission on S10 -> graceful skip.

F02 AI Photo Food Scan & Log [Core Loop]
    S15 Dashboard -> S16 Camera Viewfinder -> (Tap Shutter) -> S17 AI Scan Result -> (Tap Log Meal) -> S15 Dashboard (Ring and macros animate update)
    happy path clicks: 3
    edge: Meal has multiple unidentified components -> user taps ingredient to open S18 Edit Modal, adjusts gram weight, taps Update; low lighting -> prompt to turn on flash; camera permission denied -> fallback to gallery upload or manual search.

F03 Voice / Natural Language Food Logging
    S15 Dashboard -> S16 Camera Viewfinder -> (Select Voice Mode) -> S21 Voice Modal -> (Tap Record, speak meal description, tap Stop) -> S17 AI Breakdown Sheet -> (Tap Log Meal) -> S15 Dashboard
    happy path clicks: 4
    edge: Background noise ruins transcription -> editable text box allows manual correction; unrecognized dish defaults to custom entry.

F04 Packaged Food Barcode Scanning
    S15 Dashboard -> S16 Camera Viewfinder -> (Select Barcode Mode) -> S19 Barcode Reticle -> (Auto-detects code) -> S17 Product Nutrition Sheet -> (Tap Log Meal) -> S15 Dashboard
    happy path clicks: 3
    edge: Barcode not found in OpenFoodFacts database -> prompts user to snap a photo of the Nutrition Facts label (routes to S20) or manually input details.

F05 Nutrition Facts Label OCR Scan
    S15 Dashboard -> S16 Camera Viewfinder -> (Select Label Mode) -> S20 Label Reticle -> (Captures & OCR parses table) -> S17 Macro Sheet -> (Tap Log Meal) -> S15 Dashboard
    happy path clicks: 3
    edge: Poor angle/blurry numbers -> highlighted bounding boxes prompt user to confirm or overwrite parsed calories and carbs.

F06 Manual Food Database Search & Log
    S15 Dashboard -> (Tap (+) on Lunch) -> S22 Search Screen -> (Type query "Grilled Salmon") -> (Select result) -> (Adjust servings) -> (Tap Add to Lunch) -> S15 Dashboard
    happy path clicks: 5
    edge: Item not in database -> tap "Create Custom Food" to save custom name and macros for future reuse.

F07 Daily Hydration Quick-Log
    S15 Dashboard -> (Tap (+) on Water Card or tap Water Card to open S24) -> (Tap +250ml glass preset) -> S15 Dashboard (water progress bar fills)
    happy path clicks: 2
    edge: User consumed a non-standard bottle -> enter custom ml/oz in custom numeric field.

F08 Weight Logging & Progress Review
    S15 Dashboard -> (Tap Weight Card) -> S25 Progress Screen -> (Tap Log Weight) -> (Input scale weight, optional photo attachment) -> (Tap Save) -> S25 Chart updates
    happy path clicks: 4
    edge: User logs milestone weight -> celebratory confetti animation and updated projected timeline date.

F09 Intermittent Fasting Cycle
    S15 Dashboard -> (Tap Fasting Card) -> S26 Fasting Screen -> (Select 16:8 Protocol, tap Start Fast) -> S15 Dashboard (Live fasting timer widget appears)
    happy path clicks: 3
    edge: User breaks fast early -> confirmation dialog ("End fast early?") with logged duration.

F10 Exit-Intent Paywall Discount Recovery
    S14 Hard Paywall -> (Tap Close / Back) -> S14 Exit-Intent Discount Roulette Wheel Modal -> (Tap "Spin to Win") -> (Lands on 80% Off / $19.99 Lifetime) -> (Tap "Claim Discount") -> Native App Store Checkout -> S15 Dashboard
    happy path clicks: 3
    edge: User still dismisses wheel -> routes to dashboard with AI photo features locked behind soft upsell banners.
```

## Components

| component | variants | states | used on |
| --- | --- | --- | --- |
| PrimaryButton | Large, Medium, Small, StickyBottom | default, hover, pressed, disabled, loading | S01, S02, S06, S11, S12, S14, S17, S21 |
| SegmentedToggle | Imperial/Metric, Monthly/Annual, Day/Week/Month | default, active tab 1, active tab 2 | S05, S14, S25, S27 |
| ScrollWheelPicker | NumberPicker, UnitPicker, DatePicker | idle, scrolling, inertial snap | S04, S05, S06, S18 |
| OptionCard | SingleSelect, MultiSelect, RadioBadge | default, selected, disabled | S02, S03, S07, S08, S14 |
| CalorieBudgetRing | DashboardHero, WidgetCompact, FastingTimer | empty (0%), partial, 100% target, over-budget (red) | S15, S26, Widgets |
| MacroProgressBar | Protein (Blue), Carbs (Orange), Fat (Yellow) | 0% to 100%, over-target cap | S15, S17, S23, S27 |
| CameraReticle | FoodBracket, BarcodeRectangle, NutritionLabelBox | searching (pulsing), locked (green), error | S16, S19, S20 |
| ShutterButton | PhotoCapture, VoiceRecord, PressHoldCommit | idle, pressed, recording (pulsing red), filling ring | S12, S16, S21 |
| HealthRatingBadge | Good (Green), Moderate (Yellow), Poor (Red) | default, expanded details modal | S17, S23 |
| IngredientRow | Summary, Editable, Removable | default, editing quantity, swipe-to-delete | S17, S18, S23 |
| WaterQuickAddButton | +250ml Glass, +500ml Bottle, +1000ml Jug | default, pressed, completed | S15, S24 |
| TrendLineChart | WeightTrend, CalorieHistory, DeficitBarChart | loading, active plot, scrub/touch inspection tooltip | S11, S25, S27 |
| BottomNavigationBar | 4 Tabs (Home, Analytics, Groups, Settings) | active tab, inactive tab | S15, S27, S28, S29 |
| PaywallCard | BestValue (Annual), Standard (Monthly), DiscountSpecial | default, selected, highlighted badge | S14 |

## Inferred data model

```
User
  id: uuid (pk)
  email: string
  created_at: timestamp
  gender: enum (male, female, other)
  birth_year: integer
  height_cm: float
  current_weight_kg: float
  target_weight_kg: float
  target_date: date
  activity_level: enum (sedentary, lightly_active, moderately_active, athlete)
  dietary_preference: enum (balanced, high_protein, keto, vegetarian, vegan, etc.)
  calorie_budget: integer (computed from BMR/TDEE deficit)
  protein_target_g: integer
  carbs_target_g: integer
  fat_target_g: integer
  water_target_ml: integer
  unit_system: enum (metric, imperial)
  is_subscribed: boolean
  subscription_tier: enum (free, annual_trial, monthly_unlimited, lifetime)
  current_streak_days: integer
  last_logged_at: timestamp
  evidence: S04-S09 onboarding inputs, S14 subscription, S15 dashboard targets
  confidence: high

Meal
  id: uuid (pk)
  user_id: uuid (fk -> User.id)
  logged_at: timestamp
  meal_type: enum (breakfast, lunch, dinner, snack)
  photo_url: string (nullable)
  source_type: enum (ai_photo, barcode, voice, text, manual)
  dish_name: string
  total_calories: float
  total_protein_g: float
  total_carbs_g: float
  total_fat_g: float
  total_fiber_g: float
  total_sugar_g: float
  total_sodium_mg: float
  health_score: integer (1-10)
  notes: text (nullable)
  evidence: res/raw/scan_preview_cache_*.json API schema, S17 scan results
  confidence: high

MealIngredient
  id: uuid (pk)
  meal_id: uuid (fk -> Meal.id)
  name: string
  mass_grams: float
  display_quantity: float
  display_unit: string (e.g. "floret", "slice", "cup", "oz", "g")
  calories: float
  protein_g: float
  carbs_g: float
  fat_g: float
  fiber_g: float
  sugar_g: float
  sodium_mg: float
  serving_type_id: string
  confidence_score: float (0.0 - 1.0)
  evidence: res/raw/scan_preview_cache_1.json exact ingredients array structure
  confidence: high

FoodDatabaseItem
  id: uuid (pk)
  barcode: string (nullable, indexed)
  name: string
  brand: string (nullable)
  serving_unit: string
  serving_amount: float
  calories_per_serving: float
  protein_g: float
  carbs_g: float
  fat_g: float
  fiber_g: float
  sugar_g: float
  sodium_mg: float
  is_verified: boolean
  evidence: S19 barcode scanner, S22 manual food database search
  confidence: high

WaterLog
  id: uuid (pk)
  user_id: uuid (fk -> User.id)
  logged_at: timestamp
  amount_ml: integer
  evidence: S24 hydration tracker, S15 water card
  confidence: high

WeightLog
  id: uuid (pk)
  user_id: uuid (fk -> User.id)
  logged_at: timestamp
  weight_kg: float
  photo_url: string (nullable)
  notes: text (nullable)
  evidence: S25 weight tracking chart, ic_progress_photos drawable
  confidence: high

FastingSession
  id: uuid (pk)
  user_id: uuid (fk -> User.id)
  protocol: enum (16_8, 18_6, 20_4, omad, custom)
  start_time: timestamp
  planned_end_time: timestamp
  actual_end_time: timestamp (nullable)
  status: enum (in_progress, completed, cancelled)
  evidence: S26 fasting screen, image_fasting_intro_* drawables
  confidence: medium

Group
  id: uuid (pk)
  name: string
  description: text
  icon_name: string
  creator_id: uuid (fk -> User.id)
  invite_code: string (unique)
  created_at: timestamp
  evidence: S28 groups tab, bottom_nav_groups drawable, group_logo_* drawables
  confidence: medium

GroupMember
  id: uuid (pk)
  group_id: uuid (fk -> Group.id)
  user_id: uuid (fk -> User.id)
  joined_at: timestamp
  current_streak: integer
  evidence: S28 challenge leaderboards
  confidence: medium

Subscription
  id: uuid (pk)
  user_id: uuid (fk -> User.id)
  store_original_transaction_id: string
  store_platform: enum (apple_app_store, google_play)
  product_id: string (annual_sub_trial, monthly_sub)
  status: enum (active, in_trial, grace_period, expired)
  starts_at: timestamp
  expires_at: timestamp
  auto_renew: boolean
  evidence: S14 paywall, Google Play billing permissions in manifest
  confidence: high
```

Relationships:
- `User` 1-n `Meal` (Cascade delete)
- `Meal` 1-n `MealIngredient` (Cascade delete)
- `User` 1-n `WaterLog`
- `User` 1-n `WeightLog`
- `User` 1-n `FastingSession`
- `User` n-m `Group` (via `GroupMember`)
- `User` 1-n `Subscription`

## Feature matrix

See `replica/features.csv`.
- Must: 11
- Should: 10
- Could: 7
- Skip: 2

## Out of scope (cannot or should not be cloned)

- Proprietary in-house edge computer vision training: Cal AI relies on cloud multimodal vision models (e.g. Gemini Vision API / GPT-4o Vision) backed by food volume heuristic estimation. Do not attempt to build a custom edge CNN from scratch; use multimodal LLMs with structured JSON schema output matching `res/raw/scan_preview_cache_*.json`.
- Private proprietary nutritional clinical food datasets: Use USDA FoodData Central and OpenFoodFacts API for barcode scanning and manual search databases.
- Automated medical/clinical diagnosis: Cal AI is a wellness estimation utility, not an FDA-regulated medical device. Include explicit disclaimers regarding dietary advice.

## Size

Screens: 29, Flows: 10, Entities: 10.
Hard parts:
1. Multimodal AI photo decomposition: Prompt engineering multimodal vision LLMs to return strict JSON matching ingredients, estimated volume/grams, macro distributions, and health rating scores.
2. Low-latency camera capture & compression pipeline: Compressing images on-device to <500KB JPEG before transmission to maintain sub-2-second scan turnaround times.
3. High-converting micro-survey onboarding & hard paywall funnel: Implementing smooth single-decision question cards, tactile commitment animations, and RevenueCat subscription synchronization with exit-intent discount wheels.

Size: **M** (3 to 4 weeks for a full-stack, production-ready cross-platform MVP on Flutter or React Native).
