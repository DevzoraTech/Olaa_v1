-- PERMANENT RLS FIX - After testing with disabled RLS
-- Run this AFTER confirming updates work with disabled RLS

-- 1. Re-enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 2. Drop any existing policies
DROP POLICY IF EXISTS "Users can manage own profile" ON profiles;
DROP POLICY IF EXISTS "Allow all authenticated users" ON profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- 3. Create a very permissive policy for testing
CREATE POLICY "Allow authenticated users to manage profiles" ON profiles
    FOR ALL USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- 4. Verify the policy was created
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'profiles';

SELECT 'RLS re-enabled with permissive policy!' as status;
