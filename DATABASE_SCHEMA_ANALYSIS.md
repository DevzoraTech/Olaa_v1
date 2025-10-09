# PulseCampus Database Schema - Complete Analysis

## 🗄️ **Database Schema Overview**

This document provides a comprehensive analysis of the PulseCampus database schema, ensuring all required fields and relationships are properly covered before migration.

## 📊 **Core Tables & Relationships**

### **1. Profiles Table (Main User Table)**
**Purpose**: Central user profile table extending Supabase auth.users

**Key Fields**:
- **Basic Info**: `id`, `email`, `first_name`, `last_name`, `primary_role`
- **Student Fields**: `campus`, `year_of_study`, `course`, `gender`, `interests[]`
- **Hostel Provider Fields**: `business_name`, `primary_phone`, `secondary_phone`, `location_name`, `address`
- **Event Organizer Fields**: `organization_name`, `organization_type`, `organization_description`, `organization_website`
- **Promoter Fields**: `agency_name`, `agency_type`, `agency_description`, `agency_website`
- **Common Fields**: `bio`, `profile_image_url`, `phone_number`, `is_verified`, `is_active`, `last_seen`, `timezone`, `language`, `notification_preferences`, `privacy_settings`

**Relationships**:
- **One-to-Many**: `roommate_requests`, `hostel_listings`, `events`, `marketplace_items`, `notifications`, `chats` (as creator), `messages` (as sender), `user_roles`
- **Many-to-Many**: `user_follows` (follower/following), `user_blocks` (blocker/blocked)
- **One-to-One**: `user_preferences`, `user_sessions`

### **2. User Roles Table (Multi-Role Support)**
**Purpose**: Enable users to have multiple roles simultaneously

**Key Fields**:
- **Role Info**: `user_id`, `role`, `is_active`, `is_verified`
- **Verification**: `verification_document_url`, `verification_notes`, `verified_at`
- **Timestamps**: `added_at`

**Relationships**:
- **Many-to-One**: `user_id` → `profiles(id)`
- **Unique Constraint**: `(user_id, role)` - prevents duplicate roles per user

### **3. User Management Tables**

#### **user_follows**
- **Purpose**: Track user following relationships
- **Fields**: `follower_id`, `following_id`, `created_at`
- **Constraints**: Unique constraint on (follower_id, following_id)

#### **user_blocks**
- **Purpose**: Track blocked users
- **Fields**: `blocker_id`, `blocked_id`, `reason`, `created_at`
- **Constraints**: Unique constraint on (blocker_id, blocked_id)

#### **user_reports**
- **Purpose**: Report system for users and content
- **Fields**: `reporter_id`, `reported_user_id`, `reported_item_type`, `reported_item_id`, `reason`, `description`, `status`
- **Types**: Can report Users, Roommate Requests, Hostel Listings, Events, Marketplace Items, Messages

#### **user_sessions**
- **Purpose**: Track active user sessions
- **Fields**: `user_id`, `device_info`, `ip_address`, `location`, `is_active`, `last_activity`

#### **user_preferences**
- **Purpose**: Store user app preferences
- **Fields**: `user_id`, `theme`, `notifications_enabled`, `email_notifications`, `push_notifications`, `sms_notifications`, `marketing_emails`, `data_usage`, `language`, `timezone`

### **4. Core Feature Tables**

#### **roommate_requests**
- **Purpose**: Student roommate matching requests
- **Key Fields**: `student_id`, `student_name`, `campus`, `preferred_location`, `budget_range`, `sleep_schedule`, `lifestyle_preference`, `smoking_preference`, `drinking_preference`, `sharing_style`, `compatibility_score`, `status`
- **Relationships**: `student_id` → `profiles(id)`

#### **hostel_listings**
- **Purpose**: Hostel provider property listings
- **Key Fields**: `provider_id`, `name`, `campus`, `address`, `price_per_month`, `room_type`, `amenities[]`, `images[]`, `is_available`, `rating`, `review_count`
- **Relationships**: `provider_id` → `profiles(id)`

#### **events**
- **Purpose**: Event organizer events
- **Key Fields**: `organizer_id`, `title`, `category`, `event_date`, `end_date`, `location`, `venue`, `max_attendees`, `current_attendees`, `is_free`, `price`, `images[]`, `status`
- **Relationships**: `organizer_id` → `profiles(id)`

#### **marketplace_items**
- **Purpose**: Marketplace item listings
- **Key Fields**: `seller_id`, `title`, `category`, `price`, `condition`, `images[]`, `is_available`, `view_count`
- **Relationships**: `seller_id` → `profiles(id)`

#### **notifications**
- **Purpose**: User notifications system
- **Key Fields**: `user_id`, `title`, `message`, `type`, `category`, `priority`, `is_read`, `is_actionable`, `action_text`, `action_url`, `related_id`
- **Relationships**: `user_id` → `profiles(id)`

#### **chats & messages**
- **Purpose**: Chat system
- **Key Fields**: 
  - **chats**: `created_by`, `participants[]`, `type`, `last_message`, `last_message_at`
  - **messages**: `chat_id`, `sender_id`, `content`, `message_type`, `attachments[]`, `is_read`, `read_by[]`
