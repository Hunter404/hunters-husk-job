HH = HH or {}

HH.HuntersHusks = {
    Name = "Hunter's Husks",
    Version = "1.0.63",
    Path = table.pack(...)[1]
}

if not HH.HuntersGeneticsBase then
    error("ERROR: Hunter's Genetics Base mod is required for " .. HH.HuntersHusks.Name .. " to work! Get it from the Steam Workshop! Make sure it is loaded before " .. HH.HuntersHusks.Name .. "!");
    return
end

require 'Scripts.shared'

if SERVER or not Game.IsMultiplayer then
    require 'Scripts.utility'
    require 'Scripts.chat'

    require 'Scripts.init'
    require 'Scripts.fusedflesh'
    require 'Scripts.hireables'
end

if CLIENT then
    require 'Scripts.utility'

    require 'Scripts.cl_transformAndJump'
    require 'Scripts.cl_toggleMuteHusks'
    require 'Scripts.cl_humanHuskSkin'
end
