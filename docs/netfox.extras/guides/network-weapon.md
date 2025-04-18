# NetworkWeapon

Class to simplify writing networked weapons.

A weapon, in this context, is anything that can be fired and spawn objects (
projectiles ) upon being fired.

## Responsive projectiles

Upon firing, sending a request to the server and waiting for the response with
the projectile would introduce a delay. Doing a full-on state synchronization
with [MultiplayerSynchronizer] or [RollbackSynchronizer] can be unfeasible with
too many projectiles, and unnecessary, since most of the time, projectiles act
and move the same way regardless of their surroundings.

Instead, upon firing, a projectile is spawned instantly. At the same time, a
request is sent to the server. If the server accepts the projectile, it will
spawn it and broadcasts its starting state. Since the server's state is the
source of truth, the projectile's local state will be updated with the
difference. This is called *reconciliation*.

If the client requests a projectile with an unlikely state, it will be
rejected. This is to avoid players cheating, for example by requesting
projectiles at a more advantageous position than they're at.

If the server is too strict with what difference is considered acceptable and
what not, legitimate players may get cases where they fire a projectile which
disappears after a short time period.

## Implementing a weapon

*NetworkWeapon* provides multiple functions to override. Make sure that all
these methods work the same way on every player's game, otherwise players will
experience glitches.

*_can_fire* returns a bool, indicating whether the weapon can be fired. For
example, this method can return false if the weapon was fired recently and is
still on cooldown. **Do not** update state here. Use *_after_fire* instead.

*_can_peer_use* indicates whether a given peer can fire the weapon. Due to the
way RPCs are set up under the hood, any of the players can try to fire a
weapon. Use this method to check if the player trying to fire has permission,
e.g. a player is not trying to use someone else's weapon.

*_after_fire* is called after the weapon is successfully fired. Can be used to
update state ( e.g. last time the weapon was fired ) and play sound effects.

*_spawn* creates the projectile. Make sure to return the created node.

*_get_data* must return the projectile's starting state in a dictionary. This
can contain any property that is relevant to the projectile and must be
synchronized. For example, *global_transform* is important to ensure that the
projectile starts from the right position. On the other hand, projectile speed
does not need to be captured if it's the same for every projectile.

*_apply_data* must apply the captured properties to a projectile.

*_is_reconcilable* checks if the difference between two projectile states ( as
captured by *_get_data* ) is close enough to be allowed. Can be used to reject
cheating.

*_reconcile* adjusts the projectile based on the difference between the local
and server state.

## Specializations

*NetworkWeapon* extends [Node]. This also means that anything extending
*NetworkWeapon* is also a node, and thus can't have a position for example.

Two specialized classes are provided - *NetworkWeapon3D*, and *NetworkWeapon2D*
- extending Node3D and Node2D respectively.

This way, weapons can have transforms and have a presence in the game world.
They also take care of reconciliation, implementing *_get_data*, *_apply_data*,
*_is_reconcilable*, and *_reconcile*. These can be overridden, but make sure to
to call the base class with *super(...)*.

Reconciliation is based on distance, and can be configured with the
*distance_threshold* property.

Under the hood, these specializations create a special *NetworkWeapon* node,
that proxies all the method calls back to the specialization. This is a
workaround to build multiple inheritance in a single inheritance language.

## Compensating latency

Whenever the weapon is fired, it takes time for that event to arrive at the
host. To combat this, along with the weapon being fired, the firing's tick is
also sent. This way, the host doesn't only know that the weapon was fired, but
it also knows *when*.

To retrieve the exact tick, call *get_fired_tick()*.

This can be used to adjust the created projectile's simulation, e.g. by
simulating it from its spawn to the current tick in `_after_fire()`:

```gdscript
func _after_fire(projectile: Node3D):
	last_fire = get_fired_tick()

	for t in range(get_fired_tick(), NetworkTime.tick):
		if projectile.is_queued_for_deletion():
			break
		projectile._tick(NetworkTime.ticktime, t)
```

!!!note
    To track the tick the weapon was last fired ( e.g. for cooldowns ), make sure
    to use `get_fired_tick()`, instead of `NetworkTime.tick`.

## Hitscan weapons

Use *NetworkWeaponHitscan3D* to build networked hitscan weapons. It builds upon
the same principle as *NetworkWeapon*, but modified for hitscan.

Most of the callbacks are the same, with the following differences:

*_spawn* is not used, as there's no projectiles involved.

*_on_fire* is called whenever the weapon is successfully fired. Can be used to
implement effects on firing, such as sound or visual effects.

*_on_hit* is called whenever the weapon hits a target. Depending on
configuration, this may be another player, a different character, or just level
geometry. The raycast result is passed as a parameter to distinguish between
hits.

Reconciliation is handled under the hood - *_get_data*, *_apply_data*,
*_is_reconcilable*, and *_reconcile* do not need to be implemented.

Hitscan weapons don't implement *get_fired_tick()*, as there's no projectile to
simulate.


[MultiplayerSynchronizer]: https://docs.godotengine.org/en/stable/classes/class_multiplayersynchronizer.html
[RollbackSynchronizer]: ../../netfox/nodes/rollback-synchronizer.md
[Node]: https://docs.godotengine.org/en/stable/classes/class_node.html
