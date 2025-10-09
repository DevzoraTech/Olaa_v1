-- Test Unified Signup Database Connectivity
-- Run this script to verify the database is ready for the unified signup

-- 1. Check if all required tables exist
SELECT 
  table_name,
  CASE 
    WHEN table_name = 'profiles' THEN '✅ Required'
    WHEN table_name = 'user_roles' THEN '✅ Required'
    WHEN table_name = 'user_preferences' THEN '✅ Required'
    ELSE 'ℹ️ Optional'
  END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('profiles', 'user_roles', 'user_preferences', 'user_follows', 'user_blocks', 'user_reports', 'user_sessions')
ORDER BY table_name;

-- 2. Check profiles table structure
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Check RLS policies on profiles table
SELECT 
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- 4. Check if trigger exists
SELECT 
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'users' 
  AND event_object_schema = 'auth';

-- 5. Test profile creation with sample data
-- This will only work if you have a test user in auth.users
-- Uncomment and replace the UUID with an actual user ID from auth.users

-- INSERT INTO profiles (
--   id,
--   email,
--   first_name,
--   last_name,
--   primary_role,
--   campus,
--   year_of_study,
--   course,
--   phone_number,
--   gender,
--   interests,
--   is_verified,
--   is_active,
--   timezone,
--   language,
--   notification_preferences,
--   privacy_settings,
--   created_at,
--   updated_at
-- ) VALUES (
--   'REPLACE_WITH_ACTUAL_USER_ID',
--   'test-unified@example.com',
--   'Test',
--   'User',
--   'Student',
--   'Makerere University',
--   'Year 2',
--   'Computer Science',
--   '+256700000000',
--   'Male',
--   ARRAY['Technology', 'Sports'],
--   false,
--   true,
--   'UTC',
--   'en',
--   '{}',
--   '{}',
--   NOW(),
--   NOW()
-- );

-- 6. Check storage bucket exists
-- Note: This requires Supabase admin access
-- SELECT name, public FROM storage.buckets WHERE name = 'profile-images';

-- 7. Test query to verify data can be read
SELECT 
  COUNT(*) as total_profiles,
  COUNT(CASE WHEN primary_role = 'Student' THEN 1 END) as students,
  COUNT(CASE WHEN primary_role = 'Hostel Provider' THEN 1 END) as hostel_providers,
  COUNT(CASE WHEN primary_role = 'Event Organizer' THEN 1 END) as event_organizers,
  COUNT(CASE WHEN primary_role = 'Promoter' THEN 1 END) as promoters
FROM profiles;

-- 8. Check for any recent profile creations
SELECT 
  email,
  first_name,
  last_name,
  primary_role,
  campus,
  created_at
FROM profiles 
ORDER BY created_at DESC 
LIMIT 5;
