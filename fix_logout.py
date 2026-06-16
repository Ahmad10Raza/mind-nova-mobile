import os

files = [
    '/home/ahmad10raza/Documents/Major Projects/MindNova/mind_nova_mobile/lib/features/dashboard/presentation/widgets/sidebar_drawer.dart',
    '/home/ahmad10raza/Documents/Major Projects/MindNova/mind_nova_mobile/lib/features/profile/presentation/profile_screen.dart'
]

for file_path in files:
    with open(file_path, 'r') as f:
        content = f.read()

    # Fix sidebar_drawer.dart
    content = content.replace(
        "Navigator.of(context).pop();\n                    ref.read(authProvider.notifier).logout();",
        "final auth = ref.read(authProvider.notifier);\n                    Navigator.of(context).pop();\n                    auth.logout();"
    )

    # Fix profile_screen.dart
    content = content.replace(
        "Navigator.pop(context);\n                ref.read(authProvider.notifier).logout();",
        "final auth = ref.read(authProvider.notifier);\n                Navigator.pop(context);\n                auth.logout();"
    )

    with open(file_path, 'w') as f:
        f.write(content)

print("Done fixing logouts.")
