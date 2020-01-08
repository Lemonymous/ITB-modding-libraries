
local mod = mod_loader.mods[modApi.currentMod]
local path = mod.scriptPath .."weapons/"
assert(package.loadlib(path .."dll/utils.dll", "luaopen_utils"), "cannot find tarmean's C-Utils dll")()
local ret = test

return ret