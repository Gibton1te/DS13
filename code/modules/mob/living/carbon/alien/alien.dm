/mob/living/carbon/alien

	name = "alien"
	desc = "What IS that?"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alien"
	pass_flags = PASS_FLAG_TABLE
	health = 100
	max_health = 100
	mob_size = 4
	species_language = "Xenophage"

	var/dead_icon
	var/language
	var/death_msg = "lets out a waning guttural screech, green blood bubbling from its maw."
	var/instance_num

/mob/living/carbon/alien/New()

	add_verb(src, list(/mob/living/proc/ventcrawl, /mob/living/proc/hide_mob))

	instance_num = rand(1, 1000)
	name = "[initial(name)] ([instance_num])"
	real_name = name
	regenerate_icons()

	if(language)
		add_language(language)

	gender = NEUTER

	..()

/mob/living/carbon/alien/u_equip(obj/item/W as obj)
	return

/mob/living/carbon/alien/restrained()
	return 0

/mob/living/carbon/alien/show_inv(mob/user as mob)
	return //Consider adding cuffs and hats to this, for the sake of fun.