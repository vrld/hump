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

local assert, type = assert, type
local pairs, ipairs = pairs, ipairs
local min, math_huge = math.min, math.huge
module(...)

functions = {}
function update(dt)
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

function add(delay, func)
	assert(type(func) == "function", "second argument needs to be a function")
	functions[func] = delay
end

function addPeriodic(delay, func, count)
	assert(type(func) == "function", "second argument needs to be a function")
	local count = count or math_huge -- exploit below: math.huge - 1 = math.huge

	add(delay, function(f)
		if func(func) == false then return end
		count = count - 1
		if count > 0 then
			add(delay, f)
		end
	end)
end

function clear()
	functions = {}
end

function Interpolator(length, func)
	assert(type(func) == "function", "second argument needs to be a function")
	local t = 0
	return function(dt, ...)
		t = t + dt
		return t <= length and func((t-dt)/length, ...) or nil
	end
end

function Oscillator(length, func)
	assert(type(func) == "function", "second argument needs to be a function")
	local t = 0
	return function(dt, ...)
		t = (t + dt) % length
		return func(t/length, ...)
	end
end
