# ChatApp - Real-Time Messaging Application 💬

**ChatApp** is a dynamic real-time messaging application designed for one-to-one communication with robust features. It leverages **Firebase** for real-time messaging, user authentication, and push notifications, alongside **Provider** for state management. The app also supports theme switching with a **Theme Provider** for Dark and Light modes.

---

## 📱 Features

- **One-to-One Chat**: Enjoy seamless private messaging with friends in real time, powered by **Firebase Firestore**.
- **Push Notifications**: Stay updated with new messages using **Firebase Cloud Messaging (FCM)**.
- **User Authentication**: Secure login and signup with **Firebase Authentication**.
- **Theme Switching**: Switch between Light and Dark modes using the **Theme Provider**.
- **Profile Management**: Personalize your profile with a profile picture and user details.

---

## 📸 Screenshots

| Splash Screen      | Login Screen      | Chat Screen        | Profile Screen     |
|-------------------|-------------------|-------------------|-------------------|
| ![Splash Screen](assets/splashscreen.jpeg) | ![Login Screen](assets/login.jpeg) | ![Chat Screen](assets/chatscreen.jpeg) | ![Profile Screen](assets/profile.jpeg) |

---

## 🛠️ Built With

- **Flutter**: Cross-platform mobile framework.
- **Firebase**: For real-time database, authentication, cloud messaging, and storage.
- **Provider**: State management solution.
- **Dart**: Programming language used for building Flutter apps.

---

## 📂 Project Structure

```plaintext
chatapp/
│
├── lib/
│   ├── main.dart           # Entry point of the app
│   ├── screens/            # Screens like Login, Chat, Profile, etc.
│   ├── services/           # Firebase services for authentication, messaging, FCM, etc.
│   ├── providers/          # State management for theme, chat, user, etc.
│   ├── models/             # Data models for User, Message, etc.
│   └── widgets/            # Reusable UI components
├── assets/                 # App assets (images, icons, animations)
└── pubspec.yaml            # Project dependencies
```

---

## 🚀 How to Run Locally

1. **Clone** the repository:
   ```bash
   git clone https://github.com/obaidullah72/chatapp.git
   cd chatapp
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**:
   - Follow the [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup) to configure Firebase for your app.
   - Download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS) from the Firebase Console and add it to the respective platforms.

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🌟 Features to Implement

- **Read Receipts**: Indicate when messages are read.
- **Message Reactions**: Allow users to react to messages.
- **Media Sharing**: Enable sharing of images, videos, and files in chats.
- **Typing Indicators**: Show when a user is typing in real-time.

---

## 📦 Packages Used

- **firebase_auth**: For user authentication.
- **cloud_firestore**: For real-time database and messaging.
- **firebase_cloud_messaging**: For push notifications.
- **provider**: For state management.
- **shared_preferences**: For storing user preferences like theme settings.

---

## 🤝 Contributing

We welcome contributions! Feel free to submit a **pull request** or open an issue to discuss improvements.

---

## 🛡️ License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

For any questions or suggestions, feel free to reach out:

- **GitHub**: [obaidullah72](https://github.com/obaidullah72)
- **LinkedIn**: [obaidullah72](https://www.linkedin.com/in/obaidullah72/)

---

[![Visitor Count](https://visitcount.itsvg.in/api?id=obaidullah72&label=Profile%20Views&color=0&icon=0&pretty=true)](https://visitcount.itsvg.in)
