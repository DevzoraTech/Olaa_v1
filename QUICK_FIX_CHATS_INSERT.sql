-- Quick fix: Add missing INSERT policy for chats table
-- This should resolve the "new row violates row-level security policy for table 'chats'" error

-- First, check if the policy already exists and drop it if it does
DROP POLICY IF EXISTS "Users can create chats" ON chats;

-- Create the INSERT policy for chats table
CREATE POLICY "Users can create chats" ON chats
  FOR INSERT WITH CHECK (true);

-- Verify the policy was created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'chats' AND policyname = 'Users can create chats';
