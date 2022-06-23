local Lplus = require "Lplus"
local LuaRuntimeUpdate = Lplus.Class("LuaRuntimeUpdate")
local def = LuaRuntimeUpdate.define

local _instance = nil

def.field("table").nameToPathTable = nil -- {key = fileName, value = filePath}
def.const("string").luaFolderPath = "C:\\Users\\murphycui\\SSSEditor\\client\\output\\Lua"

def.final("=>", LuaRuntimeUpdate).Instance = function()
    if not _instance then
        _instance = LuaRuntimeUpdate()
    end
    return _instance
end

def.static().UpdateLoadedLuaFile = function()
    local updater = LuaRuntimeUpdate.Instance()

end

def.method().Init = function(self)
    self.nameToPathTable = {}
end

def.method().ReLoadAllLuaFile = function(self)

end

_G.LuaRuntimeUpdate = LuaRuntimeUpdate
return LuaRuntimeUpdate.Commit()
