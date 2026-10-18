-- ==============================================================================
-- CAL AI REPLICA: PostgreSQL Schema (Supabase)
-- High-Performance, Multi-Tenant Nutrition & AI Calorie Tracker
-- ==============================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Enum Definitions
create type user_gender as enum ('male', 'female', 'other');
create type activity_level as enum ('sedentary', 'lightly_active', 'moderately_active', 'athlete');
create type dietary_preference as enum ('balanced', 'high_protein', 'keto', 'vegetarian', 'vegan', 'pescatarian', 'intermittent_fasting');
create type meal_type as enum ('breakfast', 'lunch', 'dinner', 'snack');
create type meal_source as enum ('ai_photo', 'barcode', 'label_ocr', 'voice', 'text', 'manual');
create type fasting_protocol as enum ('16_8', '18_6', '20_4', 'omad', 'custom');
create type fasting_status as enum ('in_progress', 'completed', 'cancelled');
create type subscription_tier as enum ('free', 'annual_trial', 'monthly_unlimited', 'lifetime');

-- ==============================================================================
-- 1. PROFILES (Extends auth.users)
-- ==============================================================================
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  timezone text not null default 'UTC',
  gender user_gender,
  birth_year integer check (birth_year between 1900 and extract(year from current_date)),
  height_cm numeric(5,2) check (height_cm > 0),
  current_weight_kg numeric(5,2) check (current_weight_kg > 0),
  target_weight_kg numeric(5,2) check (target_weight_kg > 0),
  target_date date,
  activity_level activity_level not null default 'sedentary',
  dietary_preference dietary_preference not null default 'balanced',
  
  -- Computed Metabolic & Nutrient Targets
  calorie_budget integer not null default 2000 check (calorie_budget > 500),
  protein_target_g integer not null default 150 check (protein_target_g >= 0),
  carbs_target_g integer not null default 200 check (carbs_target_g >= 0),
  fat_target_g integer not null default 65 check (fat_target_g >= 0),
  water_target_ml integer not null default 2500 check (water_target_ml > 0),
  
  -- Preferences & Settings
  unit_system text not null default 'metric' check (unit_system in ('metric', 'imperial')),
  eat_back_workout_calories boolean not null default false,
  rollover_calories boolean not null default false,
  
  -- Streaks & Gamification
  current_streak_days integer not null default 0 check (current_streak_days >= 0),
  longest_streak_days integer not null default 0 check (longest_streak_days >= 0),
  last_logged_date date,
  
  -- Subscription & Entitlements
  is_subscribed boolean not null default false,
  subscription_tier subscription_tier not null default 'free',
  subscription_expires_at timestamptz,
  
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_profiles_subscribed on profiles (is_subscribed);
create index idx_profiles_last_logged on profiles (last_logged_date);

-- ==============================================================================
-- 2. MEALS
-- ==============================================================================
create table meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  logged_at timestamptz not null default now(),
  logged_date date not null default current_date,
  meal_type meal_type not null default 'breakfast',
  source_type meal_source not null default 'ai_photo',
  dish_name text not null,
  photo_url text,
  
  -- Aggregated Nutrition Breakdown
  total_calories numeric(7,2) not null default 0 check (total_calories >= 0),
  total_protein_g numeric(6,2) not null default 0 check (total_protein_g >= 0),
  total_carbs_g numeric(6,2) not null default 0 check (total_carbs_g >= 0),
  total_fat_g numeric(6,2) not null default 0 check (total_fat_g >= 0),
  total_fiber_g numeric(6,2) not null default 0 check (total_fiber_g >= 0),
  total_sugar_g numeric(6,2) not null default 0 check (total_sugar_g >= 0),
  total_sodium_mg numeric(7,2) not null default 0 check (total_sodium_mg >= 0),
  
  -- Health Analysis Rating (1 to 10 score)
  health_score integer check (health_score between 1 and 10),
  health_factors jsonb not null default '{}'::jsonb,
  notes text,
  
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_meals_user_date on meals (user_id, logged_date);
create index idx_meals_user_logged_at on meals (user_id, logged_at desc);

