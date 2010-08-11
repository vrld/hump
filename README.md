HUMP - Helper Utilities for Massive Progression
===============================================

__HUMP__ is a small collection of tools for developing games with L&Ouml;VE.

Contents:
------------

*   *vector.lua*: powerful vector class (pure lua)
*   *class.lua*: "class" system supporting function inheritance (pure lua)
*   *camera.lua*: translate-, zoom- and rotatable camera
*   *gamestate.lua*: class to handle gamestates

Documentation
=============

vector.lua
----------

A vector class implementing everything you want to do with vectors, and some more.

### Basic ###

#### function vector(x,y)  
Creates a new vector. Element access with `v.x` and `v.y`.  
**Parameters:**

*   _[number]_ `x`: x coordinate
*   _[number]_ `y`: y coordinate

**Returns:** the vector
<br /><br />

#### function isvector(v)  
Tests for vector type.  
**Parameters:**

*   `v`: variable to test  

**Returns:** `true` if `v` is a vector
<br /><br />

#### function Vector:clone()  
Clones a vector. Use when you do not want to create references.  
**Returns:** New vector with the same coordinates.
<br /><br />

#### function Vector:unpack()  
Unpacks the vector.  
**Returns:** the coordinate tuple `x, y`

**Example:**

	v = vector(1,2)
	print(v:unpack()) -- prints "1     2"


### Operators  ###

Arithmetic (`+`, `-`, `*`, `/`) and comparative operators (`==`, `<=`, `<`) are defined.

