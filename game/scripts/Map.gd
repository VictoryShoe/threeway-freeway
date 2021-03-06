extends Node2D

# Game parameters
var obstacle_interval = 1000 # Higher is easier
var difficulty_scale = 0.6 # Lower is harder
var level_1 = 500
var level_2 = 1000
var level_3 = 2000
var level_4 = 4000
var level_5 = 10000

# Nodes
onready var player = get_node("Player")
onready var back1 = get_node("Background1")
onready var back2 = get_node("Background2")

# References
var screen_size = Vector2(Globals.get("display/width"), Globals.get("display/height"))
var obstacle1 = preload("res://scenes/Obstacle1.tscn")
var obstacle2 = preload("res://scenes/Obstacle2.tscn")
var player_pos
var last_pos
var initial_pos
var top_of_screen
var bottom_of_screen

onready var back1_pos = back1.get_pos()
onready var back2_pos = back2.get_pos()
onready var back1_height = back1.get_texture().get_height()
onready var back1_width = back1.get_texture().get_width()
	
func _ready():
	var rhythm_node = get_node("RhythmManager")
	rhythm_node.connect("role_switch", self, "role_switch_handler")
	rhythm_node.connect("beat", self, "beat_handler")
	
	global.current_distance = 0
	global.distance_from_line = 0
	
	# Debug
	print("X: ", screen_size.x, " Y:", screen_size.y)
	print("Player pos: ", player.get_global_pos())
	
	# Set initial player position for obstacle generation
	player_pos = player.get_global_pos()
	top_of_screen = player_pos.y - (screen_size.y / 2)
	bottom_of_screen = player_pos.y + (screen_size.y / 2)
	last_pos = player_pos
	initial_pos = player_pos
	
	# Set background images dynamically
		
	back1.set_global_pos(Vector2(screen_size.x / 2, back1_height * 1.5))
	back2.set_global_pos(Vector2(screen_size.x / 2, back1_height * 0.5))
	
	set_process(true)

func _process(delta):
	global.current_distance = abs(player_pos.y - initial_pos.y)
	global.distance_from_line = abs(player_pos.y - get_node("Death Wall").get_global_pos().y)
	
	player_pos = player.get_global_pos()
	var left_limit = screen_size.x / 2 - back1_width / 2
	var right_limit = screen_size.x / 2 + back1_width / 2
	if player_pos.x < left_limit:
		player.set_global_pos(Vector2 (left_limit, player_pos.y))
	if player_pos.x > right_limit:
		player.set_global_pos(Vector2 (right_limit, player_pos.y))
		
	# Current camera and screen positions
	top_of_screen = player_pos.y - (screen_size.y / 2)
	bottom_of_screen = player_pos.y + (screen_size.y / 2)
	
	# Generate infinite road background image
	if back1_pos.y > bottom_of_screen + back1_height / 2:
		print("Moving Background1")
		back1_pos.y = back1_pos.y - (2 * back1_height)
	if back2_pos.y > bottom_of_screen + back1_height / 2:
		print("Moving Background2")
		back2_pos.y = back2_pos.y - (2 * back1_height)
		
	get_node("Background1").set_pos(back1_pos)
	get_node("Background2").set_pos(back2_pos)
	

func role_switch_handler(r1, r2, r3):
	get_node("HUD").role_switch_handler(r1, r2, r3)
	get_node("Player").role_switch_handler(r1, r2, r3)

func beat_handler(beat_cnt):
	get_node("HUD").beat_handler(beat_cnt)

func random_1_to_10():
	randomize()
	return randi()%11+1

func generate_obstacles(num, type):
	if type == "unbreakable":
		for i in range(num):
			var obstacle = obstacle1.instance()
			randomize()
			obstacle.set_pos(Vector2((back1_width * randf()) + (screen_size.x / 2 - back1_width / 2), top_of_screen - 100))
			add_child(obstacle)
	elif type == "breakable":
		for i in range(num):
			var obstacle = obstacle2.instance()
			randomize()
			obstacle.set_pos(Vector2((back1_width * randf()) + (screen_size.x / 2 - back1_width / 2), top_of_screen - 100))
			add_child(obstacle)
	elif type == "mixed":
		for i in range(num):
			var obstacle
			if random_1_to_10() > 5:
				obstacle = obstacle1.instance()
			else:
				obstacle = obstacle2.instance()	
			obstacle.set_pos(Vector2((back1_width * randf()) + (screen_size.x / 2 - back1_width / 2), top_of_screen - 100))
			add_child(obstacle)

func _on_Player_move():

	# Generate obstacles based on distance of player
	# Use function to generate pre-loaded instance of obstacle
	# at a random x-coord along screen dimensions
	
	var current_pos = player_pos
	
	if current_pos.y > -level_1:
		if (last_pos.y - current_pos.y > obstacle_interval):
			# Generate new obstacle
			generate_obstacles(1, "unbreakable")
			# Set last_pos to current_pos
			last_pos = current_pos
	elif current_pos.y > -level_2:
		if (last_pos.y - current_pos.y > obstacle_interval * difficulty_scale):
			if random_1_to_10() > 7:
				generate_obstacles(2, "breakable")
			else:
				generate_obstacles(1, "unbreakable")
			last_pos = current_pos
	elif current_pos.y > -level_3:
		if (last_pos.y - current_pos.y > obstacle_interval * difficulty_scale):
			if random_1_to_10() > 7:
				generate_obstacles(3, "mixed")
			else:
				generate_obstacles(2, "unbreakable")
			last_pos = current_pos
	elif current_pos.y > -level_4:
		if (last_pos.y - current_pos.y > obstacle_interval * pow(difficulty_scale, 2)):
			generate_obstacles(4, "mixed")
			last_pos = current_pos
	elif current_pos.y > -level_5:
		if (last_pos.y - current_pos.y > obstacle_interval * pow(difficulty_scale, 2)):
			if random_1_to_10() > 4:
				generate_obstacles(6, "mixed")
			else:
				generate_obstacles(4, "unbreakable")
			last_pos = current_pos
	else:
		if (last_pos.y - current_pos.y > obstacle_interval * pow(difficulty_scale, 3)):
			var num = random_1_to_10()
			if num > 7:
				generate_obstacles(20, "breakable")
			elif num > 3:
				generate_obstacles(6, "mixed")
			else:
				generate_obstacles(4, "unbreakable")
			last_pos = current_pos
