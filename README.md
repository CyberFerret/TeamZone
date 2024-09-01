# TeamZone

TeamZone is an app designed to help you keep track of your remote team timezones.  Instantly see at a glance what the current time is for anyone in your team before you ping them with a message or task.

You can set up as many different team members (or offices) in multiple locations, rearrange them on the list, and see their local time (and what day it is for them) in 12 or 24 hour format.

### About

TeamZone is a Swift app designed to run as a menu bar agent on macOS.  (Sorry, this app is Mac only at this stage).

Click on the menu bar icon to open the list of team members.  You can also quit the app from here by clicking the 'gear' icon in the bottom right of the popup window and choosing 'Quit'.  This will unload the app from memory.

TeamZone has been designed to be super efficient, and only takes up around 60MB of RAM and much less than 1% of your CPU.  It stores all information locally on your machine and does not sync or reach out to the cloud for anything, so you can be sure that your privacy is respected (although it does mean that if you are running the app on multiple machines, you will have to set up your team members on each machine to match).

### Installation

At this point in time, there is no downloadable installer for TeamZone.  You will have to pull the Swift code into a folder on your local Mac, and build the project using XCode.

Please note that you will have to install the `SQLite.swift` package in XCode to be able to compile this app.

### Development

TeamZone is fairly feature complete for now, but I will consider doing more development on this app in the future.  If you have any feature requests, please feel free to open an issue on GitHub.

Please also note that 90% of this code was developed using the Cursor AI coding assistant.  I have found this to be an extremely useful tool for rapidly developing this app.

It was an interesting move to use AI to help me get familiar with Swift coding.  There were many challenges using AI, but in the end, it did manage to do a lot of the heavy lifting for me.

### Contributions

I welcome any contributions to this app.  If you have any suggestions for improvements, please feel free to open an issue or a pull request on GitHub.

### License

This app is licensed as a free to use learning tool.  Please feel free to use it as you see fit, but under no circumstances are you permitted to use any of the code to create a commercial app that you charge money for.
