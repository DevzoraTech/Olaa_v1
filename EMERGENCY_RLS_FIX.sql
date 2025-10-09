-- EMERGENCY RLS FIX - Disable RLS temporarily to test
-- Run this in your Supabase SQL Editor

-- 1. Check current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'profiles';

-- 2. Temporarily disable RLS to test if that's the issue
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- 3. Test if updates work now (run this after disabling RLS)
-- UPDATE profiles SET business_name = 'TEST UPDATE' WHERE email = 'devzoratech@gmail.com';

-- 4. Check if the update worked
-- SELECT business_name FROM profiles WHERE email = 'devzoratech@gmail.com';

-- 5. If updates work, re-enable RLS with proper policies
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 6. Create a simple policy that definitely works
-- CREATE POLICY "Allow all authenticated users" ON profiles
--     FOR ALL USING (auth.role() = 'authenticated')
--     WITH CHECK (auth.role() = 'authenticated');

SELECT 'RLS temporarily disabled - test your app now!' as status;
