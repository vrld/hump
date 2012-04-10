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

local ringbuffer = {}
ringbuffer.__index = ringbuffer

local function new(...)
	local rb = {}
	rb.items = {...}
	rb.current = 1
	return setmetatable(rb, ringbuffer)
end

function ringbuffer:insert(item, ...)
	if not item then return end
	-- insert rest before self so order is restored, e.g.:
	-- {1,<2>,3}:insert(4,5) -> {1,<2>,3}:insert(5) -> {1,<2>,5,3} -> {1,<2>,4,5,3} 
	self:insert(...)
	table.insert(self.items, self.current+1, item)
end

function ringbuffer:append(item, ...)
	if not item then return end
	self.items[#self.items+1] = item
	return self:append(...)
end

function ringbuffer:removeAt(k)
	-- wrap position
	local pos = (self.current + k) % #self.items
	while pos < 1 do pos = pos + #self.items end

	-- remove item
	local item = table.remove(self.items, pos)

	-- possibly adjust current pointer
	if pos < self.current then self.current = self.current - 1 end
	if self.current > #self.items then self.current = 1 end

	-- return item
	return item
end

function ringbuffer:remove()
	return table.remove(self.items, self.current)
end

function ringbuffer:get()
	return self.items[self.current]
end

function ringbuffer:size()
	return #self.items
end

function ringbuffer:next()
	self.current = (self.current % #self.items) + 1
	return self:get()
end

function ringbuffer:prev()
	self.current = self.current - 1
	if self.current < 1 then
		self.current = #self.items
	end
	return self:get()
end

-- the module
return setmetatable({new = new},
	{__call = function(_, ...) return new(...) end})
