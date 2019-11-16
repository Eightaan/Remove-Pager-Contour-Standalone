local interaction_set_active_original = UnitNetworkHandler.interaction_set_active
local alarm_pager_interaction_original = UnitNetworkHandler.alarm_pager_interaction


function UnitNetworkHandler:interaction_set_active(unit, u_id, active, tweak_data, flash, sender, ...)
	if self._verify_gamestate(self._gamestate_filter.any_ingame) and self._verify_sender(sender) then
		if tweak_data == "corpse_alarm_pager" then
			if not alive(unit) then
				local u_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
				if not u_data then return end
				unit = u_data and u_data.unit
			end
			
			if not active then
				managers.interaction:pager_ended(unit)
			elseif not flash then
				managers.interaction:pager_answered(unit)
			end
		end
	end

	return interaction_set_active_original(self, unit, u_id, active, tweak_data, flash, sender, ...)
end

function UnitNetworkHandler:alarm_pager_interaction(u_id, tweak_table, status, sender, ...)
	if self._verify_gamestate(self._gamestate_filter.any_ingame) then
		local unit_data = managers.enemy:get_corpse_unit_data_from_id(u_id)
		if unit_data and unit_data.unit:interaction():active() and unit_data.unit:interaction().tweak_data == tweak_table and self._verify_sender(sender) then
			if status == 1 then
				managers.interaction:pager_answered(unit_data.unit)
			else
				managers.interaction:pager_ended(unit_data.unit)
			end
		end
	end

	return alarm_pager_interaction_original(self, u_id, tweak_table, status, sender, ...)
end
