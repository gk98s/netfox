@tool
extends EditorPlugin


func _enable_plugin() -> void:
	print("Successfully enabled Float16 support for Netfox.")


func _disable_plugin() -> void:
	print("Successfully disabled Float16 support for Netfox.")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
