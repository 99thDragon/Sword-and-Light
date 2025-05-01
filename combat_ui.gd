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
@onready var relationship_button = $RelationshipButton
@onready var relationship_visualization = $RelationshipVisualization

func _ready():
	# Connect button signals
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	charge_button.pressed.connect(_on_charge_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	relationship_button.pressed.connect(_on_relationship_button_pressed)
	
	# Initialize health bars
	update_player_health(100, 100)
	update_enemy_health(100, 100)
	
	# Add initial message to combat log
	add_combat_log("Combat started!")

func update_player_health(current_health, max_health):
	player_health_bar.max_value = max_health
	player_health_bar.value = current_health
	player_health_label.text = "Player HP: %d" % current_health

func update_enemy_health(current_health, max_health):
	enemy_health_bar.max_value = max_health
	enemy_health_bar.value = current_health
	enemy_health_label.text = "Enemy HP: %d" % current_health

func add_combat_log(text):
	combat_log.append_text(text + "\n")

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
	var player = get_parent().get_node("Player")
	var enemy = get_parent().get_node("Enemy")
	if player and enemy:
		player.health = 100
		enemy.health = 100
		update_player_health(100, 100)
		update_enemy_health(100, 100)
		win_screen.visible = false
		get_parent().game_over = false
		get_parent().turn_number = 1
		get_parent().start_player_turn()

func _on_relationship_button_pressed():
	relationship_visualization.visible = !relationship_visualization.visible
	relationship_button.text = "Hide Relationships" if relationship_visualization.visible else "Show Relationships" 
