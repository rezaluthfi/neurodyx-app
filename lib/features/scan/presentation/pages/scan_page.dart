import 'package:flutter/material.dart';
import 'package:neurodyx/core/constants/app_colors.dart';
import 'package:neurodyx/features/scan/presentation/providers/scan_provider.dart';
import 'package:neurodyx/features/scan/presentation/widgets/scan_initial_ui.dart';
import 'package:neurodyx/features/scan/presentation/widgets/scan_results_ui.dart';
import 'package:provider/provider.dart';
import '../widgets/scan_info_bar.dart';
import '../widgets/text_customization_settings.dart';

class ScanPage extends StatefulWidget {
  final ValueNotifier<bool> hideNavBarNotifier;
  final VoidCallback? onClearMedia;

  const ScanPage({
    super.key,
    required this.hideNavBarNotifier,
    this.onClearMedia,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    debugPrint('ScanPage initState');
    _scrollController.addListener(() {
      debugPrint('Scroll position: ${_scrollController.position.pixels}');
    });
  }

  @override
  void dispose() {
    debugPrint('ScanPage dispose');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ScanPage build');
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        debugPrint(
            'Consumer rebuild, isProcessing: ${provider.isProcessing}, selectedMedia: ${provider.selectedMedia != null}');
        return Scaffold(
          backgroundColor: AppColors.offWhite,
          appBar: provider.selectedMedia != null
              ? AppBar(
                  backgroundColor: AppColors.offWhite,
                  elevation: 0,
                  automaticallyImplyLeading: false, // Prevent back button
                  title: const Text(
                    'Scan Result',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.primary),
                      onPressed: () {
                        provider.clearMedia();
                        widget.onClearMedia?.call();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : AppBar(
                  backgroundColor: AppColors.offWhite,
                  elevation: 0,
                  automaticallyImplyLeading: false, // Prevent back button
                  title: const Text(
                    'Scan Text',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          body: SafeArea(
            child: GlowingOverscrollIndicator(
              showLeading: false,
              showTrailing: false,
              axisDirection: AxisDirection.down,
              color: Colors.transparent,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    if (provider.selectedMedia == null) const ScanInitialUI(),
                    if (provider.selectedMedia != null)
                      ScanResultsUI(
                        onCustomizePressed: () =>
                            showTextCustomizationSettings(context),
                      ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar:
              provider.selectedMedia != null ? const ScanInfoBar() : null,
        );
      },
    );
  }
}
