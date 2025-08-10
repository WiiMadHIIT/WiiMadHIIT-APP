import 'package:flutter/material.dart';
import 'tiktok_wheel_picker.dart';

/// 训练设置对话框的配置参数
class TrainingSetupConfig {
  final int initialRounds;
  final int initialRoundDuration; // 以秒为单位
  final int maxRounds;
  final int maxMinutes;
  final int maxSeconds;
  final String title;
            final MaterialColor roundsColor;
  final MaterialColor timeColor;
  final MaterialColor totalTimeColor;
  final MaterialColor confirmButtonColor;

  const TrainingSetupConfig({
    required this.initialRounds,
    required this.initialRoundDuration,
    this.maxRounds = 10,
    this.maxMinutes = 60,
    this.maxSeconds = 59,
    this.title = 'Set Rounds & Time',
    this.roundsColor = Colors.orange,
    this.timeColor = Colors.deepPurple,
    this.totalTimeColor = Colors.blue,
    this.confirmButtonColor = Colors.blue,
  });
}

/// 训练设置对话框的返回结果
class TrainingSetupResult {
  final int rounds;
  final int roundDuration; // 以秒为单位
  final int totalDuration; // 总时长（秒）

  const TrainingSetupResult({
    required this.rounds,
    required this.roundDuration,
    required this.totalDuration,
  });

  /// 获取总时长（分钟）
  int get totalMinutes => totalDuration ~/ 60;
  
  /// 获取剩余秒数
  int get remainingSeconds => totalDuration % 60;
  
  /// 获取单轮时长（分钟）
  int get roundMinutes => roundDuration ~/ 60;
  
  /// 获取单轮时长（秒）
  int get roundSeconds => roundDuration % 60;
}

/// 通用的训练设置对话框组件
class TrainingSetupDialog extends StatefulWidget {
  final TrainingSetupConfig config;
  final VoidCallback? onClose;
  final bool showResultOverlay;

  const TrainingSetupDialog({
    Key? key,
    required this.config,
    this.onClose,
    this.showResultOverlay = false,
  }) : super(key: key);

  /// 显示竖屏训练设置对话框
  static Future<TrainingSetupResult?> showPortrait(
    BuildContext context, {
    required TrainingSetupConfig config,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<TrainingSetupResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => TrainingSetupDialog(
        config: config,
        onClose: onClose,
      ),
    );
  }

  /// 显示横屏训练设置对话框
  static Future<TrainingSetupResult?> showLandscape(
    BuildContext context, {
    required TrainingSetupConfig config,
    VoidCallback? onClose,
    bool showResultOverlay = false,
  }) {
    return showDialog<TrainingSetupResult>(
      context: context,
      barrierDismissible: true,
      builder: (context) => TrainingSetupDialog(
        config: config,
        onClose: onClose,
        showResultOverlay: showResultOverlay,
      ),
    );
  }

  @override
  State<TrainingSetupDialog> createState() => _TrainingSetupDialogState();
}

class _TrainingSetupDialogState extends State<TrainingSetupDialog> {
  late int tempRounds;
  late int tempMinutes;
  late int tempSeconds;
  late bool isLandscape;

