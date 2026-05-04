import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard/tabs/settings_tab.dart');
  var content = file.readAsStringSync();

  // Replace withOpacity
  content = content.replaceAllMapped(
      RegExp(r'\.withOpacity\((.*?)\)'),
      (match) => '.withValues(alpha: ${match.group(1)})');

  // Replace activeColor
  content = content.replaceAll('activeColor:', 'activeThumbColor:');

  // Replace context.mounted
  content = content.replaceAll('!context.mounted', '!mounted');

  file.writeAsStringSync(content);
}
