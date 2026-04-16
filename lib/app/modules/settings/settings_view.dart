import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/snackbar_helper.dart';
import 'settings_cubit.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SettingsPasswordChanged) {
          SnackbarHelper.showSuccess(context, 'Password changed successfully');
          context.read<SettingsCubit>().resetToInitial();
        } else if (state is SettingsTwoFactorEnabled) {
          _showTwoFactorQrDialog(context, state.totpUri);
        } else if (state is SettingsTwoFactorDisabled) {
          SnackbarHelper.showSuccess(context, 'Two-factor authentication disabled');
          context.read<SettingsCubit>().resetToInitial();
        } else if (state is SettingsFailure) {
          SnackbarHelper.showError(context, state.message);
          context.read<SettingsCubit>().resetToInitial();
        }
      },
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        final isLoading = state is SettingsLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          _showChangePasswordDialog(context, cubit),
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Enable Two-Factor Auth'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: cubit.enableTwoFactor,
                    ),
                    ListTile(
                      leading: const Icon(Icons.no_encryption_outlined, color: Colors.orange),
                      title: const Text('Disable Two-Factor Auth'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showDisableTwoFactorDialog(context, cubit),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode),
                      title: const Text('Dark Mode'),
                      value: cubit.isDarkMode,
                      onChanged: (_) => cubit.toggleTheme(),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: const Text('Sign Out'),
                      onTap: cubit.signOut,
                    ),
                  ],
                ),
        );
      },
    );
  }

  void _showTwoFactorQrDialog(BuildContext context, String totpUri) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Scan this URI with your authenticator app, then confirm with your 6-digit code.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SelectableText(
              totpUri,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<SettingsCubit>().resetToInitial();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showDisableTwoFactorDialog(BuildContext context, SettingsCubit cubit) {
    final codeController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disable Two-Factor Authentication'),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: '6-digit TOTP code',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.disableTwoFactor(code: codeController.text.trim());
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, SettingsCubit cubit) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.changePassword(
                currentPassword: currentPassController.text,
                newPassword: newPassController.text,
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
