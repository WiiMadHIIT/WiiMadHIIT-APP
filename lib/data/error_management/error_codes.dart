/// 错误码定义文件
/// 对应后端 ErrorCode.java 中的所有错误码
/// 用于前端快速查阅错误含义和进行错误处理

class ErrorCodes {
  // 通用错误码
  static const String SUCCESS = "A200";
  static const String AUTH_FAIL = "A400";
  static const String TOKEN_MISSING = "A401";
  static const String TOKEN_INVALID = "A402";
  static const String TOKEN_EXPIRED = "A403";
  static const String FORBIDDEN = "A4030";
  static const String IP_BLACKLIST = "A4031";
  static const String DOMAIN_BLACKLIST = "A4032";
  static const String NOT_FOUND = "A404";
  static const String RATE_LIMIT = "A429";
  static const String SERVER_ERROR = "A500";

  // 用户服务专用错误码 (US = User Service)
  static const String US_EMAIL_INVALID = "US400";
  static const String US_VERIFICATION_CODE_EXPIRED = "US401";
  static const String US_VERIFICATION_CODE_INVALID = "US402";
  static const String US_VERIFICATION_CODE_NOT_FOUND = "US403";
  static const String US_TOO_MANY_ATTEMPTS = "US404";
  static const String US_ACCOUNT_LOCKED = "US405";
  static const String US_DAILY_LIMIT_REACHED = "US429";
  static const String US_COOLDOWN_ACTIVE = "US430";
  static const String US_REDIS_UNAVAILABLE = "US503";
  static const String US_MAIL_SEND_FAILED = "US504";
  static const String US_USER_NOT_FOUND = "US406";
  static const String US_USER_ALREADY_EXISTS = "US409";
  static const String US_TOKEN_REFRESH_FAILED = "US407";
  static const String US_INVALID_REFRESH_TOKEN = "US408";
  static const String US_PARAM_REQUIRED = "US410";
  static const String US_PARAM_INVALID = "US411";
  static const String US_ANNOUNCEMENT_LIST_FAILED = "US460";
  static const String US_USER_INFO_FETCH_FAILED = "US461";
  static const String US_USER_BATCH_FETCH_FAILED = "US462";
  static const String US_USER_MAP_FETCH_FAILED = "US463";
  static const String US_USER_UPDATE_FAILED = "US464";
  static const String US_USER_CREATE_FAILED = "US465";
  static const String US_SERVER_ERROR = "US500";

  // 打卡服务专用错误码 (CINS = Checkin Service)
  static const String CINS_PARAM_REQUIRED = "CINS400";
  static const String CINS_PARAM_INVALID = "CINS401";
  static const String CINS_ACTIVATION_SUBMIT_FAILED = "CINS402";
  static const String CINS_ACTIVATION_PROCESS_FAILED = "CINS403";
  static const String CINS_ACTIVATION_REGISTER_FAILED = "CINS404";
  static const String CINS_ACTIVATION_CODE_INVALID = "CINS405";
  static const String CINS_ACTIVATION_CODE_NOT_FOUND = "CINS406";
  static const String CINS_USER_NOT_FOUND = "CINS407";
  static const String CINS_EQUIPMENT_NOT_FOUND = "CINS408";
  static const String CINS_SERVER_ERROR = "CINS500";
  static const String CINS_CHECKIN_PRODUCTS_FAILED = "CINS409";
  static const String CINS_TRAINING_PRODUCT_FAILED = "CINS410";
  static const String CINS_TRAINING_RULE_FAILED = "CINS411";
  static const String CINS_TRAINING_DATA_FAILED = "CINS412";
  static const String CINS_TRAINING_SUBMIT_FAILED = "CINS413";
  static const String CINS_COUNTDOWN_DATA_FAILED = "CINS414";
  static const String CINS_COUNTDOWN_SUBMIT_FAILED = "CINS415";
  static const String CINS_ACTIVE_USER_LIST_FAILED = "CINS416";
  static const String CINS_CHECKIN_RECORDS_FAILED = "CINS417";
  static const String CINS_CHECKINBOARD_FAILED = "CINS418";
  static const String CINS_ACTIVATION_NOTIFICATION_FAILED = "CINS419";
  static const String CINS_EQUIPMENT_QUERY_FAILED = "CINS420";
  static const String CINS_EQUIPMENT_INFO_MAP_FAILED = "CINS421";

