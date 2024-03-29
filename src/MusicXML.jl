module MusicXML

using AcuteML

import MIDI, MusicManipulations

# I/O functions
include("io.jl")

# Types:
export Doc, Scorepartwise, Part, Measure, NoteX, Unpitched, Rest, Pitch, Attributes, Time, Transpose, Clef, Key, Partlist, Scorepart, Midiinstrument, Mididevice, Scoreinstrument

# Utilities
include("utilities.jl")

################################################################
# musicxml yes-no type
struct YN
    yn::String
    bool::Bool

    function YN(bool::Bool)
        if bool
            yn = "yes"
        else
            yn = "no"
        end
        new(yn, bool)
    end

    function YN(yn::String)
        if yn == "yes"
            bool = true
        elseif yn == "no"
            bool = false
        end
        new(yn, bool)
    end

    function YN(yn::String, bool::Bool)
        if (yn == "yes" && bool == true) || (yn == "no" && bool == false)
            new(yn, bool)
        else
            error("invalid YN definition")
        end
    end
end
YN(::Nothing) = nothing
################################################################
# Common function checks
midi16(x) = 1<= x <= 16
midi128(x) = 1 <= x <= 128
midi16384(x) = 1 <= x <= 16384
percent(x) = 0 <= x <=100
rot180(x) = -180 <= x <= 180
positive(x) = x>0
################################################################
"""
    Scoreinstrument

# Arguments
```julia
- name::String, "instrument-name"
- abbreviation::UN{String} = nothing, "instrument-abbreviation"
- sound::UN{String} = nothing, "instrument-sound"
- # ensemble::UN{Int64} = nothing, sc"~", positive
- # solo::UN{Int64} = nothing, sc"~"
- id::String, a"id"
- # VST::VST, "virtual-instrument"
```
The score-instrument type represents a single instrument within a score-part. As with the score-part type, each score-instrument has a required id attribute, a name, and an optional abbreviation. A score-instrument type is also required if the score specifies MIDI 1.0 channels, banks, or programs. An initial midi-instrument assignment can also be made here. MusicXML software should be able to automatically assign reasonable channels and instruments without these elements in simple cases, such as where part names match General MIDI instrument names.

[More info](https://usermanuals.musicxml.com/MusicXML/Content/EL-MusicXML-score-instrument.htm)

# Example
```julia
Scoreinstrument(name = "Violin", id = "P1-I1")
```
"""
@aml mutable struct Scoreinstrument "score-instrument"
    name::String, "instrument-name"
    abbreviation::UN{String} = nothing, "instrument-abbreviation"
    sound::UN{String} = nothing, "instrument-sound"
    # ensemble::UN{Int64} = nothing, sc"~", positive
    # solo::UN{Int64} = nothing, sc"~"
    id::String = "P1-I1", a"id"
    # VST::VST, "virtual-instrument"
end
################################################################
"""
    Mididevice

# Arguments
```julia
- port::Int16, a"port"
- id::String, a"id"
```
The midi-device type corresponds to the DeviceName meta event in Standard MIDI Files. Unlike the DeviceName meta event, there can be multiple midi-device elements per MusicXML part starting in MusicXML 3.0.

[More info](https://usermanuals.musicxml.com/MusicXML/Content/EL-MusicXML-midi-device.htm)
# Example
```julia
Mididevice(port = 1, id = "P1-I1")
```
"""
@aml mutable struct Mididevice "midi-device"
    port::Int64 = 1, a"port", midi16
    id::String = "P1-I1", a"id"
