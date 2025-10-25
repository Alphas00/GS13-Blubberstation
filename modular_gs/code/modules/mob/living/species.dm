
/mob/living/carbon/human/proc/update_body_size(mob/living/carbon/human/H, size_change)
	if(!istype(H))
		return

	var/obj/item/organ/genital/butt/butt = H.get_organ_slot(ORGAN_SLOT_BUTT)
	var/obj/item/organ/genital/belly/belly = H.get_organ_slot(ORGAN_SLOT_BELLY)
	var/obj/item/organ/genital/breasts/breasts = H.get_organ_slot(ORGAN_SLOT_BREASTS)
	// var/obj/item/organ/genital/taur_belly/tbelly = H.get_organ_slot(ORGAN_SLOT_TAUR_BELLY)

	if(butt)
		butt.update_size_from_weight(size_change)
	if(belly)
		belly.update_size_from_weight(size_change)
	// if(tbelly)
	// 	if(tbelly.max_genital_size > 0)
	// 		if((tbelly.size + size_change) <= tbelly.max_genital_size)
	// 			tbelly.set_size(size_change)
	// 	else
	// 		tbelly.set_size(size_change)
	if(breasts)
		breasts.update_size_from_weight(size_change)

	// H.genital_override = TRUE
	H.update_body()
	H.update_worn_undersuit()
	H.update_worn_oversuit()

/obj/item/organ/genital/proc/update_size_from_weight(size_change)
	if (max_genital_size > 0 && (set_genital_size + size_change) >= max_genital_size)
		set_size(max_genital_size)
	else
		set_size(size_change + set_genital_size)


/mob/living/carbon/human/proc/handle_fatness_trait(trait, trait_lose, trait_gain, fatness_lose, fatness_gain, chat_lose, chat_gain, weight_stage)
	var/mob/living/carbon/human/H = src
	if(H.fatness < fatness_lose)
		if (chat_lose)
			to_chat(H, chat_lose)
		if (trait)
			REMOVE_TRAIT(H, trait, OBESITY)
		if (trait_lose)
			ADD_TRAIT(H, trait_lose, OBESITY)
		update_body_size(H, weight_stage - 1)
	else if(H.fatness >= fatness_gain)
		if (chat_gain)
			to_chat(H, chat_gain)
		if (trait)
			REMOVE_TRAIT(H, trait, OBESITY)
		if (trait_gain)
			ADD_TRAIT(H, trait_gain, OBESITY)
		update_body_size(H, weight_stage + 1)

