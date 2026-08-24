import 'dart:async';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/editor_project.dart';
import '../../../providers/project_provider.dart';
import '../../../services/thumb_cache.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/project_thumb.dart';
import '../../media/media_picker_screen.dart';

class EditTab extends StatelessWidget {
  final AppLocalizations l;
  const EditTab({super.key, required this.l});

  Future<void> _openPicker(BuildContext context, MediaPickerMode mode) async {
    final selected = await Navigator.of(context).push<List<AssetEntity>>(
      MaterialPageRoute(
        builder: (_) => MediaPickerScreen(l: l, mode: mode),
      ),
    );
    if (selected == null || selected.isEmpty || !context.mounted) return;
    final projects = context.read<ProjectProvider>();
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();

    final type = mode == MediaPickerMode.photo ? 'photo' : 'video';

    // Thumb logic:
    // - If the user is creating a video project, use the first selected video as thumbnail.
    // - If there is no video selected, fallback to the first selected asset (photo).
    // - For photo projects, use the first (and only) selected photo.
    final thumbAsset = switch (mode) {
      MediaPickerMode.photo => selected.first,
      MediaPickerMode.video =>
        selected.firstWhere(
          (a) => a.type == AssetType.video,
          orElse: () => selected.first,
        ),
    };

    final thumbPath = await _cacheThumbnail(id, thumbAsset);

    projects.addProject(
      EditorProject(
        id: id,
        name:
            '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}',
        type: type,
        createdAt: now,
        assetCount: selected.length,
        thumbnailPath: thumbPath,
      ),
    );
  }

