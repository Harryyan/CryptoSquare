# ArticleDetailView HTML行间距过大问题修复

## 问题描述
在ArticleDetailView中显示的文章内容，部分文章出现行间距过大的问题，影响阅读体验。

## 问题原因分析

### 根本原因
后台返回的HTML内容中包含了过大的CSS内联样式：
```html
<p style="line-height: 38px; margin-top: 13px; margin-bottom: 13px; ...">
```

### 具体问题
1. **line-height: 38px** - 行间距过大（正常应该是24px以内）
2. **margin值过大** - 段落间距过大
3. **内联样式优先级高** - 覆盖了Flutter HTML插件的样式设置

## 解决方案

### 1. 预处理HTML内容
在渲染HTML前，使用正则表达式处理内联样式：

```dart
String _preprocessHtmlContent(String htmlContent) {
  // 移除所有line-height样式
  processedContent = processedContent.replaceAll(
    RegExp(r'line-height:\s*\d+px;?'), 
    ''
  );
  
  // 替换过大的margin值
  processedContent = processedContent.replaceAllMapped(
    RegExp(r'margin-top:\s*(\d+)px'), 
    (match) {
      int margin = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (margin > 16) {
        return 'margin-top: 8px';
      }
      return match.group(0) ?? '';
    }
  );
  
  return processedContent;
}
```

### 2. 增强HTML样式配置
为flutter_html插件配置更完善的样式：

```dart
style: {
  'p': Style(
    margin: Margins.only(bottom: 12),
    lineHeight: LineHeight(1.6), // 强制设置合理的行间距
    fontSize: FontSize(16.0),
  ),
  'ol': Style(
    padding: HtmlPaddings.zero,
    margin: Margins.only(left: 16, bottom: 12),
    listStylePosition: ListStylePosition.outside,
  ),
  'li': Style(
    lineHeight: LineHeight(1.6), // 为li也设置合理的行间距
  ),
}
```

## 修复效果

### 修复前
- 行间距过大（38px）
- 段落间距不一致
- 阅读体验差

### 修复后
- 合理的行间距（1.6倍行高，约24px）
- 一致的段落间距（12px）
- 更好的阅读体验

## 技术细节

### 处理的CSS属性
1. **line-height** - 移除或限制在24px以内
2. **margin-top/margin-bottom** - 限制在16px以内
3. **font-size** - 统一为16px

### 正则表达式模式
- `line-height:\s*\d+px;?` - 匹配所有line-height样式
- `margin-top:\s*(\d+)px` - 匹配margin-top并捕获数值
- `margin-bottom:\s*(\d+)px` - 匹配margin-bottom并捕获数值

### 应用顺序
1. 预处理HTML内容（移除/修改内联样式）
2. 应用flutter_html样式配置
3. 渲染最终内容

## 测试验证

### 测试场景
1. **包含大行间距的文章** - 验证行间距是否正常
2. **包含列表的文章** - 验证列表样式是否正确
3. **包含标题的文章** - 验证标题样式是否保持
4. **纯文本段落** - 验证基本段落格式

### 预期结果
- 所有段落行间距一致且合理
- 列表格式正确显示
- 标题样式保持原有效果
- 整体阅读体验提升

## 注意事项

### 兼容性
- 确保不影响正常格式的HTML内容
- 保持有序列表和无序列表的正确显示
- 维持标题和强调文本的样式

### 性能
- HTML预处理只在内容加载时执行一次
- 正则表达式处理对性能影响微小
- 不影响页面滚动和交互性能

### 维护
- 如果后台HTML格式发生变化，可能需要调整正则表达式
- 可以根据需要添加更多CSS属性的处理
- 建议定期检查文章显示效果

## 总结

通过预处理HTML内容和增强样式配置，成功解决了文章内容行间距过大的问题，提升了用户阅读体验。该方案具有良好的兼容性和可维护性。 