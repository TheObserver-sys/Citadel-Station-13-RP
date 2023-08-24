//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator2.dmi'
	icon_state = "particle1"//Need a new icon for this
	anchored = 1
	density = 1
	var/movement_range = 10
	var/energy = 10		//energy in eV
	var/mega_energy = 0	//energy in MeV
	var/frequency = 1
	var/ionizing = 0
	var/particle_type
	var/additional_particles = 0
	var/turf/target
	var/turf/source
	var/movetotarget = 1

/obj/effect/accelerated_particle/weak
	icon_state = "particle0"
	movement_range = 8
	energy = 5

/obj/effect/accelerated_particle/strong
	icon_state = "particle2"
	movement_range = 15
	energy = 15

/obj/effect/accelerated_particle/powerful
	icon_state = "particle3"
	movement_range = 25
	energy = 50

/obj/effect/accelerated_particle/reverse
	icon_state = "particle3"
	movement_range = 15
	energy = -20

/obj/effect/accelerated_particle/Initialize(mapload, dir = SOUTH)
	. = ..()
	src.loc = loc
	src.setDir(dir)
	INVOKE_ASYNC(src, PROC_REF(move), 1)

/obj/effect/accelerated_particle/Moved()
	. = ..()
	if(!isturf(loc))
		return
	for(var/atom/movable/AM as anything in loc.contents)
		do_the_funny(AM)

/obj/effect/accelerated_particle/proc/do_the_funny(atom/A)
	if (A)
		if(ismob(A))
			toxmob(A)
		if((istype(A,/obj/machinery/the_singularitygen))||(istype(A,/obj/singularity/))||(istype(A, /obj/machinery/particle_smasher)))
			A:energy += energy
		//R-UST port
		else if(istype(A,/obj/machinery/power/fusion_core))
			var/obj/machinery/power/fusion_core/collided_core = A
			if(particle_type && particle_type != "neutron")
				if(collided_core.AddParticles(particle_type, 1 + additional_particles))
					collided_core.owned_field.plasma_temperature += mega_energy
					collided_core.owned_field.energy += energy
					loc = null
		else if(istype(A, /obj/effect/fusion_particle_catcher))
			var/obj/effect/fusion_particle_catcher/PC = A
			if(particle_type && particle_type != "neutron")
				if(PC.parent.owned_core.AddParticles(particle_type, 1 + additional_particles))
					PC.parent.plasma_temperature += mega_energy
					PC.parent.energy += energy
					loc = null


/obj/effect/accelerated_particle/legacy_ex_act(severity)
	qdel(src)

/obj/effect/accelerated_particle/singularity_act()
	return

/obj/effect/accelerated_particle/proc/toxmob(var/mob/living/M)
	if(!istype(M))
		return
	M.afflict_radiation(energy * 5, TRUE)

/obj/effect/accelerated_particle/proc/move(var/lag)
	var/turf/new_target
	if(target)
		if(movetotarget)
			new_target = get_step_towards(src, target)
			if(get_dist(src,new_target) < 1)
				movetotarget = 0
		else
			new_target = get_step_away(src, source)
	else
		new_target = get_step(src, dir)
	if(new_target)
		forceMove(new_target)
	else
		qdel(src)
		return
	movement_range--
	if(movement_range <= 0)
		qdel(src)
	else
		sleep(lag)
		move(lag)
