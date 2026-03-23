local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}
local space_brackets = {}
local space_paddings = {}

-- Function to update app icons for all workspaces
local function update_space_icons()
  sbar.exec("aerospace list-workspaces --focused", function(focused_ws)
    focused_ws = focused_ws and focused_ws:match("^%s*(.-)%s*$") or ""
    for i = 1, 9, 1 do
      sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}'", function(result)
        local icon_line = ""
        local no_app = true
        if result and result ~= "" then
          for app in result:gmatch("[^\n]+") do
            no_app = false
            local lookup = app_icons[app]
            local icon = ((lookup == nil) and app_icons["Default"] or lookup)
            icon_line = icon_line .. icon
          end
        end

        local is_focused = (tostring(i) == focused_ws)
        local should_show = not no_app or is_focused

        if no_app then
          icon_line = " —"
        end

        if spaces[i] then
          sbar.animate("tanh", 10, function()
            spaces[i]:set({
              label = { string = icon_line, highlight = is_focused },
              icon = { highlight = is_focused },
              drawing = should_show,
              background = { border_color = is_focused and colors.black or colors.bg2 },
            })
            if space_brackets[i] then
              space_brackets[i]:set({
                drawing = should_show,
                background = { border_color = is_focused and colors.grey or colors.bg2 },
              })
            end
            if space_paddings[i] then
              space_paddings[i]:set({ drawing = should_show })
            end
          end)
        end
      end)
    end
  end)
end

for i = 1, 9, 1 do
  local space = sbar.add("item", "space." .. i, {
    icon = {
      font = { family = settings.font.numbers },
      string = i,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.blue,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
    popup = { background = { border_width = 5, border_color = colors.black } }
  })

  spaces[i] = space

  -- Single item bracket for space items to achieve double border on highlight
  space_brackets[i] = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2
    }
  })

  local space_bracket = space_brackets[i]

  -- Padding space
  space_paddings[i] = sbar.add("item", "space.padding." .. i, {
    script = "",
    width = settings.group_paddings,
  })

  local space_popup = sbar.add("item", {
    position = "popup." .. space.name,
    padding_left = 5,
    padding_right = 0,
    background = {
      drawing = true,
      image = {
        corner_radius = 9,
        scale = 0.2
      }
    }
  })

  space:subscribe("aerospace_workspace_change", function(env)
    local selected = env.FOCUSED_WORKSPACE == tostring(i)
    space:set({
      icon = { highlight = selected },
      label = { highlight = selected },
      background = { border_color = selected and colors.black or colors.bg2 }
    })
    space_bracket:set({
      background = { border_color = selected and colors.grey or colors.bg2 }
    })
  end)

  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "other" then
      space_popup:set({ background = { image = "space." .. i } })
      space:set({ popup = { drawing = "toggle" } })
    else
      -- Use Aerospace to focus workspace
      sbar.exec("aerospace workspace " .. i)
    end
  end)

  space:subscribe("mouse.exited", function(_)
    space:set({ popup = { drawing = false } })
  end)
end

local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

local spaces_indicator = sbar.add("item", {
  padding_left = -3,
  padding_right = 0,
  icon = {
    padding_left = 8,
    padding_right = 9,
    color = colors.grey,
    string = icons.switch.on,
  },
  label = {
    width = 0,
    padding_left = 0,
    padding_right = 8,
    string = "Spaces",
    color = colors.bg1,
  },
  background = {
    color = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  }
})

-- Update icons when workspace changes or windows move
space_window_observer:subscribe({ "aerospace_workspace_change", "space_windows_change", "front_app_switched" }, function(env)
  update_space_icons()
end)

-- Initial update to hide empty spaces on startup
update_space_icons()
