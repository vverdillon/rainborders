# rainborders

## LazyVim

Add this plugin as a Lazy spec:

```lua
return {
  "vverdillon/rainborders",
  opts = {},
  config = function(_, opts)
    require("rainborders").setup(opts)
  end,
}
```