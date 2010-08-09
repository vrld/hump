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
