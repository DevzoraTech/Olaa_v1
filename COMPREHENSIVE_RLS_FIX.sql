-- COMPREHENSIVE RLS POLICY FIX
-- Run this in your Supabase SQL Editor to fix all RLS issues

-- 1. First, let's see what RLS policies currently exist
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- 2. Drop existing problematic policies
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- 3. Create proper RLS policies for profiles table
-- Allow users to view their own profile
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Allow users to insert their own profile (for signup)
CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Allow users to delete their own profile
CREATE POLICY "Users can delete own profile" ON profiles
    FOR DELETE USING (auth.uid() = id);

-- 4. Check storage policies
SELECT * FROM storage.buckets WHERE name = 'profile-images';

-- 5. Create storage policies for profile images
-- Allow authenticated users to upload to profile-images bucket
CREATE POLICY "Authenticated users can upload profile images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'profile-images' 
        AND auth.role() = 'authenticated'
    );

-- Allow authenticated users to view profile images
CREATE POLICY "Authenticated users can view profile images" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'profile-images' 
        AND auth.role() = 'authenticated'
    );

-- Allow users to update their own profile images
CREATE POLICY "Users can update own profile images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'profile-images' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Allow users to delete their own profile images
CREATE POLICY "Users can delete own profile images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'profile-images' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- 6. Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'profiles';

SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- 7. Test if the profile-images bucket exists and is accessible
SELECT name, public FROM storage.buckets WHERE name = 'profile-images';

-- If bucket doesn't exist, create it
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', false)
ON CONFLICT (id) DO NOTHING;

SELECT 'RLS policies have been fixed!' as status;
