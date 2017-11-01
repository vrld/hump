package = "hump"
version = "scm-1"
source = {
   url = "git://github.com/vrld/hump"
}
description = {
   summary = "Lightweight game development utilities",
   detailed = "hump is a set of lightweight helpers for the awesome LÖVE game framework. It will help to get you over the initial hump when starting to build a new game.",
   homepage = "https://hump.readthedocs.io",
   license = "MIT",
   --labels={"love","game","statemachine"} -- only since luarocks 3.0
}
dependencies = {
  "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["hump.camera"] = "camera.lua",
      ["hump.class"] = "class.lua",
      ["hump.gamestate"] = "gamestate.lua",
      ["hump.signal"] = "signal.lua",
      ["hump.timer"] = "timer.lua",
      ["hump.vector"] = "vector.lua",
      ["hump.vector-light"] = "vector-light.lua"
   },
   copy_directories = {"docs"}
}
