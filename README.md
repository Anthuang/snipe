# Snipe

A small popup to always show you the parent scope when editing, powered by treesitter.

## Installation

Install the plugin with your preferred package manager:

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'Anthuang/snipe'

lua << EOF
  require('snipe').setup {}
EOF
```

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  'Anthuang/snipe',
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-lua/popup.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('snipe').setup {}
  end
}
```

## Configuration

## Usage
