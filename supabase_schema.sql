-- PulseCampus Database Schema for Supabase
-- Run this SQL in your Supabase SQL Editor

-- Note: auth.users table already has RLS enabled by Supabase
-- We don't need to enable it manually

-- Create profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  primary_role TEXT CHECK (primary_role IN ('Student', 'Hostel Provider', 'Event Organizer', 'Promoter')),
  
  -- Student specific fields
  campus TEXT,
  year_of_study TEXT,
  course TEXT,
  gender TEXT CHECK (gender IN ('Male', 'Female', 'Other', 'Prefer not to say')),
  interests TEXT[], -- Array of interests
  
  -- Hostel provider specific fields
  business_name TEXT,
  primary_phone TEXT,
  secondary_phone TEXT,
  location_name TEXT,
  address TEXT,
  
  -- Event organizer specific fields
  organization_name TEXT,
  organization_type TEXT,
  organization_description TEXT,
  organization_website TEXT,
  
  -- Promoter specific fields
  agency_name TEXT,
  agency_type TEXT,
  agency_description TEXT,
  agency_website TEXT,
  
  -- Common fields
  bio TEXT,
  profile_image_url TEXT,
  phone_number TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  last_seen TIMESTAMP WITH TIME ZONE,
  timezone TEXT DEFAULT 'UTC',
  language TEXT DEFAULT 'en',
  notification_preferences JSONB DEFAULT '{}',
  privacy_settings JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create roommate_requests table
CREATE TABLE roommate_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  student_name TEXT NOT NULL,
  nickname TEXT,
  campus TEXT NOT NULL,
  year_of_study TEXT,
  bio TEXT,
  profile_picture_url TEXT,
  preferred_location TEXT,
  budget_range TEXT,
  preferred_hostel TEXT,
  move_in_date DATE,
  urgency TEXT,
  lease_duration TEXT,
  sleep_schedule TEXT CHECK (sleep_schedule IN ('Early Riser', 'Night Owl', 'Flexible')),
  lifestyle_preference TEXT CHECK (lifestyle_preference IN ('Quiet', 'Social', 'Music Lover', 'Study Focused')),
  smoking_preference TEXT CHECK (smoking_preference IN ('Non-smoker', 'Smoker', 'Occasional')),
  drinking_preference TEXT CHECK (drinking_preference IN ('Non-drinker', 'Social Drinker', 'Regular Drinker')),
  sharing_style TEXT CHECK (sharing_style IN ('Private', 'Okay with Visitors', 'Very Social')),
  compatibility_score INTEGER CHECK (compatibility_score >= 0 AND compatibility_score <= 100),
  photos TEXT[], -- Array of photo URLs
  hostel_listings TEXT[], -- Array of hostel listing URLs
  status TEXT CHECK (status IN ('Active', 'Matched', 'Expired', 'Cancelled')) DEFAULT 'Active',
  phone_number TEXT,
  is_phone_shared BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on roommate_requests
ALTER TABLE roommate_requests ENABLE ROW LEVEL SECURITY;

-- Create hostel_listings table
CREATE TABLE hostel_listings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  provider_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  campus TEXT NOT NULL,
  address TEXT,
  price_per_month DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'UGX',
  room_type TEXT CHECK (room_type IN ('Single', 'Double', 'Shared', 'Apartment', 'Rental')),
  amenities TEXT[], -- Array of amenities
  images TEXT[], -- Array of image URLs
  is_available BOOLEAN DEFAULT TRUE,
  available_rooms INTEGER DEFAULT 1,
  contact_phone TEXT,
  contact_email TEXT,
  rating DECIMAL(3,2) DEFAULT 0.0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on hostel_listings
ALTER TABLE hostel_listings ENABLE ROW LEVEL SECURITY;

-- Create events table
CREATE TABLE events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  organizer_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT CHECK (category IN ('Social', 'Academic', 'Sports', 'Cultural', 'Tech', 'Campus Life')),
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  location TEXT NOT NULL,
  venue TEXT,
  max_attendees INTEGER,
  current_attendees INTEGER DEFAULT 0,
  is_free BOOLEAN DEFAULT TRUE,
  price DECIMAL(10,2) DEFAULT 0.0,
  currency TEXT DEFAULT 'USD',
  images TEXT[], -- Array of image URLs
  requirements TEXT,
  contact_info TEXT,
  status TEXT CHECK (status IN ('Draft', 'Published', 'Cancelled', 'Completed')) DEFAULT 'Draft',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on events
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Create marketplace_items table
CREATE TABLE marketplace_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT CHECK (category IN ('Books', 'Electronics', 'Furniture', 'Clothes', 'Entertainment', 'Services')),
  price DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'UGX',
  condition TEXT CHECK (condition IN ('New', 'Like New', 'Good', 'Fair', 'Poor')),
  images TEXT[], -- Array of image URLs
  is_available BOOLEAN DEFAULT TRUE,
  view_count INTEGER DEFAULT 0,
  contact_phone TEXT,
  contact_email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on marketplace_items
ALTER TABLE marketplace_items ENABLE ROW LEVEL SECURITY;

