import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/crm_provider.dart';
import 'theme/app_theme.dart';
import 'views/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EmlakCrmApp());
}

class EmlakCrmApp extends StatelessWidget {
  const EmlakCrmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CrmProvider()),
      ],
      child: MaterialApp(
        title: 'Emlak CRM Premium',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const MainNavigation(),
      ),
    );
  }
}
