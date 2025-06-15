# AFL Counter App

> Dongyi Guo, 662970

This assignment is based on week 13 Flutter & Firebase tutorial, reworked into the AFL scoring and statistics tracker.

## Test Device

Tested with Chrome and use Dev Tools to simulate a mobile device.

## References


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

