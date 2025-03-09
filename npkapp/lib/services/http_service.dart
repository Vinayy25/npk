import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  // Base URL for the FastAPI server
  // Note: When running on an emulator or physical device,
  // '127.0.0.1' or 'localhost' refers to the device itself, not your development machine
  // For emulator, use 10.0.2.2 to access host machine
  // For physical device, use the actual IP address of your Raspberry Pi

  // static const String baseUrl =
  //     'http://127.0.0.1:8000'; // Update with your Pi's IP

  static const String baseUrl =
      'http://192.168.96.171:8000'; // Update with your Pi's IP

  // Endpoint for NPK data
  static const String npkEndpoint = '/npk-data';

  // Fetch NPK data from the API
  static Future<Map<String, dynamic>?> fetchNPKData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$npkEndpoint'))
          .timeout(
              const Duration(seconds: 3)); // Add timeout to prevent hanging

      if (response.statusCode == 200) {
        // Check for empty response body
        if (response.body.isEmpty) {
          print('Empty response body received');
          return null;
        }

        try {
          final data = json.decode(response.body);
          return data;
        } catch (e) {
          print('JSON decode error: $e');
          return null;
        }
      } else if (response.statusCode >= 500) {
        // Handle internal server errors (5xx)
        print('Internal server error: ${response.statusCode}');
        return null;
      } else {
        // Handle other error status codes
        print('Error fetching NPK data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle network errors, timeouts, etc.
      print('Exception when fetching NPK data: $e');
      return null;
    }
  }

  // Validate NPK data to ensure it contains valid numbers
  static bool isValidNPKData(Map<String, dynamic>? data) {
    if (data == null) return false;

    // Check if all required keys exist
    if (!data.containsKey('N') ||
        !data.containsKey('P') ||
        !data.containsKey('K')) {
      print('Missing NPK keys in response');
      return false;
    }

    // Check if any value is 'NA'
    if (data['N'] == 'NA' || data['P'] == 'NA' || data['K'] == 'NA') {
      print('Received NA value in NPK data');
      return false;
    }

    // Try to parse and validate values
    try {
      final n = double.parse(data['N'].toString());
      final p = double.parse(data['P'].toString());
      final k = double.parse(data['K'].toString());

      // Sensor error case: 255 is often an error code in sensor readings
      if (n == 255 || p == 255 || k == 255) {
        print('Received error value (255) in NPK data');
        return false;
      }

      // Additional validation: Check for reasonable ranges
      // Customize these ranges based on your specific sensor's valid output range
      if (n < 0 || n > 200 || p < 0 || p > 200 || k < 0 || k > 200) {
        print('NPK values outside of valid range: N=$n, P=$p, K=$k');
        return false;
      }

      return true;
    } catch (e) {
      print('Invalid NPK data format: $e');
      return false;
    }
  }
}