/mob/living/carbon/human/proc/handle_helplessness()
	// return TRUE

	var/mob/living/carbon/human/fatty = src
	if (isnull(fatty.client))
		return FALSE

	if (isnull(fatty.client.prefs))
		return FALSE

	var/datum/preferences/preferences = fatty.client.prefs
	if(HAS_TRAIT(fatty, TRAIT_NO_HELPLESSNESS))
		return FALSE

	var/immobility_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/no_movement)
	if(HAS_TRAIT(fatty, TRAIT_HELPLESS_IMMOBILITY))
		immobility_BFI = FATNESS_LEVEL_IMMOBILE
		if (HAS_TRAIT(fatty, TRAIT_STRONGLEGS))
			immobility_BFI = FATNESS_LEVEL_BLOB
		if (HAS_TRAIT(fatty, TRAIT_WEAKLEGS))
			immobility_BFI = FATNESS_LEVEL_BARELYMOBILE
	
	if (immobility_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_NO_MOVE, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= immobility_BFI)
				to_chat(fatty, span_warning("You have become too fat to move anymore."))
				ADD_TRAIT(fatty, TRAIT_NO_MOVE, HELPLESSNESS_TRAIT)

		else if(fatty.fatness < immobility_BFI)
			to_chat(fatty, span_notice("You have become thin enough to regain some of your mobility."))
			REMOVE_TRAIT(fatty, TRAIT_NO_MOVE, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_NO_MOVE, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_NO_MOVE, HELPLESSNESS_TRAIT)

	var/clumsy_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/clumsy)
	if(HAS_TRAIT(fatty, TRAIT_HELPLESS_CLUMSY))
		clumsy_BFI = FATNESS_LEVEL_BARELYMOBILE

	if (clumsy_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_CLUMSY, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= clumsy_BFI)
				to_chat(fatty, span_warning("Your newfound weight has made it hard to manipulate objects."))
				ADD_TRAIT(fatty, TRAIT_CLUMSY, HELPLESSNESS_TRAIT)
				ADD_TRAIT(fatty, TRAIT_CHUNKYFINGERS, HELPLESSNESS_TRAIT)

		else if(fatty.fatness < clumsy_BFI)
			to_chat(fatty, span_notice("You feel like you have lost enough weight to recover your dexterity."))
			REMOVE_TRAIT(fatty, TRAIT_CLUMSY, HELPLESSNESS_TRAIT)
			REMOVE_TRAIT(fatty, TRAIT_CHUNKYFINGERS, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_CLUMSY, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_CLUMSY, HELPLESSNESS_TRAIT)
			REMOVE_TRAIT(fatty, TRAIT_CHUNKYFINGERS, HELPLESSNESS_TRAIT)

	var/nearsighted_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/nearsighted)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_BIG_CHEEKS))
		nearsighted_BFI = FATNESS_LEVEL_BLOB
	
	if(nearsighted_BFI > 0)
		if(!fatty.is_nearsighted_from(HELPLESSNESS_TRAIT))
			if(fatty.fatness >= nearsighted_BFI)
				to_chat(fatty, span_warning("Your fat makes it difficult to see the world around you. "))
				fatty.become_nearsighted(HELPLESSNESS_TRAIT)

		else if(fatty.fatness < nearsighted_BFI)
			to_chat(fatty, span_notice("You are thin enough to see your enviornment again. "))
			fatty.cure_nearsighted(HELPLESSNESS_TRAIT)

	else
		if(fatty.is_nearsighted_from(HELPLESSNESS_TRAIT))
			fatty.cure_nearsighted(HELPLESSNESS_TRAIT)

	var/hidden_face_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/hidden_face)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_BIG_CHEEKS))
		hidden_face_BFI = FATNESS_LEVEL_BLOB

	if(hidden_face_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_DISFIGURED, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= hidden_face_BFI)
				to_chat(fatty, span_warning("You have gotten fat enough that your face is now unrecognizable. "))
				ADD_TRAIT(fatty, TRAIT_DISFIGURED, HELPLESSNESS_TRAIT)

		else if(fatty.fatness < hidden_face_BFI)
			to_chat(fatty, span_notice("You have lost enough weight to allow people to now recognize your face."))
			REMOVE_TRAIT(fatty, TRAIT_DISFIGURED, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_DISFIGURED, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_DISFIGURED, HELPLESSNESS_TRAIT)

	var/mute_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/mute)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_MUTE))
		mute_BFI = FATNESS_LEVEL_BLOB

	if(mute_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_MUTE, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= mute_BFI)
				to_chat(fatty, span_warning("Your fat makes it impossible for you to speak."))
				ADD_TRAIT(fatty, TRAIT_MUTE, HELPLESSNESS_TRAIT)

		else if(fatty.fatness < mute_BFI)
			to_chat(fatty, span_notice("You are thin enough now to be able to speak again. "))
			REMOVE_TRAIT(fatty, TRAIT_MUTE, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_MUTE, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_MUTE, HELPLESSNESS_TRAIT)

	var/immobile_arms_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/immobile_arms)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_IMMOBILE_ARMS))
		immobile_arms_BFI = FATNESS_LEVEL_BLOB

	if(immobile_arms_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_PARALYSIS_L_ARM, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= immobile_arms_BFI)
				to_chat(fatty, span_warning("Your arms are now engulfed in fat, making it impossible to move your arms. "))
				ADD_TRAIT(fatty, TRAIT_PARALYSIS_L_ARM, HELPLESSNESS_TRAIT)
				ADD_TRAIT(fatty, TRAIT_PARALYSIS_R_ARM, HELPLESSNESS_TRAIT)
				fatty.update_body_parts()

		else if(fatty.fatness < immobile_arms_BFI)
			to_chat(fatty, span_notice("You are able to move your arms again. "))
			REMOVE_TRAIT(fatty, TRAIT_PARALYSIS_L_ARM, HELPLESSNESS_TRAIT)
			REMOVE_TRAIT(fatty, TRAIT_PARALYSIS_R_ARM, HELPLESSNESS_TRAIT)
			fatty.update_body_parts()

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_PARALYSIS_L_ARM, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_PARALYSIS_L_ARM, HELPLESSNESS_TRAIT)
			REMOVE_TRAIT(fatty, TRAIT_PARALYSIS_R_ARM, HELPLESSNESS_TRAIT)
			fatty.update_body_parts()

	var/jumpsuit_bursting_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/clothing_jumpsuit)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_CLOTHING))
		jumpsuit_bursting_BFI = FATNESS_LEVEL_IMMOBILE

	if(jumpsuit_bursting_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_NO_JUMPSUIT, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= jumpsuit_bursting_BFI)
				ADD_TRAIT(fatty, TRAIT_NO_JUMPSUIT, HELPLESSNESS_TRAIT)

				var/obj/item/clothing/under/jumpsuit = fatty.w_uniform
				if(istype(jumpsuit) && jumpsuit.modular_icon_location == null)
					to_chat(fatty, span_warning("[jumpsuit] can no longer contain your weight!"))
					fatty.dropItemToGround(jumpsuit)

		else if(fatty.fatness < jumpsuit_bursting_BFI)
			to_chat(fatty, span_notice("You feel thin enough to put on jumpsuits now."))
			REMOVE_TRAIT(fatty, TRAIT_NO_JUMPSUIT, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_NO_JUMPSUIT, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_NO_JUMPSUIT, HELPLESSNESS_TRAIT)

	var/clothing_bursting_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/clothing_misc)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_CLOTHING))
		clothing_bursting_BFI = FATNESS_LEVEL_BARELYMOBILE

	if(clothing_bursting_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_NO_MISC, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= clothing_bursting_BFI)
				ADD_TRAIT(fatty, TRAIT_NO_MISC, HELPLESSNESS_TRAIT)

				var/obj/item/clothing/suit/worn_suit = fatty.wear_suit
				if(istype(worn_suit) && !istype(worn_suit, /obj/item/clothing/suit/mod))
					to_chat(fatty, span_warning("[worn_suit] can no longer contain your weight!"))
					fatty.dropItemToGround(worn_suit)

				var/obj/item/clothing/gloves/worn_gloves = fatty.gloves
				if(istype(worn_gloves)&& !istype(worn_gloves, /obj/item/clothing/gloves/mod))
					to_chat(fatty, span_warning("[worn_gloves] can no longer contain your weight!"))
					fatty.dropItemToGround(worn_gloves)

				var/obj/item/clothing/shoes/worn_shoes = fatty.shoes
				if(istype(worn_shoes) && !istype(worn_shoes, /obj/item/clothing/shoes/mod))
					to_chat(fatty, span_warning("[worn_shoes] can no longer contain your weight!"))
					fatty.dropItemToGround(worn_shoes)

		else if(fatty.fatness < clothing_bursting_BFI)
			to_chat(fatty, span_notice("You feel thin enough to put on suits, shoes, and gloves now."))
			REMOVE_TRAIT(fatty, TRAIT_NO_MISC, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_NO_MISC, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_NO_MISC, HELPLESSNESS_TRAIT)

	var/belt_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/belts)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_BELTS))
		belt_BFI = FATNESS_LEVEL_EXTREMELY_OBESE

	if(belt_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_NO_BELT, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= belt_BFI)
				ADD_TRAIT(fatty, TRAIT_NO_BELT, HELPLESSNESS_TRAIT)

				var/obj/item/bluespace_belt/primitive/PBS_belt = fatty.belt
				if(istype(PBS_belt) && fatty.fatness > belt_BFI)
					fatty.visible_message(span_warning("[PBS_belt] fails as it's unable to contain [fatty]'s bulk!"),
					span_warning("[PBS_belt] fails as it's unable to contain your bulk!"))
					fatty.dropItemToGround(PBS_belt)

				var/obj/item/storage/belt/belt = fatty.belt
				if(istype(belt))
					fatty.visible_message(
						span_warning("With a loud ripping sound, [fatty]'s [belt] snaps open!"),
						span_warning("With a loud ripping sound, your [belt] snaps open!"))
					fatty.dropItemToGround(belt)

		else if(fatty.fatness < belt_BFI)
			to_chat(fatty, span_notice("You feel thin enough to put on belts now."))
			REMOVE_TRAIT(fatty, TRAIT_NO_BELT, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_NO_BELT, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_NO_BELT, HELPLESSNESS_TRAIT)

	var/back_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/clothing_back)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_BACKPACKS))
		back_BFI = FATNESS_LEVEL_IMMOBILE
	
	if(back_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_NO_BACKPACK, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= back_BFI)
				ADD_TRAIT(fatty, TRAIT_NO_BACKPACK, HELPLESSNESS_TRAIT)
				var/obj/item/back_item = fatty.back
				if(istype(back_item) && !istype(back_item, /obj/item/mod))
					to_chat(fatty, span_warning("Your weight makes it impossible for you to carry [back_item]."))
					fatty.dropItemToGround(back_item)

		else if(fatty.fatness < back_BFI)
			to_chat(fatty, span_notice("You feel thin enough to hold items on your back now."))
			REMOVE_TRAIT(fatty, TRAIT_NO_BACKPACK, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_NO_BACKPACK, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_NO_BACKPACK, HELPLESSNESS_TRAIT)

	var/no_buckle_BFI = preferences.read_preference(/datum/preference/numeric/helplessness/no_buckle)
	if (HAS_TRAIT(fatty, TRAIT_HELPLESS_NO_BUCKLE))
		no_buckle_BFI = FATNESS_LEVEL_EXTREMELY_OBESE

	if(no_buckle_BFI > 0)
		if(!HAS_TRAIT_FROM(fatty, TRAIT_NO_BUCKLE, HELPLESSNESS_TRAIT))
			if(fatty.fatness >= no_buckle_BFI)
				to_chat(fatty, span_warning("You feel like you've gotten too big to fit on anything."))
				ADD_TRAIT(fatty, TRAIT_NO_BUCKLE, HELPLESSNESS_TRAIT)

		else if(fatty.fatness < no_buckle_BFI)
			to_chat(fatty, span_warning("You feel thin enough to sit on things again."))
			REMOVE_TRAIT(fatty, TRAIT_NO_BUCKLE, HELPLESSNESS_TRAIT)

	else
		if(HAS_TRAIT_FROM(fatty, TRAIT_NO_BUCKLE, HELPLESSNESS_TRAIT))
			REMOVE_TRAIT(fatty, TRAIT_NO_BUCKLE, HELPLESSNESS_TRAIT)


