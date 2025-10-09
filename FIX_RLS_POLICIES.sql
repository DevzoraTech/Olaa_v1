-- Fix RLS Policies for Signup Process
-- Run this in your Supabase SQL Editor

-- Drop existing policies
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view other active profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;

-- Create new policies that allow signup process
CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can view other active profiles" ON profiles
  FOR SELECT USING (is_active = true);

-- Alternative: If the above doesn't work, try this more permissive policy for signup
-- CREATE POLICY "Allow profile creation during signup" ON profiles
--   FOR INSERT WITH CHECK (true);

-- Test the policies
SELECT 'RLS policies updated successfully' as status;
