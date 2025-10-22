# lualine-lsp-info.nvim

Lualine component for monitoring LSP server memory usage and displaying active LSP client names in a single, clean format.

<img width="404" height="162" alt="image" src="https://github.com/user-attachments/assets/49f7a93b-b79d-467d-ac64-2f89763513aa" />


## Features

- **Combined Display** - Shows LSP name and memory in one component: `📦 vtsls (512M)`
- **Built-in LSP Support** - Pre-configured for TypeScript (vtsls, typescript-tools, tsserver, tsgo) and Java (jdtls)
- **Modular Architecture** - LSP configs organized by language in separate files
- **Custom LSP Support** - Easily add any LSP server
- **Per-LSP Customization** - Customize or disable built-in LSPs individually
- **Color-coded Warnings** - Visual feedback for high memory usage
- **Smart Caching** - Memory checks cached for 30 seconds (configurable) for performance

## Requirements

- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- Unix-like system with `ps`, `grep`, and `awk` commands

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "mattpatterson94/lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {},
}
```

### Using local plugin (for development)

```lua
{
  dir = "~/Code/projects/lualine-lsp-info.nvim",
  name = "lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {},
}
```

## Usage

### Basic Setup

The plugin automatically adds itself to your lualine statusline when you install it. No additional configuration needed!

```lua
{
  "mattpatterson94/lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {},
}
```

This will display: `📦 vtsls (512M)`, `⚡ ts-tools (256M)`, or `🚀 tsgo (1.2G)` depending on which LSP is active.

By default, the component is added to the `lualine_x` section (typically on the right side). You can customize this behavior:

```lua
{
  "mattpatterson94/lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {
    lualine = {
      enabled = true,           -- Set to false to disable auto-registration
      section = "lualine_x",    -- Which lualine section to add to
      position = 1,             -- Position within the section (1 = first)
    },
  },
}
```

### Manual Setup (Optional)

If you prefer to manually control where the component appears, disable auto-registration and add it yourself:

```lua
-- In your lualine-lsp-info config
{
  "mattpatterson94/lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {
    lualine = { enabled = false }, -- Disable auto-registration
  },
}

