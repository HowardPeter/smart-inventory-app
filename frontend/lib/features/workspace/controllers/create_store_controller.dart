import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/exceptions/t_exceptions.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/features/workspace/provider/workspace_provider.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/state/services/store_service.dart';

class CreateStoreController extends GetxController {
  // --- CONTROLLERS ---
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final mapController = MapController();

  // --- STATES ---
  final isLoading = false.obs;
  final isLoadingAddress = false.obs;

  final selectedLocation = const LatLng(10.762622, 106.660172).obs;
  final addressPredictions = <dynamic>[].obs;

  final _dio = Dio();
  late final WorkspaceProvider _workspaceProvider;

  // GỌI STORE SERVICE ĐỂ LƯU DATA
  late final _storeService = Get.find<StoreService>();

  @override
  void onInit() {
    super.onInit();
    _workspaceProvider = WorkspaceProvider();
  }

  void _safeMoveMap(LatLng location) {
    try {
      mapController.move(location, 16.0);
    } catch (e) {
      debugPrint("Map not ready yet: $e");
    }
  }

  // --- 1. TÌM KIẾM ĐỊA CHỈ ---
  Future<void> searchAddress(String query) async {
    if (query.trim().length < 3) {
      addressPredictions.clear();
      return;
    }

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
          'countrycodes': 'vn',
        },
        options: Options(headers: {
          'User-Agent': 'StorixApp/1.0',
        }),
      );

      if (response.statusCode == 200) {
        addressPredictions.assignAll(response.data);
      }
    } catch (e) {
      debugPrint("Search Error: $e");
    }
  }

  // --- 2. CHỌN GỢI Ý ĐỊA CHỈ ---
  void onSuggestionSelected(dynamic place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final newLocation = LatLng(lat, lon);

    selectedLocation.value = newLocation;
    addressController.text = place['display_name'] ?? "";
    addressPredictions.clear();

    _safeMoveMap(newLocation);

    addressController.selection = TextSelection.fromPosition(
      TextPosition(offset: addressController.text.length),
    );
  }

  // --- 3. LẤY VỊ TRÍ GPS ---
  Future<void> getCurrentLocation() async {
    try {
      isLoadingAddress.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        TSnackbarsWidget.error(
            title: TTexts.gpsOffTitle.tr, message: TTexts.gpsOffMessage.tr);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final newPos = LatLng(position.latitude, position.longitude);
      selectedLocation.value = newPos;
      _safeMoveMap(newPos);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        addressController.text =
            "${p.street}, ${p.subAdministrativeArea}, ${p.administrativeArea}";
      }
    } catch (e) {
      debugPrint("GPS Error: $e");
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr, message: TTexts.locationErrorMessage.tr);
    } finally {
      isLoadingAddress.value = false;
    }
  }

  // --- 4. TẠO WORKSPACE MỚI ---
  void onTryCreateWorkspace() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr, message: TTexts.storeNameEmptyError.tr);
      return;
    }

    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.confirmCreateStoreTitle.tr,
        description: "${TTexts.confirmCreateStoreMessage.tr} '$name'?",
        icon: const Text('🤔', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.create.tr,
        onPrimaryPressed: () {
          Get.back();
          _executeCreate(name);
        },
        secondaryButtonText: TTexts.cancel.tr,
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  Future<void> _executeCreate(String name) async {
    try {
      isLoading.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.creatingWorkspace.tr);

      String currentTimezone = 'Asia/Ho_Chi_Minh';
      try {
        final dynamic tz = await FlutterTimezone.getLocalTimezone();
        currentTimezone = tz.toString();
      } catch (e) {
        debugPrint("Could not get timezone: $e");
      }

      final payload = {
        "name": name,
        "address": addressController.text.trim(),
        "latitude": selectedLocation.value.latitude,
        "longitude": selectedLocation.value.longitude,
        "timezone": currentTimezone,
      };

      // 1. NHẬN KẾT QUẢ TỪ API
      final createdStore = await _workspaceProvider.createStore(payload);

      // 2. NGAY LẬP TỨC LƯU STORE MỚI VÀO BỘ NHỚ
      await _storeService.saveSelectedStore(
          createdStore.storeId, createdStore.name, createdStore.role);

      FullScreenLoaderUtils.stopLoading();

      // 3. CHUYỂN SANG MÀN SUCCESS (Chỉ cần truyền name để hiển thị UI)
      Get.offNamed(AppRoutes.workspaceReady,
          arguments: {'storeName': createdStore.name});
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();

      final errorMap = TExceptions.getErrorMessage(e);
      TSnackbarsWidget.error(
          title: errorMap['title'] ?? TTexts.errorTitle.tr,
          message: errorMap['message'] ?? e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
