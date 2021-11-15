Quick Access Clipboard
======================

Portable installation
---------------------

Follow these instructions if you want to use Quick Access Clipboard in "portable" mode. This
will, for example, allow you to run it from an external drive or USB key. You’ll just
need to unzip a file.

1) Download quickaccessclipboard.zip.

2) There is no software to install. Just extract the zip file content to the folder of your choice.

Note: It is recommended not to install Quick Access Clipboard in system-protected folders like those
under "C:\Program Files". This could prevent QAC from saving your configuration.

3) Run the .EXE file from this folder (choose the file QuickAccessClipboard-32-bit.exe or
QuickAccessClipboard-64-bit.exe depending on your system). Quick Access Clipboard will create and update
the quickaccessclipboard.ini file in this folder. See Quick Access Clipboard is a Portable App, below.

4) At your convenience, create a shortcut on your Desktop or your Start menu or select
"Run at startup" in the Tray menu to launch Quick Access Clipboard automatically at startup.

See also the file UPDATE_INSTRUCTIONS.TXT for the best way to install a new version over an
existing portable installation.


Update instructions
-------------------

1) Download the new version zip file under Portable installation on this site home page.

2) Quit your current version of Quick Access Clipboard: right-click the Quick Access Clipboard icon in the
System Tray and choose Exit Quick Access Clipboard. If you don't before executing the next step, QAC
will not be updated.

3) Extract the new version zip file content in the folder where your current version is installed,
*overwriting* all existing content. Do not worry: this will NOT overwrite your settings in
QuickAccessClipboard.ini because this files is not part of the ZIP file. All your settings
will be preserved.

4) For your information, a text file was added to your folder with, in its name, the version of the
installed version (for example: QAC-v1_0_1.txt). You can delete this file as it is not required to
run QAC.

5) Restart Quick Access Clipboard by double-clicking the executable (.EXE) file of the new version.
Choose the 32-bit or 64-bit version depending on your system.

If you enabled this "Run at startup" option, the shortcut in your Startup folder will be updated
to launch the new version when you will restart Windows.


Quick Access Clipboard is a Portable App
------------------------------------

A portable application (portable app), sometimes also called standalone, is a program designed
to run on a compatible computer without being installed in a way that modifies the computer’s
configuration information. This type of application can be stored on any storage device, including
internal mass storage and external storage such as USB drives and floppy disks – storing its
program files and any configuration information and data on the storage medium alone
(source: Wikipedia).

Specifically, Quick Access Clipboard does not write any information in any system or temporary Windows
folder. Running the .EXE file launches Quick Access Clipboard in its current directory. That’s it!
The app creates a temporary subdirectory (named _temp) to store small images and language files
required at run time. This folder is deleted when the app quits. The only permanent file created
by Quick Access Clipboard is the QuickAccessClipboard.ini file containing your favorites and options.

The file QuickAccessClipboard.ico included in this zip file contains the app's icon that you can use to
customize the Quick Access Clipboard's folder or shortcut.


---------------------------------------------------------
Quick Access Clipboard – Copyright (C) 2021- Jean Lalonde

Jean Lalonde, support@quickaccesspopup.com
http://Clipboard.QuickAccessPopup.com
