local proxy_inventory = function()
  local chest = game.surfaces[1].create_entity{name = shared.proxy_chest_name, position = {1000000, 1000000}, force = "neutral"}
  return chest.get_output_inventory()
end

local taken = {}

local unique_index = function(entity)
  local index = entity.unit_number or entity.surface.index..math.floor(entity.position.x).."-"..math.floor(entity.position.y)
  return index
end

local mining_speed = 0.55
local interval = shared.mining_interval
local damage = shared.mining_damage
local ceil = math.ceil
local max = math.max
local min = math.min

local attack_proxy = function(entity)

  local size = min(ceil((max(entity.get_radius() - 0.1, 0.25)) * 2), 10)

  --Health is set so it will take just enough damage at exactly the right time

  local mining_time = entity.prototype.mineable_properties.mining_time

  local number_of_ticks = (mining_time / mining_speed) * 60
  local number_of_hits = math.ceil(number_of_ticks / interval)

  local proxy = entity.surface.create_entity{name = shared.attack_proxy_name..size, position = entity.position, force = "neutral"}
  proxy.health = number_of_hits * damage
  return proxy
end

local states =
{
  mining_entity = 1
}

local product_amount = util.product_amount

local mining_drone = {}

mining_drone.metatable = {__index = mining_drone}

mining_drone.new = function(entity)
  if entity.name ~= shared.drone_name then error("what are you playing at") end
  local new_drone = {}
  new_drone.entity = entity
  entity.ai_settings.path_resolution_modifier = 1
  new_drone.inventory = proxy_inventory()
  setmetatable(new_drone, mining_drone.metatable)
  return new_drone
end

function mining_drone:process_mining()

  local target = self.mining_target
  if not (target and target.valid) then
    --cancel command or something.
    return self:try_to_mine()
  end

  local mineable_properties = target.prototype.mineable_properties

  --mine it

  for k, product in pairs (mineable_properties.products) do
    local amount = self.inventory.insert({name = product.name, count = product_amount(product)})
    self.entity.surface.create_entity{name = "flying-text", position = self.entity.position, text = product.name..": +"..amount}
  end

  if target.type == "resource" then
    if target.amount > 1 then
      target.amount = target.amount - 1
      return self:mine_entity(target)
    end
  end

  target.destroy()

  return self:try_to_mine()

end

function mining_drone:update(event)
  if event.result ~= defines.behavior_result.success then return end
  if self.state == states.mining_entity then
    self:process_mining()
  end
end

function mining_drone:mine_entity(entity)
  self.mining_target = entity
  self.state = states.mining_entity
  local attack_proxy = attack_proxy(entity)
  local command = {}

  self.entity.set_command
  {
    type = defines.command.attack,
    target = attack_proxy,
    distraction = defines.distraction.by_damage
  }
end

function mining_drone:set_desired_item(item)
  if not game.item_prototypes[item] then error("What you playing at? "..item) end
  self.desired_item = item
end

function mining_drone:find_desired_item()
  local potential = {}
  for k, entity in pairs (self.entity.surface.find_entities_filtered{position = self.entity.position, radius = 32}) do
    if not taken[unique_index(entity)] then
      local properties = entity.prototype.mineable_properties
      if properties.minable then
        for k, product in pairs (properties.products) do
          if product.name == self.desired_item then
            table.insert(potential, entity)
            break
          end
        end
      end
    end
  end
  if not next(potential) then return end
  local closest = self.entity.surface.get_closest(self.entity.position, potential)
  assert(taken[unique_index(closest)] == nil, "wtf pal")
  taken[unique_index(closest)] = true
  return closest
end

function mining_drone:try_to_mine()
  local target = self:find_desired_item()
  if target then
    self:mine_entity(target)
  end
end

function mining_drone:go_to(position)
  self.entity.set_command
  {
    type = defines.command.go_to_location,
    destination = position
  }
end

return mining_drone