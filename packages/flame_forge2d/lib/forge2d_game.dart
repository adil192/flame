import 'package:flame/game.dart';
import 'package:flame_forge2d/world_contact_listener.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';

class Forge2DGame extends FlameGame {
  Forge2DGame({
    Vector2? gravity,
    double zoom = defaultZoom,
    Camera? camera,
    ContactListener? contactListener,
    this.pauseWhenBackgrounded = false,
  })  : world = World(gravity ?? defaultGravity),
        super(camera: camera ?? Camera()) {
    // ignore: deprecated_member_use
    this.camera.zoom = zoom;
    world.setContactListener(contactListener ?? WorldContactListener());
  }

  static final Vector2 defaultGravity = Vector2(0, 10.0);

  static const double defaultZoom = 10.0;

  final World world;

  /// Whether the game should pause when the app is backgrounded.
  ///
  /// If true, the first update after the app is foregrounded will be skipped.
  ///
  /// Defaults to false.
  bool pauseWhenBackgrounded;
  bool _pausedBecauseBackgrounded = false;

  @override
  void update(double dt) {
    super.update(dt);
    world.stepDt(dt);
  }

  Vector2 worldToScreen(Vector2 position) {
    return projector.projectVector(position);
  }

  Vector2 screenToWorld(Vector2 position) {
    return projector.unprojectVector(position);
  }

  Vector2 screenToFlameWorld(Vector2 position) {
    return screenToWorld(position)..y *= -1;
  }

  @override
  @mustCallSuper
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        if (_pausedBecauseBackgrounded) {
          resumeEngine();
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (pauseWhenBackgrounded) {
          pauseEngine();
          _pausedBecauseBackgrounded = true;
        }
    }
  }

  @override
  void pauseEngine() {
    _pausedBecauseBackgrounded = false;
    super.pauseEngine();
  }

  @override
  void resumeEngine() {
    _pausedBecauseBackgrounded = false;
    super.resumeEngine();
  }
}
