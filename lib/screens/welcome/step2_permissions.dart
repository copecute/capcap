import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';

class Step2Permissions extends StatefulWidget {
  final VoidCallback onNext;
  final AppLocalizations l;
  final bool isDark;

  const Step2Permissions({
    super.key,
    required this.onNext,
    required this.l,
    required this.isDark,
  });

  @override
  State<Step2Permissions> createState() => _Step2PermissionsState();
}

class _Step2PermissionsState extends State<Step2Permissions> {
  final Map<String, PermissionStatus> _statuses = {};
  bool _requesting = false;

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  List<_PermItem> get _items => [
    _PermItem(
      key: 'storage',
      icon: Icons.folder_open_rounded,
      label: widget.l.get('perm_storage'),
      desc: widget.l.get('perm_storage_desc'),
      color: const Color(0xFF00C2FF),
      permission: (!kIsWeb && Platform.isAndroid)
          ? Permission.manageExternalStorage
          : Permission.photos,
    ),
    _PermItem(
      key: 'notification',
      icon: Icons.notifications_rounded,
      label: widget.l.get('perm_notification'),
      desc: widget.l.get('perm_notification_desc'),
      color: const Color(0xFFFF6B6B),
      permission: Permission.notification,
    ),
    _PermItem(
      key: 'camera',
      icon: Icons.camera_alt_rounded,
      label: widget.l.get('perm_camera'),
      desc: widget.l.get('perm_camera_desc'),
      color: const Color(0xFF4CAF50),
      permission: Permission.camera,
    ),
    _PermItem(
      key: 'microphone',
      icon: Icons.mic_rounded,
      label: widget.l.get('perm_microphone'),
      desc: widget.l.get('perm_microphone_desc'),
      color: const Color(0xFFFF9800),
      permission: Permission.microphone,
    ),
  ];

  Future<PermissionStatus> _requestStoragePermission() async {
    if (!_isMobile) return PermissionStatus.granted;
    if (Platform.isAndroid) {
      final storage = await Permission.storage.request();
      final manage = await Permission.manageExternalStorage.request();
      if (manage.isGranted || storage.isGranted) {
        return PermissionStatus.granted;
      }
      return manage.isPermanentlyDenied ? manage : storage;
    }
    return Permission.photos.request();
  }

  Future<void> _requestAll() async {
    setState(() => _requesting = true);
    if (!_isMobile) {
      for (final item in _items) {
        _statuses[item.key] = PermissionStatus.granted;
      }
      setState(() => _requesting = false);
      widget.onNext();
      return;
    }

    for (final item in _items) {
      final status = item.key == 'storage'
          ? await _requestStoragePermission()
          : await item.permission.request();
      setState(() => _statuses[item.key] = status);
    }
    setState(() => _requesting = false);

    final storageGranted = _statuses['storage']?.isGranted ?? false;
    if (storageGranted) {
      widget.onNext();
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.l.get('storage_required')),
        action: SnackBarAction(
          label: widget.l.get('open_settings'),
          onPressed: openAppSettings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: EdgeInsets.fromLTRB(isWide ? 40 : 24, 8, isWide ? 40 : 24, 24),
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C2FF), Color(0xFF0070FF)],
                    ),
                  ),
                  child: const Icon(Icons.security_rounded, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.l.get('permissions_title'),
                style: TextStyle(
                  fontSize: isWide ? 26 : 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.l.get('permissions_subtitle'),
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isDark ? Colors.white54 : Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ..._items.map((item) {
                final status = _statuses[item.key];
                final granted = status?.isGranted ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: item.color.withValues(alpha: 0.15),
                            ),
                            child: Icon(item.icon, color: item.color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: widget.isDark
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : Colors.black.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            status == null
                                ? Icons.radio_button_unchecked
                                : (granted ? Icons.check_circle_rounded : Icons.cancel_rounded),
                            color: status == null
                                ? (widget.isDark ? Colors.white30 : Colors.black26)
                                : (granted ? const Color(0xFF4CAF50) : const Color(0xFFFF6B6B)),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _requesting ? null : _requestAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _requesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          widget.l.get('btn_grant'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.l.get('storage_required_hint'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermItem {
  final String key;
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final Permission permission;

  const _PermItem({
    required this.key,
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.permission,
  });
}
