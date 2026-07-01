/// Backend API configuration.
/// baseUrl must point to your PC's local network IP (not localhost),
/// since the phone and PC are separate devices on the network.
class ApiConstants {
  ApiConstants._();

  // TODO: Replace with your PC's local IP + your backend's port.
  // Find your IP: open PowerShell and run `ipconfig`, look for
  // "IPv4 Address" under your Wi-Fi adapter (e.g. 192.168.1.42).
  // Run your backend with `dotnet run` and check which port it uses.
  static const String baseUrl = 'http://192.168.x.xx:5292/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Auth endpoints (used directly by DioClient's refresh logic below)
  static const String refreshTokenEndpoint = '/auth/refresh-token';
}