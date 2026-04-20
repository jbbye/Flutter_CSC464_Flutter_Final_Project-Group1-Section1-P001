# Lingo AI (P001)

Language learning app with Gemini chat and Firestore session memory.

## Features

- Home screen with language selector
- Chat screen with user/AI message list
- Send message flow with loading indicator
- Gemini API integration for AI tutor responses
- Firestore storage for chats and messages

## Firestore Structure

```
/chats
	/chatId
		language: string
		createdAt: timestamp

		/messages
			/messageId
				sender: "user" | "ai"
				message: string
				timestamp: timestamp
```

## Setup

1. Install dependencies:

```bash
flutter pub get
```

2. Configure Firebase for your platforms:

```bash
flutterfire configure
```

This generates `lib/firebase_options.dart` and platform config files.

3. Run app with Gemini API key:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

## Notes

- If Firebase is not configured, the app shows a warning and chat creation is blocked.
- Gemini calls are skipped if `GEMINI_API_KEY` is missing.
