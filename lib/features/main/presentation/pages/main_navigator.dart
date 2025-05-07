import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neurodyx/core/constants/assets_path.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/home/presentation/pages/home_page.dart';
import 'package:neurodyx/features/profile/presentation/pages/profile_page.dart';
import 'package:neurodyx/features/scan/presentation/pages/scan_page.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/chat/presentation/pages/chat_page.dart';
import 'package:neurodyx/features/chat/presentation/pages/chat_history_page.dart';
import 'package:neurodyx/features/chat/presentation/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isNavigating = false;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    _pages = [
      const HomePage(),
      ScanPage(
        hideNavBarNotifier: scanProvider.hideNavBarNotifier,
        onClearMedia: () {
          setState(() {
            _selectedIndex = 1; // Switch to ScanPage immediately
          });
        },
      ),
      const ProfilePage(),
    ];
    debugPrint("MainNavigator initialized with $_pages");
    // Initialize ChatProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).initialize();
    });
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
    if (index == 1) {
      _showImageSourceDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showImageSourceDialog() {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Image Source',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Capture text from images or documents to help you read better',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 1; // Switch to ScanPage immediately
                  });
                  scanProvider.pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedIndex = 1; // Switch to ScanPage immediately
                  });
                  scanProvider.pickImage(context, ImageSource.camera);
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Future<void> _navigateToChatPage() async {
    if (_isNavigating) {
      debugPrint('Navigation already in progress, ignoring');
      return;
    }
    _isNavigating = true;
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initialize();
      final conversations = chatProvider.allConversations;
      debugPrint(
          'Navigating to chat, conversations count: ${conversations.length}');

      if (conversations.isEmpty) {
        await chatProvider.createNewConversation(title: 'New Conversation');
        debugPrint('Created new conversation for first-time chat access');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatPage(),
            settings: const RouteSettings(arguments: 'disable_hero'),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatHistoryPage(),
            settings: const RouteSettings(arguments: 'disable_hero'),
          ),
        );
      }
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("MainNavigator building with selected index: $_selectedIndex");

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const navBarHeight = 80.0;

    final bottomNavTheme = Theme.of(context).copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );

    return PopScope(
      canPop: false, // Prevent popping MainNavigator
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Always reset to HomePage on back press
        setState(() {
          _selectedIndex = 0;
        });
        debugPrint('Back button pressed, resetting to HomePage');
      },
      child: Consumer<ScanProvider>(
        builder: (context, scanProvider, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: scanProvider.hideNavBarNotifier,
                  builder: (context, hideNavBar, child) {
                    final showChatFab = !hideNavBar || _selectedIndex != 1;

                    if (!showChatFab) {
                      return const SizedBox.shrink();
                    }

                    final fabBottomPosition =
                        navBarHeight + bottomPadding + 20.0;

                    return Positioned(
                      bottom: fabBottomPosition,
                      right: 24,
                      child: HeroMode(
                        enabled: false,
                        child: FloatingActionButton(
                          onPressed: _navigateToChatPage,
                          backgroundColor: AppColors.white,
                          elevation: 6,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: SvgPicture.asset(
                            AssetPath.iconGemini,
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            bottomNavigationBar: ValueListenableBuilder<bool>(
              valueListenable: scanProvider.hideNavBarNotifier,
              builder: (context, hideNavBar, child) {
                if (hideNavBar && _selectedIndex == 1) {
                  return const SizedBox.shrink();
                }
                return Theme(
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
                );
              },
            ),
            floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: scanProvider.hideNavBarNotifier,
              builder: (context, hideNavBar, child) {
                if (hideNavBar && _selectedIndex == 1) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton(
                  onPressed: _showImageSourceDialog,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.white,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: Image.asset(
                    AssetPath.iconCamera,
                    width: 28,
                    height: 28,
                  ),
                );
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            extendBody: true,
          );
        },
      ),
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
