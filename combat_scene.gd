# enemy.gd (Attached to the root Enemy node in Enemy.tscn)
extends Node2D

var current_actor = "player"  # Track the current active character
var turn_number = 1          # Track the current turn number
var player_damage = 10       # Amount of damage player deals
var enemy_damage = 10        # Changed from 5 to 10 to match player
var game_over = false        # Track if the game has ended

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
	
	start_player_turn()

func _process(_delta):
	# We'll add input handling here later
	pass

func start_player_turn():
	if game_over:
		return
		
	print("\nTurn", turn_number, "- Player's turn")
	var player = get_node("Player")
	if player:
		player.is_player_turn = true
		print("Waiting for player input...")
		if ui:
			ui.add_to_combat_log("Player's turn")

func start_enemy_turn():
	if game_over:
		return
		
	print("\nTurn", turn_number, "- Enemy's turn")
	var enemy = get_node("Enemy")
	if enemy:
		enemy.take_turn()
		# If enemy chose to attack, deal damage to player
		if enemy.current_action == "attack":
			var player = get_node("Player")
			if player:
				player.health -= enemy_damage
				print("Enemy deals", enemy_damage, "damage!")
				print("Player health:", player.health)
				if ui:
					ui.update_player_health(player.health)
					ui.add_to_combat_log("Enemy attacks for " + str(enemy_damage) + " damage!")
				
				# Check if player is defeated
				if player.health <= 0:
					print("\nEnemy Wins!")
					if ui:
						ui.add_to_combat_log("Enemy Wins!")
						ui.show_win_screen("Enemy")
					game_over = true
					return
		elif ui:
			ui.add_to_combat_log("Enemy defends!")
	
	# After enemy turn, increment turn number and start player's turn
	turn_number += 1
	start_player_turn()

func end_player_turn():
	var player = get_node("Player")
	if player:
		# If player chose to attack, deal damage to enemy
		if player.current_action == "attack":
			var enemy = get_node("Enemy")
			if enemy:
				var damage = player_damage
				if player.is_charged:
					damage *= 2  # Double damage if charged
					if ui:
						ui.add_to_combat_log("Charged attack! Double damage!")
				
				enemy.health -= damage
				print("Player deals", damage, "damage!")
				print("Enemy health:", enemy.health)
				if ui:
					ui.update_enemy_health(enemy.health)
					ui.add_to_combat_log("Player attacks for " + str(damage) + " damage!")
				
				# Check if enemy is defeated
				if enemy.health <= 0:
					print("\nPlayer Wins!")
					if ui:
						ui.add_to_combat_log("Player Wins!")
						ui.show_win_screen("Player")
					game_over = true
					return
		elif player.current_action == "charge":
			if ui:
				ui.add_to_combat_log("Player charges up for next attack!")
		elif ui:
			ui.add_to_combat_log("Player defends!")
		
		player.is_player_turn = false
	start_enemy_turn()
