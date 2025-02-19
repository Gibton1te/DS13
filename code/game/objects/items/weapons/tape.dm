/obj/item/weapon/tool/tape_roll
	name = "duct tape"
	desc = "A roll of sticky tape. Possibly for taping ducks... or was that ducts?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "taperoll"
	w_class = ITEM_SIZE_SMALL

/obj/item/weapon/tool/tape_roll/attack(var/mob/living/carbon/human/H, var/mob/user)
	if(istype(H))
		if(get_zone_sel(user) == BP_EYES)

			if(!H.organs_by_name[BP_HEAD])
				to_chat(user, "<span class='warning'>\The [H] doesn't have a head.</span>")
				return
			if(!H.has_eyes())
				to_chat(user, "<span class='warning'>\The [H] doesn't have any eyes.</span>")
				return
			if(H.glasses)
				to_chat(user, "<span class='warning'>\The [H] is already wearing somethign on their eyes.</span>")
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				to_chat(user, "<span class='warning'>Remove their [H.head] first.</span>")
				return
			user.visible_message("<span class='danger'>\The [user] begins taping over \the [H]'s eyes!</span>")

			if(!do_mob(user, H, 30))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name[BP_HEAD] || !H.has_eyes() || H.glasses || (H.head && (H.head.body_parts_covered & FACE)))
				return

			playsound(src, 'sound/effects/tape.ogg',25)
			user.visible_message("<span class='danger'>\The [user] has taped up \the [H]'s eyes!</span>")
			H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/blindfold/tape(H), slot_glasses)

		else if(get_zone_sel(user) == BP_MOUTH || get_zone_sel(user) == BP_HEAD)
			if(!H.organs_by_name[BP_HEAD])
				to_chat(user, "<span class='warning'>\The [H] doesn't have a head.</span>")
				return
			if(!H.check_has_mouth())
				to_chat(user, "<span class='warning'>\The [H] doesn't have a mouth.</span>")
				return
			if(H.wear_mask)
				to_chat(user, "<span class='warning'>\The [H] is already wearing a mask.</span>")
				return
			if(H.head && (H.head.body_parts_covered & FACE))
				to_chat(user, "<span class='warning'>Remove their [H.head] first.</span>")
				return
			playsound(src, 'sound/effects/tape.ogg',25)
			user.visible_message("<span class='danger'>\The [user] begins taping up \the [H]'s mouth!</span>")

			if(!do_mob(user, H, 30))
				return

			// Repeat failure checks.
			if(!H || !src || !H.organs_by_name[BP_HEAD] || !H.check_has_mouth() || H.wear_mask || (H.head && (H.head.body_parts_covered & FACE)))
				return
			playsound(src, 'sound/effects/tape.ogg',25)
			user.visible_message("<span class='danger'>\The [user] has taped up \the [H]'s mouth!</span>")
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/muzzle/tape(H), slot_wear_mask)

		else if(get_zone_sel(user) == BP_R_HAND || get_zone_sel(user) == BP_L_HAND)
			playsound(src, 'sound/effects/tape.ogg',25)
			var/obj/item/weapon/handcuffs/cable/tape/T = new(user)
			if(!T.place_handcuffs(H, user))
				qdel(T)

		else if(get_zone_sel(user) == BP_CHEST)
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit/space))
				if(H == user || do_mob(user, H, 10))	//Skip the time-check if patching your own suit, that's handled in attackby()
					playsound(src, 'sound/effects/tape.ogg',25)
					H.wear_suit.attackby(src, user)
			else
				to_chat(user, "<span class='warning'>\The [H] isn't wearing a spacesuit for you to reseal.</span>")

		else
			return ..()
		return 1

/obj/item/weapon/tool/tape_roll/proc/stick(var/obj/item/weapon/W, mob/user)
	if(!istype(W, /obj/item/weapon/paper) || !user.unEquip(W))
		return
	var/obj/item/weapon/ducttape/tape = new(get_turf(src))
	tape.attach(W)
	user.put_in_hands(tape)

/obj/item/weapon/ducttape
	name = "piece of tape"
	desc = "A piece of sticky tape."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "tape"
	w_class = ITEM_SIZE_TINY
	layer = ABOVE_OBJ_LAYER

	var/obj/item/weapon/stuck = null

/obj/item/weapon/ducttape/attack_hand(var/mob/user)
	anchored = FALSE // Unattach it from whereever it's on, if anything.
	return ..()

/obj/item/weapon/ducttape/Initialize()
	. = ..()
	item_flags |= ITEM_FLAG_NO_BLUDGEON

/obj/item/weapon/ducttape/examine(mob/user)
	return stuck ? stuck.examine(user) : ..()

/obj/item/weapon/ducttape/proc/attach(var/obj/item/weapon/W)
	stuck = W
	anchored = TRUE
	W.forceMove(src)
	icon_state = W.icon_state + "_taped"
	name = W.name + " (taped)"
	overlays = W.overlays

/obj/item/weapon/ducttape/attack_self(mob/user)
	if(!stuck)
		return

	to_chat(user, "You remove \the [initial(name)] from [stuck].")
	stuck.forceMove(get_turf(src))
	user.put_in_hands(stuck)
	stuck = null
	overlays = null
	qdel(src)

/obj/item/weapon/ducttape/afterattack(var/A, mob/user, flag, params)

	if(!in_range(user, A) || istype(A, /obj/machinery/door) || !stuck)
		return

	var/turf/target_turf = get_turf(A)
	var/turf/source_turf = get_turf(user)

	var/dir_offset = 0
	if(target_turf != source_turf)
		dir_offset = get_dir(source_turf, target_turf)
		if(!(dir_offset in GLOB.cardinal))
			to_chat(user, "You cannot reach that from here.")// can only place stuck papers in cardinal directions, to
			return											// reduce papers around corners issue.

	if(!user.unEquip(src, source_turf))
		return
	playsound(src, 'sound/effects/tape.ogg',25)

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			pixel_x = text2num(mouse_control["icon-x"]) - 16
			if(dir_offset & EAST)
				pixel_x += 32
			else if(dir_offset & WEST)
				pixel_x -= 32
		if(mouse_control["icon-y"])
			pixel_y = text2num(mouse_control["icon-y"]) - 16
			if(dir_offset & NORTH)
				pixel_y += 32
			else if(dir_offset & SOUTH)
				pixel_y -= 32
