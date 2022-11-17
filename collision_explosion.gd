extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_friction(false)
	#set_gravity_scale(0.0)
	set_mass(0.1)
	set_linear_damp(0)
	set_angular_damp(0)
	pass

func start_at(pos, vel):
	position = pos
	linear_velocity = vel
	$particles.emitting = true
	$lifetime.start()

func _on_lifetime_timeout():
	queue_free()

