extends Node

# General metrics
var frame_times = []
var memory_usage = []
var cpu_usage = []
var max_samples = 100

# Combat System metrics
var combat_frame_times = []
var combat_memory_usage = []
var combat_cpu_usage = []
var combat_active = false

# AI System metrics
var ai_decision_times = []
var ai_memory_usage = []
var ai_cpu_usage = []
var last_ai_decision_start = 0

# UI metrics
var ui_frame_times = []
var ui_memory_usage = []
var ui_response_times = []
var last_ui_action = 0

func _ready():
	# Start monitoring
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	# Record general metrics
	frame_times.append(Engine.get_frames_per_second())
	memory_usage.append(OS.get_static_memory_usage() / 1024.0 / 1024.0) # Convert to MB
	cpu_usage.append(OS.get_processor_count())
	
	# Keep arrays manageable
	if frame_times.size() > max_samples:
		frame_times.pop_front()
		memory_usage.pop_front()
		cpu_usage.pop_front()
	
	# Record combat metrics if active
	if combat_active:
		combat_frame_times.append(Engine.get_frames_per_second())
		combat_memory_usage.append(OS.get_static_memory_usage() / 1024.0 / 1024.0)
		combat_cpu_usage.append(OS.get_processor_count())
		
		if combat_frame_times.size() > max_samples:
			combat_frame_times.pop_front()
			combat_memory_usage.pop_front()
			combat_cpu_usage.pop_front()

func start_ai_decision():
	last_ai_decision_start = Time.get_ticks_msec()

func end_ai_decision():
	var decision_time = Time.get_ticks_msec() - last_ai_decision_start
	ai_decision_times.append(decision_time)
	ai_memory_usage.append(OS.get_static_memory_usage() / 1024.0 / 1024.0)
	ai_cpu_usage.append(OS.get_processor_count())
	
	if ai_decision_times.size() > max_samples:
		ai_decision_times.pop_front()
		ai_memory_usage.pop_front()
		ai_cpu_usage.pop_front()

func record_ui_action():
	var current_time = Time.get_ticks_msec()
	if last_ui_action > 0:
		var response_time = current_time - last_ui_action
		ui_response_times.append(response_time)
		ui_frame_times.append(Engine.get_frames_per_second())
		ui_memory_usage.append(OS.get_static_memory_usage() / 1024.0 / 1024.0)
		
		if ui_response_times.size() > max_samples:
			ui_response_times.pop_front()
			ui_frame_times.pop_front()
			ui_memory_usage.pop_front()
	
	last_ui_action = current_time

func start_combat():
	combat_active = true
	combat_frame_times.clear()
	combat_memory_usage.clear()
	combat_cpu_usage.clear()

func end_combat():
	combat_active = false

func get_average_frame_rate() -> float:
	if frame_times.is_empty():
		return 0.0
	return frame_times.reduce(func(a, b): return a + b) / frame_times.size()

func get_average_memory_usage() -> float:
	if memory_usage.is_empty():
		return 0.0
	return memory_usage.reduce(func(a, b): return a + b) / memory_usage.size()

func get_average_cpu_usage() -> float:
	if cpu_usage.is_empty():
		return 0.0
	return cpu_usage.reduce(func(a, b): return a + b) / cpu_usage.size()

func get_combat_metrics() -> Dictionary:
	return {
		"frame_rate": combat_frame_times.reduce(func(a, b): return a + b) / combat_frame_times.size() if not combat_frame_times.is_empty() else 0.0,
		"memory_usage": combat_memory_usage.reduce(func(a, b): return a + b) / combat_memory_usage.size() if not combat_memory_usage.is_empty() else 0.0,
		"cpu_usage": combat_cpu_usage.reduce(func(a, b): return a + b) / combat_cpu_usage.size() if not combat_cpu_usage.is_empty() else 0.0
	}

func get_ai_metrics() -> Dictionary:
	return {
		"decision_time": ai_decision_times.reduce(func(a, b): return a + b) / ai_decision_times.size() if not ai_decision_times.is_empty() else 0.0,
		"memory_usage": ai_memory_usage.reduce(func(a, b): return a + b) / ai_memory_usage.size() if not ai_memory_usage.is_empty() else 0.0,
		"cpu_usage": ai_cpu_usage.reduce(func(a, b): return a + b) / ai_cpu_usage.size() if not ai_cpu_usage.is_empty() else 0.0
	}

func get_ui_metrics() -> Dictionary:
	return {
		"frame_rate": ui_frame_times.reduce(func(a, b): return a + b) / ui_frame_times.size() if not ui_frame_times.is_empty() else 0.0,
		"memory_usage": ui_memory_usage.reduce(func(a, b): return a + b) / ui_memory_usage.size() if not ui_memory_usage.is_empty() else 0.0,
		"response_time": ui_response_times.reduce(func(a, b): return a + b) / ui_response_times.size() if not ui_response_times.is_empty() else 0.0
	}

func print_performance_metrics():
	print("\nPerformance Metrics:")
	print("-------------------")
	
	print("\nCombat System:")
	var combat = get_combat_metrics()
	print("Frame Rate: ", combat.frame_rate, " FPS")
	print("Memory Usage: ", combat.memory_usage, " MB")
	print("CPU Usage: ", combat.cpu_usage, " cores")
	
	print("\nAI System:")
	var ai = get_ai_metrics()
	print("Decision Time: ", ai.decision_time, " ms")
	print("Memory Usage: ", ai.memory_usage, " MB")
	print("CPU Usage: ", ai.cpu_usage, " cores")
	
	print("\nUI System:")
	var ui = get_ui_metrics()
	print("Frame Rate: ", ui.frame_rate, " FPS")
	print("Memory Usage: ", ui.memory_usage, " MB")
	print("Response Time: ", ui.response_time, " ms") 