*   `+` and `-` _only_ work on vectors. `-` is also the unary minus (e.g. `print(-vector(1,0)) -- prints (-1,0)`
*   `a * b` works on vectors and numbers:  
    -   If `a` is a number and `b` is a vector (or vice versa), the result the scalar multiplication.  
    -   If `a` and `b` both are vectors, then the result is the _dot product_.
*   `a / b` is only defined for `a` being a vector and `b` being a number. Result is the same as `a * 1/b`

`<=` and `<` sort lexically, i.e. `a <= b` is true if it holds: `a.x < b.x` or `a.y < b.y` if `a.x == b.x`


### Even more! ###

#### function vector:permul(other)  
Perform element-wise multiplication.
<br /><br />

#### function vector:len()  
Get length of vector.
<br /><br />

#### function vector:len2()  
Get squared length.
<br /><br />

#### function vector:dist(other)  
Get distance to other vector.

**Example:**

	a,b = vector(0,1), vector(1,0)
	print(a:dist(b)) -- prints 1.4142135623731`
<br /><br />

#### function vector:normalized()  
Get normalized vector. The original vector remains unchanged.
<br /><br />

#### function vector:normalize_inplace()  
Normalize vector and return it.  
**Warning:** This will change the state of all references to this vector.
<br /><br />

#### function Vector:rotated(phi)  
Get rotated vector. The original vector remains unchanged.  
**Parameters:**

*   _[number]_ `phi`: Rotation angle in radians.
<br /><br />

#### function Vector:rotate_inplace(phi)  
Rotate the vector and return it.  
**Warning:** This will change the state of all references to this vector.
<br /><br />

class.lua
---------

Simple class-like system for Lua. Supports definition of class types and inheritance of functions.
For an example how to use this, see below.


#### function Class(constructor)
Creates a new unnamed class.
**Parameters:**

*   _[optional function]_ `constructor`: A function used to construct the class. The first parameter of this function is the object, the others are parameters given upon construction.

**Example:**

	Feline = Class(function(self, size, weight)
		self.size = size self.weight = weight
	end)
	
	function Feline:stats()
		return string.format("size: %.02f, weight %.02f", self.size, self.weight) 
	end
	
	garfield = Feline(.7, 45)
	felix = Feline(.8, 12)

	print("Garfield: " .. garfield:stats(), "Felix: " .. felix:stats())
<br /><br />

#### function Class{name = name, constructor}  
Create a named class, i.e. define a __tostring metamethod. Parameters are the same as above.
Great for debugging. Both `name` and `constructor` can be omitted (but why would you want to?)

**Example:**

	Feline = Class{name = "Feline", function(self, size, weight)
		self.size = size self.weight = weight
	end}
	
	print(Feline) -- prints 'Feline'
<br /><br />

#### function Interface(name)  
Shortcut to `Class{name = name}`, i.e. a possibly named class without constructor.


#### function Inherit(class, super, ...)  
Add functions of `super` to `class`. Multiple interfaces can be defined.  
`super`'s constructor can be accessed via super.construct(self). See example below.


### Example usage ###

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

### Warning ###

Be careful when using metamethods like `__add` or `__mul`: When subclass inherits those methods
from a superclass, but does not overwrite them, the result of the operation will be of the type
superclass. Consider the following:

    A = Class(function(self, x) self.x = x end)
    function A:__add(other) return A(self.x + other.x) end
    function A:print() print("A:", self.x) end
    
    B = Class(function(self, x, y) A.construct(self, x) self.y = y end)
    Inherit(B, A)
    function B:print() print("B:", self.x, self.y) end
    function B:foo() print("foo") end
    
    one, two = B(1,2), B(3,4)
    result = one + two
    result:print()  -- prints "A:    4"
    result:foo()    -- error: method does not exist


camera.lua
----------
_Depends on vector.lua_

Camera class to display only a certain zoomed and rotated region of the game.
You can have multiple cameras in one game.

#### function Camera(pos, zoom, rotation)  
Create a new camera with position `pos`, zoom `zoom` and rotation `rotation`.
**Parameters:**

*   _[optional vector]_ `pos`: Initial position of the camera. Defaults to (0,0).
*   _[optional number]_ `zoom`: Initial zoom. Defaults to 1.
*   _[optional number]_ `rotation`: Initial rotation in radians. Defaults to 0.

**Returns:** The new camera object.
<br /><br />


#### function camera:rotate(phi)  
Rotate camera by `phi` radians. Same as `camera.rot = camera.rot + phi`.
<br /><br />


#### function camera:translate(t)  
Translate (move) camera by vector `t`. Same as `camera.pos = camera.pos + t.
<br /><br />


#### function camera:draw(func)  
Apply camera transformation to drawings in function `func`. Shortcut to
`camera:apply()` and `camera:deapply()` (see below).

**Example:**

	cam:draw(function() love.graphics.rectangle('fill', -100,-100, 200,200) end)
<br /><br />


#### function camera:apply()  
Apply camera transformations to every drawing operation until the next `camera:deapply()`.
<br /><br />


#### function camera:deapply()  
Revert camera transformations for the rest of the drawing operations.

**Example:** (equivalent to the `cam:draw()` example above)

	camera:apply()
	love.graphics.rectangle('fill', -100,-100, 200,200)
	camera:deapply()
<br /><br />


#### function camera:transform(p)  
Transform vector `p` from camera coordinates to world coordinates.
You probably won't need this, but it is the basis to `camera:mousepos()`.
<br /><br />

#### function camera:mousepos()  
Get mouse position in world coordinates, i.e. the position the users mouse
is currently when camera transformations are applied. Use this for _any_
mouse interaction with transformed objects in your game.



gamestate.lua
-------------
Useful to separate different states of your game (hence "gamestate") like
title screens, level loading, main game, etc. Each gamestate can have it's
own `update()`, `draw()`, `keyreleased()`, `keypressed()` and `mousereleased()`
which correspond to the ones defined in `love`.

Additionally, each gamestate can define a `enter` and `leave` function, which
are called when using `Gamestate.switch`. See below.

#### function Gamestate.new()  
Create a new gamestate.  
**Returns:** The new (but empty) gamestate object.


#### function Gamestate.switch(to, ...)  
Switch the gamestate.  
Calls `leave` on the currently active gamestate.  
Calls `enter(current, ...)` on the target gamestate, where
`current` is the gamestate before the switch and `...` are 
the additionals arguments given to `Gamestate.switch`.  
**Parameters:**
*    _[gamestate]_ `to`: The target gamestate.
*    `...`: Additional arguments to pass

**Returns:** the result of `to:enter(current, ...)`
<br /><br />


#### function Gamestate.update(dt)  
Calls `update(dt)` on current gamestate.
<br /><br />


#### function Gamestate.draw()  
Calls `draw()` on current gamestate.
<br /><br />


#### function Gamestate.keypressed(key, unicode)  
Calls `keypressed(key, unicode)` on current gamestate.
<br /><br />


#### function Gamestate.keyreleased(key)  
Calls `keyreleased(key` on current gamestate.
<br /><br />


#### function Gamestate.mousereleased(x,y,btn)  
Calls `mousereleased(x,y,btn) on the current gamestate.
<br /><br />


#### Gamestate.registerEvents()  
Registers all above events so you don't need to call then in your
`love.*` routines. It is an error to call this anywhere else than
`love.load()`, since it overwrites the callbacks. Dont worry though,
your callbacks will still be executed.


License
=======
Yay, *free software*:

> Copyright (c) 2010 Matthias Richter  
>  
> Permission is hereby granted, free of charge, to any person obtaining a copy  
> of this software and associated documentation files (the "Software"), to deal  
> in the Software without restriction, including without limitation the rights  
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
> copies of the Software, and to permit persons to whom the Software is  
> furnished to do so, subject to the following conditions:  
>  
> The above copyright notice and this permission notice shall be included in  
> all copies or substantial portions of the Software.  
>  
> Except as contained in this notice, the name(s) of the above copyright holders  
> shall not be used in advertising or otherwise to promote the sale, use or  
> other dealings in this Software without prior written authorization.  
>  
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  
> THE SOFTWARE.  
