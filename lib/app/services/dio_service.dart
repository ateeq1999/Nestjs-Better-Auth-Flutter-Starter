import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class DioService extends GetxService {
  late final dio_pkg.Dio _dio;

  dio_pkg.Dio get dio => _dio;

  Future<DioService> init() async {
    _dio = dio_pkg.Dio(
      dio_pkg.BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'http://10.0.2.2:5555',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      dio_pkg.InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    return this;
  }

  void _onRequest(
    dio_pkg.RequestOptions options,
    dio_pkg.RequestInterceptorHandler handler,
  ) {
    handler.next(options);
  }

  void _onResponse(
    dio_pkg.Response response,
    dio_pkg.ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  void _onError(
    dio_pkg.DioException err,
    dio_pkg.ErrorInterceptorHandler handler,
  ) {
    handler.next(err);
  }
}
