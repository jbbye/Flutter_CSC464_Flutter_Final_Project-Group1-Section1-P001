# LingoAI Flutter App - Setup Guide

## Issues and Solutions

### "Files are not loading" - Common Causes and Fixes

#### 1. **Firebase Configuration Not Set Up**
- Run: `flutterfire configure` to set up Firebase for your platforms
- Make sure Firebase is initialized in `main.dart` (already done)

#### 2. **Firestore Security Rules Not Set**
If you see errors loading user data, your Firestore security rules might be blocking access.

**For Development/Testing**, set these rules temporarily:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{document=**} {
      allow read, write: if request.auth != null;
    }
    match /chats/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### 3. **Firebase Not Initialized**
The app waits for Firebase to initialize. If it takes too long:
- Check internet connection
- Verify Firebase credentials are correct
- Check Firebase project is active in console

#### 4. **User Document Not Created**
When registering, if the user document isn't created properly:
- The app now handles this with default values
- User can still proceed to dashboard
- Profile can be edited later

#### 5. **Empty Firestore Database**
- If you see "No active sessions" in the sidebar, this is expected
- Create new chat sessions using the "+ Add" button
- Sessions are stored in Firestore collection: `chats`

## Troubleshooting Steps

1. **Check Firebase Connection:**
   ```dart
   // In main.dart, check firebaseReady value
   print('Firebase Ready: $firebaseReady');
   ```

2. **Check Authentication State:**
   - Try logging in with a test email
   - Verify user exists in Firebase Authentication console

3. **Check Firestore Rules:**
   - Go to Firebase Console
   - Check Firestore Rules are not blocking access
   - Ensure user documents exist in 'users' collection

4. **Clear App Data:**
   ```
   flutter clean
   flutter pub get
   ```

5. **Check Console Logs:**
   - Run: `flutter run -v` for verbose output
   - Look for Firestore/Auth errors

## Features

✅ User Authentication (Register/Login)
✅ Profile Management
✅ Firestore Integration
✅ Chat Sessions with AI
✅ Language Selection
✅ Responsive UI

## Testing the App

1. **Create an Account:**
   - Go to Login screen
   - Click "REGISTER"
   - Fill in email, password, and full name
   - Submit

2. **Access Dashboard:**
   - You'll be automatically logged in
   - See sidebar with your profile

3. **Update Profile:**
   - Click "Profile Settings" in sidebar
   - Click "EDIT PROFILE"
   - Update your name and bio
   - Click "SAVE CHANGES"

4. **Logout:**
   - Click your profile card in sidebar
   - Or use "LOGOUT" button in Profile screen

## File Structure

```
lib/
  ├── main.dart                 # App entry point with auth state
  ├── services/
  │   └── auth_service.dart    # Firebase Auth & Firestore service
  ├── screens/
  │   ├── login_screen.dart    # Login/Registration
  │   ├── dashboard_screen.dart # Main app
  │   ├── profile_screen.dart  # User profile
  │   └── chat_screen.dart     # AI chat
  └── widgets/
      ├── app_sidebar.dart     # Navigation sidebar
      └── ...other widgets
```

## Next Steps if Still Having Issues

1. Check that you've run `flutterfire configure`
2. Verify Firebase console shows your users and collections
3. Try on a different device/emulator
4. Check network connectivity
5. Update Firebase dependencies:
   ```
   flutter pub upgrade
   ```
