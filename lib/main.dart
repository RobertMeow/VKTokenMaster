import 'package:flutter/cupertino.dart';
import 'package:token_master/core/pages/home.dart';

void main() => runApp(TokenMasterApp());

class TokenMasterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Token Master',
      home: TokenMasterHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
