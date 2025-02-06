# Discord Authentication Flutter App

This Flutter project demonstrates how to integrate Discord OAuth2 authentication into a Flutter app using the PKCE (Proof Key for Code Exchange) flow. Users can log in using their Discord account, and upon successful authentication, their basic profile data is displayed. A logout button allows users to clear the displayed information.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [How It Works](#how-it-works)
- [Project Structure](#project-structure)
- [Setup and Running](#setup-and-running)
- [Dependencies](#dependencies)

## Overview

This project uses the following packages and techniques:
- **flutter_web_auth:** Opens the Discord login page for authentication.
- **http:** Handles HTTP requests for token exchange and user data fetching.
- **crypto:** Generates the PKCE code verifier and challenge.
- **OAuth2 PKCE Flow:** A secure way to perform authentication on mobile devices.

## Features

- **Login with Discord:** Users authenticate via their Discord account.
- **Display User Data:** After login, the app shows the user's Discord username, ID, avatar, global name, and locale.
- **Logout:** Users can log out, which clears the displayed data.

## How It Works

1. **Code Verifier & Code Challenge Generation:**
   - A code verifier is generated (a random string of 43 bytes) and then converted into a code challenge using the SHA-256 algorithm.
   - These values are used to secure the OAuth2 flow.

2. **Initiating Authentication:**
   - When the user taps the "Log in with Discord" button, the app builds an authorization URL with parameters including the client ID, redirect URI, code challenge, and requested scopes.
   - The app then opens the Discord login page using `flutter_web_auth`.

3. **User Login and Callback:**
   - After the user logs in, Discord redirects back to the app with an authorization code.
   - The app extracts the authorization code from the callback URL.

4. **Token Exchange:**
   - The app sends a POST request to Discord's token endpoint to exchange the authorization code (and the previously generated code verifier) for an access token.
   - If successful, the access token is used to fetch the user’s basic profile information.

5. **Displaying User Data:**
   - The retrieved user data (including username, ID, avatar URL, global name, and locale) is displayed on the home screen.
   - A logout button is provided to clear the displayed data.



