---
title: "Data Science workflow using Ubuntu Subsystem on Windows"
date: 2018-05-06 13:08:00 -0400
categories:
 - data-science
 - programming
tags:
 - ubuntu
 - windows
 - bash
 - eclipse
 - jupyter-notebook
layout: single
image: /assets/images/posts/data-science-workflow-ubuntu-windows/wsl.png
redirect_from: "/data-science/programming/2018/05/06/data-science-workflow-ubuntu-windows.html"
---

Microsoft's latest push for bringing developers to Windows comes in the form of embracing Linux as part of their system. [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about), also known as WSL, has been around for over a year now. After getting fed up with using Linux VMs for development environment, and later getting fed up with having to switch operating systems in a dual-boot config, I was ready to try it. I'm very glad that I did.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src='/assets/images/posts/data-science-workflow-ubuntu-windows/wsl.png' alt='Example of WSL apps' width="100%"/>
        <figcaption><i>Current Linux distros available for WSL</i></figcaption>
    </figure>
</div>

<br/>

There is one point I cannot stress enough: WSL is **NOT** a complete replacement for a Linux dual-boot or a Linux VM with GPU pass-through. It will most definitely be slower than those. You [cannot](https://github.com/Microsoft/WSL/issues/1788) use a GPU for now, so please do not try to run TensorFlow models on GPU with this.

## Installation

There are [many](http://wsl-guide.org/en/latest/), [many](https://nickjanetakis.com/blog/using-wsl-and-mobaxterm-to-create-a-linux-dev-environment-on-windows#wsl-conemu-and-mobaxterm-to-the-rescue), **[many](https://docs.microsoft.com/en-us/windows/wsl/install-win10)** guides for getting started with WSL. For the sake of brevity, I will not repeat what others have already covered here. I personally prefer the [wsl-guide](http://wsl-guide.org/en/latest/), but following any will suffice. Just make sure that you install an X server and set up your display to be localhost.

### Choosing a X Server

I've personally tried both [VcXsrc](https://sourceforge.net/projects/vcxsrv/) and [MobaXterm](https://mobaxterm.mobatek.net/), and have had no issues with either of them. I had to install `libgtk` using `sudo apt-get install libgtk` before being able to run them. If you use VcXsrv, I also highly recommend setting the `Clipboard may use PRIMARY selection` to disabled, as it automatically copies whatever you select when it is enabled, which is probably not what you usually intend.

### Choosing a terminal

I have been using [ConEmu](https://conemu.github.io/) as recommended by one of the above guides, for roughly 4 months now. It has been so useful that I've began to prefer it over the regular Windows terminal or PowerShell. By default, it places you in your native OS' C drive. Thankfully, its very easy to change that to start at the home directory. Change the run command of ConEmu terminal to:
```
%windir%\system32\bash.exe -cur_console:pm:/mnt -c "cd ~ && bash"
```

This will change the directory to the home directory and load in your bash profile.

## Tools

This is all great, but we need to run some development tools now.

### Eclipse and IntelliJ

You can install Java on the Linux subsystem in the same way you would install it to any Linux machine. One thing to keep in mind is to install the Standard Widget Toolkit (SWT) for GTK+JNI, because these IDEs [won't work them](https://stackoverflow.com/questions/10165693/eclipse-cannot-load-swt-libraries). This can be achieved by using:
```
sudo apt-get install libswt-gtk-3-jni
```

### Sublime Text

While you can run Sublime Text on the subsystem, I actually prefer to use the Sublime Text installation on my Windows machine to edit files. While this sounds counter-intuitive, it is very smooth once you set it up correctly.

The first thing you want to keep in mind is that you can, in fact, [run Windows programs from bash](https://docs.microsoft.com/en-us/windows/wsl/interop). When you try to run a Windows program, it is automatically run on your Windows machine. Of course, for programs like Sublime Text, you want them to live on the path. One way of doing that is creating a symlink of the exe you want in the `/usr/bin/` folder, so it is in your PATH variable. The other is to create a function in your `.bashrc` file like this:

```
function subl {
    /mnt/c/Program\ Files/Sublime\ Text\ 3/subl.exe "$@"
}
```

With this function, you can call `subl` from anywhere with the same arguments you would do elsewhere. The one caveat of this method is that you can't interact with Linux internal files (files that are not part of the `/mnt/c/` directory). Luckily, there's a nifty tool called `rsub` that is built for using your local Sublime Text to edit remote files.

#### `rsub` and other tricks

[rsub](https://github.com/henrikpersson/rsub) is a tool for editing your remote files in your local Sublime Text editor. You need to download either the [Ruby version](https://github.com/textmate/rmate/tree/54f9091d35a17b70019d364604e087800bfd7b7e) or the [Shell version](https://github.com/aurora/rmate/tree/57b607eb88d9d3d766a2855fd80b1b0148550611) of `rmate`. You should then save it named as `rmate` to somewhere on your `PATH` variable. You can test to see if it is working by calling `rmate`, which should give you a similar output to:
```
usage: /home/doruk/Tools/bin/rmate [-H host-name] [-p port-number] [-w] [-f] [-v] file-path
```

Once that is done, install `rsub` on your Sublime Text using [package control](https://packagecontrol.io/packages/rsub). Finally, replace the `subl` function in your `.bashrc` to the following:

```
function subl {
    CUR_PATH=`readlink -f $1`
    if [[ $CUR_PATH == /mnt/c/* ]]; then
        /mnt/c/Program\ Files/Sublime\ Text\ 3/subl.exe "C:${CUR_PATH:6}"
    else
        rmate $CUR_PATH
    fi
}
```

This code will first try to identify whether a given path is a symbolic link or not, and it gets the actual path if it is a symbolic link. From there, it checks if the path is a Linux internal path, or a path that points to your `C:` drive. IF it points to your `C:` drive, it automatically runs the original Sublime Text command we set up. If not, it actually runs the `rmate` tool we just set up, which opens the file up in your Sublime Text if you have `rsub` installed.

And now, you can edit all your files with your local Sublime Text.

### Jupyter Notebook

The localhost of WSL and your Windows machine is shared. What this means is that the Jupyter Notebook that you run is accessible from your native Chrome browser, so you can Jupyter on your Windows while you Python on your Ubuntu. I have an alias set up in my `.bashrc` file that looks like this:

```
alias jp='/mnt/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe http://localhost:8888/ & jupyter notebook --no-browser'
```

This command automatically launches a new tab at your native Chrome, directed at the localhost port that Jupyter uses. The Jupyter Notebook is actually run after the browser is opened, because you want to be able to `CTRL+C` your way out of the Jupyter Notebook.

### Virtually any other tool you would normally use in Linux

WSL makes it very easy for you to use the typical terminal tools like `grep` and `ssh`, meaning you never have to remember how to use Putty again. I have successfully run tools like RapidMiner and RStudio on WSL, though if your application is largely self-contained (which I do not consider Eclipse to be, but RapidMiner to be), you might still want to install their Windows versions in order not to have an extra layer between the hardware and the tool.

## Final Remarks

The interoperability of WSL and the native Windows has made it possible for me to nearly exactly replicate my normal Linux setup without giving up too many things, and having the added benefit of not having to boot into Windows every now and then. For everyday tasks, there is no noticable different in speed with respect to native Linux. I would suggest everybody to at least try it out.
