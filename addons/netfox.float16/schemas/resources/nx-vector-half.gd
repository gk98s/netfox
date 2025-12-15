@tool
extends NetfoxTypeConfig
class_name NxVectorHalf

enum VecType { VECTOR_2, VECTOR_3 }
@export var vector_type: VecType = VecType.VECTOR_2

func get_serializer() -> NetfoxSerializer:
	var component := NetfoxFloat16Serializer.new()
	
	match vector_type:
		VecType.VECTOR_2:
			return NetfoxSchemas.vec2t(component)
		VecType.VECTOR_3:
			return NetfoxSchemas.vec3t(component)
			
	return NetfoxSchemas.vec2t(component)