  // 挑战服务专用错误码 (CLLS = Challenge Service)
  static const String CLLS_PARAM_REQUIRED = "CLLS400";
  static const String CLLS_PARAM_INVALID = "CLLS401";
  static const String CLLS_ACTIVATE_LIST_FAILED = "CLLS402";
  static const String CLLS_CHALLENGE_NOT_FOUND = "CLLS403";
  static const String CLLS_CHALLENGE_CONFIG_NOT_FOUND = "CLLS404";
  static const String CLLS_CHALLENGE_DETAILS_FAILED = "CLLS405";
  static const String CLLS_CHALLENGE_RULES_FAILED = "CLLS406";
  static const String CLLS_CHALLENGE_GAME_DATA_FAILED = "CLLS407";
  static const String CLLS_CHALLENGE_SUBMIT_FAILED = "CLLS408";
  static const String CLLS_LEADERBOARD_LIST_FAILED = "CLLS409";
  static const String CLLS_LEADERBOARD_RANKINGS_FAILED = "CLLS410";
  static const String CLLS_SERVER_ERROR = "CLLS500";
  static const String CLLS_BONUS_ACTIVITY_FAILED = "CLLS411";
  static const String CLLS_CHALLENGE_LIST_FAILED = "CLLS412";
  static const String CLLS_CHAMPION_LIST_FAILED = "CLLS419";
  static const String CLLS_CHALLENGE_RECORDS_FAILED = "CLLS420";
  static const String CLLS_USER_HONOR_FAILED = "CLLS421";

  // BFF服务专用错误码 (BS = BFF Service)
  static const String BS_EMAIL_INVALID = "BS400";
  static const String BS_PARAM_REQUIRED = "BS401";
  static const String BS_SERVICE_UNAVAILABLE = "BS502";
  static const String BS_SEND_CODE_FAILED = "BS503";
  static const String BS_VERIFY_CODE_FAILED = "BS504";
  static const String BS_REGISTER_FAILED = "BS505";
  static const String BS_TOKEN_REFRESH_FAILED = "BS506";
  static const String BS_BONUS_FETCH_FAILED = "BS507";
  static const String BS_PROFILE_FETCH_FAILED = "BS508";
  static const String BS_ACTIVATE_LIST_FAILED = "BS509";
  static const String BS_CHECKIN_LIST_FAILED = "BS510";
  static const String BS_CHALLENGE_LIST_FAILED = "BS511";
  static const String BS_SUBMIT_ACTIVATION_FAILED = "BS512";
  static const String BS_UPDATE_PROFILE_FAILED = "BS513";
  static const String BS_CHALLENGE_DETAILS_FAILED = "BS514";
  static const String BS_CHALLENGE_RULES_FAILED = "BS515";
  static const String BS_CHALLENGE_GAME_DATA_FAILED = "BS516";
  static const String BS_CHALLENGE_SUBMIT_FAILED = "BS517";
  static const String BS_LEADERBOARD_LIST_FAILED = "BS518";
  static const String BS_LEADERBOARD_RANKINGS_FAILED = "BS519";
  static const String BS_CHECKIN_PRODUCTS_FAILED = "BS520";
  static const String BS_TRAINING_PRODUCT_FAILED = "BS521";
  static const String BS_TRAINING_RULE_FAILED = "BS522";
  static const String BS_TRAINING_DATA_FAILED = "BS523";
  static const String BS_TRAINING_SUBMIT_FAILED = "BS524";
  static const String BS_COUNTDOWN_DATA_FAILED = "BS525";
  static const String BS_COUNTDOWN_SUBMIT_FAILED = "BS526";
  static const String BS_CHECKINBOARD_LIST_FAILED = "BS527";
  static const String BS_CHECKINBOARD_RANKINGS_FAILED = "BS528";
  static const String BS_HOME_DASHBOARD_FAILED = "BS529";
}

