-- environment.lua
-- Copyright (C) 2020 by RStudio, PBC
--
local system = require 'pandoc.system'

local tikz_doc_template = [[
\documentclass{standalone}

\usepackage{xcolor}
\usepackage{graphicx}
\usepackage{tikz}

\usetikzlibrary{shapes.geometric, arrows}
\usetikzlibrary{calc,positioning}

\graphicspath{{../../}}

\begin{document}
\nopagecolor
%s
\end{document}
]]

local function tikz2image(id, src, filetype, outfile, outdir)
    --system.with_working_directory(wd, function()
      local f = io.open(outfile .. '.tex', 'w')
      f:write(tikz_doc_template:format(src))
      f:close()
      --os.execute('pdflatex tikz.tex')
      os.execute('pdflatex -interaction=nonstopmode -output-directory='.. outdir .. ' ' .. outfile .. '.tex' .. ' --embedimages --box media -8bit')
      os.execute('pdf2svg '.. outfile .. '.pdf ' .. outfile)
    --end)
end

extension_for = {
  html = 'svg',
  html4 = 'svg',
  html5 = 'svg',
  latex = 'pdf',
  beamer = 'pdf' }

local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function starts_with(start, str)
  return str:sub(1, #start) == start
end

local function contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

function get_file_name(file)
      local file_name = file:match("[^/]*$")
      return file_name:sub(0, #file_name)
end

local function rendertikz(cb)
    if cb.attr.classes:find('{tikz}') or cb.attr.classes:find('tikz') then
        local filetype = extension_for[FORMAT] or 'svg'
        local output_directory = quarto.doc.input_file:sub(1, -5) .. '_files'
        local fdirname = get_file_name(output_directory)
        quarto.log.output(fdirname)

        local id = pandoc.sha1(cb.text)
        local fbasename = id .. '.' .. filetype
        local fname = output_directory .. '/tikz/' .. fbasename
        local relpath = fdirname .. '/tikz/' .. fbasename

        if not file_exists(output_directory .. '/tikz') then
            os.execute("mkdir " .. output_directory)
            os.execute("mkdir " .. output_directory .. '/tikz')
        end

--        if not file_exists(fname) then
            tikz2image(id, cb.text, filetype, fname, fdirname .. '/tikz')
 --       end
        local file = io.open(fname, "r") -- r read mode and b binary mode
        local content = file:read("*all")
        file:close()

        local a = pandoc.RawBlock('html', '<object data="' .. relpath.. '" type="image/svg+xml"></object>')
        local b = pandoc.RawBlock('html', content)
        local aa = pandoc.Div(pandoc.Image({}, relpath), cb.attr)
        local c = pandoc.Div(b, cb.attr)
        return aa
    else
        return cb
    end
end

return {
    {
        CodeBlock = rendertikz
    }
}
