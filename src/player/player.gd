extends CharacterBody2D

@onready var audio = $AudioStreamPlayer2D

const GRAVITY    : int = 1000
const MAX_VEL    : int = 600
const FLAP_SPEED : int = -500
var flying : bool = false
var falling : bool = false
const START_POS : Vector2 = Vector2(100, 400)

func _ready():
	reset()
	
func reset():
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)
	

func _physics_process(delta: float) -> void:
	if flying or falling:
		velocity.y += GRAVITY * delta
		# Terminal Velocity
		if velocity.y > MAX_VEL:
			velocity.y = MAX_VEL
		if flying:
			set_rotation(deg_to_rad(velocity.y * 0.05))
			$Flappy.play("flying")
		elif falling:
			set_rotation(PI/2)
			$Flappy.stop()
		move_and_collide(velocity * delta)
	else: 
		$Flappy.stop()
		
func flap():
	velocity.y = FLAP_SPEED
	audio.play()
	
		
		
