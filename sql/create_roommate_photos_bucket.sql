-- Create storage bucket for roommate request photos
-- Run this in your Supabase SQL editor

-- Create the storage bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('roommate-photos', 'roommate-photos', true);

-- Set up RLS policies for the bucket
CREATE POLICY "Allow authenticated users to upload photos" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'roommate-photos' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Allow public access to view photos" ON storage.objects
FOR SELECT USING (bucket_id = 'roommate-photos');

CREATE POLICY "Allow users to delete their own photos" ON storage.objects
FOR DELETE USING (
  bucket_id = 'roommate-photos' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
