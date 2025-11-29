return {
    {
        "bjarneo/aether.nvim",
        name = "aether",
        priority = 1000,
        opts = {
            disable_italics = false,
            colors = {
                -- Monotone shades (base00-base07)
                base00 = "#0d0a0e", -- Default background
                base01 = "#7a5c8a", -- Lighter background (status bars)
                base02 = "#0d0a0e", -- Selection background
                base03 = "#7a5c8a", -- Comments, invisibles
                base04 = "#d2ccd6", -- Dark foreground
                base05 = "#ebe7ee", -- Default foreground
                base06 = "#ebe7ee", -- Light foreground
                base07 = "#d2ccd6", -- Light background

                -- Accent colors (base08-base0F)
                base08 = "#a169bf", -- Variables, errors, red
                base09 = "#caa7dd", -- Integers, constants, orange
                base0A = "#b07acc", -- Classes, types, yellow
                base0B = "#ab6acd", -- Strings, green
                base0C = "#b884d4", -- Support, regex, cyan
                base0D = "#a557ce", -- Functions, keywords, blue
                base0E = "#ac77c8", -- Keywords, storage, magenta
                base0F = "#d8bae7", -- Deprecated, brown/yellow
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
