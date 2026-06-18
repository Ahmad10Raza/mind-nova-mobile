import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestNotifier extends AsyncNotifier<String> {
  final int arg;
  TestNotifier(this.arg);

  @override
  Future<String> build() async {
    return arg.toString();
  }
}

final testProvider = AsyncNotifierProvider.family<TestNotifier, String, int>((arg) => TestNotifier(arg));
