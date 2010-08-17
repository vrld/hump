local ringbuffer = {}
ringbuffer.__index = ringbuffer

function Ringbuffer(...)
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
	self:append(...)
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
	self.current = self.current + 1
	if self.current > #self.items then
		self.current = 1
	end
	return self:get()
end

function ringbuffer:prev()
	self.current = self.current - 1
	if self.current < 1 then
		self.current = #self.items
	end
end
