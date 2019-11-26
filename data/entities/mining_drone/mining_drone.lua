local path = util.path("data/units/smg_guy/")
local name = names.drone_name

function gaussian (mean, variance)
  return  math.sqrt(-2 * variance * math.log(math.random())) *
          math.cos(2 * math.pi * math.random()) + mean
end

for k = 1, names.variation_count do

  local base = util.copy(data.raw.character.character)
  --for k, layer in pairs (base.animations[1].idle_with_gun.layers) do
  --  layer.frame_count = 1
  --end

  --util.recursive_hack_runtime_tint(base, false)
  local random_height = gaussian(90, 10) / 100

  util.recursive_hack_scale(base, random_height)

  util.recursive_hack_tint(base, {r = 0.5 * math.random(), g = 0.5 * math.random(), b = 0.5 * math.random(), a = 0.5}, true)

  util.recursive_hack_animation_speed(base.animations[1].mining_with_tool, 1/0.9)

  local attack_range = 16
  local bot =
  {
    type = "unit",
    name = name..k,
    localised_name = {name},
    icon = base.icon,
    icon_size = base.icon_size,
    icons = base.icons,
    flags = {"player-creation", "placeable-off-grid", "hidden"},
    map_color = {b = 0.5, g = 1},
    enemy_map_color = {r = 1},
    max_health = 150,
    radar_range = 1,
    order="i-a",
    --subgroup = "iron-units",
    healing_per_tick = 0.1,
    minable = {result = name, mining_time = 2},
    collision_box = {{-0.10, -0.10}, {0.10, 0.10}},
    collision_mask = util.ground_unit_collision_mask(),
    max_pursue_distance = 64,
    resistances = nil,
    min_persue_time = 60 * 15,
    selection_box = {{-0.3, -1}, {0.3, 0.2}},
    sticker_box = {{-0.3, -1}, {0.2, 0.3}},
    distraction_cooldown = (15),
    move_while_shooting = false,
    can_open_gates = true,
    ai_settings =
    {
      do_separation = false
    },
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "bullet",
      warmup = 19,
      cooldown = 26 - 19,
      range = 0.5,
      --min_attack_distance = 1,
      --projectile_creation_distance = 0.5,
      --lead_target_for_projectile_speed = 1,
      old_sound =
      {
        variations =
        {
          {
            filename = "__core__/sound/axe-mining-ore-1.ogg",
            volume = 0.75
          },
          {
            filename = "__core__/sound/axe-mining-ore-2.ogg",
            volume = 0.75
          },
          {
            filename = "__core__/sound/axe-mining-ore-3.ogg",
            volume = 0.75
          },
          {
            filename = "__core__/sound/axe-mining-ore-4.ogg",
            volume = 0.75
          },
          {
            filename = "__core__/sound/axe-mining-ore-5.ogg",
            volume = 0.75
          }
        },
        aggregation =
        {
          max_count = 2,
          remove = true,
          count_already_playing = true
        }
      },
      ammo_type =
      {
        category = util.ammo_category("mining-drone"),
        target_type = "entity",
        action =
        {
          type = "direct",
          action_delivery =
          {
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "damage",
                  damage = {amount = shared.mining_damage , type = util.damage_type("physical")}
                }
              }
            }
          }
        }
      },
      animation = base.animations[1].mining_with_tool
    },
    vision_distance = 10,
    has_belt_immunity = false,
    affected_by_tiles = true,
    movement_speed = 0.05 * random_height,
    distance_per_frame = 0.05 / random_height,
    pollution_to_join_attack = 1000000,
    corpse = name.."-corpse",
    run_animation = base.animations[1].running,
    rotation_speed = 0.05 / random_height,
    light =
    {
      {
        minimum_darkness = 0.3,
        intensity = 0.4,
        size = 15 * random_height,
        color = {r=1.0, g=1.0, b=1.0}
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "extra-high",
          flags = { "light" },
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0, -7},
        size = 1 * random_height,
        intensity = 0.6,
        color = {r=1.0, g=1.0, b=1.0}
      }
    },
  }

  data:extend{bot}

end


local base = util.copy(data.raw.character.character)

local item = {
  type = "item",
  name = name,
  localised_name = {name},
  icon = base.icon,
  icon_size = base.icon_size,
  flags = {},
  subgroup = "extraction-machine",
  order = "zb"..name,
  stack_size = 20,
  --place_result = name
}

local recipe = {
  type = "recipe",
  name = name,
  localised_name = {name},
  --category = ,
  enabled = true,
  ingredients =
  {
    {"iron-plate", 15},
    {"iron-gear", 10},
    {"iron-rod", 10}
  },
  energy_required = 15,
  result = name
}


local light =
{
  type = "sprite",
  name = "mining-drone-light",
  filename = util.path("data/entities/mining_drone/drone-light-cone.png"),
  priority = "extra-high",
  flags = {"light"},
  width = 200,
  height = 430,
  --shift = {0, -200/32}
}

local corpse = util.copy(data.raw["character-corpse"]["character-corpse"])

util.recursive_hack_tint(corpse, {r = 0.5, g = 0.4, b = 0.3, a = 0.5}, true)
util.recursive_hack_scale(corpse, 0.9)

corpse.name = name.."-corpse"
corpse.selectable_in_game = false
corpse.selection_box = nil
corpse.render_layer = "remnants"

data:extend
{
  item,
  recipe,
  light,
  corpse
}
