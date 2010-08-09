HUMP - Helper Utilities for Massive Progression
===============================================

__HUMP__ is a small collection of tools for developing games with L&Ouml;VE.

Contents:
------------

* *vector.lua*: powerful vector class (pure lua)
* *class.lua*: "class" system supporting function inheritance
* *camera.lua*: translate-, zoom- and rotatable camera
* *gamestate.lua*: class to handle gamestates

Documentation
=============

vector.lua
----------

A vector class implementing everything you want to do with vectors, and some more.

#### Basic ####

**function vector(x,y)**<br />
Creates a new vector. Element access with `v.x` and `v.y`.<br />
*Parameters:*

* `x` (_number_) - x coordinate
* `y` (_number_) - y coordinate

*Returns:* the vector


**function isvector(v)**<br />
Tests for vector type.<br />
*Parameters:*

* `v` - variable to test<br />

*Returns:* `true` if `v` is a vector


**function Vector:clone()**<br />
Clones a vector. Use when you do not want to create references.<br />
*Returns:* New vector with the same coordinates.


**function Vector:unpack()**<br />
Unpacks the vector.<br />
*Returns:* the coordinate tuple `x, y`

*Example:*

	v = vector(1,2)
	print(v:unpack()) -- prints "1     2"


#### Operators  ####

Arithmetic (`+`, `-`, `*`, `/`) and comparative operators (`==`, `<=`, `<`) are defined.

* `+` and `-` _only_ work on vectors. `-` is also the unary minus (e.g. `print(-vector(1,0)) -- prints (-1,0)`
* `a * b` works on vectors and numbers: ==<br />==If `a` is a number and `b` is a vector (or vice versa), the result the scalar multiplication. If `a` and `b` are vectors, then the result is the _dot product_.|
* `a / b` is only defined for `a` being a vector and `b` being a number. Result is the same as `a * 1/b`

`<=` and `<` sort lexically, i.e. `a <= b` if it holds: `a.x < b.x` or `a.y < b.y` if `a.x == b.x`


#### Even more! ####

**function vector:permul(other)**<br />
Perform element-wise multiplication.


**function vector:len()**<br />
Get length of vector.


**function vector:len2()**<br />
Get squared length.


**function vector:dist(other)**<br />
Get distance to other vector.

*Example:*

	a,b = vector(0,1), vector(1,0)
	print(a:dist(b)) -- prints 1.4142135623731`


**function vector:normalized()**<br />
Get normalized vector. The original vector remains unchanged.


**function vector:normalize_inplace()**<br />
Normalize vector and return it.<br />
*Warning:* This will change the state of all references to this vector.


**function Vector:rotated(phi)**<br />
Get rotated vector. The original vector remains unchanged.<br />
*Parameters:*

* `phi` - Rotation angle in radians.


**function Vector:rotate_inplace(phi)**<br />
Rotate the vector and return it.<br />
*Warning:* This will change the state of all references to this vector.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

class.lua
---------

Simple class-like system for Lua. Supports definition of class types and inheritance of functions.
For an example how to use this, see below.

**function Class([constructor])**<br/>
Creates a new unnamed class.
*Parameters:*

* _optional_ `constructor` - A function used to construct the class. The first parameter of this function is the object, the others are parameters given upon construction.

*Example:*

	Feline = Class(function(self, size, weight)
		self.size = size self.weight = weight
	end)
	
	function Feline:stats()
		return string.format("size: %.02f, weight %.02f", self.size, self.weight) 
	end
	
	garfield = Feline(.7, 45)
	felix = Feline(.8, 12)

	print("Garfield: " .. garfield:stats(), "Felix: " .. felix:stats())


**function Class{name = name, constructor}**<br />
Create a named class, i.e. define a __tostring metamethod. Parameters are the same as above.
Great for debugging. Both `name` and `constructor` can be omitted (but why would you want to?)

*Example:*

	Feline = Class{name = "Feline", function(self, size, weight)
		self.size = size self.weight = weight
	end}
	
	print(Feline) -- prints 'Feline'


**function Interface([name])**<br />
Shortcut to `Class{name = name}`, i.e. a possibly named class without constructor.


**function Inherit(class, super, ...)**<br />
Add functions of `super` to `class`. Multiple interfaces can be defined.<br />
`super`'s constructor can be accessed via super.construct(self). See example below.


#### Example usage ####

	Feline = Class{name = "Feline", function(self, size, weight)
		self.size = size self.weight = weight
	end}
	
	function Feline:stats()
		return string.format("size: %.02f, weight %.02f", self.size, self.weight) 
	end
	
	function Feline:speak() print("meow") end
	
	
	Cat = Class{name = "Cat", function(self, name, size, weight)
		Feline.construct(self, size, weight)
		self.name = name
	end}
	Inherit(Cat, Feline)
	
	function Cat:stats()
		return string.format("name: %s, %s", self.name, Feline.stats(self))
	end
	
	
	Tiger = Class{name = "tiger", function(self, size, weight)
		Feline.construct(self, size, weight)
	end}
	Inherit(Tiger, Feline)
	
	function Tiger:speak() print("ROAR!") end
	
	felix = Cat("Felix", .8, 12)
	hobbes = Tiger(2.2, 68)
	
	print(felix:stats(), hobbes:stats())
	felix:speak()
	hobbes:speak()

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

camera.lua
----------
_Depends on vector.lua_

**TODO**

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

gamestate.lua
-------------
**TODO**
