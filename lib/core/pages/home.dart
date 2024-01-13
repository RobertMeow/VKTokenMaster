import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:token_master/core/pages/first.dart';
import 'package:token_master/core/pages/second.dart';

import '../bloc/bloc.dart';

class TokenMasterHomePage extends StatefulWidget {
  int segmentedControlGroupValue;

  TokenMasterHomePage({
    super.key,
    this.segmentedControlGroupValue = 0,
  });

  @override
  _TokenMasterHomePageState createState() => _TokenMasterHomePageState();
}

class _TokenMasterHomePageState extends State<TokenMasterHomePage> {
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text('Создание'),
    1: Text('Хранилище'),
  };

  Widget buildContent() {
    switch (widget.segmentedControlGroupValue) {
      case 0:
        return BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
          child: const FirstPage(),
        );
      case 1:
        return const SecondPage();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const CupertinoDynamicColor.withBrightness(
        color: CupertinoColors.systemGroupedBackground,
        darkColor: CupertinoColors.black,
      ),
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/VKLogo.svg',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 8,),
            const Text('Token Master'),
          ],
        ),
      ),
      child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CupertinoSlidingSegmentedControl<int>(
                    children: myTabs,
                    onValueChanged: (int? value) {
                      setState(() {
                        widget.segmentedControlGroupValue = value!;
                      });
                    },
                    groupValue: widget.segmentedControlGroupValue,
                  ),
                ),
                Flexible(
                  child: Center(
                    child: buildContent(),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
