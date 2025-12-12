import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/material.dart';

import 'package:harmonoid/localization/localization.dart';
import 'package:harmonoid/utils/constants.dart';
import 'package:harmonoid/utils/rendering.dart';
import 'package:tag_reader/tag_reader.dart';
import 'package:tag_writer/tag_writer.dart';

class TagEditorNotifier extends ChangeNotifier {
  TagEditorNotifier({required this.resource, this.onError}) {
    _ensureInitialized();
  }

  final String resource;
  final void Function(TagWriterException)? onError;
  bool loading = false;
  TagWriter? _writer;

  @override
  void dispose() {
    super.dispose();
    _writer?.dispose();
  }

  Future<void> _ensureInitialized() async {
    final Tags tags;

    final reader = TagReader(configuration: const TagReaderConfiguration(verbose: true));
    tags = await reader.parse(resource);
    await reader.dispose();

    _writer = TagWriter(tags.uri, fileFormat: tags.fileFormat, audioCodec: tags.audioCodec);
  }
}

class TagEditorScreen extends StatefulWidget {
  final String resource;
  const TagEditorScreen({super.key, required this.resource});

  @override
  State<TagEditorScreen> createState() => _TagEditorScreenState();
}

class _TagEditorScreenState extends State<TagEditorScreen> {
  Widget _buildDesktopLayout(BuildContext context) {
    return SliverContentScreen(
      caption: kCaption,
      title: Localization.instance.EDIT_TAGS,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Placeholder(),
              const VerticalDivider(width: 1.0, thickness: 1.0),
              Flexible(
                child: SizedBox(
                  width: kDesktopCenteredLayoutWidth,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    throw UnimplementedError();
  }

  Widget _buildMobileLayout(BuildContext context) {
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopLayout(context);
    }
    if (isTablet) {
      return _buildTabletLayout(context);
    }
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    throw UnimplementedError();
  }
}
