extends Node

var player    = preload("res://src/player/player.tscn")
var ground    = preload("res://src/scenes/ground.tscn")
var pipe      = preload("res://src/entities/pipe.tscn")
var game_over_button = preload("res://src/scenes/game_over.tscn")
@onready var death_sound = $Sounds/DeathSound
@onready var score_audio = $Sounds/ScoreAudio
@onready var hit_sound = $Sounds/HitPipe

var game_running: bool
var game_over: bool
var sound_has_played: bool = false
var scroll
var score
const SCROLL_SPEED: int = 4
var screen_size: Vector2i
var ground_height: int
var pipes: Array
const PIPE_DELAY: int = 100
const PIPE_RANGE: int = 200


## Main functions
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	# Instantiates the scenes
	inst_player()
	inst_pipes()
	inst_ground()
	# Starts the game
	new_game()

# Called continuously in the process
func _process(delta: float) -> void:
	if game_running:
		scroll += SCROLL_SPEED
		# Reset scroll
		if scroll >= screen_size.x:
			scroll = 0
		# Move ground node
		$Ground.position.x = -scroll
		# Move pipes
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

## Separate Functions

func new_game():
	# Reset Variables
	game_running = false
	game_over = false
	sound_has_played = false
	score = 0
	scroll = 0
	$Hud/Score.text = "SCORE: " + str(score)
	$GameOver.hide()
	get_tree().call_group("player", "queue_free")
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	$Player.reset()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if  $Player.flying:
						$Player.flap()
						check_top()
						
# Starts the game
func start_game():
	game_running = true
	$Player.flying = true
	$Player.flap()
	# Start pipe timer
	$Systems/PipeTimer.start()

# Instantiates the player
func inst_player():
	var player_instance = player.instantiate()
	add_child(player_instance)

# Instantiates the ground
func inst_ground():
	var ground_instance = ground.instantiate()
	ground_height = ground_instance.get_node("Sprite2D").texture.get_height()
	ground_instance.hit.connect(bird_hit_ground)
	add_child(ground_instance)

# Instantiates the pipes
func inst_pipes():
	var pipe_instance = pipe.instantiate()
	pipe_instance.position.x = screen_size.x + PIPE_DELAY
	pipe_instance.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe_instance.hit.connect(bird_hit_pipe)
	pipe_instance.score.connect(scored)
	add_child(pipe_instance)
	pipes.append(pipe_instance)
	

func stop_game():
	$Systems/PipeTimer.stop()
	$GameOver.show()
	$Player.flying = false
	game_running = false
	game_over = true

func check_top():
	if $Player.position.y < 0:
		$Player.falling = true
		stop_game()
		
func scored():
	score += 1
	# Plays the score audio
	score_audio.play()
	$Hud/Score.text = "SCORE: " + str(score)

func bird_hit_pipe():
	$Player.falling = true
	# Plays the hit pipe sound only ONCE
	if !sound_has_played:
		sound_has_played = true
		hit_sound.play()
	# Plays the death sound only ONCE
	if !sound_has_played:
		sound_has_played = true
		death_sound.play()
	stop_game()
	
func bird_hit_ground():
	$Player.falling = false
	stop_game()

func _on_pipe_timer_timeout() -> void:
	inst_pipes()

func _on_game_over_restart() -> void:
	new_game()
