extends Control

@onready var player_health_bar = $PlayerHealthBar
@onready var player_health_label = $PlayerHealthLabel
@onready var enemy_health_bar = $EnemyHealthBar
@onready var enemy_health_label = $EnemyHealthLabel
@onready var attack_button = $ActionButtons/AttackButton
@onready var defend_button = $ActionButtons/DefendButton
@onready var charge_button = $ActionButtons/ChargeButton
@onready var combat_log = $CombatLog
@onready var win_screen = $WinScreen
@onready var win_label = $WinScreen/WinLabel
@onready var play_again_button = $WinScreen/PlayAgainButton

func _ready():
	# Connect button signals
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	charge_button.pressed.connect(_on_charge_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	
	# Initialize health bars
	update_player_health(100)
	update_enemy_health(100)
	
	# Add initial message to combat log
	add_to_combat_log("Combat started!")

func update_player_health(health):
	player_health_bar.value = health
	player_health_label.text = "Player HP: " + str(health)

func update_enemy_health(health):
	enemy_health_bar.value = health
	enemy_health_label.text = "Enemy HP: " + str(health)

func add_to_combat_log(message):
	combat_log.append_text("\n" + message)

func show_win_screen(winner):
	win_label.text = winner + " Wins!"
	win_screen.visible = true

func _on_attack_pressed():
	var player = get_parent().get_node("Player")
	if player and player.is_player_turn:
		player.current_action = "attack"
		player.perform_action("attack")

func _on_defend_pressed():
	var player = get_parent().get_node("Player")
	if player and player.is_player_turn:
		player.current_action = "defend"
		player.perform_action("defend")

func _on_charge_pressed():
	var player = get_parent().get_node("Player")
	if player and player.is_player_turn:
		player.current_action = "charge"
		player.perform_action("charge")

func _on_play_again_pressed():
	# Reset the game
	get_tree().reload_current_scene() 
