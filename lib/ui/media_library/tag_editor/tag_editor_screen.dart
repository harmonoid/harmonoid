import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tag_writer/tag_writer.dart';

import 'package:harmonoid/core/filesystem_media_library.dart';
import 'package:harmonoid/extensions/shape_border.dart';
import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/ui/media_library/media_library_menus.dart';
import 'package:harmonoid/ui/media_library/tag_editor/search/search_dialog.dart';
import 'package:harmonoid/ui/media_library/tag_editor/state/tag_editor_notifier.dart';
import 'package:harmonoid/ui/media_library/tag_editor/tag_editor_no_tags_banner.dart';
import 'package:harmonoid/utils/async_file_image.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:harmonoid/utils/widgets.dart';

class TagEditorScreen extends StatefulWidget {
  final String resource;
  final bool demo;
  const TagEditorScreen({super.key, required this.resource, this.demo = false});

  @override
  State<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends State<TagEditorScreen> with ScrollControllerMixin {
  late final ScrollController _controller = getScrollController('tag-editor-screen');

  void _onPopInvokedWithResult(BuildContext context, bool didPop, Object? result) async {
    if (didPop) return;

    if (context.read<TagEditorNotifier>().propertiesChanged || context.read<TagEditorNotifier>().coverChanged) {
      final result = await showConfirmation(
        context,
        Localization.instance.WARNING,
        Localization.instance.TAG_EDITOR_UNSAVED_CHANGES_DIALOG_SUBTITLE,
        barrierDismissible: false,
      );
      if (result) return;
    }

    if (context.read<TagEditorNotifier>().saveInvoked) {
      recursivelyPopNavigator();
    } else {
      context.pop();
    }
  }

  Widget _buildCover(BuildContext context) {
    return Consumer<TagEditorNotifier>(
      builder: (context, notifier, _) {
        final data = notifier.cover?.data;
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: Theme.of(context).cardTheme.shape?.subtractBorderRadius(BorderRadius.circular(8.0)) ?? BorderRadius.zero,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IgnorePointer(
                    ignoring: notifier.coverLoading,
                    child: HoverActions(
                      actions: [
                        HoverActionsData(
                          label: Localization.instance.TAG_EDITOR_SET_COVER,
                          icon: Icons.edit,
                          onTap: notifier.setCover,
                        ),
                        if (notifier.cover == null && notifier.oldCover != null)
                          HoverActionsData(
                            label: Localization.instance.TAG_EDITOR_REVERT_COVER,
                            icon: Icons.undo,
                            onTap: notifier.revertCover,
                          )
                        else
                          HoverActionsData(
                            label: Localization.instance.TAG_EDITOR_REMOVE_COVER,
                            icon: Icons.delete,
                            onTap: notifier.removeCover,
                          ),
                        HoverActionsData(
                          label: Localization.instance.TAG_EDITOR_EXPORT_COVER,
                          icon: Icons.file_download,
                          onTap: notifier.exportCover,
                        ),
                      ],
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Image(
                          image: data == null
                              ? AsyncFileImage(
                                  'unknown-cover',
                                  FileSystemMediaLibrary.instance.getDefaultCoverFile,
                                  FileSystemMediaLibrary.instance.getDefaultCoverFile,
                                )
                              : MemoryImage(data),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (notifier.coverLoading) const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProperties(BuildContext context) {
    return Consumer<TagEditorNotifier>(
      builder: (context, notifier, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.0,
            children: [
              if (notifier.properties.isEmpty)
                const TagEditorNoTagsBanner()
              else
                ...notifier.properties.entries.map(
                  (e) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              Localization.instance.TAG_EDITOR_KEY.replaceAll('"KEY"', e.key),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Tooltip(
                              message: Localization.instance.TAG_EDITOR_REMOVE_PROPERTY,
                              child: GestureDetector(
                                onTap: () => notifier.removeProperty(e.key),
                                child: const Icon(
                                  Icons.close,
                                  size: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      DefaultTextFormField(
                        controller: e.value,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info, size: 16.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      Localization.instance.TAG_EDITOR_SEPARATORS_INFO,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  final property = await showSelection<String>(
                    context,
                    Localization.instance.TAG_EDITOR_ADD_PROPERTY,
                    TagWriter.kProperties,
                    null,
                    (key) => key,
                    trailing: (key) => notifier.properties.containsKey(key) ? Icon(Icons.check_circle, size: 16.0, color: Theme.of(context).colorScheme.primary) : null,
                    actions: false,
                    radio: false,
                  );
                  if (property != null) {
                    notifier.addProperty(property);

                    Future.delayed(
                      const Duration(milliseconds: 500),
                      () => _controller.animateTo(
                        _controller.position.maxScrollExtent,
                        duration: Theme.of(context).extension<AnimationDuration>()?.medium ?? Duration.zero,
                        curve: Curves.easeInOut,
                      ),
                    );
                  }
                },
                child: Text(label(Localization.instance.TAG_EDITOR_ADD_PROPERTY)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return ActionChip(
      onPressed: () async {
        final result = await showDialog(
          context: context,
          builder: (context) => const SearchDialog(),
        );
        if (result != null) {
          context.read<TagEditorNotifier>().setFromTrackSearchResult(result);
        }
      },
      padding: const EdgeInsets.all(4.0),
      label: Text(Localization.instance.TAG_EDITOR_FILL_FROM_INTERNET),
      labelStyle: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildSaveFloatingActionButton(BuildContext context) {
    return Consumer<TagEditorNotifier>(
      builder: (context, notifier, _) => (notifier.propertiesLoading || notifier.coverLoading) || !(notifier.propertiesChanged || notifier.coverChanged)
          ? const SizedBox.shrink()
          : FloatingActionButton(
              onPressed: notifier.save,
              tooltip: Localization.instance.SAVE,
              child: const Icon(Icons.save),
            ),
    );
  }

  List<Widget> _buildDesktopSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SizedBox(
                width: 360.0,
                child: _buildCover(context),
              ),
            ),
            const VerticalDivider(width: 1.0, thickness: 1.0),
            Flexible(
              child: SizedBox(
                width: kDesktopCenteredLayoutWidth,
                child: _buildProperties(context),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildTabletSlivers(BuildContext context) {
    throw UnimplementedError();
  }

  List<Widget> _buildMobileSlivers(BuildContext context) {
    return [
      SliverList.list(
        children: [
          _buildCover(context),
          _buildProperties(context),
        ],
      ),
    ];
  }

  List<Widget> _buildSlivers(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopSlivers(context);
    }
    if (isTablet) {
      return _buildTabletSlivers(context);
    }
    if (isMobile) {
      return _buildMobileSlivers(context);
    }
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TagEditorNotifier(
        resource: widget.resource,
        onError: (error) => showMessage(
          context,
          Localization.instance.ERROR,
          error,
        ),
      ),
      child: Consumer<TagEditorNotifier>(
        builder: (context, notifier, _) => Consumer<TagEditorNotifier>(
          builder: (context, notifier, _) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) => _onPopInvokedWithResult(context, didPop, result),
              child: SliverContentScreen(
                caption: kCaption,
                title: Localization.instance.EDIT_TAGS + (widget.demo ? ' ${Localization.instance.DEMO_HINT}' : ''),
                slivers: notifier.propertiesLoading ? [const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))] : _buildSlivers(context),
                trailing: _buildTrailing(context),
                floatingActionButton: _buildSaveFloatingActionButton(context),
                scrollController: _controller,
              ),
            );
          },
        ),
      ),
    );
  }
}
