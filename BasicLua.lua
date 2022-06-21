--==Internal Globals==--
use_DT=false

--==Setup==--
function setup()
--Triggered by Gearswap via get_sets()

--==Macro Set==--
	--windower.send_command:schedule(1,'input /macro set 1;wait 1;input /macro book 1')

--==Lockstyle==--
	--windower.send_command:schedule(5,'input /lockstyleset 1')
	
--==Set Keybinds==--	
	keybindsApply()

--==Reset GearSwap Locks==--
	windower.send_command('gs enable all')
	
--==Default Idle Set==--
	equip(set.idle)
end

--==Key Binds==--
keybinds = {
	{keybind='f12',command='gs c toggledt'}, --Toggle Use of DT Set
}

function get_sets()
--Called once on load. Used to define variables, and specifically “sets”
	
--==Magic Sets==--

	--General Fastcast Set
    sets.fastcast = {
 
    }
	
	sets.SIRD = {
	
	}

	sets.Enmity = {
	
	}
	--Specific Spell Fastcast
--	sets.fastcast['Drain'] = set_combine(sets.fastcast, {
--        feet="Ratri Sollerets +1" -- macc 33
 --   })
	
	--Specific Magic Skill Fastcast
	sets.fastcast['Elemental Magic'] = set_combine(sets.fastcast, { 
      
    })
	
	--Magic Skill: Dark Magic
	sets['Dark Magic'] = {
		
	}
	
	--Specific Spell: Endark
	sets['Endark II'] = set_combine(sets['Dark Magic'], {

    })

    --Specific Spell: Dread Spikes
    sets['Dread Spikes'] = set_combine(sets['Dark Magic'], {
    
    })

    --Drain and Aspir Spells
    sets.Drain_Aspir = set_combine(sets['Dark Magic'], {

    })

    --Absorbs Spells
    sets.Absorb = set_combine(sets['Dark Magic'], {

    })
	
--==Ability Sets==--
	
	sets['Diabolic Eye'] = {}
    sets['Nether Void']  = {}
    sets['Dark Seal']    = {}
    sets['Souleater']    = {}
    sets['Weapn Bash']   = {}
    sets['Blood Weapon'] = {}

--==Weapon Skills==--	
	
	--General Weaponskill Set - Used for all WS that are not defined.
	sets.WS = {

	}
	
	--Specific Weaponskill: Torcleaver
	sets.WS["Torcleaver"] = set_combine(sets.WS, {
	
    })
	
	--Specific Weaponskill: Catastrophe
	sets.WS["Catastrophe"] = set_combine(sets.WS, {

    })
	
	--Idle Set
	sets.idle = {
		
    }
	
	--Idle DT Set
	sets.idle.dt = {
				
    }
	
	--Engaged Set
	sets.engaged = {

	}
	
	--DT Set
	sets.engaged.dt = {

	}
	
	--Run Setup
	setup()
	
end --get_sets

function set_priorities(future,current,key)
    function get_val(piece)
        if piece and type(piece)=='table' and piece[key] and type(piece[key])=='number' then
            return piece[key]
        end
        return 0
    end
    local diff = {}
    for i,v in pairs(future) do
        if type(v) == 'table' then
            future[i].priority = get_val(future[i]) - get_val(current[i])
        else
            future[i] = {name=v,priority=get_val(v) - get_val(current[i])}
        end
    end
end

function precast(action)
--Passes the resources line for the action with a few modifications.
--Occurs immediately before the outgoing action packet is injected.
--cancel_spell(), verify_equip(), force_send(), and cast_delay() are implemented in this phase.
--Does not occur for items that bypass the outgoing text buffer (like using items from the menu).
	
	if action.action_type == 'Magic' then
		if sets.fastcast[action.en] then
			--Spell Specific Fastcast
			equip(sets.fastcast[action.en])
		elseif sets.fastcast[action.skill] then
			--Magic Skill Specific Fastcast
			equip(sets.fastcast[action.skill])
		else
			--General Fastcast
			equip(sets.fastcast)
		end
	elseif action.action_type == 'Ability' then
		if action.prefix == '/weaponskill' then
			if sets.WS[action.en] then
				equip(sets.WS[action.en])
			else
				equip(sets.WS)
			end
		elseif sets[action.en] then
			equip(sets[action.en])	
		end		
	end
    set_priorities(gearswap.equip_list,gearswap.equip_list_history,'hp')
end --precast

function midcast(action)
--Passes the resources line for the action with a few modifications.
--Occurs immediately after the outgoing action packet is injected.
--Does not occur for items that bypass the outgoing text buffer (like using items from the menu).
	
	if action.action_type == 'Magic' then
		if sets[action.en] then
			--Specific Spell
			equip(sets[action.en])
		elseif sets[action.skill] then
			--Magic Skill
			equip(sets[action.skill])
		elseif action.en:startswith("Drain") or action.en:startswith("Aspir") then
			equip(sets.Drain_Aspir)
		elseif action.en:startswith("Absorb") then
			equip(sets.Absorb)

		end
	end
    set_priorities(gearswap.equip_list,gearswap.equip_list_history,'hp')	
end --midcast

function aftercast(action)
--Passes the resources line for the action with a few modifications.
--Occurs when the “result” action packet is received from the server,
--or an interruption of some kind is detected.
	
	status_change(player.status,player.status)
    set_priorities(gearswap.equip_list,gearswap.equip_list_history,'hp')	
end --aftercast

function status_change(new, old)
--Passes the new and old statuses.
	
	if new == 'Engaged' then
		if use_DT then
			equip(sets.engaged.dt)
		else
			equip(sets.engaged)
		end
	else
		if use_DT then
			equip(sets.idle.dt)
		else
			equip(sets.idle)
		end
	end
	set_priorities(gearswap.equip_list,gearswap.equip_list_history,'hp')
end --status_change

function self_command(user_input)
--Passes any self commands, which are triggered by
--//gs c <command> (or /console gs c <command> in macros)
	
	if type(user_input) == 'string' then
		commands = T(user_input:split(' '))
		if commands[1]:lower() == 'toggledt' then
			use_DT = (use_DT == false)
			add_to_chat(55, '>> DT Set = ' .. tostring(use_DT):gsub("^%l", string.upper))
			status_change(player.status,player.status)
		end
	end
	
end --self_command

function file_unload(file_name)
--Called once on file/addon unload. This is passed the new short job name.
	
	keybindsRemove()
	
end --file_unload

function keybindsApply()
	--Sets Keybinds
	for id, keybind in pairs(keybinds) do
		windower.send_command:schedule(2,'bind ' .. keybind.keybind .. ' ' .. keybind.command)
	end
end

function keybindsRemove()
	--Removes Keybinds
	for id, keybind in pairs(keybinds) do
		windower.send_command('unbind ' .. keybind.keybind)
	end
end