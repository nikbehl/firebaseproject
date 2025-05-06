import 'package:get/get.dart';

class ProfessionController extends GetxController {
  // Observable variables for professions
  final RxList<Map<String, dynamic>> professions = <Map<String, dynamic>>[].obs;
  final RxString selectedProfession = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfessions();
  }

  // Load available professions
  void loadProfessions() {
    professions.value = [
      {
        'title': 'Frontend Developer',
        'status': 'Available',
        'icon': 'web',
        'color': 'green',
      },
      {
        'title': 'Backend Developer',
        'status': 'Available',
        'icon': 'storage',
        'color': 'green',
      },
      {
        'title': 'UI/UX Designer',
        'status': 'Coming Soon',
        'icon': 'design_services',
        'color': 'orange',
      },
      {
        'title': 'Data Scientist',
        'status': 'Coming Soon',
        'icon': 'analytics',
        'color': 'orange',
      },
      {
        'title': 'Mobile Developer',
        'status': 'Coming Soon',
        'icon': 'phone_android',
        'color': 'orange',
      },
      {
        'title': 'DevOps Engineer',
        'status': 'Coming Soon',
        'icon': 'settings',
        'color': 'orange',
      },
    ];
  }

  // Set selected profession
  void setSelectedProfession(String profession) {
    selectedProfession.value = profession;
  }

  // Check if profession is available
  bool isProfessionAvailable(String profession) {
    final prof = professions.firstWhere((p) => p['title'] == profession,
        orElse: () => {'status': 'Not Found'});
    return prof['status'] == 'Available';
  }
}
