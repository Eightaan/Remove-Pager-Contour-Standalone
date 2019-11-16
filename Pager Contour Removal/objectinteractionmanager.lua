local init_original = ObjectInteractionManager.init
local update_original = ObjectInteractionManager.update
local add_unit_original = ObjectInteractionManager.add_unit
local remove_unit_original = ObjectInteractionManager.remove_unit
local interact_original = ObjectInteractionManager.interact
local interupt_action_interact_original = ObjectInteractionManager.interupt_action_interact

function ObjectInteractionManager:init(...)
	init_original(self, ...)	
	self._queued_units = {}
	self._active_pagers = {}
end

function ObjectInteractionManager:update(t, ...)
	update_original(self, t, ...)
	self:_check_queued_units(t)
end

function ObjectInteractionManager:add_unit(unit, ...)
	table.insert(self._queued_units, unit)
	return add_unit_original(self, unit, ...)
end

function ObjectInteractionManager:remove_unit(unit, ...)
	self:_check_remove_unit(unit)
	return remove_unit_original(self, unit, ...)
end

function ObjectInteractionManager:interact(...)
	if alive(self._active_unit) and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
		self:pager_answered(self._active_unit)
	end	
	return interact_original(self, ...)
end

function ObjectInteractionManager:interupt_action_interact(...)
	if alive(self._active_unit) and self._active_unit:interaction() and self._active_unit:interaction().tweak_data == "corpse_alarm_pager" then
		self:pager_ended(self._active_unit)
	end
	return interupt_action_interact_original(self, ...)
end

function ObjectInteractionManager:_check_queued_units(t)
	for i, unit in ipairs(self._queued_units) do
		if alive(unit) then			
			local interaction_id = unit:interaction().tweak_data
			
			if interaction_id == "corpse_alarm_pager" then
				self:_pager_started(unit)
			end
		end
	end
	self._queued_units = {}
end

function ObjectInteractionManager:_check_remove_unit(unit)
	local interaction_id = unit:interaction().tweak_data
	if interaction_id == "corpse_alarm_pager" then
		self:pager_ended(unit)
	end
end

function ObjectInteractionManager:pager_ended(unit)
	if self._active_pagers[unit:key()] then
		self._active_pagers[unit:key()] = nil
	end
end

function ObjectInteractionManager:_pager_started(unit)
	if not self._active_pagers[unit:key()] then
		self._active_pagers[unit:key()] = true
	end
end

function ObjectInteractionManager:pager_answered(unit)
	if self._active_pagers[unit:key()] then
		if self._active_pagers[unit:key()] then
			managers.enemy:add_delayed_clbk("contour_remove_" .. tostring(unit:key()), callback(self, self, "_remove_pager_contour", unit), Application:time() + 0.01)
		end
	end
end

function ObjectInteractionManager:_remove_pager_contour(unit)
	if alive(unit) then
		unit:contour():remove(tweak_data.interaction.corpse_alarm_pager.contour_preset)
	end
end