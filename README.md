# SlackJSONtoCSV
Slack JSON to CSV via R

The purpose of this code is to convert a downloaded Slack export (via their internal archive/export system) into a readable, manipulatable CSV.

At time of programming, Slack exports are in the form of daily JSON files per channel. This is not particularly helpful for manipulating or exporting code. 

This program helps convert these JSON files into a per-channel (though invalid) JSON form, and then extracts links to uploaded files via string manipulation, as well as associated helpful information. This can then be directly uploaded to Google Drive through the use of Google Apps Scripts (attached).

Program dependencies:
- tidyverse
- geojsonR
- lubridate

Program inputs:
- path to top of unzipped Slack JSON export
- path to where you wish to save files

---

At this time, there is no plan to support non-file information exports. However, through the use of 'simple' regular expressions, it is very possible to use this code as a jumping-off platform to export other attached information.
