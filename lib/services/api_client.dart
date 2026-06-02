import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_store.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://bicho-capiba-back.onrender.com/',
  );
  final dio = Dio(
    BaseOptions(
      baseUrl: '${baseUrl}api',
      connectTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 40),
      extra: {'withCredentials': true},
    ),
  );

  final tokenStore = ref.read(tokenStoreProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final cookie = await tokenStore.read();
        if (cookie != null && cookie.isNotEmpty) {
          options.headers['Cookie'] = cookie;
        }
        handler.next(options);
      },
      onResponse: (response, handler) async {
        final setCookie = response.headers.map['set-cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          final authCookie = setCookie
              .map((c) => c.split(';').first.trim())
              .firstWhere(
                (c) => c.startsWith('auth_token='),
                orElse: () => '',
              );
          if (authCookie.isNotEmpty) {
            await tokenStore.write(authCookie);
          }
        }
        handler.next(response);
      },
    ),
  );

  return dio;
});
