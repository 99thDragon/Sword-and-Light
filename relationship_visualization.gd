extends Control

class_name RelationshipVisualization

# Constants for relationship types
const RELATIONSHIP_TYPES = {
	"FRIEND": 1,
	"ENEMY": 2,
	"NEUTRAL": 3
}

# Colors for different relationship types
const RELATIONSHIP_COLORS = {
	RELATIONSHIP_TYPES.FRIEND: Color(0.2, 0.8, 0.2),
	RELATIONSHIP_TYPES.ENEMY: Color(0.8, 0.2, 0.2),
	RELATIONSHIP_TYPES.NEUTRAL: Color(0.8, 0.8, 0.2)
}

# Node references
@onready var graph_container = $CanvasLayer/GraphContainer
@onready var filter_options = $CanvasLayer/ControlPanel/VBoxContainer/FilterContainer/FilterOptions
@onready var layout_options = $CanvasLayer/ControlPanel/VBoxContainer/LayoutContainer/LayoutOptions
@onready var refresh_button = $CanvasLayer/ControlPanel/VBoxContainer/Button
@onready var export_button = $CanvasLayer/ControlPanel/VBoxContainer/Button2

# Graph data
var nodes = {}
var edges = []
var selected_filter = 0
var current_layout = 0
var is_initialized = false

func _ready():
	if not is_initialized:
		# Connect signals
		filter_options.item_selected.connect(_on_filter_selected)
		layout_options.item_selected.connect(_on_layout_selected)
		refresh_button.pressed.connect(_on_refresh_pressed)
		export_button.pressed.connect(_on_export_pressed)
		
		# Initialize the graph
		initialize_graph()
		is_initialized = true

func initialize_graph():
	# Clear existing nodes and edges
	for child in graph_container.get_children():
		child.queue_free()
	
	nodes.clear()
	edges.clear()
	
	# Load relationship data
	load_sample_data()
	
	# Draw the initial graph
	draw_graph()

func load_sample_data():
	# Sample data for demonstration
	var sample_nodes = [
		{"id": "player", "name": "Player", "type": "character"},
		{"id": "enemy1", "name": "Enemy 1", "type": "character"},
		{"id": "enemy2", "name": "Enemy 2", "type": "character"},
		{"id": "npc1", "name": "NPC 1", "type": "character"}
	]
	
	var sample_edges = [
		{"from": "player", "to": "enemy1", "type": RELATIONSHIP_TYPES.ENEMY},
		{"from": "player", "to": "enemy2", "type": RELATIONSHIP_TYPES.ENEMY},
		{"from": "player", "to": "npc1", "type": RELATIONSHIP_TYPES.FRIEND},
		{"from": "enemy1", "to": "enemy2", "type": RELATIONSHIP_TYPES.NEUTRAL}
	]
	
	for node_data in sample_nodes:
		create_node(node_data)
	
	for edge_data in sample_edges:
		create_edge(edge_data)

func create_node(node_data):
	var node = Control.new()
	node.name = node_data.id
	node.custom_minimum_size = Vector2(100, 100)
	
	var label = Label.new()
	label.text = node_data.name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	node.add_child(label)
	graph_container.add_child(node)
	nodes[node_data.id] = node

func create_edge(edge_data):
	edges.append(edge_data)

func draw_graph():
	if not is_initialized:
		return
		
	# Clear existing edges
	for child in graph_container.get_children():
		if child is Line2D:
			child.queue_free()
	
	# Apply current filter
	var filtered_edges = edges
	if selected_filter != 0:
		filtered_edges = edges.filter(func(edge): return edge.type == selected_filter)
	
	# Draw edges
	for edge in filtered_edges:
		var line = Line2D.new()
		line.width = 2
		line.default_color = RELATIONSHIP_COLORS[edge.type]
		
		var from_node = nodes[edge.from]
		var to_node = nodes[edge.to]
		
		line.add_point(from_node.position + from_node.size / 2)
		line.add_point(to_node.position + to_node.size / 2)
		
		graph_container.add_child(line)
	
	# Apply layout
	match current_layout:
		0: # Circular
			apply_circular_layout()
		1: # Force-directed
			apply_force_directed_layout()

func apply_circular_layout():
	var center = graph_container.size / 2
	var radius = min(center.x, center.y) * 0.8
	var angle_step = TAU / nodes.size()
	var current_angle = 0
	
	for node in nodes.values():
		var pos = center + Vector2(
			cos(current_angle) * radius,
			sin(current_angle) * radius
		)
		node.position = pos - node.size / 2
		current_angle += angle_step

func apply_force_directed_layout():
	# Simple force-directed layout implementation
	var iterations = 50
	var repulsion = 200.0
	var attraction = 0.1
	
	for i in range(iterations):
		# Calculate repulsion forces
		for node1 in nodes.values():
			var force = Vector2.ZERO
			for node2 in nodes.values():
				if node1 != node2:
					var diff = node1.position - node2.position
					var distance = diff.length()
					if distance > 0:
						force += diff.normalized() * repulsion / (distance * distance)
			node1.position += force * 0.1
		
		# Calculate attraction forces
		for edge in edges:
			var from_node = nodes[edge.from]
			var to_node = nodes[edge.to]
			var diff = to_node.position - from_node.position
			var distance = diff.length()
			if distance > 0:
				var force = diff.normalized() * attraction * distance
				from_node.position += force * 0.1
				to_node.position -= force * 0.1

func _on_filter_selected(index):
	selected_filter = index
	draw_graph()

func _on_layout_selected(index):
	current_layout = index
	draw_graph()

func _on_refresh_pressed():
	initialize_graph()

func _on_export_pressed():
	# TODO: Implement data export functionality
	print("Export functionality to be implemented")

func _process(_delta):
	if is_initialized:
		# Update edge positions if nodes are moved
		draw_graph() 