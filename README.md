# Speesm
A tool for analysis-manipulate-synthesize speech. It is written in MATLAB and can be used as a graphical user interface (GUI) or as a code script.

# Installing
Just clone this repository

# Using
Open the gui_main.m file present in ./code/ directory.
Run this file in MATLAB. This will pop a GUI with pushbuttons corresponding to the following.
- Analyze
- Time/Pitch-Scaling
- Morphing
To use any of these, click the pushbutton and "Load File (or trial)" and follow this by "Get F0 track".
Rest is supposed to be self-explanatory in the GUI. But do create an issue if you something is not clear.

The tool also makes use of the vocoder https://github.com/HidekiKawahara/legacy_STRAIGHT to obtain pitch estimates.
This is bundled in the current repository (with its license file).

