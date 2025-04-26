extends CharacterBody2D

var current_action = "attack"
var health = 100  # Changed from 50 to 100 to match player
var is_player_turn = false

@onready var idle_sprite = $IdleSprite
@onready var attack_sprite = $AttackSprite

func _ready():
	print("Enemy script is ready.")
	print("Enemy health:", health)
	# Start with idle animation
	idle_sprite.visible = true
	attack_sprite.visible = false
	idle_sprite.play("default")
	
	# Flip both sprites horizontally
	idle_sprite.flip_h = true
	attack_sprite.flip_h = true
	
	# Make sure idle animation loops
	idle_sprite.sprite_frames.set_animation_loop("default", true)
	# Make sure attack animation doesn't loop
	attack_sprite.sprite_frames.set_animation_loop("default", false)

func take_turn():
	print("Enemy takes its turn.")
	# Randomly choose between attack and defend
	var random_choice = randi() % 2  # This will give us 0 or 1
	if random_choice == 0:
		current_action = "attack"
	else:
		current_action = "defend"
	
	perform_action(current_action)

func perform_action(action):
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
		
		print("Enemy attacks!")
		# In the future, we'll add damage calculation here
	elif action == "defend":
		print("Enemy defends!")
		# In the future, we'll add defense logic here
