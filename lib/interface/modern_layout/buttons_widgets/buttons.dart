import 'package:flutter/material.dart';

import 'package:harmonoid/constants/language.dart';
import 'package:harmonoid/core/collection.dart';
import 'package:harmonoid/interface/modern_layout/utils_modern/broken_icons.dart';
import 'package:harmonoid/web/utils/widgets.dart';

class CreatePlaylistButton extends StatelessWidget {
  const CreatePlaylistButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String text = '';
        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          // elevation: kDefaultHeavyElevation,
          useRootNavigator: true,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return Container(
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom -
                      MediaQuery.of(context).padding.bottom,
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4.0),
                    TextField(
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      onChanged: (value) => text = value,
                      onSubmitted: (String value) async {
                        if (value.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          await Collection.instance
                              .playlistCreateFromName(value);
                          Navigator.of(context).maybePop();
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(
                          12,
                          30,
                          12,
                          6,
                        ),
                        hintText: Language.instance.PLAYLISTS_TEXT_FIELD_LABEL,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .iconTheme
                                .color!
                                .withOpacity(0.4),
                            width: 1.8,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .iconTheme
                                .color!
                                .withOpacity(0.4),
                            width: 1.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (text.isNotEmpty) {
                          FocusScope.of(context).unfocus();
                          await Collection.instance.playlistCreateFromName(
                            text,
                          );
                          Navigator.of(context).maybePop();
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      child: Text(
                        Language.instance.CREATE.toUpperCase(),
                        style: const TextStyle(
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      child: Row(
        children: [
          Icon(Broken.edit),
          const SizedBox(
            width: 8.0,
          ),
          Text(Language.instance.CREATE)
        ],
      ),
    );
  }
}

class ImportPlaylistButton extends StatelessWidget {
  const ImportPlaylistButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          constraints: BoxConstraints(
            maxHeight: double.infinity,
          ),
          context: context,
          // elevation: kDefaultHeavyElevation,
          useRootNavigator: true,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return PlaylistImportBottomSheet();
            },
          ),
        );
      },
      child: Row(
        children: [
          Icon(Broken.document_download),
          const SizedBox(
            width: 8.0,
          ),
          Text(Language.instance.IMPORT)
        ],
      ),
    );
  }
}
