/datum/quirk/fat_affinity
	name = "Fat affinity"
	desc = "You like fat people, alot, maybe even a little bit too much. You are happier when fat, and having fat people around you will make you even happier!"
	icon = "fa-heart"
	value = 1
	quirk_flags = QUIRK_HIDE_FROM_SCAN | QUIRK_PROCESSES | QUIRK_MOODLET_BASED
	erp_quirk = FALSE // Disables on ERP config.
	mob_trait = TRAIT_FAT_GOOD
	var/mob/living/carbon/last_fatty
	var/highest_recorded_weight = 0

/datum/mood_event/fat_self
	description = span_nicegreen("I'm so fat!")
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/fat_other
	description = span_nicegreen("Someone around me is fat!")
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/very_fat_other
	description = span_nicegreen("Someone around me is ") + span_boldnicegreen("so") + span_nicegreen(" fat!")
	mood_change = 6
	timeout = 3 MINUTES

// COPY PASTING THE WELL TRAINED QUIRK LETS GOOOOOOOOOOOOOOOOOOOOOOOO

/datum/quirk/fat_affinity/process(seconds_per_tick)
	if(quirk_holder.stat == DEAD)
		return
	if(!TIMER_COOLDOWN_FINISHED(quirk_holder, FAT_AFFINITY_COOLDOWN)) // 15 second Early return
		return
	if(!quirk_holder)
		return

	var/mob/living/carbon/fatty_holder = quirk_holder

	if(iscarbon(quirk_holder) && fatty_holder.fatness > FATNESS_LEVEL_FATTER)
		quirk_holder.add_mood_event(TRAIT_FAT_GOOD_SELF, /datum/mood_event/fat_self)

	. = FALSE
	// handles calculating nearby fatties
	var/list/mob/living/carbon/fatties = viewers(world.view / 2, fatty_holder)
	var/highest_weight
	for(var/mob/living/carbon/fatty in fatties)
		if(fatty != fatty_holder) // ignore our player
			if(!highest_weight || fatty.fatness > highest_weight) // If original fatty is not fattest, set a new one
				. = fatty // set parent to new fatty
				highest_weight = fatty.fatness // set new highest weight
	if(!.) // If there's no fatty nearby
		last_fatty = null
		return
	
	if(last_fatty == .)
		if(last_fatty.fatness <= highest_recorded_weight)
			if(!TIMER_COOLDOWN_FINISHED(quirk_holder, SAME_FATTY_COOLDOWN))
				return

	last_fatty = . // Set new fatty and run new code
	highest_recorded_weight = highest_weight

	if (last_fatty.fatness < FATNESS_LEVEL_FATTER)
		TIMER_COOLDOWN_START(quirk_holder, FAT_AFFINITY_COOLDOWN, 15 SECONDS)
		return

	if (iscarbon(quirk_holder) && last_fatty.fatness <= fatty_holder.fatness)	// only get excited about other fatties when they're bigger than you. Otherwise what's the point?
		return

	var/list/notices = list(
		"You feel someone's softness making you excited.",
		"The thought of being smushed under someone's fat floods you with lust.",
		"You really want to snuggle in someone's rolls.",
		"Someone's weight is making you all flustered.",
		"You start getting excited and sweating."
	)

	if (last_fatty.fatness >= FATNESS_LEVEL_EXTREMELY_OBESE)
		quirk_holder.add_mood_event(TRAIT_FAT_GOOD, /datum/mood_event/very_fat_other)
	else
		quirk_holder.add_mood_event(TRAIT_FAT_GOOD, /datum/mood_event/fat_other)

	to_chat(quirk_holder, span_purple(pick(notices)))
	TIMER_COOLDOWN_START(quirk_holder, FAT_AFFINITY_COOLDOWN, 15 SECONDS)
	if (TIMER_COOLDOWN_FINISHED(quirk_holder, SAME_FATTY_COOLDOWN))
		S_TIMER_COOLDOWN_START(quirk_holder, SAME_FATTY_COOLDOWN, 1 MINUTES)
	else
		S_TIMER_COOLDOWN_RESET(quirk_holder, SAME_FATTY_COOLDOWN)
	// TIMER_COOLDOWN_START(fatty_holder, SAME_FATTY_COOLDOWN, 1 MINUTES)
