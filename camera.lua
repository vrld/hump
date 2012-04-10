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

local _PATH = (...):match('^(.*[%./])[^%.%/]+$') or ''
local vec = require(_PATH..'vector-light')

local camera = {}
camera.__index = camera

local function new(x,y, zoom, rot)
	x,y  = x or love.graphics.getWidth()/2, y or love.graphics.getHeight()/2
	zoom = zoom or 1
	rot  = rot or 0
	return setmetatable({x = x, y = y, zoom = zoom, rot = rot}, camera)
end

function camera:rotate(phi)
	self.rot = self.rot + phi
	return self
end

function camera:move(x,y)
	self.x, self.y = self.x + x, self.y + y
	return self
end

function camera:attach()
	local cx,cy = vec.div(self.zoom*2, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.push()
	love.graphics.scale(self.zoom)
	love.graphics.translate(cx, cy)
	love.graphics.rotate(self.rot)
	love.graphics.translate(-self.x, -self.y)
end

function camera:detach()
	love.graphics.pop()
end

function camera:draw(func)
	self:attach()
	func()
	self:detach()
end

function camera:cameraCoords(x,y)
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	x,y = vec.rotate(self.rot, x-self.x, y-self.y)
	return x*self.zoom + w/2, y*self.zoom + h/2
end

function camera:worldCoords(x,y)
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	x,y = vec.rotate(-self.rot, vec.div(self.zoom, x-w/2, y-h/2))
	return x+self.x, y+self.y
end

function camera:mousepos()
	return self:worldCoords(love.mouse.getPosition())
end

-- the module
return setmetatable({new = new},
	{__call = function(_, ...) return new(...) end})
