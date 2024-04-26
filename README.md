GUI Music Player

Overview
The GUI Music Player is a Ruby application that allows users to play music, create playlists, and browse albums. All data used by the program is read from the albums.txt file, which contains information about albums, artists, genres, album covers, and tracks.

Dependencies
Ruby
RubyGems
Gosu
AudioInfo

Data Structure
The albums.txt file follows this structure:

Each album entry starts with the number of tracks in the album.
Album details include artist name, album name, genre, album cover image path, and track information.
Track information includes track name and track file path.

Example:
vbnet
Copy code
9
Tyler, the Creator
Call Me If You Get Lost
Rap
img/callmeifyougetlost.jpg
5
LEMONHEAD
sounds/LEMONHEAD.mp3
WUSYANAME
sounds/WUSYANAME.mp3
...

Features
Browse albums by artist or genre.
Create and manage playlists.
Play, pause, stop, skip, and control volume.
Display album covers and track information.
