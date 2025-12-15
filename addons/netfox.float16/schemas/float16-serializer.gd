class_name NetfoxFloat16Serializer extends NetfoxSerializer

func encode(v: Variant, b: StreamPeerBuffer) -> void:
	b.put_half(v)

func decode(b: StreamPeerBuffer) -> Variant:
	return b.get_half()
