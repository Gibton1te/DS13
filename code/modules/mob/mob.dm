/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	STOP_PROCESSING(SSmobs, src)
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.living_mob_list -= src
	unset_machine()
	QDEL_NULL(hud_used)
	if(istype(skillset))
		QDEL_NULL(skillset)
	for(var/obj/item/grab/G in grabbed_by)
		qdel(G)
	clear_fullscreen()
	if(client)
		for(var/atom/movable/AM in client.screen)
			var/atom/movable/screen/screenobj = AM
			if(!istype(screenobj) || !screenobj.globalscreen)
				qdel(screenobj)
		client.screen = list()
	if(mind && mind.current == src)
		spellremove(src)
	ghostize()
	..()
	return QDEL_HINT_HARDDEL

/mob/Initialize()
	GLOB.mob_list += src
	. = ..()
	skillset = new skillset(src)
	if(!move_intent)
		move_intent = move_intents[1]
	if(ispath(move_intent))
		move_intent = decls_repository.get_decl(move_intent)
	START_PROCESSING(SSmobs, src)
	update_verbs()

	//Call Entered on the area we're created in
	var/area/A = get_area(src)
	if (A)
		A.Entered(src)

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(!client)	return

	//spaghetti code
	if(type)
		if((type & VISIBLE_MESSAGE) && is_blind())//Vision related
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
		if((type & AUDIBLE_MESSAGE) && is_deaf())//Hearing related
			if(!alt)
				return
			else
				msg = alt
				type = alt_type
				if(((type & VISIBLE_MESSAGE) && is_blind()))
					return

	to_chat(src, msg)


