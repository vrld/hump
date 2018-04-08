package = "hump"
version = "0.4-2"
source = {
   url = "git://github.com/vrld/hump"
}
description = {
   summary = "Lightweight game development utilities",
   detailed = [[Collection of independent components that implement common task needed in games:
  - Gamestates that can stack on each other (e.g., for menus)
  - Timers and Tweens with thread-like scripting support
  - Cameras with camera movement control (locking, smooth follow, etc)
  - 2D vector math
  - Signals and Slots
  - Prototype-based OOP helper
  ]],
   homepage = "https://hump.readthedocs.io",
   license = "MIT",
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
}
