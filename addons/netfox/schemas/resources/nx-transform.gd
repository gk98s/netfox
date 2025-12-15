@tool
extends NetfoxTypeConfig
class_name NxTransform

enum TransformType { TRANSFORM_2D, TRANSFORM_3D }
enum Precision { FLOAT_32, DOUBLE_64 }

@export var type: TransformType = TransformType.TRANSFORM_3D
@export var precision: Precision = Precision.FLOAT_32

func get_serializer() -> NetfoxSerializer:
	var component: NetfoxSerializer
	match precision:
		Precision.FLOAT_32:
			component = NetfoxSchemas.float32()
		Precision.DOUBLE_64:
			component = NetfoxSchemas.float64()
	
	match type:
		TransformType.TRANSFORM_2D:
			return NetfoxSchemas.transform2t(component)
		TransformType.TRANSFORM_3D:
			return NetfoxSchemas.transform3t(component)
			
	return NetfoxSchemas.transform3f32()
