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
(done) tab bar should look better will need to look into implementations, 1 it takes too much space, 2nd i think it should be an overlay on top of the terminal or others   to save space and stuff ya know... it is so big and is useless currently

# UI / Visual 
(done) monochrome theme :o
(done) monochrome themes failure color is unreadable -> added onFailure/failureText and proper contrasting button colors
(done) Themes define failureText, on-surface colors, and border radius (monochrome has sharp radius=2/0, other themes radius=8)
(done) Make entire UI juicy and playful:
  - Reusable JoyAnimation, JoyWobble, JoyPressArea components
  - Drag & Drop reorderable tabs in ThemedTabBar with dynamic slot displacement & spring bounce
  - File/folder Drag & Drop target overlay on Main.qml
  - Bouncy press squish & hover pop on ThemedButton and cards
  - Breathing glowing live pulse on running server cards
  - OutBack spring popup entrance animations
(done) Server closepopup doesn't tell it's closing -> made ServerRunner::shutdown asynchronous/non-blocking so GUI updates smoothly with animated closing indicator and force-close fallback option


# Performance
it uses 1%  CPU and 300MB ram (js grassy app) not counting the server it runs 
resizing the ui is really laggy :/


# WINDOWS (5th class citizen) [kind of done]
- java support (and windows folders)
- windows server download and running cuz it aint posix :(
- port and ip
- run.bat
