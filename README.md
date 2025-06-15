# AFL Counter App

This project is a modified version of the week 13 Flutter tutorial. It has been reworked into an AFL scoring and statistics tracker. The app uses Firebase Firestore for storing match, team and player data and allows recording player actions during a match.

## Test Device
- **Android emulator** – API 34 (Android 14). The app was developed and run against this target.

## References
- Flutter and Firebase tutorials from the KIT305 labs and lecture material.
- [FlutterFire documentation](https://firebase.flutter.dev/) for Firebase initialisation and Firestore use.
- Various snippets from StackOverflow for image picker/file handling and table layouts.
- ChatGPT was used extensively to generate boilerplate code, refactor the project into models for matches, teams and players, and to implement the live match recording and statistics screens. The full conversation is available in the assignment submission.

## Screen Overview

1. **Home Page** – lists existing matches from Firestore with the final score if available. Provides a button to create a new match.
2. **New Match Flow** – step based flow used when creating a match:
   - enter team names
   - add/edit players for Team A
   - add/edit players for Team B
   On completion the match is saved and the app proceeds to the briefing screen.
3. **Match Briefing Page** – shows both teams and their players. From here a match can be discarded or started.
4. **Live Match Page** – used during play to record player actions. Users switch between teams, pick a player and record kicks, handballs, marks, tackles, goals or behinds. Quarters can be ended and the match can be finished at any time.
5. **Match Details Page** – read only view of a recorded match with tabs for Scores, Team Stats, Player Stats and Compare Players. Includes a share button for exporting a plain text summary.

These screens are connected in a simple flow: the Home Page launches the New Match Flow, which ends at the Match Briefing Page. Starting the match opens the Live Match Page. Completed matches from the Home Page open directly to the Match Details Page.

