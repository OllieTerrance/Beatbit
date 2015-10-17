# Beatbit

A rhythmic 2D shooter, where enemies and weapons act to the beat of the music.

## Start

Download LÖVE if you haven't already (you'll need at least version 0.9.0).  You'll also need a copy of [JSON.lua](http://regex.info/code/JSON.lua), saved as `Beatbit/lib/JSON.lua`.

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

Other audio formats are available -- check the list of [supported formats in LÖVE](https://love2d.org/wiki/Audio_Formats).

Inside `track.json`:

```json
{
    "artist": "Cool Dude",
    "title": "Track Name",
    "music": "music.mp3",
    "start": 0.21,
    "length": 254
}
```

Valid top-level properties in a `track.json` file:

Property | Required (default)  | Description
-------- | ------------------- | ------------------------------------------
`artist` | No (`""`)           | Artist of the song
`title`  | Yes                 | Name of the song
`music`  | Yes                 | Relative path to the audio file
`start`  | No (`0`)            | Position of the first beat, in **seconds**
`length` | Yes                 | Number of beats to the end of the song
`bpm`    | Yes                 | Number of beats per minute
`speed`  | No (`1`)            | Relative in-game speed
`melody` | No (`{"map": [0]}`) | Primary song pattern and loop size
`rhythm` | No (`{"map": [0]}`) | Secondary song pattern and loop size

### Changesets

Songs may not be constant in BPM or speed.  Any changes to values can be defined inside a `changes` array, with each changeset requiring timing for when to apply them:

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

Valid properties in a changeset (`at` is required; all others default to none, i.e. causing no change in that component):

Property | Description
-------- | ------------------------------------------------
`at`     | Position from which the change applies, in beats
`bpm`    | Number of beats per minute
`speed`  | Relative in-game speed
`melody` | Primary song pattern and loop size
`rhythm` | Secondary song pattern and loop size

The benefit of measuring in beats rather than time is nice round values, since you'll likely be changing BPM on a beat, though the consequence is changing an earlier BPM causes later entries to be incorrect.

### Melodies

The default changeset assumes every beat is a beat of the song.  You will likely want more control on this (for example, with off-beat notes or more complicated patterns).  Enter the melody and rhythm:

```json
{
    "melody": {
        "map": [0, 0.5, 1.5, 2.5, 3, 4, 6],
        "loop": 8
    }
}
```

This defines a repeating pattern of length 8 (it is actually the first seven notes to the Overworld music in Super Mario Bros.), for which in-game beats occur on and off the regular timing.

The `loop` value can be omitted if the pattern fills the last whole beat (in the example, it would actually default to `7`, hence the explicit definition is required).  If no melodies are specified, the default at time zero is a single beat on `0`, and a loop of `1` -- that is, a simple on-beat pattern.

In Beatbit, there are two such pattern variables: `melody` and `rhythm`.  The former controls player firing rate, whist the latter affects enemy spawn rates.  Both of these can also be used inside changesets.
