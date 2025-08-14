import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            children: [
              // Settings sections
              ...viewModel.settingsSections.map((section) => _buildSection(
                context,
                section,
                viewModel,
              )),

              // App info section
              _buildInfoSection(context, viewModel),

              // Danger zone
              _buildDangerZone(context, viewModel),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
    }
  }

  Widget _buildSection(BuildContext context, SettingsSection section, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: section.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == section.items.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                    trailing: item.isSwitch
                        ? Switch(
                            value: item.switchValue ?? false,
                            onChanged: item.onSwitchChanged,
                            activeColor: AppColors.primaryGreen,
                          )
                        : const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textGray,
                          ),
                    onTap: item.isSwitch ? null : () => _handleSettingTap(context, item, viewModel),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 70,
                      color: AppColors.borderLight,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Información',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.infoBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.infoBlue,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Acerca de',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: Text(
                  '${viewModel.appName} v${viewModel.appVersion}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textGray,
                ),
                onTap: () => _showAboutDialog(context, viewModel),
              ),
              const Divider(height: 1, indent: 70, color: AppColors.borderLight),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.warningYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: AppColors.warningYellow,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Ayuda y soporte',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: const Text(
                  'Contacta con nosotros',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textGray,
                ),
                onTap: () => _showHelpDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context, SettingsViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            'Zona de peligro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.errorRed,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.errorRed,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Restablecer configuración',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: const Text(
                  'Volver a la configuración predeterminada',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textGray,
                ),
                onTap: () => _showResetDialog(context, viewModel),
              ),
              const Divider(height: 1, indent: 70, color: AppColors.borderLight),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: AppColors.errorRed,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Eliminar cuenta',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.errorRed,
                  ),
                ),
                subtitle: const Text(
                  'Eliminar permanentemente todos los datos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.errorRed,
                ),
                onTap: () => _showDeleteAccountDialog(context, viewModel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSettingTap(BuildContext context, SettingsItem item, SettingsViewModel viewModel) {
    // Handle different setting taps
    switch (item.title) {
      case 'Idioma':
        _showLanguageDialog(context, viewModel);
        break;
      case 'Tema':
        _showThemeDialog(context, viewModel);
        break;
      case 'Frecuencia':
        _showFrequencyDialog(context, viewModel);
        break;
      default:
        // Default behavior for other settings
        break;
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: viewModel.availableLanguages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: viewModel.language,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: viewModel.availableThemes.map((theme) {
            return RadioListTile<String>(
              title: Text(theme),
              value: theme,
              groupValue: viewModel.theme,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setTheme(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFrequencyDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frecuencia de notificaciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: viewModel.availableFrequencies.map((frequency) {
            return RadioListTile<String>(
              title: Text(frequency),
              value: frequency,
              groupValue: viewModel.notificationFrequency,
              onChanged: (value) {
                if (value != null) {
                  viewModel.setNotificationFrequency(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, SettingsViewModel viewModel) {
    showAboutDialog(
      context: context,
      applicationName: viewModel.appName,
      applicationVersion: 'v${viewModel.appVersion} (${viewModel.buildNumber})',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.agriculture,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const SizedBox(height: 20),
        const Text(
          'AgroBot EC es tu asistente agrícola inteligente, diseñado para ayudar a los agricultores ecuatorianos con recomendaciones personalizadas sobre cultivos, fertilización, control de plagas y más.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 15),
        const Text(
          'Desarrollado por estudiantes de la Universidad de las Fuerzas Armadas ESPE.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.textGray,
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda y Soporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para obtener ayuda con la aplicación, puedes:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 15),
            Text('• Consultar la sección de preguntas frecuentes'),
            SizedBox(height: 8),
            Text('• Contactar a nuestro equipo de soporte'),
            SizedBox(height: 8),
            Text('• Enviar comentarios y sugerencias'),
            SizedBox(height: 15),
            Text(
              'Email: soporte@agrobot.ec',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer configuración'),
        content: const Text(
          '¿Estás seguro de que deseas restablecer toda la configuración a los valores predeterminados? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await viewModel.resetSettings();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuración restablecida'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Eliminar cuenta',
          style: TextStyle(color: AppColors.errorRed),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ Esta acción es irreversible',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.errorRed,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Se eliminarán permanentemente:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text('• Tu perfil y configuraciones'),
            Text('• Historial de consultas'),
            Text('• Todas las notificaciones'),
            Text('• Datos almacenados localmente'),
            SizedBox(height: 15),
            Text(
              '¿Estás completamente seguro?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mantener cuenta'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation(context, viewModel);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context, SettingsViewModel viewModel) {
    final TextEditingController confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirmación final',
          style: TextStyle(color: AppColors.errorRed),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para confirmar la eliminación de tu cuenta, escribe "ELIMINAR" en el campo de abajo:',
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'Escribe ELIMINAR',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              confirmController.dispose();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: confirmController,
            builder: (context, value, child) {
              return TextButton(
                onPressed: value.text == 'ELIMINAR'
                    ? () async {
                        await viewModel.deleteAccount();
                        confirmController.dispose();
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cuenta eliminada'),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                        // Navigate to login or exit app
                      }
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                ),
                child: const Text('Eliminar cuenta'),
              );
            },
          ),
        ],
      ),
    );
  }