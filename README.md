# Localizations 0.2

Localizations is an OS X app that manages your Xcode project localization files (.strings).

It focuses on keeping .strings files in sync with the code (NSLocalizedString) and the UI files (storyboards & xib). 

It is the missing link that prevents obsolete keys to persists in .strings files and newly introduced to be missed.

You will find Localizations particularly useful when working on a new version of your app or when adding a full new language to your app.

The removal of obselete translations strings will save you money in translations costs.
 
## How it works
1/ Choose a root folder containing an xcode project, source code (.h, .m and/or .swift files), ui files (.xib and/or .storyboard files) and eventually existing .string files in their *.lproj folders.

2/ Localization dives in the file system to find all of these files and store both their content and locations

3/ It regenerate fresh .strings files using ibtool and genstrings and store the generated files in a cache directory (automatically generated inside /tmp

4/ It compares the existing and the new files and creates a diff

5/ It shows the diff in the detail view

**Important: Before saving changes, you should stash your local changes and work with a fresh commit so you can revert the results eventually**

6/ If you likes the changes, you can review and save them

7/ Localizations will erase, overwrite and create all necessary files and folders.

By default, all brand new files will be created as a development language (picked from the pbxproj) folder.

## Intentions & License
When it comes to handle your string files, Xcode has been leaving a void which is yet to be filled.
My intentions with this app are to fill this void and, by making it open source, enable developers to alter it up to the very need their specific situation may present. It is my hope that users of the app will share their improvements so that all can be enjoying them.

This project is completely open source and under the MIT license. So enjoy and have fun. For full details please see license.md

## Screenshots
![Screenshot](https://github.com/athiercelin/Localizations/blob/master/Screenshots/localization-0.1-4.png?raw=true)
![Screenshot](https://github.com/athiercelin/Localizations/blob/master/Screenshots/localization-0.1-5.png?raw=true)

## Special Thanks
[Sebastien Del Grosso](http://sebastiendelgrosso.myportfolio.com) - For the app icon.

## Questions & Contact
If you have any questions, reach out to me on twitter [@athiercelin](https://twitter.com/athiercelin) or drop an issue on github.