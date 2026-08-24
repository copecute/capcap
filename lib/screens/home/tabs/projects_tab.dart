import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/project_provider.dart';
import '../../../widgets/project_thumb.dart';
import '../../media/media_picker_screen.dart';

class ProjectsTab extends StatelessWidget {
  final AppLocalizations l;
  const ProjectsTab({super.key, required this.l});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projects = context.watch<ProjectProvider>().projects;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  l.get('projects_title'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Icon(Icons.search_rounded, color: isDark ? Colors.white70 : Colors.black54),
              ],
            ),
          ),
          Expanded(
            child: projects.isEmpty
                ? Center(
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
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
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
                            onPressed: () => context.read<ProjectProvider>().removeProject(project.id),
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
