# enemy.gd (Attached to the root Enemy node in Enemy.tscn)
extends Node2D

var current_actor = "player"  # Track the current active character
var turn_number = 1          # Track the current turn number
var player_damage = 10       # Amount of damage player deals
var enemy_damage = 10        # Changed from 5 to 10 to match player
var game_over = false        # Track if the game has ended
var last_player_action = ""  # Track the last player action

# Combat mechanics
var defense_bonus = 0.5  # Damage reduction when defending
var charge_multiplier = 2.0  # Damage multiplier for charged attacks
var consecutive_attack_penalty = 0.2  # Damage reduction for consecutive attacks
var player_consecutive_attacks = 0
var enemy_consecutive_attacks = 0

# AI Learning Display
var learning_display = null
var last_ai_state = ""
var last_ai_style = ""

# Performance Monitoring
var performance_monitor = null
var last_performance_check = 0
var performance_check_interval = 5.0  # Check every 5 seconds

var ui = null

func _ready():
	print("Combat scene is ready.")
	# Try to get the UI node
	ui = get_node_or_null("CombatUI")
	if ui:
		print("UI found")
	else:
		print("UI not found - some features will be disabled")
	
	# Set up the background
	var background = $Background
	if background:
		# Make sure background is behind everything
		background.z_index = -1
		# Center the background
		background.position = Vector2(0, 0)
	
	# Set up the camera
	var camera = $Camera2D
	if camera:
		# Center the camera horizontally, but move it down a bit
		camera.position = Vector2(0, 50)  # Moved down by 50 pixels
		# Make sure it's the current camera
		camera.make_current()
	
	# Position the player and enemy
	var player = get_node("Player")
	if player:
		player.position = Vector2(-100, 100)  # Left side, lower position
	
	var enemy = get_node("Enemy")
	if enemy:
		enemy.position = Vector2(100, 100)  # Right side, lower position
	
	# Set up performance monitoring
	performance_monitor = get_node_or_null("PerformanceMonitor")
	if performance_monitor:
		print("Performance monitoring active")
		performance_monitor.start_combat()
	
	start_player_turn()

func _process(delta):
	# Check performance periodically
	if performance_monitor:
		last_performance_check += delta
		if last_performance_check >= performance_check_interval:
			performance_monitor.print_performance_metrics()
			last_performance_check = 0

func start_player_turn():
	if game_over:
		return
		
	print("\nTurn", turn_number, "- Player's turn")
	var player = get_node("Player")
	if player:
		player.is_player_turn = true
		print("Waiting for player input...")
		if ui:
			ui.add_combat_log("Player's turn")
			performance_monitor.record_ui_action()

func start_enemy_turn():
	if game_over:
		return
		
	print("\nTurn", turn_number, "- Enemy's turn")
	var enemy = get_node("Enemy")
	if enemy:
		# Update enemy AI with last player action
		if enemy.ai_system:
			performance_monitor.start_ai_decision()
			enemy.ai_system.last_player_action = last_player_action
			
			# Display AI learning information
			var current_state = enemy.ai_system.get_state_description()
			if current_state != last_ai_state:
				if ui:
					ui.add_combat_log(current_state)
				last_ai_state = current_state
			
			# Display player style analysis
			var style_info = get_player_style_info(enemy.ai_system.player_style)
			if style_info != last_ai_style:
				if ui:
					ui.add_combat_log(style_info)
				last_ai_style = style_info
			
			performance_monitor.end_ai_decision()
		
		enemy.take_turn()
		
		# If enemy chose to attack, deal damage to player
		if enemy.current_action == "attack":
			var player = get_node("Player")
			if player:
				var damage = enemy_damage
				
				# Apply charge multiplier if charged
				if enemy.is_charged:
					damage *= charge_multiplier
					if ui:
						ui.add_combat_log("Enemy uses charged attack! Double damage!")
				
				# Apply consecutive attack penalty
				if enemy_consecutive_attacks > 0:
					damage *= (1.0 - (consecutive_attack_penalty * enemy_consecutive_attacks))
					if ui:
						ui.add_combat_log("Enemy's attack is weakened from repetition!")
				
				# Apply defense reduction if player defended
				if last_player_action == "defend":
					damage *= (1.0 - defense_bonus)
					if ui:
						ui.add_combat_log("Player's defense reduces the damage!")
				
				player.health -= damage
				print("Enemy deals", damage, "damage!")
				print("Player health:", player.health)
				if ui:
					ui.update_player_health(player.health)
					ui.add_combat_log("Enemy attacks for " + str(damage) + " damage!")
				
				if player.health <= 0:
					print("\nEnemy Wins!")
					if ui:
						ui.add_combat_log("Enemy Wins!")
						ui.show_win_screen("Enemy")
					game_over = true
					return
				
				enemy_consecutive_attacks += 1
		elif enemy.current_action == "charge":
			if ui:
				ui.add_combat_log("Enemy charges up for next attack!")
			enemy_consecutive_attacks = 0
		elif enemy.current_action == "defend":
			if ui:
				ui.add_combat_log("Enemy defends!")
			enemy_consecutive_attacks = 0
	
	turn_number += 1
	start_player_turn()

func get_player_style_info(player_style) -> String:
	var dominant_style = ""
	var max_value = 0.0
	
	if player_style.aggressive > max_value:
		max_value = player_style.aggressive
		dominant_style = "aggressive"
	if player_style.defensive > max_value:
		max_value = player_style.defensive
		dominant_style = "defensive"
	if player_style.strategic > max_value:
		max_value = player_style.strategic
		dominant_style = "strategic"
	
	if max_value > 0.6:
		return "The enemy has identified your " + dominant_style + " fighting style!"
	return ""

func end_player_turn():
	var player = get_node("Player")
	if player:
		last_player_action = player.current_action
		
		if player.current_action == "attack":
			var enemy = get_node("Enemy")
			if enemy:
				var damage = player_damage
				
				# Apply charge multiplier if charged
				if player.is_charged:
					damage *= charge_multiplier
					if ui:
						ui.add_combat_log("Charged attack! Double damage!")
				
				# Apply consecutive attack penalty
				if player_consecutive_attacks > 0:
					damage *= (1.0 - (consecutive_attack_penalty * player_consecutive_attacks))
					if ui:
						ui.add_combat_log("Your attack is weakened from repetition!")
				
				# Apply defense reduction if enemy defended
				if enemy.current_action == "defend":
					damage *= (1.0 - defense_bonus)
					if ui:
						ui.add_combat_log("Enemy's defense reduces the damage!")
				
				enemy.health -= damage
				print("Player deals", damage, "damage!")
				print("Enemy health:", enemy.health)
				if ui:
					ui.update_enemy_health(enemy.health)
					ui.add_combat_log("Player attacks for " + str(damage) + " damage!")
				
				if enemy.health <= 0:
					print("\nPlayer Wins!")
					if ui:
						ui.add_combat_log("Player Wins!")
						ui.show_win_screen("Player")
					game_over = true
					return
				
				player_consecutive_attacks += 1
		elif player.current_action == "charge":
			if ui:
				ui.add_combat_log("Player charges up for next attack!")
			player_consecutive_attacks = 0
		elif player.current_action == "defend":
			if ui:
				ui.add_combat_log("Player defends!")
			player_consecutive_attacks = 0
		
		player.is_player_turn = false
	start_enemy_turn()
