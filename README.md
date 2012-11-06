# HUMP

## Introduction

Helper Utilities for a Multitude of Problems is a set of lightweight helpers
for the awesome LÖVE Engine.

hump differs from other libraries in that every component is independent of the
remaining ones. hump's footprint is very small and thus should fit nicely into
your projects.


## Module hump.gamestate [A gamestate system.]

	Gamestate = require "hump.gamestate"

A gamestate encapsulates independent data an behaviour into a single entity.

A typical game could consist of a menu-state, a level-state and a game-over-state.

#### Example:

	local menu = Gamestate.new()
	local game = Gamestate.new()
	
	function menu:draw()
		love.graphics.print("Press Enter to continue", 10, 10)
	end
	
	function menu:keyreleased(key, code)
		if key == 'enter' then
			Gamestate.switch(game)
		end
	end
	
	function game:enter()
		Entities.clear()
		-- setup entities here
	end
	
	function game:update(dt)
		Entities.update(dt)
	end
	
	function game:draw()
		Entities.draw()
	end
	
	function love.load()
		Gamestate.registerEvents()
		Gamestate.switch(menu)
	end


### Callbacks [Gamestate Callbacks.]

A gamestate can define all callbacks that LÖVE defines. In addition, there are
callbacks for initalizing, entering and leaving a state:

