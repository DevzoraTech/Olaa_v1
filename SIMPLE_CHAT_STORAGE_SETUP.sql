-- Simple Chat Files Storage Bucket Setup
-- Run this if the main script has issues

-- Create the chat-files storage bucket (simple version)
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-files', 'chat-files', true)
ON CONFLICT (id) DO NOTHING;

-- Basic storage policies
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'chat-files' AND auth.role() = 'authenticated'
);

CREATE POLICY "Allow authenticated downloads" ON storage.objects  
FOR SELECT USING (
  bucket_id = 'chat-files' AND auth.role() = 'authenticated'
);

-- Grant permissions
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;
