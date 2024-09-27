import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class CacheRepository {
  String requestsCacheBox = 'userSDKRequestsCache';
  String userCacheBox = 'userSDKCache';
  String userKeyKey = 'userk';

  late final Box requestsBox;
  late final Box box;

  final StreamController<String?> _userKeyController = StreamController<String?>.broadcast();
  Stream<String?> get userKeyStream => _userKeyController.stream;

  Future<void> initialize({required String instanceName}) async {
    requestsCacheBox = "$requestsCacheBox-$instanceName";
    userCacheBox = "$userCacheBox-$instanceName";
    userKeyKey = "$userKeyKey-$instanceName";

    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    await Hive.openBox<dynamic>(requestsCacheBox);
    await Hive.openBox<dynamic>(userCacheBox);

    requestsBox = Hive.box<dynamic>(requestsCacheBox);
    box = Hive.box<dynamic>(userCacheBox);
  }

  void saveInvalidRequest(Map<String, dynamic> jsonRequest) {
    requestsBox.add(jsonEncode(jsonRequest));
  }

  void removeRequest({required int key}) {
    requestsBox.delete(key);
  }

  List<HiveObject> getCachedRequests() {
    List<HiveObject> requests = [];

    for (int i = 0; i < requestsBox.length; i++) {
      requests.add(
        HiveObject(
          key: requestsBox.keys.toList()[i],
          object: jsonDecode(requestsBox.values.toList()[i]) as Map<String, dynamic>,
        ),
      );
    }
    return requests;
  }

  void addUserKey(String? userKey) {
    box.put(userKeyKey, userKey);

    _userKeyController.add(userKey);
  }

  String? getUserKey() {
    return box.get(userKeyKey);
  }

  Future<void> clearStorage() async {
    await box.clear();
    await requestsBox.clear();
  }
}

class HiveObject {
  final int key;
  final Map<String, dynamic> object;

  HiveObject({
    required this.key,
    required this.object,
  });
}