/// 错误码解释工具类
/// 提供根据错误码获取错误信息和处理建议的功能
/// 为美国用户提供简短、有创意的英文错误信息
class ErrorCodeHelper {
  /// 根据错误码获取错误信息
  static String getErrorMessage(String code) {
    switch (code) {
      // 通用错误码
      case ErrorCodes.SUCCESS:
        return "Success! 🎉";
      case ErrorCodes.AUTH_FAIL:
        return "Oops! Authentication failed 🔐";
      case ErrorCodes.TOKEN_MISSING:
        return "Missing access token 🔑";
      case ErrorCodes.TOKEN_INVALID:
        return "Invalid access token ❌";
      case ErrorCodes.TOKEN_EXPIRED:
        return "Token expired! Please login again ⏰";
      case ErrorCodes.FORBIDDEN:
        return "Access denied 🚫";
      case ErrorCodes.IP_BLACKLIST:
        return "IP blocked 🚫";
      case ErrorCodes.DOMAIN_BLACKLIST:
        return "Domain blocked 🚫";
      case ErrorCodes.NOT_FOUND:
        return "Resource not found 🔍";
      case ErrorCodes.RATE_LIMIT:
        return "Too many requests! Slow down 🐌";
      case ErrorCodes.SERVER_ERROR:
        return "Server hiccup! Try again later 🤖";

      // 用户服务错误码
      case ErrorCodes.US_EMAIL_INVALID:
        return "Invalid email format 📧";
      case ErrorCodes.US_VERIFICATION_CODE_EXPIRED:
        return "Code expired! Get a new one ⏰";
      case ErrorCodes.US_VERIFICATION_CODE_INVALID:
        return "Wrong code! Try again 🔢";
      case ErrorCodes.US_VERIFICATION_CODE_NOT_FOUND:
        return "Code not found! Request a new one 📱";
      case ErrorCodes.US_TOO_MANY_ATTEMPTS:
        return "Too many tries! Take a break 😅";
      case ErrorCodes.US_ACCOUNT_LOCKED:
        return "Account temporarily locked 🔒";
      case ErrorCodes.US_DAILY_LIMIT_REACHED:
        return "Daily limit reached! Come back tomorrow 📅";
      case ErrorCodes.US_COOLDOWN_ACTIVE:
        return "Too fast! Wait a moment ⏳";
      case ErrorCodes.US_REDIS_UNAVAILABLE:
        return "Service temporarily unavailable 🔧";
      case ErrorCodes.US_MAIL_SEND_FAILED:
        return "Email delivery failed 📬";
      case ErrorCodes.US_USER_NOT_FOUND:
        return "User not found 👤";
      case ErrorCodes.US_USER_ALREADY_EXISTS:
        return "User already exists! Try logging in 👥";
      case ErrorCodes.US_TOKEN_REFRESH_FAILED:
        return "Token refresh failed 🔄";
      case ErrorCodes.US_INVALID_REFRESH_TOKEN:
        return "Invalid refresh token 🔑";
      case ErrorCodes.US_PARAM_REQUIRED:
        return "Missing required info 📝";
      case ErrorCodes.US_PARAM_INVALID:
        return "Invalid input! Check your data ✏️";
      case ErrorCodes.US_ANNOUNCEMENT_LIST_FAILED:
        return "Failed to load announcements 📢";
      case ErrorCodes.US_USER_INFO_FETCH_FAILED:
        return "Failed to load user info 👤";
      case ErrorCodes.US_USER_BATCH_FETCH_FAILED:
        return "Failed to load user list 📋";
      case ErrorCodes.US_USER_MAP_FETCH_FAILED:
        return "Failed to load user map 🗺️";
      case ErrorCodes.US_USER_UPDATE_FAILED:
        return "Failed to update user info 🔄";
      case ErrorCodes.US_USER_CREATE_FAILED:
        return "Failed to create user ➕";
      case ErrorCodes.US_SERVER_ERROR:
        return "User service error! Try again later 🔧";

      // 打卡服务错误码
      case ErrorCodes.CINS_PARAM_REQUIRED:
        return "Missing required info 📝";
      case ErrorCodes.CINS_PARAM_INVALID:
        return "Invalid input! Check your data ✏️";
      case ErrorCodes.CINS_ACTIVATION_SUBMIT_FAILED:
        return "Failed to submit activation code 🔑";
      case ErrorCodes.CINS_ACTIVATION_PROCESS_FAILED:
        return "Failed to process activation codes ⚙️";
      case ErrorCodes.CINS_ACTIVATION_REGISTER_FAILED:
        return "Failed to submit registration code 📝";
      case ErrorCodes.CINS_ACTIVATION_CODE_INVALID:
        return "Invalid activation code ❌";
      case ErrorCodes.CINS_ACTIVATION_CODE_NOT_FOUND:
        return "Activation code not found 🔍";
      case ErrorCodes.CINS_USER_NOT_FOUND:
        return "User not found 👤";
      case ErrorCodes.CINS_EQUIPMENT_NOT_FOUND:
        return "Equipment not found 🏋️";
      case ErrorCodes.CINS_SERVER_ERROR:
        return "Checkin service error! Try again later 🔧";
      case ErrorCodes.CINS_CHECKIN_PRODUCTS_FAILED:
        return "Failed to load checkin products 📱";
      case ErrorCodes.CINS_TRAINING_PRODUCT_FAILED:
        return "Failed to load training product 🏃";
      case ErrorCodes.CINS_TRAINING_RULE_FAILED:
        return "Failed to load training rules 📋";
      case ErrorCodes.CINS_TRAINING_DATA_FAILED:
        return "Failed to load training data 📊";
      case ErrorCodes.CINS_TRAINING_SUBMIT_FAILED:
        return "Failed to submit training result 📤";
      case ErrorCodes.CINS_COUNTDOWN_DATA_FAILED:
        return "Failed to load countdown data ⏰";
      case ErrorCodes.CINS_COUNTDOWN_SUBMIT_FAILED:
        return "Failed to submit countdown result 📤";
      case ErrorCodes.CINS_ACTIVE_USER_LIST_FAILED:
        return "Failed to load active users 👥";
      case ErrorCodes.CINS_CHECKIN_RECORDS_FAILED:
        return "Failed to load checkin records 📝";
      case ErrorCodes.CINS_CHECKINBOARD_FAILED:
        return "Failed to load checkinboard 🏆";
      case ErrorCodes.CINS_ACTIVATION_NOTIFICATION_FAILED:
        return "Failed to load activation notifications 🔔";
      case ErrorCodes.CINS_EQUIPMENT_QUERY_FAILED:
        return "Failed to query equipment info 🔍";
      case ErrorCodes.CINS_EQUIPMENT_INFO_MAP_FAILED:
        return "Failed to load equipment info map 🗺️";

      // 挑战服务错误码
      case ErrorCodes.CLLS_PARAM_REQUIRED:
        return "Missing required info 📝";
      case ErrorCodes.CLLS_PARAM_INVALID:
        return "Invalid input! Check your data ✏️";
      case ErrorCodes.CLLS_ACTIVATE_LIST_FAILED:
        return "Failed to load activated list 📋";
      case ErrorCodes.CLLS_CHALLENGE_NOT_FOUND:
        return "Challenge not found! 🏆";
      case ErrorCodes.CLLS_CHALLENGE_CONFIG_NOT_FOUND:
        return "Challenge config missing! ⚙️";
      case ErrorCodes.CLLS_CHALLENGE_DETAILS_FAILED:
        return "Failed to load challenge details 📖";
      case ErrorCodes.CLLS_CHALLENGE_RULES_FAILED:
        return "Failed to load challenge rules 📋";
      case ErrorCodes.CLLS_CHALLENGE_GAME_DATA_FAILED:
        return "Failed to load game data 🎮";
      case ErrorCodes.CLLS_CHALLENGE_SUBMIT_FAILED:
        return "Failed to submit challenge result 📤";
      case ErrorCodes.CLLS_LEADERBOARD_LIST_FAILED:
        return "Failed to load leaderboard 🏆";
      case ErrorCodes.CLLS_LEADERBOARD_RANKINGS_FAILED:
        return "Failed to load rankings 📊";
      case ErrorCodes.CLLS_SERVER_ERROR:
        return "Challenge service error! Try again later 🔧";
      case ErrorCodes.CLLS_BONUS_ACTIVITY_FAILED:
        return "Failed to load bonus activities 🎁";
      case ErrorCodes.CLLS_CHALLENGE_LIST_FAILED:
        return "Failed to load challenge list 📋";
      case ErrorCodes.CLLS_CHAMPION_LIST_FAILED:
        return "Failed to load champions 🏅";
      case ErrorCodes.CLLS_CHALLENGE_RECORDS_FAILED:
        return "Failed to load challenge records 📝";
      case ErrorCodes.CLLS_USER_HONOR_FAILED:
        return "Failed to load user honors 🏆";

      // BFF服务错误码
      case ErrorCodes.BS_EMAIL_INVALID:
        return "Invalid email format 📧";
      case ErrorCodes.BS_PARAM_REQUIRED:
        return "Missing required info 📝";
      case ErrorCodes.BS_SERVICE_UNAVAILABLE:
        return "Service temporarily unavailable 🔧";
      case ErrorCodes.BS_SEND_CODE_FAILED:
        return "Failed to send verification code 📱";
      case ErrorCodes.BS_VERIFY_CODE_FAILED:
        return "Failed to verify code 🔍";
      case ErrorCodes.BS_REGISTER_FAILED:
        return "Registration failed! Try again 📝";
      case ErrorCodes.BS_TOKEN_REFRESH_FAILED:
        return "Token refresh failed 🔄";
      case ErrorCodes.BS_BONUS_FETCH_FAILED:
        return "Failed to load bonus activities 🎁";
      case ErrorCodes.BS_PROFILE_FETCH_FAILED:
        return "Failed to load profile 👤";
      case ErrorCodes.BS_ACTIVATE_LIST_FAILED:
        return "Failed to load activate list 📋";
      case ErrorCodes.BS_CHECKIN_LIST_FAILED:
        return "Failed to load checkin list 📝";
      case ErrorCodes.BS_CHALLENGE_LIST_FAILED:
        return "Failed to load challenge list 🏆";
      case ErrorCodes.BS_SUBMIT_ACTIVATION_FAILED:
        return "Failed to submit activation code 🔑";
      case ErrorCodes.BS_UPDATE_PROFILE_FAILED:
        return "Failed to update profile 🔄";
      case ErrorCodes.BS_CHALLENGE_DETAILS_FAILED:
        return "Failed to load challenge details 📖";
      case ErrorCodes.BS_CHALLENGE_RULES_FAILED:
        return "Failed to load challenge rules 📋";
      case ErrorCodes.BS_CHALLENGE_GAME_DATA_FAILED:
        return "Failed to load game data 🎮";
      case ErrorCodes.BS_CHALLENGE_SUBMIT_FAILED:
        return "Failed to submit challenge result 📤";
      case ErrorCodes.BS_LEADERBOARD_LIST_FAILED:
        return "Failed to load leaderboard 🏆";
      case ErrorCodes.BS_LEADERBOARD_RANKINGS_FAILED:
        return "Failed to load rankings 📊";
      case ErrorCodes.BS_CHECKIN_PRODUCTS_FAILED:
        return "Failed to load checkin products 📱";
      case ErrorCodes.BS_TRAINING_PRODUCT_FAILED:
        return "Failed to load training product 🏃";
      case ErrorCodes.BS_TRAINING_RULE_FAILED:
        return "Failed to load training rules 📋";
      case ErrorCodes.BS_TRAINING_DATA_FAILED:
        return "Failed to load training data 📊";
      case ErrorCodes.BS_TRAINING_SUBMIT_FAILED:
        return "Failed to submit training result 📤";
      case ErrorCodes.BS_COUNTDOWN_DATA_FAILED:
        return "Failed to load countdown data ⏰";
      case ErrorCodes.BS_COUNTDOWN_SUBMIT_FAILED:
        return "Failed to submit countdown result 📤";
      case ErrorCodes.BS_CHECKINBOARD_LIST_FAILED:
        return "Failed to load checkinboard 🏆";
      case ErrorCodes.BS_CHECKINBOARD_RANKINGS_FAILED:
        return "Failed to load checkinboard rankings 📊";
      case ErrorCodes.BS_HOME_DASHBOARD_FAILED:
        return "Failed to load home dashboard 🏠";

      default:
        return "Unknown error! 🤔";
    }
  }