// Show a message to all mobs and objects in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/mob/visible_message(var/message, var/self_message, var/blind_message, var/range = world.view, var/checkghosts = null, var/narrate = FALSE)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T,range, mobs, objs, checkghosts)

	for(var/o in objs)
		var/obj/O = o
		O.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)

	for(var/m in mobs)
		var/mob/M = m
		var/mob_message = message

		if(isghost(M))
			if(ghost_skip_message(M))
				continue
			mob_message = add_ghost_track(mob_message, M)

		if(self_message && M == src)
			M.show_message(self_message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(!is_invisible_to(M) || narrate)
			M.show_message(mob_message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
			continue

		if(blind_message)
			M.show_message(blind_message, AUDIBLE_MESSAGE)
			continue
	//Multiz, have shadow do same
	if(bound_overlay)
		bound_overlay.visible_message(message, blind_message, range, checkghosts)

// Show a message to all mobs and objects in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/mob/audible_message(var/message, var/self_message, var/deaf_message, var/hearing_distance = world.view, var/checkghosts = null, var/narrate = FALSE)
	var/turf/T = get_turf(src)
	var/list/mobs = list()
	var/list/objs = list()
	get_mobs_and_objs_in_view_fast(T, hearing_distance, mobs, objs, checkghosts)

	for(var/m in mobs)
		var/mob/M = m
		var/mob_message = message

		if(isghost(M))
			if(ghost_skip_message(M))
				continue
			mob_message = add_ghost_track(mob_message, M)

		if(self_message && M == src)
			M.show_message(self_message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else if(M.see_invisible >= invisibility || narrate) // Cannot view the invisible
			M.show_message(mob_message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		else
			M.show_message(mob_message, AUDIBLE_MESSAGE)

	for(var/o in objs)
		var/obj/O = o
		O.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)

/mob/proc/add_ghost_track(var/message, var/mob/dead/observer/ghost/M)
	ASSERT(istype(M))

	var/remote = ""
	if(M.get_preference_value(/datum/client_preference/ghost_sight) == GLOB.PREF_ALL_EMOTES && !(src in view(M)))
		remote = "\[R\]"

	var/speaker_name = ""

	if(real_name)
		if(name != real_name && name != "Unknown (as [real_name])")
			speaker_name = "<span class='warning'>([real_name])</span> "

	var/track = "([ghost_follow_link(src, M)])"

	message = track + remote + " " + speaker_name  + message
	return message

/mob/proc/ghost_skip_message(var/mob/dead/observer/ghost/M)
	ASSERT(istype(M))
	if(M.get_preference_value(/datum/client_preference/ghost_sight) == GLOB.PREF_ALL_EMOTES && !(src in view(M)))
		if(!client)
			return TRUE
	return FALSE

// Returns an amount of power drawn from the object (-1 if it's not viable).
// If drain_check is set it will not actually drain power, just return a value.
// If surge is set, it will destroy/damage the recipient and not return any power.
// Not sure where to define this, so it can sit here for the rest of time.
/atom/proc/drain_power(var/drain_check,var/surge, var/amount = 0)
	return -1

/mob/proc/findname(msg)
	for(var/mob/M in SSmobs.mob_list)
		if (M.real_name == msg)
			return M
	return 0

/mob/proc/movement_delay()
	. = 0
	if(istype(loc, /turf))
		var/turf/T = loc
		. += T.movement_delay

	if ((drowsyness > 0) && !MOVING_DELIBERATELY(src))
		. += 6

	. += move_intent.move_delay
	. += encumbrance() * (0.5 + 1.5 * (SKILL_MAX - get_skill_value(SKILL_HAULING))/(SKILL_MAX - SKILL_MIN)) //Varies between 0.5 and 2, depending on skill

//How much the stuff the mob is pulling contributes to its movement delay.
/mob/proc/encumbrance()
	. = 0
	if(pulling && update_pulling())
		if(istype(pulling, /obj))
			var/obj/O = pulling
			. += between(0, O.w_class, ITEM_SIZE_GARGANTUAN) / 5
		else if(istype(pulling, /mob))
			var/mob/M = pulling
			. += max(0, M.mob_size) / MOB_MEDIUM
		else
			. += 1
	. *= (0.8 ** size_strength_mod())

//Determines mob size/strength effects for slowdown purposes. Standard is 0; can be pos/neg.
/mob/proc/size_strength_mod()
	return log(2, mob_size / MOB_MEDIUM)

/mob/proc/Life()
//	if(organStructure)
//		organStructure.ProcessOrgans()
	return

#define UNBUCKLED 0
#define PARTIALLY_BUCKLED 1
#define FULLY_BUCKLED 2
/mob/proc/buckled()
	// Preliminary work for a future buckle rewrite,
	// where one might be fully restrained (like an elecrical chair), or merely secured (shuttle chair, keeping you safe but not otherwise restrained from acting)
	if(!buckled)
		return UNBUCKLED
	return restrained() ? FULLY_BUCKLED : PARTIALLY_BUCKLED

/mob/proc/is_blind()
	return ((sdisabilities & BLIND) || blinded || incapacitated(INCAPACITATION_KNOCKOUT))

/mob/proc/is_deaf()
	return ((sdisabilities & DEAF) || ear_deaf || incapacitated(INCAPACITATION_KNOCKOUT))

/mob/proc/is_physically_disabled()
	return incapacitated(INCAPACITATION_DISABLED)

/mob/proc/cannot_stand()
	return incapacitated(INCAPACITATION_KNOCKDOWN)

/mob/proc/incapacitated(var/incapacitation_flags = INCAPACITATION_DEFAULT)
	if ((incapacitation_flags & INCAPACITATION_STUNNED) && stunned)
		return 1

	if ((incapacitation_flags & INCAPACITATION_FORCELYING) && (weakened || resting || pinned.len))
		return 1

	if ((incapacitation_flags & INCAPACITATION_KNOCKOUT) && (stat || paralysis || sleeping || (status_flags & FAKEDEATH)))
		return 1

	if((incapacitation_flags & INCAPACITATION_RESTRAINED) && restrained())
		return 1

	if((incapacitation_flags & (INCAPACITATION_BUCKLED_PARTIALLY|INCAPACITATION_BUCKLED_FULLY)))
		var/buckling = buckled()
		if(buckling >= PARTIALLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_PARTIALLY))
			return 1
		if(buckling == FULLY_BUCKLED && (incapacitation_flags & INCAPACITATION_BUCKLED_FULLY))
			return 1

	return 0

#undef UNBUCKLED
#undef PARTIALLY_BUCKLED
#undef FULLY_BUCKLED

/mob/proc/restrained()
	return

/mob/proc/reset_view(atom/A)
	if (!lock_view && client)
		A = A ? A : eyeobj
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc

		if (ismob(client.eye))
			var/mob/M = client.eye
			visualnet_range = M.view_range
			var/view_changed = FALSE
			if (client.change_view(M.view_range))
				view_changed = TRUE
			if (client.set_view_offset(M.get_visual_dir(), M.view_offset))
				view_changed = TRUE

			if (view_changed)
				GLOB.view_changed_event.raise_event(src)


/mob/proc/show_inv(mob/user as mob)
	return

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	if((is_blind(src) || usr.stat) && !isobserver(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return 1

	face_atom(A, TRUE)
	A.examine(src)

/mob/verb/pointed(atom/A as mob|obj|turf in view())
	set name = "Point To"
	set category = "Object"

	if(!src || !isturf(src.loc) || !(A in view(src.loc)))
		return 0
	if(istype(A, /obj/effect/decal/point))
		return 0

	var/tile = get_turf(A)
	if (!tile)
		return 0

	var/obj/P = new /obj/effect/decal/point(tile)
	P.set_invisibility(invisibility)
	spawn (20)
		if(P)
			qdel(P)	// qdel

	face_atom(A, TRUE)
	return 1

//Gets the mob grab conga line.
/mob/proc/ret_grab(list/L)
	if (!istype(l_hand, /obj/item/grab) && !istype(r_hand, /obj/item/grab))
		return L
	if (!L)
		L = list(src)
	for(var/A in list(l_hand,r_hand))
		if (istype(A, /obj/item/grab))
			var/obj/item/grab/G = A
			if (!(G.affecting in L))
				L += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L)
	return L

/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(istype(loc,/obj/mecha)) return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand()
	return

/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")
/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")
/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if (sane)
		msg = sanitize(msg)

	if (length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if (popup)
		memory()

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		to_chat(usr, "No.")
	var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null, extra = 0)

	if(msg != null)
		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		to_chat(src, "<h2 class='alert'>OOC Warning:</h2>")
		to_chat(src, "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>")

/mob/proc/print_flavor_text()
	if (flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(length(msg) <= 40)
			return "<span class='notice'>[msg]</span>"
		else
			return "<span class='notice'>[copytext_preserve_html(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a></span>"

/*
/mob/verb/help()
	set name = "Help"
	src << browse('html/help.html', "window=help")
	return
*/

/mob/dead/new_player/verb/observe()
	set name = "Observe"
	set category = "OOC"

	if(!(initialization_stage&INITIALIZATION_COMPLETE))
		to_chat(src, "<span class='warning'>Please wait for server initialization to complete...</span>")
		return

	var/is_admin = 0

	if(client.holder && (client.holder.rights & R_ADMIN))
		is_admin = 1

	if(is_admin && stat == DEAD)
		is_admin = 0

	var/list/names = list()
	var/list/namecounts = list()
	var/list/creatures = list()

	for(var/obj/O in world)				//EWWWWWWWWWWWWWWWWWWWWWWWW ~needs to be optimised
		if(!O.loc)
			continue
		if(istype(O, /obj/item/weapon/disk/nuclear))
			var/name = "Nuclear Disk"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

		if(istype(O, /obj/singularity))
			var/name = "Singularity"
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			creatures[name] = O

	for(var/mob/M in sortAtom(SSmobs.mob_list))
		var/name = M.name
		if (names.Find(name))
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1

		creatures[name] = M


	client.perspective = EYE_PERSPECTIVE

	var/eye_name = null

	var/ok = "[is_admin ? "Admin Observe" : "Observe"]"
	eye_name = input("Please, select a player!", ok, null, null) as null|anything in creatures

	if (!eye_name)
		return

	var/mob/mob_eye = creatures[eye_name]

	if(client && mob_eye)
		client.eye = mob_eye
		if (is_admin)
			client.adminobs = 1
			if(mob_eye == client.mob || client.eye == client.mob)
				client.adminobs = 0

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	unset_machine()
	reset_view(null)




//Is this mob allowed to jump to links?
/mob/proc/can_jump_to_link()
	return FALSE

/mob/proc/pull_damage()
	return 0

/mob/living/carbon/human/pull_damage()
	if(!lying || getBruteLoss() + getFireLoss() < 100)
		return 0
	for(var/thing in organs)
		var/obj/item/organ/external/e = thing
		if(!e || e.is_stump())
			continue
		if((e.status & ORGAN_BROKEN) && !e.splinted)
			return 1
		if(e.status & ORGAN_BLEEDING)
			return 1
	return 0

/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(istype(M,/mob/living/silicon/ai)) return
	show_inv(usr)




/mob/proc/can_use_hands()
	return

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/is_dead()
	return stat == DEAD

/mob/proc/is_mechanical()
	if(mind && (mind.assigned_role == "Robot" || mind.assigned_role == "AI"))
		return 1
	return istype(src, /mob/living/silicon) || get_species() == SPECIES_IPC

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/get_gender()
	return gender

/mob/proc/see(message)
	if(!is_active())
		return 0
	to_chat(src, message)
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)



// Not sure what to call this. Used to check if humans are wearing an AI-controlled exosuit and hence don't need to fall over yet.
/mob/proc/can_stand_overridden()
	return 0

//Updates lying and icons
/mob/proc/update_lying_buckled_and_verb_status()
	if(!resting && cannot_stand() && can_stand_overridden())
		lying = 0
	else if(buckled)
		anchored = 1
		if(istype(buckled))
			set_moving_slowly()
			if(buckled.buckle_lying == -1)
				lying = incapacitated(INCAPACITATION_KNOCKDOWN)
			else
				lying = buckled.buckle_lying
			if(buckled.buckle_movable)
				anchored = 0
	else
		lying = incapacitated(INCAPACITATION_KNOCKDOWN)

	if(lying)
		set_moving_slowly()
		set_density(density_lying())
		if (incapacitated(INCAPACITATION_KNOCKOUT))
			if(l_hand) unEquip(l_hand)
			if(r_hand) unEquip(r_hand)
	else
		set_density(initial(density))
	reset_layer()

	for(var/obj/item/grab/G in grabbed_by)
		if(G.force_stand())
			lying = 0

	//Temporarily moved here from the various life() procs
	//I'm fixing stuff incrementally so this will likely find a better home.
	//It just makes sense for now. ~Carn
	if( update_icon )	//forces a full overlay update
		update_icon = 0
		regenerate_icons()


	else if( lying != lying_prev )
		update_icons()

//Overridden by humans in human.dm
/mob/proc/density_lying()
	return 0






/mob/verb/eastface()
	set hidden = 1
	return facedir(client.client_dir(EAST))


/mob/verb/westface()
	set hidden = 1
	return facedir(client.client_dir(WEST))


/mob/verb/northface()
	set hidden = 1
	return facedir(client.client_dir(NORTH))


/mob/verb/southface()
	set hidden = 1
	return facedir(client.client_dir(SOUTH))


//This might need a rename but it should replace the can this mob use things check
/mob/proc/is_advanced_tool_user()
	return 0


//Like stun, but doesn't set the stun var. Just sets move and click cooldowns
/mob/proc/disable(stoptime)
	set_move_cooldown(stoptime)
	set_click_cooldown(stoptime)

/mob/proc/enable()
	reset_move_cooldown()
	reset_click_cooldown()

/mob/proc/Stun(amount)
	if(status_flags & CANSTUN)
		facing_dir = null
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun

		update_lying_buckled_and_verb_status()
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount,0)
		update_lying_buckled_and_verb_status()
	return

/mob/proc/AdjustStunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
		update_lying_buckled_and_verb_status()
	return

/mob/proc/Weaken(amount)
	if(status_flags & CANWEAKEN)
		facing_dir = null
		weakened = max(max(weakened,amount),0)
		update_lying_buckled_and_verb_status()
	return

/mob/proc/SetWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(amount,0)
		update_lying_buckled_and_verb_status()
	return

/mob/proc/AdjustWeakened(amount)
	if(status_flags & CANWEAKEN)
		weakened = max(weakened + amount,0)
		update_lying_buckled_and_verb_status()
	return

/mob/proc/Paralyse(amount)
	if(status_flags & CANPARALYSE)
		facing_dir = null
		paralysis = max(max(paralysis,amount),0)
		return TRUE
	return FALSE

/mob/living/Paralyse(amount)
	var/zero_before = FALSE
	if (!paralysis)
		zero_before = TRUE
	.=..()
	if (. && zero_before)
		//These three procs instantly create the blinding/sleep overlay
		//We only call them if the mob has just become paralysed, to prevent an infinite loop
		handle_regular_status_updates() //This checks paralysis and sets stat
		handle_disabilities() //This checks stat and sets eye_blind
		handle_regular_hud_updates(TRUE) //This checks eye_blind and adds or removes the hud overlay


/mob/proc/SetParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(amount,0)
	return

/mob/proc/AdjustParalysis(amount)
	if(status_flags & CANPARALYSE)
		paralysis = max(paralysis + amount,0)
	return

/mob/proc/Sleeping(amount)
	facing_dir = null
	sleeping = max(max(sleeping,amount),0)
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	return

/mob/proc/Resting(amount)
	facing_dir = null
	resting = max(max(resting,amount),0)
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	return



/mob/proc/get_visible_implants(var/class = 0, include_shrapnel = FALSE)
	var/list/visible_implants = list()
	for(var/obj/item/O in embedded)
		if(O.w_class > class)
			visible_implants += O
	return visible_implants

/mob/proc/embedded_needs_process()
	return (embedded.len > 0)

/mob/proc/yank_out_object_verb()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!isliving(usr) || !usr.canClick())
		return
	usr.set_click_cooldown(20)

	if(usr.stat == 1)
		to_chat(usr, "You are unconcious and cannot do that!")
		return

	if(usr.restrained())
		to_chat(usr, "You are restrained and cannot do that!")
		return

	var/mob/S = src
	var/mob/user = usr
	var/list/valid_objects = list()
	var/self = FALSE

	if(S == user)
		self = TRUE // Removing object from yourself.

	valid_objects = get_visible_implants(0, TRUE)
	if(!valid_objects.len)
		if(self)
			to_chat(src, "You have nothing stuck in your body that is large enough to remove.")
		else
			to_chat(user, "[src] has nothing stuck in their wounds that is large enough to remove.")
		return

	var/obj/item/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects

	yank_out_object(selection, user)



/mob/proc/yank_out_object(obj/item/selection, mob/user)
	var/mob/S = src
	if(user == S)
		to_chat(src, "<span class='warning'>You attempt to get a good grip on [selection] in your body.</span>")
	else
		to_chat(user, "<span class='warning'>You attempt to get a good grip on [selection] in [S]'s body.</span>")
	if(!do_mob(user, S, 30, incapacitation_flags = INCAPACITATION_DEFAULT & (~INCAPACITATION_FORCELYING), needhand = 2)) //let people pinned to stuff yank it out, otherwise they're stuck... forever!!!
		return
	if(!selection || !S || !user)
		return



	playsound(src, "fleshtear", VOLUME_MID, TRUE)

	shake_animation()

	var/message
	if(user == S)
		message = "<span class='warning'><b>[src] rips [selection] out of their body.</b></span>"
	else
		message = "<span class='warning'><b>[usr] rips [selection] out of [src]'s body.</b></span>"


	var/mob/living/carbon/human/H
	if(ishuman(src))
		H = src
		var/obj/item/organ/external/affected

		for(var/obj/item/organ/external/organ in H.organs) //Grab the organ holding the implant.
			if(selection in organ.implants)
				affected = organ

		for(var/datum/wound/wound in affected.wounds)
			wound.embedded_objects -= selection

		H.shock_stage+=15
		affected.take_external_damage((selection.w_class * 2.5), 0, DAM_EDGE, "Embedded object extraction", allow_dismemberment = FALSE)

		if(prob(selection.w_class * 5) && affected.sever_artery()) //I'M SO ANEMIC I COULD JUST -DIE-.
			H.custom_pain("Something tears wetly in your [affected] as [selection] is pulled free!", 50, affecting = affected)

		if (ishuman(user))
			var/mob/living/carbon/human/human_user = user
			human_user.bloody_hands(H)

	else if(issilicon(src))
		var/mob/living/silicon/robot/R = src
		R.embedded -= selection
		R.adjustBruteLoss(5)
		R.adjustFireLoss(10)

	if (H)
		H.unembed(selection, null, FALSE, message)

	var/list/valid_objects = get_visible_implants(0, TRUE)
	if(length(valid_objects.len == 0)) //Yanking out last object - removing verb.
		remove_verb(src, /mob/proc/yank_out_object_verb)

	user.put_in_hands(selection)

	for(var/obj/item/weapon/O in pinned)
		if(O == selection)
			pinned -= O
		if(!pinned.len)
			anchored = 0
	return 1

//Check for brain worms in head.
/mob/proc/has_brain_worms()

	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			return I

	return 0

// A mob should either use update_icon(), overriding this definition, or use update_icons(), not touching update_icon().
// It should not use both.
/mob/update_icon()
	return update_icons()

/mob/verb/face_direction()

	set name = "Face Direction"
	set category = "IC"
	set src = usr

	set_face_dir()

	if(!facing_dir)
		to_chat(usr, "You are now not facing anything.")
	else
		to_chat(usr, "You are now facing [dir2text(facing_dir)].")

/mob/proc/set_face_dir(var/newdir)
	if(!isnull(facing_dir) && newdir == facing_dir)
		facing_dir = null
	else if(newdir)
		set_dir(newdir)
		facing_dir = newdir
	else if(facing_dir)
		facing_dir = null
	else
		facedir(dir)
		facing_dir = dir



/mob/proc/set_stat(var/new_stat)
	. = stat != new_stat
	stat = new_stat

/mob/verb/northfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(NORTH))

