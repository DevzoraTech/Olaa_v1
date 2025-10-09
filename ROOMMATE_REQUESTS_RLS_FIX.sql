-- ROOMMATE REQUESTS RLS FIX
-- Fix RLS policies for roommate_requests table

-- 1. Drop existing policies
DROP POLICY IF EXISTS "Anyone can view active roommate requests" ON roommate_requests;
DROP POLICY IF EXISTS "Users can create their own roommate requests" ON roommate_requests;
DROP POLICY IF EXISTS "Users can update their own roommate requests" ON roommate_requests;
DROP POLICY IF EXISTS "Users can delete their own roommate requests" ON roommate_requests;

-- 2. Create more permissive policies for testing
CREATE POLICY "Allow authenticated users to view roommate requests" ON roommate_requests
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to create roommate requests" ON roommate_requests
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to update roommate requests" ON roommate_requests
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to delete roommate requests" ON roommate_requests
    FOR DELETE USING (auth.role() = 'authenticated');

-- 3. Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'roommate_requests';

SELECT 'Roommate requests RLS policies updated!' as status;
