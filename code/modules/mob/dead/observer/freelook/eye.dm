// EYE
//
// A mob that another mob controls to look around the station with.
// It streams chunks as it moves around, which will show it what the controller can and cannot see.

/mob/dead/observer/eye
	name = "Eye"
	var/name_sufix = "Eye"
	icon = 'icons/mob/eye.dmi'
	icon_state = "default-eye"

	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 1
	var/owner_follows_eye = 0

	invisibility = INVISIBILITY_EYE

	ghost_image_flag = GHOST_IMAGE_ALL
	var/mob/owner = null
	var/list/visibleChunks = list()

	var/datum/visualnet/visualnet

/mob/dead/observer/eye/Destroy()
	release(owner)
	owner = null
	visualnet = null
	. = ..()

/mob/dead/observer/eye/Move(n, direct)
	if(owner == src)
		return EyeMove(direct)
	return 0

/mob/dead/observer/eye/facedir(var/ndir)
	if(!canface())
		return 0
	set_dir(ndir)
	return 1


/mob/dead/observer/eye/pointed()
	set popup_menu = 0
	set src = usr.contents
	return 0

/mob/dead/observer/eye/examine(mob/user)
	return

/mob/dead/observer/eye/proc/possess(var/mob/user)
	if(owner && owner != user)
		return
	if(owner && owner.eyeobj != src)
		return
	owner = user
	owner.set_eyeobj(src)
	SetName("[owner.name] ([name_sufix])") // Update its name
	if(owner.client)
		owner.client.eye = src
		owner.update_vision_range()
	setLoc(owner)
	if (visualnet)
		visualnet.update_eye_chunks(src, TRUE)



/mob/dead/observer/eye/proc/release(var/mob/user)
	if(owner != user || !user)
		return
	if(owner.eyeobj != src)
		return
	if (visualnet)
		visualnet.remove_eye(src)
	owner.eyeobj = null
	owner.update_vision_range()
	owner = null
	SetName(initial(name))

// Use this when setting the eye's location.
// It will also stream the chunk that the new loc is in.
/mob/dead/observer/eye/proc/setLoc(var/T)
	if(!owner)
		return FALSE

	T = get_turf(T)
	if(!T || T == loc)
		return FALSE

	forceMove(T)

	if(owner.client)
		owner.client.eye = src
	if(owner_follows_eye)
		owner.forceMove(loc)

	if (visualnet)
		visualnet.update_eye_chunks(src)
	return TRUE

/mob/dead/observer/eye/proc/getLoc()
	if(owner)
		if(!isturf(owner.loc) || !owner.client)
			return
		return loc

/mob
	var/mob/dead/observer/eye/eyeobj

/mob/proc/EyeMove(n, direct)
	if(!eyeobj)
		return

	return eyeobj.EyeMove(n, direct)

/mob/dead/observer/eye/EyeMove(direct)
	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.time)
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(src, direct))
		if(step)
			setLoc(step)

	cooldown = world.time + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial
	return 1
