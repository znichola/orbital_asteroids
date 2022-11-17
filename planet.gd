#tool # this makes the script run in the main scene window. no need to load game to see effects
extends RigidBody2D
signal exited_well

export var planet_radius = 60.0
export var grav_well_radius = 2000.0

func _ready():
	$outline.set_default_color(global.outlines)
	$fill.set_color(global.background)
	
	$planet.get_shape().radius = planet_radius
	$grav_well/shape.get_shape().radius = grav_well_radius
	
	var verts = 24
	var rot = 0.0
	var shape = Array()
	for i in verts:
		var p = Vector2(planet_radius, 0.0).rotated(rot)
		rot += 2*PI/verts
		shape.append(p)
	shape.append(shape[0])
	$outline.points = shape
	$fill.polygon = shape
	
	
	$clouds.scale = $clouds.scale * planet_radius/10
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

#func _on_grav_well_body_exited(body):
#	#emit_signal("exited_grav_well")
#	print("_on_grav_well_body_exited")

func release():
	$grav_well.gravity = 500

func reset():
	$grav_well.gravity = 1024

func _on_grav_well_body_exited(body):
	if !body.is_in_group("bullets"):
		emit_signal("exited_well", body)
		body.queue_free()
		#prints(body, "exited well")
	pass # replace with function body
