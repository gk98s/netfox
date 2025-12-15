@tool
extends NetfoxTypeConfig
class_name NxFloat

enum FloatSize { FLOAT_32, DOUBLE_64 }

@export var size: FloatSize = FloatSize.FLOAT_32

func get_serializer() -> NetfoxSerializer:
	match size:
		FloatSize.FLOAT_32:
			return NetfoxSchemas.float32()
		FloatSize.DOUBLE_64:
			return NetfoxSchemas.float64()
	return NetfoxSchemas.float32()