-- Create notifications table
CREATE TABLE notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT CHECK (type IN ('Chat', 'Event', 'Housing', 'Marketplace', 'System', 'Match')) NOT NULL,
  category TEXT CHECK (category IN ('All', 'Chats & Messages', 'Events', 'Housing', 'Marketplace', 'Campus Pulse')) DEFAULT 'All',
  priority TEXT CHECK (priority IN ('Low', 'Medium', 'High', 'Urgent')) DEFAULT 'Medium',
  is_read BOOLEAN DEFAULT FALSE,
  is_actionable BOOLEAN DEFAULT FALSE,
  action_text TEXT,
  action_url TEXT,
  avatar_url TEXT,
  related_id UUID, -- ID of related item (event, message, etc.)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create chats table
CREATE TABLE chats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT,
  type TEXT CHECK (type IN ('Direct', 'Group', 'Roommate', 'Event')) DEFAULT 'Direct',
  created_by UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  participants UUID[] NOT NULL, -- Array of user IDs
  last_message TEXT,
  last_message_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on chats
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Create messages table
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT CHECK (message_type IN ('Text', 'Image', 'File', 'Link')) DEFAULT 'Text',
  attachments TEXT[], -- Array of file URLs
  is_read BOOLEAN DEFAULT FALSE,
  read_by UUID[], -- Array of user IDs who read the message
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create additional tables for enhanced functionality

-- Create user_roles table for multiple roles per user
CREATE TABLE user_roles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  role TEXT CHECK (role IN ('Student', 'Hostel Provider', 'Event Organizer', 'Promoter')) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE,
  verification_document_url TEXT,
  verification_notes TEXT,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  verified_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(user_id, role)
);

-- Create user_follows table for following/followers
CREATE TABLE user_follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  follower_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  following_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- Create user_blocks table for blocking users
CREATE TABLE user_blocks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  blocker_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  blocked_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id)
);