/mob/verb/southfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(SOUTH))

/mob/verb/eastfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(EAST))

/mob/verb/westfaceperm()
	set hidden = 1
	set_face_dir(client.client_dir(WEST))

/mob/proc/adjust_ear_damage()
	return

/mob/proc/setEarDamage()
	return

//Throwing stuff

/mob/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(src.hud_used.throw_icon) //in case we don't have the HUD and we use the hotkey
		src.hud_used.throw_icon.icon_state = "act_throw_off"

/mob/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(src.hud_used.throw_icon)
		src.hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/toggle_antag_pool()
	set name = "Toggle Add-Antag Candidacy"
	set desc = "Toggles whether or not you will be considered a candidate by an add-antag vote."
	set category = "OOC"
	if (!mind || !client || !client.prefs)
		return
	if(client.prefs.ghost_candidacy)
		to_chat(usr, "You have left the antag pool.")
		client.prefs.ghost_candidacy = FALSE
		client.prefs.save_preferences()
	else
		to_chat(usr, "You have joined the antag pool. Make sure you have the needed role set to high!")
		client.prefs.ghost_candidacy = TRUE
		client.prefs.save_preferences()

/mob/proc/is_invisible_to(var/mob/viewer)
	return (!alpha || !mouse_opacity || viewer.see_invisible < invisibility)

