import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:zaibal/models/user.dart';

/// Owns the locally signed-in [User] and persists changes to disk.
///
/// Listens to OGS for live rank updates via [updateOgsRank]. The OGS service
/// pushes the rank in; this service does not depend on OGS directly to keep
/// the dependency graph simple.
class UserService extends ChangeNotifier {
  static const _kUserJson = 'userProfile.v1';

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Loads the persisted user, or seeds a fresh local profile so the app has a
  /// default identity to display before any OGS sign-in.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUserJson);
    if (raw != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _currentUser = _seed();
        await _persist();
      }
    } else {
      _currentUser = _seed();
      await _persist();
    }
    notifyListeners();
  }

  User _seed() => User(id: const Uuid().v4(), displayName: 'Player');

  Future<void> updateProfile({String? displayName, String? avatarPath}) async {
    if (_currentUser == null) return;
    if (displayName != null) _currentUser!.displayName = displayName;
    if (avatarPath != null) _currentUser!.avatarPath = avatarPath;
    await _persist();
    notifyListeners();
  }

  /// Called by OGS sign-in flow to surface the current rank in the profile.
  Future<void> updateOgsRank(String? rank) async {
    if (_currentUser == null || _currentUser!.rank == rank) return;
    _currentUser!.rank = rank;
    await _persist();
    notifyListeners();
  }

  Future<void> recordGameResult({required bool win}) async {
    if (_currentUser == null) return;
    _currentUser!.gamesPlayed++;
    if (win) {
      _currentUser!.wins++;
    } else {
      _currentUser!.losses++;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserJson, jsonEncode(_currentUser!.toJson()));
  }
}