  /// 根据错误码获取处理建议
  static String getErrorSuggestion(String code) {
    switch (code) {
      // 认证相关错误
      case ErrorCodes.TOKEN_EXPIRED:
      case ErrorCodes.TOKEN_INVALID:
        return "Please login again";
      case ErrorCodes.TOKEN_MISSING:
        return "Please login first";
      case ErrorCodes.AUTH_FAIL:
        return "Check your login status";

      // 限流相关错误
      case ErrorCodes.RATE_LIMIT:
      case ErrorCodes.US_DAILY_LIMIT_REACHED:
      case ErrorCodes.US_COOLDOWN_ACTIVE:
        return "Please try again later";

      // 参数相关错误
      case ErrorCodes.US_PARAM_REQUIRED:
      case ErrorCodes.CINS_PARAM_REQUIRED:
      case ErrorCodes.CLLS_PARAM_REQUIRED:
      case ErrorCodes.BS_PARAM_REQUIRED:
        return "Check your input data";

      // 验证码相关错误
      case ErrorCodes.US_VERIFICATION_CODE_EXPIRED:
        return "Request a new code";
      case ErrorCodes.US_VERIFICATION_CODE_INVALID:
        return "Double-check your code";

      // 服务不可用错误
      case ErrorCodes.US_REDIS_UNAVAILABLE:
      case ErrorCodes.BS_SERVICE_UNAVAILABLE:
        return "Service will be back soon";

      // 资源不存在错误
      case ErrorCodes.US_USER_NOT_FOUND:
      case ErrorCodes.CLLS_CHALLENGE_NOT_FOUND:
        return "Resource doesn't exist";

      default:
        return "Try again later or contact support";
    }
  }

