enum Environment {
  /// 正式环境
  production,

  /// 测试环境
  qa,
}

/// 环境配置类，用于管理不同环境的API基础URL
class EnvironmentConfig {
  /// 环境类型枚举

  /// 当前环境
  static Environment _currentEnvironment = Environment.production;

  /// 环境URL映射
  static final Map<Environment, String> _baseUrls = {
    Environment.production: 'https://d3qx0f55wsubto.cloudfront.net/api/',
    Environment.qa: 'https://terminal-cn2.bitpush.news/api/',
  };

  /// 获取当前环境的基础URL
  static String get baseUrl => _baseUrls[_currentEnvironment]!;

  /// 设置当前环境
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  /// 获取当前环境
  static Environment get currentEnvironment => _currentEnvironment;

  /// 切换到正式环境
  static void switchToProduction() {
    setEnvironment(Environment.production);
  }

  /// 切换到测试环境
  static void switchToTest() {
    setEnvironment(Environment.qa);
  }
}