/datum/movespeed_modifier/fatness
	id = "fat"
	variable = TRUE

/mob/living/carbon
	var/list/fatness_delay_modifiers

/datum/fatness_delay_modifier
	var/name
	var/amount = 0
	var/multiplier = 1

/mob/living/carbon/proc/add_fat_delay_modifier(name = "", amount = 0, multiplier = 1)
	var/find_name = FALSE
	for(var/datum/fatness_delay_modifier/modifier in fatness_delay_modifiers)
		if(modifier.name == name && find_name == FALSE)
			modifier.amount = amount
			modifier.multiplier = multiplier
			find_name = TRUE
	if(find_name == FALSE)
		var/datum/fatness_delay_modifier/new_modifier = new()
		new_modifier.name = name
		new_modifier.amount = amount
		new_modifier.multiplier = multiplier
		LAZYADD(fatness_delay_modifiers, new_modifier)

/mob/living/carbon/proc/remove_fat_delay_modifier(name)
	for(var/datum/fatness_delay_modifier/modifier in fatness_delay_modifiers)
		if(modifier.name == name)
			LAZYREMOVE(fatness_delay_modifiers, modifier)

/mob/living/carbon/human/proc/apply_fatness_speed_modifiers(fatness_delay)
	var/mob/living/carbon/human/H = src
	var/delay_cap = FATNESS_MAX_MOVE_PENALTY
	if(HAS_TRAIT(H, TRAIT_WEAKLEGS))
		delay_cap = 60
	for(var/datum/fatness_delay_modifier/modifier in H.fatness_delay_modifiers)
		fatness_delay = fatness_delay + modifier.amount
	for(var/datum/fatness_delay_modifier/modifier in H.fatness_delay_modifiers)
		fatness_delay *= modifier.multiplier
	fatness_delay = max(fatness_delay, 0)
	fatness_delay = min(fatness_delay, delay_cap)
	return fatness_delay

