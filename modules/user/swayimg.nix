{ config, pkgs, theme, ... }:

# swayimg as a minimal, chrome-less viewer: pure black canvas (matching the
# island), quiet SF overlay that fades out, vim-style keys.
let
  argb = hex: alpha: "0x${alpha}${hex}";
in
{
  home.packages = [ pkgs.swayimg ];

  xdg.configFile."swayimg/init.lua".text = ''
    -- Closs swayimg config (generated from theme.nix)

    swayimg.enable_decoration(false)
    swayimg.enable_antialiasing(true)
    swayimg.imagelist.enable_adjacent(true)  -- browse the rest of the folder
    swayimg.imagelist.set_order("alpha")

    -- Overlay: small, quiet, gone after 2s
    swayimg.text.set_font("${theme.font.ui}")
    swayimg.text.set_size(15)
    swayimg.text.set_padding(18)
    swayimg.text.set_foreground(${argb theme.fg "ff"})
    swayimg.text.set_background(${argb theme.black "00"})
    swayimg.text.set_shadow(${argb theme.black "a0"})
    swayimg.text.set_timeout(2)
    swayimg.text.set_status_timeout(2)

    -- Viewer
    swayimg.viewer.set_window_background(${argb theme.black "ff"})
    swayimg.viewer.set_image_chessboard(16, ${argb theme.surface "ff"}, ${argb theme.surface2 "ff"})
    swayimg.viewer.set_default_scale("optimal")
    swayimg.viewer.set_mark_color(${argb theme.primary "ff"})
    swayimg.viewer.set_text("topleft", { "{name}" })
    swayimg.viewer.set_text("topright", { "{list.index} / {list.total}" })
    swayimg.viewer.set_text("bottomleft", { "{frame.width}×{frame.height}  ·  {sizehr}" })
    swayimg.viewer.set_text("bottomright", { "{scale}" })
    swayimg.on_window_resize(function() swayimg.viewer.set_fix_scale("optimal") end)

    -- Gallery
    swayimg.gallery.set_window_color(${argb theme.black "ff"})
    swayimg.gallery.set_unselected_color(${argb theme.bg_alt "ff"})
    swayimg.gallery.set_selected_color(${argb theme.surface "ff"})
    swayimg.gallery.set_border_color(${argb theme.primary "ff"})
    swayimg.gallery.set_border_size(2)
    swayimg.gallery.set_padding_size(8)
    swayimg.gallery.set_selected_scale(1.06)
    swayimg.gallery.set_thumb_size(220)
    swayimg.gallery.set_text("topleft", { "{name}" })
    swayimg.gallery.set_text("topright", { "{list.index} / {list.total}" })

    -- Keys (vim-flavoured)
    local v, g = swayimg.viewer, swayimg.gallery
    local function zoom(f)
      return function() v.set_abs_scale(v.get_scale() * f) end
    end
    local function pan(dx, dy)
      return function()
        local w = swayimg.get_window_size()
        local p = v.get_position()
        v.set_abs_position(math.floor(p.x + dx * w.width / 8), math.floor(p.y + dy * w.height / 8))
      end
    end

    v.on_key("q", swayimg.exit)
    v.on_key("Escape", swayimg.exit)
    v.on_key("n", function() v.switch_image("next") end)
    v.on_key("p", function() v.switch_image("prev") end)
    v.on_key("space", function() v.switch_image("next") end)
    v.on_key("Shift-space", function() v.switch_image("prev") end)
    v.on_key("g", function() v.switch_image("first") end)
    v.on_key("Shift-g", function() v.switch_image("last") end)
    v.on_key("h", pan(1, 0))
    v.on_key("l", pan(-1, 0))
    v.on_key("k", pan(0, 1))
    v.on_key("j", pan(0, -1))
    v.on_key("plus", zoom(1.15))
    v.on_key("equal", zoom(1.15))
    v.on_key("minus", zoom(1 / 1.15))
    v.on_key("0", function() v.set_fix_scale("real") end)
    v.on_key("w", function() v.set_fix_scale("fit") end)
    v.on_key("Shift-w", function() v.set_fix_scale("fill") end)
    v.on_key("z", function() v.reset() end)
    v.on_key("r", function() v.rotate(90) end)
    v.on_key("Shift-r", function() v.rotate(270) end)
    v.on_key("m", function() v.flip_horizontal() end)
    v.on_key("f", swayimg.toggle_fullscreen)
    v.on_key("i", function()
      if swayimg.text.visible() then swayimg.text.hide() else swayimg.text.show() end
    end)
    v.on_key("Return", function() swayimg.set_mode("gallery") end)
    local function sq(str)
      return "'" .. (str:gsub("'", [['"'"']])) .. "'"
    end
    v.on_key("y", function()
      os.execute("wl-copy < " .. sq(v.get_image().path))
      swayimg.text.set_status("Copied")
    end)
    v.on_key("Shift-y", function()
      os.execute("printf %s " .. sq(v.get_image().path) .. " | wl-copy")
      swayimg.text.set_status("Copied path")
    end)
    v.on_mouse("ScrollUp", zoom(1.1))
    v.on_mouse("ScrollDown", zoom(1 / 1.1))

    g.on_key("q", swayimg.exit)
    g.on_key("Escape", function() swayimg.set_mode("viewer") end)
    g.on_key("Return", function() swayimg.set_mode("viewer") end)
    g.on_key("h", function() g.switch_image("left") end)
    g.on_key("j", function() g.switch_image("down") end)
    g.on_key("k", function() g.switch_image("up") end)
    g.on_key("l", function() g.switch_image("right") end)
    g.on_key("g", function() g.switch_image("first") end)
    g.on_key("Shift-g", function() g.switch_image("last") end)
  '';
}
