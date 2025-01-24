# Setting Up and Running Schoolbreak

This guide outlines the steps and configurations required to set up the **Schoolbreak** project on a new computer.

## Prerequisites

1. Install Flutter:
   - Download Flutter from https://flutter.dev/docs/get-started/install
   - If on university machine, it is available on AppsAnywhere
   - Add Flutter to your system PATH:
     - Windows:
       set PATH=%PATH%;C:\path\to\flutter\bin
     - macOS/Linux:
       export PATH="$PATH:/path/to/flutter/bin"
   - Verify installation:
     - flutter doctor

2. Clone the Repository and move to the appropriate directory:
   git clone https://github.com/pmrtnzs/Schoolbreak.git
   cd Schoolbreak

3. Install Dependencies:
   flutter pub get

## Running on web

- Run the App on browser  
  - Use the command: flutter run -d chrome
 
This will run the app in **debug mode**. Ideally the app should be ran on **release mode** by adding a '--release' at the end.  
However, I encountered a limitation with Flutter's video_player package. As specified in https://pub.dev/packages/video_player_web:  

   _"Certain videos will rewind to the beginning when users attempt to seekTo (change the progress/scrub to) another position, instead of jumping to the desired position. Once the video is fully stored in the browser cache, seeking will work fine after a full page reload."_  
   
This causes an unexpected black background after a video finishes playing for the first time, if page reloaded, this doesn't happen as the video is in the browser's cache. For this reason and demonstration purposes, the ideal performance occurs on **debug mode**, having all videos played once before. This behaviour is most evident when the **Skip** button is used, as it has an explicit **.seekTo()** operation. However, it may happen non-deterministically as the **.play()** method has a **.seekTo()** in its definition (see line 555 in https://github.com/flutter/packages/blob/main/packages/video_player/video_player/lib/video_player.dart). 

## Running on Android

# Run the App on emulator:
1. Install Android Studio:
 - Download and install Android Studio.
 - Open Android Studio and go to Tools > SDK Manager.
 - Ensure the necessary SDK platforms and tools are installed.

2. Create an Emulator:
 - In Android Studio, go to Tools > Device Manager.
 - Click Create Device and select a device profile (e.g., Pixel 6).
 - Choose a system image (e.g., Android 13 with Google APIs) and download it if necessary.
 - Finish the setup and start the emulator.

3. Run the app:
 - flutter run -d android_device 

# Create .apk
 - Execute 'flutter build apk --release' in cmd.
 - Find in 'build\app\outputs\flutter-apk\app-release.apk'.

# Create App bundle for release
 - Execute 'flutter build appbundle --release' in cmd.
 - Find in 'build\app\outputs\bundle\release\app-release.aab'.  

 For minimal space consumption, no builds were inside the submitted foler. Thess instructions should make them.

