extends Node

var HOME_SCREEN = true
var INSAIN_MODE = false

var spawn_score_freq = 5

var thrust = 10
var rot = 10

var starting_lives = 3
var lives = 3
var game_over = false
var score = 0
var paused = false
var screen_size = Vector2()
var player_collision_energy = 1800
var player_fire_rate = 0.3
var player_colision_immunity_time = 0.8

#asteroid stuff
var asteroid_collision_energy = 8000 
var explosiveness = 2500 # the speed at which the asteroids explode
var exlosion_split_fac = 2 #number of shild asteroids
var minimum_mass = 8
var mass_split = 0.5	#the % of mass the spawned asteroids take from the parent

var outlines = "f4eaea"
var background = "0d0d0d"

func _ready():
	screen_size = get_viewport().size
	#insain_mode()
	pass

func insain_mode():
	if not INSAIN_MODE:
		exlosion_split_fac = 4
		minimum_mass = 6
		mass_split = 0.6
		explosiveness = 2800
		player_fire_rate = 0.1
		player_colision_immunity_time = 3.8
		player_collision_energy = 3800
		INSAIN_MODE = true
		
	else: 
		exlosion_split_fac = 2
		minimum_mass = 8
		mass_split = 0.5
		explosiveness = 2500
		player_fire_rate = 0.3
		player_colision_immunity_time = 0.8
		player_collision_energy = 1800
		INSAIN_MODE = false

func new_game():
	game_over = false
	score = 0
	lives = 3
	#goto_scene("res:/main.tscn")