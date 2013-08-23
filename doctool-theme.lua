local discount = function(s) return (require 'discount')(s, "nopants") end
local actions = {}

local function filter(t, p)
	local r = {}
	for _,v in ipairs(t) do
		if p(v) then r[#r+1] = v end
	end
	return r
end

local function anchorname(s)
	return s:gsub('%s$', ''):gsub('%s','_')
end

-- generic
function actions.textblock(info)
	return discount(info[1])
end

function actions.section(info)
	local htype = 'h'..(info[3]+1)
	if info[3] >= 3 then
		return table.concat{
			'<div class="section-block" id="{{MODULE}}', anchorname(info[1]), '">',
				'<',htype,'>', info[1], '<a class="top" href="#{{MODULE}}">^top</a></',htype,'>',
				 discount(info[4]),
			'</div>'
		}
	end
	return table.concat{
		'<div class="outer-block" id="{{MODULE}}', anchorname(info[1]), '">',
			'<',htype,'>', info[1], '<a class="top" href="#top">^top</a></',htype,'>',
			'<div class="preamble">', discount(info[4]), '</div>',
		'</div>'
	}
end

-- function
function actions.parameters(info)
	return discount(info[1]):gsub('<dt>([^<]+)</dt>', function(m)
		local type, what, optional = m:match("(%S+) ([^%(]+)( %b())")
		if not type then
			optional, type, what = '', m:match("(%S+) ([^%(]+)%s*")
		end
		assert(type and what and optional, "Invalid parameter description: " .. m)
		return table.concat{'<dt>', type, ' <code>', what, '</code>', optional, '</dt>'}
	end)
end

function actions.returns(info)
	return discount(info[1])
end

function actions.example(info)
	return discount(info[1])
end

function actions.sketch(info)
	return discount(info[1])
end

actions['function'] = function(info)
	local arg_delim = info.has_table_args and {'{','}'} or {'(',')'}
	local out = {
		'<div class="ref-block" id="{{MODULE}}', anchorname(info[1]), '">',
		'<h4>',
		'function <span class="name">', info[1], '</span>',
		'<span class="arglist">', arg_delim[1], info[2], arg_delim[2], '</span>',
		'<a class="top" href="#{{MODULE}}">^top</a></h4>',
		discount(info[4])
	}

	-- parameter list
	local parameters = filter(info[5], function(v) return v.type == 'parameters' end)
	out[#out+1] = '<div class="arguments">'
	out[#out+1] = 'Parameters:'
	if #parameters == 0 then
		out[#out+1] = '<dl><dt>None</dt></dl>'
	else
		for _, r in ipairs(parameters) do
			out[#out+1] = actions.parameters(r)
		end
	end
	out[#out+1] = '</div>'

	-- returns list
	local returns = filter(info[5], function(v) return v.type == 'returns' end)
	out[#out+1] = '<div class="returns">'
	out[#out+1] = 'Returns:'
	if #returns == 0 then
		out[#out+1] = '<dl><dt>Nothing</dt></dl>'
	else
		for _, r in ipairs(returns) do
			out[#out+1] = actions.returns(r)
		end
	end
	out[#out+1] = '</div>'

	-- examples
	local examples = filter(info[5], function(v) return v.type == 'example' end)
	assert(#examples > 0, "No examples given for function " .. info[1] .. "()")
	out[#out+1] = '<div class="example">'
	out[#out+1] = #examples > 1 and 'Examples:' or 'Example:'
	for _,s in ipairs(examples) do
		out[#out+1] = actions.example(s)
	end
	out[#out+1] = '</div>'

	-- sketch
	local sketch = filter(info[5], function(v) return v.type == 'sketch' end)
	if #sketch > 0 then
		out[#out+1] = '<div class="example">'
		out[#out+1] = #sketch > 1 and 'Sketches:' or 'Sketch:'
		for _,s in ipairs(sketch) do
			out[#out+1] = actions.sketch(s)
		end
		out[#out+1] = '</div>'
	end

	out[#out+1] = '</div>'
	return table.concat(out)
end

-- module
function actions.module(info)
	local modname = info[1]
	local out = {
		'<div class="outer-block" id="', anchorname(modname), '">',
		'<h3>', modname, '<a class="top" href="#top">^top</a></h3>',
		'<div class="preamble">', discount(info[3]), '</div>'
	}

	-- create module overview
	out[#out+1] = '<div class="overview">'
	out[#out+1] = '<h4>Module overview</h4>'
	out[#out+1] = '<dl>'
	for _,info in ipairs(info[4]) do
		if info.type == 'function' then
			out[#out+1] = table.concat{
				'<dt>',
					'<a href="#', anchorname(modname), anchorname(info[1]), '">',
						info[1], '()',
					'</a>',
				'</dt><dd>',
					 info[3],
				'</dd>',
			 }
		elseif info.type == 'section' then
			out[#out+1] = table.concat{
				'<dt>',
					'<a href="#', anchorname(modname), anchorname(info[1]), '">',
						info[1],
					'</a>',
				'</dt><dd>',
					 info[2],
				'</dd>',
			 }
		else
			error("Unhandled module subtype: " .. info.type)
		end
	end
	out[#out+1] = '</dl>'
	out[#out+1] = '</div>'

	-- create detailed reference
	for _,info in ipairs(info[4]) do
		local s = actions[info.type](info)
		out[#out+1] = s:gsub('{{MODULE}}', modname)
	end

	out[#out+1] = '</div>'
	return table.concat(out)
end


-- title
function actions.title(info)
	--return table.concat{'<h1>', info[1], '</h1>'}
	return ""
end

-- build module overview
function actions.preprocess(doctree)
	local out = {}
	out[#out+1] = '<dl>'
	for _, info in ipairs(filter(doctree, function(v) return v.type == 'module' end)) do
		out[#out+1] = table.concat{
			'<dt><a href="#', anchorname(info[1]), '">', info[1], '</a></dt>',
			'<dd>', info[2], '</dd>',
		}
	end
	out[#out+1] = '</dl>'

	local mod_overview = {type = 'section', 'Modules', '', 2, table.concat(out)}
	for i = 1,#doctree do
		if doctree[i][1] == 'Introduction' then
			table.insert(doctree, i+1, mod_overview)
			break
		end
	end

	return doctree
end

function actions.postprocess(out)
	return table.concat{[[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>hump - L&Ouml;VE Helper Utilities for More Productivity</title>
<link rel="stylesheet" type="text/css" href="style.css" />
<link rel="stylesheet" type="text/css" href="highlight.css" />
<script type="text/javascript" src="highlight.pack.js"></script>
<script type="text/javascript">
	window.onload = function() {
		var examples = document.getElementsByTagName("code");
		for (i = 0; i < examples.length; ++i) {
			if (examples[i].className == "lua")
				hljs.highlightBlock(examples[i], "    ");
		}
	};
</script>
</head>

<body><a name="top"></a>
<div id="header">
	<h1><a href="http://github.com/vrld/hump">hump</a>
		<span class="small"> Helper Utilities for More Productivity</span></h1>
	<ul id="main-nav">
		<li><a href="#Introduction">Introduction</a></li>
		<li><a href="#Modules">Modules</a></li>
		<li><a href="#License">License</a></li>
		<li><a href="#Download">Download</a></li>
	</ul>
	<h2>&nbsp;</h2>
</div>]],
		out:gsub('{{MODULE}}', ''):gsub('<code>', '<code class="lua">'),
		"</body></html>"
	}
end

return actions
