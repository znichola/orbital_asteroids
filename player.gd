extends RigidBody2D

signal hit
signal dead

var COLLISION_KILLABLE = true
var RELATIVE_ROT = true

var thrust = global.thrust
var rot = global.thrust
var ORBIT = true
var planet_pos = Vector2()

export (PackedScene) var bullet
export (PackedScene) var particles

var reload = 0.0

var old_angle = 0.0
var old_velo = Vector2()
var vec_offset = 35

func _ready():
	
	$outline.set_default_color(global.outlines)
	$fill.set_color(global.background)
	
	$collision.shape.points = $outline.points
	$fill.polygon = $outline.points
	
	#reload = $gun_timer.get_wait_time()
	reload = global.player_fire_rate
	$collision_timer.wait_time = global.player_colision_immunity_time
	
	rot *= mass
	thrust *= mass
	
	planet_pos = get_node("../planet").position
	
	
	$velocity_vec.points[0].x = vec_offset
	semi_circle($velocity_vec)

	$acceleration_vec.points[0].x = vec_offset
	semi_circle($acceleration_vec)
	
	collision_imune()
	pass

func semi_circle(parent):
	var circ = Line2D.new()
	circ.default_color = parent.default_color
	circ.width = parent.width
	var p = 5
	var a = PI/4 /p
	
	for i in p:
		#prints(i, a*floor(p/2) - i*a, a*floor(p/2), i*a)
		circ.add_point(Vector2(vec_offset, 0).rotated( a*floor(p/2) - i*a ) )
	circ.begin_cap_mode = 2
	circ.end_cap_mode = 2
	#circ.set_begin_cap_mode(LINE_CAP_ROUND)
	#circ.set_end_cap_mode(LINE_CAP_ROUND)
	parent.add_child(circ)

func pos(pos):
	position = pos
	pass

func shoot(velocity):
	if $gun_timer.time_left == 0:
		$shot_sfx.playing = true
		var b = bullet.instance()
		$bullets.add_child(b)
		b.start_at(global_rotation, 
					$muzzle.global_position, 
					velocity, 
					600)
		$gun_timer.wait_time = reload
		$gun_timer.start()
		#print("pew")	
		
func _integrate_forces(state):
	
	# acceleration and velocity vectors
	var accel = linear_velocity - old_velo
	$velocity_vec.rotation = linear_velocity.angle() - rotation
	$velocity_vec.points[1].x = linear_velocity.length() / 24 + vec_offset

	$acceleration_vec.rotation = accel.angle() - rotation
	$acceleration_vec.points[1].x = clamp(accel.length() * 2 + vec_offset, 0.0, 100.0)

	old_velo = linear_velocity

	
	if ORBIT and state.total_gravity.length() > 0:
		# give the object orbital velocity! 
		#print("jump in")
		ORBIT = false
		var r = planet_pos.distance_to(position)
		var v = sqrt(state.total_gravity.length()*r) * mass
		
		linear_velocity= Vector2(0.0, 0.0)
		apply_impulse(Vector2(0, 0), Vector2(v, 0.0).rotated(state.total_gravity.angle() + PI/2) )
		#print(linear_velocity, "  vel: ", v, "  radius: ", r)
		pass
	
	#trail
	if $g/trail_timer.time_left == 0:
		#print("appended", position)
		$g/trail.add_point(position)
		$g/trail_timer.start()
		$g/trail.set_draw_behind_parent(true) 
	while $g/trail.points.size() > 20:
		#print("removal")
		$g/trail.remove_point(0)
		$g/trail.set_draw_behind_parent(true) 
	$g/trail.set_point_position($g/trail.get_point_count()-1, position)
	
	var angle = get_angle_to(planet_pos)
	#var error = old_angle - error
	#prints(angle) 
	
	old_angle = angle
	
#	if Input.is_action_pressed("ui_down"):
#		apply_impulse(Vector2(0, 0), Vector2(thrust/-4, 0).rotated(rotation))
#		$reverse_exaust.emitting = true
#		$reverse_exaust2.emitting = true
		
	if Input.is_action_pressed("ui_up"):
		apply_impulse(Vector2(0, 0), Vector2(thrust, 0).rotated(rotation))
		$exaust.emitting = true
	if Input.is_action_just_pressed("ui_up"):
		$thruster_sfx.playing = true
	elif Input.is_action_just_released("ui_up"):
		$thruster_sfx.playing = false
		
	var dir =  int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if dir != 0:
		apply_impulse(Vector2(10, 0), Vector2(0, rot * dir))
		apply_impulse(Vector2(-10, 0), Vector2(0, rot * -dir))
	pass
	
	if Input.is_action_pressed("ui_select"):
		shoot(get_linear_velocity())

	# collision stuff
	for i in range(state.get_contact_count()):
		var impact_point = state.get_contact_local_position(i)
		var relative_vec = linear_velocity - state.get_contact_collider_velocity_at_position(i)
		var relative_vel = abs(relative_vec.length())
		
		var colision_body = state.get_contact_collider_object(i)
		# collison particles
		if $particles_timer.time_left == 0 and (colision_body.is_in_group("asteroids") or colision_body.is_in_group("planets")):
			var p = particles.instance()
			$particles_container.add_child(p)
			p.start_at(impact_point, 
						linear_velocity)
			$particles_timer.start()
		
		
		if ( (colision_body.is_in_group("asteroids") or colision_body.is_in_group("planets")) and
			COLLISION_KILLABLE and 
			relative_vel * (colision_body.mass + mass) > global.player_collision_energy):
			
			prints("collision energy", relative_vel * (colision_body.mass + mass))
			hit(state.get_contact_collider_object(i))
			#print("DEAD")

func hit(body):
	$collision_sfx.playing = true
	global.lives -= 1
	emit_signal("hit", body)
	print("I've been hit! ", global.lives, " left" )
	collision_imune()
	
	if global.lives <= -1:
		death(body)

func death(body):
	#depawning has to be controlled int he main mail this timer does nothing!	
#	$despawn_timer.start()
	print("despwn timer started")
	print("... and I'm dead")
	
	#global.lives = 3
	global.game_over = true
	$collision_sfx.playing = true
	emit_signal("dead", body)
#	yield($death_timer, "timeout")
	

func collision_imune():
	COLLISION_KILLABLE = false
	$collision_timer.start()
	$flashing_animation.play("flash")

func _on_timer_timeout():
	COLLISION_KILLABLE = true
	$flashing_animation.stop()
	pass # replace with function body


func _on_despawn_timer_timeout():
	#no we will controle this in the main file not here! 
	print("ship despawn timer over") 
	queue_free()
	pass # replace with function body
