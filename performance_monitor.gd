extends Node

var frame_times = []
var memory_usage = []
var cpu_usage = []
var max_samples = 100
var ui_action_times = []

func _ready():
	# Start monitoring
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_combat():
	# Reset all metrics when combat starts
	frame_times.clear()
	memory_usage.clear()
	cpu_usage.clear()
	ui_action_times.clear()
	print("Performance monitoring started for combat")

func record_ui_action():
	# Record the time of UI action for performance tracking
	ui_action_times.append(Time.get_ticks_msec())
	if ui_action_times.size() > max_samples:
		ui_action_times.pop_front()

func _process(_delta):
	# Record frame time
	frame_times.append(Engine.get_frames_per_second())
	if frame_times.size() > max_samples:
		frame_times.pop_front()
	
	# Record memory usage
	memory_usage.append(OS.get_static_memory_usage() / 1024.0 / 1024.0) # Convert to MB
	if memory_usage.size() > max_samples:
		memory_usage.pop_front()
	
	# Record CPU usage
	cpu_usage.append(OS.get_processor_count())
	if cpu_usage.size() > max_samples:
		cpu_usage.pop_front()

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

func print_performance_metrics():
	print("Performance Metrics:")
	print("Average FPS: ", get_average_frame_rate())
	print("Average Memory Usage: ", get_average_memory_usage(), " MB")
	print("Average CPU Usage: ", get_average_cpu_usage(), " cores") 