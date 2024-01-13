import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:token_master/core/widgets/storage.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _tokenController = TextEditingController();
  List<String> _tokens = [];

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final tokens = await Storage.loadTokens();
    setState(() {
      _tokens = tokens;
    });
  }

  Future<void> _addToken(String token) async {
    await Storage.addToken(token);
    _loadTokens();
  }

  Future<void> _delToken(String token) async {
    await Storage.delToken(token);
    _loadTokens();
  }

  void showAddTokenDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Добавление токена'),
          content: CupertinoTextField(controller: _tokenController),
          actions: [
            CupertinoDialogAction(
              child: const Text('Назад'),
              onPressed: () {
                _tokenController.clear();
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Добавить'),
              onPressed: () {
                _addToken(_tokenController.text);
                _tokenController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton(
          onPressed: showAddTokenDialog,
          child: const Text('Добавить токен вручную'),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            itemCount: _tokens.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: CupertinoContextMenu(
                  actions: [
                    CupertinoContextMenuAction(
                      onPressed: () {
                        _delToken(_tokens[index]);
                        Navigator.pop(context);
                      },
                      trailingIcon: CupertinoIcons.delete,
                      child: const Text('Удалить'),
                    ),
                    CupertinoContextMenuAction(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _tokens[index]));
                        Navigator.pop(context);
                      },
                      trailingIcon: CupertinoIcons.share,
                      child: const Text('Скопировать'),
                    ),
                  ],
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    color: const CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.systemGroupedBackground,
                      darkColor: CupertinoColors.black,
                    ).resolveFrom(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CupertinoListTile(
                        backgroundColor: const CupertinoDynamicColor.withBrightness(
                          color: CupertinoColors.white,
                          darkColor: CupertinoColors.systemFill,
                        ).resolveFrom(context),
                        title: SizedBox(
                          width: 100,
                          child: Text(
                            _tokens[index],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: const Text('тут типа всякая инфа о токене'),
                        additionalInfo: GestureDetector(
                          onTap: () {},
                          child: const Icon(
                            CupertinoIcons.refresh_bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