end
################################################################
"""
    Midiinstrument

# Arguments
```julia
- channel::Int64 = 0, "midi-channel",  midi16
- name::UN{String} = nothing, "midi-name"
- bank::UN{Int64} = nothing, "midi-bank", midi16384
- program::Int64 = 1, "midi-program", midiCheck
- unpitched::UN{Int64} = nothing, "midi-unpitched", midi16
- volume::Float64 = 127, "volume", percent
- pan::Float64 = 0, "pan", rot180
- elevation::UN{Float64} = nothing, "elevation", rot180
- id::String = "P1-I1", a"id"
```

Midiinstrument type holds information about the sound of a midi instrument.

[More info](https://usermanuals.musicxml.com/MusicXML/Content/EL-MusicXML-midi-instrument.htm)

Pan: -90 is hard left, 0 is center, -180 is behind

# Example
```julia
Midiinstrument(channel= 1, program =1, volume = 127, pan =0, id = "P1-I1")
```
"""
@aml mutable struct Midiinstrument "midi-instrument"
    channel::Int64 = 1, "midi-channel",  midi16
    name::UN{String} = nothing, "midi-name"
    bank::UN{Int64} = nothing, "midi-bank", midi16384
    program::Int64 = 1, "midi-program", midiCheck
    unpitched::UN{Int64} = nothing, "midi-unpitched", midi16
    volume::Float64 = 127, "volume", percent
    pan::Float64 = 0, "pan", rot180
    elevation::UN{Float64} = nothing, "elevation", rot180
    id::String = "P1-I1", a"id"
end
################################################################
"""
    Scorepart

# Arguments
```julia
- # identification
- name::String, "part-name"
- nameDisplay::UN{String} = nothing, "part-name-display"
- abbreviation::UN{String} = nothing, "part-abbreviation"
- abbreviationDisplay::UN{String} = nothing, "part-abbreviation-display"
- scoreinstrument::UN{Scoreinstrument} = nothing, "score-instrument"
- mididevice::UN{Mididevice} = nothing, "midi-device"
- midiinstrument::Midiinstrument, "midi-instrument"
- id::String, a"id"
```

Holds information about one Scorepart in a score

Each MusicXML part corresponds to a track in a Standard MIDI Format 1 file. The score-instrument elements are used when there are multiple instruments per track. The midi-device element is used to make a MIDI device or port assignment for the given track or specific MIDI instruments. Initial midi-instrument assignments may be made here as well.

scoreinstrument: See [`Scoreinstrument`](@ref) doc
mididevice: See [`Mididevice`](@ref) doc
midiinstrument: See [`Midiinstrument`](@ref) doc

[More info](https://usermanuals.musicxml.com/MusicXML/Content/CT-MusicXML-score-part.htm)

# Examples
```julia
Scorepart(name = "Piano",midiinstrument = Midiinstrument(), id = "P1")
```
"""
@aml mutable struct Scorepart "score-part"
    # identification
    name::String, "part-name"
    nameDisplay::UN{String} = nothing, "part-name-display"
    abbreviation::UN{String} = nothing, "part-abbreviation"
    abbreviationDisplay::UN{String} = nothing, "part-abbreviation-display"
    scoreinstrument::UN{Scoreinstrument} = nothing, "score-instrument"
    mididevice::UN{Mididevice} = nothing, "midi-device"
    midiinstrument::Midiinstrument, "midi-instrument"
    id::String, a"id"
end
################################################################
"""
    Partlist

# Arguments
```julia
- # TODO partgroup
- scoreparts::Vector{Scorepart}, "score-part"
```

Holds scoreparts and partgroup.

See [`Scorepart`](@ref) doc

[More info](https://usermanuals.musicxml.com/MusicXML/Content/EL-MusicXML-part-list.htm)

# Example
Partlist([
    Scorepart(name = "Piano 1", midiinstrument = Midiinstrument(), id = "P1"),
    Scorepart(name = "Piano 2", midiinstrument = Midiinstrument(), id = "P2"),
])
"""
@aml mutable struct Partlist "part-list"
    # TODO partgroup
    scoreparts::Vector{Scorepart}, "score-part"