=`init()`=
	Called once before entering the state. See [`switch()`](#hump.gamestateswitch).
=`enter(previous, ...)`=
	Called when entering the state. See [`switch()`](#hump.gamestateswitch).
=`leave()`=
	Called when leaving a state. See [`switch()`](#hump.gamestateswitch).
=`update()`=
	Update the game state. Called every frame.
=`draw()`=
	Draw on the screen. Called every frame.
=`focus()`=
	Called if the window gets or looses focus.
=`keypressed()`=
	Triggered when a key is pressed.
=`keyreleased()`=
	Triggered when a key is released.
=`mousepressed()`=
	Triggered when a mouse button is pressed.
=`mousereleased()`=
	Triggered when a mouse button is released.
=`joystickpressed()`=
	Triggered when a joystick button is pressed.
=`joystickreleased()`=
	Triggered when a joystick button is released.
=`quit()`=
	Called on quitting the game. Only called on the active gamestate.

When using [`registerEvents()`](#hump.gamestateregisterEvents), all these
callbacks will be called by the corresponding LÖVE callbacks and receive
receive the same arguments (e.g. `state:update(dt)` will be called by
`love.update(dt)`).

#### Example:

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
	end

### function new() [Create a new gamestate.]

Declare a new gamestate. A gamestate can define several callbacks.

#### Returns:

=Gamestate=
    The new gamestate.

#### Example:

    menu = Gamestate.new()


### function switch(to, ...) [Switch to gamestate.]

Switch to a gamestate, with any additional arguments passed to the new state.

Switching a gamestate will call the `leave()` callback on the current
gamestate, replace the current gamestate with `to`, call the `init()` function
if the state was not yet inialized and finally call `enter(old_state, ...)` on
the new gamestate.


#### Parameters:

=Gamestate to=
    Target gamestate.
=mixed ...=
    Additional arguments to pass to `to:enter(current, ...)`.


#### Returns:

=mixed=
    The results of `to:enter(current, ...)`

#### Example:

    Gamestate.switch(game, level_two)


### function &lt;callback&gt;(...) [Call function on active gamestate.]

Calls a function on the current gamestate. Can be any function, but is intended to
be one of the [callbacks](#hump.gamestateCallbacks). Mostly useful when not using
[`registerEvents()`](#hump.gamestateregisterEvents).

#### Parameters:

=mixed ...=
	Arguments to pass to the corresponding function.

#### Returns:

=mixed=
	The result of the callback function.

#### Example:

	function love.draw()
		Gamestate.draw() -- <callback> is `draw'
	end
	
	function love.update(dt)
		Gamestate.update(dt) -- pass dt to currentState:update(dt)
	end
	
	function love.keypressed(key, code)
		Gamestate.keypressed(key, code) -- pass multiple arguments
	end


### function registerEvents(callbacks) [Automatically do all of the above when needed.]

Overwrite love callbacks to call `Gamestate.update()`, `Gamestate.draw()`, etc.
automatically. love callbacks (e.g. `love.update()`) are still invoked.

This is by done by overwriting the love callbacks, e.g.:

	local old_update = love.update
	function love.update(dt)
		old_update(dt)
		return Gamestate.current:update(dt)
	end

**Note:** Only works when called in love.load() or any other function that is
executed *after* the whole file is loaded.

#### Parameters:

=table callbacks (optional)=
	Names of the callbacks to register. If omitted, register all love callbacks.

#### Example:

	function love.load()
		Gamestate.registerEvents()
		Gamestate.switch(menu)
	end
	
	-- love callback will still be invoked
	function love.update(dt)
		Timer.update(dt)
		-- no need for Gamestate.update(dt)
	end

#### Example:

	function love.load()
		-- only register draw, update and quit
		Gamestate.registerEvents{'draw', 'update', 'quit'}
		Gamestate.switch(menu)
	end



## Module hump.timer [Delayed and time-limited function calls.]

    Timer = require "hump.timer"

hump.timer offers a simple interface to schedule the execution of functions. It
is possible to run functions *after* and *for* some amount of time. For
example, a timer could be set to move critters every 5 seconds or to make the
player invincible for a short amount of time.

#### Example:

	function love.keypressed(key)
		if key == ' ' then
			Timer.add(1, function() print("Hello, world!") end)
		end
	end
	
	function love.update(dt)
		Timer.update(dt)
	end


### function new() [Create new timer instance.]

**If you don't need multiple independent schedulers, you can use the
global/default timer (see examples).**

Creates a new timer instance that is independent of the global timer: It will
manage it's own list of scheduled functions and does not in any way affect the
the global timer. Likewise, the global timer does not affect timer instances.

**Note:** Timer instances use the colon-notation (e.g. `instance:update(dt)`),
while the global timer uses the dot-notation (e.g. `Timer.update(dt)`).

#### Returns:

=Timer=
	A timer instance.

#### Example:

	menuTimer = Timer.new()


### function add(delay, func) [Schedule a function.]

Schedule a function. The function will be executed after `delay` seconds have
elapsed, given that `update(dt)` is called every frame.

**Note:** There is no guarantee that the delay will not be exceeded, it is only
guaranteed that the function will *not* be executed *before* the delay has
passed.

`func` will receive itself as only parameter. This is useful to implement
periodic behavior (see the example).

#### Parameters:

=number delay=
	Number of seconds the function will be delayed.
=function func=
	The function to be delayed.

#### Returns:

=table=
	The timer handle.

#### Example:

	-- grant the player 5 seconds of immortality
	player.isInvincible = true
	Timer.add(5, function() player.isInvincible = false end)

#### Example:

	-- print "foo" every second. See also addPeriodic()
	Timer.add(1, function(func) print("foo") Timer.add(1, func) end)

#### Example:

	--Using a timer instance:
	menuTimer:add(1, finishAnimation)


### function addPeriodic(delay, func) [Add a periodic function.]

Add a function that will be called `count` times every `delay` seconds.

If `count` is omitted, the function will be called until it returns `false` or
[`cancel(handle)`](#hump.timercancel) or [`clear()`](#hump.timerclear) is
called.

#### Parameters:

=number delay=
	Number of seconds between two consecutive function calls.
=function func=
	The function to be called periodically.
=number count (optional)=
	Number of times the function is to be called.

#### Returns:

=table=
	The timer handle. See also [`cancel()`](#hump.timercancel).

#### Example:

	-- toggle light on and off every second
	Timer.addPeriodic(1, function() lamp:toggleLight() end)

#### Example:

	-- launch 5 fighters in quick succession (using a timer instance)
	mothership_timer:addPeriodic(0.3, function() self:launchFighter() end, 5)

#### Example:

	-- flicker player's image as long as he is invincible
	Timer.addPeriodic(0.1, function()
		player:flipImage()
		return player.isInvincible
	end)


### function do_for(delay, func, after) [Run a function for the next few seconds.]

Run `func(dt)` for the next `delta` seconds. The function is called every time
`update(dt)` is called. Optionally run `after()` once `delta` seconds have
passed.

`after()` will receive itself as only parameter.

**Note:** You should not add new timers in `func(dt)`, as this can lead to random
crashes.

#### Parameters:

=number delta=
	Number of seconds the func will be called.
=function func=
	The function to be called on `update(dt)`.
=function after (optional)=
	A function to be called after delta seconds.

#### Returns:

=table=
	The timer handle.

#### Example:

	-- play an animation for 5 seconds
	Timer.do_for(5, function(dt) animation:update(dt) end)

#### Example:

	-- shake the camera for one second
	local orig_x, orig_y = camera:pos()
	Timer.do_for(1, function()
	    camera:lookAt(orig_x + math.random(-2,2), orig_y + math.random(-2,2))
	end, function()
	    -- reset camera position
	    camera:lookAt(orig_x, orig_y)
	end)

#### Example:

	player.isInvincible = true
	-- flash player for 3 seconds
	local t = 0
	player.timer:do_for(3, function(dt)
	    t = t + dt
	    player.visible = (t % .2) < .1
	end, function()
	    -- make sure the player is visible after three seconds
	    player.visible = true
	    player.isInvincible = false
	end)


### function cancel(handle) [Cancel a scheduled function.]

Prevent a timer from being executed in the future.

#### Parameters:

=table handle=
	The function to be canceled.

#### Example:

	function tick()
		print('tick... tock...')
	end
	handle = Timer.addPeriodic(1, tick)
	-- later
	Timer.cancel(handle) -- NOT: Timer.cancel(tick)


### function clear() [Remove all timed and periodic functions.]

Remove all timed and periodic functions. Functions that have not yet been
executed will discarded.

#### Example:

	Timer.clear()

#### Example:

	menu_timer:clear()


### function update(dt)  [Update scheduled functions.]

Update timers and execute functions if the deadline is reached. Use this in
`love.update(dt)`.

#### Parameters:

=number dt=
	Time that has passed since the last `update()`.

#### Example:

	function love.update(dt)
	    do_stuff()
	    Timer.update(dt)
	end

#### Example:

	-- using hump.gamestate and a timer instance
	function menuState:update(dt)
	    self.timer:update(dt)
	end



## Module hump.vector [2D vector math.]

	vector = require "hump.vector"

A handy 2D vector class providing most of the things you do with vectors.

You can access the individual coordinates by using vec.x and vec.y.

#### Example:

	function player:update(dt)
		local delta = vector(0,0)
		if love.keyboard.isDown('left') then
			delta.x = -1
		elseif love.keyboard.isDown('right') then
			delta.x =  1
		end
		if love.keyboard.isDown('up') then
			delta.y = -1
		elseif love.keyboard.isDown('down') then
			delta.y =  1
		end
		delta:normalize_inplace()

		player.velocity = player.velocity + delta * player.acceleration * dt

		if player.velocity:len() > player.max_velocity then
			player.velocity = player.velocity:normalized() * player.max_velocity
		end

		player.position = player.position + player.velocity * dt
	end

### Operators [Arithmetics and relations.]

Vector arithmetic is implemented by using `__add`, `__mul` and other
metamethods:

=`vector + vector = vector`=
	Component wise sum.
=`vector - vector = vector`=
	Component wise difference.
=`vector * vector = number`=
	Dot product.
=`number * vector = vector`=
	Scalar multiplication (scaling).
=`vector * number = vector`=
	Scalar multiplication.
=`vector / number = vector`=
	Scalar multiplication.

Relational operators are defined, too:

=`a == b`=
	Same as `a.x == b.x and a.y == b.y`.
=`a <= b`=
	Same as `a.x <= b.x and a.y <= b.y`.
=`a < b`=
	Lexical sort: `a.x < b.x or (a.x == b.x and a.y < b.y)`.

#### Example:

	-- acceleration, player.velocity and player.position are vectors
	acceleration = vector(0,-9)
	player.velocity = player.velocity + acceleration * dt
	player.position = player.position + player.velocity * dt


### function new(x,y) [Create a new vector.]

Create a new vector.

#### Parameters:

=numbers x,y=
	Coordinates.

#### Returns:

=vector=
	The vector.

#### Example:

	a = vector.new(10,10)

#### Example:

	-- as a shortcut, you can call the module like a function:
	vector = require "hump.vector"
	a = vector(10,10)


### function isvector(v) [Test if value is a vector.]

Test whether a variable is a vector.

#### Parameters:

=mixed v=
	The variable to test.

#### Returns:

=boolean=
	`true` if `v` is a vector, `false` otherwise

#### Example:

	if not vector.isvector(v) then
	    v = vector(v,0)
	end


### function vector:clone() [Copy a vector.]

Copy a vector. Simply assigning a vector a vector to a variable will create a
*reference*, so when modifying the vector referenced by the new variable would
also change the old one:

	a = vector(1,1) -- create vector
	b = a           -- b references a
	c = a:clone()   -- c is a copy of a
	b.x = 0         -- changes a,b and c
	print(a,b,c)    -- prints '(1,0), (1,0), (1,1)'

#### Returns:

=vector=
	Copy of the vector

#### Example:

	copy = original:clone()


### function vector:unpack() [Extract coordinates.]

Extract coordinates.

#### Returns:

=numbers=
	The coordinates

#### Example:

	x,y = pos:unpack()

#### Example:

	love.graphics.draw(self.image, self.pos:unpack())


### function vector:permul(other) [Per element multiplication.]

Multiplies vectors coordinate wise, i.e. `result = vector(a.x * b.x, a.y *
b.y)`.

This does not change either argument vectors, but creates a new one.

#### Parameters:

=vector other=
	The other vector

#### Returns:

=vector=
	The new vector as described above

#### Example:

	scaled = original:permul(vector(1,1.5))


### function vector:len() [Get length.]

Get length of a vector, i.e. `math.sqrt(vec.x * vec.x + vec.y * vec.y)`.

#### Returns:

=number=
	Length of the vector.

#### Example:

	distance = (a - b):len()


### function vector:len2() [Get squared length.]

Get squared length of a vector, i.e. `vec.x * vec.x + vec.y * vec.y`.

#### Returns:

=number=
	Squared length of the vector.

#### Example:

	-- get closest vertex to a given vector
	closest, dsq = vertices[1], (pos - vertices[1]):len2()
	for i = 2,#vertices do
		local temp = (pos - vertices[i]):len2()
		if temp < dsq then
			closest, dsq = vertices[i], temp
		end
	end


### function vector:dist(other) [Distance to other vector.]

Get distance of two vectors. The same as `(a - b):len()`.

#### Parameters:

=vector other=
	Other vector to measure the distance to.

#### Returns:

=number=
	The distance of the vectors.

#### Example:

	-- get closest vertex to a given vector
	-- slightly slower than the example using len2()
	closest, dist = vertices[1], pos:dist(vertices[1])
	for i = 2,#vertices do
		local temp = pos:dist(vertices[i])
		if temp < dist then
			closest, dist = vertices[i], temp
		end
	end


### function vector:normalized() [Get normalized vector.]

Get normalized vector, i.e. a vector with the same direction as the input
vector, but with length 1.

This does not change the input vector, but creates a new vector.

#### Returns:

=vector=
	Vector with same direction as the input vector, but length 1.

#### Example:

	direction = velocity:normalized()


### function vector:normalize_inplace() [Normalize vector in-place.]

Normalize a vector, i.e. make the vector unit length. Great to use on
intermediate results.

**This modifies the vector. If in doubt, use
[`vector:normalized()`](#hump.vectornormalized).**

#### Returns:

=vector=
	Itself - the normalized vector

#### Example:

	normal = (b - a):perpendicular():normalize_inplace()


### function vector:rotated(angle) [Get rotated vector.]

Get a rotated vector.

This does not change the input vector, but creates a new vector.

#### Parameters:

=number angle=
	Rotation angle in radians.

#### Returns:

=vector=
	The rotated vector

#### Example:

	-- approximate a circle
	circle = {}
	for i = 1,30 do
		local phi = 2 * math.pi * i / 30
		circle[#circle+1] = vector(0,1):rotated(phi)
	end

#### Sketch:

![Rotated vector sketch](vector-rotated.png)


### function vector:rotate_inplace(angle) [Rotate vector in-place.]

Rotate a vector in-place. Great to use on intermediate results.

**This modifies the vector. If in doubt, use
[`vector:rotate()`](#hump.vectorrotate).**

#### Parameters:

=number angle=
	Rotation angle in radians.

#### Returns:

=vector=
	Itself - the rotated vector

#### Example:

	-- ongoing rotation
	spawner.direction:rotate_inplace(dt)


### function vector:perpendicular() [Get perpendicular vector.]

Quick rotation by 90°. Creates a new vector. The same (but faster) as
`vec:rotate(math.pi/2)`.

#### Returns:

=vector=
	A vector perpendicular to the input vector

#### Example:

	normal = (b - a):perpendicular():normalize_inplace()

#### Sketch:

![Perpendiculat vector sketch](vector-perpendicular.png)


### function vector:projectOn(v) [Get projection onto another vector.]

Project vector onto another vector (see sketch).

#### Parameters:

=vector v=
	The vector to project on.

#### Returns:

=vector=
	The projected vector.

#### Example:

	velocity_component = velocity:projectOn(axis)

#### Sketch:

![Projected vector sketch](vector-projectOn.png)


### function vector:mirrorOn(v) [Mirrors vector on other vector]

Mirrors vector on the axis defined by the other vector.

#### Parameters:

=vector v=
	The vector to mirror on.

#### Returns:

=vector=
	The mirrored vector.

#### Example:

	deflected_velocity = ball.velocity:mirrorOn(surface_normal)

#### Sketch:

![Mirrored vector sketch](vector-mirrorOn.png)


### function vector:cross(other) [Cross product of two vectors.]

Get cross product of both vectors. Equals the area of the parallelogram spanned
by both vectors.

#### Parameters:

=vector other=
	Vector to compute the cross product with.

#### Returns:

=number=
	Cross product of both vectors.

#### Example:

	parallelogram_area = a:cross(b)



## Module hump.vector-light [Lightweight 2D vector math.]

	vector = require "hump.vector-light"

An table-free version of [`hump.vector`](#hump.vector). Instead of a vector
type, `hump.vector-light` provides functions that operate on numbers.

**Note:** Using this module instead of [`hump.vector`](#hump.vector) might
result in faster code, but does so at the expense of readability. Unless you
are sure that it causes a significant performance penalty, I recommend using
[`hump.vector`](#hump.vector).

#### Example:

	function player:update(dt)
		local dx,dy = 0,0
		if love.keyboard.isDown('left') then
			dx = -1
		elseif love.keyboard.isDown('right') then
			dx =  1
		end
		if love.keyboard.isDown('up') then
			dy = -1
		elseif love.keyboard.isDown('down') then
			dy =  1
		end
		dx,dy = vector.normalize(dx, dy)

		player.velx, player.vely = vector.add(player.velx, player.vely,
										vector.mul(dy, dx, dy))

		if vector.len(player.velx, player.vely) > player.max_velocity then
			player.velx, player.vely = vector.mul(player.max_velocity,
								vector.normalize(player.velx, player.vely)
		end

		player.x = player.x + dt * player.velx
		player.y = player.y + dt * player.vely
	end

### function str(x,y) [String representation.]

Transforms a vector to a string of the form `(x,y)`.

#### Parameters:

=numbers x,y=
	The vector

#### Returns:
=string=
	The string representation

#### Example:

	print(vector.str(love.mouse.getPosition()))

### function mul(s, x,y) [Product of a vector and a scalar.]

Computes `x*s,y*s`. The order of arguments is chosen so that it's possible to
chain multiple operations (see example).

#### Parameters:

=number s=
	The scalar.
= numbers x,y=
	The vector.

#### Returns:

=numbers=
	`x*s, y*s`

#### Example:

	velx,vely = vec.mul(dt, vec.add(velx,vely, accx,accy))


### function div(s, x,y) [Product of a vector and the inverse of a scalar.]

Computes `x/s,y/s`. The order of arguments is chosen so that it's possible to
chain multiple operations.

#### Parameters:

=number s=
	The scalar.
= numbers x,y=
	The vector.

#### Returns:

=numbers=
	`x/s, y/s`

#### Example:

	x,y = vec.div(self.zoom, x-w/2, y-h/2)


### function add(x1,y1, x2,y2) [Sum of two vectors.]

Computes the sum (`x1+x2,y1+y2`) of two vectors. Meant to be used in
conjunction with other functions.

#### Parameters:

=numbers x1,y1=
	First vector.
= numbers x2,y2=
	Second vector.

#### Returns:

=numbers=
	`x1+x2, x1+x2`

#### Example:

	player.x,player.y = vector.add(player.x,player.y, vector.mul(dt, dx,dy))

### function sub(x1,y1, x2,y2) [Difference of two vectors.]

Computes the difference (`x1-x2,y1-y2`) of two vectors. Meant to be used in
conjunction with other functions.

#### Parameters:

=numbers x1,y1=
	First vector.
= numbers x2,y2=
	Second vector.

#### Returns:

=numbers=
	`x1-x2, x1-x2`

#### Example:

	dx,dy = vector.sub(400,300, love.mouse.getPosition())


### function permul(x1,y1, x2,y2) [Per element multiplication.]

Multiplies vectors coordinates, i.e.: `x1*x2, y1*y2`.

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=numbers=
	`x1*x2, y1*y2`

#### Example:

	x,y = vector.permul(x,y, 1,1.5)

### function dot(x1,y1, x2,y2) [Dot product.]

Computes the [dot product](http://en.wikipedia.org/wiki/Dot_product ) of two
vectors: `x1*x2 + y1*y2`.

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=number=
	`x1*x2 + y1*y2`

#### Example:

	cosphi = vector.dot(rx,ry, vx,vy)

### function cross(x1,y1, x2,y2) [Cross product.]

Computes the [cross product](http://en.wikipedia.org/wiki/Cross_product) of two
vectors, `x1*y2 - y1*x2`.

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=number=
	`x1*y2 - y1*x2`

#### Example:

	parallelogram_area = vector.cross(ax,ay, bx,by)


Alias to [`vector.cross(x1,y1, x2,y2)`].

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=number=
	`x1*y2 - y1*x2`

#### Example:

	parallelogram_area = vector.det(ax,ay, bx,by)


### function eq(x1,y1, x2,y2) [Equality.]

Test for equality.

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=boolean=
	`x1 == x2 and y1 == y2`

#### Example:

	if vector.eq(x1,y1, x2,y2) then be.happy() end


### function le(x1,y1, x2,y2) [Partial lexical order.]

Test for partial lexical order, `<=`.

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=boolean=
	`x1 <= x2 and y1 <= y2`

#### Example:

	if vector.le(x1,y1, x2,y2) then be.happy() end


### function lt(x1,y1, x2,y2) [Strict lexical order.]

Test for strict lexical order, `<`.

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=boolean=
	`x1 < x2 or (x1 == x2) and y1 <= y2`

#### Example:

	if vector.lt(x1,y1, x2,y2) then be.happy() end

### function len(x,y) [Get length.]

Get length of a vector, i.e. `math.sqrt(x*x + y*y)`.

#### Parameters:

=numbers x,y=
	The vector.

#### Returns:

=number=
	Length of the vector.

#### Example:

	distance = vector.len(love.mouse.getPosition())


### function len2(x,y) [Get squared length.]

Get squared length of a vector, i.e. `x*x + y*y`.

#### Parameters:

=numbers x,y=
	The vector.

#### Returns:

=number=
	Squared length of the vector.

#### Example:

	-- get closest vertex to a given vector
	closest, dsq = vertices[1], vector.len2(px-vertices[1].x, py-vertices[1].y)
	for i = 2,#vertices do
		local temp = vector.len2(px-vertices[i].x, py-vertices[i].y)
		if temp < dsq then
			closest, dsq = vertices[i], temp
		end
	end


### function dist(x1,y1, x2,y2) [Distance of two points.]

Get distance of two points. The same as `vector.len(x1-x2, y1-y2)`.

#### Parameters:

=numbers x1,y1=
	First vector.
=numbers x2,y2=
	Second vector.

#### Returns:

=number=
	The distance of the points.

#### Example:

	-- get closest vertex to a given vector
	-- slightly slower than the example using len2()
	closest, dist = vertices[1], vector.dist(px,py, vertices[1].x,vertices[1].y)
	for i = 2,#vertices do
		local temp = vector.dist(px,py, vertices[i].x,vertices[i].y)
		if temp < dist then
			closest, dist = vertices[i], temp
		end
	end


### function normalize(x,y) [Normalize vector.]

	Get normalized vector, i.e. a vector with the same direction as the input
	vector, but with length 1.

#### Parameters:

=numbers x,y=
	The vector.

#### Returns:

=numbers=
	Vector with same direction as the input vector, but length 1.

#### Example:

	dx,dy = vector.normalize(vx,vy)


### function rotate(phi, x,y) [Rotate vector.]

Get a rotated vector.

#### Parameters:

=number phi=
	Rotation angle in radians.
=numbers x,y=
	The vector.

#### Returns:

=numbers=
	The rotated vector

#### Example:

	-- approximate a circle
	circle = {}
	for i = 1,30 do
		local phi = 2 * math.pi * i / 30
		circle[i*2-1], circle[i*2] = vector.rotate(phi, 0,1)
	end


### function perpendicular(x,y) [Get perpendicular vector.]

Quick rotation by 90°. The same (but faster) as `vector.rotate(math.pi/2, x,y)`.

#### Parameters:

=numbers x,y=
	The vector.

#### Returns:

=numbers=
	A vector perpendicular to the input vector

#### Example:

	nx,ny = vector.normalize(vector.perpendicular(bx-ax, by-ay))


### function project(x,y, u,v) [Project vector onto another vector.]

Project vector onto another vector.

#### Parameters:

=numbers x,y=
	The vector to project.
=numbers u,v=
	The vector to project onto.

#### Returns:

=numbers=
	The projected vector.

#### Example:

	vx_p,vy_p = vector.project(vx,vy, ax,ay)


### function mirror(x,y, u,v) [Mirror vector on other vector.]

Mirrors vector on the axis defined by the other vector.

#### Parameters:

=numbers x,y=
	The vector to mirror.
=numbers u,v=
	The vector defining the axis.

#### Returns:

=numbers=
	The mirrored vector.

#### Example:

	vx,vy = vector.mirror(vx,vy, surface.x,surface.y)


## Module hump.class [Class-based object orientated programming for Lua.]

	Class = require "hump.class"

A small, fast class implementation with multiple inheritance support.

Implements [class commons](https://github.com/bartbes/Class-Commons).

#### Example:

	Critter = Class{function(self, pos, img)
		self.pos = pos
		self.img = img
	end}
	Critter.speed = 5
	
	function Critter:update(dt, player)
		-- see hump.vector
		local dir = (player.pos - self.pos):normalize_inplace()
		self.pos = self.pos + dir * Critter.speed * dt
	end
	
	function Critter:draw()
		love.graphics.draw(self.img, self.pos.x, self.pos.y)
	end


### function new{constructor, name = the_name, inherits = super} [Declare a new class.]

Declare a new class.

The constructor will receive the newly create object as first argument.

You can check if an object is an instance of a class using
[`object:is_a()`](#hump.classis_a).

The name of the variable that holds the module can be used as a shortcut to
`new()` (see example).

#### Parameters:

=function constructor (optional)=
	Class constructor. Can be accessed with theclass.construct(object, ...)
=string the_name (optional)=
	Class name (used only to make the class compliant to tostring().
=class or table of classes super (optional)=
	Classes to inherit from. Can either be a single class or a table of classes

#### Returns:

=class=
	The class

#### Example:

	Class = require 'hump.class' -- `Class' is now a shortcut to new()
	
	-- define unnamed class
	Feline = Class{function(self, size, weight)
		self.size = size
		self.weight = weight
	end}
	print(Feline) -- prints '
	
	-- define class method
	function Feline:stats()
		return string.format("size: %.02f, weight %.02f", self.size, self.weight)
	end
	
	-- create two objects
	garfield = Feline(.7, 45)
	felix = Feline(.8, 12)
	
	print("Garfield: " .. garfield:stats(), "Felix: " .. felix:stats())

#### Example:

	Class = require 'hump.class'
	
	-- define class with explicit name 'Feline'
	Feline = Class{name = "Feline", function(self, size, weight)
		self.size = size
		self.weight = weight
	end}
	
	garfield = Feline(.7, 45)
	print(Feline, garfield) -- prints '	>'

#### Example:

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


### function class.construct(object, ...) [Call class constructor.]

Calls class constructor of a class on an object.

Derived classes use this function their constructors to initialize the parent
class(es) portions of the object.

#### Parameters:

=Object object=
	The object. Usually `self`.
=mixed ...=
	Arguments to pass to the constructor.

#### Returns:

=mixed=
	Whatever the parent class constructor returns.


#### Example:

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

#### Example:

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

### function class:inherit(...) [Explicit class inheritance/mixin support.]

Inherit functions and variables of another class, if they are not already
defined for the class. This is done by simply copying the functions and
variables over to the subclass. The Lua rules for copying apply (i.e. tables
are referenced, functions and primitive types are copied by value).

**Be careful with changing table values in a subclass: This will change the
value in the parent class too.**

If more than one parent class is specified, inherit from all of these, in order
of occurrence. That means that when two parent classes define the same method,
the one from the first class will be inherited.

**Note:** `class:inherit()` doesn't actually care if the arguments supplied are
hump classes. Just any table will work.

#### Parameters:

=tables ...=
	Parent classes to inherit from

#### Example:

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

### function object:is_a(cls) [Test object's type.]

Tests whether an object is an instance of a class.

#### Parameters:

=class cls=
	Class to test. **Note:** this is the class itself, not the name of the class.

#### Returns:

=boolean=
	`true` if the object is an instance of the class, `false` otherwise

#### Example:

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

### Caveats [Common gotchas.]

Be careful when using metamethods like `__add` or `__mul`: If subclass inherits
those methods from a superclass, but does not overwrite them, the result of the
operation may be of the type superclass. Consider the following:

Class = require 'hump.class'

	A = Class{function(self, x) self.x = x end}
	function A:__add(other) return A(self.x + other.x) end
	function A:show() print("A:", self.x) end
	
	B = Class{inherits = A, function(self, x, y) A.construct(self, x) self.y = y end}
	function B:show() print("B:", self.x, self.y) end
	function B:foo() print("foo") end
	
	one, two = B(1,2), B(3,4)
	result = one + two
	result:show()   -- prints "A:    4"
	result:foo()    -- error: method does not exist

Note that while you can define the `__index` metamethod of the class, this is
not a good idea: It will break the class. To add a custom `__index` metamethod
without breaking the class system, you have to use `rawget()`. But beware that
this won't affect subclasses:

	Class = require 'hump.class'
	
	A = Class{}
	function A:foo() print('bar') end
	
	function A:__index(key)
		print(key)
		return rawget(A, key)
	end
	
	instance = A()
	instance:foo() -- prints foo  bar
	
	B = Class{inherits = A}
	instance = B()
	instance:foo() -- prints only foo


## Module hump.signal [Simple Signal/Slot (aka. Observer) implementation.]

    Signals = require 'hump.signal'

A simple yet effective implementation of [Signals and
Slots](http://en.wikipedia.org/wiki/Signals_and_slots), also known as [Observer
pattern](http://en.wikipedia.org/wiki/Observer_pattern): Functions can be
dynamically bound to signals. When a *signal* is *emitted*, all registered
functions will be invoked. Simple as that.

`hump.signal` makes things more interesing by allowing to emit all signals that
match a [Lua string pattern](http://www.lua.org/manual/5.1/manual.html#5.4.1).

#### Example:

	-- in AI.lua
	signals.register('shoot', function(x,y, dx,dy)
		-- for every critter in the path of the bullet:
		-- try to avoid being hit
		for critter in pairs(critters) do
			if critter:intersectsRay(x,y, dx,dy) then
				critter:setMoveDirection(-dy, dx)
			end
		end
	end)
	
	-- in sounds.lua
	signals.register('shoot', function()
		Sounds.fire_bullet:play()
	end)
	
	-- in main.lua
	function love.keypressed(key)
		if key == ' ' then
			local x,y   = player.pos:unpack()
			local dx,dy = player.direction:unpack()
			signals.emit('shoot', x,y, dx,dy)
		end
	end

### function new() [Create a new signal registry]

**If you don't need multiple independent registries, you can use the
global/default registry (see examples).**

Creates a new signal registry that is independent of the default registry: It
will manage it's own list of signals and does not in any way affect the the
global registry. Likewise, the global registry does not affect the instance.

**Note:** Independent registries use the colon-notation (e.g.
`instance:emit("foo")`), while the global registry uses the dot-notation (e.g.
`Signal.emit("foo")`).

#### Returns:

=Registry=
	A new signal registry.

#### Example:

	player.signals = Signals.new()


### function register(s, f) [Register function with signal.]

Registers a function `f` to be called when signal `s` is emitted.

#### Parameters:

=string s=
	The signal identifier.
=function f=
	The function to register.

#### Returns:

=function=
	A function handle to use in [`remove()`](#hump.signalremove).

#### Example:

	Signal.register('level-complete', function() self.fanfare:play() end)

#### Example:

	handle = Signal.register('level-load', function(level) level.show_help() end)

#### Example:

	menu:register('key-left', select_previous_item)


### function emit(s, ...) [Call all functions bound to a signal.]

Calls all functions bound to signal `s` with the supplied arguments.


#### Parameters:

=string s=
	The signal identifier.
=mixed ... (optional)=
	Arguments to pass to the bound functions.

#### Example:

	function love.keypressed(key)
		-- using a signal instance
		if key == 'left' then menu:emit('key-left') end
	end

#### Example

	if level.is_finished() then
		-- adding arguments
		Signal.emit('level-load', level.next_level)
	end


### function remove(s, ...) [Remove functions from registry. ]

Unbinds (removes) functions from signal `s`.

#### Parameters:

=string s=
	The signal identifier.
=functions ...=
	Functions to unbind from the signal.

#### Example:

	Signal.remove('level-load', handle)


### function clear(s) [Clears a signal registry.]

Removes all functions from signal `s`.

#### Parameters:

=string s=
	The signal identifier.

#### Example:

	Signal.clear('key-left')


### function emit_pattern(p, ...) [Emits signals matching a pattern.]

Emits all signals matching a [string pattern](http://www.lua.org/manual/5.1/manual.html#5.4.1).

#### Parameters:

=string p=
	The signal identifier pattern.
=mixed ... (optional)=
	Arguments to pass to the bound functions.

#### Example:

	Signal.emit_pattern('^update%-.*', dt)


### function remove_pattern(p, ...) [Remove functions from signals matching a pattern.]

Removes functions from all signals matching a [string pattern](http://www.lua.org/manual/5.1/manual.html#5.4.1).

#### Parameters:

=string p=
	The signal identifier pattern.
=functions ...=
	Functions to unbind from the signals.

#### Example:

	Signal.remove_pattern('key%-.*', play_click_sound)


### function clear_pattern(p) [Clears signal registry matching a pattern.]

Removes *all* functions from all signals matching a [string pattern](http://www.lua.org/manual/5.1/manual.html#5.4.1).

#### Parameters:

=string p=
	The signal identifier pattern.

#### Example:

	Signal.clear_pattern('sound%-.*')

#### Example:

	player.signals:clear_pattern('.*') -- clear all signals


## Module hump.camera [A camera for LÖVE.]

	Camera = require "hump.camera"

A camera utility for LÖVE. A camera can "look" at a position. It can zoom in
and out and it can rotate it's view. In the background, this is done by
actually moving, scaling and rotating everything in the game world. But don't
worry about that.

#### Example:

	function love.load()
		cam = Camera(player.pos.x, player.pos.y)
	end
	
	function love.update(dt)
		local dx,dy = player.x - cam.x, player.y - cam.y
		cam:move(dx/2, dy/2)
	end

### function new(x,y, zoom, rot) [Create a new camera.]

Creates a new camera. You can access the camera position using `camera.x,
camera.y`, the zoom using `camera.scale` and the rotation using `camera.rot`.

The module variable name can be used at a shortcut to `new()`.

#### Parameters:

=numbers x,y (optional)=
	Point for the camera to look at.
=number zoom (optional)=
	Camera zoom.
=number rot (optional)=
	Camera rotation in radians.


#### Returns:

=camera=
	A new camera.

#### Example:

	camera = require 'hump.camera'
	-- camera looking at (100,100) with zoom 2 and rotated by 45 degrees
	cam = camera(100,100, 2, math.pi/2)


### function camera:move(dx,dy) [Move camera.]

Move the camera *by* some vector. To set the position, use
[`camera:lookAt(x,y)`](#hump.cameralookAt).

This function is shortcut to camera.x,camera.y = camera.x+dx, camera.y+dy.

#### Parameters:

=numbers dx,dy=
	Direction to move the camera.

#### Returns:

=camera=
	The camera.

#### Example:

	function love.update(dt)
		camera:move(dt * 5, dt * 6)
	end

#### Example:

	function love.update(dt)
		camera:move(dt * 5, dt * 6):rotate(dt)
	end


### function camera:lookAt(x,y) [Move camera to position.]

Let the camera look at a point. In other words, it sets the camera position. To
move the camera *by* some amount, use [`camera:move(x,y)`](#hump.cameramove).

This function is shortcut to `camera.x,camera.y = x, y`.

#### Parameters:

=numbers x,y=
	Position to look at.

#### Returns:

=camera=
	The camera.

#### Example:

	function love.update(dt)
		camera:lookAt(player.pos:unpack())
	end

#### Example:

	function love.update(dt)
		camera:lookAt(player.pos:unpack()):rotation(player.rot)
	end

### function camera:pos() [Get camera position.]

Returns `camera.x, camera.y`.

#### Returns:

=numbers=
	Camera position.

#### Example:

	-- let the camera fly!
	local cam_dx, cam_dy = 0, 0
	
	function love.mousereleased(x,y)
		local cx,cy = camera:position()
		dx, dy = x-cx, y-cy
	end
	
	function love.update(dt)
		camera:move(dx * dt, dy * dt)
	end


### function camera:rotate(angle) [Rotate camera.]

Rotate the camera by some angle. To set the angle use `camera.rot = new_angle`.

This function is shortcut to `camera.rot = camera.rot + angle`.

#### Parameters:

=number angle=
	Rotation angle in radians

#### Returns:

=camera=
	The camera.

#### Example:

	function love.update(dt)
		camera:rotate(dt)
	end

#### Example:

	function love.update(dt)
		camera:rotate(dt):move(dt,dt)
	end


### function camera:rotateTo(angle) [Set camera rotation.]

Set rotation: `camera.rot = angle`.

#### Parameters:

=number angle=
	Rotation angle in radians

#### Returns:

=number=
	The camera.

#### Example:

	camera:rotateTo(math.pi/2)


### function camera:zoom(mul) [Change zoom.]

*Multiply* zoom: `camera.scale = camera.scale * mul`.

#### Parameters:

=number mul=
	Zoom change. Should be > 0.

#### Returns:

=number=
	The camera.

#### Example:

	camera:zoom(2)   -- make everything twice as big

#### Example:

	camera:zoom(0.5) -- ... and back to normal

#### Example:

	camera:zoom(-1)  -- flip everything


### function camera:zoomTo(zoom) [Set zoom.]

Set zoom: `camera.scale = zoom`.

#### Parameters:

=number zoom=
	New zoom.

#### Returns:

=number=
	The camera.

#### Example:

	camera:zoomTo(1)


### function camera:attach() [Attach camera.]

Start looking through the camera.

Apply camera transformations, i.e. move, scale and rotate everything until
`camera:detach()` as if looking through the camera.

#### Example:

	function love.draw()
		camera:attach()
		draw_world()
		cam:detach()

		draw_hud()
	end


### function camera:detach() [Detach camera.]

Stop looking through the camera.

#### Example:

	function love.draw()
		camera:attach()
		draw_world()
		cam:detach()

		draw_hud()
	end


### function camera:draw(func) [Attach, draw, then detach.]

Wrap a function between a `camera:attach()/camera:detach()` pair:

	cam:attach()
	func()
	cam:detach()


#### Parameters:

=function func=
	Drawing function to be wrapped.

#### Example:

	function love.draw()
		camera:draw(draw_world)
		draw_hud()
	end


### function camera:worldCoords(x, y) [Convert point to world coordinates.]

Because a camera has a point it looks at, a rotation and a zoom factor, it
defines a coordinate system. A point now has two sets of coordinates: One
defines where the point is to be found in the game world, and the other
describes the position on the computer screen. The first set of coordinates is
called *world coordinates*, the second one *camera coordinates*. Sometimes it
is needed to convert between the two coordinate systems, for example to get the
position of a mouse click in the game world in a strategy game, or to see if an
object is visible on the screen.

`camera:worldCoords(x,y)` and `camera:cameraCoords(x,y)` transform a point
between these two coordinate systems.

#### Parameters:

=numbers x, y=
	Point to transform.

#### Returns:

=numbers=
	Transformed point.

#### Example:

	x,y = camera:worldCoords(love.mouse.getPosition())
	selectedUnit:plotPath(x,y)


### function camera:cameraCoords(x, y) [Convert point to camera coordinates.]

Because a camera has a point it looks at, a rotation and a zoom factor, it
defines a coordinate system. A point now has two sets of coordinates: One
defines where the point is to be found in the game world, and the other
describes the position on the computer screen. The first set of coordinates is
called *world coordinates*, the second one *camera coordinates*. Sometimes it
is needed to convert between the two coordinate systems, for example to get the
position of a mouse click in the game world in a strategy game, or to see if an
object is visible on the screen.

`camera:worldCoords(x,y)` and `camera:cameraCoords(x,y)` transform a point
between these two coordinate systems.

#### Parameters:

=numbers x, y=
	Point to transform.

#### Returns:

=numbers=
	Transformed point.

#### Example:

	x,y = cam:cameraCoords(player.pos)
	love.graphics.line(x, y, love.mouse.getPosition())


### function camera:mousepos() [Get mouse position in world coordinates.]

Shortcut to `camera:worldCoords(love.mouse.getPosition())`.

#### Returns:

=numbers=
	Mouse position in world coordinates.

#### Example:

	x,y = camera:mousepos()
	selectedUnit:plotPath(x,y)


## Module hump.ringbuffer [A data structure that wraps around itself.]

	Ringbuffer = require "hump.ringbuffer"

A ring-buffer is a circular array: It does not have a first nor a last item,
but it has a *selected* or *current* element.

A ring-buffer can be used to implement [Tomb Raider style
inventories](http://www.youtube.com/watch?v=YTdsKq77_lg), looping play-lists,
recurring dialogs (like a unit's answers when selecting it multiple
times in *Warcraft*) and generally everything that has a circular or looping
structure.

### function new(...) [Create a new ringbuffer.]

Create new ring-buffer.

The module name is a shortcut to this function.

#### Parameters:

=mixed ...=
	Initial elements.

#### Returns:

=Ringbuffer=
	The ring-buffer object.

#### Example:

	ringbuffer = require 'hump.ringbuffer'
	rb = ringbuffer.new(1,2,3)
	-- or:
	rb = ringbuffer(1,2,3)

### function ringbuffer:insert(...) [Inser elements.]

Insert items behind current element.

#### Parameters:

=mixed ...=
	Items to insert.

#### Example:

	rb = Ringbuffer(1,5,6) -- content: 1,5,6
	rb:insert(2,3,4)       -- content: 1,2,3,4,5,6


### function ringbuffer:remove() [Remove currently selected item.]

Remove current item, return it and select next element.

#### Returns:

=mixed=
	The removed item.

#### Example:

	rb = Ringbuffer(1,2,3,4) -- content: 1,2,3,4
	val = rb:remove()        -- content: 2,3,4
	print(val)               -- prints `1'


### function ringbuffer:removeAt(pos) [Remove an item.]

Remove the item at a position relative to the current element.

#### Parameters:

=number pos=
	Position of the item to remove.


#### Returns:

=mixed=
	The removed item.


#### Example:

	rb = Ringbuffer(1,2,3,4,5) -- content: 1,2,3,4,5
	rb:removeAt(2)             -- content: 1,2,4,5
	rb:removeAt(-1)            -- content: 1,2,4


### function ringbuffer:next() [Select next item.]

Select and return the next element.

#### Returns:

=mixed=
	The next item.

#### Example:

	rb = Ringbuffer(1,2,3)
	rb:next()     -- content: 2,3,1
	rb:next()     -- content: 3,1,2
	x = rb:next() -- content: 1,2,3
	print(x)      -- prints `1'

### function ringbuffer:prev() [Select previous item.]

Select and return the previous item.

#### Returns:

=mixed=
	The previous item.

#### Example:

	rb = Ringbuffer(1,2,3)
	rb:prev())    -- content: 3,1,2
	rb:prev())    -- content: 2,3,1
	x = rb:prev() -- content: 1,2,3
	print(x)      -- prints `1'


### function ringbuffer:get() [Get currently selected item.]

Return the current element.

#### Returns:

=mixed=
	The currently selected element.


#### Example:

	rb = Ringbuffer(1,2,3)
	rb:next()       -- content: 2,3,1
	print(rb:get()) -- prints '2'


### function ringbuffer:size() [Get ringbuffer size.]

Get number of items in the buffer

#### Returns:

=number=
	Number of items in the buffer.

#### Example:

	rb = Ringbuffer(1,2,3)
	print(rb:size()) -- prints '3'
	rb:remove()
	print(rb:size()) -- prints '2'


## License

Yay, *free software*

> Copyright (c) 2010-2012 Matthias Richter
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

## Download

You can view and download the individual modules on github: [vrld/hump](http://github.com/vrld/hump)
You may also download the whole packed sourcecode either in
[zip](http://github.com/vrld/hump/zipball/master) or
[tar](http://github.com/vrld/hump/tarball/master) formats.

Using [Git](http://git-scm.com), you can clone the project by running:

	git clone git://github.com/vrld/hump

Once done, tou can check for updates by running

	git pull
