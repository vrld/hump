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

Timer = {}
Timer.functions = {}
function Timer.update(dt)
	for func, delay in pairs(Timer.functions) do
		delay = delay - dt
		if delay <= 0 then
			Timer.functions[func] = nil
			func(func)
		else
			Timer.functions[func] = delay
		end
	end
end

function Timer.add(delay, func)
	assert(type(func) == "function", "second argument needs to be a function")
	Timer.functions[func] = delay
end

function Timer.addPeriodic(delay, func, count)
	assert(type(func) == "function", "second argument needs to be a function")
	if count then
		Timer.add(delay, function(f) func(func) count = count - 1 if count > 0 then Timer.add(delay, f) end end)
	else
		Timer.add(delay, function(f) func(func) Timer.add(delay, f) end)
	end
end

function Timer.clear()
	Timer.functions = {}
end

function Interpolator(length, func)
	assert(type(func) == "function", "second argument needs to be a function")
	local t = 0
	return function(dt)
		t = t + dt
		return t <= length or nil, func(math.min(1, (t-dt)/length))
	end
end