  Future<String?> _cacheThumbnail(String projectId, AssetEntity asset) async {
    try {
      final data = await asset.thumbnailDataWithSize(const ThumbnailSize(240, 240));
      if (data == null || data.isEmpty) return null;
      return await ThumbCache.saveBytes('p_$projectId', data);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final layout = AppLayout.of(context);
    final pad = layout.pagePadding;
    final projects = context.watch<ProjectProvider>().projects;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _BannerSlideshow(l: l, layout: layout),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _CreateButtons(
                      l: l,
                      isDark: isDark,
                      wide: layout.useSidebar,
                      onNewVideo: () => _openPicker(context, MediaPickerMode.video),
                      onEditPhoto: () => _openPicker(context, MediaPickerMode.photo),
                    ),
                    if (projects.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        l.get('tab_project'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RecentProjects(
                        isDark: isDark,
                        l: l,
                        projects: projects,
                        desktop: layout.useSidebar,
                      ),
                    ],
                    const SizedBox(height: 28),
                    _ToolsGrid(l: l, isDark: isDark, layout: layout),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerSlideshow extends StatefulWidget {
  final AppLocalizations l;
  final AppLayout layout;
  const _BannerSlideshow({required this.l, required this.layout});

  @override
  State<_BannerSlideshow> createState() => _BannerSlideshowState();
}

class _BannerSlideshowState extends State<_BannerSlideshow> {
  static const _banners = [
    'assets/images/banner-1.jpg',
    'assets/images/banner-2.jpg',
  ];
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;
  bool _searchOpen = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_index + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final desktop = widget.layout.useSidebar;
    final bannerHeight = widget.layout.isExpanded
        ? 320.0
        : (desktop ? 240.0 : 200.0);
    final overlayTop = desktop ? 12.0 : top + 8;
    return Padding(
      padding: desktop
          ? EdgeInsets.fromLTRB(
              widget.layout.pagePadding,
              top + 16,
              widget.layout.pagePadding,
              0,
            )
          : EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: desktop ? BorderRadius.circular(20) : BorderRadius.zero,
        child: SizedBox(
          height: desktop ? bannerHeight : bannerHeight + top,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _banners.length,
                itemBuilder: (context, i) {
                  return Image.asset(
                    _banners[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x99000000)],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: overlayTop,
                right: 12,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: widget.l.get('search'),
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    onPressed: () => setState(() => _searchOpen = !_searchOpen),
                  ),
                ),
              ),
              if (_searchOpen)
                Positioned(
                  top: overlayTop,
                  left: 12,
                  right: 64,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: widget.l.get('search_hint'),
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_banners.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 16 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: active ? Colors.white : Colors.white54,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateButtons extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  final bool wide;
  final VoidCallback onNewVideo;
  final VoidCallback onEditPhoto;
  const _CreateButtons({
    required this.l,
    required this.isDark,
    required this.wide,
    required this.onNewVideo,
    required this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Expanded(
          child: _CreateCard(
            icon: Icons.add_rounded,
            label: l.get('new_video'),
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF252540)],
            ),
            onTap: onNewVideo,
            tall: wide,
          ),
        ),
        SizedBox(width: wide ? 16 : 12),
        Expanded(
          child: _CreateCard(
            icon: Icons.photo_rounded,
            label: l.get('edit_photo'),
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF252540)]
                  : [Colors.white, const Color(0xFFF5F5F5)],
            ),
            onTap: onEditPhoto,
            isLight: !isDark,
            tall: wide,
          ),
        ),
      ],
    );
    if (!wide) return row;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: row,
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool isLight;
  final bool tall;

  const _CreateCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.isLight = false,
    this.tall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: tall ? 108 : 80,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: isLight ? Border.all(color: Colors.black.withValues(alpha: 0.08)) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  icon,
                  color: isLight ? Colors.black87 : Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isLight ? Colors.black87 : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentProjects extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final List<EditorProject> projects;
  final bool desktop;
  const _RecentProjects({
    required this.isDark,
    required this.l,
    required this.projects,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final w = desktop ? 120.0 : 70.0;
    final h = desktop ? 132.0 : 80.0;
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        separatorBuilder: (_, __) => SizedBox(width: desktop ? 12 : 8),
        itemBuilder: (context, i) {
          final project = projects[i];
          return SizedBox(
            width: w,
            child: Stack(
              children: [
                ProjectThumb(
                  path: project.thumbnailPath,
                  projectType: project.type,
                  width: w,
                  height: h,
                  radius: 12,
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => context.read<ProjectProvider>().removeProject(project.id),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToolsGrid extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  final AppLayout layout;
  const _ToolsGrid({
    required this.l,
    required this.isDark,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = layout.gridColumns(
      compact: 3,
      medium: 5,
      expanded: 8,
    );

    final tools = [
      _Tool(Icons.content_cut_rounded, l.get('autocut'), const Color(0xFF00C2FF)),
      _Tool(Icons.face_retouching_natural_rounded, l.get('beauty'), const Color(0xFFFF6B9D)),
      _Tool(Icons.photo_library_rounded, l.get('photo_tool'), const Color(0xFF9B59B6)),
      _Tool(Icons.videocam_rounded, l.get('record'), const Color(0xFF2ECC71)),
      _Tool(Icons.auto_fix_high_rounded, l.get('auto_enhance'), const Color(0xFF00C2FF)),
      _Tool(Icons.subtitles_rounded, l.get('auto_subtitle'), const Color(0xFFE67E22)),
      _Tool(Icons.auto_awesome_rounded, l.get('ai_sticker'), const Color(0xFF3498DB)),
      _Tool(Icons.content_cut_rounded, l.get('ai_cut'), const Color(0xFFE74C3C)),
      _Tool(Icons.image_not_supported_rounded, l.get('remove_bg'), const Color(0xFF1ABC9C)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: layout.useSidebar ? 0.92 : 1.0,
      ),
      itemCount: tools.length,
      itemBuilder: (context, i) {
        final tool = tools[i];
        return GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: tool.color.withValues(alpha: isDark ? 0.18 : 0.12),
                ),
                child: Icon(tool.icon, color: tool.color, size: 26),
              ),
              const SizedBox(height: 6),
              Text(
                tool.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tool {
  final IconData icon;
  final String label;
  final Color color;
  const _Tool(this.icon, this.label, this.color);
}
