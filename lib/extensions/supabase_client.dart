import 'package:identity/identity.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

/// Extensions for [SupabaseClient].
extension SupabaseClientExtensions on SupabaseClient {
  /// Builds the URL of a backend edge function.
  Uri functionUri(String functionName, [Map<String, String>? queryParameters]) {
    return Uri.parse('$supabaseUrl/functions/v1/$functionName').replace(
      queryParameters: queryParameters == null || queryParameters.isEmpty ? null : queryParameters,
    );
  }
}
