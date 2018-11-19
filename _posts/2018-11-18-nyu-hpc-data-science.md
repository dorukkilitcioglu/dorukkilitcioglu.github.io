---
layout: post
title: "Running Jupyter Notebook on NYU HPC in 3 Clicks"
date: 2018-11-18 18:30:00 -0500
categories: data-science programming
tags: ubuntu bash anaconda jupyter-notebook
image: /assets/images/posts/nyu-hpc-data-science/slurm.png
---

I've been lately getting a lot of question about my setup for NYU's High Performance Computing cluster and how it can be made more convenient to use. In this post, I'm going to be sharing my tips and tricks for increasing the productivity when working with remote clusters that use the [Slurm Workload Manager](https://slurm.schedmd.com/), such as NYU's Prince cluster.

## Requirements

1. [NYU Prince access](https://wikis.nyu.edu/display/NYUHPC/Request+or+Renew).
2. Some terminal that allows you to `ssh`. If you're on Windows, I highly suggest using [Windows Subsystem for Linux]({% post_url 2018-05-06-data-science-workflow-ubuntu-windows %}).
3. 2 ports that are above `10000`. One will be used for `rmate`, the other for Jupyter Notebook. We will call them `port_rmate` and `port_jupyter`.

## Baby Steps

The first order of business is to make sure we can access the Prince cluster easily. The [official method](https://wikis.nyu.edu/display/NYUHPC/Logging+in+to+the+NYU+HPC+Clusters) requires you to first login to the bastion host (the gateway), and then login into the Prince cluster. In both cases, you're required to enter your password, which is highly inefficient.

Normally, I'd recommend setting up ssh keys, because that is the most secure way of connecting to remote servers. However, you **cannot** modify the contents of the `.ssh` folder in the gateway server. Thankfully, we can use a little something called `sshpass` in order to automate the password bit.

In general, you can use `sshpass -p <your password> <valid ssh command>` for all actions that require a password. Even better, if you don't want your password to be persisted in your `history`, you can use `sshpass -f <file containing your password> <valid ssh command>` to pass in a file that contains your history instead.

So install `sshpass` and save your Prince password to a file (lets call it `prince.pwd`). I generally do a `chmod 400 prince.pwd` in order to make sure only my user can read it. Then add the following to your `.ssh/config` file:
```
Host prince
    HostName prince.hpc.nyu.edu
    ProxyCommand sshpass -f ~/prince.pwd ssh <net_id>@gw.hpc.nyu.edu -W %h:%p
    User <net_id>
    RemoteForward <port_rmate> localhost:<port_rmate>
    ServerAliveInterval 240
    ServerAliveCountMax 2
```

and the following to your `.bash_profile` file:
```
alias prince='sshpass -f ~/prince.pwd ssh prince'
```

Reload your `.bash_profile` file, and viola, you should be able to type `prince` and land straight into one of the login servers!

## Rmate & Rsub

I personally use [rsub](https://github.com/henrikpersson/rsub) in order to remotely edit my files in my local Sublime Text instance. Go ahead and install it, and make sure you go to `Preferences > Package Settings > rsub > Settings - Default` and replace the contents with the following:
```
{
    "port": <port_rsub>,
    "host": "localhost"
}
```

This will make your local Sublime Text listen to the specific port you are forwarding. Now, advanced users will observe that this is just the _local_ port, and it has nothing to do with the _remote_ port we are forwarding, but I feel like keeping them the same is **much** easier.

On Prince, download one of the `rmate` implementations linked above inside above `rsub` link (hint: `wget` is your friend.), and place it on your `PATH`. I placed mine under `~/tools/bin`, and placed that directory in my path (`export PATH=$PATH:$HOME/tools/bin` in your remote `.bash_profile` file).

You also have to make sure you set the relevant `rmate` variables in Prince, so add these to your `.bash_profile`:
```
export RMATE_HOST=localhost
export RMATE_PORT=<port_rmate>/
```

Now you should be able to do `rmate filename.txt` and edit it in your local Sublime Text. Even with port forwarding it twice!

## Setting up a Python environment

When using Python (which is the case for most Data Science projects), it is important to use [virtual environments](https://docs.python-guide.org/dev/virtualenvs/) to handle different projects. This is especially important when dealing with Prince, because you don't have control over the different Python modules available on Prince.

There are different virtual environment managers, including [virtualenv](https://virtualenv.pypa.io/en/latest/), [pipenv](https://pipenv.readthedocs.io/en/latest/), [pyenv](https://github.com/pyenv/pyenv), and [Anaconda](https://www.anaconda.com/). I personally use Anaconda, so the rest of this guide will assume the use of Anaconda.

While logged into Prince, type `module load anaconda3/4.3.1` to load the Anaconda module. You will now have access to the `conda` command, and you can use [this guide](https://conda.io/docs/user-guide/tasks/manage-environments.html) to create a new environment (let's call it `<env_name>`).

**IMPORTANT**: You can now activate the environment and install your dependencies. HOWEVER, if you are going to be using a GPU, make sure you install the GPU versions of your packages. For example, if you want to install Tensorflow, first load in CUDA using `module load cuda/9.0.176`, load in cuDNN using `module load cudnn/9.0v7.0.5`, and install the GPU version of Tensorflow using `pip install tensorflow-gpu`. Otherwise you'll be requesting a GPU that will not be of any use :)

Also, make sure you install Jupyter **inside** your environment, otherwise you might end up running a different Jupyter, or the script might just crash. For bonus points, set up a [password](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html) for Jupyter.

## Sbatch & Jupyter Notebook

Here comes the fun part. The stuff we covered until now has been relatively tame. We will now up our game with triple port forwarding.

<div style="margin: 0 auto;max-width: 700px;text-align: center;">
    <figure>
        <img src="/assets/images/posts/nyu-hpc-data-science/sweat-towel-meme.jpg" alt="Sweating towel guy meme" width="70%"/>
        <figcaption><i><a href="https://knowyourmeme.com/photos/565399-sweating-towel-guy">image credit</a></i></figcaption>
    </figure>
</div>

`sbatch` is Slurm's batch script scheduler. Jobs submitted to Slurm using `sbatch` will be run on the background, so you can safely exit the shell without killing your application. If you need an introduction, you can read [NYU's docs on sbatch](https://wikis.nyu.edu/display/NYUHPC/Submitting+jobs+with+sbatch).

What we will do is run a Jupyter Notebook using `sbatch`, which will place it on a GPU node. We can then forward the Jupyter port to the login servers, and forward that back to our local machine. Fun!

I use a [slightly modified version](https://github.com/dorukkilitcioglu/dorukkilitcioglu.github.io/blob/master/assets/misc/nyu-hpc-data-science/prince/tools/batch/run-jupyter.sbatch) of the `sbatch` file given [here](https://wikis.nyu.edu/display/NYUHPC/Running+Jupyter+on+Prince). Download my version, modify the contents with your own `<env_name>` and `<port_jupyter>`, and put it under your `~/tools/batch/` directory.

While you're there, you might as well do it for [all the files](https://github.com/dorukkilitcioglu/dorukkilitcioglu.github.io/tree/master/assets/misc/nyu-hpc-data-science), since we will be needing all of them.

This script loads in all the necessary CUDA modules, activates your environment, forwards the Jupyter port to the login servers, and then starts the Jupyter notebook. You can run it using `sbatch $HOME/tools/batch/run-jupyter.sbatch`. However, we can be cheeky, and add
```
alias jp='sbatch $HOME/tools/batch/run-jupyter.sbatch'
```
to our `.bash_profile` file. This makes it so that you can run `jp` from any directory and it will run a notebook from that directory.

Once you submit the job and Jupyter is running, you can open another shell and start forwarding the right port to your local machine. Normally, you would have to do 2 port forwarding `ssh`s, which is time consuming, so add this to your local `.bash_profile` file:
```
alias jpprince='sshpass -f ~/prince.pwd ssh -N -L localhost:8888:localhost:<port_jupyter> <net_id>@prince'
```
and again, by simply doing `jpprince`, you can port forward the whole thing.

Now, go to `http://localhost:8888` in your browser, and you should be able to use Jupyter notebook as if it was running on your computer!

## Conclusion

Now that everything is in place, you can very quickly start a Jupyter notebook in 3 commands:

1. Run `prince` on your local machine.
2. Run `jp` from Prince when the previous command finishes.
3. Run `jpprince` on your local machine from another shell.

And viola! You now have a GPU enabled Jupyter notebook!

### Advanced topics

You'll notice that there are some additional files and commands [in the repo](https://github.com/dorukkilitcioglu/dorukkilitcioglu.github.io/tree/master/assets/misc/nyu-hpc-data-science) for the Prince side. They are general utility functions that I've found to be useful for productivity.

- Running `pygpu <python_script>` from a Prince shell will immediately create a batch job that runs the script that you give it.
- Running `gpu "<shell command>"` will execute the given shell command in a GPU node. This is more flexible than the previous one.
- Running `sq` will give you the breakdown of your batch jobs.
- Running `sr` will place you in an interactive shell inside a GPU node. From there, you can use any shell command while having access to a GPU. This is useful if you're testing to see a script works.

If you have any more shortcuts, please do let me know!