import 'package:flutter/material.dart';

/// 标签工具类，用于处理标签显示相关的功能
class TagUtils {
  /// 标签最大长度限制
  static const int maxTagLength = 10;

  /// 处理标签文本，如果超过最大长度则在中间显示省略号
  ///
  /// [tag] 原始标签文本
  /// [maxLength] 最大长度限制，默认为10
  /// 返回处理后的标签文本
  static String formatTag(String tag, {int maxLength = maxTagLength}) {
    if (tag.length <= maxLength) {
      return tag;
    }

    // 计算前后各保留的字符数
    final int frontChars = (maxLength - 3) ~/ 2;
    final int endChars = maxLength - 3 - frontChars;

    // 在中间显示省略号
    return '${tag.substring(0, frontChars)}...${tag.substring(tag.length - endChars)}';
  }
}
