enum TypeAuth {
  Android,
  iPhone,
  Me,
}

class UserAgent {
  String value;

  UserAgent(this.value);

  static final UserAgent Android = UserAgent("VKAndroidApp/7.7-11871 (Android 13; SDK 30; arm64-v8a; berht.dev; ru; 3040x1440)");
  static final UserAgent iPhone = UserAgent("com.vk.vkclient/2990 (iPhone, iOS 15.4.1, iPhone10,6, Scale/2.0)");
  static final UserAgent Me = UserAgent("VKAndroidApp/7.7-11871 (Android 13; SDK 30; arm64-v8a; berht.dev; ru; 3040x1440)");

  @override
  String toString() {
    return value;
  }
}
