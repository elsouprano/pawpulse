import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard/tabs/overview_tab.dart');
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  var original = content;

  // Fix .withOpacity(x) -> .withValues(alpha: x)
  content = content.replaceAllMapped(
    RegExp(r'\.withOpacity\(([^)]+)\)'),
    (match) => '.withValues(alpha: ${match.group(1)})'
  );

  // Fix curly braces in `_formatTimeAgo`
  content = content.replaceAll(
    'if (futureDiff.inDays > 1) return "In \${futureDiff.inDays}d";',
    'if (futureDiff.inDays > 1) {\n        return "In \${futureDiff.inDays}d";\n      }'
  );
  content = content.replaceAll(
    'else if (futureDiff.inDays == 1) return "Tomorrow";',
    'else if (futureDiff.inDays == 1) {\n        return "Tomorrow";\n      }'
  );
  content = content.replaceAll(
    'else if (futureDiff.inHours > 0) return "In \${futureDiff.inHours}h";',
    'else if (futureDiff.inHours > 0) {\n        return "In \${futureDiff.inHours}h";\n      }'
  );
  content = content.replaceAll(
    'else return "In \${futureDiff.inMinutes}m";',
    'else {\n        return "In \${futureDiff.inMinutes}m";\n      }'
  );

  // Fix curly braces in `_buildMyPetsPreview`
  content = content.replaceAll(
    "if (s.contains('attention') || s.contains('issue')) healthColor = AppTheme.secondary;",
    "if (s.contains('attention') || s.contains('issue')) {\n                  healthColor = AppTheme.secondary;\n                }"
  );
  content = content.replaceAll(
    "else if (s.contains('critical') || s.contains('bad')) healthColor = AppTheme.error;",
    "else if (s.contains('critical') || s.contains('bad')) {\n                  healthColor = AppTheme.error;\n                }"
  );
  
  if (content != original) {
    file.writeAsStringSync(content);
    print('Updated overview_tab.dart');
  }
}
