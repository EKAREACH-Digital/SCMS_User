import 'package:flutter/foundation.dart';

import 'package:smart_canteen_user_frontend/core/error/exceptions.dart';
import 'package:smart_canteen_user_frontend/core/utils/logger.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/entities/pickup_checkin.dart';
import 'package:smart_canteen_user_frontend/features/pickup/domain/repositories/pickup_repository.dart';

enum PickupScanState { idle, loading, success, error }

/// Manages the pickup check-in flow.
///
/// Both the camera scan and the manual-entry paths call [arrive] with the
/// decoded stand code. [reset] returns to [PickupScanState.idle] so the
/// camera can resume.
class PickupScanViewModel extends ChangeNotifier {
  PickupScanViewModel(this._repository);

  final PickupRepository _repository;

  PickupScanState _state = PickupScanState.idle;
  PickupScanState get state => _state;

  PickupCheckin? _checkin;
  PickupCheckin? get checkin => _checkin;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setState(PickupScanState newState) {
    _state = newState;
    notifyListeners();
  }

  /// `POST /pickup/arrive` — check in by stand code.
  Future<void> arrive(String code) async {
    _setState(PickupScanState.loading);
    try {
      final checkin = await _repository.arrive(code);
      _checkin = checkin;
      _errorMessage = null;
      _setState(PickupScanState.success);
    } catch (e, st) {
      AppLogger.e('Pickup arrive failed', e, st);
      _errorMessage = e is ApiException ? e.message : 'Something went wrong';
      _setState(PickupScanState.error);
    }
  }

  /// Returns to [PickupScanState.idle] so the camera can start scanning again.
  void reset() {
    _checkin = null;
    _errorMessage = null;
    _setState(PickupScanState.idle);
  }
}
