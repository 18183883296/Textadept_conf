-- Copyright 2016-2022 Mitchell. See LICENSE.

local M = {}

--[[This comment is for LuaDoc
---
-- Textadept module for outputting source files into various formats like HTML.
--
-- Install this module by copying it into your *~/.textadept/modules/* directory or Textadept's
-- *modules/* directory, and then putting the following in your *~/.textadept/init.lua*:
--
--     require('export')
--
-- There will be a "File > Export" menu.
-- @field browser (string)
--   Path to or the name of the browser executable to show exported HTML files in.
--   The default value is 'firefox'.
-- @field line_numbers (boolean)
--   Whether or not to show line numbers in exported output.
--   The default value is `true`.
module('export')]]

M.browser = 'firefox'
M.line_numbers = true

-- Localizations.
if not rawget(_L, 'Export') then
  _L['Export'] = 'E_xport'
  _L['Export to HTML...'] = 'Export to _HTML...'
end

---
-- Exports filename *filename* (or the current file) to filename *out_filename* (or the
-- user-specified file) in HTML format, and then opens the result in a web browser.
-- @param filename The filename to export. The default value is the current buffer's filename.
-- @param out_filename The filename to export to. If `nil`, the user is prompted for one.
-- @name to_html
function M.to_html(filename, out_filename)
  -- Prompt the user for the HTML file to export to, if necessary.
  filename = filename or buffer.filename or ''
  local dir, name = filename:match('^(.-[/\\]?)([^/\\]-)%.?[^.]*$')
  out_filename = out_filename or ui.dialogs.filesave{
    title = _L['Save File'], with_directory = dir, with_file = name .. '.html',
    width = CURSES and ui.size[1] - 2 or nil
  }
  if not out_filename then return end

  local buffer = buffer
  local format = string.format

  local html = {}
  html[#html + 1] = '<html><head><meta charset="utf-8"/>'
  html[#html + 1] = format('<title>%s</title>',
    filename:iconv('UTF-8', _CHARSET) or buffer:untitled())

  -- Iterate over defined styles and convert them into CSS.
  html[#html + 1] = '<style type="text/css">'
  for i = 1, view.STYLE_MAX do
    name = buffer:name_of_style(i)
    if name == 'Not Available' then goto continue end
    local style = {}
    -- Determine style properties.
    local style_def = view.property['style.' .. name]
    style_def = style_def:gsub('[%%$](%b())',
      function(prop) return view.property[prop:sub(2, -2)] end)
    if style_def == '' then
      style_def = table.concat({
        string.format('size:%d', view.style_size[i]), -- LuaFormatter
        string.format('fore:%s', view.style_fore[i]), -- LuaFormatter
        string.format('back:%s', view.style_back[i]), -- LuaFormatter
        view.style_bold[i] and 'bold' or 'notbold',
        view.style_italic[i] and 'italics' or 'notitalics',
        view.style_underline[i] and 'underlined' or 'notunderlined'
      }, ',')
    end
    local font_size = style_def:match('size:(%d+)')
    local fore_color = style_def:match('fore:([^,]+)')
    local back_color = style_def:match('back:([^,]+)')
    -- TODO: inheritance like "...,bold,notbold,..."
    local bold = style_def:find('bold') and not style_def:find('notbold')
    local italic = style_def:find('italics') and not style_def:find('notitalics')
    local underline = style_def:find('underlined') and not style_def:find('notunderlined')
    -- Convert style properties to CSS.
    style[#style + 1] = name == 'default' and '* {' or format('.%s {', name)
    if name == 'default' then style[#style + 1] = 'font-family: Monospace;' end
    if font_size then style[#style + 1] = format('font-size: %dpt;', font_size) end
    if tonumber(fore_color) then
      local r = tonumber(fore_color) & 0xFF
      local g = (tonumber(fore_color) & (0xFF << 8)) >> 8
      local b = (tonumber(fore_color) & (0xFF << 16)) >> 16
      style[#style + 1] = format('color: rgb(%d,%d,%d);', r, g, b)
    end
    if tonumber(back_color) then
      local r = tonumber(back_color) & 0xFF
      local g = (tonumber(back_color) & (0xFF << 8)) >> 8
      local b = (tonumber(back_color) & (0xFF << 16)) >> 16
      style[#style + 1] = format('background-color: rgb(%d,%d,%d);', r, g, b)
    end
    if bold then style[#style + 1] = 'font-weight: bold;' end
    if italic then style[#style + 1] = 'font-style: italic;' end
    if underline then style[#style + 1] = 'text-decoration: underline;' end
    style[#style + 1] = '}\n'
    html[#html + 1] = table.concat(style, '\n')
    ::continue::
  end
  html[#html + 1] = '</style></head><body>'

  -- Start inserting line numbers as necessary.
  local line_num = 1
  local line_num_fmt = format('%%%dd', #tostring(buffer.line_count))
  if M.line_numbers then
    html[#html + 1] = format('<span class="linenumber">%s&nbsp;</span>',
      format(line_num_fmt, line_num):gsub(' ', '&nbsp;'))
    line_num = line_num + 1
  end

  -- Iterate over characters in the buffer, grouping styles into <span>s whose classes are
  -- their respective style names.
  local style_at = buffer.style_at
  local pos, style = 1, nil
  local prev_pos, prev_style
  local text_range = buffer.text_range
  local position_after = buffer.position_after
  local function format_span(code)
    -- Ensure HTML entities are escaped and insert line numbers as necessary.
    local function insert_line_number()
      local suffix = ''
      if M.line_numbers then
        suffix = format('<span class="linenumber">%s&nbsp;</span>',
          format(line_num_fmt, line_num):gsub(' ', '&nbsp;'))
        line_num = line_num + 1
      end
      return format('\n<br/>%s', suffix)
    end
    code = code:gsub('[<>& ]', {['<'] = '&lt;', ['>'] = '&gt;', ['&'] = '&amp;', [' '] = '&nbsp;'})
      :gsub('\n', insert_line_number)
    return format('%s</span>', code)
  end
  while pos <= buffer.length do
    style = style_at[pos]
    if style ~= prev_style then
      -- Start of new <span>. Finish the old one first, if necessary.
      if prev_pos then html[#html + 1] = format_span(text_range(buffer, prev_pos, pos)) end
      html[#html + 1] = format('<span class="%s">', buffer:name_of_style(style))
      prev_pos, prev_style = pos, style
    end
    pos = position_after(buffer, pos)
  end
  -- Finish any incomplete <span>.
  if prev_pos then html[#html + 1] = format_span(text_range(buffer, prev_pos, buffer.length + 1)) end

  html[#html + 1] = '</body></html>'

  -- Done. Export to the file and show it.
  io.open(out_filename, 'wb'):write(table.concat(html)):close()
  os.spawn(format('%s "%s"', M.browser, out_filename))
end

-- Add a sub-menu.
local m_file = textadept.menu.menubar[_L['File']]
table.insert(m_file, #m_file - 1, {''}) -- separator
table.insert(m_file, #m_file - 1, {title = _L['Export'], {_L['Export to HTML...'], M.to_html}})

return M