-- ==============================================================================
-- 3. MEAL INGREDIENTS (Itemized AI Breakdown & Servings)
-- ==============================================================================
create table meal_ingredients (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references meals(id) on delete cascade,
  name text not null,
  mass_grams numeric(7,2) not null check (mass_grams >= 0),
  display_quantity numeric(6,2) not null default 1 check (display_quantity > 0),
  display_unit text not null default 'serving',
  
  -- Macros for this specific ingredient portion
  calories numeric(7,2) not null check (calories >= 0),
  protein_g numeric(6,2) not null default 0 check (protein_g >= 0),
  carbs_g numeric(6,2) not null default 0 check (carbs_g >= 0),
  fat_g numeric(6,2) not null default 0 check (fat_g >= 0),
  fiber_g numeric(6,2) not null default 0 check (fiber_g >= 0),
  sugar_g numeric(6,2) not null default 0 check (sugar_g >= 0),
  sodium_mg numeric(7,2) not null default 0 check (sodium_mg >= 0),
  
  serving_types jsonb not null default '[]'::jsonb,
  confidence_score numeric(4,3) check (confidence_score between 0 and 1),
  created_at timestamptz not null default now()
);

create index idx_meal_ingredients_meal on meal_ingredients (meal_id);

-- ==============================================================================
-- 4. FOOD DATABASE (Verified Products & Barcodes)
-- ==============================================================================
create table food_items (
  id uuid primary key default gen_random_uuid(),
  barcode text unique,
  name text not null,
  brand text,
  serving_unit text not null default 'g',
  serving_amount numeric(6,2) not null default 100 check (serving_amount > 0),
  
  -- Nutrition per serving
  calories_per_serving numeric(7,2) not null check (calories_per_serving >= 0),
  protein_g numeric(6,2) not null default 0 check (protein_g >= 0),
  carbs_g numeric(6,2) not null default 0 check (carbs_g >= 0),
  fat_g numeric(6,2) not null default 0 check (fat_g >= 0),
  fiber_g numeric(6,2) not null default 0 check (fiber_g >= 0),
  sugar_g numeric(6,2) not null default 0 check (sugar_g >= 0),
  sodium_mg numeric(7,2) not null default 0 check (sodium_mg >= 0),
  
  is_verified boolean not null default false,
  creator_user_id uuid references profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create index idx_food_items_barcode on food_items (barcode) where barcode is not null;
create index idx_food_items_name_trgm on food_items using gin (name gin_trgm_ops);

-- ==============================================================================
-- 5. WATER LOGS
-- ==============================================================================
create table water_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  logged_at timestamptz not null default now(),
  logged_date date not null default current_date,
  amount_ml integer not null check (amount_ml > 0),
  created_at timestamptz not null default now()
);

create index idx_water_logs_user_date on water_logs (user_id, logged_date);

-- ==============================================================================
-- 6. WEIGHT & BODY LOGS
-- ==============================================================================
create table weight_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  logged_at timestamptz not null default now(),
  logged_date date not null default current_date,
  weight_kg numeric(5,2) not null check (weight_kg > 0),
  photo_url text,
  notes text,
  created_at timestamptz not null default now()
);

create index idx_weight_logs_user_date on weight_logs (user_id, logged_date);

-- ==============================================================================
-- 7. FASTING SESSIONS
-- ==============================================================================
create table fasting_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  protocol fasting_protocol not null default '16_8',
  start_time timestamptz not null default now(),
  planned_end_time timestamptz not null,
  actual_end_time timestamptz,
  status fasting_status not null default 'in_progress',
  created_at timestamptz not null default now(),
  constraint valid_fasting_window check (planned_end_time > start_time)
);

create index idx_fasting_user_status on fasting_sessions (user_id, status);

-- ==============================================================================
-- 8. COMMUNITY CHALLENGE GROUPS
-- ==============================================================================
create table challenge_groups (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  icon_name text not null default 'group_logo_fire',
  creator_id uuid not null references profiles(id) on delete cascade,
  invite_code text not null unique default substr(md5(random()::text), 1, 8),
  is_private boolean not null default false,
  created_at timestamptz not null default now()
);

create index idx_challenge_groups_invite on challenge_groups (invite_code);

create table group_members (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references challenge_groups(id) on delete cascade,
  user_id uuid not null references profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  current_streak integer not null default 0 check (current_streak >= 0),
  unique (group_id, user_id)
);

create index idx_group_members_group on group_members (group_id);
create index idx_group_members_user on group_members (user_id);

