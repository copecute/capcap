import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../services/thumb_cache.dart';

enum MediaPickerMode { video, photo }

class MediaPickerScreen extends StatefulWidget {
  final AppLocalizations l;
  final MediaPickerMode mode;

  const MediaPickerScreen({
    super.key,
    required this.l,
    required this.mode,
  });

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  static const _pageSize = 80;

  int _tab = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _granted = false;
  List<AssetEntity> _assets = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _folderAlbum;
  final Map<String, AssetEntity> _selected = {};

  AssetPathEntity? _imageAll;
  AssetPathEntity? _videoAll;
  AssetPathEntity? _singlePath;
  int _imagePage = 0;
  int _videoPage = 0;
  int _singlePage = 0;
  bool _imageDone = true;
  bool _videoDone = true;
  bool _singleDone = true;

  bool get _multi => widget.mode == MediaPickerMode.video;
  bool get _photoOnly => widget.mode == MediaPickerMode.photo;
  bool get _folderTab => !_photoOnly && _tab == 3 && _folderAlbum == null;

  /// photo_manager Android casts duration ms to Int; keep max within 32-bit.
  static const _maxDurationMs = 2147483647;

  PMFilter get _filter {
    const duration = DurationConstraint(
      max: Duration(milliseconds: _maxDurationMs),
      allowNullable: true,
    );
    const option = FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
      durationConstraint: duration,
    );
    return FilterOptionGroup(
      imageOption: option,
      videoOption: option,
      audioOption: option,
      orders: const [
        OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  int _loadGen = 0;

  Future<void> _reload() async {
    final gen = ++_loadGen;
    _loadingMore = false;
    setState(() {
      _loading = true;
      _assets = [];
      _imageAll = null;
      _videoAll = null;
      _singlePath = null;
      _imagePage = 0;
      _videoPage = 0;
      _singlePage = 0;
      _imageDone = true;
      _videoDone = true;
      _singleDone = true;
    });

    _granted = await _ensureAccess();
    if (gen != _loadGen) return;
    if (!_granted) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (_folderTab) {
      final paths = await _pathList(
        type: RequestType.common,
        onlyAll: false,
      );
      _albums = paths.where((p) => !p.isAll).toList();
      if (gen != _loadGen) return;
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (_folderAlbum != null) {
      _singlePath = _folderAlbum;
      _singleDone = false;
    } else if (_photoOnly || _tab == 1) {
      _singlePath = await _firstPath(RequestType.image);
      _singleDone = _singlePath == null;
    } else if (_tab == 2) {
      _singlePath = await _firstPath(RequestType.video);
      _singleDone = _singlePath == null;
    } else {
      _imageAll = await _firstPath(RequestType.image);
      _videoAll = await _firstPath(RequestType.video);
      _imageDone = _imageAll == null;
      _videoDone = _videoAll == null;
    }

    await _loadMore(reset: true);
    if (gen != _loadGen) return;
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _ensureAccess() async {
    if (!kIsWeb && Platform.isAndroid) {
      final manage = await Permission.manageExternalStorage.isGranted;
      final storage = await Permission.storage.isGranted;
      if (manage || storage) {
        await PhotoManager.setIgnorePermissionCheck(true);
        return true;
      }
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        await PhotoManager.setIgnorePermissionCheck(true);
        return true;
      }
      return false;
    }
    final state = await PhotoManager.requestPermissionExtend();
    return state.hasAccess;
  }

  Future<List<AssetPathEntity>> _pathList({
    required RequestType type,
    required bool onlyAll,
  }) async {
    try {
      return await PhotoManager.getAssetPathList(
        type: type,
        onlyAll: onlyAll,
        filterOption: _filter,
      );
    } catch (_) {
      return [];
    }
  }

  Future<AssetPathEntity?> _firstPath(RequestType type) async {
    final paths = await _pathList(type: type, onlyAll: true);
    if (paths.isEmpty) return null;
    return paths.first;
  }

  Future<void> _loadMore({bool reset = false}) async {
    if (_loadingMore) return;
    if (!reset && _imageDone && _videoDone && _singleDone) return;
    _loadingMore = true;
    try {
      if (_singlePath != null) {
        final batch = await _singlePath!.getAssetListPaged(
          page: _singlePage,
          size: _pageSize,
        );
        if (batch.length < _pageSize) _singleDone = true;
        _singlePage++;
        _append(batch);
      } else {
        final next = <AssetEntity>[];
        if (!_imageDone && _imageAll != null) {
          final batch = await _imageAll!.getAssetListPaged(
            page: _imagePage,
            size: _pageSize,
          );
          if (batch.length < _pageSize) _imageDone = true;
          _imagePage++;
          next.addAll(batch);
        }
        if (!_videoDone && _videoAll != null) {
          final batch = await _videoAll!.getAssetListPaged(
            page: _videoPage,
            size: _pageSize,
          );
          if (batch.length < _pageSize) _videoDone = true;
          _videoPage++;
          next.addAll(batch);
        }
        _append(next);
        _assets.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
      }
    } catch (_) {
      _imageDone = true;
      _videoDone = true;
      _singleDone = true;
    }

    _loadingMore = false;
    if (mounted && !reset) setState(() {});
  }

  void _append(List<AssetEntity> batch) {
    final seen = {for (final a in _assets) a.id};
    for (final asset in batch) {
      if (seen.add(asset.id)) {
        _assets.add(asset);
      }
    }
  }

  void _toggle(AssetEntity asset) {
    if (!_multi) {
      Navigator.pop(context, [asset]);
      return;
    }
    setState(() {
      if (_selected.containsKey(asset.id)) {
        _selected.remove(asset.id);
      } else {
        _selected[asset.id] = asset;
      }
    });
  }

  void _import() {
    Navigator.pop(context, _selected.values.toList());
  }

  Future<void> _openAlbum(AssetPathEntity album) async {
    _folderAlbum = album;
    _tab = 0;
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = _photoOnly
        ? [l.get('media_photos')]
        : [
            l.get('media_all'),
            l.get('media_photos'),
            l.get('media_videos'),
            l.get('media_folders'),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_photoOnly ? l.get('select_photo') : l.get('select_media')),
        actions: [
          if (_multi && _selected.isNotEmpty)
            TextButton(
              onPressed: _import,
              child: Text(
                '${l.get('import')} (${_selected.length})',
                style: const TextStyle(
                  color: Color(0xFF00C2FF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!_photoOnly)
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = _tab == i;
                  return ChoiceChip(
                    label: Text(tabs[i]),
                    selected: selected,
                    onSelected: (_) {
                      _folderAlbum = null;
                      setState(() => _tab = i);
                      _reload();
                    },
                    selectedColor: const Color(0xFF00C2FF),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          Expanded(child: _buildBody(isDark, l)),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_granted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.get('permission_media'), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (!kIsWeb && Platform.isAndroid) {
                    await openAppSettings();
                  } else {
                    await PhotoManager.openSetting();
                  }
                },
                child: Text(l.get('open_settings')),
              ),
            ],
          ),
        ),
      );
    }
    if (_folderTab) {
      if (_albums.isEmpty) {
        return Center(child: Text(l.get('no_media')));
      }
      return ListView.separated(
        itemCount: _albums.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final album = _albums[i];
          return ListTile(
            leading: const Icon(Icons.folder_rounded, color: Color(0xFF00C2FF)),
            title: Text(album.name),
            subtitle: FutureBuilder<int>(
              future: album.assetCountAsync,
              builder: (context, snap) =>
                  Text('${snap.data ?? 0} ${l.get('items')}'),
            ),
            onTap: () => _openAlbum(album),
          );
        },
      );
    }
    if (_assets.isEmpty) {
      return Center(child: Text(l.get('no_media')));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels > n.metrics.maxScrollExtent - 800) {
          _loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: _assets.length,
        itemBuilder: (context, i) {
          final asset = _assets[i];
          final selected = _selected.containsKey(asset.id);
          return _AssetTile(
            key: ValueKey(asset.id),
            asset: asset,
            selected: selected,
            index: _multi ? (_selected.keys.toList().indexOf(asset.id) + 1) : 0,
            onTap: () => _toggle(asset),
          );
        },
      ),
    );
  }
}

class _AssetTile extends StatefulWidget {
  final AssetEntity asset;
  final bool selected;
  final int index;
  final VoidCallback onTap;

  const _AssetTile({
    super.key,
    required this.asset,
    required this.selected,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AssetTile> createState() => _AssetTileState();
}

class _AssetTileState extends State<_AssetTile> {
  File? _thumb;

  @override
  void initState() {
    super.initState();
    _loadThumb();
  }

  @override
  void didUpdateWidget(covariant _AssetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.id != widget.asset.id) {
      _thumb = null;
      _loadThumb();
    }
  }

  Future<void> _loadThumb() async {
    final file = await ThumbCache.forAsset(widget.asset);
    if (!mounted) return;
    setState(() => _thumb = file);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_thumb != null)
            Image.file(_thumb!, fit: BoxFit.cover)
          else
            const ColoredBox(color: Color(0x22000000)),
          if (widget.asset.type == AssetType.video)
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatDuration(widget.asset.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          if (widget.selected)
            Container(
              color: const Color(0xFF00C2FF).withValues(alpha: 0.35),
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                radius: 11,
                backgroundColor: const Color(0xFF00C2FF),
                child: Text(
                  '${widget.index}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
