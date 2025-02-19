/datum/antagonist/proc/update_leader()
	if(!leader && current_antagonists.len && (flags & ANTAG_HAS_LEADER))
		leader = current_antagonists[1]

/datum/antagonist/proc/update_antag_mob(var/datum/mind/player, var/preserve_appearance)

	// Get the mob.
	if((flags & ANTAG_OVERRIDE_MOB) && (!player.current || (mob_path && !istype(player.current, mob_path))))
		var/mob/holder = player.current
		player.current = new mob_path(get_turf(player.current))
		player.transfer_to(player.current)
		if(holder) qdel(holder)
	player.original = player.current
	if(!preserve_appearance && (flags & ANTAG_SET_APPEARANCE))
		spawn(3)
			var/mob/living/carbon/human/H = player.current
			if(istype(H)) H.change_appearance(APPEARANCE_ALL, H.loc, H, valid_species, state = GLOB.z_state)
	return player.current

/datum/antagonist/proc/update_access(var/mob/living/player)
	for(var/obj/item/weapon/card/id/id in player.contents)
		player.set_id_info(id)

/datum/antagonist/proc/clear_indicators(var/datum/mind/recipient)
	if(!recipient.current || !recipient.current.client)
		return
	for(var/image/I in recipient.current.client.images)
		if(I.icon_state == antag_indicator || (faction_indicator && I.icon_state == faction_indicator))
			qdel(I)

/datum/antagonist/proc/get_indicator(var/datum/mind/recipient, var/datum/mind/other)
	if(!antag_indicator || !other.current || !recipient.current)
		return
	var/indicator = (faction_indicator && (other in faction_members)) ? faction_indicator : antag_indicator
	var/image/I = image('icons/mob/hud.dmi', loc = other.current, icon_state = indicator, layer = LIGHTING_LAYER+0.1)
	if(ishuman(other.current))
		var/mob/living/carbon/human/H = other.current
		I.pixel_x = H.species.antaghud_offset_x
		I.pixel_y = H.species.antaghud_offset_y
	return I

/datum/antagonist/proc/update_all_icons()
	if(!antag_indicator)
		return
	for(var/datum/mind/antag in current_antagonists)
		clear_indicators(antag)
		if(faction_invisible && (antag in faction_members))
			continue
		for(var/datum/mind/other_antag in current_antagonists)
			if(antag.current && antag.current.client)
				antag.current.client.images |= get_indicator(antag, other_antag)

/datum/antagonist/proc/update_icons_added(var/datum/mind/player)
	if(!antag_indicator || !player.current)
		return
	spawn(0)

		var/give_to_player = (!faction_invisible || !(player in faction_members))
		for(var/datum/mind/antag in current_antagonists)
			if(!antag.current)
				continue
			if(antag.current.client)
				antag.current.client.images |= get_indicator(antag, player)
			if(!give_to_player)
				continue
			if(player.current.client)
				player.current.client.images |= get_indicator(player, antag)

/datum/antagonist/proc/update_icons_removed(var/datum/mind/player)
	if(!antag_indicator || !player.current)
		return
	spawn(0)
		clear_indicators(player)
		if(player.current && player.current.client)
			for(var/datum/mind/antag in current_antagonists)
				if(antag.current && antag.current.client)
					for(var/image/I in antag.current.client.images)
						if(I.loc == player.current)
							qdel(I)

/datum/antagonist/proc/update_current_antag_max()
	if (SSticker.current_state <	GAME_STATE_PLAYING)
		cur_max = hard_cap
	else
		cur_max = hard_cap_round


	var/scaling = SSticker.mode.antag_scaling_coeff
	if (!isnull(override_scaling))
		scaling = override_scaling

	if(scaling)

		var/count = 0
		for(var/mob/living/M in GLOB.player_list)
			if(M.client)
				count++

		// Minimum: initial_spawn_target
		// Maximum: hard_cap or hard_cap_round
		cur_max = max(initial_spawn_target,min(round(count/SSticker.mode.antag_scaling_coeff),cur_max))
