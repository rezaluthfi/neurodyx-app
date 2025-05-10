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
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigator extends StatefulWidget {
  final int initialIndex;

  const MainNavigator({
    super.key,
    this.initialIndex = 0, // Default to HomePage
  });

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with WidgetsBindingObserver {
  late int _selectedIndex;
  bool _isNavigating = false;
  late final List<Widget> _pages;

  // Variables for FAB positioning
  double _fabX = 0.0;
  double _fabY = 0.0;
  bool _fabPositionLoaded = false;
  bool _useCustomPosition = false;

  // Constants for FAB positioning
  final double _fabSize = 56.0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Initialize with the provided index
    WidgetsBinding.instance.addObserver(this);
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    _pages = [
      const HomePage(),
      ScanPage(
        hideNavBarNotifier: scanProvider.hideNavBarNotifier,
        onClearMedia: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
      const ProfilePage(),
    ];

    // Initialize ChatProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).initialize();
      _loadFabPosition();
    });
  }

  // Load saved FAB position from SharedPreferences
  Future<void> _loadFabPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        // Check if custom position is saved
        _useCustomPosition =
            prefs.getBool('use_custom_chat_fab_position') ?? false;

        if (_useCustomPosition) {
          _fabX = prefs.getDouble('chat_fab_x') ?? 0.0;
          _fabY = prefs.getDouble('chat_fab_y') ?? 0.0;
        }
        _fabPositionLoaded = true;
      });
      debugPrint(
          'Loaded FAB position: ($_fabX, $_fabY), useCustom: $_useCustomPosition');
    } catch (e) {
      debugPrint('Error loading FAB position: $e');
      setState(() {
        _fabPositionLoaded = true;
      });
    }
  }

  // Save FAB position to SharedPreferences
  Future<void> _saveFabPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_custom_chat_fab_position', true);
      await prefs.setDouble('chat_fab_x', _fabX);
      await prefs.setDouble('chat_fab_y', _fabY);
      debugPrint('Saved FAB position: ($_fabX, $_fabY)');
    } catch (e) {
      debugPrint('Error saving FAB position: $e');
    }
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

  void _navigateToChatPage() async {
    if (_isNavigating) {
      debugPrint('Navigation already in progress, ignoring');
      return;
    }
    _isNavigating = true;
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initialize();
      final conversations = chatProvider.allConversations;

      // Store current tab index for consistent back navigation
      final currentTabIndex = _selectedIndex;
      debugPrint(
          'Navigating to chat from tab: $currentTabIndex, conversations count: ${conversations.length}');

      if (conversations.isEmpty) {
        await chatProvider.createNewConversation(title: 'New Conversation');
        debugPrint('Created new conversation for first-time chat access');

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChatPage(),
              settings: RouteSettings(arguments: {
                'from': 'main',
                'sourceTabIndex': currentTabIndex,
              }),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatHistoryPage(
                sourceTabIndex: currentTabIndex,
              ),
            ),
          );
        }
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
    final screenSize = MediaQuery.of(context).size;

    final bottomNavTheme = Theme.of(context).copyWith(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );

    return PopScope(
      canPop: false, // Prevent popping MainNavigator
      onPopInvoked: (didPop) {
        if (didPop) return;
        // If we're not already on the Home tab, navigate to it
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          debugPrint(
              'MainNavigator back button pressed, switching to HomePage');
        }
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
                    // Show chat FAB only on HomePage and when nav bar is not hidden
                    final showChatFab = _selectedIndex == 0 && !hideNavBar;

                    if (!showChatFab || !_fabPositionLoaded) {
                      return const SizedBox.shrink();
                    }

                    // Default positioning (right bottom above nav bar)
                    final fabBottomMargin = navBarHeight + bottomPadding + 20.0;

                    if (_useCustomPosition) {
                      // Use custom position if set
                      return Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                        child: Stack(
                          children: [
                            Positioned(
                              left: _fabX - _fabSize / 2,
                              top: _fabY - _fabSize / 2,
                              child: _buildDraggableChatFab(
                                  screenSize, navBarHeight, bottomPadding),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Use original fixed position from first code version
                      return Positioned(
                        bottom: fabBottomMargin,
                        right: 24,
                        child: HeroMode(
                          enabled: false,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              // Start using custom position when user drags
                              final newX = screenSize.width -
                                  24 -
                                  _fabSize / 2 +
                                  details.delta.dx;
                              final newY = screenSize.height -
                                  fabBottomMargin -
                                  _fabSize / 2 +
                                  details.delta.dy;

                              setState(() {
                                _useCustomPosition = true;
                                _fabX = newX;
                                _fabY = newY;
                              });
                            },
                            onPanEnd: (details) {
                              _saveFabPosition();
                            },
                            child: FloatingActionButton(
                              onPressed: _navigateToChatPage,
                              backgroundColor: AppColors.white,
                              elevation: 6,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              child: SvgPicture.asset(
                                AssetPath.iconGemini,
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
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

  Widget _buildDraggableChatFab(
      Size screenSize, double navBarHeight, double bottomPadding) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _fabX += details.delta.dx;
          _fabY += details.delta.dy;

          // Add bounds to prevent FAB from going off-screen
          _fabX = _fabX.clamp(_fabSize / 2, screenSize.width - _fabSize / 2);

          // Keep above navbar
          final minY = _fabSize / 2 + MediaQuery.of(context).padding.top;
          final maxY =
              screenSize.height - (navBarHeight + bottomPadding) - _fabSize / 2;
          _fabY = _fabY.clamp(minY, maxY);
        });
      },
      onPanEnd: (details) {
        _saveFabPosition();
      },
      child: HeroMode(
        enabled: false,
        child: Material(
          elevation: 6,
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _navigateToChatPage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: _fabSize,
              height: _fabSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AssetPath.iconGemini,
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ),
        ),
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
