extends Camera2D

var zoom_incraments = Vector2(0.05,0.05)
var zoomies = Vector2(0.05, 0.05)
var old_zoom = Vector2(0.0, 0.0)

var screen_extents = Vector2(800,600)
var view_rect = Rect2(Vector2(0,0), screen_extents)
var emission_box = Vector3(600,400,0)
func _ready():
	screen_extents = get_viewport().get_size()
	view_rect = Rect2(Vector2(0,0), get_viewport().get_size())
	emission_box = Vector3(screen_extents.x/0.8, screen_extents.y/0.8, 0.0)
	
	$vector_particles.set_visibility_rect(view_rect)
	$vector_particles.get_process_material().set_emission_box_extents(emission_box)
	
	pass

func _process(delta):
	
#	if(Input.is_action_pressed("zoom_in") or Input.is_action_pressed("ui_page_up") and zoom.x >= 0.1):
#		zoom -= zoomies
#		$vector_particles.get_process_material().scale -= zoomies.x
#		print("zooming", zoom)
#	elif(Input.is_action_pressed("zoom_out") or Input.is_action_pressed("ui_page_down") ):
#		zoom += zoomies
#		$vector_particles.get_process_material().scale += zoomies.x
#		print("zooming")
	
	#clamp(zoom, Vector2(0.1,0.1), Vector2(10.0,10.0)) # does not work
	
	rotate( get_angle_to(get_node("../../planet").position) - PI/4 )
#	var d_zoom = zoom - old_zoom 
#	zoomies = ( d_zoom.abs() + Vector2(1.0, 1.0) ) * zoom_incraments
#	old_zoom = zoom
	
func _input(event):
    # Wheel Up Event
    if event.is_action_pressed("zoom_in") and zoom.x >= 0.1:
        #print("zoom in")
        _zoom_camera(-1)
    # Wheel Down Event
    elif event.is_action_pressed("zoom_out"):
        #print("zoom out")
        _zoom_camera(1)

# Zoom Camera
func _zoom_camera(dir):
	zoom += zoomies * dir
	$vector_particles.get_process_material().scale = (dir * 
			$vector_particles.get_process_material().scale + zoomies.x)
	
