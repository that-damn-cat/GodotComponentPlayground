# GodotComponentPlayground
A collection of (possibly) useful components/nodes for Godot

Icons are from https://game-icons.net/

**Included components**

- `AudioJitterPlayer` - AudioStreamPlayer that randomizes pitch to reduce repetition.
- `FreeTimer` - Timer that calls `queue_free()` on its parent when it times out.
- `FreeNotifier2D` - VisibleOnScreenNotifier2D that frees its parent when it leaves the screen.
- `StatComponent` - Generic Statistic Tracker
- `HealthComponent` - Specialty StatComponent for tracking Health
- `Hitbox2D` / `Hurtbox2D` - Small hit/hurt Area2D components for dealing damage between entities.
- `SpeechLabel` - Label that types text over time and optionally plays a sound per character.
- `Spawner` - Timer-based spawner with spawntime Callables and cooldown handling.
- `State` / `StateMachine` - Lightweight node-based state machine for gameplay states.