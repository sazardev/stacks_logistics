import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Network configuration and utilities
class NetworkConfig {
  /// Creates a configured Dio instance
  static Dio createDio() {
    final dio = Dio();

    // Base options
    dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authentication token if available
          // This will be implemented when we add auth
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          // Log error details
          print('Network Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    return dio;
  }
}

/// Network utilities
class NetworkUtils {
  /// Checks if the response is successful
  static bool isSuccessResponse(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  /// Extracts error message from response
  static String extractErrorMessage(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response['message'] ??
          response['error'] ??
          response['detail'] ??
          'Unknown error occurred';
    }
    return 'Unknown error occurred';
  }

  /// Creates query parameters map
  static Map<String, dynamic> createQueryParameters({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? filters,
  }) {
    final params = <String, dynamic>{};

    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (sortBy != null && sortBy.isNotEmpty) params['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty)
      params['sortOrder'] = sortOrder;

    if (filters != null) {
      params.addAll(filters);
    }

    return params;
  }
}
