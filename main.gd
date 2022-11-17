extends Node

# TODO:
#		negative score for asteroid planet impact
#		make explode/damage threshhold be relative to mass.
#
#		change asteroids init so it only uses one scale value
#			set so number of pints and size are related
#			perhaps with a linear relationship? 
#			no i think its more a log thing. 


# Sound; shooting, hits, point scored, maybe background music
# A proper menu system, with controls, and insane mode toggle/check box
# In relative mode the player acts like its rotating by its self. That's an illusion, it's just rotating relative to the plant. I would need to calculate it's orbital period then apply rotation impulses so it matches. I think this could take a fair bit of time so unsure if its worth it.
# Proper difficultly; it's too easy to just fly high above the planet and shoot from there.
# Leader board with three letter names; would need to be persistent between games.
# anything more?


export (PackedScene) var asteroid
export (PackedScene) var player

var screen_extents = Vector2(0.0, 0.0)
var old_score = 0.0

func _ready():
	randomize() #randomises the starting seed
	#$player.connect("hit", self, "update_lives")
	#$player.connect("dead", self, "game_over")
	screen_extents = get_viewport().size 
	#asteroids(6)
	#start_level(6)
	$HUD.connect("start_game", self, "start_game")
	start_level(8)
	$HUD.start_game()
	get_tree().get_root().connect("size_changed", self, "resize")
	
func _process(delta):
	if Input.is_action_just_pressed("insain"):
		global.insain_mode()
		global.lives = -1
		print(get_children())
		print("insaine mode ", global.INSAIN_MODE)

func spawn_asteroids(size, points, pos, vel):
	var a = asteroid.instance()
	a.connect("explode", self, "explode_asteroid")
	a.connect("scored", self, "update_score")
	#func init(pos, plnt_pos, vel, pnts, scle, spke):
	a.init(pos, 
			$planet.position,
			vel, 
			points,
			size, 
			0.9)
	$asteroids.add_child(a)
	pass

func update_score():
	$HUD.update_score(global.score)

func update_lives(body):
	print("here hit by ", body)
	$HUD.update_lives(global.lives)

func game_over(body):
	$level_reset_timer.start()
	$planet/planet_cam/vector_parts.visible = true
	global.lives = 0
	$HUD.update_lives(global.lives)
	$HUD.show_game_over()
	$planet/planet_cam.current = true
	$planet.release()
	pass

#	reset_level()
	#yield($gameover_timer, "timeout")
#	remove_nodes($asteroids)
#	$player.queue_free()
##	var node = Node.new()
##	node.set_name("asteroids")
##	add_child(node)
#
#	$HUD.start_game()
#	$planet.reset()
#	start_level(3) 
	pass

func reset_level():
	remove_nodes($asteroids)
#	var node = Node.new()
#	node.set_name("asteroids")
#	add_child(node)

	$HUD.start_game()
	$planet.reset()
	start_level(8)

func remove_nodes(node):
	for N in node.get_children():
		N.queue_free()
		#else:
		#	print("- "+N.get_name())

func start_game():
	$planet/planet_cam/vector_parts.visible = false
	var p = player.instance()
	p.connect("hit", self, "update_lives")
	p.connect("dead", self, "game_over")
	self.add_child(p)
	p.pos(Vector2(rand_range( screen_extents.x/2 - 500, screen_extents.x/2 + 500), 
					rand_range( screen_extents.y/2 - 500, screen_extents.y/2 + 500)))
	pass

func start_level(asteroid_num):
	global.score = 0
	global.lives = global.starting_lives
	$HUD.update_score(global.score)
	$HUD.update_lives(global.lives)
	$HUD/message_timer.start()
	
	for i in asteroid_num:
		var p = Vector2(randi() % int(screen_extents.x/1.5), randi() % int(screen_extents.y/1))
		spawn_asteroids(rand_range(12, 32),
						int(rand_range(8,10)),
						p,
						Vector2(0,0))

func explode_asteroid(mass, pos, vel, collider_vel):
	#prints(mass, pos, vel, collider_vel)

	var slpt_fac = global.exlosion_split_fac
	if mass < global.minimum_mass:
		return
	for i in slpt_fac:
		spawn_asteroids(mass*global.mass_split, 
					int(rand_range(5,7)), 
					pos, 
					vel + Vector2(global.explosiveness/mass,0).rotated(2*PI/slpt_fac * i))
					#vel + Vector2(collider_vel.length()*0.02*mass,0).rotated(2*PI/slpt_fac * i))
	pass

func asteroids(asteroid_num):
	for i in asteroid_num:
		var a = asteroid.instance()
		$asteroids.add_child(a)
		
		#var p = Vector2(rand_range(0, screen_extents.x), rand_range(0, screen_extents.y))
#		var p = Vector2()
#		var FLG = true
#
#		while FLG:
#			FLG = false
#			p = Vector2(int(rand_range(0, screen_extents.x/10)), int(rand_range(0, screen_extents.y/10)))
#			p = p * 10
#			prints("sm", p)
#			for i in $asteroids.get_children():
#				prints("asd",i.position.distance_to(p))
#				if i.position.distance_to(p) > 100:
#					FLG = true
#		print(p)
		var p = Vector2(randi() % int(screen_extents.x/1.5), randi() % int(screen_extents.y/1))
		
		prints("position", p)
		a.init(p, 
				$planet.position,
				Vector2(0,0), 
				int(rand_range(8,13)),
				rand_range(12, 24), 
				0.9)
		pass
	
	pass

func _on_asteroid_spawn_timer_timeout():
	if global.score > old_score + global.spawn_score_freq:
		var p = Vector2(randi() % int(screen_extents.x/1.5), randi() % int(screen_extents.y/1))
		spawn_asteroids(rand_range(12, 32),
						int(rand_range(8,10)),
						p,
						Vector2(0,0))
		print("new spawn")
		old_score = global.score
	pass # replace with function body

func resize():
	#print("Resizing: ", get_viewport_rect().size)
	screen_extents = get_viewport().size
	$HUD.center()
	

func _on_background_sfx_finished():
	$background_sfx.play()
	pass # replace with function body


func _on_level_reset_timer_timeout():
	print($player)
	$player.queue_free()
	reset_level()
	
	pass # replace with function body