  /// 判断是否为认证相关错误
  static bool isAuthError(String code) {
    return code == ErrorCodes.TOKEN_EXPIRED ||
           code == ErrorCodes.TOKEN_INVALID ||
           code == ErrorCodes.TOKEN_MISSING ||
           code == ErrorCodes.AUTH_FAIL;
  }

  /// 判断是否为限流相关错误
  static bool isRateLimitError(String code) {
    return code == ErrorCodes.RATE_LIMIT ||
           code == ErrorCodes.US_DAILY_LIMIT_REACHED ||
           code == ErrorCodes.US_COOLDOWN_ACTIVE;
  }

  /// 判断是否为参数相关错误
  static bool isParamError(String code) {
    return code == ErrorCodes.US_PARAM_REQUIRED ||
           code == ErrorCodes.US_PARAM_INVALID ||
           code == ErrorCodes.CINS_PARAM_REQUIRED ||
           code == ErrorCodes.CINS_PARAM_INVALID ||
           code == ErrorCodes.CLLS_PARAM_REQUIRED ||
           code == ErrorCodes.CLLS_PARAM_INVALID ||
           code == ErrorCodes.BS_PARAM_REQUIRED;
  }

  /// 判断是否为服务不可用错误
  static bool isServiceUnavailableError(String code) {
    return code == ErrorCodes.US_REDIS_UNAVAILABLE ||
           code == ErrorCodes.BS_SERVICE_UNAVAILABLE ||
           code == ErrorCodes.SERVER_ERROR ||
           code == ErrorCodes.US_SERVER_ERROR ||
           code == ErrorCodes.CINS_SERVER_ERROR ||
           code == ErrorCodes.CLLS_SERVER_ERROR;
  }

