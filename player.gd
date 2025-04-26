extends CharacterBody2D

var current_action = "attack"
var is_player_turn = false
var health = 100  # Player starts with 100 health
var is_charged = false  # Track if player is charged

@onready var idle_sprite = $IdleSprite
@onready var attack_sprite = $AttackSprite

func _ready():
	print("Player script is ready.")
	print("Player health:", health)
	# Start with idle animation
	idle_sprite.visible = true
	attack_sprite.visible = false
	idle_sprite.play("default")
	
	# Make sure idle animation loops
	idle_sprite.sprite_frames.set_animation_loop("default", true)
	# Make sure attack animation doesn't loop
	attack_sprite.sprite_frames.set_animation_loop("default", false)

func _process(_delta):
	if is_player_turn and Input.is_action_just_pressed("ui_accept"):  # Space bar
		perform_action(current_action)

func perform_action(action):
	if not is_player_turn:
		return
		
	if action == "attack":
		# Switch to attack animation
		idle_sprite.visible = false
		attack_sprite.visible = true
		attack_sprite.play("default")
		await attack_sprite.animation_finished
		# Return to idle animation
		attack_sprite.visible = false
		idle_sprite.visible = true
		idle_sprite.play("default")
		
		print("Player attacks!")
		if is_charged:
			print("Charged attack!")
			is_charged = false
		
	elif action == "defend":
		print("Player defends!")
		
	elif action == "charge":
		print("Player charges up!")
		is_charged = true
		
	# End turn after performing action
	is_player_turn = false
	get_parent().end_player_turn()

func end_turn():
	is_player_turn = false
	print("Player ends turn.")
