# LSC: A Personal Chat Monitor for Windower4 and FFXI

### Overview

LSC (short for "linkshell chat") was originally created out of a desire to know what's been happening in LS while afk. This eventually expanded to cover the other main social chat types: linkshell, linkshell2, party, and tell.

LSC will show the most recent 20 or so lines of chat from all tracked modes in a panel on the lower-right section of your screen. This window can be hidden (see the `hide` command under usage below), in which case messages will still be tracked for later review.

<img title="" src="./content/sample.png" alt="dsaf" width="507" data-align="center">

LSC also provides a mechanism to review all received messages via the `replay` command (see below), so you'll never miss anything.

### Installation

Drop the `lsc` folder into your Windower4/addons directory and run `//lua r lsc`. To unload the addon, run `//lua u lsc`.

LSC can be added to your `init.txt` file to have it autoloaded at startup. Add `lua load lsc` near the end of the file if you'd like it to start with Windower.

**The latest release is available [here](https://github.com/Kaiconure/lsc/releases/).**

### Usage

LSC supports a handful of commands to help you get them most out of the addon.  Commands are sent to LSC by typing `//lsc <command> <arguments>` into the FFXI chat window.

- **show** - Shows the UI panel if it's currently hidden. Run as `//lsc show`.

- **hide** - Hides the UI pannel if it's currently being shown. Run as `//lsc hide`.

- <mark>NEW</mark> **anchor** [<nw|ne|se|sw>] - Sets the "anchor point" for the UI chat log, which is the cardinal corner (northwest, southeast, etc) to which it will be attached. Running without arguments will show you the current anchor point. The default value can be set with `//lsc anchor se`.

- <mark>NEW</mark> **margin** [h v] - Set the horizontal and vertical margins for the UI chat log. This controls its distance from the anchor point. The default values can be set with `//lsc margin 0 200`.

- <mark>NEW</mark> **size** [w h] - Sets the width and height of the UI chat log. There's no upper limit, with the width must be at least 300 pixels and the height at least 200 pixels. The default values can be set with `//lsc size 600 400`.

- **replay** [-type all|linkshell|linkshell2|party|tell>] [-max &lt;number&gt;] - Writes chat history out to the FFXI chat window for review.

- - **type** - Used to control the types of messages to list. If not specified, `all` is used. Shortcuts are support: `l` or `ls` for `linkshell`, `l2` or `ls2` for `linkshell2`, `p` for party, and `t` for tell.
  
  - **max** - The maximum number of messages to show. If not specified, the most recent 10 messages of your specified type will be displayed.

- **clear** [-display|-d] - Clears the chat log (that is, what's shown when running `//lsc replay` and its variants). If you specify the `-display` (or `-d` shortcut), then the on-screen chat display will also be cleared.

- **help** - Shows an in-game variation of these help notes.

Additional commands will be made available in a later version.

### Tips and Tricks

#### Absolute Positioning

LSC uses anchors and margins rather than direct (x, y) positioning. The main reason for this is portability. For example, anchoring to the bottom-right (SE) corner will continue to function regardless of window size.

That said, sometimes you just want to set a position directly. You *can* actually get this level of control by anchoring to the top-right (NW) corner. By doing so, margins become equivalent to screen space coordinates and you can have your way with absolute positioning.

To position the window at (100, 300) on the screen, you'd start with setting the anchor:

```bash
//lsc anchor ne
```

And then you'd set the margins (which, again, are the same as screen space coordinates when anchored to ne):

```bash
//lsc margin 100 300
```

And there you have it!

### Known Issues

- Japanese text is not properly captured. I need to do a better job of stripping out control characters while not stripping out non-ANSI text.

- Configuration options are limited. The only items currently saved are the chat window anchor and margins.

- The chat window cannot be resized at this time. This introduces complexity in terms of what can fit into the window, how to re-layout text already being shown, and so on. I need time to think about this, and to implement it in a reasonable way.


## Attribution

- [cylibs-ui by cyritegamestudios](https://github.com/cyritegamestudios/cylibs-ui) - LSC uses cylibs-ui for rendering its on-screen components.
