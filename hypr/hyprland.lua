--------------------
---- MONITORS ----
--------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@144",
    position = "0x0",
    scale    = 1,
    bitdepth = 10,
})

------------------------------
---- ENVIRONMENT VARIABLES ----
------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE",                    "24")

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME",              "nvidia")
hl.env("XDG_SESSION_TYPE",               "wayland")
hl.env("GBM_BACKEND",                    "nvidia-drm")   -- firefox crash :( 
hl.env("__GLX_VENDOR_LIBRARY_NAME",      "nvidia")
hl.env("NVD_BACKEND",                    "direct")

-- Qt
hl.env("QT_QPA_PLATFORM",               "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",   "1")
hl.env("QT_QPA_PLATFORMTHEME",          "qt5ct")

-- Electron
hl.env("ELECTRON_OZONE_PLATFORM_HINT",  "wayland")

--------------------
---- LOOK & FEEL ----
--------------------
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    cursor = {
        no_hardware_cursors = false, -- true?
        zoom_rigid          = true,
    },

    general = {
        gaps_in     = 10,
        gaps_out    = 20,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(b4befeee)", "rgba(cba6f7ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled          = true,
            size             = 4,
            passes           = 3,
            new_optimizations = true,
            ignore_opacity   = true,
            noise            = 0,
            brightness       = 0.90,
        },
        -- shadow = {
        --     enabled      = true,
        --     range        = 4,
        --     render_power = 3,
        --     color        = 0xee1a1a1a,
        -- },
    },

    animations = {
        enabled = true,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity  = 0.0,  -- -1.0 to 1.0, 0 = no modification
        touchpad = {
            natural_scroll = false,
        },
    },

    dwindle = {
        preserve_split       = true,
        special_scale_factor = 1.0,
    },

    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo = true,
    },

    binds = {
        allow_workspace_cycles = true,
    },
})

-----------------------
---- ANIMATIONS ----
-----------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "default",   style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle",enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })

-----------------------
---- GESTURE ----
-----------------------
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-----------------------
---- PLUGIN ----
-----------------------

-- Nothing here rn

--------------------
---- AUTOSTART ----
--------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- exec-once is replaced by hl.on("hyprland.start", ...) with hl.exec_cmd()
-- hl.exec_cmd() spawns async, no need for & disown
hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("gammastep-indicator")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("awww img wallpapers/moony-night.png")
    hl.exec_cmd("fcitx5 && fcitx5-remote -r")
    hl.exec_cmd("copyq --start-server")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("/opt/KopiaUI/kopia-ui")
    hl.exec_cmd("hyprctl setcursor phinger-cursors-dark 24")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME")

    -- Trays
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("pasystray")
    hl.exec_cmd("blueman-tray")
    hl.exec_cmd("qs -c overview")

    -- yeahhh
    -- hl.exec_cmd("diurnals")  -- Wait until AUR bump
    hl.exec_cmd("flatpak run io.github.sss_says_snek.diurnals")

    -- Launch apps into specific workspaces
    hl.exec_cmd("[workspace 1 silent] firefox")
    hl.exec_cmd("[workspace 2 silent] kitty")
    hl.exec_cmd("[workspace 4 silent] discord")
    hl.exec_cmd("[workspace 7 silent] pear-desktop")
end)

--------------------
---- LAYER RULES ----
--------------------
-- IDK
hl.layer_rule({ name = "layerrule-1", match = { namespace = "rofi" },       blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "layerrule-2", match = { namespace = "hyprpicker" }, no_anim = true })
hl.layer_rule({ name = "layerrule-3", match = { namespace = "selection" },  no_anim = true })

--------------------
---- WINDOW RULES ----
--------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
    name    = "windowrule-1",
    match   = { class = "^(kitty|discord|vesktop|org.prismlauncher.PrismLauncher)$" },
    opacity = "0.9 0.85",
})

-- FLOATS
hl.window_rule({ name = "pavucontrol",  match = { class = "^(org.pulseaudio.pavucontrol)$" },                                                float = true })
hl.window_rule({ name = "windowrule-3",  match = { class = "^(blueman-manager|Pinentry-gtk-2|com.github.hluk.copyq|xdg-desktop-portal-gtk|RimPy)$" }, float = true })
hl.window_rule({ name = "windowrule-4",  match = { class = "^(org.gnome.FileRoller|file-roller)$" },                                          float = true })
hl.window_rule({ name = "windowrule-5",  match = { class = "firefox", title = "Library(.*)$" },                                               float = true })
hl.window_rule({ name = "windowrule-6",  match = { class = "(main\\.py)$" },                                                                  float = true })
hl.window_rule({ name = "windowrule-7",  match = { class = "(rquickshare)$" },                                                                float = true })
hl.window_rule({ name = "windowrule-8",  match = { class = "^(io\\.github\\.sss_says_snek\\.diurnals)$" },                                    float = true })
hl.window_rule({ name = "windowrule-9",  match = { class = "^firefox$", title = "^Extension:(.*)$" },                                         float = true })

hl.window_rule({ name = "windowrule-10", match = { class = "^(io.github.celluloid_player.Celluloid)$" }, suppress_event = "maximize" })
hl.window_rule({ name = "windowrule-11", match = { class = "^steam_app%d+$" },                           fullscreen = true })
hl.window_rule({ name = "windowrule-12", match = { class = "^steam_app_%d+$" },                          monitor = 1 })

