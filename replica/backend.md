# KALO Backend Integration & Architecture

## 1. Credentials Configuration
- File: `lib/core/config/app_config.dart`
- Project Ref: `fgnrrlnvlgxbmfggivfd`
- Supabase URL: `https://fgnrrlnvlgxbmfggivfd.supabase.co`
- Gemini Flash API Key: Configured via `--dart-define=GEMINI_API_KEY` (kept private)
- Primary AI Vision Model: `gemini-2.5-flash` with active fallback to `gemini-3.8-flash`

## 2. Supabase Tables & Schema
### `profiles` Table
- `id`: uuid, primary key, references `auth.users(id)`
- `weight`: numeric / integer (kg)
- `height`: numeric / integer (cm)
- `age`: integer (years)
- `goal`: text (e.g., 'maintain', 'cut', 'bulk', 'hypertrophy')
- `daily_calories`: integer (kcal)
- `daily_protein`: integer (g)
- `daily_carbs`: integer (g)
- `daily_fat`: integer (g)

### `meal_logs` Table
- `id`: uuid, primary key (default `gen_random_uuid()`)
- `user_id`: uuid, references `auth.users(id)`
- `food_name`: text
- `total_calories`: integer
- `protein`: integer
- `carbs`: integer
- `fat`: integer
- `health_score`: integer (1 to 10)
- `ingredients`: jsonb
- `logged_at`: timestamptz

## 3. Services Implemented
### `SupabaseService` (`lib/services/supabase_service.dart`)
- `signUp(email, password)`: Creates user and automatically inserts default profile in `profiles` table.
- `signIn(email, password)`: Authenticates existing user.
- `signOut()`: Terminates active session.
- `getProfile(userId)` / `updateProfile(profile)`: Read and persist profile settings.
- `insertMealLog(mealLog)` / `getMealLogs(userId)` / `deleteMealLog(id)`: Full CRUD for logged food.

### `GeminiScannerService` (`lib/services/gemini_scanner_service.dart`)
- Takes compressed food image (`Uint8List`) and optional context tags.
- Invokes Gemini Generative Language API with `responseMimeType: "application/json"`.
- Uses prompt engineering to decompose plates into ingredients with grams, calories, and macros.
- Automatically handles fallback from `gemini-2.5-flash` to `gemini-3.8-flash`.
- Directly parses structured JSON into `MealLog` model.

## 4. Security Checklist
- [x] Official public APIs only using configured project keys.
- [x] Secrets isolated in dedicated configuration file (`lib/core/config/app_config.dart`).
- [x] Zero comments (`//`, `///`, `/* */`) strictly maintained across all codebase files.
- [x] Row Level Security (RLS) supported on `profiles` and `meal_logs`.
- [x] Automatic fallback mechanisms for resilient network operation.