end
################################################################
"""
    Key

# Arguments
```julia
- # cancel
- fifths::Int8, "~"
- mode::UN{String} = nothing, "~", modeCheck
- # key-octave
```
A type to hold key information for a measure in musicxml file.

The key element represents a key signature. Both traditional and non-traditional key signatures are supported. The optional number attribute refers to staff numbers. If absent, the key signature applies to all staves in the part.

fifth: number of flats or sharps in a traditional key signature. Negative numbers are used for flats and positive numbers for sharps, reflecting the key's placement within the circle of fifths

mode:  major, minor, dorian, phrygian, lydian, mixolydian, aeolian, ionian, locrian, none

[More info](https://usermanuals.musicxml.com/MusicXML/Content/CT-MusicXML-key.htm)

# Example
```julia
Key(fifths = 0, mode = "major")
```
"""
@aml mutable struct Key "key"
    # cancel
    fifths::Int8 = 0, "~"
    mode::UN{String} = nothing, "~", modeCheck
    # key-octave
end

modeCheck(x) = in(x, Ref("major", "minor", "dorian", "phrygian", "lydian", "mixolydian", "aeolian", "ionian", "locrian", "none"))
################################################################
"""
    Clef

# Arguments
```julia
- sign::String, "sign"
- line::Int16, "line"
- octave::UN{Int64} = nothing, "clef-octave-change"
```

A type to hold clef information for a measure in musicxml file.

Clefs are represented by a combination of sign, line, and clef-octave-change elements. Clefs appear at the start of each system unless the print-object attribute has been set to "no" or the additional attribute has been set to "yes".

sign: The sign element represents the clef symbol: G, F, C, percussion, TAB, jianpu, none. [More info](https://usermanuals.musicxml.com/MusicXML/Content/ST-MusicXML-clef-sign.htm)

line: Line numbers are counted from the bottom of the staff. Standard values are 2 for the G sign (treble clef), 4 for the F sign (bass clef), 3 for the C sign (alto clef) and 5 for TAB (on a 6-line staff).

octave: The clef-octave-change element is used for transposing clefs. A treble clef for tenors would have a value of -1.

[More info](https://usermanuals.musicxml.com/MusicXML/Content/CT-MusicXML-clef.htm)

# Example
```julia
Clef(sign = "TAB")
```
"""
@aml mutable struct Clef "clef"
    sign::String, "sign"
    line::Int16, "line"
    octave::UN{Int64} = nothing, "clef-octave-change"
end

# Standard values
function Clef(; sign::String)
    if sign == "G"
        line = 2
    elseif sign == "F"
        line = 4
    elseif sign == "C"
        line = 3
    elseif sign == "TAB"
        line = 5
    end
    return Clef(sign = sign, line = line)
end
################################################################
"""
    Transpose

# Arguments
```julia
- diatonic::Int8 = 0, "~"
- chromatic::Int8 = 0, "~"
- octaveChange::UN{Int8} = nothing, "octave-change"
- double::UN{Bool} = nothing, "~"
```

A type to hold transpose information for a measure in musicxml file.

If the part is being encoded for a transposing instrument in written vs. concert pitch, the transposition must be encoded in the transpose element using the transpose type.

diatonic: The diatonic element specifies the number of pitch steps needed to go from written to sounding pitch. This allows for correct spelling of enharmonic transpositions.

chromatic: The chromatic element represents the number of semitones needed to get from written to sounding pitch. This value does not include octave-change values; the values for both elements need to be added to the written pitch to get the correct sounding pitc

octaveChange: The octave-change element indicates how many octaves to add to get from written pitch to sounding pitch.

double: If the double element is present, it indicates that the music is doubled one octave down from what is currently written (as is the case for mixed cello / bass parts in orchestral literature).

[More info](https://usermanuals.musicxml.com/MusicXML/Content/EL-MusicXML-transpose.htm)

# Example
Transpose() # default values
"""
@aml mutable struct Transpose "transpose"
    diatonic::Int8 = 0, "~"
    chromatic::Int8 = 0, "~"
    octaveChange::UN{Int8} = nothing, "octave-change"
    double::UN{Bool} = nothing, "~"
