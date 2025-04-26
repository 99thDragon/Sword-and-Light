@tool
extends EditorScript

func _run():
	# This script will help you convert your GIF to a sprite sheet
	print("GIF to Sprite Sheet Converter")
	print("1. First, use an online tool like https://ezgif.com/split to split your GIF into frames")
	print("2. Save each frame as a PNG file")
	print("3. Name them like: attack_1.png, attack_2.png, etc.")
	print("4. Import them into your project")
	print("5. In the AnimatedSprite2D node:")
	print("   - Click 'New SpriteFrames'")
	print("   - Click 'Edit'")
	print("   - Click 'Add Animation'")
	print("   - Name it 'attack'")
	print("   - Drag each frame into the animation in order")
	print("   - Set FPS to 10 (or adjust as needed)")
	print("   - Uncheck 'Loop'")
	print("6. The animation will play when the player attacks") 