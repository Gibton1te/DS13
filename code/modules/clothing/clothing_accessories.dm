/obj/item/clothing/proc/can_attach_accessory(obj/item/clothing/accessory/A)
	if(valid_accessory_slots && istype(A) && (A.slot in valid_accessory_slots))
		.=1
	else
		return 0
	if(accessories.len && restricted_accessory_slots && (A.slot in restricted_accessory_slots))
		for(var/obj/item/clothing/accessory/AC in accessories)
			if (AC.slot == A.slot)
				return 0

/obj/item/clothing/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/clothing/accessory))

		if(!valid_accessory_slots || !valid_accessory_slots.len)
			to_chat(usr, "<span class='warning'>You cannot attach accessories of any kind to \the [src].</span>")
			return

		var/obj/item/clothing/accessory/A = I
		if(can_attach_accessory(A))
			if(!user.unEquip(A))
				return
			attach_accessory(user, A)
			return
		else
			to_chat(user, "<span class='warning'>You cannot attach more accessories of this type to [src].</span>")
		return

	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attackby(I, user)
		return

	..()

/obj/item/clothing/attack_hand(var/mob/user)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(accessories.len && src.loc == user)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attack_hand(user)
		return
	return ..()

/obj/item/clothing/MouseDrop(var/obj/over_object)
	if (!over_object || !(ishuman(usr) || issmall(usr)))
		return

	//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
	if (!(src.loc == usr))
		return

	if (usr.incapacitated())
		return

	if (!usr.unEquip(src))
		return

	switch(over_object.name)
		if("r_hand")
			usr.put_in_r_hand(src)
		if("l_hand")
			usr.put_in_l_hand(src)
	src.add_fingerprint(usr)

/obj/item/clothing/examine(var/mob/user)
	. = ..(user)
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "[icon2html(A)] \A [A] is attached to it.")
	switch(ironed_state)
		if(WRINKLES_WRINKLY)
			to_chat(user, "<span class='bad'>It's wrinkly.</span>")
		if(WRINKLES_NONE)
			to_chat(user, "<span class='notice'>It's completely wrinkle-free!</span>")

/obj/item/clothing/proc/update_accessory_slowdown()
	var/before = slowdown_accessory
	slowdown_accessory = 0
	for(var/obj/item/clothing/accessory/A in accessories)
		slowdown_accessory += A.slowdown

	if (slowdown_accessory != before)
		var/mob/living/L = loc
		if (istype(L))
			L.update_extension(/datum/extension/updating/encumbrance)
/**
 *  Attach accessory A to src
 *
 *  user is the user doing the attaching. Can be null, such as when attaching
 *  items on spawn
 */
/obj/item/clothing/proc/attach_accessory(mob/user, obj/item/clothing/accessory/A)
	accessories += A
	A.on_attached(src, user)
	if(A.removable)
		src.verbs |= /obj/item/clothing/proc/removetie_verb
	update_accessory_slowdown()
	update_clothing_icon()

/obj/item/clothing/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(!(A in accessories))
		return

	A.on_removed(user)
	accessories -= A
	update_accessory_slowdown()
	update_clothing_icon()

/obj/item/clothing/proc/removetie_verb()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return
	if(!accessories.len) return
	var/obj/item/clothing/accessory/A
	var/list/removables = list()
	for(var/obj/item/clothing/accessory/ass in accessories)
		if(ass.removable)
			removables |= ass
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as null|anything in removables
	else
		A = accessories[1]
	src.remove_accessory(usr,A)
	removables -= A
	if(!removables.len)
		src.verbs -= /obj/item/clothing/proc/removetie_verb

/obj/item/clothing/emp_act(severity)
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)
	..()