local terminal = "kitty"
local fileManager = "thunar"
local mainMod = "SUPER"

hl.monitor({
	output = "DP-1",
	mode = "2560x1440@74.78",
	position = "0x0",
	scale = 1,
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIB_DRIVER_NAME", "nvidia")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("quickshell --path /home/adrian/dotfiles/quickshell/.config/quickshell")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 6,
		border_size = 0,
		["col.active_border"] = "rgba(A7C080ff)",
		["col.inactive_border"] = "rgba(475258aa)",
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},
	animations = {
		enabled = true,
		bezier = {
			"quick,0.15,0,0.1,1",
		},
		animation = {
			"global, 1, 2.4, default",
			"windows, 1, 2.2, quick",
			"windowsIn, 1, 2.0, quick, popin 90%",
			"windowsOut, 1, 2.8, quick, popin 90%",
			"fade, 1, 2.0, quick",
			"fadeOut, 1, 2.8, quick",
			"layers, 1, 2.0, quick",
			"fadeLayers, 1, 2.0, quick",
			"fadeLayersOut, 1, 2.6, quick",
			"workspaces, 1, 2.4, quick, slidefade 15%",
			"workspacesIn, 1, 2.1, quick, slidefade 15%",
			"workspacesOut, 1, 3.2, quick, slidefade 15%",
		},
	},
	dwindle = {
		preserve_split = true,
		smart_split = true,
	},
	master = {
		new_status = "master",
	},
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
		vrr = 1,
	},
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "caps:escape",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = {
			natural_scroll = false,
		},
	},
	cursor = {
		no_hardware_cursors = false,
	},
})

hl.animation({ leaf = "global", enabled = true, speed = 2.4, bezier = "default" })
hl.animation({ leaf = "windows", enabled = true, speed = 2.2, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.6, bezier = "default", style = "popin 90%" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.8, bezier = "default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.0, bezier = "default" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.0, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.2, bezier = "default", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2.0, bezier = "default", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2.4, bezier = "default", style = "fade" })

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + SPACE", hl.dsp.global("quickshell:toggle_launcher"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + N", hl.dsp.global("quickshell:toggle_notification_history"))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("~/.config/hypr/toggle-hypridle.sh afk"))
hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd("~/.config/hypr/toggle-hypridle.sh normal"))

hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special(""))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { mouse = true })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { mouse = true })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.window_rule({
	match = { class = "impala" },
	float = true,
	center = true,
	size = "15% 40%",
	opacity = "1.0 1.0",
})
