--- gotime.lua

-- Copyright (C) 2022 , Sunrise

-- Author: Sunrise
-- Version: 0.4
-- Created with ThemeCreator, https://github.com/mswift42/themecreator.
-- Textadept theme template was provided by Pedro A. Aranda Gutiérrez,
-- https://github.com/paaguti.

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.

-- This file is not part of TextAdept
local view, colors, styles = view, lexer.colors, lexer.styles

colors.fg1      = 0xff80ff
colors.fg2      = 0xeb76eb
colors.fg3      = 0xd66cd6
colors.fg4      = 0xc261c2
colors.bg1      = 0x000024
colors.bg2      = 0x141436
colors.bg3      = 0x292947
colors.bg4      = 0x3d3d59
colors.builtin  = 0x00ffff
colors.keyword  = 0x4040ff
colors.const    = 0xff8080
colors.comment  = 0xffa000
colors.func     = 0x00ffff
colors.str      = 0x64b4ff
colors.type     = 0x40ff00
colors.var      = 0xffffff
colors.warning  = 0x4000ff
colors.warning2 = 0x0000ff

-- Default font.
if not font then
  font = WIN32 and 'OPPOSans M' or OSX and 'OPPOSans M' or
    'OPPOSans M'
end
if not size then size = OSX and 12 or 11 end

-- Find/replace dialog
ui.find.entry_font = font .. ' ' .. (size - 1)

-- Predefined styles.
styles.default = {
  font = font, size = size, fore = colors.fg1, back = colors.bg1
}
styles.line_number = {fore = colors.fg1, back = colors.bg2}
--styles.control_char =
styles.indent_guide = {fore = colors.comment}
styles.call_tip = {fore = colors.fg1, back = colors.bg2}
styles.fold_display_text = {fore = colors.bg2}

-- Token styles.
styles.class = {fore = colors.func, bold = true}
styles.comment = {fore = colors.comment}
styles.constant = {fore = colors.const}
styles.embedded = {fore = colors.builtin, back = colors.bg2}
styles.error = {fore = colors.warning, italics = true}
styles['function'] = {fore = colors.func}
styles.identifier = {fore=colors.var}
styles.keyword = {fore = colors.keyword}
styles.label = {fore = colors.warning}
styles.number = {fore = colors.const}
styles.operator = {fore = colors.fg2}
styles.preprocessor = {fore = colors.str}
styles.regex = {fore = colors.str}
styles.string = {fore = colors.str}
styles.type = {fore = colors.func}
styles.variable = {fore = colors.warning}
styles.whitespace = {}

-- Multiple Selection and Virtual Space
--view.additional_sel_alpha =
--view.additional_sel_fore =
--view.additional_sel_back =
--view.additional_caret_fore =

-- Caret and Selection Styles.
view:set_sel_fore(true, colors.fg3)
view:set_sel_back(true, colors.bg3)
--view.sel_alpha =
view.caret_fore = colors.fg2
view.caret_line_back = colors.bg2
--view.caret_line_back_alpha =

-- Fold Margin.
view:set_fold_margin_color(true, colors.bg2)
view:set_fold_margin_hi_color(true, colors.bg2)

-- Markers.
--view.marker_fore[textadept.bookmarks.MARK_BOOKMARK] = colors.bg1
view.marker_back[textadept.bookmarks.MARK_BOOKMARK] = colors.str
--view.marker_fore[textadept.run.MARK_WARNING] = colors.bg1
view.marker_back[textadept.run.MARK_WARNING] = colors.keyword
--view.marker_fore[textadept.run.MARK_ERROR] = colors.bg1
view.marker_back[textadept.run.MARK_ERROR] = colors.warning
for i = view.MARKNUM_FOLDEREND, view.MARKNUM_FOLDEROPEN do -- fold margin
  view.marker_fore[i] = colors.bg1
  view.marker_back[i] = colors.comment
  view.marker_back_selected[i] = colors.bg3
end

-- Indicators.
view.indic_fore[ui.find.INDIC_FIND] = colors.const
view.indic_alpha[ui.find.INDIC_FIND] = 255
view.indic_fore[textadept.editing.INDIC_BRACEMATCH] = colors.fg3
view.indic_fore[textadept.editing.INDIC_HIGHLIGHT] = colors.fg4
view.indic_alpha[textadept.editing.INDIC_HIGHLIGHT] = 64
view.indic_fore[textadept.snippets.INDIC_PLACEHOLDER] = colors.fg1

-- Call tips.
view.call_tip_fore_hlt = colors.fg3

-- Long Lines.
view.edge_color = colors.bg3

-- Add red, green, and yellow for diff lexer.
colors.red = colors.warning
colors.green = colors.str
colors.yellow = colors.keyword
