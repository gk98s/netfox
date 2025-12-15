@tool
extends NetfoxTypeConfig
class_name NxBool

func get_serializer() -> NetfoxSerializer:
	# 1-bit boolean is not directly supported without BitWriter/BitReader, you can bitmask them in your game's logic.
	return NetfoxSchemas.bool8()
