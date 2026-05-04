import re

with open('lib/screens/dashboard/tabs/settings_tab.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace withOpacity
content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)

# Replace activeColor
content = content.replace('activeColor:', 'activeThumbColor:')

# Replace context.mounted
content = content.replace('!context.mounted', '!mounted')

with open('lib/screens/dashboard/tabs/settings_tab.dart', 'w', encoding='utf-8') as f:
    f.write(content)