- **Relationships**: `created_by`, `sender_id` → `profiles(id)`; `chat_id` → `chats(id)`

## 🔄 **Multi-Role Functionality**

### **How Multi-Role System Works**

#### **Primary Role**
- **`primary_role`** in `profiles` table represents the user's main role
- Set during initial signup and can be changed in settings
- Determines default UI/UX experience

#### **Additional Roles**
- **`user_roles`** table stores all roles a user has
- Users can add multiple roles through settings
- Each role can be independently verified and activated/deactivated
- Roles include: Student, Hostel Provider, Event Organizer, Promoter

#### **Role Management Flow**
1. **Initial Signup**: User selects primary role, creates initial `user_roles` entry
2. **Add Role**: User can add additional roles in settings
3. **Verification**: Each role requires verification (document upload, admin approval)
4. **Activation**: Verified roles become active and visible to other users
5. **Deactivation**: Users can deactivate roles they no longer need

#### **Use Cases**
- **Student + Event Organizer**: A student who also organizes campus events
- **Student + Promoter**: A student who promotes parties/concerts
- **Hostel Provider + Event Organizer**: A hostel owner who also organizes events
- **Any Combination**: Users can have any combination of roles

#### **API Methods Available**
- `addUserRole()` - Add new role to user profile
- `getUserRoles()` - Get all user roles
- `updateRoleVerification()` - Update verification status
- `deactivateUserRole()` - Deactivate a role
- `updatePrimaryRole()` - Change primary role

## 🔐 **Security & Access Control**

### **Row Level Security (RLS) Policies**

#### **Profiles**
- Users can view their own profile
- Users can view other active profiles
- Users can update their own profile
- Users can insert their own profile

#### **User Management**
- Users can view/manage their own follows, blocks, reports, sessions, preferences
- Users can create follows, blocks, reports
- Users can delete their own follows and blocks

#### **Content Tables**
- Public read access to active roommate requests, available hostel listings, published events, available marketplace items
- Users can manage their own content (roommate requests, hostel listings, events, marketplace items)
- Users can view their own notifications and update them

#### **Chat System**
- Users can view chats they participate in
- Users can create chats
- Users can view/send messages in their chats

## 📈 **Performance Optimizations**

### **Indexes Created**
- **Profiles**: `user_type`, `campus`, `is_active`, `last_seen`
- **Roommate Requests**: `campus`, `status`, `student_id`
- **Hostel Listings**: `campus`, `is_available`, `provider_id`
- **Events**: `event_date`, `category`, `organizer_id`, `status`
- **Marketplace Items**: `category`, `is_available`, `seller_id`
- **Notifications**: `user_id`, `is_read`, `type`
- **Messages**: `chat_id`, `sender_id`
- **User Management**: All foreign key relationships indexed

## 🔄 **Automated Functions & Triggers**

### **Profile Creation**
- **Function**: `handle_new_user()`
- **Trigger**: `on_auth_user_created`
- **Purpose**: Automatically creates profile and user preferences when auth user is created

### **Timestamp Updates**
- **Function**: `update_updated_at_column()`
- **Triggers**: Applied to all tables with `updated_at` fields
- **Purpose**: Automatically updates `updated_at` timestamp on record updates

### **Last Seen Tracking**
- **Function**: `update_last_seen()`
- **Trigger**: `update_last_seen_on_session_activity`
- **Purpose**: Updates user's `last_seen` timestamp when session activity changes

## 💾 **Storage Configuration**

### **Storage Buckets**
- `profile-images` - User profile pictures
- `hostel-images` - Hostel listing images
- `event-images` - Event images
- `marketplace-images` - Marketplace item images

### **Storage Policies**
- Public read access to all images
- Users can upload/update/delete their own images
- Folder structure: `{user_id}/{filename}`

## ✅ **Migration Readiness Checklist**

### **Schema Completeness**
- ✅ All user types covered (Student, Hostel Provider, Event Organizer, Promoter)
- ✅ All signup fields included
- ✅ All relationships properly defined
- ✅ All constraints and checks in place
- ✅ All indexes created for performance
- ✅ All RLS policies implemented
- ✅ All triggers and functions created

### **Data Integrity**
- ✅ Foreign key constraints
- ✅ Unique constraints where needed
- ✅ Check constraints for enums
- ✅ Default values set appropriately
- ✅ Cascade deletes configured

### **Security**
- ✅ Row Level Security enabled on all tables
- ✅ Appropriate policies for each table
- ✅ Storage policies configured
- ✅ User isolation maintained

### **Performance**
- ✅ Indexes on all foreign keys
- ✅ Indexes on frequently queried fields
- ✅ Composite indexes where beneficial
- ✅ Triggers for automatic updates

## 🚀 **Ready for Migration**

The schema is now **comprehensive and production-ready** with:

1. **Complete User Management**: All user types, preferences, sessions, follows, blocks, reports
2. **Full Feature Support**: Roommate requests, hostel listings, events, marketplace, notifications, chat
3. **Robust Security**: RLS policies, storage policies, user isolation
4. **Optimal Performance**: Proper indexing, automated triggers, efficient queries
5. **Data Integrity**: Constraints, validations, cascade operations
6. **Scalability**: Designed to handle growth with proper relationships and indexes

**The database schema is ready for migration!** 🎉
