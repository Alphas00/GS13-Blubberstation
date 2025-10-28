/datum/mutation/radfat
	name = "Radiotrophic Metabolism"
	desc = "A mutation that causes the user to be immune to the adverse effects of radiations, but causes sudden cell multiplication with increased strength under irradiation."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You crave the taste of... radiation?</span>"
	text_lose_indication = "<span class='notice'>You no longer desire the taste of radiation...</span>"
	difficulty = 14
	instability = 30
	power_coeff = 1

/datum/mutation/radfat/on_life(seconds_per_tick, times_fired)
	var/fat_add = 1
	var/pwr = GET_MUTATION_POWER(src)
	if(HAS_TRAIT(owner, TRAIT_IRRADIATED))
		fat_add += 9
	owner.adjust_fatness(fat_add * pwr, FATTENING_TYPE_RADIATIONS)

/datum/mutation/radfat/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_RAD_RESISTANCE, src)

/datum/mutation/radfat/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(owner, TRAIT_RAD_RESISTANCE, src)

/obj/item/dnainjector/antiradfat
	name = "\improper DNA injector (Anti-Radiotrophic Metabolism)"
	desc = "The green kills."
	remove_mutations = list(/datum/mutation/radfat)

/obj/item/dnainjector/radfat
	name = "\improper DNA injector (Radiotrophic Metabolism)"
	desc = "Nuclear fallout protection at an heavy price."
	add_mutations = list(/datum/mutation/radfat)
