// Google Places API Configuration
class GooglePlacesConfig {
  // TODO: Replace with your actual Google Places API key
  // Get your API key from: https://console.cloud.google.com/apis/credentials
  static const String placesApiKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE";
  
  // You can also use environment variables for better security
  // static const String placesApiKey = String.fromEnvironment('GOOGLE_PLACES_API_KEY');
  
  // Required APIs to enable in Google Cloud Console:
  // 1. Places API
  // 2. Geocoding API
  // 3. Maps JavaScript API (if using web)
  
  // Required permissions for Android (android/app/src/main/AndroidManifest.xml):
  // <uses-permission android:name="android.permission.INTERNET" />
  // <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  // <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  
  // Required permissions for iOS (ios/Runner/Info.plist):
  // <key>NSLocationWhenInUseUsageDescription</key>
  // <string>This app needs location access to search for hostels</string>
}




