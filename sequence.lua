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
	local scene = assert(self.scenes:get(), "No scene in sequence")
	scene:leave()

	self.scenes.current = k % self.scenes:size()
	scene = assert(self.scenes:get(), "No scene in sequence")
	scene:enter()
	scene.time = 0
end

function sequence:rewind()
	self:select(1)
end

function sequence:prevScene()
	local scene = assert(self.scenes:get(), "No scene in sequence")
	scene:leave()

	scene = assert(self.scenes:prev(), "No scene in sequence")
	scene:enter()
	scene.time = 0
end

function sequence:nextScene()
	local scene = assert(self.scenes:get(), "No scene in sequence")
	scene:leave()

	scene = assert(self.scenes:next(), "No scene in sequence")
	scene:enter()
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