  /// 判断是否为网络相关错误
  static bool isNetworkError(String code) {
    return code == ErrorCodes.SERVER_ERROR ||
           code == ErrorCodes.US_SERVER_ERROR ||
           code == ErrorCodes.CINS_SERVER_ERROR ||
           code == ErrorCodes.CLLS_SERVER_ERROR ||
           code == ErrorCodes.BS_SERVICE_UNAVAILABLE;
  }

  /// 判断是否为用户输入错误
  static bool isUserInputError(String code) {
    return code == ErrorCodes.US_EMAIL_INVALID ||
           code == ErrorCodes.US_PARAM_INVALID ||
           code == ErrorCodes.CINS_PARAM_INVALID ||
           code == ErrorCodes.CLLS_PARAM_INVALID ||
           code == ErrorCodes.BS_EMAIL_INVALID;
  }

  /// 获取错误严重程度 (1-5, 5为最严重)
  static int getErrorSeverity(String code) {
    switch (code) {
      case ErrorCodes.SUCCESS:
        return 1;
        
      // 轻微错误 (级别2)
      case ErrorCodes.US_VERIFICATION_CODE_EXPIRED:
      case ErrorCodes.US_VERIFICATION_CODE_INVALID:
      case ErrorCodes.US_VERIFICATION_CODE_NOT_FOUND:
      case ErrorCodes.US_COOLDOWN_ACTIVE:
      case ErrorCodes.RATE_LIMIT:
      case ErrorCodes.US_DAILY_LIMIT_REACHED:
        return 2;
        
      // 中等错误 (级别3)
      case ErrorCodes.US_PARAM_REQUIRED:
      case ErrorCodes.US_PARAM_INVALID:
      case ErrorCodes.US_EMAIL_INVALID:
      case ErrorCodes.CINS_PARAM_REQUIRED:
      case ErrorCodes.CINS_PARAM_INVALID:
      case ErrorCodes.CLLS_PARAM_REQUIRED:
      case ErrorCodes.CLLS_PARAM_INVALID:
      case ErrorCodes.BS_PARAM_REQUIRED:
      case ErrorCodes.BS_EMAIL_INVALID:
      case ErrorCodes.US_USER_NOT_FOUND:
      case ErrorCodes.CLLS_CHALLENGE_NOT_FOUND:
        return 3;
        
      // 严重错误 (级别4)
      case ErrorCodes.TOKEN_EXPIRED:
      case ErrorCodes.TOKEN_INVALID:
      case ErrorCodes.TOKEN_MISSING:
      case ErrorCodes.AUTH_FAIL:
      case ErrorCodes.US_ACCOUNT_LOCKED:
      case ErrorCodes.US_USER_ALREADY_EXISTS:
      case ErrorCodes.US_TOKEN_REFRESH_FAILED:
      case ErrorCodes.US_INVALID_REFRESH_TOKEN:
        return 4;
        
      // 致命错误 (级别5)
      case ErrorCodes.SERVER_ERROR:
      case ErrorCodes.US_SERVER_ERROR:
      case ErrorCodes.CINS_SERVER_ERROR:
      case ErrorCodes.CLLS_SERVER_ERROR:
      case ErrorCodes.BS_SERVICE_UNAVAILABLE:
      case ErrorCodes.US_REDIS_UNAVAILABLE:
      case ErrorCodes.US_MAIL_SEND_FAILED:
        return 5;
        
      default:
        return 3; // 默认为中等错误
    }
  }

  /// 判断是否为可重试错误
  static bool isRetryableError(String code) {
    return code == ErrorCodes.RATE_LIMIT ||
           code == ErrorCodes.US_COOLDOWN_ACTIVE ||
           code == ErrorCodes.US_DAILY_LIMIT_REACHED ||
           code == ErrorCodes.US_REDIS_UNAVAILABLE ||
           code == ErrorCodes.BS_SERVICE_UNAVAILABLE ||
           code == ErrorCodes.SERVER_ERROR ||
           code == ErrorCodes.US_SERVER_ERROR ||
           code == ErrorCodes.CINS_SERVER_ERROR ||
           code == ErrorCodes.CLLS_SERVER_ERROR;
  }

