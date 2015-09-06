# Beatbit

A 2D rhythm-based game, written in Lua for LÖVE.

## Start

Setup LÖVE if you haven't already (you'll need at least version 0.9.0).  Download [JSON.lua](http://regex.info/code/JSON.lua) and save it as `Beatbit/lib/JSON.lua`.

Run the unpacked app with `.../path/to/love Beatbit`.

## Controls

On a keyboard, arrow keys to move and WASD to fire.

For joysticks, an Xbox controller layout is assumed; right stick to move, d-pad to fire.

## Tracks

Tracks live in the `tracks` folder.  The location of this folder may vary depending on the platform.  The table below lists the places to be searched (see the [LÖVE wiki](https://love2d.org/wiki/love.filesystem) for a more detailed explanation).

Run method | Project root  | App data
---------- | ------------- | ------------
Source     | Yes           | LOVE/Beatbit
Packaged   | If in package | LOVE/Beatbit
Fused      | If in package | Beatbit

The structure of a track should look something like the following:

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
    "length": 254,
    "speeds": [
        [64, 96, 0.5]
    ]
}
```

Here, `start` is the position (in seconds) of the first beat, whereas `length` is the number of **beats** to the end of the song.  Use `speeds` to create beat ranges where all movement is accelerated or slowed.
