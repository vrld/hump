require 'ringbuffer'

local sequence = {}
sequence.__index = sequence

function Sequence(...)
	local seq = {}
	seq.scenes = Ringbuffer(...)
	return setmetatable(seq, sequence)
end

function sequence:add(...)
	self.scenes:append(...)
end

function sequence:select(k)
	self.scenes.current = k % self.scenes:size()
	local scene = assert(self.scenes:get(), "No scene in sequence")
	scene.time = 0
end

function sequence:rewind()
	self:select(1)
end

function sequence:prevScene()
	local scene = assert(self.scenes:prev(), "No scene in sequence")
	scene.time = 0
end

function sequence:nextScene()
	local scene = assert(self.scenes:next(), "No scene in sequence")
	scene.time = 0
end

function sequence:draw()
	local scene = assert(self.scenes:get(), "No scene in sequence")
	scene:draw()
end

function sequence:update(dt)
	local scene = assert(self.scenes:get(), "No scene in sequence")
	scene:update(dt)
	scene.time = scene.time + dt
	if scene:isFinished() then
		self:nextScene()
	end
end

local scene = {}
scene.__index = scene

local function __NULL__() end
function Scene(length)
	local sc = {time = 0, length = length or -1}
	sc.update = __NULL__
	sc.enter = __NULL__
	sc.leave = __NULL__
	return setmetatable(sc, scene)
end

function scene:isFinished()
	return self.length > 0 and self.time >= self.length
end