  /// 判断是否为业务逻辑错误
  static bool isBusinessLogicError(String code) {
    return code == ErrorCodes.US_USER_NOT_FOUND ||
           code == ErrorCodes.US_USER_ALREADY_EXISTS ||
           code == ErrorCodes.US_ACCOUNT_LOCKED ||
           code == ErrorCodes.CLLS_CHALLENGE_NOT_FOUND ||
           code == ErrorCodes.CLLS_CHALLENGE_CONFIG_NOT_FOUND ||
           code == ErrorCodes.CINS_USER_NOT_FOUND ||
           code == ErrorCodes.CINS_EQUIPMENT_NOT_FOUND;
  }

  /// 判断是否为数据验证错误
  static bool isDataValidationError(String code) {
    return code == ErrorCodes.US_EMAIL_INVALID ||
           code == ErrorCodes.US_PARAM_INVALID ||
           code == ErrorCodes.US_PARAM_REQUIRED ||
           code == ErrorCodes.CINS_PARAM_INVALID ||
           code == ErrorCodes.CINS_PARAM_REQUIRED ||
           code == ErrorCodes.CLLS_PARAM_INVALID ||
           code == ErrorCodes.CLLS_PARAM_REQUIRED ||
           code == ErrorCodes.BS_PARAM_REQUIRED ||
           code == ErrorCodes.BS_EMAIL_INVALID;
  }

  /// 获取错误分类标签
  static String getErrorCategory(String code) {
    if (isAuthError(code)) return "Authentication";
    if (isRateLimitError(code)) return "Rate Limit";
    if (isParamError(code)) return "Input Validation";
    if (isServiceUnavailableError(code)) return "Service Unavailable";
    if (isNetworkError(code)) return "Network";
    if (isUserInputError(code)) return "User Input";
    if (isBusinessLogicError(code)) return "Business Logic";
    if (isDataValidationError(code)) return "Data Validation";
    if (isRetryableError(code)) return "Retryable";
    
    return "General";
  }

  /// 获取错误处理建议的详细说明
  static String getDetailedErrorSuggestion(String code) {
    switch (code) {
      case ErrorCodes.TOKEN_EXPIRED:
        return "Your session has expired. Please log in again to continue.";
      case ErrorCodes.TOKEN_INVALID:
        return "Your login token is invalid. Please log in again.";
      case ErrorCodes.TOKEN_MISSING:
        return "You need to log in to access this feature.";
      case ErrorCodes.AUTH_FAIL:
        return "Authentication failed. Please check your credentials and try again.";
      case ErrorCodes.RATE_LIMIT:
        return "Too many requests. Please wait a moment before trying again.";
      case ErrorCodes.US_DAILY_LIMIT_REACHED:
        return "Daily limit reached. Come back tomorrow for more attempts.";
      case ErrorCodes.US_COOLDOWN_ACTIVE:
        return "Please wait a bit before trying again. This helps prevent spam.";
      case ErrorCodes.US_EMAIL_INVALID:
        return "Please enter a valid email address (e.g., user@example.com).";
      case ErrorCodes.US_VERIFICATION_CODE_EXPIRED:
        return "Your verification code has expired. Please request a new one.";
      case ErrorCodes.US_VERIFICATION_CODE_INVALID:
        return "The verification code you entered is incorrect. Please try again.";
      case ErrorCodes.US_PARAM_REQUIRED:
        return "Some required information is missing. Please fill in all fields.";
      case ErrorCodes.US_PARAM_INVALID:
        return "Some information you entered is not valid. Please check and try again.";
      case ErrorCodes.US_ACCOUNT_LOCKED:
        return "Your account is temporarily locked due to too many failed attempts.";
      case ErrorCodes.US_USER_NOT_FOUND:
        return "User account not found. Please check your information.";
      case ErrorCodes.US_USER_ALREADY_EXISTS:
        return "An account with this information already exists.";
      case ErrorCodes.US_REDIS_UNAVAILABLE:
        return "Service temporarily unavailable. Please try again in a few minutes.";
      case ErrorCodes.US_MAIL_SEND_FAILED:
        return "Failed to send email. Please check your email address and try again.";
      case ErrorCodes.CINS_ACTIVATION_SUBMIT_FAILED:
        return "Failed to submit activation code. Please try again.";
      case ErrorCodes.CLLS_CHALLENGE_NOT_FOUND:
        return "The challenge you're looking for doesn't exist.";
      case ErrorCodes.BS_SERVICE_UNAVAILABLE:
        return "Service temporarily unavailable. Please try again later.";
      case ErrorCodes.BS_PROFILE_FETCH_FAILED:
        return "Failed to load your profile. Please refresh and try again.";
      case ErrorCodes.BS_CHALLENGE_DETAILS_FAILED:
        return "Failed to load challenge details. Please try again.";
      case ErrorCodes.BS_TRAINING_SUBMIT_FAILED:
        return "Failed to save your training results. Please try again.";
      default:
        return "Something went wrong. Please try again or contact support if the problem persists.";
    }
  }

