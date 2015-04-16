100% Checklist:

Created by Lighnat0r
Contact me at Lighnat0r@gmail.com for any questions, bugs, suggestions or find me in the speedrunslive.com #gta irc channel. You can also message me on Twitch (www.twitch.tv/Lighnat0r)

General Information:

This program will create a customizable output window or file output showing which of the requirements for 100% you have completed while running one of the supported games.
You have the option of showing the requirements on the output window in either text or icon form.
Start the program and it will update automatically (if the game is already running) or the program will wait until the game is started and then update automatically. It will work with both loading a game and starting a new game.

V1.52 Updates:
Added support for the Japanese No-CD version of GTA Vice City



List of supported games:
GTA Vice City
GTA San Andreas
GTA III

Contact me if you want support for another game, but keep in mind that this is not a trivial process so I won't make any promises.


Compatibility:

GTA Vice City:
The program is currently compatible with the following game versions:
* Version 1.0 
* Version 1.1 
* Version 1.1 (Steam)
* Version Retail Japanese
It will automatically detect which version is running.
Please contact me if if you have any version related errors so I can make the script compatible. 

GTA San Andreas:
The program is currently compatible with the following game versions:
* Version 1.0 EU/AUS
* Version 1.0 US
* Version 1.0 Downgraded/Hoodlum No-CD
* Version 1.01 EU/AUS
* Version 1.01 US
* Version 1.01 Downgraded/Deviance No-CD
* Version 1.01 (Steam (DE?))
* Version 2.0 EU/AUS
* Version 3.0 (Steam)
It will automatically detect which version is running.
Because I don't have access to the following versions, they are not yet supported (contact me if you have one of these so I can add support):
* Version 1.0 DE
* Version 1.01 DE
* Version 2.0 US
* Version 2.0 DE

GTA III:
The program is currently compatible with the following game versions:
* Version 1.0 (No-CD)
* Version 1.1 (No-CD)
* Version 1.1 (Steam)
It will automatically detect which version is running.
I don't have access to a CD, so I can't test if the retail 1.0 and 1.1 also work or not (contact me if you have one of these so I can add support).



Known Issues:
* 100% transparency will make everything that has the same colour as the background transparent. (For this reason, when using transparency don't set the background colour 
to the same as the text colour). This could also make (parts of) icons transparent.
* If you resize the window in OBS, there will be a one pixel border around the text, in a colour very similar to the background colour. To counter this, 
change the background colour to something more to your liking (not the same as text colour, see the issue above). Using the right background colour might even make the text 
even more readable. This issue seems to be specific to OBS, not sure if I can do anything to solve it.
* When using transparency the preview icon in Windows Peek and the alt-tab menu shows a box in the background colour instead of what the program actually looks like.
* The semi-transparent background might glitch out if you're restarting the program while it is inactive. The only solution I know of is to make the window always on top and I don't want to do that.



Created by Lighnat0r
Contact me at Lighnat0r@gmail.com for any questions, bugs, suggestions or find me in the speedrunslive.com #gta irc channel. You can also message me on Twitch (www.twitch.tv/Lighnat0r)






Credits to geekdude for the custom memory function
Credits to Laszlo for the custom hex to float function

Ideas:

* Add option to change text colour depending on how close it is to the total required to more easily spot what still needs to be done.
	Possibly make completed requirements disappear (not preferable) or show them greyed out.
* If one of the supported games is running, automatically preselect it on the welcome screen.
* Option to show the main storyline as one item. (Make collapsable categories which are clickable and will fold in/out)
* Mode with percentage and the last X completed items.
* More options for customizable gui.
* Allow clicking on goals to monitor in more detail (e.g. show the separate missions)
* Show mouse-over descriptions in the settings menu.
* Show the requirement name as a tooltip if hovering the mouse over an icon.
* Save the custom colours created in the choose colour dialogs in the settings window to the settings file so they can be recalled if the program is restarted.
* If the background is made 100% transparent, prevent that everything of that colour in the window becomes transparent (i.e. also text/icons etc.).
* Add a possibility to have the output up on a different (connected obv.) pc.
* Items on the output window should not be selectable.
* When using transparency make the preview icon in Windows Peek and the alt-tab menu show what the program actually looks like instead of a box in the background colour like it shows now.
* The semi-transparent background might glitch out if you're restarting the program while it is inactive. Always-on-top fixes this but is not desirable.
* Make the buttons also adhere to the colours in the settings.


Old version updates:

V1.51 Updates:
Fixed a bug which caused the text explaining where the file output is stored to not follow the text colour selected in the settings menu.
Using transparency will no longer ruin the layout of the welcome window.
Due to limitations in Windows, using a filename for the checklist of over 198 characters means that file output cannot be used and custom settings cannot be saved. The checklist now recognizes this and notifies the user.
Fixed a bug where not all the text fit on the output window when using bold output, text output and only one column without transparency and having long requirements (such as Sunshine Autos Import Garage).

