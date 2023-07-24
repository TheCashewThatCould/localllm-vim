## Prerequisites

1) Vim with Python3 support.

## Installation
https://github.com/ggerganov/llama.cpp#obtaining-the-facebook-llama-original-model-and-stanford-alpaca-model-data
append this to the end of vimrc file
``vim
source path_to_this_file_from_vimrc_file.vim
```
Configure run.sh variables to what you want to run and where you want to run it
## Usage

The plugin offers the following commands for interacting with local llama install:

1) `:Ask '<prompt>'` Sends your raw prompt to the local llama install API.

To use this command, type :Ask followed by your prompt.

2) `:<>Review` Sends the highlighted code to local llama install and requests a review.

To use these commands (:Explain, :Review, or :Rewrite), visually select the lines of code you want to interact with, then type the desired command and press Enter.

4) `:GenerateCommit` Sends entire buffer to local llama install and requests a commit messages be generated, then pastes it at the top of the buffer
To use this command type `git commit -v`  then `:GenerateCommit`

5) `:<>Explain '<context>'` Sends the highlighted code to local llama install and requests an explanation, with the option to include additional context.
5) `:<>Rewrite '<context>'` Sends the highlighted code to local llama install and requests a rewritten version, with the option to include additional context.
5) `:<>Test '<context>'` Sends the highlighted code to local llama install and requests it writes a test, with the option to include additional context.
5) `:<>Fix '<context>'` Sends the highlighted code to local llama install and that it fixes any errors it may find, with the option to include additional context.

To use this command, visually select the lines of code you want to extend, then type :Extend 'context', where context is any additional information you want to provide.

The local llama install response will be displayed in a new buffer.

## Mappings

This plugin exposes a binding to open a menu for options on a visual selecition. You can map it like this:
```
vmap <silent> <leader>0 <Plug>(chatgpt-menu)
```

### Example usage:
1) Enter visual mode by pressing V.
1) Select the lines of code you want to explain, review, or rewrite.
1) Type `:Explain`, `:Review`, or `:Rewrite`, `:Fix`, `:Test` and press Enter.


