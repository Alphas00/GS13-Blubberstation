/datum/mutation/fatfang
	name = "The Nibble"
	desc = "A rare mutation that grows a pair of fangs in the user's mouth that inject a chemical that develops the target's adipose tissue."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You feel something growing in your mouth!</span>"
	text_lose_indication = "<span class='notice'>You feel your fangs shrink away.</span>"
	difficulty = 8
	//power = /obj/effect/proc_holder/spell/targeted/touch/fatfang
	instability = 10
	energy_coeff = 1
	power_coeff = 1
	power_path = /datum/action/cooldown/mob_cooldown/aphrodisiacal_bite/fatfang

/datum/action/cooldown/mob_cooldown/aphrodisiacal_bite/fatfang
	name = "Nibble 'em!"
	desc = "Just a small bite and watch them grow."
	button_icon = 'modular_gs/icons/mob/actions/the_nibble.dmi'
	button_icon_state = "fattybite_active"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi'
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED // can use it if cuffed, enjoy
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE

	reagent_typepath = /datum/reagent/consumable/lipoifier
	to_inject = 5

/datum/action/cooldown/mob_cooldown/aphrodisiacal_bite/fatfang/set_reagent(datum/reagent/new_reagent, quantity_override = null, cooldown_override = null)
	return

/datum/action/cooldown/mob_cooldown/aphrodisiacal_bite/fatfang/Activate(atom/target_atom)
	if (!isliving(target_atom))
		return FALSE

	if (astype(owner, /mob/living/carbon)?.is_mouth_covered())
		owner.balloon_alert(owner, "mouth covered!")
		return FALSE

	if (!owner.Adjacent(target_atom))
		owner.balloon_alert(owner, "too far!")
		return FALSE

	if (target_atom == owner)
		owner.balloon_alert(owner, "can't bite yourself!")
		return FALSE

	if(!iscarbon(target_atom))
		owner.balloon_alert(owner, "not carbon!")
		return FALSE

	log_combat(owner, target_atom, "started to bite", null, "with venom: [reagent_typepath::name]")
	owner.visible_message(span_warning("[owner] starts to bite [target_atom]!"), span_warning("You start to bite [target_atom]!"), ignored_mobs = target_atom)
	to_chat(target_atom, span_userdanger("[owner] starts to bite you!"))
	owner.balloon_alert_to_viewers("biting...")
	if (!do_after(owner, 2 SECONDS, target_atom, IGNORE_HELD_ITEM))
		return FALSE

	if (attempt_bite(target_atom))
		inject(target_atom)
		if(owner.pulling && owner.pulling == target_atom)
			var/cycle = 0
			while(cycle < 9 && in_range(owner, target_atom))
				cycle += 1
				owner.balloon_alert_to_viewers("pumping...")
				if(do_after(owner, 1 SECONDS, target_atom, IGNORE_HELD_ITEM))
					inject(target_atom)

	var/total_delay = 0
	for(var/datum/action/cooldown/ability as anything in initialized_actions)
		if(LAZYLEN(ability.initialized_actions) > 0)
			ability.initialized_actions = list()
		addtimer(CALLBACK(ability, PROC_REF(Activate), target), total_delay)
		total_delay += initialized_actions[ability]
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/aphrodisiacal_bite/fatfang/proc/attempt_bite(mob/living/target)
	var/target_zone = check_zone(owner.zone_selected)

	var/text = "[owner] sinks [owner.p_their()] teeth into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"
	var/self_message = "You sink your teeth into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"
	var/victim_message = "[owner] sinks [owner.p_their()] teeth into your [target.parse_zone_with_bodypart(target_zone)]!"

	owner.visible_message(span_warning(text), span_warning(self_message), ignored_mobs = list(target))
	to_chat(target, span_userdanger(victim_message))

	owner.do_attack_animation(target, ATTACK_EFFECT_BITE)
	playsound(owner, 'sound/items/weapons/bite.ogg', 60, TRUE)
	log_combat(owner, target, "successfully bit", null, "with venom: [reagent_typepath::name]")
	return TRUE

/datum/action/cooldown/mob_cooldown/aphrodisiacal_bite/fatfang/add_reagents(datum/reagents/target, harvesting = FALSE)
	var/mob/living/carbon/human/holder = owner
	var/temp = holder?.coretemperature
	var/datum/mutation/fatfang/ff = holder?.dna.get_mutation(/datum/mutation/fatfang)
	target.add_reagent(reagent_typepath, to_inject * GET_MUTATION_POWER(ff), reagtemp = temp)
	return TRUE

/*
/obj/effect/proc_holder/spell/targeted/touch/fatfang
	name = "The Nibble"
	desc = "Draw out fangs that inject fattening venom"
	drawmessage = "You draw out your fangs."
	dropmessage = "You retract your fangs."
	hand_path = /obj/item/melee/touch_attack/fatfang
	action_icon = 'icons\mob\actions\actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	charge_max = 50
	clothes_req = FALSE

/obj/item/melee/touch_attack/fatfang
	name = "\improper fattening fangs"
	desc = "Fangs armed with a venom most ample."
	catchphrase = null
	icon = 'icons\mob\actions\actions_ecult.dmi'
	icon_state = "blood_siphon"

	var/starttime = 0

/obj/item/melee/touch_attack/fatfang/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || !iscarbon(target))
		return FALSE
	var/datum/mutation/human/fatfang/fang = user.dna.get_mutation(FATFANG)
	if(!target || !istype(fang) || !fang.chem_to_add || !fang.chem_amount)
		return FALSE
	target.visible_message("<span class='danger'>[user] nibbles [target]!</span>","<span class='userdanger'>[user] nibbles you!</span>")
	if(target == user.pulling && ishuman(user.pulling))
		starttime = world.time
		fang.power.charge_max = 600 * GET_MUTATION_ENERGY(fang)
		while(starttime + 300 > world.time && in_range(user, target))
			if(do_mob(user, target, 10, 0, 1))
				target.reagents.add_reagent(fang.chem_to_add, (fang.chem_amount * GET_MUTATION_POWER(fang)/2))
				target.visible_message("<span class='danger'>[user] pumps some venom in [target]!</span>","<span class='userdanger'>[user] pumps some venom in you!</span>")
	else
		fang.power.charge_max = 50 * GET_MUTATION_ENERGY(fang)
		target.reagents.add_reagent(fang.chem_to_add, fang.chem_amount * GET_MUTATION_POWER(fang))
	//user.changeNext_move(50)
*/
/obj/item/dnainjector/antifang
	name = "\improper DNA injector (Anti-The Nibble)"
	desc = "By the power of sugar, their fangs shall fall."
	remove_mutations = list(/datum/mutation/fatfang)

/obj/item/dnainjector/fatfang
	name = "\improper DNA injector (The Nibble)"
	desc = "Give 'em just a teeny tiny bite."
	add_mutations = list(/datum/mutation/fatfang)
