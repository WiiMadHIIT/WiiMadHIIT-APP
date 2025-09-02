/// 认证错误码映射工具类
/// 统一管理所有认证相关的错误码和用户友好消息
class AuthErrorMapper {
  /// 获取发送验证码相关的错误信息
  static Map<String, String> getSendCodeError(String businessCode) {
    switch (businessCode) {
      // 限流相关错误
      case 'US429':
        return {
          'message': 'Daily limit reached',
          'userFriendly': 'Too many attempts today! Take a break and try again tomorrow 🚫',
        };
      case 'US430':
        return {
          'message': 'Cooldown active',
          'userFriendly': 'Slow down, speed racer! Wait a bit before trying again ⏰',
        };
      
      // 服务可用性错误
      case 'US503':
        return {
          'message': 'Service temporarily unavailable',
          'userFriendly': 'Our memory is taking a nap! 😴 Try again in a moment',
        };
      case 'US504':
        return {
          'message': 'Failed to send email',
          'userFriendly': 'Email got lost in the digital void! 📧 Try again',
        };
      
      // 其他错误（保持向后兼容）
      case 'US431':
        return {
          'message': 'Too frequent requests',
          'userFriendly': 'You\'re clicking faster than a caffeinated rabbit! 🐰 Wait a moment',
        };
      case 'US432':
        return {
          'message': 'Account locked',
          'userFriendly': 'Account temporarily locked for security! 🔒 Try again later',
        };
      case 'US433':
        return {
          'message': 'Email invalid',
          'userFriendly': 'That email looks suspicious! 🤔 Double-check and try again',
        };
      case 'US434':
        return {
          'message': 'Redis unavailable',
          'userFriendly': 'Our memory is taking a nap! 😴 Try again in a moment',
        };
      case 'US435':
        return {
          'message': 'Mail send failed',
          'userFriendly': 'Email got lost in the digital void! 📧 Try again',
        };
      
      default:
        return {
          'message': 'Failed to send code',
          'userFriendly': 'Already have an account? Try logging in instead! 🚀',
        };
    }
  }

  /// 获取验证登录验证码相关的错误信息
  static Map<String, String> getVerifyLoginError(String businessCode) {
    switch (businessCode) {
      // 验证码相关错误
      case 'US401':
        return {
          'message': 'Verification code expired',
          'userFriendly': 'Code expired! Time flies when you\'re having fun ⏰',
        };
      case 'US402':
        return {
          'message': 'Verification code invalid',
          'userFriendly': 'Wrong code! Double-check those digits 🔍',
        };
      case 'US403':
        return {
          'message': 'Verification code not found',
          'userFriendly': 'Code not found! Maybe it got lost in the digital maze 🧩',
        };
      
      // 账户安全相关错误
      case 'US404':
        return {
          'message': 'Too many attempts',
          'userFriendly': 'Too many wrong guesses! Account locked temporarily 🔒',
        };
      case 'US405':
        return {
          'message': 'Account temporarily locked',
          'userFriendly': 'Account locked for security! Try again later 🚫',
        };
      
      // 用户相关错误
      case 'US406':
        return {
          'message': 'User not registered',
          'userFriendly': 'User not registered! Go to register first 👤',
        };
      // Token相关错误
      case 'US407':
        return {
          'message': 'Token refresh failed',
          'userFriendly': 'Token refresh failed! Please log in again 🔄',
        };
      case 'US408':
        return {
          'message': 'Invalid refresh token',
          'userFriendly': 'Invalid refresh token! Please log in again 🔑',
        };
      case 'US409':
        return {
          'message': 'User already exists',
          'userFriendly': 'User already exists! Try logging in instead 👤',
        };
      case 'US410':
        return {
          'message': 'User account already deleted',
          'userFriendly': 'User account already deleted! Try registering again 👤',
        };
      case 'US411':
        return {
          'message': 'Required parameter missing',
          'userFriendly': 'Required parameter missing! Check your request 📧',
        };
      case 'US412':
        return {
          'message': 'Invalid parameter',
          'userFriendly': 'Invalid parameter! Check your request 📧',
        };
      
      // 其他登录相关错误
      case 'US429':
        return {
          'message': 'Daily limit reached',
          'userFriendly': 'Too many attempts today! Take a break and try again tomorrow 🚫',
        };
      case 'US430':
        return {
          'message': 'Cooldown active',
          'userFriendly': 'Slow down, speed racer! Wait a bit before trying again ⏰',
        };
      case 'US503':
        return {
          'message': 'Service temporarily unavailable',
          'userFriendly': 'Our memory is taking a nap! 😴 Try again in a moment',
        };
      case 'US504':
        return {
          'message': 'Failed to send email',
          'userFriendly': 'Email got lost in the digital void! 📧 Try again',
        };
      
      default:
        return {
          'message': 'Login failed',
          'userFriendly': 'Not registered yet? Create an account first! 🚀',
        };
    }
  }

