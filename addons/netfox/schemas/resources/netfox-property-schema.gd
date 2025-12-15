@tool
extends Resource
class_name NetfoxPropertySchema

@export var properties: Array[NetfoxTypeConfig]

func get_serializers() -> Dictionary:
	var result := {}
	
	var sorted_props := properties.duplicate()
	
	# Sort alphabetically by property name
	sorted_props.sort_custom(func(a, b): return a.property_name < b.property_name)
	
	for config in sorted_props:
		if config == null or config.property_name.is_empty():
			continue
			
		result[config.property_name] = config.get_serializer()
		
	return result
