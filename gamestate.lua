--[[
Copyright (c) 2010 Matthias Richter

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

Gamestate = {}

local function __NULL__() end
-- default gamestate produces error on every callback
local function __ERROR__() error("Gamestate not initialized. Use Gamestate.switch()") end
Gamestate.current = {
    enter          = __ERROR__,
    leave          = __NULL__,
    update         = __ERROR__,
    draw           = __ERROR__,
    keyreleased    = __ERROR__,
    keypressed     = __ERROR__,
    mousereleased  = __ERROR__,
}

function Gamestate.new()
	return {
		enter          = __NULL__,
		leave          = __NULL__,
		update         = __NULL__,
		draw           = __NULL__,
		keyreleased    = __NULL__,
		keypressed     = __NULL__,
		mousereleased  = __NULL__,
	}
end

function Gamestate.switch(to, ...)
	if not to then return end
    Gamestate.current:leave()
	local pre = Gamestate.current
	Gamestate.current = to
	Gamestate.current:enter(pre, ...)
end

local _update
function Gamestate.update(dt)
	if _update then _update(dt) end
	Gamestate.current:update(dt)
end

local _keypressed
function Gamestate.keypressed(key, unicode)
	if _keypressed then _keyreleased(key) end
	Gamestate.current:keypressed(key, unicode)
end

local _keyreleased
function Gamestate.keyreleased(key)
	if _keyreleased then _keyreleased(key) end
	Gamestate.current:keyreleased(key)
end

local _mousereleased
function Gamestate.mousereleased(x,y,btn)
	if _mousereleased then _mousereleased(x,y,btn) end
	Gamestate.current:mousereleased(x,y,btn)
end

local _draw
function Gamestate.draw()
	if _draw then _draw() end
	Gamestate.current:draw()
end

function Gamestate.registerEvents()
	_update            = love.update
	love.update        = Gamestate.update
	_keypressed        = love.keypressed
	love.keypressed    = Gamestate.keypressed
	_keyreleased       = love.keyreleased
	love.keyreleased   = Gamestate.keyreleased
	_mousereleased     = love.mousereleased
	love.mousereleased = Gamestate.mousereleased
	_draw              = love.draw
	love.draw          = Gamestate.draw
end
