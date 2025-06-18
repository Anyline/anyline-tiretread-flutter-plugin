import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:anyline_tire_tread_plugin/src/models/tire_tread_config.dart';
import 'package:http/http.dart' as http;
import 'package:json_schema/json_schema.dart';

/// Constants used across tests
class TestConstants {
  static const schemaUrl =
      'https://documentation.anyline.com/tiretreadsdk-component/latest/_attachments/json-schemas/tire_tread_config_schema.json';
  static const configsDir = 'test/fixtures/tire_tread_configs';
}

void main() {
  late JsonSchema schema;

  setUpAll(() async {
    // Fetch schema once for all tests
    final response = await http.get(Uri.parse(TestConstants.schemaUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch schema: ${response.statusCode}');
    }
    final schemaJson = json.decode(response.body) as Map<String, dynamic>;
    schema = JsonSchema.create(schemaJson);
  });

  /// Recursively validates that all non-null properties from original are present in generated.
  void validateObjectProperties(Map<String, dynamic> original, Map<String, dynamic> generated, String filePath, String path) {
    original.forEach((key, value) {
      final currentPath = path.isEmpty ? key : '$path.$key';
      
      if (value != null) {
        // Check if the key exists in generated JSON
        expect(
          generated.containsKey(key),
          true,
          reason: '$filePath: Property "$currentPath" from original JSON is missing in generated JSON. This may indicate incorrect property naming in the model class.'
        );
        
        // If both are objects, recursively validate
        if (value is Map<String, dynamic> && generated[key] is Map<String, dynamic>) {
          validateObjectProperties(
            value, 
            generated[key] as Map<String, dynamic>, 
            filePath, 
            currentPath
          );
        }
      }
    });
  }

  /// Validates that no data is lost during JSON serialization by checking
  /// that all non-null properties from the original JSON are present in the generated JSON.
  void validateNoDataLoss(Map<String, dynamic> original, Map<String, dynamic> generated, String filePath) {
    validateObjectProperties(original, generated, filePath, '');
  }

  group('TireTreadConfig JSON Schema Validation', () {
    test('generates valid JSON for all test fixtures', () async {
      final dir = Directory(TestConstants.configsDir);
      final files = await dir
          .list()
          .where((entity) => entity.path.endsWith('.json'))
          .toList();

      for (final file in files) {
        // Load and parse test fixture
        final jsonString = await File(file.path).readAsString();
        final inputJson = jsonDecode(jsonString) as Map<String, dynamic>;

        // Create config and generate JSON
        final config = TireTreadConfig.fromJson(inputJson);
        final generatedJson = config.toJson();

        // Validate against schema
        final validationResult = schema.validate(generatedJson);
        expect(
          validationResult.isValid,
          true,
          reason: '${file.path}: ${validationResult.errors.join(", ")}',
        );
      }
    });

    test('ensures no data loss during JSON roundtrip', () async {
      final dir = Directory(TestConstants.configsDir);
      final files = await dir
          .list()
          .where((entity) => entity.path.endsWith('.json'))
          .toList();

      for (final file in files) {
        // Load original JSON
        final jsonString = await File(file.path).readAsString();
        final originalJson = jsonDecode(jsonString) as Map<String, dynamic>;
        
        // Parse to object and back to JSON
        final config = TireTreadConfig.fromJson(originalJson);
        final generatedJson = config.toJson();
        
        // Parse generated JSON back to object
        final reparsedConfig = TireTreadConfig.fromJson(generatedJson);
        final finalJson = reparsedConfig.toJson();
        
        // The final JSON should be identical to the generated JSON
        // This catches cases where properties are ignored during parsing
        expect(
          finalJson, 
          equals(generatedJson),
          reason: '${file.path}: Data loss detected in roundtrip - some properties may have incorrect names'
        );
        
        // Additionally, validate that all non-null properties in original
        // are represented in the generated JSON (allowing for null exclusion)
        validateNoDataLoss(originalJson, generatedJson, file.path);
      }
    });
  });
}