-- Create user_reports table for reporting users/content
CREATE TABLE user_reports (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  reporter_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  reported_user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  reported_item_type TEXT CHECK (reported_item_type IN ('User', 'Roommate Request', 'Hostel Listing', 'Event', 'Marketplace Item', 'Message')),
  reported_item_id UUID,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT CHECK (status IN ('Pending', 'Reviewed', 'Resolved', 'Dismissed')) DEFAULT 'Pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_sessions table for tracking active sessions
CREATE TABLE user_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  device_info TEXT,
  ip_address TEXT,
  location TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create user_preferences table for app preferences
CREATE TABLE user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL UNIQUE,
  theme TEXT CHECK (theme IN ('Light', 'Dark', 'System')) DEFAULT 'System',
  notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications BOOLEAN DEFAULT TRUE,
  push_notifications BOOLEAN DEFAULT TRUE,
  sms_notifications BOOLEAN DEFAULT FALSE,
  marketing_emails BOOLEAN DEFAULT FALSE,
  data_usage TEXT CHECK (data_usage IN ('WiFi Only', 'Always', 'Never')) DEFAULT 'WiFi Only',
  language TEXT DEFAULT 'en',
  timezone TEXT DEFAULT 'UTC',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on new tables
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Create indexes for better performance
CREATE INDEX idx_profiles_primary_role ON profiles(primary_role);
CREATE INDEX idx_profiles_campus ON profiles(campus);
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);
CREATE INDEX idx_user_roles_active ON user_roles(is_active);
CREATE INDEX idx_user_roles_verified ON user_roles(is_verified);
CREATE INDEX idx_profiles_is_active ON profiles(is_active);
CREATE INDEX idx_profiles_last_seen ON profiles(last_seen);
CREATE INDEX idx_roommate_requests_campus ON roommate_requests(campus);
CREATE INDEX idx_roommate_requests_status ON roommate_requests(status);
CREATE INDEX idx_roommate_requests_student_id ON roommate_requests(student_id);
CREATE INDEX idx_hostel_listings_campus ON hostel_listings(campus);
CREATE INDEX idx_hostel_listings_available ON hostel_listings(is_available);
CREATE INDEX idx_hostel_listings_provider_id ON hostel_listings(provider_id);
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_organizer_id ON events(organizer_id);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_marketplace_items_category ON marketplace_items(category);
CREATE INDEX idx_marketplace_items_available ON marketplace_items(is_available);
CREATE INDEX idx_marketplace_items_seller_id ON marketplace_items(seller_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_messages_chat_id ON messages(chat_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX idx_user_follows_following ON user_follows(following_id);
CREATE INDEX idx_user_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX idx_user_blocks_blocked ON user_blocks(blocked_id);
CREATE INDEX idx_user_reports_reporter ON user_reports(reporter_id);
CREATE INDEX idx_user_reports_reported ON user_reports(reported_user_id);
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_active ON user_sessions(is_active);

-- Create RLS Policies

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can view other active profiles" ON profiles
  FOR SELECT USING (is_active = true);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- User roles policies
CREATE POLICY "Users can view their own roles" ON user_roles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view other users' active verified roles" ON user_roles
  FOR SELECT USING (is_active = true AND is_verified = true);

CREATE POLICY "Users can add roles to their profile" ON user_roles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own roles" ON user_roles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can deactivate their own roles" ON user_roles
  FOR DELETE USING (auth.uid() = user_id);

-- User follows policies
CREATE POLICY "Users can view their own follows" ON user_follows
  FOR SELECT USING (auth.uid() = follower_id OR auth.uid() = following_id);

CREATE POLICY "Users can create follows" ON user_follows
  FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can delete their own follows" ON user_follows
  FOR DELETE USING (auth.uid() = follower_id);

-- User blocks policies
CREATE POLICY "Users can view their own blocks" ON user_blocks
  FOR SELECT USING (auth.uid() = blocker_id);

CREATE POLICY "Users can create blocks" ON user_blocks
  FOR INSERT WITH CHECK (auth.uid() = blocker_id);

CREATE POLICY "Users can delete their own blocks" ON user_blocks
  FOR DELETE USING (auth.uid() = blocker_id);

-- User reports policies
CREATE POLICY "Users can view their own reports" ON user_reports
  FOR SELECT USING (auth.uid() = reporter_id);

CREATE POLICY "Users can create reports" ON user_reports
  FOR INSERT WITH CHECK (auth.uid() = reporter_id);

-- User sessions policies
CREATE POLICY "Users can view their own sessions" ON user_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own sessions" ON user_sessions
  FOR ALL USING (auth.uid() = user_id);

-- User preferences policies
CREATE POLICY "Users can view their own preferences" ON user_preferences
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own preferences" ON user_preferences
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own preferences" ON user_preferences
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Roommate requests policies
CREATE POLICY "Anyone can view active roommate requests" ON roommate_requests
  FOR SELECT USING (status = 'Active');

CREATE POLICY "Users can create their own roommate requests" ON roommate_requests
  FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Users can update their own roommate requests" ON roommate_requests
  FOR UPDATE USING (auth.uid() = student_id);

CREATE POLICY "Users can delete their own roommate requests" ON roommate_requests
  FOR DELETE USING (auth.uid() = student_id);

-- Hostel listings policies
CREATE POLICY "Anyone can view available hostel listings" ON hostel_listings
  FOR SELECT USING (is_available = true);

CREATE POLICY "Hostel providers can manage their own listings" ON hostel_listings
  FOR ALL USING (auth.uid() = provider_id);

-- Events policies
CREATE POLICY "Anyone can view published events" ON events
  FOR SELECT USING (status = 'Published');

CREATE POLICY "Event organizers can manage their own events" ON events
  FOR ALL USING (auth.uid() = organizer_id);

-- Marketplace items policies
CREATE POLICY "Anyone can view available marketplace items" ON marketplace_items
  FOR SELECT USING (is_available = true);

CREATE POLICY "Sellers can manage their own items" ON marketplace_items
  FOR ALL USING (auth.uid() = seller_id);

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Chats policies
CREATE POLICY "Users can view chats they participate in" ON chats
  FOR SELECT USING (auth.uid() = ANY(participants));

CREATE POLICY "Users can create chats" ON chats
  FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Messages policies
CREATE POLICY "Users can view messages in their chats" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chats 
      WHERE chats.id = messages.chat_id 
      AND auth.uid() = ANY(chats.participants)
    )
  );

CREATE POLICY "Users can send messages to their chats" ON messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM chats 
      WHERE chats.id = messages.chat_id 
      AND auth.uid() = ANY(chats.participants)
    )
  );

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
  ('profile-images', 'profile-images', true),
  ('hostel-images', 'hostel-images', true),
  ('event-images', 'event-images', true),
  ('marketplace-images', 'marketplace-images', true);

-- Create storage policies
CREATE POLICY "Profile images are publicly accessible" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload their own profile images" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own profile images" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own profile images" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'profile-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Create functions for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_name, last_name, primary_role)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name',
    NEW.raw_user_meta_data->>'user_type'
  );
  
  -- Create initial role entry
  INSERT INTO public.user_roles (user_id, role, is_active, is_verified)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'user_type',
    true,
    false
  );
  
  -- Create default user preferences
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic profile creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_roommate_requests_updated_at BEFORE UPDATE ON roommate_requests
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_hostel_listings_updated_at BEFORE UPDATE ON hostel_listings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_marketplace_items_updated_at BEFORE UPDATE ON marketplace_items
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_chats_updated_at BEFORE UPDATE ON chats
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_reports_updated_at BEFORE UPDATE ON user_reports
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_roles_updated_at BEFORE UPDATE ON user_roles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Create function to update last_seen timestamp
CREATE OR REPLACE FUNCTION public.update_last_seen()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.profiles 
  SET last_seen = NOW() 
  WHERE id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to update last_seen on session activity
CREATE TRIGGER update_last_seen_on_session_activity
  AFTER UPDATE ON user_sessions
  FOR EACH ROW 
  WHEN (NEW.last_activity != OLD.last_activity)
  EXECUTE FUNCTION public.update_last_seen();
