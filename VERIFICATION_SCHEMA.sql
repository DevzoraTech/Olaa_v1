-- Verification System Database Schema
-- Run this in your Supabase SQL Editor

-- Create verification_documents table
CREATE TABLE IF NOT EXISTS verification_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL CHECK (document_type IN (
        'student_id', 'business_registration', 'landlord_agreement', 
        'organization_certificate', 'official_contact', 'live_photo'
    )),
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    mime_type TEXT NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_notes TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES auth.users(id)
);

-- Create verification_submissions table
CREATE TABLE IF NOT EXISTS verification_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    submission_type TEXT NOT NULL CHECK (submission_type IN (
        'student', 'hostel_provider', 'event_organizer', 'promoter'
    )),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected')),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES auth.users(id),
    admin_notes TEXT,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 days')
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_verification_documents_user_id ON verification_documents(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_documents_status ON verification_documents(status);
CREATE INDEX IF NOT EXISTS idx_verification_submissions_user_id ON verification_submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_verification_submissions_status ON verification_submissions(status);

-- Enable RLS
ALTER TABLE verification_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_submissions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for verification_documents
CREATE POLICY "Users can view own verification documents" ON verification_documents
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own verification documents" ON verification_documents
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own verification documents" ON verification_documents
    FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for verification_submissions
CREATE POLICY "Users can view own verification submissions" ON verification_submissions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own verification submissions" ON verification_submissions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own verification submissions" ON verification_submissions
    FOR UPDATE USING (auth.uid() = user_id);

-- Create storage bucket for verification documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('verification-documents', 'verification-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for verification documents
CREATE POLICY "Users can upload own verification documents" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'verification-documents' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own verification documents" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'verification-documents' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

SELECT 'Verification system database schema created!' as status;