end
################################################################
"""
    Time

# Arguments
```julia
- beats::Int8 = 4, "~"
- beatType::Int8 = 4, "beat-type"
- # interchangeable
```

Time signatures are represented by the beats element for the numerator and the beat-type element for the denominator.

[More info](https://usermanuals.musicxml.com/MusicXML/Content/EL-MusicXML-time.htm)


```julia
Time(beats=6, beattype = 8)
```
"""
@aml mutable struct Time "time"
    beats::Int8 = 4, "~"
    beattype::Int8 = 4, "beat-type"
    # interchangeable
end
################################################################
"""
    Attributes

# Arguments
```julia
- divisions::Int16, "~"
- key::Key, "~"
- time::Time, "~"
- staves::UN{UInt16} = nothing, "~"
- instruments::UN{UInt16} = nothing, "~"
- clef::UN{Clef} = nothing, "~"
- transpose::UN{Transpose} = nothing, "~"
```

A type to hold the data for the attributes of a musicxml measure

The attributes element contains musical information that typically changes on measure boundaries. This includes key and time signatures, clefs, transpositions, and staving. When attributes are changed mid-measure, it affects the music in score order, not in MusicXML document order.

key: See [`Key`](@ref) doc

divisions: Musical notation duration is commonly represented as fractions. The divisions element indicates how many divisions per quarter note are used to indicate a note's duration. For example, if duration = 1 and divisions = 2, this is an eighth note duration. Duration and divisions are used directly for generating sound output, so they must be chosen to take tuplets into account. Using a divisions element lets us use just one number to represent a duration for each note in the score, while retaining the full power of a fractional representation. If maximum compatibility with Standard MIDI 1.0 files is important, do not have the divisions value exceed 16383.

time: See [`Time`](@ref) doc

staves: The staves element is used if there is more than one staff represented in the given part (e.g., 2 staves for typical piano parts). If absent, a value of 1 is assumed. Staves are ordered from top to bottom in a part in numerical order, with staff 1 above staff 2.

instruments: The instruments element is only used if more than one instrument is represented in the part (e.g., oboe I and II where they play together most of the time). If absent, a value of 1 is assumed.

clef: See [`Clef`](@ref) doc

[More info](https://usermanuals.musicxml.com/MusicXML/Content/EL-MusicXML-attributes.htm)
"""
@aml mutable struct Attributes "attributes"
    divisions::Int16, "~"
    key::Key, "~"
    time::Time, "~"
    staves::UN{UInt16} = nothing, "~"
    instruments::UN{UInt16} = nothing, "~"
    clef::UN{Clef} = nothing, "~"
    transpose::UN{Transpose} = nothing, "~"
end
################################################################
"""
    Pitch

# Arguments
```julia
- step::String, "~"
- alter::UN{Float16} = nothing, "~"
- octave::Int8, "~"
```

Holds musicxml pitch data. MusicXML pitch data is represented as a combination of the step of the diatonic scale, the chromatic alteration, and the octave.

Use step, alter, octave = pitch2xml(pitch) and  pitch = xml2pitch(step, alter, octave)
for conversions between midi pitch and musicxml pitch

"""
@aml mutable struct Pitch "pitch"
    step::String, "~"
    alter::UN{Float16} = nothing, "~"
    octave::Int8, "~"
end
################################################################
"""
    Rest

# Arguments
```julia
- rest::Bool
- aml::Node
```

The rest element indicates notated rests or silences. Rest elements are usually empty, but placement on the staff can be specified using display-step and display-octave elements. If the measure attribute is set to yes, this indicates this is a complete measure rest.

The display-step-octave group contains the sequence of elements used by both the rest and unpitched elements. This group is used to place rests and unpitched elements on the staff without implying that these elements have pitch. Positioning follows the current clef. If percussion clef is used, the display-step and display-octave elements are interpreted as if in treble clef, with a G in octave 4 on line 2. If not present, the note is placed on the middle line of the staff, generally used for a one-line staff.

"""
@aml mutable struct Rest sc"rest"
    measure::UN{YN} = nothing, a"~"
    dispStep::UN{String} = nothing, "display-step"
    dispOctave::UN{Int8} = nothing, "display-octave"
