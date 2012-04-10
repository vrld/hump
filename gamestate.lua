--[[
Copyright (c) 2010-2012 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local function __NULL__() end

-- default gamestate produces error on every callback
local function __ERROR__() error("Gamestate not initialized. Use Gamestate.switch()") end
local current = setmetatable({leave = __NULL__}, {__index = __ERROR__})

local GS = {}
function GS.new()
	return {
		init             = __NULL__,
		enter            = __NULL__,
		leave            = __NULL__,
		update           = __NULL__,
		draw             = __NULL__,
		focus            = __NULL__,
		keyreleased      = __NULL__,
		keypressed       = __NULL__,
		mousepressed     = __NULL__,
		mousereleased    = __NULL__,
		joystickpressed  = __NULL__,
		joystickreleased = __NULL__,
		quit             = __NULL__,
	}
end

function GS.switch(to, ...)
	assert(to, "Missing argument: Gamestate to switch to")
	current:leave()
	local pre = current
	to:init()
	to.init = __NULL__
	current = to
	return current:enter(pre, ...)
end

-- holds all defined love callbacks after GS.registerEvents is called
-- returns empty function on undefined callback
local registry = setmetatable({}, {__index = function() return __NULL__ end})

local all_callbacks = {
	'update', 'draw', 'focus', 'keypressed', 'keyreleased',
	'mousepressed', 'mousereleased', 'joystickpressed',
	'joystickreleased', 'quit'
}

function GS.registerEvents(callbacks)
	callbacks = callbacks or all_callbacks
	for _, f in ipairs(callbacks) do
		registry[f] = love[f]
		love[f] = function(...) GS[f](...) end
	end
end

-- forward any undefined functions
setmetatable(GS, {__index = function(_, func)
	return function(...)
		registry[func](...)
		current[func](current, ...)
	end
end})

return GS
