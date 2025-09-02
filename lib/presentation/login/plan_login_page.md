# 登录页面 API 接口设计文档

## 概述
本文档定义了登录页面所需的所有API接口，包括登录验证码、注册验证码等相关接口。

## API 基础信息
- **Base URL**: `/api/auth`
- **Content-Type**: `application/json`
- **认证方式**: 除登录接口外，其他接口需要 Bearer Token

---

## 1. 发送登录验证码

### 接口信息
- **URL**: `POST /api/auth/login/send-code`
- **描述**: 向指定邮箱发送登录验证码
- **认证**: 无需认证

### 请求参数
```json
{
  "email": "user@example.com"
}
```

### 响应格式
```json
{
  "code": "A200",
  "message": "Verification code sent successfully",
  "data": {
    "email": "user@example.com",
    "expireTime": 1737367800000,
    "resendTime": 1737367500000
  }
}
```

### 错误响应
```json
{
  "code": "E400",
  "message": "Invalid email format",
  "data": null
}
```

---

## 2. 验证登录验证码

### 接口信息
- **URL**: `POST /api/auth/login/verify-code`
- **描述**: 验证登录验证码并完成登录
- **认证**: 无需认证

### 请求参数
```json
{
  "email": "user@example.com",
  "code": "123456"
}
```

### 响应格式
```json
{
  "code": "A200",
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "issuedAt": 1737363600000,
    "expiresIn": 1737367200000
  }
}
```

### 错误响应
```json
{
  "code": "E401",
  "message": "Invalid or expired verification code",
  "data": null
}
```

---

## 3. 发送注册验证码

### 接口信息
- **URL**: `POST /api/auth/register/send-code`
- **描述**: 向指定邮箱发送注册验证码
- **认证**: 无需认证

### 请求参数
```json
{
  "email": "newuser@example.com"
}
```

### 响应格式
```json
{
  "code": "A200",
  "message": "Registration verification code sent successfully",
  "data": {
    "email": "newuser@example.com",
    "expireTime": 1737367800000,
    "resendTime": 1737367500000
  }
}
```

### 错误响应
```json
{
  "code": "E400",
  "message": "Email already registered",
  "data": null
}
```

---

## 4. 验证注册验证码并完成注册

### 接口信息
- **URL**: `POST /api/auth/register/verify-code`
- **描述**: 验证注册验证码并创建新账户
- **认证**: 无需认证

### 请求参数
```json
{
  "email": "newuser@example.com",
  "code": "123456",
  "activationCode": "AMZ123456789"
}
```

### 响应格式
```json
{
  "code": "A200",
  "message": "Account created successfully",
  "data": {
    "status": "success"
  }
}
```

### 错误响应
```json
{
  "code": "E400",
  "message": "Invalid or expired verification code",
  "data": {
    "status": "failed"
  }
}
```

---

## 5. 刷新Token

### 接口信息
- **URL**: `POST /api/auth/refresh`
- **描述**: 使用刷新Token获取新的访问Token
- **认证**: 需要刷新Token

### 请求参数
```json
{
  "refreshToken": "refresh_token_here"
}
```

### 响应格式
```json
{
  "code": "A200",
  "message": "Token refreshed successfully",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "new_refresh_token_here",
    "issuedAt": 1737363600000,
    "expiresIn": 1737367200000
  }
}
```

---

## 错误码定义

| 错误码 | 含义 | HTTP状态码 |
|--------|------|------------|
| A200 | Success | 200 |
| E400 | Bad Request | 400 |
| E401 | Unauthorized | 401 |
| E403 | Forbidden | 403 |
| E404 | Not Found | 404 |
| E429 | Too Many Requests | 429 |
| E500 | Internal Server Error | 500 |

---

## 接口调用流程

### 登录流程
1. 调用 `POST /api/auth/login/send-code` 发送验证码
2. 用户输入验证码
3. 调用 `POST /api/auth/login/verify-code` 验证并登录

### 注册流程
1. 调用 `POST /api/auth/register/send-code` 发送注册验证码
2. 用户输入验证码
3. 调用 `POST /api/auth/register/verify-code` 完成注册

---

## 安全考虑

### 1. 验证码安全
- 验证码有效期：5分钟
- 重发间隔：1分钟
- 最大重试次数：5次
- 验证码长度：6位数字

### 2. 激活码安全
- 激活码格式：AMZ + 9位数字
- 激活码一次性使用
- 激活码与设备绑定

### 3. 频率限制
- 验证码发送：每分钟最多3次
- 验证码验证：每分钟最多5次
- 激活码验证：每分钟最多3次

---

## 数据模型

### User 模型
```json
{
  "userId": "string",
  "username": "string",
  "email": "string",
  "avatar": "string?",
  "isActivated": "boolean",
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp?"
}
```

### DeviceInfo 模型
```json
{
  "deviceId": "string",
  "deviceType": "string",
  "activationDate": "timestamp",
  "lastActiveAt": "timestamp?"
}
```

---

---

## 注意事项

1. **邮箱验证**: 所有邮箱操作都需要验证邮箱格式
2. **状态管理**: 前端需要管理验证码发送状态和倒计时
3. **错误处理**: 需要友好的错误提示和重试机制
4. **安全性**: 验证码和激活码都有有效期和重试限制
5. **用户体验**: 提供清晰的流程指引和状态反馈