end
################################################################
"""
    Unpitched

# Arguments
```julia
- unpitched::Bool
- aml::Node
```

The unpitched type represents musical elements that are notated on the staff but lack definite pitch, such as unpitched percussion and speaking voice.
"""
@aml mutable struct Unpitched sc"unpitched"
    measure::UN{YN} = nothing, a"~"
    dispStep::UN{String} = nothing, "display-step"
    dispOctave::UN{Int8} = nothing, "display-octave"
end
################################################################
"""
    NoteX

# Arguments
```julia
- pitch::UN{Pitch} = nothing, "~"
- rest::UN{Rest} = nothing, "~"
- unpitched::UN{Unpitched} = nothing, "~"
- duration::UInt, "~"
- # voice
- type::UN{String} = nothing, "~"
- accidental::UN{String} = nothing, "~"
- tie::UN{String} = nothing, "~" # start, stop, nothing TODO
```

Notes are the most common type of MusicXML data. The MusicXML format keeps the MuseData distinction between elements used for sound information and elements used for notation information (e.g., tie is used for sound, tied for notation). Thus grace notes do not have a duration element. Cue notes have a duration element, as do forward elements, but no tie elements. Having these two types of information available can make interchange considerably easier, as some programs handle one type of information much more readily than the other.

pitch: See [`Pitch`](@ref) doc

duration : See [`MIDI.Note`] (@ref) doc

type: Type indicates the graphic note type, Valid values (from shortest to longest) are 1024th, 512th, 256th, 128th, 64th, 32nd, 16th, eighth, quarter, half, whole, breve, long, and maxima. The size attribute indicates full, cue, or large size, with full the default for regular notes and cue the default for cue and grace notes.

accidental: The accidental type represents actual notated accidentals. Editorial and cautionary indications are indicated by attributes. Values for these attributes are "no" if not present. Specific graphic display such as parentheses, brackets, and size are controlled by the level-display attribute group. Empty accidental objects are not allowed. If no accidental is desired, it should be omitted. sharp, flat, natural, double sharp, double flat, parenthesized accidental

tie:

[More info](https://usermanuals.musicxml.com/MusicXML/Content/CT-MusicXML-note.htm)
"""
@aml mutable struct NoteX "note"
    pitch::UN{Pitch} = nothing, "~"
    rest::UN{Rest} = nothing, "~"
    unpitched::UN{Unpitched} = nothing, "~"
    duration::UInt, "~"
    # voice
    type::UN{String} = nothing, "~"
    accidental::UN{String} = nothing, "~"
    tie::UN{String} = nothing, "~" # start, stop, nothing TODO
end
################################################################
"""
    Measure

# Arguments
```julia
- attributes::UN{Attributes} = nothing, "~"
- notes::Vector{NoteX}, "note"
```

A type to hold the data for a musicxml measure

attributes: See [`Attributes`](@ref) doc
notes: See [`NoteX`](@ref) doc

"""
@aml mutable struct Measure "measure"
    attributes::UN{Attributes} = nothing, "~"
    notes::Vector{NoteX}, "note"
end
################################################################
"""
    Part

# Arguments
```julia
- measures::Vector{Measure}, "measure"
- id::String, a"~"
```

A type to hold the data for a part in musicxml file.

measures: See [`Measure`](@ref) doc

"""
@aml mutable struct Part "part"
    measures::Vector{Measure}, "measure"
    id::String, a"~"
end
################################################################
"""
    Scorepartwise

# Arguments
```julia
- # TODO identification
- # TODO defaults
- partlist::Partlist, "part-list"
- parts::Vector{Part}, "part"
```

A type to hold the data for a musicxml file.
"""
@aml mutable struct Scorepartwise "score-partwise"
    # TODO identification
    # TODO defaults
    partlist::Partlist, "part-list"
    parts::Vector{Part}, "part"
end
################################################################

@aml mutable struct Doc xd""
    scorepartwise::Scorepartwise, "score-partwise"
end
################################################################


end
