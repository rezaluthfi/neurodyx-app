import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../scan/presentation/page/scan_page.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      const HomePage(),
      const ScanPage(),
      const ProfilePage(),
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
        child: BottomAppBar(
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          color: AppColors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    assetPath: AssetPath.iconHome,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.person,
                    assetPath: AssetPath.iconProfileSettings,
                    label: 'Profile',
                    index: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(1),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.white,
          shape: const CircleBorder(),
          child: Image.asset(
            AssetPath.iconCamera,
            width: 32,
            height: 32,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String assetPath,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 24,
                height: 2,
                color: AppColors.primary,
              ),
            const SizedBox(height: 8),
            Image.asset(
              assetPath,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading icon: $assetPath, Error: $error');
                return Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.grey,
                );
              },
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
