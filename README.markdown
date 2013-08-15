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

```bash
cd ~/.vim/bundle
git clone ssh://git@github.com/coldfix/paster.vim
```

Alternatively, you can simply drop everything `~/.vim/` directory.


### Configuration

User data can be configured via `pastebin#config()`.
The function `g:InstallPasterConfig` will be called automatically when the autoload file is loaded.
So, for use with `pastebin.com`, you could add the following to your `.vimrc`:

```vim
function! g:InstallPasterConfig()
    call pastebin#config('pastebin.com', { 'api_dev_key': '4ca886bc1ac78c4d20d8cb0864a0b0c8' })
endfunction
```

Of course, you'd have to substitute your personal key as handed out by the site.
