import 'package:day_app/core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/email_auth_service.dart';

const String pushTopic = 'push_enabled';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final _SettingsScreenState state;

  _AppLifecycleObserver(this.state);

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      state._loadPushSetting();
    }
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = false;
  bool _pushLoaded = false;
  final EmailAuthService _authService = EmailAuthService();

  @override
  void initState() {
    super.initState();
    _loadPushSetting();
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(this));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver(this));
    super.dispose();
  }

  Future<void> _loadPushSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEnabled = prefs.getBool('push_notifications') ?? false;

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    final actualEnabled = savedEnabled && authorized;

    if (actualEnabled) {
      await FirebaseMessaging.instance.subscribeToTopic(pushTopic);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(pushTopic);
    }

    if (!mounted) return;

    setState(() {
      _pushNotifications = actualEnabled;
      _pushLoaded = true;
    });
  }


  Future<void> _togglePushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final currentlyAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (value) {
      if (!currentlyAuthorized) {
        final newSettings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        final granted = newSettings.authorizationStatus == AuthorizationStatus.authorized ||
            newSettings.authorizationStatus == AuthorizationStatus.provisional;

        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Разрешение на уведомления отклонено')),
          );
          return;
        }
      }

      await FirebaseMessaging.instance.subscribeToTopic(pushTopic);
      await prefs.setBool('push_notifications', true);
      setState(() => _pushNotifications = true);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(pushTopic);
      await prefs.setBool('push_notifications', false);
      setState(() => _pushNotifications = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: AppBar(
                title: Text(
                  'Настройки',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
              ),
            ),

            // Основной контент
            Expanded(
              child: StreamBuilder<User?>(
                stream: _authService.authStateChanges,
                builder: (context, snapshot) {
                  final user = snapshot.data;

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (user != null) _buildUserProfile(user),
                      if (user == null) _buildAuthSection(context),

                      const SizedBox(height: 16),

                      Card(
                        child: _pushLoaded
                            ? SwitchListTile(
                          value: _pushNotifications,
                          onChanged: _togglePushNotifications,
                          title: const Text('Push-уведомления'),
                          subtitle: Text(
                            _pushNotifications ? 'Включены' : 'Выключены',
                            style: TextStyle(
                              color: _pushNotifications
                                  ? Colors.green
                                  : AppColors.textSecondary(context),
                            ),
                          ),
                        )
                            : const ListTile(
                          title: Text('Push-уведомления'),
                          subtitle: Text('Проверяем настройки...'),
                          trailing: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),


                      if (user != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.logout),
                            title: const Text('Выйти'),
                            onTap: () async {
                              await _authService.signOut();
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(User user) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(
          user.displayName ?? user.email ?? 'Пользователь',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        subtitle: Text(
          user.email ?? '',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      ),
    );
  }

  Widget _buildAuthSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              'assets/icons/sf/Password.png',
              width: 64,
              height: 64,
              color: AppColors.textPrimary(context),
            ),
            const SizedBox(height: 12),
            Text(
              'Вход или регистрация',
              style: TextStyle(fontSize: 18, color: AppColors.textPrimary(context)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAuthDialog,
              child: const Text('Войти / Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();

    bool isLogin = true;
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isLogin ? 'Вход' : 'Регистрация'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Пароль'),
                  ),
                  if (!isLogin)
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Имя или никнейм',
                        hintText: 'Как вас зовут?',
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => setDialogState(() => isLogin = !isLogin),
                  child: Text(isLogin ? 'Нет аккаунта? Регистрация' : 'Есть аккаунт? Вход'),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                    setDialogState(() => loading = true);

                    try {
                      if (isLogin) {
                        await _authService.signIn(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                      } else {
                        if (nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Введите имя или никнейм')),
                          );
                          setDialogState(() => loading = false);
                          return;
                        }

                        await _authService.register(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          displayName: nameController.text.trim(),
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? 'Ошибка')),
                      );
                    } finally {
                      if (mounted) setDialogState(() => loading = false);
                    }
                  },
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(isLogin ? 'Войти' : 'Зарегистрироваться'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
