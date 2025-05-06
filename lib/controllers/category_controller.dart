import 'package:get/get.dart';

class CategoryController extends GetxController {
  // Observable variables for categories
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = ''.obs;

  // Load categories based on profession
  void loadCategories(String profession) {
    if (profession == 'Frontend Developer') {
      categories.value = ['HTML', 'CSS', 'JavaScript', 'Frameworks', 'Tools'];
    } else if (profession == 'Backend Developer') {
      categories.value = ['Node.js', 'Python', 'Databases', 'Server', 'Tools'];
    } else {
      // Default empty list for unsupported professions
      categories.value = [];
    }
  }

  // Set selected category
  void setSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  // Clear selected category
  void clearSelectedCategory() {
    selectedCategory.value = '';
  }
}
