# Chat Files Storage Setup Guide

## 🚨 IMPORTANT: Storage Bucket Setup Required

The chat file sharing feature requires a Supabase Storage bucket to be created. Follow these steps to set it up:

## 📋 Step-by-Step Setup

### 1. **Access Supabase Dashboard**
- Go to your Supabase project dashboard
- Navigate to **Storage** in the left sidebar

### 2. **Create Storage Bucket**
You have two options:

#### Option A: Use SQL Script (Recommended)
1. Go to **SQL Editor** in your Supabase dashboard
2. Copy and paste the contents of `SETUP_CHAT_STORAGE_BUCKET.sql`
3. Click **Run** to execute the script

#### Option B: Manual Creation
1. In **Storage**, click **New bucket**
2. Set bucket name: `chat-files`
3. Make it **Public** (so files can be accessed via URL)
4. Set file size limit: `50MB`
5. Add allowed MIME types (see list below)

### 3. **Verify Setup**
After running the script, verify the bucket was created:
```sql
SELECT id, name, public, file_size_limit FROM storage.buckets WHERE id = 'chat-files';
```

## 📁 Allowed File Types

The bucket supports these MIME types:
- **Images**: `image/jpeg`, `image/png`, `image/gif`, `image/webp`
- **Videos**: `video/mp4`, `video/avi`, `video/mov`, `video/quicktime`
- **Audio**: `audio/mpeg`, `audio/wav`, `audio/aac`
- **Documents**: `application/pdf`, `application/msword`, `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- **Spreadsheets**: `application/vnd.ms-excel`, `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
- **Presentations**: `application/vnd.ms-powerpoint`, `application/vnd.openxmlformats-officedocument.presentationml.presentation`
- **Archives**: `application/zip`, `application/x-rar-compressed`
- **Other**: `application/octet-stream`

## 🔒 Security Policies

The script creates these RLS policies:
- ✅ **Upload**: Authenticated users can upload files
- ✅ **Download**: Authenticated users can view/download files
- ✅ **Update**: Users can update their own files
- ✅ **Delete**: Users can delete their own files

## 📂 File Structure

Files are stored with this structure:
```
chat-files/
├── {chatId}/
│   ├── {timestamp}_{userId}_{filename}
│   └── {timestamp}_{userId}_{filename}
└── {chatId}/
    └── {timestamp}_{userId}_{filename}
```

## 🛠️ Troubleshooting

### Error: "Bucket not found"
1. Make sure you ran the SQL script
2. Check if the bucket exists in Storage dashboard
3. Verify the bucket name is exactly `chat-files`

### Error: "Permission denied"
1. Check RLS policies are created
2. Verify user is authenticated
3. Check file path follows the expected structure

### Error: "File too large"
1. Check file size limit (50MB)
2. Verify MIME type is allowed
3. Check file size in debug logs

## 🧪 Testing

After setup, test file upload:
1. Try sending an image in chat
2. Check console for upload success messages
3. Verify file appears in Storage dashboard
4. Test file download by tapping the file

## 📱 App Behavior

Once set up, the app will:
- ✅ Upload files to Supabase Storage
- ✅ Store download URLs in database
- ✅ Display file previews in chat
- ✅ Allow one-tap downloads
- ✅ Handle different file types appropriately

## 🔄 Alternative Setup

If the main script fails, use `SIMPLE_CHAT_STORAGE_SETUP.sql` for basic setup, then manually configure policies in the dashboard.

