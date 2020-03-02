# PathsOfJjro
Paths of Jjro is a 3D game based on Bungie's Marathon, made by the community for the community. Open sourced.
Made using Joyeuse Framework for Godot. The code itself is under MIT License. 

As the game assets are based on the original assets, we must include the following licensing information, which is a modified version of the one AlephOne uses for the marathon data


# Building the game

This section will teach you how to write code and mantain the project:

## Cloning the project
Currently the project is LFS enabled, so you will have to download Git-LFS. 
This project also uses a modular apporach to handling code and repos, so you will have to clone the project like this:
`git clone --recursive -j4 git://github.com/RiseRobotRise/PathsOfJjaro.git`
Avoid the -j4 flag if your bandwidth is low. 

Once the game is cloned you must change your branch to the development branch "3.1"

## How the project is structured
As the game is made in the Godot Engine, we will refer to the root directory as `res://`
Now you should see the Joyeuse submodule under `res://joyeuse`, the code there corresponds to https://github.com/RiseRobotRise/JoyeuseCodeBase
The codebase contains different classes and subsystems. Heavier development will occur here, with the only content going directly to Paths of Jjaro repo being the quite specific one. 

You should also find another submodule at `res://assets/Characters` that can be found at https://github.com/RiseRobotRise/Characters there are stored the characters for the game as both 3d models that you can import with any editor as well as their in-engine implementations. 

## Other relevant projects

There are multiple other project under development to aid the community to create content around Paths Of Jjaro and any other Joyeuse based games.

### Character Studio
The character studio aims to provide easy to use tools to create complex behaviors and AI characters, as well as set their hitboxes, their ragdolls and sounds they may emmit, pack it all into one single file and get re-distributed easily. 
You can find the project here: https://github.com/RiseRobotRise/CharacterStudio
 
## World Shaper
This is a level editor with a layered approach, so you can easily use the multiple ways that Godot allows for creating game levels. Qodot support is planned. 
The project can be found at: https://github.com/RiseRobotRise/WorldShaper

## Universal Godot Controller
This is an utility pluggin for any godot game, that allows Couch-gaming with a single PC and multiple android devices. 
 https://github.com/RiseRobotRise/UniversalGodotController

# Marathon game content non-license

Unfortunately, Bungie has not released Marathon game content under a formal, unambiguous content license. To our knowledge, Bungie has not blocked any noncommercial distribution of these assets, but the Marathon series is not considered abandonware and Bungie retains the right to control its distribution and use.


## History

In 2000, Bungie released the Marathon 2 source code under the GPL 2 license, which led to the Aleph One project. The game content was not part of this release; the games were still commercially available at the time.

In 2005, Bungie made the Marathon game content freely available, at [trilogyrelease.bungie.org][1]. No content license was posted. The Frequently Asked Questions page includes this statement:

> **Wow... can I do whatever I want with this stuff?**

> NO. Bungie still holds the copyrights to these files. They're allowing them to be distributed for free (mostly because you can't buy them any more) - but they're still Bungie's intellectual property. You can't, for example, sell them.

In 2011, Bungie released the [Marathon Infinity source code][2] under the GPL 3 license. The source code archive also included a CC-BY-NC-SA 3.0 license, but its scope is unclear. It may only cover the design documents and other non-code files present alongside the source, and not the game data (which was not part of the archive).

In late 2011, Aleph One began distributing Marathon game content bundled with Aleph One binaries, in the spirit of the Trilogy Release page's "free distribution" aim. Bungie [announced these bundled downloads][3] on their company site, so Bungie was aware of and tacitly approved Aleph One's redistribution of the game content.

[1]: http://trilogyrelease.bungie.org/
[2]: http://infinitysource.bungie.org/
[3]: http://halo.bungie.net/news/content.aspx?cid=31991


