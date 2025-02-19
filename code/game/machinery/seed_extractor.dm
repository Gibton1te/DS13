/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics_machines.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	use_power = 2
	idle_power_usage = 10
	active_power_usage = 2000
	circuit = /obj/item/weapon/circuitboard/seed_extractor

obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(default_deconstruction_screwdriver(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(default_part_replacement(user, O))
		return

	// Fruits and vegetables.
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown) || istype(O, /obj/item/weapon/grown))
		if(!user.unEquip(O))
			return

		var/datum/seed/new_seed_type
		if(istype(O, /obj/item/weapon/grown))
			var/obj/item/weapon/grown/F = O
			new_seed_type = plant_controller.seeds[F.plantname]
		else
			var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
			new_seed_type = plant_controller.seeds[F.plantname]

		if(new_seed_type)
			to_chat(user, "<span class='notice'>You extract some seeds from [O].</span>")
			playsound(src, 'sound/machines/tankbiorecycle.ogg', VOLUME_LOW)
			var/produce = rand(1,4)
			for(var/i = 0;i<=produce;i++)
				var/obj/item/seeds/seeds = new(get_turf(src))
				seeds.seed_type = new_seed_type.name
				seeds.update_seed()
		else
			to_chat(user, "[O] doesn't seem to have any usable seeds inside it.")

		qdel(O)

	//Grass.
	else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		if (S.use(1))
			to_chat(user, "<span class='notice'>You extract some seeds from the grass tile.</span>")
			playsound(src, 'sound/machines/tankbiorecycle.ogg', VOLUME_LOW)
			new /obj/item/seeds/grassseed(loc)

	else if(istype(O, /obj/item/weapon/fossil/plant)) // Fossils
		var/obj/item/seeds/random/R = new(get_turf(src))
		to_chat(user, "\The [src] scans \the [O] and spits out \a [R].")
		playsound(src, 'sound/machines/tankbiorecycle.ogg', VOLUME_LOW)
		qdel(O)

	return

/obj/machinery/seed_extractor/dismantle()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	..()
