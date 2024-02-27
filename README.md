# Buku Telescope Plugin

> **WARNING:** this is currently a quick, crude implementation that I plan on improving! Key
> bindings and API likely to change

Telescope plugin for [buku](https://github.com/jarun/buku), a CLI bookmark manager

## Installation

### Pre-requisites

You must have buku installed

### Install

Install as a dependency of Telescope with your favourite plugin manager. For example, with
lazy.nvim:

```lua
{
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  config = function()
    require('telescope').setup({
      -- other config here
      extensions = {
        buku = {
          -- TODO are there any props?
        }
      }
    })
  end
  dependencies = {
    { 'danarth/telescope-buku.nvim' }
  },
}
```

### Configuration

| Property | Description | Default Value |
| --- | --- | --- |

TODO

### Setup

```lua
require('telescope').load_extension('buku')
```

## Usage 

Command line:

```
Telescope buku
```

Using Lua:

```lua
require('telescope').extensions.buku()
```

### Work Items

#### Key Mappings

| Key | Action |
| --- | --- |
| `<cr>` | Open URL in new browser window |
