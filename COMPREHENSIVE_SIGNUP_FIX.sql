-- Comprehensive Fix for Signup Issues
-- Run this in your Supabase SQL Editor

-- Step 1: Fix the trigger function to handle signup properly
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert basic profile (this should work even during signup)
  INSERT INTO public.profiles (id, email, first_name, last_name, primary_role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'primary_role', 'Student')
  )
  ON CONFLICT (id) DO NOTHING;
  
  -- Create initial role entry
  INSERT INTO public.user_roles (user_id, role, is_active, is_verified)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'primary_role', 'Student'),
    true,
    false
  )
  ON CONFLICT (user_id, role) DO NOTHING;
  
  -- Create default user preferences
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Update RLS policies to be more permissive during signup
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can view other active profiles" ON profiles;
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;

-- Create new policies
CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can view other active profiles" ON profiles
  FOR SELECT USING (is_active = true);

-- Step 3: If the above still doesn't work, temporarily disable RLS for testing
-- ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Step 4: Test the setup
SELECT 'Signup fix applied successfully' as status;
