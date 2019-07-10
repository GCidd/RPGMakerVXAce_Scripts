# Persona System

This script implements the Persona System from the Persona games (specifically Persona 4).
Quoting from the Megami Tensei Wiki:  

> A Persona is a manifestation of a Persona User's personality in the Persona series, referred to as a "mask" for an individual to use to face hardship.

In this system, you can use Personas to fight enemies. Each character can equip one of those Personas which, as a result, increases all of the user's parameters. 
In the original game, the characters have no parameters nor skills and all those depend on the persona they have currently equipped. In this script you can choose the percentages of the parameters contributed by the user and the Persona while, also, use the skills of the currently equipped Persona.
Following the original game's system, Personas can only learn a specific number of skills. When they try to learn a new one, they have to forget an old one (or skip learning it).

Personas can be acquired with two different methods:
  * By fusing two (or three) Personas to create a new one
  * During the Shuffle Time
 
Compared to the original game's fusion system, this script implements a quiet simpler Fusion System, for ease of use. It is divided into a Normal Fusion (two Personas) and a Special Fusion (three Personas). When fusing Personas, the resulting Persona will gain a bonus EXP depending on the Arcana rank (explained later) and the Personas' level used in the Fusion.

Shuffle Time, happens after every battle and if the enemy has dropped any Persona cards. Along with the Persona cards, enemies drop Blank cards and Penalty cards. There are two different Shuffle methods: Rotating cards and Memory match. During the first method, the cards rotate either horizontally, diagonally or a combination of both. During the Memory match, the player has to match two cards together, with a maximum number of attempts. If the player has picked a Blank card during the Shuffle Time, nothing will happen (no Persona will be acquired), but if they pick a Penalty card, they will lose all battle rewards (no EXP or Gold will be acquired).

Additionally, Personas have classes called Arcanas. Quoting (again) the Megami Tensei Wiki:

> Each Social Link represents a single Arcana, and raising a particular Social Link increases the experience bonus the protagonists receive when they fuse Personas of that Arcana. By completing a Social Link, it unlocks the ultimate Persona of that Arcana.

Each Arcana has its own rank and when it reaches a specific one a Persona of that Arcana can evolve into a stronger one (you can choose which Personas can evolve and at which rank).
You can check all the available Arcanas through the Social Link option in the main menu, along with its rank, its individual Social Links and their description. You can choose, for each Social Link, which actors it is consisted of.

# Screenshots & Videos

![Social_Links_2](https://imgur.com/cLYSBmV.png)

[More screenshots](https://imgur.com/a/6qvb88P)

[Videos](https://www.youtube.com/playlist?list=PLBpfffVr62KCmPbw9iQxcHB5Uq-gfOUnk)

# Instructions and Demo

Instructions on how to use, setup and change options are present inside the script. Those cover all the available tags that can be used to setup the system, along with all the scene and script calls you can make and the explanation of each system.
The script goes above Main and bellow Materials.
There are many option settings you can change in this script, which are not covered in the instructions and are located at the beginning of the script, for each "sub-system" separately.

# Credits

* First and foremost [demifiend700 who requested this script](https://forums.rpgmakerweb.com/index.php?threads/persona-system-for-vx-ace-big-script-willing-to-trade.92260/) ~~(more than a year ago LUL)~~
* Arthellinus for his [Game Mechanics/Persona Database](https://web.archive.org/web/20131219130533/http://www.gamefaqs.com/ps2/945498-shin-megami-tensei-persona-4/faqs/54981)
* [Megami Tensei Wiki](https://megamitensei.fandom.com/wiki/Megami_Tensei_Wiki)

# TODO

- [x] Upload to github
- [ ] Implement the fusion result as it is in the original game, which can become a bit confusing when using it (regarding the determination of the results). 
- [ ] Implement Arcana effects that can happen after battles.
- [ ] Implement "slot machine" Shuffle Time method.
- [ ] Bug fixes, if there are (there probably are ~~I hope not~~) 

