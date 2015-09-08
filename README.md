# Beatbit

A rhythmic 2D shooter, written in Lua for LÖVE.

## Start

Setup LÖVE if you haven't already (you'll need at least version 0.9.0).  Download [JSON.lua](http://regex.info/code/JSON.lua) and save it as `Beatbit/lib/JSON.lua`.

Run the unpacked app with `.../path/to/love Beatbit`.

## Gameplay

On a keyboard, arrow keys to move and WASD to fire.

For joysticks, an Xbox controller layout is assumed; right stick to move, d-pad to fire.

Evil squares spawn to the rhythm.  Each player can fire bullets to the beat of the song.

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
    "length": 254
}
```

Here, `start` is the position (in seconds) of the first beat, whereas `length` is the number of **beats** to the end of the song.

### Advanced

A song may not have a constant BPM.  In this case, replace the `bpm` line with an array of BPMs:

```json
{
    "bpm": [
        [0, 140],
        [32, 110],
        [48, 140]
    ]
}
```

Note that the position (first column) is also measured in **beats**, not seconds.  The benefit is nice round values, since you'll likely be changing BPM on a beat, though the consequence is changing an earlier BPM causes later entries to be incorrect.

Use `speed` to create beat ranges where all movement is accelerated or slowed.

```json
{
    "speed": [
        [64, 96, 0.5]
    ]
}
```

The third column acts as a modifier, and multiple speeds can stack (e.g. `2` and `0.5` would cancel out).  Speed differs from BPM in that the bullet firing rate is unaffected.
