import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:token_master/core/bloc/bloc.dart';
import 'package:token_master/core/api/model.dart';
import 'package:token_master/core/widgets/storage.dart';
import 'dart:math';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  late AuthBloc authBloc;
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _twoFaController = TextEditingController();
  bool is2Fa = false;
  List<Widget> userBots = [
    CupertinoListTile(
      title: const Text('AlyaLP'),
      leading: ClipOval(
        child: Image.asset('assets/icons/ub/alya.png'),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () async {
        final _url = Uri.parse('https://t.me/alyalp');
        if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $_url');
        }
      },
    ),
    CupertinoListTile(
      title: const Text('Hella'),
      leading: Image.asset('assets/icons/ub/hella.png'),
      trailing: const CupertinoListTileChevron(),
      onTap: () async {
        final _url = Uri.parse('https://t.me/hella_news');
        if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $_url');
        }
      },
    ),
    CupertinoListTile(
      title: const Text('UnutyLP'),
      leading: ClipOval(
        child: Image.asset('assets/icons/ub/unuty.png'),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () async {
        final _url = Uri.parse('https://t.me/unutylp');
        if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $_url');
        }
      },
    ),
  ];

  @override
  void initState() {
    authBloc = context.read<AuthBloc>();
    super.initState();
  }

  @override
  void dispose() {
    authBloc.close();
    super.dispose();
  }

  void showCreateTokenDialog(TypeAuth typeAuth) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Получение токена'),
          content: Column(
            children: [
              const SizedBox(height: 12,),
              CupertinoTextField(controller: _loginController, placeholder: 'Логин', obscureText: true,),
              const SizedBox(height: 6,),
              CupertinoTextField(controller: _passwordController, placeholder: 'Пароль', obscureText: true,),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Назад'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: const Text('Получить'),
              onPressed: () {
                authBloc.add(LoginEvent(
                  login: _loginController.text,
                  password: _passwordController.text,
                  typeAuth: typeAuth,
                ));
              },
            ),
          ],
        );
      },
    );
  }

  void show2FACreateTokenDialog(TypeAuth typeAuth) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Двухфакторная аутентификация'),
          content: Column(
            children: [
              const SizedBox(height: 12,),
              CupertinoTextField(controller: _twoFaController, placeholder: '2FA Code'),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Готово'),
              onPressed: () {
                Navigator.of(context).pop();
                authBloc.add(LoginEvent(
                  login: _loginController.text,
                  password: _passwordController.text,
                  typeAuth: typeAuth,
                  code: _twoFaController.text,
                ));
              },
            ),
          ],
        );
      },
    );
  }

  void showMessageDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('Закрыть'),
              onPressed: () {
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
    userBots.shuffle(Random());
    bool isDartMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showMessageDialog("Ошибка", state.message);
        } else if (state is AuthNeedCode) {
          Navigator.of(context).pop();
          show2FACreateTokenDialog(state.typeAuth);
        } else if (state is AuthCaptcha) {
          showMessageDialog("Captcha", "Необходимо подождать.");
        } else if (state is AuthAuthenticated) {
          Storage.addToken(state.accessToken);
          showMessageDialog("Успешно", "Токен находится в хранилище.");
        }
      },
      builder: (context, state) {
        print(state);
        if (state is AuthLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return Column(
          children: [
            CupertinoListSection(
              header: const Text('Доступные токены'),
              children: [
                CupertinoListTile(
                  title: const Text('Me'),
                  leading: Image.asset('assets/icons/VKMe.png'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => showCreateTokenDialog(TypeAuth.Me),
                ),
                CupertinoListTile(
                  title: const Text('iPhone'),
                  leading: Image.asset('assets/icons/iPhone.png'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => showCreateTokenDialog(TypeAuth.iPhone),
                ),
                CupertinoListTile(
                  title: const Text('Android'),
                  leading: Image.asset('assets/icons/Android.png'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => showCreateTokenDialog(TypeAuth.Android),
                ),
              ],
            ),
            CupertinoListSection(
              header: const Text('Разработчик t.me/robert_meow'),
              children: [
                CupertinoListTile(
                  title: const Text('Telegram канал'),
                  leading: SvgPicture.asset('assets/icons/Telegram.svg'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                    final _url = Uri.parse('https://t.me/berht_dev');
                    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $_url');
                    }
                  },
                ),
                CupertinoListTile(
                  title: const Text('GitHub'),
                  leading: isDartMode ? SvgPicture.asset('assets/icons/GitHubWhite.svg') : SvgPicture.asset('assets/icons/GitHub.svg'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () async {
                    final _url = Uri.parse('https://github.com/RobertMeow');
                    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $_url');
                    }
                  },
                ),
              ],
            ),
            CupertinoListSection(
              header: const Text('Лучшие UserBots'),
              children: userBots,
            ),
          ],
        );
      },
    );
  }
}