-- DaVinci Resolve popup focus (tag-based)
hl.window_rule({ name = "windowrule-13", match = { class = "^(resolve)$", float = true }, tag = "+drpopup" })
hl.window_rule({ name = "windowrule-14", match = { tag = "drpopup" },                     stay_focused = true })

--------------------
---- KEYBINDS ----
--------------------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "ALT"

-- Core window management
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun -theme ~/.config/rofi/launcher.rasi"))
-- NOTE: mainMod+P (pseudo/pseudotile) removed — dwindle:pseudotile was dropped in 0.55
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

-- Move focus (HJKL)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,        hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0",        hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Scroll through workspaces with mainMod + mouse scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Custom binds
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("~/.config/rofi/power-menu.sh"))
hl.bind(mainMod .. " + F",         hl.dsp.exec_cmd("nautilus --new-window"))
hl.bind(mainMod .. " + TAB",       hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("wayscriber -a"))

-- Mouse side button
hl.bind(mainMod .. " + mouse:275", hl.dsp.window.kill())

-- Print screen
hl.bind("Print",             hl.dsp.exec_cmd("grimblast copy area"))
hl.bind("SHIFT + Print",     hl.dsp.exec_cmd("grimblast copy screen"))
hl.bind("CTRL + Print",      hl.dsp.exec_cmd("grimblast save area - | swappy -f -"))
hl.bind("SUPER + Print",     hl.dsp.exec_cmd("grimblast --freeze copy area - | swappy -f -"))

hl.bind("SUPER + F",  hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind("SUPER + K",  hl.dsp.window.move({ workspace = "special" }))
hl.bind("SUPER + F8", hl.dsp.workspace.toggle_special())
hl.bind("SUPER + C",  hl.dsp.exec_cmd("copyq toggle"))

hl.bind("SUPER + F6", hl.dsp.exec_cmd("qs ipc -p '/home/bdon/Downloads/files (2)/' call wha toggleDrawer"))
hl.bind("SUPER + F7", hl.dsp.exec_cmd("qs ipc -p '/home/bdon/Downloads/files (2)/' call wha toggleEditor"))

hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview toggle"))

-- Audio — repeating binds use { repeat = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer --set-limit 250 --allow-boost --increase 2"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer --set-limit 250 --allow-boost --decrease 2"), { repeating = true })
hl.bind("SUPER + W",            hl.dsp.exec_cmd("pamixer --set-limit 250 --allow-boost --increase 2"), { repeating = true })
hl.bind("SUPER + S",            hl.dsp.exec_cmd("pamixer --set-limit 250 --allow-boost --decrease 2"), { repeating = true })
hl.bind("SUPER + M",            hl.dsp.exec_cmd("pamixer --toggle-mute"),                              { repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer --toggle-mute"))

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- Audio sink switching — Le Olde headset
hl.bind("SUPER + A", hl.dsp.exec_cmd("pactl set-default-sink alsa_output.pci-0000_80_1f.3.analog-stereo"))
-- hl.bind("SUPER + A", hl.dsp.exec_cmd("pactl set-default-sink alsa_output.usb-Logitech_G432_Gaming_Headset_000000000000-00.analog-stereo"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo"))

-- Global keybind (pass to OBS)
hl.bind("Home", hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }))

-- Cursor zoom
hl.bind("CTRL + SUPER + equal", hl.dsp.exec_cmd(
    [[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 1.25}')"]]
), { repeating = true })
hl.bind("CTRL + SUPER + minus", hl.dsp.exec_cmd(
    [[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 1.25}')"]]
), { repeating = true })
hl.bind("CTRL + SUPER + 0", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1"), { repeating = true })

-- Waybar bindings toggle submap
hl.bind("SUPER + x", hl.dsp.exec_cmd("~/.config/waybar/scripts/toggle-hyprland-bindings.sh toggle"))
hl.define_submap("clean", function()
    hl.bind("SUPER + x", hl.dsp.exec_cmd("~/.config/waybar/scripts/toggle-hyprland-bindings.sh toggle"))
end)


local alt_passthrough_keys = {
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
    "a", "s", "d", "f", "g", "h", "j", "k", "l",
    "z", "x", "c", "v", "b", "n", "m",
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
    "F1", "F2", "F3", "F4", "F5", "F6",
    "F7", "F8", "F9", "F10", "F11", "F12",
    "Tab", "Return", "space", "BackSpace", "Delete",
    "Left", "Right", "Up", "Down",
}
 
-- Register F13 + ALT + <key> → send ALT+<key> to active window
for _, key in ipairs(alt_passthrough_keys) do
    hl.bind("SUPER + ALT + " .. key, hl.dsp.send_shortcut({
        mods   = "ALT",
        key    = key,
        window = "activewindow",
    }))
end
 
-- Also forward ALT+SHIFT combos (e.g. FL Studio ALT+SHIFT+something)
for _, key in ipairs(alt_passthrough_keys) do
    hl.bind("SUPER + ALT + SHIFT + " .. key, hl.dsp.send_shortcut({
        mods   = "ALT SHIFT",
        key    = key,
        window = "activewindow",
    }))
end

