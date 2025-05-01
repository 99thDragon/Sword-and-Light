extends Control

var learning_text = ""
var style_text = ""
var state_text = ""

func _ready():
	# Set up the display
	$LearningLabel.text = "AI Learning System Active"
	$StyleLabel.text = "Analyzing Player Style..."
	$StateLabel.text = "Initializing AI State..."

func update_learning_info(ai_system):
	if not ai_system:
		return
	
	# Update learning progress
	var success_rate = ai_system.success_rate
	$LearningLabel.text = "Learning Progress: " + str(int(success_rate * 100)) + "%"
	
	# Update player style analysis
	var style = ai_system.player_style
	var dominant_style = ""
	var max_value = 0.0
	
	if style.aggressive > max_value:
		max_value = style.aggressive
		dominant_style = "Aggressive"
	if style.defensive > max_value:
		max_value = style.defensive
		dominant_style = "Defensive"
	if style.strategic > max_value:
		max_value = style.strategic
		dominant_style = "Strategic"
	
	$StyleLabel.text = "Player Style: " + dominant_style + " (" + str(int(max_value * 100)) + "%)"
	
	# Update AI state
	$StateLabel.text = "AI State: " + ai_system.get_state_description()

func _process(_delta):
	# Animate the learning display
	var time = Time.get_ticks_msec() / 1000.0
	$LearningLabel.modulate.a = 0.7 + sin(time * 2) * 0.3
	$StyleLabel.modulate.a = 0.7 + sin(time * 2 + 1) * 0.3
	$StateLabel.modulate.a = 0.7 + sin(time * 2 + 2) * 0.3 