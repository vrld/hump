function markup(str)
	local function trim(tbl)
		for i=#tbl,1,-1 do
			if tbl[i] == ' ' then
				tbl[i] = nil
			else
				return tbl
			end
		end
	end

	local parse, block, block2, element, code, url, title, def, dt, dd
	function parse(out, next)
		local c = next()
		if not c then return out end
		if c == ' ' or c == '\t' then return parse(out, next) end
		out[#out+1] = '<p>'
		if c == '[' then return element(out, next) end
		out[#out+1] = c
		return block(out, next)
	end

	function block(out, next)
		local c = next()
		if not c     then out[#out+1] = '</p>' return out end
		if c == '['  then                      return element(out, next) end
		if c == '\n' then                      return block2(out, next) end
		out[#out+1] = c
		return block(out, next)
	end

	function block2(out, next)
		local c = next()
		if not c     then out[#out+1] = '</p>' return out end
		if c == '['  then                      return element(out, next) end
		if c == '\n' then out[#out+1] = '</p>' return parse(out, next) end

		if c ~= ' ' and c ~= '\t' then out[#out+1] = c end
		return block(out, next)
	end

	function element(out, next)
		local c = assert(next(), 'markup error')
		if c == '^' then out[#out+1] = '<a href="' return url(out, next) end
		if c == '|' then out[#out+1] = '<dl>'      return def(out, next) end
		if c == '%' then out[#out+1] = '<pre><code class="lua">' return code(out, next) end
		out[#out+1] = '['..c
		return block(out, next)
	end

	function url(out, next)
		local c = assert(next(), 'markup error')
		assert(c ~= ']', 'incomplete link definition')
		if c == ' ' then out[#out+1] = '">' return title(out, next) end
		out[#out+1] = c
		return url(out, next)
	end

	function title(out, next)
		local c = assert(next(), 'markup error')
		if c == ']' then out[#out+1] = '</a>' return block(out, next) end
		out[#out+1] = c
		return title(out, next)
	end

	function def(out, next)
		local c = assert(next(), 'markup error')
		if c == ' ' or c == '\t' or c == '\n' then return def(out, next) end
		if c == ']' then out[#out+1] = '</dl>' return block(out, next) end
		out[#out+1] = '<dt>' .. c
		return dt(out, next)
	end

	function dt(out, next)
		local c = assert(next(), 'markup error')
		if c == ':' then trim(out) out[#out+1] = '</dt><dd>' return dd(out, next) end
		out[#out+1] = c
		return dt(out, next)
	end

	function dd(out, next)
		local c = assert(next(), 'markup error')
		if c == '\n' then out[#out+1] = '</dd>' return def(out, next) end
		out[#out+1] = c
		return dd(out, next)
	end

	function code(out, next)
		local c = assert(next(), 'markup error')
		if c == ']' then out[#out+1] = '</code></pre>' return block(out, next) end
		out[#out+1] = c
		return code(out, next)
	end

	local function spans(m)
		local cmd,rest = m:match('^{(.)(.+)}$')
		if cmd == '#' then return '<code class="lua">'..rest..'</code>' end
		if cmd == '*' then return '<em>'..rest..'</em>' end
		if cmd == '!' then return '<span class="warning">'..rest..'</span>' end
		return m
	end

	return table.concat(parse({}, str:gmatch('.'))):gsub('%b{}', spans):gsub('%b{}', spans)
end


-- PREPARE DOCUMENTATION MARKUP
local DOC = { short = {}, long = {} }

function Module(M)
	for _,field in ipairs{'name', 'title', 'short', 'long'} do
		assert(M[field], "Module: Required field `"..field.."' is missing")
	end

	DOC.short[#DOC.short+1] = ('<dt><a href="#%s">%s</a></dt><dd>%s</dd>'):format(M.title, M.name, M.short)

	local long = {}
	local function F(s, ...) long[#long+1] = select('#', ...) > 0 and s:format(...) or s end
	F('<a name="%s" id="%s"></a>', M.title, M.title)
	F('<div class="outer-block">') -- outer block>
		F('<h3>%s<a class="top" href="#top">^ top</a></h3>', M.name)
		F('<div class="preamble">') -- preamble>
			F('<pre><code class="lua">%s = require "%s"</code></pre>', M.title:gsub("^(%w+)%W.+", "%1"), M.name)
			F(markup(M.long))
		F('</div>') -- <preamble
		F('<div class="overview"><h4>Module overview</h4><dl>') -- overview>
			for _,item in ipairs(M) do if item.short then F(item.short) end end
		F('</dl></div>') -- <overview
		for _,item in ipairs(M) do F(item.long) end
	F('</div>') -- <outer block

	DOC.long[#DOC.long+1] = table.concat(long):gsub('{{MODULE}}', M.title)
end


function Section(M)
	for _,field in ipairs{'name', 'title', 'content'} do
		assert(M[field], "Section: Required field `"..field.."' is missing")
	end

	local short = ('<dt><a href="#{{MODULE}}-%s">%s</a></dt><dd>%s</dd>'):format(M.name, M.name, M.title)

	local long = {}
	local function F(s, ...) long[#long+1] = select('#', ...) > 0 and s:format(...) or s end
	F('<a name="{{MODULE}}-%s" id="{{MODULE}}-%s"></a>', M.name, M.name)
	F('<div class="section-block"><h4>%s<a class="top" href="#{{MODULE}}">^ top</a></h4>', M.title) -- section block>
	F(markup(M.content))
	if M.example then
		if type(M.example) ~= 'table' then M.example = {M.example} end
		F('<div class="example">Example:')
		for i=1,#M.example do
			F('<pre><code class="lua">')
			F(M.example[i])
			F('</code></pre>')
		end
		F('</div>')
	end
	F('</div>') -- <section block

	return {short = short, long = table.concat(long)}
end

function Function(M)
	for _,field in ipairs{'name', 'short', 'long', 'params', 'returns', 'example'} do
		assert(M[field], "Function: Required field `"..field.."' is missing")
	end

	if type(M.name)  ~= 'table' then M.name = {M.name} end
	if type(M.short) ~= 'table' then M.short = {M.short} end
	assert(#M.name >= #M.short)

	local short = {}
	for i=1,#M.short do
		short[i] = ('<dt><a href="#{{MODULE}}-%s">%s()</a></dt><dd>%s</dd>'):format(M.name[i], M.name[i], M.short[i])
	end
	short = table.concat(short)

	local args
	if #M.params == 0 then
		args = '()'
	elseif M.params.table_argument then
		args = {}
		for i,p in ipairs(M.params) do
			if p.name then
				args[i] = p.name..' = '.. p[2]
			else
				args[i] = p[2]
			end
		end
		args = '{'..table.concat(args, ', ')..'}'
	else
		args = {}
		for i,p in ipairs(M.params) do
			args[i] = p[2]
		end
		args = '('..table.concat(args, ', ')..')'
	end

	local long = {}
	local function F(s, ...) long[#long+1] = select('#', ...) > 0 and s:format(...) or s end

	-- header(s)
	for i=1,#M.name do F('<a name="{{MODULE}}-%s" id="{{MODULE}}-%s"></a>', M.name[i], M.name[i]) end
	F('<div class="ref-block">')
	for i=1,#M.name do
		F('<h4>function <span class="name">%s</span><span class="arglist">%s</span><a class="top" href="#{{MODULE}}">^ top</a></h4>', M.name[i], args) -- section block>
	end

	-- description
	F(markup(M.long))

	-- parameters
	F('<div class="arguments">Parameters:<dl>')
	if #M.params == 0 then F('<dt>None</dt>') end
	for _,p in ipairs(M.params) do
		F('<dt>%s <code>%s</code>%s</dt><dd>%s</dd>', p[1], p[2], p.optional and ' (optional)' or '', markup(p[3]):sub(4,-5))
	end
	F('</dl></div>')

	-- return values
	F('<div class="returns">Returns:<dl>')
	if #M.returns == 0 then F('<dt>Nothing</dt>') end
	for _,r in ipairs(M.returns) do
		F('<dt>%s</dt><dd>%s</dd>', r[1], markup(r[2]):sub(4,-5))
	end
	F('</dl></div>')

	-- example(s)
	if type(M.example) ~= 'table' then M.example = {M.example} end
	F('<div class="example">Example:')
	for i=1,#M.example do
		F('<pre><code class="lua">')
		F(M.example[i])
		F('</code></pre>')
	end
	F('</div>')

	-- sketch
	if M.sketch then
		F('<div class="example">Sketch:<img src="%s" width="%s" height="%s" /></div>', M.sketch[1], M.sketch.width, M.sketch.height)
	end

	F('</div>') -- <section block

	return {short = short, long = table.concat(long)}
end

dofile(...) -- magic

-- ASSEMBLE DOCUMENTATION MARKUP
io.write([[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><title>hump - L&Ouml;VE Helper Utilities for More Productivity</title><link rel="stylesheet" type="text/css" href="style.css" /><link rel="stylesheet" type="text/css" href="highlight.css" /><script type="text/javascript" src="highlight.pack.js"></script><script type="text/javascript">window.onload = function() {var examples = document.getElementsByTagName("code");for (i = 0; i < examples.length; ++i) {if (examples[i].className == "lua")hljs.highlightBlock(examples[i], "    ");}};</script></head><body><a name="top" id="top"></a><div id="header"><h1><a href="http://github.com/vrld/hump">hump</a><span class="small"> Helper Utilities for More Productivity</span></h1><ul id="main-nav"><li><a href="#intro">Introduction</a></li><li><a href="#doc">Documenation</a></li><li><a href="#license">License</a></li><li><a href="#download">Download</a></li></ul><h2>&nbsp;</h2></div><a name="intro" id="intro"></a><div class="outer-block"><h3>Introduction<a class="top" href="#top">^ top</a></h3><div class="preamble"><p><em>Helper Utilities for a Multitude of Problems</em> is a set of lightweight helpers for the <strong>awesome</strong> <a href="http://love2d.org/">L&Ouml;VE</a> Engine.</p><p>It features<ul><li><em>gamestate.lua</em>: a gamestate system.</li><li><em>timer.lua</em>: timed function calling and interpolating functions,</li><li><em>vector.lua</em>: a mature vector type,</li><li><em>vector-light.lua</em>: lightweight vector math,</li><li><em>class.lua</em>: a simple and easy class system,</li><li><em>camera.lua</em>: a move-, zoom- and rotatable camera and</li><li><em>ringbuffer.lua</em>: a circular container.</li></ul></p><p><em>hump</em> differs from other libraries in that every component is independent of the remaining ones (apart from camera.lua, which does depends on vector.lua). <em>hump</em>'s footprint is very small and thus should fit nicely into your projects.</p></div></div><a name="doc"></a><div class="outer-block"><h3>Documentation<a class="top" href="#top">^ top</a></h3><div class="preamble">]])
io.write('<dl>'..table.concat(DOC.short):gsub('Ö', '&Ouml;')..'</dl>')
io.write([[</div></div>]])
io.write(''..table.concat(DOC.long):gsub('Ö', '&Ouml;'))
io.write[[<a name="license" id="license"></a><div class="outer-block"><h3>License<a class="top" href="#top">^ top</a></h3><div class="preamble"><p>Yay, <em>free software</em>:</p><blockquote><p>Copyright (c) 2010 Matthias Richter</p><p>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:</p><p>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.</p><p>Except as contained in this notice, the name(s) of the above copyright holders shall not be used in advertising or otherwise to promote the sale, use or other dealings in this Software without prior written authorization.</p><p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.</p></blockquote></div></div><a name="download" id="download"></a><div class="outer-block"><h3>Download<a class="top" href="#top">^ top</a></h3><div class="preamble"><p>You can view and download the individual modules on github: <a href="http://github.com/vrld/hump">vrld/hump</a>. You may also download the whole packed sourcecode either in <a href="http://github.com/vrld/hump/zipball/master">zip</a> or <a href="http://github.com/vrld/hump/tarball/master">tar</a> formats.</p><p>You can clone the project with <a href="http://git-scm.com">Git</a> by running: <pre>git clone git://github.com/vrld/hump</pre> Once done, you can check for updates by running <pre>git pull</pre></p></div></div></body>]]
