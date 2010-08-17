local Vector = {}
Vector.__index = Vector

function vector(x,y)
	local v = {x = x or 0, y = y or 0}
	setmetatable(v, Vector)
	return v
end

function isvector(v)
	return getmetatable(v) == Vector
end

function Vector:clone()
	return vector(self.x, self.y)
end

function Vector:unpack()
	return self.x, self.y
end

function Vector:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function Vector.__unm(a)
	return vector(-a.x, -a.y)
end

function Vector.__add(a,b)
	assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
	return vector(a.x+b.x, a.y+b.y)
end

function Vector.__sub(a,b)
	assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expexted)")
	return vector(a.x-b.x, a.y-b.y)
end

function Vector.__mul(a,b)
	if type(a) == "number" then
		return vector(a*b.x, a*b.y)
	elseif type(b) == "number" then
		return vector(b*a.x, b*a.y)
	else
		assert(isvector(a) and isvector(b), "Mul: wrong argument types (<vector> or <number> expected)")
		return a.x*b.x + a.y*b.y
	end
end

function Vector.__div(a,b)
	assert(isvector(a) and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
	return vector(a.x / b, a.y / b)
end

function Vector.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function Vector.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function Vector.permul(a,b)
	assert(isvector(a) and isvector(b), "permul: wrong argument types (<vector> expected)")
	return vector(a.x*b.x, a.y*b.y)
end

function Vector:len2()
	return self * self
end

function Vector:len()
	return math.sqrt(self*self)
end

function Vector.dist(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	return (b-a):len()
end

function Vector:normalize_inplace()
	local l = self:len()
	self.x, self.y = self.x / l, self.y / l
	return self
end

function Vector:normalized()
	return self / self:len()
end

function Vector:rotate_inplace(phi)
	local c, s = math.cos(phi), math.sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function Vector:rotated(phi)
	return self:clone():rotate_inplace(phi)
end

function Vector:perpendicular()
    return vector(-self.y, self.x)
end

function Vector:projectOn(v)
    assert(isvector(v), "invalid argument: cannot project onto anything other than a vector.")
    return (self * v) * v / v:len2()
end
