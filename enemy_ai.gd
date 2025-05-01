extends Node

# AI States
enum AIState {
	AGGRESSIVE,
	DEFENSIVE,
	STRATEGIC,
	LEARNING,
	ADAPTIVE
}

# Current AI state
var current_state = AIState.STRATEGIC

# Decision weights
var attack_weight = 0.5
var defend_weight = 0.3
var charge_weight = 0.2

# State thresholds
var health_threshold_low = 30
var health_threshold_high = 70

# Last player action
var last_player_action = ""

# Combat history
var combat_history = []

# Pattern recognition
var consecutive_attacks = 0
var last_actions = []
var pattern_database = {}
var success_rate = 0.0
var learning_rate = 0.1

# Adaptive behavior
var player_style = {
	"aggressive": 0.0,
	"defensive": 0.0,
	"strategic": 0.0
}

func _init():
	randomize()

func update_state(enemy_health, player_health, last_player_action):
	self.last_player_action = last_player_action
	
	# Update combat history
	combat_history.append({
		"enemy_health": enemy_health,
		"player_health": player_health,
		"player_action": last_player_action,
		"success": calculate_action_success()
	})
	
	# Keep history manageable
	if combat_history.size() > 10:
		combat_history.pop_front()
	
	# Update pattern recognition
	last_actions.append(last_player_action)
	if last_actions.size() > 5:
		last_actions.pop_front()
	
	# Update player style analysis
	analyze_player_style()
	
	# Count consecutive attacks
	if last_player_action == "attack":
		consecutive_attacks += 1
	else:
		consecutive_attacks = 0
	
	# Determine AI state based on health, player behavior, and learning
	if enemy_health <= health_threshold_low:
		current_state = AIState.DEFENSIVE
	elif enemy_health >= health_threshold_high and player_health <= health_threshold_low:
		current_state = AIState.AGGRESSIVE
	elif success_rate < 0.4:
		current_state = AIState.LEARNING
	elif player_style.aggressive > 0.7:
		current_state = AIState.ADAPTIVE
	else:
		current_state = AIState.STRATEGIC

func analyze_player_style():
	var recent_history = combat_history.slice(-5) if combat_history.size() >= 5 else combat_history
	
	for action in recent_history:
		match action.player_action:
			"attack":
				player_style.aggressive += 0.2
				player_style.defensive -= 0.1
			"defend":
				player_style.defensive += 0.2
				player_style.aggressive -= 0.1
			"charge":
				player_style.strategic += 0.2
				player_style.aggressive -= 0.1
	
	# Normalize values
	var total = player_style.aggressive + player_style.defensive + player_style.strategic
	if total > 0:
		player_style.aggressive /= total
		player_style.defensive /= total
		player_style.strategic /= total

func calculate_action_success() -> bool:
	if combat_history.size() < 2:
		return false
	
	var last_action = combat_history[-1]
	var previous_action = combat_history[-2]
	
	# Success is defined as:
	# 1. Enemy health increased or player health decreased
	# 2. Enemy survived the turn
	return (last_action.enemy_health >= previous_action.enemy_health or
			last_action.player_health < previous_action.player_health)

func decide_action(enemy_health, player_health) -> String:
	update_state(enemy_health, player_health, last_player_action)
	
	# Base weights for each state
	match current_state:
		AIState.AGGRESSIVE:
			attack_weight = 0.6
			defend_weight = 0.2
			charge_weight = 0.2
			
		AIState.DEFENSIVE:
			attack_weight = 0.3
			defend_weight = 0.5
			charge_weight = 0.2
			
		AIState.STRATEGIC:
			attack_weight = 0.4
			defend_weight = 0.3
			charge_weight = 0.3
			
		AIState.LEARNING:
			# More balanced approach while learning
			attack_weight = 0.4
			defend_weight = 0.4
			charge_weight = 0.2
			
		AIState.ADAPTIVE:
			# Counter player's style
			attack_weight = 0.4 + (player_style.defensive * 0.3)
			defend_weight = 0.3 + (player_style.aggressive * 0.3)
			charge_weight = 0.3 + (player_style.strategic * 0.3)
	
	# Adjust weights based on player patterns
	if consecutive_attacks >= 2:
		defend_weight += 0.3
		attack_weight -= 0.2
		charge_weight -= 0.1
	
	if last_player_action == "charge":
		defend_weight += 0.2
		attack_weight -= 0.1
		charge_weight -= 0.1
	elif last_player_action == "defend":
		charge_weight += 0.2
		attack_weight -= 0.1
		defend_weight -= 0.1
	
	# Health-based adjustments
	if enemy_health <= health_threshold_low:
		defend_weight += 0.2
		charge_weight += 0.1
		attack_weight -= 0.3
	
	if player_health <= health_threshold_low:
		attack_weight += 0.2
		defend_weight -= 0.1
		charge_weight -= 0.1
	
	# Make decision based on weights
	var total_weight = attack_weight + defend_weight + charge_weight
	var random_value = randf() * total_weight
	
	if random_value < attack_weight:
		return "attack"
	elif random_value < attack_weight + defend_weight:
		return "defend"
	else:
		return "charge"

func get_state_description() -> String:
	match current_state:
		AIState.AGGRESSIVE:
			return "The enemy looks aggressive and ready to strike!"
		AIState.DEFENSIVE:
			return "The enemy seems cautious and defensive..."
		AIState.STRATEGIC:
			return "The enemy is analyzing the situation carefully."
		AIState.LEARNING:
			return "The enemy is studying your fighting style..."
		AIState.ADAPTIVE:
			return "The enemy has adapted to your tactics!"
	return "" 