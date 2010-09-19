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

require 'vector'

local camera = {}
camera.__index = camera
function Camera(pos, zoom, rot)
	local pos  = pos or vector(love.graphics.getWidth(), love.graphics.getHeight()) / 2
	local zoom = zoom or 1
	local rot  = rot or 0
	return setmetatable({pos = pos, zoom = zoom, rot = rot}, camera)
end

function camera:rotate(phi)
	self.rot = self.rot + phi
end

function camera:translate(t)
	self.pos = self.pos + t
end

function camera:predraw()
	local center = vector(love.graphics.getWidth(), love.graphics.getHeight()) / (self.zoom * 2)
	love.graphics.push()
	love.graphics.scale(self.zoom)
	love.graphics.translate(center:unpack())
	love.graphics.rotate(self.rot)
	love.graphics.translate((-self.pos):unpack())
end

function camera:postdraw()
	love.graphics.pop()
end

function camera:draw(func)
	self:predraw()
	func()
	self:postdraw()
end

function camera:toCameraCoords(p)
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	local p = p - self.pos
	return vector((p.x+w/2) * self.zoom, (p.y+h/2) / self.zoom):rotate_inplace(self.rot)
end

function camera:toWorldCoords(p)
	local w,h = love.graphics.getWidth(), love.graphics.getHeight()
	p = vector((p.x-w/2) / self.zoom, (p.y-h/2) / self.zoom):rotate_inplace(-self.rot)
	return p + self.pos
end

function camera:mousepos()
	return self:toWorldCoords(vector(love.mouse.getPosition()))
end
