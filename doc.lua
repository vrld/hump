Module { name  = "hump.gamestate",
	title = "Gamestate",
	short = "A gamestate system",
	long  = [===[
	A gamestate encapsulates independent data an behaviour into a single entity.

	A typical game could consist of a {** menu-state}, a {** level-state} and a {** game-over-state}.]===],

	Section { name    = "callbacks",
		title   = "Gamestate Callbacks",
		content = [===[
		A gamestate can define (nearly) all callbacks that LÖVE defines. In addition,
		there are callbacks for entering and leaving a state.:

		[|
		{# init()}               | Called once before entering the state. See {# switch()}.
		{# enter(previous, ...)} | Called when entering the state. See {# switch()}.
		{# leave()}              | Called when leaving a state. See {# switch()}.
		{# update()}             | Update the game state. Called every frame.
		{# draw()}               | Draw on the screen. Called every frame.
		{# focus()}              | Called if the window gets or looses focus.
		{# keypressed()}         | Triggered when a key is pressed.
		{# keyreleased()}        | Triggered when a key is released.
		{# mousepressed()}       | Triggered when a mouse button is pressed.
		{# mousereleased()}      | Triggered when a mouse button is released.
		{# joystickpressed()}    | Triggered when a joystick button is pressed.
		{# joystickreleased()}   | Triggered when a joystick button is released.
		{# quit()}               | Called on quitting the game. Only called on the active gamestate.
		|]

		When using {# registerEvents()}, all these callbacks will receive the same
		arguments as the [[http://love2d.org/wiki/love|LÖVE callbacks]] do.]===],
		example = [===[
menu = Gamestate.new()
function menu:init() -- run only once
    self.background = love.graphics.newImage('bg.jpg')
    Buttons.initialize()
end

function menu:enter(previous) -- run every time the state is entered
    Buttons.setActive(Buttons.start)
end

function menu:update(dt)
    Buttons.update(dt)
end

function menu:draw()
    love.graphics.draw(self.background, 0, 0)
    Buttons.draw()
end

function menu:keyreleased(key)
    if key == 'up' then
        Buttons.selectPrevious()
    elseif key == 'down' then
        Buttons.selectNext()
    elseif
        Buttons.active:onClick()
    end
end

function menu:mousereleased(x,y, mouse_btn)
    local button = Buttons.hovered(x,y)
    if button then
        Button.select(button)
        if mouse_btn == 'l' then
            button:onClick()
        end
    end
end]===]
	},

	Function { name    = "new",
		short   = "Create a new gamestate.",
		long    = "Declare a new gamestate. A gamestate can define several [[callbacks]]",
		params  = {},
		returns = {
			{"Gamestate", "The new gamestate."}
		},
		example = "menu = Gamestate.new()",
	},

	Function { name    = "switch",
		short   = "Switch to gamestate.",
		long    = [===[
		Switch to a gamestate, with any additional arguments passed to the new state.

		Switching a gamestate will call the leave() callback on the current gamestate,
		replace the current gamestate with to, call the init() function if the state
		was not yet inialized and finally call enter(old_state, ...) on the new gamestate.]===],
		params = {
			{"Gamestate", "to", "Target gamestate."},
			{"mixed", "...", "Additional arguments to pass to to:enter()."}
		},
		returns = {
			{"mixed", "The results of to:enter()"}
		},
		example = "Gamestate.switch(game, level_two)",
	},

	Function { name = {
			"update",
			"draw",
			"focus",
			"keypressed",
			"keyreleased",
			"mousepressed",
			"mousereleased",
			"joystickpressed",
			"joystickreleased",
			"quit",
		},
		short = {
			"Update current gamestate.",
			"Draw the current gamestate.",
			"Inform current gamestate of a focus event.",
			"Inform current gamestate of a keypressed event.",
			"Inform current gamestate of a keyreleased event.",
			"Inform current gamestate of a mousepressed event.",
			"Inform current gamestate of a mousereleased event.",
			"Inform current gamestate of a joystickpressed event.",
			"Inform current gamestate of a joystickreleased event.",
			"Inform current gamestate of a quit event.",
		},
		long = [===[
		Calls the corresponding function on the current gamestate (see [[callbacks]]).

		Only needed when not using registerEvents().]===],
		params = {
			{"mixed", "...", "Arguments to pass to the corresponding [[callbacks|callback]]."},
		},
		returns = {
			{"mixed", "The results of the callback function."},
		},
		example = [===[
function love.update(dt)
    Gamestate.update(dt)
end

function love.draw()
    local mx,my = love.mouse.getPosition()
    Gamestate.draw(mx, my)
end

function love.keypressed(key, code)
    Gamestate.keypressed(key, code)
end]===],
	},

	Function { name = "registerEvents",
		short = "Automatically do all of the above when needed.",
		long = [===[
		Register all love callbacks to call Gamestate.update(), Gamestate.draw(), etc. automatically.

		This is by done by overwriting the love callbacks, e.g.:
		{## local old_update = love.update
function love.update(dt)
    old_update(dt)
    Gamestate.current:update(dt)
end}

{!! Note:} Only works when called in {# love.load()} or any other function that is executed
after the whole file is loaded.]===],
		params = {},
		returns = {},
		example = [===[
function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end]===],
	},
}

Module { name = "hump.timer",
	title = "Timer",
	short = "Delayed function calls and helpers for interpolating functions.",
	long = [===[
	hump.timer provides a simple interface to use delayed functions, i.e. functions
	that will be executed after some amount time has passed. For example, you can use
	a timer to set the player invincible for a short amount of time.

	In addition, the module offers facilities to create functions that interpolate
	or oscillate over time. An interpolator could fade the color or a text message,
	whereas an oscillator could be used for the movement of foes in a shmup.]===],

	Function { name = "add",
		short = "Add a timed function.",
		long = [===[
		Add a timed function. The function will be executed after {# delay} seconds
		have elapsed, given that update() is called every frame.

		Note that there is no guarantee that the delay will not be exceeded, it is
		only guaranteed that the function will not be executed {** before} the delay
		has passed.

		{# func} will receive itself as only parameter. This is useful to implement
		periodic behavior (see the example).]===],
		params = {
			{"number", "delay", "Number of seconds the function will be delayed."},
			{"function", "func", "The function to be delayed."},
		},
		returns = {},
		example = {
			[===[
-- grant the player 5 seconds of immortality
player.isInvincible = true
Timer.add(5, function() player.isInvincible = false end)]===],
			[===[
-- print "foo" every second. See addPeriodic.
Timer.add(1, function(func) print("foo") Timer.add(1, func) end)]===]
		},
	},

	Function { name = "addPeriodic",
		short = "Add a periodic function.",
		long = [===[
		Add a function that will be called {# count} times every {# delay} seconds.

		If {# count} is omitted, the function will be called until it returns {# false}
		or clear() is called.]===],
		params = {
			{"number", "delay", "Number of seconds between two consecutive function calls."},
			{"function", "func", "The function to be called periodically."},
			{"number", "count", "Number of times the function is to be called.", optional = true},
		},
		returns = {},
		example = {
			"Timer.addPeriodic(1, function() lamp:toggleLight() end)",
			"Timer.addPeriodic(0.3, function() mothership:spawnFighter() end, 5)",
			[===[-- flicker player's image as long as he is invincible
Timer.addPeriodic(0.1, function()
    player:flipImage()
    return player.isInvincible
end)]===],
		},
	},

	Function { name = "clear",
		short = "Remove all timed and periodic functions.",
		long = "Remove all timed and periodic functions. Functions that have not yet been executed will discarded.",
		params = {},
		returns = {},
		example = "Timer.clear",
	},

	Function { name = "update",
		short = "Update timed functions.",
		long = "Update timers and execute functions if the deadline is reached. Use this in love.update(dt).",
		params = {
			{"number", "dt", "Time that has passed since the last update()."},
		},
		returns = {},
		example = [===[
function love.update(dt)
    do_stuff()
    Timer.update(dt)
end]===],
	},

	Function { name = "Interpolator",
		short = "Create a new interpolating function.",
		long = [===[
		Create a wrapper for an interpolating function, i.e. a function that acts
		depending on how much time has passed.

		The wrapper will have the prototype:
		{## function wrapper(dt, ...) }
		where {# dt} is the time that has passed since the last call of the wrapper
		and {# ...} are arguments passed to the interpolating function. It will return
		whatever the interpolating functions returns if the interpolation is not yet
		finished or nil if the interpolation is done.

		The prototype of the interpolating function is:
		{## function interpolator(fraction, ...) }
		where {# fraction} is a number between 0 and 1 depending on how much time has
		passed and {# ...} are additional arguments supplied to the wrapper.]===],
		params = {
			{"number", "length", "Interpolation length in seconds."},
			{"function", "func", "Interpolating function."},
		},
		returns = {
			{"function", "The wrapper function."}
		},
		example = [===[
fader = Timer.Interpolator(5, function(frac, r,g,b)
    love.graphics.setBackgroundColor(frac*r,frac*g,frac*b)
end)

function love.update(dt)
    fader(dt, 255,255,255)
end]===],
	},

	Function { name = "Oscillator",
		short = "Create a new oscillating function.",
		long = [===[
		Create a wrapper for an oscillating function, which is basically a looping
		interpolating function.

		The function prototypes are the same as with Interpolator():
		{## function wrapper(dt, ...) }
		{## function oscillator(fraction, ...) }

		As with Interpolator, the wrapper will return whatever {# oscillator()} returns.]===],
		params = {
			{"number", "length", "Length of one interpolation period."},
			{"function", "func", "Oscillating function."},
		},
		returns = {
			{"function", "The wrapper function."}
		},
		example = [===[
mover = Timer.Oscillator(10, function(frac)
   return 400 + 300 * math.sin(2*math.pi*frac)
end)

local xpos = 100
function love.update(dt)
    xpos = mover(dt)
end

function love.draw()
    love.graphics.circle('fill', xpos, 300, 80, 36)
end]===],
	},
}

Module { name = "hump.vector",
	title = "vector",
	short = "2D vector math",
	long = [===[
	A handy 2D vector class providing most of the things you do with vectors.

	You can access the individual coordinates by using {# vec.x} and {# vec.y}.]===],

	Section { name = "operators",
		title = "Arithmetics and relations",
		content = [===[
		Vector arithmetic is implemented by using {# __add}, {# __mul} and other metamethods:

		[|
		{# vector + vector = vector}  | Component wise sum.
		{# vector - vector = vector}  | Component wise difference.
		{# vector * vector = number}  | [[http://en.wikipedia.org/wiki/Dot_product|Dot product]].
		{# number * vector = vector}  | Vector scaling ([[http://en.wikipedia.org/wiki/Scalar_multiplication|scalar multiplication]]).
		{# vector * number = vector}  | Vector scaling.
		{# vector / number = vector}  | Vector scaling.
		|]

		Relational operators are defined, too:

		[|
		a == b | {# true}, if {# a.x == b.x} and {# a.y == b.y}.
		a <= b | {# true}, if {# a.x <= b.x} and {# a.y <= b.y}.
		a < b  | Lexical sort: {# true}, if {# a.x < b.x} or {# a.x == b.x} and {# a.y < b.y}.
		|]]===],
		example = [===[
-- acceleration, player.velocity and player.position are vectors
acceleration = vector(0,-9)
player.velocity = player.velocity + acceleration * dt
player.position = player.position + player.velocity * dt]===],
	},

	Function { name = "new",
		short = "Create a new vector.",
		long = "Create a new vector.",
		params = {
			{"numbers", "x,y", "Coordinates."}
		},
		returns = {
			{"vector", "The vector."}
		},
		example = {
			"a = vector.new(10,10)",
			[===[-- as a shortcut, you can call the module like a function:
vector = require "hump.vector"
a = vector(10,10)]===],
		},
	},

	Function { name = "isvector",
		short = "Test if value is a vector.",
		long = "Test whether a variable is a vector.",
		params = {
			{"mixed", "v", "The variable to test."}
		},
		returns = {
			{"boolean", "{# true} if {# v} is a vector, {# false} otherwise"}
		},
		example = [===[
if not vector.isvector(v) then
    v = vector(v,0)
end]===],
	},

	Function { name = "vector:clone",
		short = "Copy a vector.",
		long = [===[
		Copy a vector. Simply assigning a vector a vector to a variable will create
		a reference, so when modifying the vector referenced by the new variable
		would also change the old one:
		{## a = vector(1,1) -- create vector
b = a           -- b references a
c = a:clone()   -- c is a copy of a
b.x = 0         -- changes a,b and c
print(a,b,c)    -- prints '(1,0), (1,0), (1,1)'}]===],
		params = {},
		returns = {
			{"vector", "Copy of the vector"}
		},
		example = "copy = original:clone",
	},

	Function { name = "vector:unpack",
		short = "Extract coordinates.",
		long = "Extract coordinates.",
		params = {},
		returns = {
			{"numbers", "The coordinates"}
		},
		example = {
			"x,y = pos:unpack",
			"love.graphics.draw(self.image, self.pos:unpack())"
		},
	},

	Function { name = "vector:permul",
		short = "Per element multiplication.",
		long = [===[
		Multiplies vectors coordinate wise, i.e. {# result = vector(a.x * b.x, a.y * b.y)}.

		This does not change either argument vectors, but creates a new one.]===],
		params = {
			{"vector", "other", "The other vector"}
		},
		returns = {
			{"vector", "The new vector as described above"}
		},
		example = "scaled = original:permul(vector(1,1.5))",
	},

	Function { name = "vector:len",
		short = "Get length.",
		long = "Get length of a vector, i.e. {# math.sqrt(vec.x * vec.x + vec.y * vec.y)}.",
		params = {},
		returns = {
			{"number", "Length of the vector."}
		},
		example = "distance = (a - b):len()",
	},

	Function { name = "vector:len2",
		short = "Get squared length.",
		long = "Get squared length of a vector, i.e. {# vec.x * vec.x + vec.y * vec.y}.",
		params = {},
		returns = {
			{"number", "Squared length of the vector."}
		},
		example = [===[
-- get closest vertex to a given vector
closest, dsq = vertices[1], (pos - vertices[1]):len2()
for i = 2,#vertices do
    local temp = (pos - vertices[i]):len2()
    if temp < dsq then
        closest, dsq = vertices[i], temp
    end
end]===],
	},

	Function { name = "vector:dist",
		short = "Distance to other vector.",
		long = "Get distance of two vectors. The same as {# (a - b):len()}.",
		params = {
			{"vector", "other", "Other vector to measure the distance to."},
		},
		returns = {
			{"number", "The distance of the vectors."}
		},
		example = [===[
-- get closest vertex to a given vector
-- slightly slower than the example using len2()
closest, dist = vertices[1], pos:dist(vertices[1])
for i = 2,#vertices do
    local temp = pos:dist(vertices[i])
    if temp < dist then
        closest, dist = vertices[i], temp
    end
end]===],
	},

	Function { name = "vector:normalized",
		short = "Get normalized vector.",
		long = [===[
		Get normalized vector, i.e. a vector with the same direction as the input
		vector, but with length 1.

		This does not change the input vector, but creates a new vector.]===],
		params = {},
		returns = {
			{"vector", "Vector with same direction as the input vector, but length 1."}
		},
		example = "direction = velocity:normalized()"
	},

	Function { name = "vector:normalize_inplace",
		short = "Normalize vector in-place.",
		long = [===[
		Normalize a vector, i.e. make the vector unit length. Great to use on
		intermediate results.

		{!! This modifies the vector. If in doubt, use {# vector:normalized()}.}]===],
		params = {},
		returns = {
			{"vector", "Itself - the normalized vector"}
		},
		example = "normal = (b - a):perpendicular():normalize_inplace()"
	},

	Function { name = "vector:rotated",
		short = "Get rotated vector.",
		long = [===[
		Get a rotated vector.

		This does not change the input vector, but creates a new vector.]===],
		params = {
			{"number", "phi", "Rotation angle in [[http://en.wikipedia.org/wiki/Radians|radians]]."}
		},
		returns = {
			{"vector", "The rotated vector"}
		},
		example = [===[
-- approximate a circle
circle = {}
for i = 1,30 do
    local phi = 2 * math.pi * i / 30
    circle[#circle+1] = vector(0,1):rotated(phi)
end]===],
		sketch = {
			"vector-rotated.png", "sketch of rotated vectors", width = 260, height = 171
		},
	},

	Function { name = "vector:rotate_inplace",
		short = "Rotate vector in-place.",
		long = [===[
		Rotate a vector in-place. Great to use on intermediate results.

		{!! This modifies the vector. If in doubt, use {# vector:rotate()}}]===],
		params = {
			{"number", "phi", "Rotation angle in [[http://en.wikipedia.org/wiki/Radians|radians]]."}
		},
		returns = {
			{"vector", "Itself - the rotated vector"}
		},
		example = [===[
-- ongoing rotation
spawner.direction:rotate_inplace(dt)]===],
	},

	Function { name = "vector:perpendicular",
		short = "Get perpendicular vector.",
		long = [===[
		Quick rotation by 90°. Creates a new vector. The same as (but faster):
		{## vec:rotate(math.pi/2)}]===],
		params = {},
		returns = {
			{"vector", "A vector perpendicular to the input vector"}
		},
		example = "normal = (b - a):perpendicular():normalize_inplace()",
		sketch = {
			"vector-perpendicular.png", "sketch of perpendicular vectors", width = 267, height = 202
		},
	},

	Function { name = "vector:projectOn",
		short = "Get projection onto another vector.",
		long = "Project vector onto another vector (see sketch).",
		params = {
			{"vector", "v", "The vector to project on."}
		},
		returns = {
			{"vector", "The projected vector."}
		},
		example = "velocity_component = velocity:projectOn(axis)",
		sketch = {
			"vector-projectOn.png", "sketch of vector projection", width = 605, height = 178
		},
	},

	Function { name = "vector:mirrorOn",
		short = "Mirrors vector on other vector",
		long = "Mirrors vector on the axis defined by the other axis.",
		params = {
			{"vector", "v", "The vector to mirror on."}
		},
		returns = {
			{"vector", "The mirrored vector."}
		},
		example = "deflected_velocity = ball.velocity:mirrorOn(surface)",
	},

	Function { name = "vector:cross",
		short = "Cross product of two vectors.",
		long = [===[
		Get cross product of both vectors.

		For the math geeks:

		The cross product is usually not defined for 2D vectors. To still get a
		meaningful result, we treat the vectors as being 3D vectors {** (x,y,0)}. The
		cross product of both vectors has just a z-component, and this is what this
		function returns. It's also the determinant of both vectors {** d = det(a,b)}
		which is the area of the parallelogram spanned by both vectors.]===],
		params = {
			{"vector", "other", "Vector to compute the cross product with."}
		},
		returns = {
			{"number", "Cross product of both vectors."}
		},
		example = "parallelogram_area = a:cross(b)"
	},
}

Module { name = "hump.class",
	title = "Class",
	short = "Class-based object orientated programming for Lua",
	long  = "A small, fast class implementation with multiple inheritance support",

	Function { name = "new",
		short = "Declare a new class.",
		long = [===[
		Declare a new class.

		The constructor will receive the newly create object as first argument.

		If no name is given, the module will try to guess the name based on the
		variable name the class is assigned to. Note that this can only work for
		global variables.

		You can check if an object is an instance of a class using {# object:is_a()}.

		The name of the variable that holds the module can be used as a shortcut to
		{# new()} (see example).]===],
		params = { table_argument = true,
			{"function", "constructor", "Class constructor. Can be accessed with {# theclass.construct(object, ...)}", optional = true},
			{"string", "the_name", "Class name (used only to make the class compliant to {# tostring()).", name = "name", optional = true},
			{"class or table of classes", "super", "Classes to inherit from. Can either be a single class or a table of classes", name = "inherits", optional = true},
		},
		returns = {
			{"class", "The class"}
		},
		example = {
[===[
Class = require 'hump.class' -- `Class' is now a shortcut to new()

-- define class with implicit name  'Feline'
Feline = Class{function(self, size, weight)
    self.size = size
    self.weight = weight
end}
print(Feline) -- prints 'Feline'

-- define class method
function Feline:stats()
    return string.format("size: %.02f, weight %.02f", self.size, self.weight)
end

-- create two objects
garfield = Feline(.7, 45)
felix = Feline(.8, 12)

print("Garfield: " .. garfield:stats(), "Felix: " .. felix:stats())
]===],
[===[
Class = require 'hump.class'

-- define class with explicit name 'Feline'
Feline = Class{name = "Feline", function(self, size, weight)
    self.size = size
    self.weight = weight
end}

garfield = Feline(.7, 45)
print(Feline, garfield) -- prints 'Feline	<instance of Feline>'
]===],
[===[
Class = require 'hump.class'
A = Class{}
function A:foo()
    print('foo')
end

B = Class{}
function B:bar()
    print('bar')
end

-- single inheritance
C = Class{inherits = A}
instance = C()
instance:foo() -- prints 'foo'

-- multiple inheritance
D = Class{inherits = {A,B}}
instance = D()
instance:foo() -- prints 'foo'
instance:bar() -- prints 'bar'
]===],
		},
	},

	Function { name = "class.construct",
		short = "Call class constructor.",
		long = [===[
		Calls class constructor of a class on an object

		Derived classes use this function their constructors to initialize the
		parent class(es) portions of the object.]===],
		params = {
			{"Object", "object", "The object. Usually {# self}."},
			{"mixed", "...", "Arguments to pass to the constructor"},
		},
		returns = {
			{"mixed", "Whatever the parent class constructor returns"},
		},
		example = {
[===[
Class = require 'hump.class'

Shape = Class{function(self, area)
    self.area = area
end}
function Shape:__tostring()
    return "area = " .. self.area
end

Rectangle = Class{inherits = Shape, function(self, width, height)
    Shape.construct(self, width * height)
    self.width  = width
    self.height = height
end}
function Rectangle:__tostring()
    local strs = {
        "width = " .. self.width,
        "height = " .. self.height,
        Shape.__tostring(self)
    },
    return table.concat(strs, ", ")
end

print( Rectangle(2,4) ) -- prints 'width = 2, height = 4, area = 8'
]===],
[===[
Menu = Class{function(self)
    self.entries = {}
end}
function Menu:add(title, entry)
    self.entries[#self.entries + 1] = entry
end
function Menu:display()
    -- ...
end

Entry = Class{function(self, title, command)
    self.title = title
    self.command = command
end}
function Entry:execute()
    return self.command()
end

Submenu = Class{inherits = {Menu, Entry}, function(self, title)
    Menu.construct(self)
    -- redirect self:execute() to self:display()
    Entry.construct(self, title, Menu.display)
end}
]===]
		},

	},

	Function { name = "class:inherit",
		short = "Explicit class inheritance/mixin support.",
		long = [===[
		Inherit functions and variables of another class, if they are not already
		defined for the class. This is done by simply copying the functions and
		variables over to the subclass. The Lua rules for copying apply
		(i.e. tables are referenced, functions and primitive types are copied by value).

		{!! Be careful with changing table values in a subclass: This will change the
		value in the parent class too.}

		If more than one parent class is specified, inherit from all of these, in
		order of occurrence. That means that when two parent classes define the same
		method, the one from the first class will be inherited.

		Note: {# class:inherit()} doesn't actually care if the arguments supplied are
		hump classes. Just any table will work.]===],
		params = {
			{"tables", "...", "Parent classes to inherit from"}
		},
		returns = {},
		example = [===[
Class = require 'hump.class'

Entity = Class{function(self)
    GameObjects.register(self)
end}

Collidable = {
    dispatch_collision = function(self, other, dx, dy)
        if self.collision_handler[other.type])
            return collision_handler[other.type](self, other, dx, dy)
        end
        return collision_handler["*"](self, other, dx, dy)
    end,

    collision_handler = {["*"] = function() end},
}

Spaceship = Class{function(self)
    self.type = "Spaceship"
    -- ...
end}

-- make Spaceship collidable
Spaceship:inherit(Collidable)

function Spaceship:collision_handler["Spaceship"](other, dx, dy)
    -- ...
end
]===]
	},

	Function { name = "object:is_a",
		short = "Test object's type.",
		long = "Tests whether an object is an instance of a class.",
		params = {
			{"class", "cls", "Class to test. Note: this is the class itself, {** not} the name of the class."}
		},
		returns = {
			{"Boolean", "{# true} if the object is an instance of the class, {# false} otherwise"}
		},
		example = [===[
Class = require 'hump.class'

A = Class{}
B = Class{inherits=A}
C = Class{inherits=B}
a, b, c = A(), B(), C()
print(a:is_a(A), a:is_a(B), a:is_a(C)) --> true   false  false
print(b:is_a(A), b:is_a(B), b:is_a(C)) --> true   true   false
print(c:is_a(A), c:is_a(B), c:is_a(C)) --> true   true   true

D = Class{}
E = Class{inherits={B,D}}
d, e = D(), E()
print(d:is_a(A), d:is_a(B), d:is_a(D)) --> false  false  true
print(e:is_a(A), e:is_a(B), e:is_a(D)) --> true   true   true
]===]
	},

	Section { name = "caveats",
		title = "Caveats",
		content = [===[
		Be careful when using metamethods like {# __add} or {# __mul}: If subclass
		inherits those methods from a superclass, but does not overwrite them, the
		result of the operation may be of the type superclass. Consider the following:
		{## Class = require 'hump.class'

A = Class{function(self, x) self.x = x end}
function A:__add(other) return A(self.x + other.x) end
function A:show() print("A:", self.x) end

B = Class{inherits = A, function(self, x, y) A.construct(self, x) self.y = y end}
function B:show() print("B:", self.x, self.y) end
function B:foo() print("foo") end

one, two = B(1,2), B(3,4)
result = one + two
result:show()   -- prints "A:    4"
result:foo()    -- error: method does not exist}

		Note that while you can define the {# __index} metamethod of the class, this
		is not a good idea: It will break the class. To add a custom __index
		metamethod without breaking the class system, you have to use rawget().
		But beware that this won't affect subclasses:
		{## Class = require 'hump.class'

A = Class{}
function A:foo() print('bar') end

function A:__index(key)
    print(key)
    return rawget(A, key)
end

instance = A()
instance:foo() -- prints foo <newline> bar

B = Class{inherits = A}
instance = B()
instance:foo() -- prints only foo}]===],
	},
}

Module { name = "hump.camera",
	title = "Camera",
	short = "A camera for LÖVE",
	long = [===[
	{!! Depends on hump.vector}

	A camera utility for LÖVE. A camera can "look" at a position. It can zoom in and
	out and it can rotate it's view. In the background, this is done by actually
	moving, scaling and rotating everything in the game world. But don't worry about
	that.]===],

	Function { name = "new",
		short = "Create a new camera object.",
		long = [===[
		Creates a new camera object. You can access the camera position using
		{# camera.pos}, the zoom using {# camera.zoom} and the rotation using
		{# camera.rot}.

		The module variable name can be used at a shortcut to {# new()}.]===],

		params = {
			{"vector", "pos", "Point for the camera to look at.", default = "screen center"},
			{"number", "zoom", "Camera zoom.", default = "1"},
			{"number", "rot", "Camera rotation in radians.", default = "0"},
		},

		returns = {
			{"camera", "A new camera object."}
		},

		example = [===[
camera = require 'hump.camera'
vector = require 'hump.vector'

-- camera looking at (100,100) with zoom 2 and rotated by 45 degrees
cam = camera(vector(100,100), 2, math.pi/2)
]===]
	},

	Function { name = "camera:rotate",
		short = "Rotate camera object.",
		long = [===[
		Rotate the camera {** by} some angle. To {** set} the angle use
		{# camera.rot = new_angle}.

		This function is shortcut to {# camera.rot = camera.rot + angle}.]===],

		params = {
			{"number", "angle", "Rotation angle in radians"}
		},

		returns = {
			{"camera", "The camera object."}
		},

		example = {
			"function love.update(dt)\n    camera:rotate(dt)\nend",
			"function love.update(dt)\n    camera:rotate(dt):move(dt)\nend"
		},
	},

	Function { name = "camera:move",
		short = "Move camera object.",
		long = [===[
		{** Move} the camera {** by} some vector. To {** set} the position, use
		{# camera.pos = some_vector} or {# camera.pos.x, camera.pos.y = new_x, new_y}.

		This function is shortcut to {# camera.pos = camera.pos + v}.]===],

		params = {
			{ {"vector", "v", "Direction to move the camera."} },
			{ {"numbers", "x, y", "Direction to move the camera."} },
		},

		returns = {
			{"camera", "The camera object."},
		},

		example = {
			"function love.update(dt)\n    camera:move(dt * velocity)\nend",
			"function love.update(dt)\n    camera:move(dt * 5, dt * 6):rotate(dt)\nend"
		},
	},

	Function { name = "camera:attach",
		short = "Attach camera object.",
		long = [===[
		Start looking through the camera.

		Apply camera transformations, i.e. move, scale and rotate everything until
		{# camera:detach()} as if looking through the camera.]===],

		params = {},
		returns = {},

		example = [===[
function love.draw()
    camera:attach()
    draw_world()
    cam:detach()

    draw_hud()
end]===]
	},

	Function { name = "camera:detach",
		short = "Detach camera object.",
		long = "Stop looking through the camera.",

		params = {},
		returns = {},

		example = [===[
function love.draw()
    camera:attach()
    draw_world()
    cam:detach()

    draw_hud()
end]===]
	},

	Function { name = "camera:draw",
		short = "Attach, draw and detach.",
		long = [===[
		Wrap a function between a {# camera:attach()}/{# camera:detach()} pair:
		{## cam:attach()
func()
cam:detach()}]===],

		params = {
			{"function", "func", "Drawing function to be wrapped."},
		},

		returns = {},

		example = [===[
function love.draw()
    camera:draw(draw_world)
    draw_hud()
end]===]
	},

	Function { name = {
			"camera:worldCoords",
			"camera:cameraCoords",
		},
		short = {
			"Convert point to world coordinates.",
			"Convert point to camera coordinates.",
		},
		long = [===[
		Because a camera has a point it looks at, a rotation and a zoom factor, it
		defines a coordinate system. A point now has two sets of coordinates: One
		defines where the point is to be found in the game world, and the other
		describes the position on the computer screen. The first set of coordinates
		is called {** world coordinates}, the second one {** camera coordinates}.
		
		Sometimes it is needed to convert between the two coordinate systems, for
		example to get the position of a mouse click in the game world in a strategy
		game, or to see if an object is visible on the screen.

		These two functions convert a point between these two coordinate systems.]===],

		params = {
			{ {"vector", "v", "Point to transform."} },
			{ {"numbers", "x, y", "Point to transform."} },
		},

		returns = {
			{"vector", "Transformed point."},
		},

		example = {
			[===[
target = camera:worldCoords( vector(love.mouse.getPosition()) )
selectedUnit:plotPath(target)
]===], [===[
pos = cam:toCameraCoords(player.pos)
love.graphics.line(pos.x, pos.y, love.mouse.getPosition())
]===]
		},
	},

	Function { name = "camera:mousepos",
		short = "Get mouse position in world coordinates.",
		long = "Shortcut to {# camera:worldCoords(vector(love.mouse.getPosition()))}.",
		params = {},
		returns = {
			{"vector", "Mouse position in world coordinates."},
		},
		example = [===[
target = camera:mousepos()
selectedUnit:plotPath(target)
]===],
	},
}

Module { name = "hump.ringbuffer",
	title = "Ringbuffer",
	short = "A data structure that wraps around itself.",
	long = [===[
	A ring-buffer is a circular array: It does not have a first nor a last item,
	but it has a {** selected} or {** current} element.

	A ring-buffer can be used to implement {** Tomb Raider} style inventories, looping
	play-lists, recurring dialogs (like a unit's answers when selecting it multiple
	times in {** Warcraft}) and generally everything that has a circular or looping
	structure.]===],

	Function { name = "new",
		short = "Create new ring-buffer.",
		long = "Create new ring-buffer.\n\nThe module name is a shortcut to this function.",
		params = {
			{"mixed", "...", "Initial elements."}
		},
		returns = {
			{"Ringbuffer", "The ring-buffer object."},
		},
		example = [===[
Ringbuffer = require 'hump.ringbuffer'

rb = ringbuffer(1,2,3)
]===]
	},

	Function { name = "ringbuffer:insert",
		short = "Insert element.",
		long = "Insert items behind current element.",

		params = {
			{"mixed", "...", "Items to insert."},
		},

		returns = {},

		example = [===[
rb = RingbuffeR(1,5,6) -- content: 1,5,6
rb:insert(2,3,4)       -- content: 1,2,3,4,5,6
]===]
	},

	Function { name = "ringbuffer:remove",
		short = "Remove currently selected item.",
		long = "Remove current item, return it and select next element.",

		params = {},

		returns = {
			{"mixed", "The removed item."}
		},

		example = [===[
rb = Ringbuffer(1,2,3,4) -- content: 1,2,3,4
val = rb:remove()        -- content: 2,3,4
print(val)               -- prints `1'
]===]
	},

	Function { name = "ringbuffer:removeAt",
		short = "Remove an item.",
		long = "Remove the item at a position relative to the current element.",

		params = {
			{"number", "pos", "Position of the item to remove."}
		},

		returns = {
			{"mixed", "The removed item."}
		},

		example = [===[
rb = Ringbuffer(1,2,3,4,5) -- content: 1,2,3,4,5
rb:removeAt(2)             -- content: 1,2,4,5
rb:removeAt(-1)            -- content: 1,2,4
]===]
	},

	Function { name = "ringbuffer:next",
		short = "Select next item.",
		long = "Select and return the next element.",

		params = {},

		returns = {
			{"mixed", "The next item."}
		},

		example = [===[
rb = Ringbuffer(1,2,3)
rb:next()     -- content: 2,3,1
rb:next()     -- content: 3,1,2
x = rb:next() -- content: 1,2,3
print(x)      -- prints `1'
]===]
	},

	Function { name = "ringbuffer:prev",
		short = "Select previous item.",
		long = "Select and return the previous item.",

		params = {},

		returns = {
			{"mixed", "The previous item."}
		},

		example = [===[
rb = Ringbuffer(1,2,3)
rb:prev())    -- content: 3,1,2
rb:prev())    -- content: 2,3,1
x = rb:prev() -- content: 1,2,3
print(x)      -- prints `1'
]===]
	},

	Function { name = "ringbuffer:get",
		short = "Get currently selected item.",
		long = "Return the current element.",

		params = {},

		returns = {
			{"mixed", "The currently selected element."}
		},

		example = [===[
rb = Ringbuffer(1,2,3)
rb:next()       -- content: 2,3,1
print(rb:get()) -- prints '2'
]===]
	},

	Function { name = "ringbuffer:size",
		short = "Get ringbuffer size.",
		long = "Get number of items in the buffer",

		params = {},

		returns = {
			{"number", "Number of items in the buffer."},
		},

		example = [===[
rb = Ringbuffer(1,2,3)
print(rb:size()) -- prints '3'
rb:remove()
print(rb:size()) -- prints '2'
]===]
	},
}
