HH = HH or {}

HH.HuntersHusks = {
    Name = "Hunter's Husks",
    Version = "1.0.52",
    Path = table.pack(...)[1]
}

if not HH.HuntersGeneticsBase then
    error("ERROR: Hunter's Genetics Base mod is required for " .. HH.HuntersHusks.Name .. " to work! Get it from the Steam Workshop! Make sure it is loaded before " .. HH.HuntersHusks.Name .. "!");
    return
end

dofile(HH.HuntersHusks.Path .. "/Lua/Scripts/shared.lua")

if SERVER or not Game.IsMultiplayer then
    dofile(HH.HuntersHusks.Path .. "/Lua/Scripts/init.lua")
end

if CLIENT then
    dofile(HH.HuntersHusks.Path .. "/Lua/Scripts/cl_init.lua")
end