  /// 判断是否需要用户重新登录
  static bool requiresReLogin(String code) {
    return code == ErrorCodes.TOKEN_EXPIRED ||
           code == ErrorCodes.TOKEN_INVALID ||
           code == ErrorCodes.TOKEN_MISSING ||
           code == ErrorCodes.AUTH_FAIL;
  }

  /// 判断是否需要用户重新输入
  static bool requiresReInput(String code) {
    return code == ErrorCodes.US_PARAM_REQUIRED ||
           code == ErrorCodes.US_PARAM_INVALID ||
           code == ErrorCodes.US_EMAIL_INVALID ||
           code == ErrorCodes.US_VERIFICATION_CODE_INVALID ||
           code == ErrorCodes.CINS_PARAM_REQUIRED ||
           code == ErrorCodes.CINS_PARAM_INVALID ||
           code == ErrorCodes.CLLS_PARAM_REQUIRED ||
           code == ErrorCodes.CLLS_PARAM_INVALID ||
           code == ErrorCodes.BS_PARAM_REQUIRED ||
           code == ErrorCodes.BS_EMAIL_INVALID;
  }

  /// 获取错误恢复时间建议（秒）
  static int getRecoveryTimeSeconds(String code) {
    switch (code) {
      case ErrorCodes.RATE_LIMIT:
        return 60; // 1分钟
      case ErrorCodes.US_COOLDOWN_ACTIVE:
        return 300; // 5分钟
      case ErrorCodes.US_DAILY_LIMIT_REACHED:
        return 86400; // 24小时
      case ErrorCodes.US_REDIS_UNAVAILABLE:
      case ErrorCodes.BS_SERVICE_UNAVAILABLE:
        return 180; // 3分钟
      default:
        return 0; // 无需等待
    }
  }

  /// 判断是否为开发调试信息
  static bool isDebugInfo(String code) {
    return code == ErrorCodes.SERVER_ERROR ||
           code == ErrorCodes.US_SERVER_ERROR ||
           code == ErrorCodes.CINS_SERVER_ERROR ||
           code == ErrorCodes.CLLS_SERVER_ERROR;
  }

  /// 获取用户友好的错误标题
  static String getErrorTitle(String code) {
    switch (code) {
      case ErrorCodes.TOKEN_EXPIRED:
      case ErrorCodes.TOKEN_INVALID:
      case ErrorCodes.TOKEN_MISSING:
      case ErrorCodes.AUTH_FAIL:
        return "Login Required";
      case ErrorCodes.RATE_LIMIT:
      case ErrorCodes.US_DAILY_LIMIT_REACHED:
      case ErrorCodes.US_COOLDOWN_ACTIVE:
        return "Too Fast!";
      case ErrorCodes.US_EMAIL_INVALID:
      case ErrorCodes.US_PARAM_INVALID:
      case ErrorCodes.US_PARAM_REQUIRED:
        return "Check Your Input";
      case ErrorCodes.US_VERIFICATION_CODE_EXPIRED:
      case ErrorCodes.US_VERIFICATION_CODE_INVALID:
        return "Code Issue";
      case ErrorCodes.US_ACCOUNT_LOCKED:
        return "Account Locked";
      case ErrorCodes.US_USER_NOT_FOUND:
        return "User Not Found";
      case ErrorCodes.US_USER_ALREADY_EXISTS:
        return "Already Exists";
      case ErrorCodes.US_REDIS_UNAVAILABLE:
      case ErrorCodes.BS_SERVICE_UNAVAILABLE:
        return "Service Busy";
      case ErrorCodes.CLLS_CHALLENGE_NOT_FOUND:
        return "Challenge Missing";
      case ErrorCodes.BS_PROFILE_FETCH_FAILED:
        return "Profile Error";
      case ErrorCodes.BS_CHALLENGE_DETAILS_FAILED:
        return "Loading Failed";
      case ErrorCodes.BS_TRAINING_SUBMIT_FAILED:
        return "Save Failed";
      default:
        return "Oops!";
    }
  }
}