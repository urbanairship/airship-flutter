
class FeatureFlag {

  final bool isEligible;

  final bool exists;

  final Map<String, dynamic>? variables;

  const FeatureFlag._internal(this.isEligible, this.exists, this.variables);

  static FeatureFlag fromJson(Map<String, dynamic> json) {
    try {
      var isEligible = json["isEligible"];
      var exists = json["exists"];
      var variables = Map<String, dynamic>.from(json["variables"]);
      return FeatureFlag(isEligible, exists, variables);
    } catch (e, s) {
      print("Invalid config: $e");
      print("Stack trace:\n$s");
    }
  }

  @override
  String toString() {
    return "FeatureFlag(isEligible=$isEligible, exists=$exists, variables=$variables)";
  }
}