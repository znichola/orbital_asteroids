extends RigidBody2D
#var DEAD = false
var vel = Vector2(0,0)
#export var speed = 1000
#var DEAD = false

func _ready():
	set_friction(false)
	#set_gravity_scale(0.0)
	set_mass(0.1)
	set_linear_damp(0)
	set_angular_damp(0)
	#scale = Vector2(0.3,0.3)
	#$bullet.scale = Vector2(0.3,0.3)
	#$collision_shape.scale = Vector2(0.3,0.3)
	$collision_shape.visible
	
func start_at(rot, pos, vel, speed):
	rotation = rot
	position = pos
	linear_velocity = Vector2(speed, 0).rotated(rot) + vel
	$collision_shape.disabled = false
	
func _integrate_forces(state):
	
	for i in range(state.get_contact_count()):
		#print("bullet hit")
		$hit.emitting = true
		$lifetime.wait_time = $hit.lifetime
		$line.visible = false
		#continuous_cd = CCD_MODE_DISABLED
		$collision_shape.disabled = true
		
		#set_collision_mask_bit( 1, true)
		#set_collision_mask_bit( 0, false)
		angular_velocity = 0.0
		#linear_velocity = state.get_contact_collider_velocity_at_position()
		
#func _physics_process(delta):
#	#position += vel * delta
#	pass

func _on_lifetime_timeout():
	#print("dead bulllet")
	queue_free()
