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

local Timer = {}
Timer.__index = Timer

local function _nothing_() end

local function new()
	return setmetatable({functions = {}}, Timer)
end

function Timer:update(dt)
	local to_remove = {}
	for handle, delay in pairs(self.functions) do
		delay = delay - dt
		if delay <= 0 then
			to_remove[#to_remove+1] = handle
		end
		self.functions[handle] = delay
		handle.func(dt, delay)
	end
	for _,handle in ipairs(to_remove) do
		self.functions[handle] = nil
		handle.after(handle.after)
	end
end

function Timer:do_for(delay, func, after)
	local handle = {func = func, after = after}
	self.functions[handle] = delay
	return handle
end

function Timer:add(delay, func)
	return self:do_for(delay, _nothing_, func)
end

function Timer:addPeriodic(delay, func, count)
	local count = count or math.huge -- exploit below: math.huge - 1 = math.huge

	return self:add(delay, function(f)
		if func(func) == false then return end
		count = count - 1
		if count > 0 then
			self:add(delay, f)
		end
	end)
end

function Timer:cancel(handle)
	self.functions[handle] = nil
end

function Timer:clear()
	self.functions = {}
end

-- default timer
local default = new()

-- the module
return setmetatable({
	new          = new,
	update       = function(...) return default:update(...) end,
	do_for       = function(...) return default:do_for(...) end,
	add          = function(...) return default:add(...) end,
	addPeriodic  = function(...) return default:addPeriodic(...) end,
	cancel       = function(...) return default:cancel(...) end,
	clear        = function(...) return default:clear(...) end,
}, {__call = new})
