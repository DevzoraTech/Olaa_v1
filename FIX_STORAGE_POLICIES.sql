-- Fix Storage Bucket RLS Policies for Signup
-- Run this in your Supabase SQL Editor

-- First, let's check if the bucket exists and its current policies
SELECT name, public FROM storage.buckets WHERE name = 'profile-images';

-- Check current storage policies
SELECT * FROM storage.policies WHERE bucket_id = 'profile-images';

-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can upload their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile images" ON storage.objects;

-- Create more permissive policies for signup process
-- Allow authenticated users to upload profile images
CREATE POLICY "Authenticated users can upload profile images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-images' 
    AND auth.role() = 'authenticated'
  );

-- Allow public access to view profile images
CREATE POLICY "Public can view profile images" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-images');

-- Allow authenticated users to update their own profile images
CREATE POLICY "Authenticated users can update profile images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profile-images' 
    AND auth.role() = 'authenticated'
  );

-- Allow authenticated users to delete their own profile images
CREATE POLICY "Authenticated users can delete profile images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profile-images' 
    AND auth.role() = 'authenticated'
  );

-- Alternative: If the above doesn't work, temporarily make the bucket public
-- UPDATE storage.buckets SET public = true WHERE name = 'profile-images';

-- Test the policies
SELECT 'Storage policies updated successfully' as status;
