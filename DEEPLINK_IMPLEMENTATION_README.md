# 深度链接功能实现说明

## 功能概述

本次实现为CryptoSquare应用添加了浏览器内唤起app的功能，支持通过深度链接直接跳转到论坛文章详情页面。

## 实现的功能

### 1. 支持的深度链接格式

- **自定义协议**: `cryptosquare://app?topicId=123`
- **Universal Links (推荐)**: `https://cryptosquare.org/app?topicId=123`

### 2. 网页端JavaScript代码

**推荐使用Universal Links格式（与iOS Associated Domains匹配）：**

```javascript
// 推荐方案：使用Universal Links
let r = "https://cryptosquare.org/app";
if (y.params.id) {
    r = "https://cryptosquare.org/app?topicId=" + y.params.id;
}
window.location.href = r;
```

**备用方案：使用自定义协议（需要配置iOS URL Scheme）：**

```javascript
// 备用方案：自定义协议
let r = "cryptosquare://app";
if (y.params.id) {
    r = "cryptosquare://app?topicId=" + y.params.id;
}
window.location.href = r;
```

### 3. 导航逻辑

当用户点击深度链接时，应用会：

1. **解析topicId参数**
   - 如果有topicId，则自动切换到"全球论坛"Tab并导航到对应的文章详情页面
   - 如果没有topicId，则直接打开app停留在首页，不做任何跳转

2. **特殊topicId处理**
   - topicId为5313或5981时，会打开特殊的WebView页面，显示"300U大奖过来拿！Web2与Web3大佬选美大比拼！"
   - 其他topicId则使用标准的文章详情页面

3. **Tab切换逻辑**
   - **有topicId参数时**: 自动切换到"全球论坛"Tab（第4个Tab，index=3），然后导航到相应的页面
   - **无topicId参数时**: 保持在首页，不进行任何Tab切换

## 技术实现

### 1. 包依赖

```yaml
dependencies:
  app_links: ^6.3.2  # 深度链接处理
```

### 2. Android配置

在`android/app/src/main/AndroidManifest.xml`中添加了：

```xml
<!-- Deep Link: Custom Scheme -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="cryptosquare" />
</intent-filter>

<!-- Deep Link: HTTPS URLs -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="cryptosquare.org" />
</intent-filter>
```

### 3. iOS配置

iOS项目中的associate domain配置已由开发者完成。

### 4. 核心代码实现

在`main.dart`中的实现：

```dart
// 初始化深度链接监听器
void _initDeepLinkListener() async {
  try {
    final appLinks = AppLinks();
    
    // 监听所有深度链接事件（包括初始链接和运行时链接）
    appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });
  } catch (e) {
    print('初始化深度链接监听器失败: $e');
  }
}
```

### 5. 核心代码文件

- **main.dart**: 深度链接监听和处理逻辑
- **topic_webview.dart**: 特殊topicId的WebView页面
- **article_controller.dart**: 文章详情导航控制器

## 使用方法

### 1. 网页端触发代码

```javascript
let r = "cryptosquare://app?topicId=123"
if (y.params.id) {
    r = "cryptosquare://app?topicId=" + y.params.id;
}
// 触发深度链接
window.location.href = r;
```

### 2. 测试深度链接

#### Android测试

```bash
# 测试基本深度链接
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "cryptosquare://app" \
  com.cryptosquare.cryptosquare

# 测试带topicId的深度链接
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "cryptosquare://app?topicId=123" \
  com.cryptosquare.cryptosquare

# 测试特殊topicId
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "cryptosquare://app?topicId=5313" \
  com.cryptosquare.cryptosquare
```

#### iOS测试

```bash
# 使用xcrun模拟器测试
xcrun simctl openurl booted "cryptosquare://app?topicId=123"
```

## 安装和部署

### 1. 安装依赖

```bash
flutter pub get
```

### 2. Android构建

```bash
flutter build apk --release
# 或
flutter build appbundle --release
```

### 3. iOS构建

```bash
flutter build ios --release
```

## 功能流程图

```
网页点击链接
    ↓
解析深度链接URL
    ↓
检查topicId参数
    ↓
┌─────────────┬─────────────┐
│   有topicId  │  无topicId   │
└─────────────┴─────────────┘
    ↓                ↓
切换到论坛Tab      切换到论坛Tab
    ↓                ↓
检查是否特殊ID      停留在论坛页面
    ↓
┌─────────────┬─────────────┐
│ 5313/5981   │   其他ID     │
└─────────────┴─────────────┘
    ↓                ↓
打开WebView页面   打开文章详情页面
```

## 注意事项

1. **网络权限**: 确保应用有网络访问权限
2. **URL验证**: 深度链接会进行URL格式验证
3. **错误处理**: 包含完整的错误处理机制
4. **延迟导航**: 使用延迟导航确保应用完全启动后再执行跳转

## 调试信息

应用会在控制台输出以下调试信息：

- `收到深度链接: [URL]` - 接收到深度链接时
- `导航到文章详情页面失败: [错误]` - 导航失败时
- `初始化深度链接监听器失败: [错误]` - 初始化失败时

## 后续优化建议

1. **缓存机制**: 对频繁访问的文章进行缓存
2. **预加载**: 预加载论坛页面数据
3. **用户体验**: 添加加载动画和错误提示
4. **统计埋点**: 添加深度链接使用统计 