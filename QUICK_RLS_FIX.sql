-- QUICK RLS FIX - Run this first
-- This fixes the most critical RLS issues

-- 1. Drop existing policies that might be blocking updates
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- 2. Create simple, working policies
CREATE POLICY "Users can manage own profile" ON profiles
    FOR ALL USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- 3. Ensure profile-images bucket exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', false)
ON CONFLICT (id) DO NOTHING;

-- 4. Create simple storage policy
CREATE POLICY "Authenticated users can manage profile images" ON storage.objects
    FOR ALL USING (
        bucket_id = 'profile-images' 
        AND auth.role() = 'authenticated'
    );

-- 5. Verify
SELECT 'Quick RLS fix applied!' as status;







