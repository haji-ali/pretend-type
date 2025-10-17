# pretend-type-mode

`pretend-type-mode` is a playful Emacs minor mode that hides the content of a buffer and "reveals" it as you pretend to type. Your keystrokes do **not** insert any text; instead, the hidden text is gradually revealed. This is perfect for demos, presentations, or just for fun.

---

## Features

- Hides all buffer content on activation.
- "Inserting" printable characters reveals one character at a time.
- "Inserting" whitespace characters (space, tab, newline) reveal all consecutive whitespace at once.
- `<tab>` reveals the next word, including leading whitespace.
- `<return>` and `C-j` reveals text up to the next newline.
- `<DEL>` hides the previous character.
- `<M-DEL>` hides the previous word.
- All other Emacs commands remain fully functional.
- Automatically disables when the entire buffer is revealed.

---

## Installation

1. Save `pretend-type.el` to your Emacs `load-path`.
2. Add the following to your Emacs configuration:

```elisp
(require 'pretend-type)
```

## Usage
Simply open a buffer and enable `pretend-type-mode`, then type away.

Tip: You can add `eval: (pretend-type-mode)` in your list of local variables
to have the minor mode auto-enabled when you open a file, for maximum
sneakiness.


## Similar packages
- [reveal-next](https://www.emacswiki.org/emacs/RevealNextTextMode) is similar
  as it reveals the next character or line, except less sneaky.
- [hacker-typer](https://github.com/dieggsy/emacs-hacker-typer) is also
  similar buts adds text at a constant or random rate. It also works by
  inserting the text in a new buffer. `pretend-type` does not modify the file.
