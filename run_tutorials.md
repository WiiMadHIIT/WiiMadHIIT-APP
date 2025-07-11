<!-- git bash 配置临时环境 -->

export JAVA_HOME="/d/Program Files/Java/jdk-17.0.12"
export PATH="$JAVA_HOME/bin:$PATH"

<!-- 检查设备 -->
flutter devices

<!-- git bash 运行flutter项目 -->
flutter run
flutter run -d emulator-5554  # Android 模拟器
flutter run -d iPhone  # iOS 模拟器
flutter run -d chrome  # Web 平台

<!-- 创建项目 -->
flutter create my_app
cd my_app

<!-- 依赖安装 -->
首先在pubspec.yaml下加入依赖，然后运行
flutter pub get