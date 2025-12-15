@tool
extends NetfoxTypeConfig
class_name NxFloat16

func get_serializer() -> NetfoxSerializer:
	return NetfoxFloat16Serializer.new()