-- In your lualine config
{
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    local lsp_info = require("lualine-lsp-info")
    table.insert(opts.sections.lualine_x, lsp_info.component())
    return opts
  end,
}
```

### Customizing Built-in LSPs

```lua
{
  "mattpatterson94/lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {
    -- Disable vtsls
    vtsls = { enabled = false },

    -- Customize tsgo icon
    tsgo = { icon = "🔥" },  -- Will display as: 🔥 tsgo (512M)

    -- Change display name
    tsserver = { display_name = "TS" },  -- Will display as: 📘 TS (512M)
  },
}
```

### Adding Custom LSPs

```lua
{
  "mattpatterson94/lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {
    custom = {
      rust_analyzer = {
        client_name = "rust_analyzer",
        process_names = { "rust-analyzer", "rust_analyzer" },
        icon = "🦀",
        display_name = "rust",  -- Optional: cleaner name
        filetypes = { "rust" },
      },
      gopls = {
        client_name = "gopls",
        process_names = { "gopls" },
        icon = "🐹",
        filetypes = { "go" },
      },
    },
  },
}
```

This will display as `🦀 rust (256M)` and `🐹 gopls (128M)`.

### Complete Configuration Example

```lua
{
  "mattpatterson94/lualine-lsp-info.nvim",
  dependencies = { "nvim-lualine/lualine.nvim" },
  opts = {
    -- Lualine integration (optional, these are the defaults)
    lualine = {
      enabled = true,
      section = "lualine_x",
      position = 1,
    },

    -- Customize built-in LSP
    vtsls = { icon = "📘" },

    -- Add custom LSPs
    custom = {
      rust_analyzer = {
        client_name = "rust_analyzer",
        process_names = { "rust-analyzer" },
        icon = "🦀",
        filetypes = { "rust" },
      },
    },

    -- Global settings
    thresholds = {
      high = 3072,   -- 3GB
      medium = 1536, -- 1.5GB
    },
    colors = {
      high = "#ff0000",
      medium = "#ffa500",
    },
    cache_duration = 60,
  },
}
```

## Configuration

### Built-in LSPs

The plugin comes with pre-configured support for these LSPs:

**TypeScript/JavaScript** (`lua/lualine-lsp-info/lsps/typescript.lua`):

| LSP Key | Client Name | Icon | Display | Filetypes |
|---------|-------------|------|---------|-----------|
| `vtsls` | `vtsls` | `📦` | `📦 vtsls` | ts, tsx, js, jsx |
| `typescript_tools` | `typescript-tools` | `⚡` | `⚡ ts-tools` | ts, tsx, js, jsx |
| `tsserver` | `tsserver` | `📘` | `📘 tsserver` | ts, tsx, js, jsx |
| `tsgo` | `tsgo` | `🚀` | `🚀 tsgo` | ts, tsx, js, jsx |

**Java** (`lua/lualine-lsp-info/lsps/java.lua`):

| LSP Key | Client Name | Icon | Display | Filetypes |
|---------|-------------|------|---------|-----------|
| `jdtls` | `jdtls` | `☕` | `☕ jdtls` | java |

All built-in LSPs are enabled by default and can be customized or disabled.

**Note:** The icon is automatically prepended to the name. For `typescript-tools`, we use `display_name = "ts-tools"` for a cleaner display.

### Adding Built-in LSPs for Other Languages

Want to contribute built-in support for other languages? Follow this pattern:

1. Create a new file: `lua/lualine-lsp-info/lsps/your-language.lua`
2. Use the template from `lua/lualine-lsp-info/lsps/_template.lua`
3. Add your language module to the `lsp_modules` list in `init.lua`

Example for Rust (`lua/lualine-lsp-info/lsps/rust.lua`):
```lua
return {
  rust_analyzer = {
    enabled = true,
    client_name = "rust_analyzer",
    display_name = "rust",
    process_names = { "rust-analyzer", "rust_analyzer" },
    icon = "🦀",
    filetypes = { "rust" },
  },
}
```

### Per-LSP Configuration Options

Each LSP (built-in or custom) supports these options:

```lua
{
  enabled = true,                  -- Enable/disable this LSP
  client_name = "vtsls",           -- LSP client name (required for custom LSPs, must match Neovim's LSP client)
  process_names = { "vtsls" },     -- Process patterns to monitor (required for custom LSPs)
  icon = "📦",                     -- Icon to prepend to name
  display_name = "my-name",        -- Optional: custom display name (defaults to client_name)
  filetypes = { "typescript" },    -- Filetypes where this LSP applies
}
```

**Display Logic:**
- Icon is automatically prepended: `icon + " " + (display_name || client_name)`
- Example: `icon = "📦"`, `display_name = "vtsls"` → displays as `📦 vtsls`
- If no `display_name` is set, falls back to `client_name`

### Global Settings

```lua
{
  -- Lualine integration (auto-registration)
  lualine = {
    enabled = true,        -- Auto-register with lualine (set to false for manual setup)
    section = "lualine_x", -- Which lualine section to add to
    position = 1,          -- Position within the section (1 = first)
  },

  -- Memory thresholds in MB
  thresholds = {
    high = 2048,   -- Above this shows warning and red color
    medium = 1024, -- Above this shows in GB and orange color
  },

  -- Colors for different memory levels
  colors = {
    high = "#f38ba8",   -- Red (high memory)
    medium = "#fab387", -- Orange (medium memory)
    normal = nil,       -- Default lualine color
  },

  -- Cache duration in seconds
  cache_duration = 30,
}
```

## Component

### `component()`

The main component displays LSP name and memory usage in a single entry with color coding:

**Format:** `icon name (memory)`

**Examples:**
- `📦 vtsls (512M)` - Normal memory usage (< 1GB)
- `🚀 tsgo (1.5G)` - Medium memory usage (1-2GB) - orange color
- `⚡ ts-tools (2.5G ⚠️)` - High memory usage (> 2GB) - red color with warning

**Color Coding:**
- Default color: Memory < 1GB
- Orange (`#fab387`): Memory between 1-2GB
- Red (`#f38ba8`): Memory > 2GB (shows ⚠️ icon)

## How it works

1. On setup, automatically registers itself with lualine (can be disabled for manual setup)
2. Resolves LSP configuration from built-in LSPs, custom LSPs, and user overrides
3. Checks if any configured LSP client is attached to the current buffer
4. Uses `ps aux` with LSP-specific process patterns to measure memory usage
5. Caches memory results for the configured duration (default 30s) for performance
6. Displays only in filetypes configured for the active LSP
7. Color codes the entire component based on memory thresholds

## Use Cases

- **Monitor TypeScript LSP memory** - Works out of the box with vtsls, typescript-tools, tsserver, or tsgo
- **Track any LSP** - Add custom LSPs like Rust Analyzer, gopls, lua_ls, etc.
- **Debug memory issues** - Visual feedback when your LSP uses too much RAM
- **Multiple projects** - See which LSP is active and how much memory it's using at a glance
- **Clean statusline** - Single component instead of multiple separate entries

## Project Structure

```
lualine-lsp-info.nvim/
├── lua/
│   └── lualine-lsp-info/
│       ├── init.lua           # Main plugin logic
│       └── lsps/              # Built-in LSP configurations
│           ├── _template.lua  # Template for adding new LSPs
│           ├── typescript.lua # TypeScript/JavaScript LSPs
│           └── java.lua       # Java LSPs
└── README.md
```

The modular structure makes it easy to:
- Add built-in support for new languages
- Maintain LSP configurations separately
- Contribute language-specific LSP configs without touching core logic

## Contributing

Want to add built-in support for your favorite language's LSP?

1. Copy `lua/lualine-lsp-info/lsps/_template.lua`
2. Rename it to your language (e.g., `rust.lua`, `go.lua`, `python.lua`)
3. Fill in the LSP configurations
4. Add your module name to `lsp_modules` in `init.lua`
5. Submit a PR!

## License

MIT
