return {
    {
        "bjarneo/aether.nvim",
        name = "aether",
        priority = 1000,
        opts = {
            disable_italics = false,
            colors = {
                -- Monotone shades (base00-base07)
                base00 = "#18131a", -- Default background
                base01 = "#805c8a", -- Lighter background (status bars)
                base02 = "#18131a", -- Selection background
                base03 = "#805c8a", -- Comments, invisibles
                base04 = "#d9d2db", -- Dark foreground
                base05 = "#f1eef2", -- Default foreground
                base06 = "#f1eef2", -- Light foreground
                base07 = "#d9d2db", -- Light background

                -- Accent colors (base08-base0F)
                base08 = "#ac69bf", -- Variables, errors, red
                base09 = "#d1a7dd", -- Integers, constants, orange
                base0A = "#bb7acc", -- Classes, types, yellow
                base0B = "#b86acd", -- Strings, green
                base0C = "#c384d4", -- Support, regex, cyan
                base0D = "#b557ce", -- Functions, keywords, blue
                base0E = "#b677c8", -- Keywords, storage, magenta
                base0F = "#debae7", -- Deprecated, brown/yellow
            },
        },
        config = function(_, opts)
            require("aether").setup(opts)
            vim.cmd.colorscheme("aether")

            -- Enable hot reload
            require("aether.hotreload").setup()
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "aether",
        },
    },
}
