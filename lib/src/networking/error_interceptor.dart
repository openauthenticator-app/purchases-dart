import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http_client_interceptor/http_client_interceptor.dart';
import 'package:purchases_dart/src/networking/rc_http_status_code.dart';

/// ErrorInterceptor for handling errors in http_client_interceptor,
/// and converting them to custom exceptions.
class ErrorInterceptor extends HttpInterceptor {
  ErrorInterceptor();

  @override
  FutureOr<OnResponse> onResponse(StreamedResponse response) async {
    if (RcHttpStatusCodes.isSuccessful(response.statusCode)) {
      return OnResponse.next(response);
    }

    // For non-successful status codes, we consume the stream to read the body
    // and provide it in the exception if available.
    Response fullResponse = await Response.fromStream(response);
    final responseData = fullResponse.data;

    if (responseData != null) {
      return OnResponse.reject(
        PurchasesNetworkException(
          request: fullResponse.request,
          response: fullResponse,
          message: responseData.toString(),
        ),
      );
    }

    switch (fullResponse.statusCode) {
      case 400:
        return OnResponse.reject(BadRequestException(fullResponse.request));
      case 401:
        return OnResponse.reject(UnauthorizedException(fullResponse.request));
      case 404:
        return OnResponse.reject(NotFoundException(fullResponse.request));
      case 409:
        return OnResponse.reject(ConflictException(fullResponse.request));
      case 500:
        return OnResponse.reject(
          InternalServerErrorException(fullResponse.request),
        );
    }

    return OnResponse.reject(
      PurchasesNetworkException(
        request: fullResponse.request,
        response: fullResponse,
        message: 'Unhandled status code: ${fullResponse.statusCode}',
      ),
    );
  }

  @override
  FutureOr<OnError> onError(
    BaseRequest request,
    Object error,
    StackTrace? stackTrace,
  ) {
    if (error is PurchasesNetworkException) {
      return OnError.next(request, error, stackTrace);
    }

    if (error is SocketException) {
      return OnError.reject(NoInternetConnectionException(request), stackTrace);
    }

    if (error is TimeoutException) {
      return OnError.reject(ConnectionTimeOutException(request), stackTrace);
    }

    if (error is HandshakeException) {
      return OnError.reject(CertificateVerificationFailed(request), stackTrace);
    }

    return OnError.next(request, error, stackTrace);
  }
}

extension ResponseDataExtension on Response {
  /// Returns the decoded JSON body of the response.
  dynamic get data {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}

/// Custom Exceptions

/// Base exception for Purchases network errors.
class PurchasesNetworkException implements Exception {
  final BaseRequest? request;
  final Response? response;
  final String? message;

  PurchasesNetworkException({
    this.request,
    this.response,
    this.message,
  });

  @override
  String toString() => message ?? 'PurchasesNetworkException';
}

/// Exception thrown when there is no internet connection available.
class NoInternetConnectionException extends PurchasesNetworkException {
  static String errorMessage = 'No internet connection detected, please try again';

  NoInternetConnectionException(BaseRequest? request)
      : super(
          request: request,
          message: errorMessage,
        );

  @override
  String toString() => errorMessage;
}

/// Exception thrown when a connection timeout occurs.
class ConnectionTimeOutException extends PurchasesNetworkException {
  ConnectionTimeOutException(BaseRequest? request)
      : super(
          request: request,
          message: 'Connection Timed out, Please try again',
        );

  @override
  String toString() => 'Connection Timed out, Please try again';
}

/// Exception thrown when a send timeout occurs.
class SendTimeOutException extends PurchasesNetworkException {
  SendTimeOutException(BaseRequest? request)
      : super(
          request: request,
          message: 'Send Timed out, Please try again',
        );

  @override
  String toString() => 'Send Timed out, Please try again';
}

/// Exception thrown when a receive timeout occurs.
class ReceiveTimeOutException extends PurchasesNetworkException {
  ReceiveTimeOutException(BaseRequest? request)
      : super(
          request: request,
          message: 'Receive Timed out, Please try again',
        );

  @override
  String toString() => 'Receive Timed out, Please try again';
}

/// Exception thrown when a bad request (HTTP 400) is received from the server.
class BadRequestException extends PurchasesNetworkException {
  BadRequestException(BaseRequest? request)
      : super(
          request: request,
          message: 'Invalid request',
        );

  @override
  String toString() => 'Invalid request';
}

/// Exception thrown when an internal server error (HTTP 500) occurs.
class InternalServerErrorException extends PurchasesNetworkException {
  InternalServerErrorException(BaseRequest? request)
      : super(
          request: request,
          message: 'Internal server error occurred, please try again later.',
        );

  @override
  String toString() => 'Internal server error occurred, please try again later.';
}

/// Exception thrown when a conflict (HTTP 409) occurs.
class ConflictException extends PurchasesNetworkException {
  ConflictException(BaseRequest? request)
      : super(
          request: request,
          message: 'Conflict occurred',
        );

  @override
  String toString() => 'Conflict occurred';
}

/// Exception thrown when an unauthorized request (HTTP 401) is made.
class UnauthorizedException extends PurchasesNetworkException {
  UnauthorizedException(BaseRequest? request)
      : super(
          request: request,
          message: 'Access denied',
        );

  @override
  String toString() => 'Access denied';
}

/// Exception thrown when a resource is not found (HTTP 404).
class NotFoundException extends PurchasesNetworkException {
  NotFoundException(BaseRequest? request)
      : super(
          request: request,
          message: 'The requested information could not be found',
        );

  @override
  String toString() => 'The requested information could not be found';
}

/// Exception thrown when SSL/TLS certificate verification fails.
class CertificateVerificationFailed extends PurchasesNetworkException {
  static String errorMessage = 'Certificate verification failed, please try again later.';

  CertificateVerificationFailed(BaseRequest? request)
      : super(
          request: request,
          message: errorMessage,
        );

  @override
  String toString() => errorMessage;
}
