@tool
extends Resource
class_name NetfoxTypeConfig

@export var property_name: String

func get_serializer() -> NetfoxSerializer:
	return NetfoxSchemas.variant()
