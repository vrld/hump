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

local functions = {}
local function update(dt)
	local to_remove = {}
	for func, delay in pairs(functions) do
		delay = delay - dt
		if delay <= 0 then
			to_remove[#to_remove+1] = func
		end
		functions[func] = delay
	end
	for _,func in ipairs(to_remove) do
		functions[func] = nil
		func(func)
	end
end

local function add(delay, func)
	assert(not functions[func], "Function already scheduled to run.")
	functions[func] = delay
	return func
end

local function addPeriodic(delay, func, count)
	local count = count or math.huge -- exploit below: math.huge - 1 = math.huge

	return add(delay, function(f)
		if func(func) == false then return end
		count = count - 1
		if count > 0 then
			add(delay, f)
		end
	end)
end

local function cancel(func)
	functions[func] = nil
end

local function clear()
	functions = {}
end

local function Interpolator(length, func)
	local t = 0
	return function(dt, ...)
		t = t + dt
		return t <= length and func((t-dt)/length, ...) or nil
	end
end

local function Oscillator(length, func)
	local t = 0
	return function(dt, ...)
		t = (t + dt) % length
		return func(t/length, ...)
	end
end

-- the module
return {
	update       = update,
	add          = add,
	addPeriodic  = addPeriodic,
	cancel       = cancel,
	clear        = clear,
	Interpolator = Interpolator,
	Oscillator   = Oscillator
}
