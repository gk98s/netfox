@tool
extends NetfoxTypeConfig
class_name NxVector

enum VecType { VECTOR_2, VECTOR_3 }
enum Precision { FLOAT_32, DOUBLE_64 }

@export var vector_type: VecType = VecType.VECTOR_2
@export var precision: Precision = Precision.FLOAT_32

func get_serializer() -> NetfoxSerializer:
	match vector_type:
		VecType.VECTOR_2:
			match precision:
				Precision.FLOAT_32: return NetfoxSchemas.vec2f32()
				Precision.DOUBLE_64: return NetfoxSchemas.vec2f64()
		VecType.VECTOR_3:
			match precision:
				Precision.FLOAT_32: return NetfoxSchemas.vec3f32()
				Precision.DOUBLE_64: return NetfoxSchemas.vec3f64()
	return NetfoxSchemas.vec2f32()
