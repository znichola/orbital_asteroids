extends RigidBody2D

signal explode
signal scored

var COLLISION_KILLABLE = false
var ORBIT = true

var planet_pos = Vector2()
var points_a
var scale_a
var spike_a

func _ready():
	$outline.set_default_color(global.outlines)
	$fill.set_color(global.background)
	
	# Called every time the node is added to the scene.
	# Initialization here
	#init(position, get_node("../planet").position, 13, 20, 0.9)
	#planet_pos = get_node("../planet").position
	
	#get_node("../planet").connect("exited_grav_well", self, "exited_grav_well")
	pass

func init(pos, plnt_pos, vel, pnts, scle, spke):
	planet_pos = plnt_pos
	points_a = pnts
	scale_a = scle
	spike_a = spke
	
	var shape = Array()
	var r = 0.0
	for i in pnts:
		r += 2*PI / pnts
		var rand = rand_range(scle, scle*(1+spke))
		var p = Vector2(rand, 0.0).rotated(r)
		shape.append(p)

	shape.append(shape[0])
	$outline.points = shape
	shape.pop_back()
	$fill.polygon = shape
	$collision.polygon = shape
	#print("test")
	position = pos
	angular_velocity = rand_range(-5, 5) 
	mass = scle # this stops the circularisation from working! 
					#maybe impuls needs to be scaled for mass? 
					# HA! its mass * velocity, dough!  
	if vel.length() > 0:
		linear_velocity = vel
		ORBIT = false
		pass
	
	#$collision.disabled = true

func _integrate_forces(state):
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
	
	for i in range(state.get_contact_count()):

		var impact_point = state.get_contact_local_position(i)
		var relative_vec = state.get_contact_collider_velocity_at_position(i) - linear_velocity
		var relative_vel = abs(relative_vec.length())
		#print(relative_vel)
#		if relative_vel > 100:
#			print("love tap")
			#collision(impact_point)
		var colision_body = state.get_contact_collider_object(i)
		if colision_body.is_in_group("bullets"):
			#print("what")
			explode(state.get_contact_collider_velocity_at_position(i))
			global.score += 1
			emit_signal("scored")
			pass
		if (colision_body.is_in_group("asteroids") and 
			COLLISION_KILLABLE and
			relative_vel * (colision_body.mass + mass)/mass  > global.asteroid_collision_energy):
			#print(relative_vel * (colision_body.mass + mass))
			explode(state.get_contact_collider_velocity_at_position(i))
			pass
		elif colision_body.is_in_group("planets"):
			queue_free()
		

func explode(collider_vel):
	emit_signal("explode", mass, position, linear_velocity, collider_vel)
	queue_free()

func out_of_bounds():
	queue_free()

#func exited_grav_well():
#	queue_free()



func _on_collision_imunity_timeout():
	#$collision.disabled = false
	COLLISION_KILLABLE = true
	pass # replace with function body
