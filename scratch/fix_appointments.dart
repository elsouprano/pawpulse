import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard/tabs/appointments_tab.dart');
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  var original = content;

  // Fix .withOpacity(x) -> .withValues(alpha: x)
  content = content.replaceAllMapped(
    RegExp(r'\.withOpacity\(([^)]+)\)'),
    (match) => '.withValues(alpha: ${match.group(1)})'
  );

  // Remove unused import
  content = content.replaceAll("import '../../../widgets/common/gradient_button.dart';\n", '');
  content = content.replaceAll("import '../../../widgets/common/error_card.dart';\n", '');

  // Fix use_build_context_synchronously
  content = content.replaceAll(
    '''                              await _appointmentProvider.cancelAppointment(appointment.id);
                              if (mounted && _appointmentProvider.value.error == null) {
                                ScaffoldMessenger.of(context).showSnackBar('''.trimRight(),
    '''                              await _appointmentProvider.cancelAppointment(appointment.id);
                              if (!context.mounted) return;
                              if (_appointmentProvider.value.error == null) {
                                ScaffoldMessenger.of(context).showSnackBar('''.trimRight()
  );
  
  if (content != original) {
    file.writeAsStringSync(content);
    print('Updated appointments_tab.dart');
  } else {
    print('No changes made to appointments_tab.dart');
  }
}
