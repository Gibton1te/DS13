//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/datum/track
	var/title
	var/track

/datum/track/New(title, track)
	src.title = title
	src.track = track

datum/track/proc/GetTrack()
	if(ispath(track, /music_track))
		var/music_track/music_track = decls_repository.get_decl(track)
		return music_track.song
	return track // Allows admins to continue their adminbus simply by overriding the track var

/obj/machinery/media/jukebox
	name = "mediatronic jukebox"
	desc = "An immense, standalone touchscreen on a swiveling base, equipped with phased array speakers. Embossed on one corner of the ultrathin bezel is the brand name, 'Leitmotif Enterprise Edition'."
	description_info = "Click the jukebox and then select a track on the interface. You can choose to play or stop the track, or set the volume. Use a wrench to attach or detach the jukebox to the floor. The room it is installed in must have power for it to operate!"
	description_fluff = "The Leitmotif is Auraliving's most popular brand of retro jukebox, putting a modern spin on the ancient curved plasmascreen design. The Enterprise Edition allows an indefinite number of users to sync music from their devices simultaneously... of course the Expeditionary Corps made sure to lock down the selection before they installed this one."
	description_antag = "Slide a cryptographic sequencer into the jukebox to overload its speakers. Instead of music, it'll produce a hellish blast of noise and explode!"
	icon = 'icons/obj/jukebox_new.dmi'
	icon_state = "jukebox3-nopower"
	var/state_base = "jukebox3"
	anchored = 1
	density = 1
	power_channel = EQUIP
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	clicksound = 'sound/machines/buttonbeep.ogg'
	pixel_x = -8

	var/active = FALSE
	var/playing = 0
	var/volume = 20

	var/sound_id
	var/datum/sound_token/sound_token

	var/datum/track/current_track
	var/list/datum/track/tracks


/obj/machinery/media/jukebox/old
	name = "space jukebox"
	desc = "A battered and hard-loved jukebox in some forgotten style, carefully restored to some semblance of working condition."
	description_fluff = "No one these days knows what civilization is responsible for this machine's design - various alien species have been credited on more than one occasion."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2-nopower"
	state_base = "jukebox2"
	pixel_x = 0

/obj/machinery/media/jukebox/New(var/atom/location, var/direction, var/nocircuit = FALSE)
	..()
	update_icon()
	sound_id = "[/obj/machinery/media/jukebox]_[sequential_id(/obj/machinery/media/jukebox)]"

/obj/machinery/media/jukebox/Initialize()
	. = ..()
	tracks = setup_music_tracks(tracks)

/obj/machinery/media/jukebox/Destroy()
	StopPlaying()
	QDEL_NULL_LIST(tracks)
	current_track = null
	. = ..()

/obj/machinery/media/jukebox/powered()
	return anchored && ..()

/obj/machinery/media/jukebox/power_change()
	. = ..()
	if(stat & (NOPOWER|BROKEN) && playing)
		StopPlaying()

/obj/machinery/media/jukebox/update_icon()
	overlays.Cut()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		if(stat & BROKEN)
			icon_state = "[state_base]-broken"
		else
			icon_state = "[state_base]-nopower"
		return
	icon_state = state_base
	if(playing)
		if(emagged)
			overlays += "[state_base]-emagged"
		else
			overlays += "[state_base]-running"

/obj/machinery/media/jukebox/interact(mob/user)
	if(!anchored)
		to_chat(usr, "<span class='warning'>You must secure \the [src] first.</span>")
		return

	if(stat & (NOPOWER|BROKEN))
		to_chat(usr, "\The [src] doesn't appear to function.")
		return

	tgui_interact(user)

/obj/machinery/media/jukebox/ui_status(mob/user)
	if(!anchored || inoperable())
		return UI_CLOSE
	return ..()

/obj/machinery/media/jukebox/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "jukebox", "Your Media Library")
		ui.open()

/obj/machinery/media/jukebox/ui_data()
	var/list/data = list()
	data["active"] = active
	data["songs"] = list()
	for(var/datum/track/S in tracks)
		var/list/track_data = list(
			name = S.title
		)
		data["songs"] += list(track_data)
	data["track_selected"] = null
	data["track_length"] = null
	data["track_beat"] = null
	if(current_track)
		data["track_selected"] = current_track.title
	data["volume"] = volume

	return data

/obj/machinery/media/jukebox/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle")
			if(QDELETED(src))
				return
			if(!active)
				if(emagged)
					emag_play()
				else if(!current_track)
					to_chat(usr, "No track selected.")
				else
					StartPlaying()
				active = TRUE
				return TRUE
			else
				active = FALSE
				StopPlaying()
				return TRUE
		if("select_track")
			if(active)
				to_chat(usr, "<span class='warning'>Error: You cannot change the song until the current one is over.</span>")
				return
			var/list/available = list()
			for(var/datum/track/S in tracks)
				available[S.title] = S
			var/selected = params["track"]
			if(QDELETED(src) || !selected || !istype(available[selected], /datum/track))
				return
			current_track = available[selected]
			return TRUE
		if("set_volume")
			var/new_volume = params["volume"]
			if(new_volume  == "reset")
				AdjustVolume(initial(volume))
				return TRUE
			else if(new_volume == "min")
				AdjustVolume(0)
				return TRUE
			else if(new_volume == "max")
				AdjustVolume(100)
				return TRUE
			else if(text2num(new_volume) != null)
				AdjustVolume(text2num(new_volume))
				return TRUE

/obj/machinery/media/jukebox/meddle()
	if (prob(1))
		emag_play()

	else
		current_track = pick(tracks)
		StartPlaying()

/obj/machinery/media/jukebox/proc/emag_play()
	playsound(loc, 'sound/items/AirHorn.ogg', 100, 1)
	for(var/mob/living/carbon/M in ohearers(6, src))
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
		M.sleeping = 0
		M.stuttering += 20
		M.adjust_ear_damage(0, 30)
		M.Weaken(3)
		if(prob(30))
			M.Stun(10)
			M.Paralyse(4)
		else
			M.make_jittery(400)
	spawn(15)
		explode()

/obj/machinery/media/jukebox/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/media/jukebox/attack_hand(var/mob/user as mob)
	interact(user)

/obj/machinery/media/jukebox/proc/explode()
	walk_to(src,0)
	src.visible_message("<span class='danger'>\the [src] blows apart!</span>", 1)

	explosion(4, 2)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	qdel(src)

/obj/machinery/media/jukebox/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		add_fingerprint(user)
		wrench_floor_bolts(user, 0)
		power_change()
		return
	return ..()

/obj/machinery/media/jukebox/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		emagged = 1
		StopPlaying()
		visible_message("<span class='danger'>\The [src] makes a fizzling sound.</span>")
		update_icon()
		return 1

/obj/machinery/media/jukebox/proc/StopPlaying()
	playing = 0
	update_use_power(1)
	update_icon()
	QDEL_NULL(sound_token)


/obj/machinery/media/jukebox/proc/StartPlaying()
	StopPlaying()
	if(!current_track)
		return

	// Jukeboxes cheat massively and actually don't share id. This is only done because it's music rather than ambient noise.
	sound_token = GLOB.sound_player.PlayLoopingSound(src, sound_id, current_track.GetTrack(), volume = volume, range = 7, falloff = 3, prefer_mute = TRUE)

	playing = 1
	update_use_power(2)
	update_icon()

/obj/machinery/media/jukebox/proc/AdjustVolume(new_volume)
	volume = Clamp(new_volume, 0, 100)
	if(sound_token)
		sound_token.SetVolume(volume)
