---
layout: post
title: "A case for better Python docstrings"
date: 2018-08-17 20:27:00 -0400
categories: programming
tags: python
image: /assets/images/posts/python-better-docstring/python-docstring.png
---

I have been using Python daily for 3 years, and working professionally with it for about a year now. It is a great language, and I'm grateful that I get to work with it every day. However, my biggest gripe with Python was the rather uninspiring docstrings found online and in style guides. Here, I propose a **clean**, **explicit**, and **visually appealing** alternative.

![Example of a better Python docstring]({{ "/assets/images/posts/python-better-docstring/python-docstring.png" | absolute_url }})

This is a style I've been using in my [latest project](https://github.com/dorukkilitcioglu/persist-desktop), and I'm quite happy with how it's working out.

## The Standard

The official guidelines for Python's docstring conventions is given by [PEP 257](https://www.python.org/dev/peps/pep-0257/). The following is _the_ example given by it:

```python
def complex(real=0.0, imag=0.0):
    """Form a complex number.

    Keyword arguments:
    real -- the real part (default 0.0)
    imag -- the imaginary part (default 0.0)
    """
    if imag == 0.0 and real == 0.0:
        return complex_zero
```

Now, PEP 257 _technically_ does not define the need to use the `varname -- explanation (default defaultval)` syntax. However, as the authoritative source on the matter, this piece of code is what most people see when they search for `python docstring` on Google.

I have a few problems with this. One is that it is not clear in the first glance that where the keyword argument name ends and where the explanation begins. The specific example looks okay, but only because the lengths of the keyword arguments match, and the explanations are short. Case in point:

```python
def complex(real=0.0, imaginary=0.0, print_result=False):
    """Form a complex number.

    Keyword arguments:
    real -- the real part (default 0.0)
    imaginary -- the imaginary part (default 0.0)
    print_result -- whether to print the result to the console.
                    this is required for some legacy code (default False)
    """
    if imaginary == 0.0 and real == 0.0:
        return complex_zero
```

There are different ways of handling multi-line explanations here, like aligning it with the start of the above comment, or going with an indent, but there are problems with both of them. It's also difficult to explain a tuple input without having statements like "a 3-tuple which..."

Another problem is the **lack of types**. Although Python is dynamically typed, it is always good to indicate the expected type in the docstring, so that whoever is looking at your code doesn't have to guesstimate what exactly is being passed into the function. The `default` argument can sometimes indicate the type, but when the `default` is `None`, it's going to be tough.

## The Google Way

The [Google style guide for Python](https://github.com/google/styleguide/blob/gh-pages/pyguide.md#383-functions-and-methods) defines a syntax that makes way more sense. Below is an example directly taken from their style guide:

```python
def fetch_bigtable_rows(big_table, keys, other_silly_variable=None):
    """Fetches rows from a Bigtable.

    Retrieves rows pertaining to the given keys from the Table instance
    represented by big_table.  Silly things may happen if
    other_silly_variable is not None.

    Args:
        big_table: An open Bigtable Table instance.
        keys: A sequence of strings representing the key of each table row
            to fetch.
        other_silly_variable: Another optional variable, that has a much
            longer name than the other args, and which does nothing.

    Returns:
        A dict mapping keys to the corresponding table row data
        fetched. Each row is represented as a tuple of strings. For
        example:

        {'Serak': ('Rigel VII', 'Preparer'),
         'Zim': ('Irk', 'Invader'),
         'Lrrr': ('Omicron Persei 8', 'Emperor')}

        If a key from the keys argument is missing from the dictionary,
        then that row was not found in the table.

    Raises:
        IOError: An error occurred accessing the bigtable.Table object.
    """
```

This does a few things well:
- `Args` and `Returns` are clearly separated from the rest of the docstring
- The `:` separator is much more natural than `--`

However, the problems I had above are not entirely gone. It is hard to separate the variable names from their explanations, its hard to explain a tuple, and there are no types.

## An alternative

What I'm proposing is a **clean**, **explicit**, and **visually appealing** solution:

```python
def run_on_command_line(command, input=None, open_async=False):
    """ Runs a command on command line

    Args:
        command::[str]
            The command to run. The first element in list is the
            executable, the rest are the arguments
        input::bytes
            The input to be fed in as STDIN
        open_async::bool(=False)
            Whether to open the process as asynchronous. If set,
            there will not be any communication through stdin and
            stdout, and the return code may not be set.

    Returns:
        return_code::int
            The return code of the executed command
        stdout::str
            The output of the command as a string, or an error object
            if the command was not executed successfully
        pid::int
            The process id of the created process
    """
```

The first thing to notice is that each keyword argument and returned object has a base syntax of `varname::type`. This makes it easy to, at a glance, understand the type of argument the function is expecting, and is very explicit. If there is a optional argument, you can optionally use `varname::type(=defaultval)`. I personally do not use them if I'm not expecting to generate a docstring using `pydoc`.

For lists and dicts, I use shorthands like `[str]` and `{int: float}`. If you have non-uniform lists or dicts, you can always fall back to `list` and `dict` keywords.

All the explanations are on a new line and indented, which makes their starting points clearly align between different lines and different arguments, making the docstring look clean and visually appealing.

For the high level tuples which are the only input or the output for a function, like the return value above, you can use a spread out notation similar to arguments. Since by default you can only have a single return value (even if it is a tuple), spreading it out does not create any confusion.

For inner tuples, it gets a little trickier:

```python
"""
   Returns:
        return_code::int
            The return code of the executed command
        stdout::str
            The output of the command as a string, or an error object
            if the command was not executed successfully
        process::tuple(2)
            All information related to a process

            pid::int
                The process id of the created process
            proc::Process
                The process object
"""
```

The description for the tuple string is optional, as explaining everything inside that tuple should be sufficient in order to understand the tuple, but it is sometimes worth it to explain the tuple at a high level.

This is not a perfect solution for inner tuples, and I welcome improvements.

## Conclusion

This docstring style has been adopted by a few of my coworkers and friends already. Since it is very verbose, I do not use it for every single function, but for longer functions that need clarity, this style works very well. If you have any suggestions, or if you decide to adopt this style, make sure you send me a message or an email!