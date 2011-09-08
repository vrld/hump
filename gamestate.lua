--[[
Copyright (c) 2010-2011 Matthias Richter

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
current = {
	init             = __ERROR__,
	enter            = __ERROR__,
	leave            = __NULL__,
	update           = __ERROR__,
	draw             = __ERROR__,
	focus            = __ERROR__,
	keyreleased      = __ERROR__,
	keypressed       = __ERROR__,
	mousepressed     = __ERROR__,
	mousereleased    = __ERROR__,
	joystickpressed  = __ERROR__,
	joystickreleased = __ERROR__,
	quit             = __ERROR__,
}

local function new()
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

local function switch(to, ...)
	assert(to, "Missing argument: Gamestate to switch to")
	current:leave()
	local pre = current
	to:init()
	to.init = __NULL__
	current = to
	return current:enter(pre, ...)
end

local _update
local function update(...)
	if _update then _update(...) end
	return current:update(...)
end

local _draw
local function draw(...)
	if _draw then _draw(...) end
	return current:draw(...)
end

local _focus
local function focus(...)
	if _focus then _focus(...) end
	return current:focus(...)
end

local _keypressed
local function keypressed(...)
	if _keypressed then _keypressed(...) end
	return current:keypressed(...)
end

local _keyreleased
local function keyreleased(...)
	if _keyreleased then _keyreleased(...) end
	return current:keyreleased(...)
end

local _mousepressed
local function mousepressed(...)
	if _mousepressed then _mousepressed(...) end
	return current:mousepressed(...)
end

local _mousereleased
local function mousereleased(...)
	if _mousereleased then _mousereleased(...) end
	return current:mousereleased(...)
end

local _joystickpressed
local function joystickpressed(...)
	if _joystickpressed then _joystickpressed(...) end
	return current:joystickpressed(...)
end

local _joystickreleased
local function joystickreleased(...)
	if _joystickreleased then _joystickreleased(...) end
	return current:joystickreleased(...)
end

local _quit
local function quit(...)
	if _quit then _quit(...) end
	return current:quit(...)
end

local function registerEvents()
	_update               = love.update
	love.update           = update
	_draw                 = love.draw
	love.draw             = draw
	_focus                = love.focus
	love.focus            = focus
	_keypressed           = love.keypressed
	love.keypressed       = keypressed
	_keyreleased          = love.keyreleased
	love.keyreleased      = keyreleased
	_mousepressed         = love.mousepressed
	love.mousepressed     = mousepressed
	_mousereleased        = love.mousereleased
	love.mousereleased    = mousereleased
	_joystickpressed      = love.joystickpressed
	love.joystickpressed  = joystickpressed
	_joystickreleased     = love.joystickreleased
	love.joystickreleased = joystickreleased
	_quit                 = love.quit
	love.quit             = quit
end

-- the module
return {
	new              = new,
	switch           = switch,
	update           = update,
	draw             = draw,
	focus            = focus,
	keypressed       = keypressed,
	keyreleased      = keyreleased,
	mousepressed     = mousepressed,
	mousereleased    = mousereleased,
	joystickpressed  = joystickpressed,
	joystickreleased = joystickreleased,
	quit             = quit,
	registerEvents   = registerEvents
}