/client/proc/check_has_body_select()
	return mob && mob.hud_used && istype(mob.hud_used.zone_sel, /atom/movable/screen/zone_sel)

/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = 1
	toggle_zone_sel(list(BP_HEAD,BP_EYES,BP_MOUTH))

/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = 1
	toggle_zone_sel(list(BP_R_ARM,BP_R_HAND))

/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = 1
	toggle_zone_sel(list(BP_L_ARM,BP_L_HAND))

/client/verb/body_chest()
	set name = "body-chest"
	set hidden = 1
	toggle_zone_sel(list(BP_CHEST))

/client/verb/body_groin()
	set name = "body-groin"
	set hidden = 1
	toggle_zone_sel(list(BP_GROIN,BP_TAIL))

/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = 1
	toggle_zone_sel(list(BP_R_LEG,BP_R_FOOT))

/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = 1
	toggle_zone_sel(list(BP_L_LEG,BP_L_FOOT))

/client/proc/toggle_zone_sel(list/zones)
	if(!check_has_body_select())
		return
	var/atom/movable/screen/zone_sel/selector = mob.hud_used.zone_sel
	selector.set_zone_sel(next_in_list(mob.hud_used.zone_sel.selecting,zones))

/mob/proc/has_chem_effect(chem, threshold)
	return FALSE

/*
	Simple generic proc to simplify verb adding/removal logic.
	Always call parent in overrides!
*/
/mob/proc/update_verbs()
	return

/// Adds this list to the output to the stat browser
/mob/proc/get_status_tab_items()
	. = list()

/mob/GenerateTag()
	tag = "mob_[next_mob_id++]"

///Get the item on the mob in the storage slot identified by the id passed in
/mob/proc/get_item_by_slot(slot_id)
	return null
