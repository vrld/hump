--[[
Copyright (c) 2010-2013 Matthias Richter

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
local cos, sin = math.cos, math.sin

local camera = {}
camera.__index = camera

local function new(x,y, zoom, rot, smoother)
	x,y  = x or love.graphics.getWidth()/2, y or love.graphics.getHeight()/2
	zoom = zoom or 1
	rot  = rot or 0
	smoother = smoother or camera.smoothNone() -- for locking, see below
	return setmetatable({x = x, y = y, scale = zoom, rot = rot, smoother = smoother}, camera)
end

function camera:lookAt(x,y)
	self.x, self.y = x,y
	return self
end

function camera:move(x,y)
	self.x, self.y = self.x + x, self.y + y
	return self
end

function camera:pos()
	return self.x, self.y
end

function camera:rotate(phi)
	self.rot = self.rot + phi
	return self
end

function camera:rotateTo(phi)
	self.rot = phi
	return self
end

function camera:zoom(mul)
	self.scale = self.scale * mul
	return self
end

function camera:zoomTo(zoom)
	self.scale = zoom
	return self
end

function camera:attach()
	local cx,cy = love.graphics.getWidth()/(2*self.scale), love.graphics.getHeight()/(2*self.scale)
	love.graphics.push()
	love.graphics.scale(self.scale)
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
	-- x,y = ((x,y) - (self.x, self.y)):rotated(self.rot) * self.scale + center
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	local c,s = cos(self.rot), sin(self.rot)
	x,y = x - self.x, y - self.y
	x,y = c*x - s*y, s*x + c*y
	return x*self.scale + w/2, y*self.scale + h/2
end

function camera:worldCoords(x,y)
	-- x,y = (((x,y) - center) / self.scale):rotated(-self.rot) + (self.x,self.y)
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	local c,s = cos(-self.rot), sin(-self.rot)
	x,y = (x - w/2) / self.scale, (y - h/2) / self.scale
	x,y = c*x - s*y, s*x + c*y
	return x+self.x, y+self.y
end

function camera:mousepos()
	return self:worldCoords(love.mouse.getPosition())
end

-- camera scrolling utilities - adapted from http://gamasutra.com/blogs/ItayKeren/20150511/243083/Scroll_Back_The_Theory_and_Practice_of_Cameras_in_SideScrollers.php

-- movement interpolators
function camera.smoothNone()
	return function(dx,dy) return dx,dy end
end

function camera.smoothLinear(speed)
	assert(type(speed) == "number", "Invalid parameter: speed = "..tostring(speed))
	return function(dx,dy, s)
		-- normalize direction
		local d = math.sqrt(dx*dx+dy*dy)
		dts = math.min((s or speed) * love.timer.getDelta(), d) -- prevent overshooting the goal
		if d > 0 then
			dx,dy = dx/d, dy/d
		end

		return dx*dts, dy*dts
	end
end

function camera.smoothDamped(speed)
	assert(type(speed) == "number", "Invalid parameter: speed = "..tostring(speed))
	return function(dx,dy, s)
		local dts = love.timer.getDelta() * (s or speed)
		return dx*dts, dy*dts
	end
end

-- position locking
function camera:lockX(x, smoother, ...)
	local dx, dy = (smoother or self.smoother)(x - self.x, self.y, ...)
	self.x = self.x + dx
end

function camera:lockY(y, smoother, ...)
	local dx, dy = (smoother or self.smoother)(self.x, y - self.y, ...)
	self.y = self.y + dy
end

function camera:lockPos(x,y, smoother, ...)
	self:move((smoother or self.smoother)(x - self.x, y - self.y, ...))
end

-- (possibly) move camera to keep x,y (in world coordinates) inside camera window (in camera coordinates)
function camera:lockWindow(x, y, x_min, x_max, y_min, y_max, smoother, ...)
	-- figure out displacement in camera coordinates
	x,y = self:cameraCoords(x,y)
	local dx, dy = 0,0
	if x < x_min then
		dx = x - x_min
	elseif x > x_max then
		dx = x - x_max
	end
	if y < y_min then
		dy = y - y_min
	elseif y > y_max then
		dy = y - y_max
	end

	-- transform displacement to movement in world coordinates
	local c,s = cos(-self.rot), sin(-self.rot)
	dx,dy = (c*dx - s*dy) * self.scale, (s*dx + c*dy) * self.scale

	-- move
	self:move((smoother or self.smoother)(dx,dy,...))
end

-- the module
return setmetatable({new = new,
		smoothNone = camera.smoothNone,
		smoothLinear = camera.smoothLinear,
		smoothDamped = camera.smoothDamped
	}, {__call = function(_, ...) return new(...) end})
