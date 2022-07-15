require('spellcheck')
require('format')
require('export')
require('golang')
require('multiedit')
view:set_theme(not CURSES and 'gotime' or 'term')

io.encodings[#io.encodings + 1] = 'GBK'
table.insert(io.encodings, 3, 'GBK') -- before CP1252
local menu = textadept.menu.menubar[_L['Buffer']][_L['Encoding']]
local encoding = 'GBK'
menu[#menu + 1] = {encoding, function() buffer:set_encoding(encoding) end}

keys['ctrl+alt+j'] = require('format').paragraph
view.h_scroll_bar, view.v_scroll_bar =  false, true
ui.find.highlight_all_matches = true
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
textadept.editing.auto_enclose = true

-- 自动完成使用所有打开缓冲区中的单词，多个缓冲区打开时，性能可能会降低。
-- textadept.editing.autocomplete_all_words = true

-- Always strip trailing spaces, except in patch files.
events.connect(events.LEXER_LOADED, function(name)
  textadept.editing.strip_trailing_spaces = name ~= 'diff'
end)
buffer.tab_width = 4
buffer.use_tabs  = true
buffer.back_space_un_indents = true
view.view_ws  = view.WS_INVISIBLE

textadept.run.run_commands.crystal='wsl crystal "%f"'
textadept.run.compile_commands.crystal='wsl crystal build "%f" --release --link-flags -static'
textadept.run.run_commands.ruby='wsl ruby "%f"'
textadept.run.compile_commands.ruby='wsl mruby "%f"'
