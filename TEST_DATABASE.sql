-- Test Database Schema - Run this to verify everything is working
-- Run this in your Supabase SQL Editor

-- Test 1: Check if profiles table exists and has correct structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- Test 2: Check if trigger function exists
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';

-- Test 3: Check if trigger exists
SELECT trigger_name, event_manipulation, action_timing 
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Test 4: Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'profiles';

-- Test 5: Check storage bucket exists
SELECT name, public 
FROM storage.buckets 
WHERE name = 'profile-images';

-- If all tests pass, your database is ready!
