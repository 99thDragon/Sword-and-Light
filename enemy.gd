extends CharacterBody2D

var current_action = "attack"
var health = 100
var is_player_turn = false
var is_charged = false
var ai_system = null

@onready var idle_sprite = $IdleSprite
@onready var attack_sprite = $AttackSprite
@onready var charge_sprite = $ChargeSprite

func _ready():
	print("Enemy script is ready.")
	print("Enemy health:", health)
	
	# Initialize AI system
	ai_system = load("res://enemy_ai.gd").new()
	add_child(ai_system)
	
	# Start with idle animation
	idle_sprite.visible = true
	attack_sprite.visible = false
	charge_sprite.visible = false
	idle_sprite.play("default")
	
	# Flip all sprites horizontally
	idle_sprite.flip_h = true
	attack_sprite.flip_h = true
	charge_sprite.flip_h = true
	
	# Make sure idle animation loops
	idle_sprite.sprite_frames.set_animation_loop("default", true)
	# Make sure attack and charge animations don't loop
	attack_sprite.sprite_frames.set_animation_loop("default", false)
	charge_sprite.sprite_frames.set_animation_loop("default", false)

func take_turn():
	print("Enemy takes its turn.")
	
	# Get player reference
	var player = get_parent().get_node("Player")
	if not player:
		return
	
	# Get AI decision
	current_action = ai_system.decide_action(health, player.health)
	
	# Get AI state description
	var state_desc = ai_system.get_state_description()
	if state_desc:
		print(state_desc)
	
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
		if is_charged:
			print("Charged attack!")
			is_charged = false
			
	elif action == "defend":
		print("Enemy defends!")
		# Add visual feedback for defense
		modulate = Color(0.5, 0.5, 1.0)  # Slight blue tint
		await get_tree().create_timer(0.5).timeout
		modulate = Color(1, 1, 1)  # Reset color
		
	elif action == "charge":
		print("Enemy charges up!")
		is_charged = true
		# Switch to charge animation
		idle_sprite.visible = false
		charge_sprite.visible = true
		charge_sprite.play("default")
		await charge_sprite.animation_finished
		# Return to idle animation
		charge_sprite.visible = false
		idle_sprite.visible = true
		idle_sprite.play("default")
