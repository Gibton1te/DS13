//Pouches
/obj/item/clothing/accessory/storage/pouches
	name = "storage pouches"
	desc = "A collection of black pouches that can be attached to a plate carrier. Carries up to two items."
	icon_override = 'icons/mob/onmob/modular_armor.dmi'
	icon = 'icons/obj/clothing/modular_armor.dmi'
	accessory_icons = list(slot_tie_str = 'icons/mob/onmob/modular_armor.dmi', slot_wear_suit_str = 'icons/mob/onmob/modular_armor.dmi')
	icon_state = "pouches"
	gender = PLURAL
	slot = ACCESSORY_SLOT_ARMOR_S
	slots = 2

/obj/item/clothing/accessory/storage/pouches/blue
	desc = "A collection of blue pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_blue"

/obj/item/clothing/accessory/storage/pouches/navy
	desc = "A collection of navy blue pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_navy"

/obj/item/clothing/accessory/storage/pouches/green
	desc = "A collection of green pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_green"

/obj/item/clothing/accessory/storage/pouches/tan
	desc = "A collection of tan pouches that can be attached to a plate carrier. Carries up to two items."
	icon_state = "pouches_tan"

/obj/item/clothing/accessory/storage/pouches/large
	name = "large storage pouches"
	desc = "A collection of black pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches"
	slots = 4
	slowdown = 1

/obj/item/clothing/accessory/storage/pouches/large/blue
	desc = "A collection of blue pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_blue"

/obj/item/clothing/accessory/storage/pouches/large/navy
	desc = "A collection of navy blue pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_navy"

/obj/item/clothing/accessory/storage/pouches/large/green
	desc = "A collection of green pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_green"

/obj/item/clothing/accessory/storage/pouches/large/tan
	desc = "A collection of tan pouches that can be attached to a plate carrier. Carries up to four items."
	icon_state = "lpouches_tan"

//Armor plates
/obj/item/clothing/accessory/armorplate
	name = "light armor plate"
	desc = "A basic armor plate made of steel-reinforced synthetic fibers. Attaches to a plate carrier."
	icon = 'icons/obj/clothing/modular_armor.dmi'
	icon_state = "armor_light"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 25, bullet = 30, laser = 30, energy = 10, bomb = 25, bio = 0, rad = 0)
	slot = ACCESSORY_SLOT_ARMOR_C

/obj/item/clothing/accessory/armorplate/get_fibers()
	return null	//plates do not shed

/obj/item/clothing/accessory/armorplate/medium
	name = "medium armor plate"
	desc = "A plasteel-reinforced synthetic armor plate, providing good protection. Attaches to a plate carrier."
	icon_state = "armor_medium"
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)

/obj/item/clothing/accessory/armorplate/tactical
	name = "tactical armor plate"
	desc = "A medium armor plate with additional ablative coating. Attaches to a plate carrier."
	icon_state = "armor_tactical"
	armor = list(melee = 40, bullet = 40, laser = 60, energy = 35, bomb = 30, bio = 0, rad = 0)

/obj/item/clothing/accessory/armorplate/merc
	name = "heavy armor plate"
	desc = "A ceramics-reinforced synthetic armor plate, providing state of of the art protection. Attaches to a plate carrier."
	icon_state = "armor_merc"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 40, bomb = 40, bio = 0, rad = 0)
	slowdown = 1

//Arm guards
/obj/item/clothing/accessory/armguards
	name = "arm guards"
	desc = "A pair of black arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_override = 'icons/mob/onmob/modular_armor.dmi'
	icon = 'icons/obj/clothing/modular_armor.dmi'
	accessory_icons = list(slot_tie_str = 'icons/mob/onmob/modular_armor.dmi', slot_wear_suit_str = 'icons/mob/onmob/modular_armor.dmi')
	icon_state = "armguards"
	gender = PLURAL
	body_parts_covered = ARMS
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)
	slot = ACCESSORY_SLOT_ARMOR_A

/obj/item/clothing/accessory/armguards/blue
	desc = "A pair of blue arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_blue"

/obj/item/clothing/accessory/armguards/navy
	desc = "A pair of navy blue arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_navy"

