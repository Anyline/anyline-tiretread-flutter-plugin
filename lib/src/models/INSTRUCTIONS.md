# Model Classes Maintenance Instructions

This document provides guidelines for maintaining and regenerating the model classes in this directory. These classes are critical for the Anyline Tire Tread SDK integration and must maintain their current functionality while staying in sync with the SDK's API.

## Reference Documentation

- API Documentation: [TireTread SDK Config API](https://documentation.anyline.com/tiretreadsdk-component/latest/_attachments/kdoc/shared/io.anyline.tiretread.sdk.config/index.html)
- JSON Schema: [TireTread Config Schema](https://documentation.anyline.com/tiretreadsdk-component/latest/_attachments/json-schemas/tire_tread_config_schema.json)

## Critical Requirements

1. **Flutter Lint Compliance**

   - All generated model classes MUST comply with the Flutter lint rules defined in `analysis_options.yaml`
   - Run `flutter analyze` to verify compliance before committing changes
   - Key lint rules to follow:
     - `empty_constructor_bodies`: Use semicolons (`;`) for empty constructors, not braces (`{}`)
     - `curly_braces_in_flow_control_structures`: Always use braces for if statements, even single-line ones
     - `unused_import`: Remove any unused import statements
     - `always_declare_return_types`: Ensure all methods have explicit return types

2. **API Compatibility**

   - Always verify changes against the official API documentation
   - Confirm with the development team if the API documentation is up to date

3. **Property and JSON Field Naming**

   - **CRITICAL**: Both Dart property names AND JSON field names MUST match the JSON schema exactly
   - **DO NOT** optimize property names for readability - use the exact names from the schema
   - **ALWAYS** consult the official JSON schema before making any naming assumptions
   - **NEVER** assume naming patterns (e.g., suffixes, prefixes) - the schema is the single source of truth

   - **Correct approach**:

     ```dart
     class UiConfig {
       // Property name matches JSON schema exactly
       OrientationWarningConfig? orientationWarningConfig;

       Map<String, dynamic> toJson() {
         final map = <String, dynamic>{};
         // JSON field name also matches schema exactly
         if (orientationWarningConfig != null) {
           map['orientationWarningConfig'] = orientationWarningConfig?.toJson();
         }
         return map;
       }
     }
     ```

   - **Incorrect approach**:

     ```dart
     class UiConfig {
       // WRONG: Property name differs from schema
       OrientationWarningConfig? orientationWarning;

       Map<String, dynamic> toJson() {
         final map = <String, dynamic>{};
         // Even if JSON key is correct, property name mismatch causes confusion
         if (orientationWarning != null) {
           map['orientationWarningConfig'] = orientationWarning?.toJson();
         }
         return map;
       }
     }
     ```

   - **Enum Usage**:

     - **ALWAYS** use enums for fields that have a fixed set of values in the schema
     - Enums MUST be defined in the `lib/src/enum` directory
     - Each enum MUST have proper documentation for each value
     - Each enum MUST override `toString()` to return the name
     - Example:

       ```dart
       /// The measurement system to be displayed.
       enum MeasurementSystem {
         /// Metric system (millimeters)
         Metric,

         /// Imperial system (inches)
         Imperial;

         @override
         String toString() => name;
       }
       ```

     - When deserializing JSON, use `firstWhere` with `orElse` for validation:
       ```dart
       config.measurementSystem = MeasurementSystem.values.firstWhere(
         (e) => e.name == json['measurementSystem'],
         orElse: () => throw ArgumentError('Invalid measurement system value'),
       );
       ```
     - When serializing to JSON, use the enum's name:
       ```dart
       map['measurementSystem'] = measurementSystem.name;
       ```

   - **Schema verification process**:
     1. **First**: Check the official JSON schema at the URL provided in this document
     2. **Second**: Identify any fields with fixed values (enums) and ensure they have corresponding enum classes
     3. **Third**: Cross-reference with test fixtures in `test/fixtures/tire_tread_configs/`
     4. **Fourth**: Verify against the SDK documentation
     5. **Last resort**: Ask the development team if schema is unclear or inconsistent

4. **JSON Serialization**

   - Null properties MUST NOT be included in the JSON output
   - Use the pattern with proper braces for lint compliance:
     ```dart
     Map<String, dynamic> toJson() {
       final map = <String, dynamic>{};
       if (property != null) {
         map['property'] = property;
       }
       return map;
     }
     ```
   - For nested objects, only include them if they have at least one non-null property
   - Always use braces for if statements to comply with `curly_braces_in_flow_control_structures` lint rule

5. **Schema Compliance**

   - All generated JSON MUST validate against the official JSON schema
   - Pay special attention to:
     - Required fields
     - Type constraints
     - Enum values
     - Nested object structures

6. **Current Functionality**

   - Maintain all existing validation logic
   - Keep current error handling and default values

7. **Model Documentation**

   - Documentation should focus on WHAT the model represents, not HOW it works
   - Do not include implementation details in model documentation
   - Do not reference these instructions in model documentation
   - Keep documentation concise and focused on the model's purpose and usage
   - DO NOT modify class documentation unless:
     - The class structure changes (new fields, removed fields, changed relationships)
     - The class's purpose or behavior changes
     - The API documentation updates require clarification
   - When documentation is modified:
     - Keep existing documentation style and format
     - Only update what's necessary to reflect the changes
     - Maintain backward compatibility in documentation
     - Do not rewrite documentation that is still accurate

8. **Model Regeneration**

   - When regenerating a model class, all its subclasses must be regenerated together
   - This ensures consistent implementation across the model hierarchy
   - Example: When regenerating TireTreadConfig, also regenerate:
     - ScanConfig
     - AdditionalContext
     - UiConfig
     - And any other classes they depend on

9. **Field Mutability**

   - Fields MUST NOT be final
   - All fields must be modifiable after initialization
   - This allows for dynamic updates to the configuration during runtime
   - Example:

     ```dart
     class Config {
       // Correct: Field is mutable
       String? property;

       // Incorrect: Field is final
       // final String? property;
     }
     ```

10. **Constructor Requirements**

    - All model classes MUST have an empty constructor
    - This allows for flexible object creation and initialization
    - Example:

      ```dart
      class Config {
        // Correct: Empty constructor
        Config();

        // Incorrect: Constructor with parameters
        // Config({this.property});
      }
      ```

    - Fields should be initialized after construction using setters
    - This pattern enables dynamic configuration updates and better serialization control

## Class-Specific Requirements

### UiConfig

- Maintain all UI component configurations
- Keep current default values for visibility flags
- Ensure all nested config objects follow the null-exclusion pattern

## Testing Requirements

1. All changes must pass the existing test suite in `test/tire_tread_config_test.dart`
2. Generated JSON must validate against the schema
3. All model classes must handle:
   - Valid input correctly
   - Missing optional fields gracefully
   - Invalid input without crashing
4. After regenerating any model class, you MUST run the unit tests to ensure the changes haven't broken any existing functionality
5. Specifically run the tire tread config tests:
   ```bash
   flutter test test/tire_tread_config_test.dart
   ```
6. This test file validates that:
   - The generated JSON matches the official schema
   - All test fixtures are properly serialized/deserialized
   - The model maintains compatibility with the API
7. If any tests fail, fix the issues before committing the changes
8. Pay special attention to:
   - JSON serialization/deserialization tests
   - Schema validation tests
   - Null safety tests
   - Field mutability tests (if applicable)

## Change Management

- DO NOT modify the model classes unless necessary due to:
  - Changes in the API specification
  - Updates to the JSON schema
  - Critical bug fixes
- Preserve the existing structure and implementation:
  - Keep the same class hierarchy
  - Maintain existing field names and types
  - Keep the same documentation style
  - Preserve existing validation logic
- Only adapt what's needed to match new API/schema requirements
- If changes are needed, document the reason in the commit message

## Common Pitfalls to Avoid

1. **JSON Serialization**

   - Don't include null values in JSON output
   - Don't serialize empty objects
   - Don't modify the property names
   - Don't use single-line if statements without braces (violates `curly_braces_in_flow_control_structures`)

2. **Type Safety**

   - Don't use dynamic types where specific types are available
   - Don't remove null safety
   - Don't change enum values without updating all references

3. **Validation**

   - Don't remove existing validation logic
   - Don't change default values without team consensus
   - Don't modify error messages without updating tests

4. **Documentation**

   - Don't include implementation details in model documentation
   - Don't reference these instructions in model documentation
   - Don't duplicate information that's already in the SDK documentation

5. **Field Mutability**

   - Don't make fields final
   - Don't prevent field modification after initialization
   - Don't use const constructors that would make fields immutable

6. **Lint Compliance**

   - Don't use empty braces `{}` for constructors (use semicolons `;` instead)
   - Don't forget to remove unused imports
   - Don't use single-line if statements without braces

7. **Enum Usage**
   - Don't use strings for fields that should be enums
   - Don't create enums without proper documentation
   - Don't forget to override `toString()` in enums
   - Don't use raw string values in JSON serialization/deserialization
   - Don't skip validation when deserializing enum values

## When in Doubt

1. Check the test fixtures in `test/fixtures/tire_tread_configs/` for examples of valid configurations
2. Run the test suite to verify changes
3. Consult with the development team
4. Refer to the official SDK documentation
5. Maintain the current behavior if the documentation is unclear
