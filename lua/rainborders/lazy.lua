return {
    "vverdillon/rainborders",
    opts = {},
    config = function(_, opts)
        require("rainborders").setup(opts)
    end,
}