/obj/item/clothing/accessory/armguards/green
	desc = "A pair of green arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_green"

/obj/item/clothing/accessory/armguards/tan
	desc = "A pair of tan arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_tan"

/obj/item/clothing/accessory/armguards/pcsi
	desc = "A pair of arm pads reinforced with armor plating. Attaches to a plate carrier."
	icon_state = "armguards_pcsi"
	armor = list(melee = 30, bullet = 20, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/accessory/armguards/merc
	name = "heavy arm guards"
	desc = "A pair of red-trimmed black arm pads reinforced with heavy armor plating. Attaches to a plate carrier."
	icon_state = "armguards_merc"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 40, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/accessory/armguards/riot
	name = "riot arm guards"
	desc = "A pair of armored arm pads with heavy padding to protect against melee attacks."
	icon_state = "armguards_riot"
	armor = list(melee = 75, bullet = 33, laser = 50, energy = 0, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.5

/obj/item/clothing/accessory/armguards/ballistic
	name = "ballistic arm guards"
	desc = "A pair of armored arm pads with heavy plates to protect against ballistic projectiles."
	icon_state = "armguards_ballistic"
	armor = list(melee = 42, bullet = 75, laser = 42, energy = 0, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.7

/obj/item/clothing/accessory/armguards/ablative
	name = "ablative arm guards"
	desc = "A pair of armored arm pads with advanced shielding to protect against energy weapons."
	icon_state = "armguards_ablative"
	armor = list(melee = 35, bullet = 35, laser = 75, energy = 50, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/*
/obj/item/clothing/accessory/armguards/tactical
	name = "tactical arm guards"
	desc = "TEMPORARY DESC"
	icon_state = "armguards_tactical"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.5*/

//Leg guards
/obj/item/clothing/accessory/legguards
	name = "leg guards"
	desc = "A pair of armored leg pads in black. Attaches to a plate carrier."
	icon_override = 'icons/mob/onmob/modular_armor.dmi'
	icon = 'icons/obj/clothing/modular_armor.dmi'
	accessory_icons = list(slot_tie_str = 'icons/mob/onmob/modular_armor.dmi', slot_wear_suit_str = 'icons/mob/onmob/modular_armor.dmi')
	icon_state = "legguards"
	gender = PLURAL
	body_parts_covered = LEGS
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 25, bomb = 30, bio = 0, rad = 0)
	slot = ACCESSORY_SLOT_ARMOR_L

/obj/item/clothing/accessory/legguards/blue
	desc = "A pair of armored leg pads in blue. Attaches to a plate carrier."
	icon_state = "legguards_blue"

/obj/item/clothing/accessory/legguards/navy
	desc = "A pair of armored leg pads in navy blue. Attaches to a plate carrier."
	icon_state = "legguards_navy"

/obj/item/clothing/accessory/legguards/green
	desc = "A pair of armored leg pads in green. Attaches to a plate carrier."
	icon_state = "legguards_green"

/obj/item/clothing/accessory/legguards/tan
	desc = "A pair of armored leg pads in tan. Attaches to a plate carrier."
	icon_state = "legguards_tan"

/obj/item/clothing/accessory/legguards/pcsi
	desc = "A pair of armored leg pads. Attaches to a plate carrier."
	icon_state = "legguards_pcsi"
	armor = list(melee = 30, bullet = 20, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/accessory/legguards/merc
	name = "heavy leg guards"
	desc = "A pair of heavily armored leg pads in red-trimmed black. Attaches to a plate carrier."
	icon_state = "legguards_merc"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 40, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/accessory/legguards/riot
	name = "riot leg guards"
	desc = "A pair of armored leg pads with heavy padding to protect against melee attacks. Looks like they might impair movement."
	icon_state = "legguards_riot"
	armor = list(melee = 75, bullet = 33, laser = 50, energy = 0, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.5
	slowdown = 1

/obj/item/clothing/accessory/legguards/ballistic
	name = "ballistic leg guards"
	desc = "A pair of armored leg pads with heavy plates to protect against ballistic projectiles. Looks like they might impair movement."
	icon_state = "legguards_ballistic"
	armor = list(melee = 42, bullet = 75, laser = 42, energy = 0, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.7
	slowdown = 1

/obj/item/clothing/accessory/legguards/ablative
	name = "ablative leg guards"
	desc = "A pair of armored leg pads with advanced shielding to protect against energy weapons. Looks like they might impair movement."
	icon_state = "legguards_ablative"
	armor = list(melee = 35, bullet = 35, laser = 75, energy = 50, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0
	slowdown = 1

/*
/obj/item/clothing/accessory/legguards/tactical
	name = "tactical legguards guards"
	desc = "TEMPORARY DESC"
	icon_state = "legguards_tactical"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.5*/


//Decorative attachments
/obj/item/clothing/accessory/armor/tag
	name = "master armor tag"
	desc = "A collection of various tags for placing on the front of a plate carrier."
	icon_override = 'icons/mob/onmob/modular_armor.dmi'
	icon = 'icons/obj/clothing/modular_armor.dmi'
	accessory_icons = list(slot_tie_str = 'icons/mob/onmob/modular_armor.dmi', slot_wear_suit_str = 'icons/mob/onmob/modular_armor.dmi')
	icon_state = "null"
	slot = ACCESSORY_SLOT_ARMOR_M

/obj/item/clothing/accessory/armor/tag/pcsi
	name = "\improper P.C.S.I. SECURITY tag"
	desc = "An armor tag with the words P.C.S.I. SECURITY printed in red lettering on it."
	icon_state = "nanotag"

/obj/item/clothing/accessory/armor/tag/opos
	name = "\improper O+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as O POSITIVE."
	icon_state = "opostag"

/obj/item/clothing/accessory/armor/tag/oneg
	name = "\improper O- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as O NEGATIVE."
	icon_state = "onegtag"

/obj/item/clothing/accessory/armor/tag/apos
	name = "\improper A+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as A POSITIVE."
	icon_state = "apostag"

/obj/item/clothing/accessory/armor/tag/aneg
	name = "\improper A- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as A NEGATIVE."
	icon_state = "anegtag"

/obj/item/clothing/accessory/armor/tag/bpos
	name = "\improper B+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as B POSITIVE."
	icon_state = "bpostag"

/obj/item/clothing/accessory/armor/tag/bneg
	name = "\improper B- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as B NEGATIVE."
	icon_state = "bnegtag"

/obj/item/clothing/accessory/armor/tag/abpos
	name = "\improper AB+ blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as AB POSITIVE."
	icon_state = "abpostag"

/obj/item/clothing/accessory/armor/tag/abneg
	name = "\improper AB- blood patch"
	desc = "An embroidered patch indicating the wearer's blood type as AB NEGATIVE."
	icon_state = "abnegtag"

/obj/item/clothing/accessory/armor/helmcover
	name = "helmet cover"
	desc = "A fabric cover for armored helmets."
	icon_override = 'icons/mob/onmob/modular_armor.dmi'
	icon = 'icons/obj/clothing/modular_armor.dmi'
	accessory_icons = list(slot_tie_str = 'icons/mob/onmob/modular_armor.dmi', slot_head_str = 'icons/mob/onmob/modular_armor.dmi')
	icon_state = "null"
	slot = ACCESSORY_SLOT_HELM_C

/obj/item/clothing/accessory/armor/helmcover/blue
	name = "blue helmet cover"
	desc = "A fabric cover for armored helmets in a bright blue color."
	icon_state = "helmcover_blue"

/obj/item/clothing/accessory/armor/helmcover/navy
	name = "navy blue helmet cover"
	desc = "A fabric cover for armored helmets. This one is colored navy blue."
	icon_state = "helmcover_navy"

/obj/item/clothing/accessory/armor/helmcover/green
	name = "green helmet cover"
	desc = "A fabric cover for armored helmets. This one has a woodland camouflage pattern."
	icon_state = "helmcover_green"

/obj/item/clothing/accessory/armor/helmcover/tan
	name = "tan helmet cover"
	desc = "A fabric cover for armored helmets. This one has a desert camouflage pattern."
	icon_state = "helmcover_tan"