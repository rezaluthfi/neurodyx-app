import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  // List of pages to switch between
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      const HomePage(),
      const ProfilePage(),
      const SettingsPage(),
    ];
    debugPrint("MainNavigator initialized with $_pages");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint("MainNavigator dependencies changed");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("MainNavigator building with selected index: $_selectedIndex");

    // Define a theme for the bottomNavigationBar separately
    final bottomNavTheme = Theme.of(context).copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: bottomNavTheme,
        child: SizedBox(
          height: 72, // Explicitly set height
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: _buildNavItem(AssetPath.iconHome, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(AssetPath.iconProfile, 1),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: _buildNavItem(AssetPath.iconSettings, 2),
                label: 'Setting',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconPath, int index) {
    final bool isSelected = _selectedIndex == index;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isSelected)
          Positioned(
            top: 0,
            child: Container(
              height: 2,
              width: 64,
              color: AppColors.primary,
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading icon: $iconPath, Error: $error');
                  return Icon(
                    index == 0
                        ? Icons.home
                        : index == 1
                            ? Icons.person
                            : Icons.settings,
                    size: 24,
                    color: isSelected ? AppColors.primary : AppColors.grey,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