-- ==============================================================================
-- 9. SUBSCRIPTIONS & ENTITLEMENTS (RevenueCat Webhook Destination)
-- ==============================================================================
create table subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  original_transaction_id text not null unique,
  platform text not null check (platform in ('ios', 'android', 'stripe')),
  product_id text not null,
  tier subscription_tier not null default 'annual_trial',
  status text not null check (status in ('active', 'trialing', 'past_due', 'canceled', 'expired')),
  starts_at timestamptz not null,
  expires_at timestamptz not null,
  auto_renew boolean not null default true,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index idx_subscriptions_user on subscriptions (user_id);
create index idx_subscriptions_status on subscriptions (user_id, status);

-- ==============================================================================
-- 10. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
alter table profiles enable row level security;
alter table meals enable row level security;
alter table meal_ingredients enable row level security;
alter table food_items enable row level security;
alter table water_logs enable row level security;
alter table weight_logs enable row level security;
alter table fasting_sessions enable row level security;
alter table challenge_groups enable row level security;
alter table group_members enable row level security;
alter table subscriptions enable row level security;

-- Profiles: Users can view and update their own profile
create policy "Users can view own profile" on profiles
  for select using (auth.uid() = id);
create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

-- Meals: Users can CRUD their own meals
create policy "Users can view own meals" on meals
  for select using (auth.uid() = user_id);
create policy "Users can insert own meals" on meals
  for insert with check (auth.uid() = user_id);
create policy "Users can update own meals" on meals
  for update using (auth.uid() = user_id);
create policy "Users can delete own meals" on meals
  for delete using (auth.uid() = user_id);

-- Meal Ingredients: Inherits access from meals
create policy "Users can view ingredients of own meals" on meal_ingredients
  for select using (exists (select 1 from meals where meals.id = meal_ingredients.meal_id and meals.user_id = auth.uid()));
create policy "Users can insert ingredients of own meals" on meal_ingredients
  for insert with check (exists (select 1 from meals where meals.id = meal_ingredients.meal_id and meals.user_id = auth.uid()));
create policy "Users can update ingredients of own meals" on meal_ingredients
  for update using (exists (select 1 from meals where meals.id = meal_ingredients.meal_id and meals.user_id = auth.uid()));
create policy "Users can delete ingredients of own meals" on meal_ingredients
  for delete using (exists (select 1 from meals where meals.id = meal_ingredients.meal_id and meals.user_id = auth.uid()));

-- Food Items: Readable by all authenticated users, writable if custom creator
create policy "Public food items are viewable by all" on food_items
  for select using (true);
create policy "Users can create custom food items" on food_items
  for insert with check (auth.uid() = creator_user_id);

-- Water Logs: Users can CRUD their own logs
create policy "Users can view own water logs" on water_logs
  for select using (auth.uid() = user_id);
create policy "Users can insert own water logs" on water_logs
  for insert with check (auth.uid() = user_id);
create policy "Users can delete own water logs" on water_logs
  for delete using (auth.uid() = user_id);

-- Weight Logs: Users can CRUD their own logs
create policy "Users can view own weight logs" on weight_logs
  for select using (auth.uid() = user_id);
create policy "Users can insert own weight logs" on weight_logs
  for insert with check (auth.uid() = user_id);
create policy "Users can delete own weight logs" on weight_logs
  for delete using (auth.uid() = user_id);

-- Fasting Sessions: Users can CRUD their own sessions
create policy "Users can view own fasting sessions" on fasting_sessions
  for select using (auth.uid() = user_id);
create policy "Users can manage own fasting sessions" on fasting_sessions
  for all using (auth.uid() = user_id);

-- Groups: Viewable by group members or public
create policy "View challenge groups" on challenge_groups
  for select using (not is_private or exists (select 1 from group_members where group_members.group_id = challenge_groups.id and group_members.user_id = auth.uid()));
create policy "Create challenge group" on challenge_groups
  for insert with check (auth.uid() = creator_id);

create policy "View group members" on group_members
  for select using (exists (select 1 from group_members gm where gm.group_id = group_members.group_id and gm.user_id = auth.uid()));
create policy "Join group" on group_members
  for insert with check (auth.uid() = user_id);
create policy "Leave group" on group_members
  for delete using (auth.uid() = user_id);

-- Subscriptions: Read-only for users (updated strictly via backend webhook service role)
create policy "Users can view own subscriptions" on subscriptions
  for select using (auth.uid() = user_id);
