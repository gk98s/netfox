extends VestTest

func get_suite_name() -> String:
	return "SnapshotHistoryEncoder"

var source_history: _PropertyHistoryBuffer
var target_history: _PropertyHistoryBuffer
var property_cache: PropertyCache

var source_encoder: _SnapshotHistoryEncoder
var target_encoder: _SnapshotHistoryEncoder

func before_case(__):
	# Setup
	var root_node := Node3D.new()
	source_history = _PropertyHistoryBuffer.new()
	target_history = _PropertyHistoryBuffer.new()
	property_cache = PropertyCache.new(root_node)

	source_encoder = _SnapshotHistoryEncoder.new(source_history, property_cache)
	target_encoder = _SnapshotHistoryEncoder.new(target_history, property_cache)

	# Set history
	source_history.set_snapshot(0, SnapshotFixtures.state_snapshot(Vector3(1, 1, 0)))
	target_history.set_snapshot(1, SnapshotFixtures.state_snapshot(Vector3(0, 1, 0)))

func after_case(__):
	NetworkTime._tick = 0

func test_encode_should_decode_to_same():
	# Source encodes a snapshot, and the target decodes it.
	# The two snapshots should match.

	var tick := 0
	var data := source_encoder.encode(tick)
	var snapshot := target_encoder.decode(data)

	# TODO: Better support for custom types in vest
	expect_equal(
		snapshot.as_dictionary(),
		source_history.get_snapshot(tick).as_dictionary()
	)

func test_apply_should_update_history():
	# Source encodes a snapshot, the target decodes and applies it.
	# Histories should be in sync for the affected tick.

	var tick := 0
	var data := source_encoder.encode(tick)
	var snapshot := target_encoder.decode(data)

	var success := target_encoder.apply(tick, snapshot)

	expect(success, "Snapshot should have been applied!")
	expect_equal(
		target_history.get_snapshot(tick).as_dictionary(),
		source_history.get_snapshot(tick).as_dictionary()
	)

func test_apply_should_fail_on_old_data():
	# Source encodes a snapshot, the target decodes and tries to apply it.
	# Apply fails because the snapshot is too old.

	var tick := 0
	var data := source_encoder.encode(tick)
	var snapshot := target_encoder.decode(data)

	NetworkTime._tick = tick + NetworkRollback.history_limit + 2

	expect_false(
		target_encoder.apply(tick, snapshot),
		"Snapshot should be rejected!"
	)

func test_apply_should_fail_on_unauthorized_data():
	# Source encodes a snapshot, the target decodes and tries to apply it.
	# Apply fails because none of the properties are owned by the sender

	var tick := 0
	var data := source_encoder.encode(tick)
	var snapshot := target_encoder.decode(data)

	NetworkTime._tick = tick + NetworkRollback.history_limit + 2

	expect_false(
		target_encoder.apply(tick, snapshot, 2),
		"Snapshot should be rejected!"
	)

func test_bandwidth():
	# TODO(vest): Attach custom data to test results and benchmarks
	var data := source_encoder.encode(0)
	var bytes_per_snapshot := var_to_bytes(data).size()

	Vest.message("Snapshot size: %d bytes" % [bytes_per_snapshot])

	ok()
