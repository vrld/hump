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

local function __NULL__() end
function Class(constructor)
	-- check name and constructor
	local name = '<unnamed class>'
	if type(constructor) == "table" then
		if constructor.name then name = constructor.name end
		constructor = constructor[1]
	end
	assert(not constructor or type(constructor) == "function",
		string.format('%s: constructor has to be nil or a function', name))

	-- build class
	local c = {}
	c.__index = c
	c.__tostring = function() return string.format("<instance of %s>", name) end
	c.construct = constructor or __NULL__

	local meta = {
		__call = function(self, ...)
			local obj = {}
			self.construct(obj, ...)
			return setmetatable(obj, self)
		end,
		__tostring = function() return tostring(name) end
	}

	return setmetatable(c, meta)
end
function Interface(name) return Class{name = name or "<unnamed interface>"} end

function Inherit(class, interface, ...)
	if not interface then return end

	-- __index and construct are not overwritten as for them class[name] is defined
	for name, func in pairs(interface) do
		if not class[name] and type(func) == "function" then
			class[name] = func
		end
	end

	Inherit(class, ...)
end
