package = 'hump'
version = '0.1.0'
source = {
  url = "git://github.com/hewills/hump",
  branch = "master"
}
description = {
  summary = 'Fork of LזE Helper Utilities for Massive Progression',
  detailed = [[
    Just go here: http://hump.readthedocs.org
  ]],
  homepage = 'http://github.com/hewills/hump',
  license = 'MIT <http://opensource.org/licenses/MIT>'
}
dependencies = {
  'lua >= 5.1'
}
build = {
  type = 'builtin',
  modules = {
    ['hump.gamestate']                                	= 'gamestate.lua',
    ['hump.camera']			                            = 'camera.lua',
    ['hump.src.Engine']                              	= 'class.lua',
    ['hump.src.Entity']                              	= 'signal.lua',
    ['hump.src.EventManager']                        	= 'timer.lua',
    ['hump.lib.middleclass']                         	= 'vector-light.lua',
    ['hump.src.System']                              	= 'vector.lua',
  }
}