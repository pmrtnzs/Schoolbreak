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

- Run the App on emulator:
   - flutter run -d android_device 
    
