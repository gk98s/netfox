@tool
extends NetfoxTypeConfig
class_name NxInt

enum IntSize { INT_8, INT_16, INT_32, INT_64 }

@export var size: IntSize = IntSize.INT_16
@export var is_signed: bool = true

func get_serializer() -> NetfoxSerializer:
	match size:
		IntSize.INT_8:
			return NetfoxSchemas.int8() if is_signed else NetfoxSchemas.uint8()
		IntSize.INT_16:
			return NetfoxSchemas.int16() if is_signed else NetfoxSchemas.uint16()
		IntSize.INT_32:
			return NetfoxSchemas.int32() if is_signed else NetfoxSchemas.uint32()
		IntSize.INT_64:
			return NetfoxSchemas.int64() if is_signed else NetfoxSchemas.uint64()
	return NetfoxSchemas.int16()
