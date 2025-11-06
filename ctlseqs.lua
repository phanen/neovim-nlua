return {
  -- Queries
  primary_device_attrs = '\x1b[c',
  tertiary_device_attrs = '\x1b[=c',
  device_status_report = '\x1b[5n',
  xtversion = '\x1b[>0q',
  decrqm_focus = '\x1b[?1004$p',
  decrqm_sgr_pixels = '\x1b[?1016$p',
  decrqm_sync = '\x1b[?2026$p',
  decrqm_unicode = '\x1b[?2027$p',
  decrqm_color_scheme = '\x1b[?2031$p',
  csi_u_query = '\x1b[?u',
  kitty_graphics_query = '\x1b_Gi=1,a=q\x1b\\',
  sixel_geometry_query = '\x1b[?2;1;0S',
  cursor_position_request = '\x1b[6n',
  explicit_width_query = '\x1b]66;w=1; \x1b\\',
  scaled_text_query = '\x1b]66;s=2; \x1b\\',
  multi_cursor_query = '\x1b[> q',

  -- Mouse
  mouse_set = '\x1b[?1002;1003;1004;1006h',
  mouse_set_pixels = '\x1b[?1002;1003;1004;1016h',
  mouse_reset = '\x1b[?1002;1003;1004;1006;1016l',

  -- In-band window size reports
  in_band_resize_set = '\x1b[?2048h',
  in_band_resize_reset = '\x1b[?2048l',

  -- Sync
  sync_set = '\x1b[?2026h',
  sync_reset = '\x1b[?2026l',

  -- Unicode
  unicode_set = '\x1b[?2027h',
  unicode_reset = '\x1b[?2027l',
  explicit_width = '\x1b]66;w=%d;%s\x1b\\',

  -- Text sizing
  scaled_text = '\x1b]66;s=%d:w=%d;%s\x1b\\',
  scaled_text_with_fractions = '\x1b]66;s=%d:w=%d:n=%d:d=%d:v=%d;%s\x1b\\',

  -- Bracketed paste
  bp_set = '\x1b[?2004h',
  bp_reset = '\x1b[?2004l',

  -- Color scheme updates
  color_scheme_request = '\x1b[?996n',
  color_scheme_set = '\x1b[?2031h',
  color_scheme_reset = '\x1b[?2031l',

  -- Key encoding
  csi_u_push = '\x1b[>%du',
  csi_u_pop = '\x1b[<u',

  -- Cursor
  home = '\x1b[H',
  cup = '\x1b[%d;%dH',
  hide_cursor = '\x1b[?25l',

  show_cursor = '\x1b[?25h',
  cursor_shape = '\x1b[%d q',
  ri = '\x1bM',
  ind = '\n',
  cuf = '\x1b[%dC',
  cub = '\x1b[%dD',

  -- Erase
  erase_below_cursor = '\x1b[J',

  -- Alt screen
  smcup = '\x1b[?1049h',
  rmcup = '\x1b[?1049l',

  -- SGR reset all
  sgr_reset = '\x1b[m',
  sgr_fg_rgb = '\x1b[38:2:%d:%d:%dm',
  sgr_bg_rgb = '\x1b[48:2:%d:%d:%dm',

  -- Colors
  fg_base = '\x1b[3%dm',
  fg_bright = '\x1b[9%dm',
  bg_base = '\x1b[4%dm',
  bg_bright = '\x1b[10%dm',

  fg_reset = '\x1b[39m',
  bg_reset = '\x1b[49m',
  ul_reset = '\x1b[59m',
  fg_indexed = '\x1b[38:5:%dm',
  bg_indexed = '\x1b[48:5:%dm',
  ul_indexed = '\x1b[58:5:%dm',
  fg_rgb = '\x1b[38:2:%d:%d:%dm',
  bg_rgb = '\x1b[48:2:%d:%d:%dm',
  ul_rgb = '\x1b[58:2:%d:%d:%dm',
  fg_indexed_legacy = '\x1b[38;5;%dm',
  bg_indexed_legacy = '\x1b[48;5;%dm',
  ul_indexed_legacy = '\x1b[58;5;%dm',
  fg_rgb_legacy = '\x1b[38;2;%d;%d;%dm',
  bg_rgb_legacy = '\x1b[48;2;%d;%d;%dm',
  ul_rgb_legacy = '\x1b[58;2;%d;%d;%dm',
  ul_rgb_conpty = '\x1b[58:2::%d:%d:%dm',

  -- Underlines
  ul_off = '\x1b[24m', -- NOTE: this could be \x1b[4:0m but is not as widely supported
  ul_single = '\x1b[4m',
  ul_double = '\x1b[4:2m',
  ul_curly = '\x1b[4:3m',
  ul_dotted = '\x1b[4:4m',
  ul_dashed = '\x1b[4:5m',

  -- Attributes
  bold_set = '\x1b[1m',
  dim_set = '\x1b[2m',
  italic_set = '\x1b[3m',
  blink_set = '\x1b[5m',
  reverse_set = '\x1b[7m',
  invisible_set = '\x1b[8m',
  strikethrough_set = '\x1b[9m',
  bold_dim_reset = '\x1b[22m',
  italic_reset = '\x1b[23m',
  blink_reset = '\x1b[25m',
  reverse_reset = '\x1b[27m',
  invisible_reset = '\x1b[28m',
  strikethrough_reset = '\x1b[29m',

  -- OSC sequences
  osc2_set_title = '\x1b]2;%s\x1b\\',
  osc7 = '\x1b]7;%s\x1b\\',
  osc8 = '\x1b]8;%s;%s\x1b\\',
  osc8_clear = '\x1b]8;;\x1b\\',
  osc9_notify = '\x1b]9;%s\x1b\\',
  osc777_notify = '\x1b]777;notify;%s;%s\x1b\\',
  osc22_mouse_shape = '\x1b]22;%s\x1b\\',
  osc52_clipboard_copy = '\x1b]52;c;%s\x1b\\',
  osc52_clipboard_request = '\x1b]52;c;?\x1b\\',

  -- Kitty graphics
  kitty_graphics_clear = '\x1b_Ga=d\x1b\\',
  kitty_graphics_preamble = '\x1b_Ga=p,i=%d',
  kitty_graphics_closing = ',C=1\x1b\\',

  -- Color control sequences
  osc4_query = '\x1b]4;%d;?\x1b\\', -- color index %d
  osc4_reset = '\x1b]104\x1b\\', -- this resets _all_ color indexes
  osc10_query = '\x1b]10;?\x1b\\', -- fg
  osc10_set = '\x1b]10;rgb:%s/%s/%s\x1b\\', -- set default terminal fg
  osc10_reset = '\x1b]110\x1b\\', -- reset fg to terminal default
  osc11_query = '\x1b]11;?\x1b\\', -- bg
  osc11_set = '\x1b]11;rgb:%s/%s/%s\x1b\\', -- set default terminal bg
  osc11_reset = '\x1b]111\x1b\\', -- reset bg to terminal default
  osc12_query = '\x1b]12;?\x1b\\', -- cursor color
  osc12_set = '\x1b]12;rgb:%s/%s/%s\x1b\\', -- set terminal cursor color
  osc12_reset = '\x1b]112\x1b\\', -- reset cursor to terminal default
}
