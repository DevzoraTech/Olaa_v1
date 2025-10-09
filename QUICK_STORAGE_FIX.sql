-- Quick Fix: Make Profile Images Bucket Public
-- Run this in your Supabase SQL Editor

-- First, check if the bucket exists
SELECT name, public FROM storage.buckets WHERE name = 'profile-images';

-- If the bucket doesn't exist, create it
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Make the profile-images bucket public (simplest solution)
UPDATE storage.buckets 
SET public = true 
WHERE name = 'profile-images';

-- Verify the bucket is now public
SELECT name, public FROM storage.buckets WHERE name = 'profile-images';

SELECT 'Profile images bucket is now public' as status;
