@tool
extends EditorPlugin

func _enter_tree():
	add_import_plugin(GIFImporter.new())

func _exit_tree():
	remove_import_plugin(GIFImporter.new())

class GIFImporter extends EditorImportPlugin:
	func _get_importer_name():
		return "gif_importer"
		
	func _get_visible_name():
		return "GIF Importer"
		
	func _get_recognized_extensions():
		return ["gif"]
		
	func _get_save_extension():
		return "res"
		
	func _get_resource_type():
		return "SpriteFrames"
		
	func _get_preset_count():
		return 0
		
	func _get_preset_name(preset_index):
		return ""
		
	func _get_import_options(path, preset_index):
		return []
		
	func _get_option_visibility(path, option_name, options):
		return true
		
	func _import(source_file, save_path, options, platform_variants, gen_files):
		var file = FileAccess.open(source_file, FileAccess.READ)
		if file == null:
			return FAILED
			
		var buffer = file.get_buffer(file.get_length())
		file.close()
		
		var sprite_frames = SpriteFrames.new()
		sprite_frames.add_animation("default")
		sprite_frames.set_animation_speed("default", 10)
		sprite_frames.set_animation_loop("default", false)
		
		# Create a temporary image to store the GIF frame
		var image = Image.new()
		var err = image.load_from_buffer(buffer)
		if err != OK:
			return FAILED
		
		# Create a texture from the image
		var texture = ImageTexture.create_from_image(image)
		
		# Add the frame to the animation
		sprite_frames.add_frame("default", texture)
		
		var filename = save_path + "." + _get_save_extension()
		err = ResourceSaver.save(sprite_frames, filename)
		if err != OK:
			return FAILED
			
		return OK 