V1.5 Updates:
Added File Output as an option: Using this you can import the text from a file in a streaming program such as OBS so it doesn't require you to have the output window on a second monitor. Note that this doesn't log your progress, it only stores the most recent values. It is recommended to use this with "Percentage Only" mode as all the entries are stored in one column, though it is possible to store all requirements in the file.
You can select the refresh rate for the file output in the settings window (0-20 sec). This is in addition to the 0.5 second refresh rate which is in place for all output types.
Fixed the icon library not being removed on exit when the option "Skip exit confirmation" was enabled.
Fixed the choose colour dialog not correctly starting with the current colour selected.
Fixed the update window not pausing the rest of the program.

V1.43 Updates:
Because of compatibility issues, the program will detect if Avast is installed, in which case the auto-updater will NOT work.
If the program has issues accessing the game, it will try to restart with admin privileges which often solves the problem.

V1.42 Updates:
Added compatibility with another version of San Andreas (Version 1.01 (Steam (DE?))).

V1.41 Updates:
Fixed the Firefighter and Vigilante requirements for GTA:SA.
Fixed the auto-updater which was broken in V1.4

V1.4 Updates:
Major overhaul of the system which updates the output window. This improved performance and the system is now much more flexible for future updates.
Major overhaul of the system which creates the output window. The layout should look a lot cleaner with smaller margins. It will also be able to adapt to future additions more easily.
An option has been added to show "DONE" in the output window when a requirement is completed. This way it's more clear which requirements are still left.
An option has been added to skip the exit confirmation window when trying to close the program.
An option has been added to make the checklist always on top.
The output can now be alternated between text and icons without ever requiring a restart.
The readme can now be opened from within the program by right-clicking or by selecting it in the tray menu.
When using the 'change output type' button, the window will remain in the same position instead of snapping back to the centre of the screen.
Some changes to the layout of the settings menu.
Reduced the minimum value for maximum rows selectable in the settings menu from 10 to 4 for text mode and from 5 to 3 for icon mode.
Increased the maximum value for maximum rows selectable in the settings menu from 60 to 65 for text mode and from 25 to 30 for icon mode.
Reduced the maximum value for decimal places selectable in the settings menu from 15 to 5.
Removed refresh rate from the settings menu.
The Restore Default option in the settings menu will now also restore the default 'output window bold text' setting.
The welcome window now shows which version is running.
Improved all-round efficiency.
Added a ton of comments to the source file.
Fixed a bug which caused part of the output window not to be usable for moving it in text mode.
Fixed a bug where the program tried to identify GTA 3 as VC and vice versa.
Fixed a bug which caused some of the total required amounts to be wrong.
Fixed a bug that caused the current window to not disable when triggering the exit confirmation from the right click context menu.
Fixed the Paramedic requirement in GTA III 1.0 No-CD. For real this time.

V1.31 Updates:
The text in the output window can now be bolded in the settings menu.

V1.3 Updates:
The program will now automatically look for new updates.
Paramedic completion is now registered when using GTA III Version 1.0 (No-CD).

V1.2 Updates:
Fixed icon mode showing the wrong number for total required in some cases.
Percentage is now shown correctly when using GTA III Version 1.0 (No-CD).

V1.1 Updates:
GTA III Version 1.0 (No-CD) is now supported.

V1.0 Updates:
You can now select a transparency between 0 and 100%, instead of just on/off.
The width of the columns now changes automatically depending on the length of the text in there. This also fixes the percentage only mode, where only the first digit was visible. (Not happy with the resizing on icon mode yet, it works but it's not elegant)
Fixed several issues with percentage only mode.
Fixed the change output button.
Fixed resetting the output window after closing the game.
The text on the welcome screen will now also be bold when using transparency.
Changing the decimal places now actually works without having to restart the program.

Beta 4 Updates:
Added support for GTA 3, both text and icons.
The program now finds the game in a more reliable way. This should prevent false positives.
When using transparency, the text on the output window will be bold. This way it can be used as an overlay in streaming software and it improves readability in general. Tested on OBS, using colour key works.
Some icons for GTA SA and GTA VC are updated.
Removed the border around the output screen. This is currently disabled if transparency is on.
Right click now opens a menu to close/restart the program.
Fixed a bug where changing some of the settings had no effect.

Beta 3.1 Updates:
Text colour on the exit screen is no longer customizable.

Beta 3 Updates:
All settings can now be customized within the program.
Updated all Vice City icons, they are now better compatible with dark backgrounds as well as a lot of general improvements.
Added San Andreas icons. These are also compatible with dark backgrounds, as will all icons from now on.
Added more customization options: Transparency and Text smoothing.
Added percentage only mode.
Fixed a small bug in how the icons are loaded.

Beta 2 Updates:
Added support for GTA San Andreas (text only for now).
Various settings are now customizable in the settings file which is created when you start the program for the first time.
Added backend support for executing custom code per memory address making the program much more flexible.
The text output window will now also create new columns after the maximum number of rows is exceded.
The supported games list is now somewhat modular making it slightly easier to add new games.
The exit confirmation window now also follows the colour settings.

Beta 1.1 Updates:
Fixed a bug where the program didn't function after opening and closing the game.

Beta 1.0 Updates:
Initial release.
