import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants.dart';
import '../../core/date_helpers.dart';
import '../../core/error_types.dart';
import '../../providers/app_providers.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isPermissionDenied = false;
  bool _isPermanentlyDenied = false;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.status;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _isPermanentlyDenied = true;
          _isPermissionDenied = true;
          _isCameraInitialized = false;
        });
      }
      return;
    }

    if (!status.isGranted) {
      final requestResult = await Permission.camera.request();
      if (!requestResult.isGranted) {
        if (mounted) {
          setState(() {
            _isPermissionDenied = true;
            _isPermanentlyDenied = requestResult.isPermanentlyDenied;
            _isCameraInitialized = false;
          });
        }
        return;
      }
    }

    // Permission is granted
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _isPermissionDenied = false;
            _isCameraInitialized = false;
          });
        }
        return;
      }

      final controller = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
        _isPermissionDenied = false;
        _isPermanentlyDenied = false;
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  Future<void> _captureFromCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final xfile = await _cameraController!.takePicture();
      final bytes = await xfile.readAsBytes();
      final base64Image = base64Encode(bytes);
      await _analyzeMeal(base64Image);
    } catch (e) {
      _showErrorDialog('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (xfile == null) return;

      final bytes = await xfile.readAsBytes();
      final base64Image = base64Encode(bytes);
      await _analyzeMeal(base64Image);
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeMeal(String imageBase64) async {
    setState(() => _isAnalyzing = true);
    try {
      final quota = await ref.read(scanRepositoryProvider).getQuota();
      if (quota.remaining <= 0) {
        throw ScanException(
          code: ScanErrorCode.limitReached,
          message: 'Daily scan limit reached. Your quota resets at midnight IST.',
        );
      }

      final mealType = DateHelpers.defaultMealType(DateTime.now());
      final estimator = ref.read(nutritionEstimatorProvider);

      final result = await estimator.estimate(
        imageBase64: imageBase64,
        mealType: mealType,
      );

      ref.read(scanQuotaNotifierProvider.notifier).refreshQuota();

      if (mounted) {
        context.push('/scan/result', extra: result);
      }
    } on ScanException catch (e) {
      if (mounted) {
        _showErrorDialog(e.userFacingMessage(), canRetry: true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Analysis failed: $e', canRetry: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showErrorDialog(String message, {bool canRetry = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        title: const Text('Scan Notice', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/manual-add');
            },
            child: const Text('Add manually'),
          ),
          if (canRetry)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
              child: const Text('Retry'),
            )
          else
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quotaAsync = ref.watch(scanQuotaNotifierProvider);
    final scansLeft = quotaAsync.value?.remaining ?? 7;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePadding,
            vertical: 16,
          ),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E281F) : const Color(0xFFE5EEDF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$scansLeft scans left today',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Viewfinder / Live Camera Preview
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1F1C) : const Color(0xFF1E221F),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera Preview or Fallback View
                      if (_isCameraInitialized && _cameraController != null)
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController!.value.previewSize?.height ?? 1,
                              height: _cameraController!.value.previewSize?.width ?? 1,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        )
                      else if (_isPermissionDenied)
                        _buildPermissionDeniedView(isDark)
                      else
                        _buildDefaultPlateIllustration(isDark),

                      // Corner Reticles
                      Positioned(
                        top: 24,
                        left: 24,
                        child: _buildCorner(isTop: true, isLeft: true, isDark: isDark),
                      ),
                      Positioned(
                        top: 24,
                        right: 24,
                        child: _buildCorner(isTop: true, isLeft: false, isDark: isDark),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 24,
                        child: _buildCorner(isTop: false, isLeft: true, isDark: isDark),
                      ),
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: _buildCorner(isTop: false, isLeft: false, isDark: isDark),
                      ),

                      // "Point at your food" chip
                      Positioned(
                        bottom: 28,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Point at your food',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      // Loading Overlay
                      if (_isAnalyzing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.7),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? AppColors.accentLime : AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Analyzing meal with AI...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Barcode / Photo Selector (Barcode marked for V2 as in spec)
              Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B1E1C) : const Color(0xFFE7ECE2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Barcode scanning is coming in V2! Photo mode active.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Barcode',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Photo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Guidance text
              Text(
                'Hold steady. We capture it automatically.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 14),

              // Shutter Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pick from Gallery
                  IconButton(
                    onPressed: _isAnalyzing ? null : _pickFromGallery,
                    icon: Icon(
                      Icons.photo_library_outlined,
                      size: 28,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                    tooltip: 'Choose from gallery',
                  ),
                  const SizedBox(width: 28),

                  // Shutter Button
                  GestureDetector(
                    onTap: _isAnalyzing
                        ? null
                        : (_isCameraInitialized ? _captureFromCamera : _pickFromGallery),
                    child: Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                          width: 3.5,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),

                  // Refresh camera permission / toggle
                  IconButton(
                    onPressed: () => _initCamera(),
                    icon: Icon(
                      Icons.flip_camera_ios_outlined,
                      size: 26,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                    tooltip: 'Refresh camera',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Add Manually Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/manual-add'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
                    ),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderSubtle,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Add manually',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 52,
            color: isDark ? AppColors.accentLime : AppColors.primaryGreen,
          ),
          const SizedBox(height: 16),
          const Text(
            'Camera Permission Required',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'CalCount needs camera access to photograph your meals for instant AI estimation. You can also pick photos from your gallery.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_isPermanentlyDenied) {
                openAppSettings();
              } else {
                _initCamera();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.accentLime : AppColors.primaryGreen,
              foregroundColor: isDark ? Colors.black : Colors.white,
              minimumSize: const Size(180, 44),
            ),
            child: Text(_isPermanentlyDenied ? 'Open Settings' : 'Enable Camera'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Pick from Gallery'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPlateIllustration(bool isDark) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2C322E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 35,
            left: 35,
            child: Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDE9343),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 35,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFBE7129),
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            child: Container(
              width: 85,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFF70983A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    required bool isTop,
    required bool isLeft,
    required bool isDark,
  }) {
    final color = isDark ? AppColors.accentLime : const Color(0xFF67B73F);
    return SizedBox(
      width: 38,
      height: 38,
      child: CustomPaint(
        painter: _CornerPainter(
          isTop: isTop,
          isLeft: isLeft,
          color: color,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 16);
      path.quadraticBezierTo(0, 0, 16, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width - 16, 0);
      path.quadraticBezierTo(size.width, 0, size.width, 16);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height - 16);
      path.quadraticBezierTo(0, size.height, 16, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width - 16, size.height);
      path.quadraticBezierTo(size.width, size.height, size.width, size.height - 16);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
