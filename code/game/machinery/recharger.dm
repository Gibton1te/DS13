//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

obj/machinery/recharger
	name = "recharger"
	desc = "An all-purpose recharger for a variety of devices."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 50 KILOWATTS
	circuit = /obj/item/weapon/circuitboard/recharger
	var/obj/item/charging = null
	var/recharge_coeff = 1
	var/list/allowed_devices = list(/obj/item/weapon/gun/energy, /obj/item/weapon/gun/magnetic/railgun, /obj/item/weapon/melee/baton, /obj/item/weapon/cell, /obj/item/modular_computer/, /obj/item/device/suit_sensor_jammer, /obj/item/weapon/computer_hardware/battery_module, /obj/item/weapon/shield_diffuser, /obj/item/clothing/mask/smokable/ecig, /obj/item/device/radio)
	var/icon_state_charged = "recharger2"
	var/icon_state_charging = "recharger1"
	var/icon_state_idle = "recharger0" //also when unpowered
	var/portable = 1

/obj/machinery/recharger/RefreshParts()
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating/2

obj/machinery/recharger/attackby(obj/item/weapon/G as obj, mob/user as mob)
	if(default_deconstruction_screwdriver(user, G))
		return
	if(default_deconstruction_crowbar(user, G))
		return
	if(default_part_replacement(user, G))
		return

	if(istype(user,/mob/living/silicon))
		return

	var/allowed = 0
	for (var/allowed_type in allowed_devices)
		if (istype(G, allowed_type)) allowed = 1

	if(allowed)
		if(charging)
			to_chat(user, "<span class='warning'>\A [charging] is already charging here.</span>")
			return
		// Checks to make sure he's not in space doing it, and that the area got proper power.
		if(!powered())
			to_chat(user, "<span class='warning'>The [name] blinks red as you try to insert the item!</span>")
			return
		if (istype(G, /obj/item/weapon/gun/energy/))
			var/obj/item/weapon/gun/energy/E = G
			if(E.self_recharge)
				to_chat(user, "<span class='notice'>You can't find a charging port on \the [E].</span>")
				return
		if(!G.get_cell())
			to_chat(user, "This device does not have a battery installed.")
			return

		if(user.unEquip(G))
			G.forceMove(src)
			charging = G
			update_icon()
	else if(portable && isWrench(G))
		if(charging)
			to_chat(user, "<span class='warning'>Remove [charging] first!</span>")
			return
		anchored = !anchored
		to_chat(user, "You [anchored ? "attached" : "detached"] the recharger.")
		playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)

obj/machinery/recharger/attack_hand(mob/user as mob)
	if(istype(user,/mob/living/silicon))
		return

	..()

	if(charging)
		charging.update_icon()
		user.put_in_hands(charging)
		charging = null
		update_icon()

obj/machinery/recharger/Process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		update_use_power(0)
		icon_state = icon_state_idle
		return

	if(!charging)
		update_use_power(1)
		icon_state = icon_state_idle
	else
		var/obj/item/weapon/cell/C = charging.get_cell()
		if(istype(C))
			if(!C.fully_charged())
				icon_state = icon_state_charging
				C.give(active_power_usage*recharge_coeff*CELLRATE)
				update_use_power(2)
			else
				icon_state = icon_state_charged
				update_use_power(1)

obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return
	if(charging)
		var/obj/item/weapon/cell/C = charging.get_cell()
		if(istype(C))
			C.emp_act(severity)
	..(severity)

obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(charging)
		icon_state = icon_state_charging
	else
		icon_state = icon_state_idle


obj/machinery/recharger/wallcharger
	name = "wall recharger"
	desc = "A heavy duty wall recharger specialized for energy weaponry."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"
	active_power_usage = 70 KILOWATTS	//It's more specialized than the standalone recharger (guns and batons only) so make it more powerful
	allowed_devices = list(/obj/item/weapon/gun/magnetic/railgun, /obj/item/weapon/gun/energy, /obj/item/weapon/melee/baton)
	icon_state_charged = "wrecharger2"
	icon_state_charging = "wrecharger1"
	icon_state_idle = "wrecharger0"
	portable = 0
