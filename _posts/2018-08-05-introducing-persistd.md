---
layout: post
title: "Introducing persistd"
date: 2018-08-05 10:07:00 -0400
categories: programming
tags: windows workflow
image: /assets/images/projects/persistd.png
---

[persistd](https://github.com/dorukkilitcioglu/persistd) is a workspace/workflow manager made for multi-tasking developers. It allows you to persist your virtual desktop over multiple reboots. Automatically open all your relevant programs, and close them when you're done for the day. Never fear the Windows updates again.

## Background

I am always on the lookout for improving my workflow, be it for my personal projects or for work. And I do have a lot of [side projects](https://github.com/dorukkilitcioglu?tab=repositories), usually multiple projects going on at a time. As a user of [Windows Subsystem for Linux]({% post_url 2018-05-06-data-science-workflow-ubuntu-windows %}), one of my annoyances are those pesky Windows updates, that make you close all 5 of your virtual desktops that all have something different open.

There is also the Chrome situation, which, when given the chance, will happily consume half your RAM. This is particularly troubling when you are working on multiple projects, each with its own window.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/introducing-persistd/chrome-ram.png' alt="This isn't even its final form." width="70%"/>
        <figcaption><i>This isn't even its final form.</i></figcaption>
    </figure>
</div>
<br/>

## How persistd helps

Once properly set up, opening a project is as simple as

```
python persist.py <project_name>
```

What this does is open up a new Virtual Desktop, open up all supported programs that were running when you closed the project down, and move out of your way so that you can continue working on whatever you like.

Closing the project again (while persisting your work) is as simple as

```
python persist.py -c <project_name>
```

which will first save the states of the supported programs, close them down, and finally close the Virtual Desktop.

Compare this to the manual process, wherein I had to open up a new Virtual Desktop, open a Sublime Text window with the project folder, open up Chrome and reload my tabs using a tab manager, open up ConEmu with the correct startfile, and finally, move all these programs to the new Virtual Desktop.

Definitely saves me a lot of time. Perhaps more importantly, it **reduces the load on my brain**, knowing that all of these things are taken care of **by a single command**.

## So is this the best thing since sliced bread?

Probably not. There are some steps you have to do in order to fully set it up, which are all documented under the [readme](https://github.com/dorukkilitcioglu/persistd/blob/master/README.md). To make the program as lightweight as possible, it communicates with the programs in order to get whatever information on the state it can get. Unfortunately, that also means some programs are not easy to get support for, as they hide their state due to security concerns.

For any program requests, feel free to open up an [issue](https://github.com/dorukkilitcioglu/persistd/issues). Right now, Sublime Text, Google Chrome, and ConEmu are the only supported programs.

## Can't you have just used a bash script?

Yes and no. Obviously, you can replicate all functionality of this program in bash. However, that would soon be unmanageable as you wouldn't have an object oriented approach, and it would take me significantly longer to code.

Also, although there are no desktop managers for Mac OS or Linux yet, the architecture of this program is OS-agnostic. That is, as long as you implement the bindings for a desktop manager and the programs you want in your OS of choice, the rest of the program should work as expected. This is contrast to bash scripting, where it (obviously) only works in bash.

## Conclusion

This project appeals to both the hacker and the multitasker inside me. Since it contains all the parts I need for it to work at the moment, it is now relased as version 1.0.0. I had a great deal of fun while working on this project, and aim to continue until I iron out the kinks.

I also learned a great deal about how Windows works and how different programs utilize the Windows API. Perhaps those lessons will make another blog post in the future. For now, bye!