  @override
  void initState() {
    super.initState();
    tempRounds = widget.config.initialRounds;
    tempMinutes = widget.config.initialRoundDuration ~/ 60;
    tempSeconds = widget.config.initialRoundDuration % 60;
    // 不在 initState 中访问 MediaQuery，在 build 中动态获取
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里安全地访问 MediaQuery
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation != (isLandscape ? Orientation.landscape : Orientation.portrait)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleOrientationChange(orientation);
          });
        }
        return isLandscape ? _buildLandscapeDialog() : _buildPortraitDialog();
      },
    );
  }

  void _handleOrientationChange(Orientation newOrientation) {
    if (newOrientation == Orientation.landscape) {
      Navigator.of(context).pop();
      TrainingSetupDialog.showLandscape(
        context,
        config: widget.config,
        onClose: widget.onClose,
        showResultOverlay: widget.showResultOverlay,
      );
    } else {
      Navigator.of(context).pop();
      TrainingSetupDialog.showPortrait(
        context,
        config: widget.config,
        onClose: widget.onClose,
      );
    }
  }

  Widget _buildPortraitDialog() {
    final totalSeconds = tempRounds * (tempMinutes * 60 + tempSeconds);
    final totalMinutes = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds % 60;
    
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Set Rounds & Time',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1,
              ),
            ),
            SizedBox(height: 16),
            
            // 设置区域 - 轮次和时间并排
            Row(
              children: [
                // 轮次设置
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.config.roundsColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.config.roundsColor.withOpacity(0.1), width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Rounds',
                          style: TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w600, 
                            color: widget.config.roundsColor.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        TikTokWheelPicker(
                          label: '',
                          value: tempRounds,
                          min: 1,
                          max: widget.config.maxRounds,
                          onChanged: (v) => setState(() => tempRounds = v),
                          color: widget.config.roundsColor,
                          compact: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // 时间设置
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.config.timeColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: widget.config.timeColor.withOpacity(0.1), width: 1),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w600, 
                            color: widget.config.timeColor.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 分钟选择器
                            Expanded(
                              child: TikTokWheelPicker(
                                label: 'Min',
                                value: tempMinutes,
                                min: 0,
                                max: widget.config.maxMinutes,
                                onChanged: (v) => setState(() => tempMinutes = v),
                                color: widget.config.timeColor,
                                compact: true,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: widget.config.timeColor.shade400,
                                ),
                              ),
                            ),
                            // 秒选择器
                            Expanded(
                              child: TikTokWheelPicker(
                                label: 'Sec',
                                value: tempSeconds,
                                min: 0,
                                max: widget.config.maxSeconds,
                                onChanged: (v) => setState(() => tempSeconds = v),
                                color: widget.config.timeColor,
                                compact: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // 总时间显示
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${tempRounds} Rounds × ${tempMinutes.toString().padLeft(2, '0')}:${tempSeconds.toString().padLeft(2, '0')} = ${totalMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Colors.black87, 
                      fontWeight: FontWeight.w600, 
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // 确认按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final result = TrainingSetupResult(
                    rounds: tempRounds,
                    roundDuration: tempMinutes * 60 + tempSeconds,
                    totalDuration: tempRounds * (tempMinutes * 60 + tempSeconds),
                  );
                  Navigator.of(context).pop(result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'OK', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.2
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeDialog() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 468 ? 420 : screenWidth - 48;
    final totalSeconds = tempRounds * (tempMinutes * 60 + tempSeconds);
    final totalMinutes = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds % 60;
    
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Stack(
              children: [
                // 右上角关闭按钮
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.black54),
                    onPressed: () {
                      widget.onClose?.call();
                      Navigator.of(context).pop();
                      if (widget.showResultOverlay) {
                        Navigator.of(context).maybePop();
                      }
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Set Rounds & Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.1),
                      ),
                    ),
                    
                    // 设置区域 - 轮次和时间并排
                    Row(
                      children: [
                        // 轮次设置
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.config.roundsColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: widget.config.roundsColor.withOpacity(0.1), width: 1),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Rounds',
                                  style: TextStyle(
                                    fontSize: 13, 
                                    fontWeight: FontWeight.w600, 
                                    color: widget.config.roundsColor.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                TikTokWheelPicker(
                                  label: '',
                                  value: tempRounds,
                                  min: 1,
                                  max: widget.config.maxRounds,
                                  onChanged: (v) => setState(() => tempRounds = v),
                                  color: widget.config.roundsColor,
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 12),
                        
                        // 时间设置
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: widget.config.timeColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: widget.config.timeColor.withOpacity(0.1), width: 1),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Duration',
                                  style: TextStyle(
                                    fontSize: 13, 
                                    fontWeight: FontWeight.w600, 
                                    color: widget.config.timeColor.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // 分钟选择器
                                    Expanded(
                                      child: TikTokWheelPicker(
                                        label: 'Min',
                                        value: tempMinutes,
                                        min: 0,
                                        max: widget.config.maxMinutes,
                                        onChanged: (v) => setState(() => tempMinutes = v),
                                        color: widget.config.timeColor,
                                        compact: true,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Text(
                                        ':',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: widget.config.timeColor.shade400,
                                        ),
                                      ),
                                    ),
                                    // 秒选择器
                                    Expanded(
                                      child: TikTokWheelPicker(
                                        label: 'Sec',
                                        value: tempSeconds,
                                        min: 0,
                                        max: widget.config.maxSeconds,
                                        onChanged: (v) => setState(() => tempSeconds = v),
                                        color: widget.config.timeColor,
                                        compact: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8),
                    
                    // 总时间显示
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '${tempRounds} × ${tempMinutes.toString().padLeft(2, '0')}:${tempSeconds.toString().padLeft(2, '0')} = ${totalMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.black87, 
                              fontWeight: FontWeight.w600, 
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // 确认按钮
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {
                          final result = TrainingSetupResult(
                            rounds: tempRounds,
                            roundDuration: tempMinutes * 60 + tempSeconds,
                            totalDuration: tempRounds * (tempMinutes * 60 + tempSeconds),
                          );
                          Navigator.of(context).pop(result);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          'OK', 
                          style: TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.bold, 
                            letterSpacing: 1.1
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }







  Widget _buildSetupControls() {
    return Row(
      children: [
        // 轮次设置
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 12 : 16,
              vertical: isLandscape ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: widget.config.roundsColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.config.roundsColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Rounds',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.config.roundsColor.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                TikTokWheelPicker(
                  label: '',
                  value: tempRounds,
                  min: 1,
                  max: widget.config.maxRounds,
                  onChanged: (v) => setState(() => tempRounds = v),
                  color: widget.config.roundsColor,
                  compact: isLandscape,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        // 时间设置
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 12 : 16,
              vertical: isLandscape ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: widget.config.timeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.config.timeColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.config.timeColor.shade700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TikTokWheelPicker(
                        label: 'Min',
                        value: tempMinutes,
                        min: 0,
                        max: widget.config.maxMinutes,
                        onChanged: (v) => setState(() => tempMinutes = v),
                        color: widget.config.timeColor,
                        compact: isLandscape,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.config.timeColor.shade400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TikTokWheelPicker(
                        label: 'Sec',
                        value: tempSeconds,
                        min: 0,
                        max: widget.config.maxSeconds,
                        onChanged: (v) => setState(() => tempSeconds = v),
                        color: widget.config.timeColor,
                        compact: isLandscape,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }




} 