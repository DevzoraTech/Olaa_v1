-- Setup Chat Files Storage Bucket
-- This script creates the storage bucket and policies for chat file uploads

-- Create the chat-files storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'chat-files',
  'chat-files',
  true, -- Public bucket so files can be accessed via URL
  52428800, -- 50MB file size limit
  ARRAY[
    'image/jpeg',
    'image/png', 
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/avi',
    'video/mov',
    'video/quicktime',
    'audio/mpeg',
    'audio/wav',
    'audio/aac',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/zip',
    'application/x-rar-compressed',
    'application/octet-stream'
  ]
)
ON CONFLICT (id) DO NOTHING;

-- Create storage policies for the chat-files bucket

-- Policy: Allow authenticated users to upload files
CREATE POLICY "Users can upload chat files" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'chat-files' 
  AND auth.role() = 'authenticated'
);

-- Policy: Allow authenticated users to view/download files
CREATE POLICY "Users can view chat files" ON storage.objects
FOR SELECT USING (
  bucket_id = 'chat-files' 
  AND auth.role() = 'authenticated'
);

-- Policy: Allow users to update their own files (for potential file updates)
CREATE POLICY "Users can update their own chat files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'chat-files' 
  AND auth.role() = 'authenticated'
  AND auth.uid()::text = (storage.foldername(name))[2] -- Check if user ID matches folder name
);

-- Policy: Allow users to delete their own files
CREATE POLICY "Users can delete their own chat files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'chat-files' 
  AND auth.role() = 'authenticated'
  AND auth.uid()::text = (storage.foldername(name))[2] -- Check if user ID matches folder name
);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;

-- Create a function to help with file path validation
CREATE OR REPLACE FUNCTION validate_chat_file_path(file_path TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if the file path follows the pattern: chat-files/{chatId}/{timestamp}_{userId}_{filename}
  RETURN file_path ~ '^chat-files/[a-f0-9-]+/\d+_[a-f0-9-]+_.+$';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add a more restrictive policy for file uploads that validates the path structure
DROP POLICY IF EXISTS "Users can upload chat files" ON storage.objects;

CREATE POLICY "Users can upload chat files with valid path" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'chat-files' 
  AND auth.role() = 'authenticated'
  AND validate_chat_file_path(name)
  AND auth.uid()::text = (storage.foldername(name))[2] -- Ensure user ID matches the path
);

-- Create an index for better performance on file queries
CREATE INDEX IF NOT EXISTS idx_storage_objects_chat_files 
ON storage.objects (bucket_id, name) 
WHERE bucket_id = 'chat-files';

-- Test the bucket creation
SELECT 
  id, 
  name, 
  public, 
  file_size_limit,
  created_at
FROM storage.buckets 
WHERE id = 'chat-files';
