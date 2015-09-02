# Beatbit

A 2D rhythm-based game, written in Lua for LÖVE.

## Tracks

Tracks live in the `tracks` folder.  The structure of a track should look something like the following:

* _Cool Dude - Track Name_
  - track.json
  - music.mp3

Inside `track.json`:

```json
{
    "artist": "Cool Dude",
    "title": "Track Name",
    "music": "music.mp3",
    "bpm": 140,
    "start": 0.21,
    "length": 254
}
```

Here, `start` is the position (in seconds) of the first beat, whereas `length` is the number of **beats** to the end of the song.

## External

Download [JSON.lua](http://regex.info/code/JSON.lua) and place it inside a `lib` folder.