/mob/living/carbon/human/proc/handle_fatness()
	// handle_modular_items()
	var/mob/living/carbon/human/H = src
	// update movement speed
	var/fatness_delay = 0
	if(H.fatness && !HAS_TRAIT(H, TRAIT_NO_FAT_SLOWDOWN))
		fatness_delay = (H.fatness / FATNESS_DIVISOR)
		fatness_delay = min(fatness_delay, FATNESS_MAX_MOVE_PENALTY)

		if(HAS_TRAIT(H, TRAIT_STRONGLEGS))
			fatness_delay = fatness_delay * FATNESS_STRONGLEGS_MODIFIER

		if(HAS_TRAIT(H, TRAIT_WEAKLEGS))
			if(H.fatness <= FATNESS_LEVEL_IMMOBILE)
				fatness_delay += fatness_delay * FATNESS_WEAKLEGS_MODIFIER / 100
			if(H.fatness > FATNESS_LEVEL_IMMOBILE)
				fatness_delay += (H.fatness / FATNESS_LEVEL_IMMOBILE) * FATNESS_WEAKLEGS_MODIFIER
				fatness_delay = min(fatness_delay, 60)

	if(fatness_delay)
		fatness_delay = apply_fatness_speed_modifiers(fatness_delay)
		H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/fatness, TRUE, fatness_delay)
	else
		H.remove_movespeed_modifier(/datum/movespeed_modifier/fatness)

	if(HAS_TRAIT(H, TRAIT_BLOB))
		handle_fatness_trait(
			TRAIT_BLOB,
			TRAIT_IMMOBILE,
			null,
			FATNESS_LEVEL_BLOB,
			INFINITY,
			span_notice("You feel like you've regained some mobility!"),
			null,
			9)
		return
	if(HAS_TRAIT(H, TRAIT_IMMOBILE))
		handle_fatness_trait(
			TRAIT_IMMOBILE,
			TRAIT_BARELYMOBILE,
			TRAIT_BLOB,
			FATNESS_LEVEL_IMMOBILE,
			FATNESS_LEVEL_BLOB,
			span_notice("You feel less restrained by your fat!"),
			span_danger("You feel like you've become a mountain of fat!"),
			8)
		return
	if(HAS_TRAIT(H, TRAIT_BARELYMOBILE))
		handle_fatness_trait(
			TRAIT_BARELYMOBILE,
			TRAIT_EXTREMELYOBESE,
			TRAIT_IMMOBILE,
			FATNESS_LEVEL_BARELYMOBILE,
			FATNESS_LEVEL_IMMOBILE,
			span_notice("You feel less restrained by your fat!"),
			span_danger("You feel your belly smush against the floor!"),
			7)
		return
	if(HAS_TRAIT(H, TRAIT_EXTREMELYOBESE))
		handle_fatness_trait(
			TRAIT_EXTREMELYOBESE,
			TRAIT_MORBIDLYOBESE,
			TRAIT_BARELYMOBILE,
			FATNESS_LEVEL_EXTREMELY_OBESE,
			FATNESS_LEVEL_BARELYMOBILE,
			span_notice("You feel less restrained by your fat!"),
			span_danger("You feel like you can barely move!"),
			6)
		return
	if(HAS_TRAIT(H, TRAIT_MORBIDLYOBESE))
		handle_fatness_trait(
			TRAIT_MORBIDLYOBESE,
			TRAIT_OBESE,
			TRAIT_EXTREMELYOBESE,
			FATNESS_LEVEL_MORBIDLY_OBESE,
			FATNESS_LEVEL_EXTREMELY_OBESE,
			span_notice("You feel a bit less fat!"),
			span_danger("You feel your belly rest heavily on your lap!"),
			5)
		return
	if(HAS_TRAIT(H, TRAIT_OBESE))
		handle_fatness_trait(
			TRAIT_OBESE,
			TRAIT_VERYFAT,
			TRAIT_MORBIDLYOBESE,
			FATNESS_LEVEL_OBESE,
			FATNESS_LEVEL_MORBIDLY_OBESE,
			span_notice("You feel like you've lost weight!"),
			span_danger("Your thighs begin to rub against each other."),
			4)
		return
	if(HAS_TRAIT(H, TRAIT_VERYFAT))
		handle_fatness_trait(
			TRAIT_VERYFAT,
			TRAIT_FATTER,
			TRAIT_OBESE,
			FATNESS_LEVEL_VERYFAT,
			FATNESS_LEVEL_OBESE,
			span_notice("You feel like you've lost weight!"),
			span_danger("You feel like you're starting to get really heavy."),
			3)
		return
	if(HAS_TRAIT(H, TRAIT_FATTER))
		handle_fatness_trait(
			TRAIT_FATTER,
			TRAIT_ROUNDED,
			TRAIT_VERYFAT,
			FATNESS_LEVEL_FATTER,
			FATNESS_LEVEL_VERYFAT,
			span_notice("You feel like you've lost weight!"),
			span_danger("Your clothes creak quietly!"),
			2)
		return
	if(HAS_TRAIT(H, TRAIT_ROUNDED))
		handle_fatness_trait(
			TRAIT_ROUNDED,
			null,
			TRAIT_FATTER,
			FATNESS_LEVEL_FAT,
			FATNESS_LEVEL_FATTER,
			span_notice("You feel fit again!"),
			span_danger("You feel even plumper!"),
			1)
	else
		handle_fatness_trait(
			null,
			null,
			TRAIT_ROUNDED,
			0,
			FATNESS_LEVEL_FAT,
			null,
			span_danger("You suddenly feel blubbery!"),
			0)
