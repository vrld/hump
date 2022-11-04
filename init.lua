local dir = (...) .. '.'
assert(not dir:match('%.init%.$'), "Invalid require path `"..(...).."' (remove the `.init').")

local function get(mod_name)
	return require(dir..mod_name)
end

return {
	camera       = get("camera"),
	class        = get("class"),
	gamestate    = get("gamestate"),
	signal       = get("signal"),
	timer        = get("timer"),
	vector_light = get("vector-light"),
	vector       = get("vector")
}
