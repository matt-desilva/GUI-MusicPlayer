# GUI Music Player

## Overview
The GUI Music Player is a Ruby application that allows users to play music, create playlists, and browse albums. All data used by the program is read from the `albums.txt` file, which contains information about albums, artists, genres, album covers, and tracks.

## Dependencies
- Ruby
- RubyGems
- Gosu
- AudioInfo

## Installation
1. Install Ruby from [ruby-lang.org](https://www.ruby-lang.org/).
2. Install Gosu and AudioInfo gems:
gem install gosu audioinfo

## Data Structure
The `albums.txt` file follows this structure:
- Artist: The name of the artist or band.
- Album Name: The title of the album.
- Genre: The genre of the music.
- Album Cover: The path to the album cover image.
- Number of Tracks: The total number of tracks in the album.
- Tracks: Information about each track, including the track name and file path.
  
```
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
JUGGERNAUT
sounds/JUGGERNAUT.mp3
RISE!
sounds/RISE.mp3
MANIFESTO
sounds/MANIFESTO.mp3

5
Childish Gambino
Awaken, My Love
Pop
img/awakenmylove.jpg
5
Redbone
sounds/redbone.mp3
Zombies
sounds/zombies.mp3
California
sounds/california.mp3
Baby Boy
sounds/babyboy.mp3
Boogieman
sounds/boogieman.mp3
...
```
