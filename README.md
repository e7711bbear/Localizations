#Localizations 0.1

Localizations is an OS X app that manages your Xcode project localization files (.strings).

It focuses on keeping .strings files in sync with the code (NSLocalizedString) and the UI files (storyboards & xib). 

It is the missing link that prevents obsolete keys to persists in .strings files and newly introduced to be missed.

You will find Localizations particularly useful when working on a new version of your app or when adding a full new language to your app.

The removal of obselete translations strings will save you money in translations costs.
 
## How it works
Starting from a root folder - typically the project folder - it collects existing localizations data, re-generate new data using genstrings and ibtool, compute a diff and upon request, publishes the changes.

## Intentions & License
When it comes to handle your string files, Xcode has been leaving a void which is yet to be filled.
My intentions with this app are to fill this void and, by making it open source, enable developers to alter it up to the very need their specific situation may present. It is my hope that users of the app will share their improvements so that all can be enjoying them.

This project is completely open source and under the MIT license. So enjoy and have fun. For full details please see license.md

##Screenshots
![Screenshot](https://github.com/athiercelin/Localizations/blob/master/Screenshots/localization-0.1-1.png?raw=true)

## Special Thanks
[Sebastien Del Grosso](http://sebastiendelgrosso.myportfolio.com) - For the app icon.