local wezterm = require("wezterm")

local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

local function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
        return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
end

local dark_bg = "#0b0022"

local inactive_bg = "#1b1032"
local inactive_fg = "#808080"

local hover_bg = "#3b3052"
local hover_fg = "#909090"

local active_bg = "#2b2042"
local active_fg = "#c0c0c0"

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
    local edge_background = dark_bg
    local background = inactive_bg
    local foreground = inactive_fg

    if tab.is_active then
        background = active_bg
        foreground = active_fg
    elseif hover then
        background = hover_bg
        foreground = hover_fg
    end

    local edge_foreground = background

    local title = tab_title(tab)

    -- ensure that the titles fit in the available space,
    -- and that we have room for the edges.
    title = wezterm.truncate_right(title, max_width - 6)

    return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = " " .. SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = " " .. title .. " " },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW .. " " },
    }
end)

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

return {
    color_scheme = "catppuccin-mocha",

    -- font settings
    font_size = 11,
    font = wezterm.font_with_fallback({ "FantasqueSansM Nerd Font", "JetBrains Mono" }),
    warn_about_missing_glyphs = false,

    -- tab bar settings
    use_fancy_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    tab_max_width = 50,
    colors = {
        tab_bar = {
            background = dark_bg,
            new_tab = {
                bg_color = dark_bg,
                fg_color = inactive_fg,
            },
            new_tab_hover = {
                bg_color = hover_bg,
                fg_color = hover_fg,
                intensity = "Bold",
                italic = false,
            },
            active_tab = {
                -- colors are unnecessary here due to format function overriding them,
                -- but wezterm complains if I don't include them
                bg_color = active_bg,
                fg_color = active_fg,
                intensity = "Bold",
            },
            inactive_tab_hover = {
                -- colors are unnecessary here due to format function overriding them,
                -- but wezterm complains if I don't include them
                bg_color = hover_bg,
                fg_color = hover_fg,
                intensity = "Bold",
                italic = false,
            },
        },
    },

    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
}
