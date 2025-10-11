-- Simple Storage Bucket Fix
-- Run this in your Supabase SQL Editor

-- Create the bucket if it doesn't exist and make it public
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Verify it worked
SELECT name, public FROM storage.buckets WHERE name = 'profile-images';









