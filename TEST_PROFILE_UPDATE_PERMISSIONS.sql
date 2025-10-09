-- Test Profile Update Permissions
-- Run this in your Supabase SQL Editor to test if updates work

-- First, check if the profile exists
SELECT id, email, first_name, last_name, primary_role, business_name, primary_phone 
FROM profiles 
WHERE email = 'devzoratech@gmail.com';

-- Try to update a single field to test permissions
UPDATE profiles 
SET business_name = 'TEST UPDATE' 
WHERE email = 'devzoratech@gmail.com';

-- Check if the update worked
SELECT id, email, first_name, last_name, primary_role, business_name, primary_phone 
FROM profiles 
WHERE email = 'devzoratech@gmail.com';

-- Check RLS policies on profiles table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- If updates don't work, try this to temporarily disable RLS for testing
-- ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;
-- (Don't forget to re-enable it: ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;)
