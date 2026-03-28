/// Header configuration for Purchases API requests.
///
/// Use this class to override default headers when making requests to the RevenueCat API.
/// This is useful for customizing platform information, API keys, or adding additional headers.
class PurchasesHeader {
  /// The platform identifier to use in the X-Platform header.
  String? platform;

  /// An optional API key to use for authorization.
  ///
  /// If provided, this will override the default API key for this request.
  String? apiKey;

  /// Additional custom headers to include in the request.
  Map<String, String>? extra;

  /// Creates a [PurchasesHeader] with optional platform, API key, and extra headers.
  ///
  /// [platform] The platform identifier (e.g., 'web-billing').
  /// [apiKey] An optional API key to override the default.
  /// [extra] Additional custom headers to include.
  PurchasesHeader({
    this.platform,
    this.apiKey,
    this.extra,
  });

  /// Converts this header configuration to Dio [Options] for use in HTTP requests.
  Map<String, String>? get map {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Platform': 'web-billing',
      if (platform != null) 'X-Platform': platform!,
      if (apiKey != null) 'Authorization': 'Bearer $apiKey',
      if (extra != null) ...extra!,
    };
    return headers.isEmpty ? null : headers;
  }
}
