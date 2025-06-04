# Firebase Controller Setup Guide

This guide will help you set up our App to use Firebase Messaging

## Prerequisites

- A Firebase account
- Flutter development environment
- Android Studio / Xcode for platform-specific setup

## Setup Steps

### 1. Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter a project name (e.g., "Braustuebl Bestell App")
4. Follow the setup wizard

### 2. Add Firebase to Your Flutter App

It is recommended to use the **FlutterFire CLI** but you can also
do this manually. Just check the Firebase documentation.

1. Install the Firebase CLI:

   ```bash
   npm install -g firebase-tools
   ```

2. Log in to Firebase:

   ```bash
   firebase login
   ```

3. Install the FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   ```

4. Configure your Flutter app:

   ```bash
   flutterfire configure
   ```

5. Select the Firebase Project you want to use and follow the CLI

### 4. Dependencies

Add the `firebase_messaging` as a dependency to your `pubspec.yaml`:
