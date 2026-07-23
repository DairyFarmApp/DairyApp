enum AppEnvironment { development, staging, production }

final class EnvironmentConfig {
  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  factory EnvironmentConfig.fromCompileTime() {
    const name = String.fromEnvironment('APP_ENV', defaultValue: 'development');
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:8000/api/v1',
    );
    return EnvironmentConfig(
      environment: AppEnvironment.values.firstWhere(
        (value) => value.name == name,
        orElse: () => AppEnvironment.development,
      ),
      apiBaseUrl: Uri.parse(baseUrl),
    );
  }

  final AppEnvironment environment;
  final Uri apiBaseUrl;
}
