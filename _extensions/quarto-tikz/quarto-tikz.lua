-- environment.lua
-- Copyright (C) 2020 by RStudio, PBC
--
local system = require 'pandoc.system'

local tikz_doc_template = [[
\documentclass{standalone}
\usepackage{xcolor}
\usepackage{tikz}
\begin{document}
\nopagecolor
%s
\end{document}
]]

local function tikz2image(src, filetype, outfile)
  system.with_temporary_directory('tikz2image', function (tmpdir)
    system.with_working_directory(tmpdir, function()
      local f = io.open('tikz.tex', 'w')
      f:write(tikz_doc_template:format(src))
      f:close()
      --os.execute('pdflatex tikz.tex')
      os.execute('pdflatex -interaction=nonstopmode tikz.tex')
      if filetype == 'pdf' then
        os.rename('tikz.pdf', outfile)
      else
        os.execute('pdf2svg tikz.pdf ' .. outfile)
      end
    end)
  end)
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

        local fbasename = pandoc.sha1(cb.text) .. '.' .. filetype
        local fname = output_directory .. '/' .. fbasename
        local relpath = fdirname .. '/' .. fbasename

        if not file_exists(fname) then
            tikz2image(cb.text, filetype, fname)
        end

        local b = pandoc.Div(pandoc.Image({}, relpath), cb.attr)
        return b
    else
        return cb
    end
end

return {
    {
        CodeBlock = rendertikz
    }
}
