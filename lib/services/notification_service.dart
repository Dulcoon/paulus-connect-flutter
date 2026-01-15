import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/notification_overlay.dart';

enum NotificationType { success, error, info, warning }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  OverlayEntry? _currentOverlay;
  Timer? _dismissTimer;

  void showNotification(
    BuildContext context, {
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remove existing notification if any
    _removeCurrentOverlay();

    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: NotificationOverlay(
            message: message,
            type: type,
            onDismiss: () {
              _removeCurrentOverlay();
            },
          ),
        ),
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto dismiss after duration
    _dismissTimer = Timer(duration, () {
      _removeCurrentOverlay();
    });
  }

  void showSuccess(BuildContext context, String message) {
    showNotification(
      context,
      message: message,
      type: NotificationType.success,
    );
  }

  void showError(BuildContext context, String message) {
    showNotification(
      context,
      message: message,
      type: NotificationType.error,
    );
  }

  void showInfo(BuildContext context, String message) {
    showNotification(
      context,
      message: message,
      type: NotificationType.info,
    );
  }

  void showWarning(BuildContext context, String message) {
    showNotification(
      context,
      message: message,
      type: NotificationType.warning,
    );
  }

  void _removeCurrentOverlay() {
    _dismissTimer?.cancel();
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
