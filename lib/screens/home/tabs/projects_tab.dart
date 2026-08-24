import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/editor_project.dart';
import '../../../providers/project_provider.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/project_thumb.dart';
import '../../media/media_picker_screen.dart';

class ProjectsTab extends StatelessWidget {
  final AppLocalizations l;
  const ProjectsTab({super.key, required this.l});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final layout = AppLayout.of(context);
    final pad = layout.pagePadding;
    final projects = context.watch<ProjectProvider>().projects;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
            child: Row(
              children: [
                Text(
                  l.get('projects_title'),
                  style: TextStyle(
                    fontSize: layout.useSidebar ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54),
              ],
            ),
          ),
          Expanded(
            child: projects.isEmpty
                ? _EmptyProjects(l: l, isDark: isDark)
                : layout.useSidebar
                    ? GridView.builder(
                        padding: EdgeInsets.all(pad),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: projects.length,
                        itemBuilder: (context, i) => _ProjectCard(
                          project: projects[i],
                          l: l,
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(pad),
                        itemCount: projects.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final project = projects[i];
                          return Material(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              leading: ProjectThumb(
                                path: project.thumbnailPath,
                                projectType: project.type,
                                width: 44,
                                height: 44,
                                radius: 22,
                              ),
                              title: Text(project.name),
                              subtitle: Text('${project.assetCount} ${l.get('items')}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () => context
                                    .read<ProjectProvider>()
                                    .removeProject(project.id),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProjects extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  const _EmptyProjects({required this.l, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isDark ? const Color(0xFF252538) : const Color(0xFFF0F0F8),
            ),
            child: Icon(
              Icons.folder_off_rounded,
              size: 40,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.get('no_projects'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            l.get('no_projects_sub'),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MediaPickerScreen(
                    l: l,
                    mode: MediaPickerMode.video,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.get('new_video')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C2FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final EditorProject project;
  final AppLocalizations l;
  const _ProjectCard({required this.project, required this.l});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ProjectThumb(
              path: project.thumbnailPath,
              projectType: project.type,
              width: double.infinity,
              height: double.infinity,
              radius: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${project.assetCount} ${l.get('items')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () =>
                      context.read<ProjectProvider>().removeProject(project.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
