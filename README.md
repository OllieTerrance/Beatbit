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
    "start": 0.21,
    "length": 254,
    "changes": {...}
}
```

Here, `start` is the position (in seconds) of the first beat, whereas `length` is the number of **beats** to the end of the song.

### Changesets

Each song consists of one or more changes.  For a basic song, only an initial BPM is required:

```json
{
    "changes": [{
        "bpm": 140
    }]
}
```

Songs will typically not be constant.  Subsequent changes can be added, but require timing for when to apply them:

```json
{
    "changes": [{
        "bpm": 140,
        "speed": 1
    }, {
        "at": 32,
        "bpm": 110
    }, {
        "at": 48,
        "bpm": 140,
        "speed": 0.5
    }, {
        "at": 56,
        "speed": 1
    }]
}
```

BPM affects the rate of actions in game (player firing rate, enemy spawning), whereas speed only affects movement.

Note that the `at` value is also measured in **beats**, not seconds.  The benefit is nice round values, since you'll likely be changing BPM on a beat, though the consequence is changing an earlier BPM causes later entries to be incorrect.

### Melodies

The default changeset assumes every beat is a beat of the song.  You will likely want more control on this (for example, with off-beat notes or more complicated patterns).  Enter the melody:

```json
{
    "changes": [{
        "melody": {
            "map": [0, 0.5, 1.5, 2.5, 3, 4, 6],
            "loop": 8
        }
    }]
}
```

This defines a repeating pattern of length 8 (it is actually the first seven notes to the Overworld music in Super Mario Bros.), for which in-game beats occur on and off the regular timing.

The `loop` value can be omitted if the pattern fills the last whole beat (in the example, it would actually default to `7`, hence the explicit definition is required).  If no melodies are specified, the default at time zero is `{"map": [0]}` -- that is, a simple on-beat melody.
