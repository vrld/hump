Gamestate = {}

-- default gamestate produces error on every callback
local function __ERROR__() error("Gamestate not initialized. Use Gamestate.switch()") end
Gamestate.current = {
    enter          = __ERROR__,
    leave          = __ERROR__,
    update         = __ERROR__,
    draw           = __ERROR__,
    keyreleased    = __ERROR__,
    keypressed     = __ERROR__,
    mousereleased  = __ERROR__,
}

local function __NULL__() end
function Gamestate.new()
	return {
		enter          = __NULL__,
		leave          = __NULL__,
		update         = __NULL__,
		draw           = __NULL__,
		keyreleased    = __NULL__,
		keypressed     = __NULL__,
		mousereleased  = __NULL__,
	}
end

function Gamestate.switch(to, ...)
	if not to then return end
	if Gamestate.current then
		Gamestate.current:leave()
	end
	local pre = Gamestate.current
	Gamestate.current = to
	Gamestate.current:enter(pre, ...)
end

local _update
function Gamestate.update(dt)
	if _update then _update(dt) end
	Gamestate.current:update(dt)
end

local _keypressed
function Gamestate.keypressed(key, unicode)
	if _keypressed then _keyreleased(key) end
	Gamestate.current:keypressed(key, unicode)
end

local _keyreleased
function Gamestate.keyreleased(key)
	if _keyreleased then _keyreleased(key) end
	Gamestate.current:keyreleased(key)
end

local _mousereleased
function Gamestate.mousereleased(x,y,btn)
	if _mousereleased then _mousereleased(x,y,btn) end
	Gamestate.current:mousereleased(x,y,btn)
end

local _draw
function Gamestate.draw()
	if _draw then _draw() end
	Gamestate.current:draw()
end

function Gamestate.registerEvents()
	_update            = love.update
	love.update        = Gamestate.update
	_keypressed        = love.keypressed
	love.keypressed    = Gamestate.keypressed
	_keyreleased       = love.keyreleased
	love.keyreleased   = Gamestate.keyreleased
	_mousereleased     = love.mousereleased
	love.mousereleased = Gamestate.mousereleased
	_draw              = love.draw
	love.draw          = Gamestate.draw
end