  /// 获取验证注册验证码相关的错误信息
  static Map<String, String> getVerifyRegisterError(String businessCode) {
    switch (businessCode) {
      // 验证码相关错误
      case 'US450':
        return {
          'message': 'Verification code expired',
          'userFriendly': 'Code expired! Time flies when you\'re having fun ⏰',
        };
      case 'US451':
        return {
          'message': 'Verification code invalid',
          'userFriendly': 'Wrong code! Double-check those digits 🔍',
        };
      case 'US452':
        return {
          'message': 'Verification code not found',
          'userFriendly': 'Code not found! Maybe it got lost in the digital maze 🧩',
        };
      case 'US409':
        return {
          'message': 'User already exists',
          'userFriendly': 'User already exists! Try logging in instead 👤',
        };
      
      // 激活码相关错误
      case 'US453':
        return {
          'message': 'Activation code invalid',
          'userFriendly': 'Invalid activation code! Check your order number 🛒',
        };
      case 'US454':
        return {
          'message': 'Activation code expired',
          'userFriendly': 'Activation code expired! Time to get a fresh one ⏰',
        };
      case 'US455':
        return {
          'message': 'Activation code not found',
          'userFriendly': 'Activation code not found! Check your order details 📋',
        };
      
      // 账户安全相关错误
      case 'US456':
        return {
          'message': 'Too many attempts',
          'userFriendly': 'Too many wrong guesses! Account locked temporarily 🔒',
        };
      case 'US457':
        return {
          'message': 'Account temporarily locked',
          'userFriendly': 'Account locked for security! Try again later 🚫',
        };
      
      // 用户相关错误
      case 'US458':
        return {
          'message': 'User already exists',
          'userFriendly': 'User already exists! Try logging in instead 👤',
        };
      case 'US459':
        return {
          'message': 'User account already deleted',
          'userFriendly': 'User account already deleted! Try registering again 👤',
        };
      case 'US460':
        return {
          'message': 'Required parameter missing',
          'userFriendly': 'Required parameter missing! Check your request 📧',
        };
      case 'US461':
        return {
          'message': 'Invalid parameter',
          'userFriendly': 'Invalid parameter! Check your request 📧',
        };
      
      // 其他注册相关错误
      case 'US429':
        return {
          'message': 'Daily limit reached',
          'userFriendly': 'Too many attempts today! Take a break and try again tomorrow 🚫',
        };
      case 'US430':
        return {
          'message': 'Cooldown active',
          'userFriendly': 'Slow down, speed racer! Wait a bit before trying again ⏰',
        };
      case 'US503':
        return {
          'message': 'Service temporarily unavailable',
          'userFriendly': 'Our memory is taking a nap! 😴 Try again in a moment',
        };
      case 'US504':
        return {
          'message': 'Failed to send email',
          'userFriendly': 'Email got lost in the digital void! 📧 Try again',
        };
      
      default:
        return {
          'message': 'Engineers are fixing bugs! 🐛',
          'userFriendly': 'Server is having a coffee break! ☕ Try again later',
        };
    }
  }

  /// 判断是否为限流相关错误
  static bool isRateLimitError(String businessCode) {
    return businessCode == 'US429' || businessCode == 'US430' || businessCode == 'US431';
  }

  /// 判断是否为账户锁定错误
  static bool isAccountLockedError(String businessCode) {
    return businessCode == 'US432' || businessCode == 'US444';
  }

  /// 判断是否为验证码相关错误
  static bool isVerificationCodeError(String businessCode) {
    return businessCode.startsWith('US44') || businessCode.startsWith('US45');
  }

  /// 获取错误显示样式
  static Map<String, dynamic> getErrorStyle(String businessCode) {
    if (isRateLimitError(businessCode)) {
      return {
        'color': 'orange',
        'icon': 'warning',
        'duration': 5,
      };
    } else if (isAccountLockedError(businessCode)) {
      return {
        'color': 'red',
        'icon': 'lock',
        'duration': 6,
      };
    } else if (isVerificationCodeError(businessCode)) {
      return {
        'color': 'red',
        'icon': 'error',
        'duration': 4,
      };
    } else {
      return {
        'color': 'red',
        'icon': 'error',
        'duration': 4,
      };
    }
  }
}
