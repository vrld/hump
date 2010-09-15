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
	p = vector((p.x-w/2) / self.zoom, (p.y-h/2) / self.zoom):rotate_inplace(-self.rot)
	return p + self.pos
end

function camera:mousepos()
	return self:transform(vector(love.mouse.getPosition()))
end
