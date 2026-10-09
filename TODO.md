# TODO

## Server settings popup

(done) why is dropdown so dependent upon the position??? also the user won't probably add memory in Mb so just tell him to add memory in GB (create run.sh/run.bat is handled on save) also does x ruin all changes??? and it shouldnt take G as input run script controls should be on top asking for min and max ram
(done?) Shorcuts don't work... editing serverProperties doesn't refresh servers... calling from the saveServerProperties Function crashes the UI :/

(fixed) stupid ai started using snake_case in ServerWindow and CustomLabelProgressBar

(working on it) shortcuts (for UI) ?
(done) The serverRunner and Terminal (don't display the cmd executed like ./run.sh or ./run.bat) or smth
(done)also they don't tell which port they are using which should be on the top :3
(bruh, for later) the port thingi in ServerWindow has diff size compared to Progress Bars TT
(done)Icons get blurry when scaled
(done) customVer of Java support (other than /usr/bin/java) for mods

(done) downloading mcServer and fabricServer

(done) forge??
- https://maven.minecraftforge.net/net/minecraftforge/forge/{MC_VERSION}-{FORGE_VERSION}/forge-{MC_VERSION}-{FORGE_VERSION}-installer.jar
- https://maven.minecraftforge.net/releases/net/minecraftforge/forge/maven-metadata.xml
- example construction: https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.26/forge-1.20.1-47.4.26-installer.jar

(done) ctrl+f support inside ServerRunner :O (since its just html) - (a bottom-right thingi opens up which lets u search)
(done) closing the serverRunnerWindow before quiting the serve will give a popup Closing the server safely, press this button to force close it


deleting session.lock if its corrupted
filtering in Main.qml server delegates by types forge/fabric/official
tabs in server window to display players.. ban them even... js what other server runners allow u to do.
(done) tab bar should look better will need to look into implementations, 1 it takes too much space, 2nd i think it should be an overlay on top of the terminal or others
  to save space and stuff ya know... it is so big and is useless currently

Server closepopup doenst tell its closing cuz it doesnt update :(

# Performance
it uses 1%  CPU and 300MB ram (js grassy app) not counting the server it runs 
resizing the ui is really laggy :/


(done) monochrome theme :o
- monochrome themes failure color is unreadale

# WINDOWS (5th class citizen) [kind of done]
- java support (and windows folders)
- windows server download and running cuz it aint posix :(
- port and ip
- run.bat
