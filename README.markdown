## pastebin.vim

### Description

VIM plugin for pasting selected content to pastebins.


### Features

The plugin is invoked via the key binding `<Shift>F8`.
It behaves differently depending on the current mode:

* normal mode: paste the entire file
* visual mode: paste the selected content
* visual block|line mode: paste selected content


### Installation

You can install this plugin using [vim-pathogen](https://github.com/tpope/vim-pathogen/):

    cd ~/.vim/bundle
    git clone git://github.com/thomas-glaessle/vim-blockcomment.git

Alternatively, you can simply drop everything `~/.vim/` directory.


### Configuration

User data can be configured via `pastebin#config()`.
For use with `pastebin.com`, you could add the following to your `.vimrc`:

    call pastebin#config('pastebin.com', { 'api_dev_key': '4ca886bc1ac78c4d20d8cb0864a0b0c8' })

Of course, you'd have to substitute your personal key as handed out by the site.
