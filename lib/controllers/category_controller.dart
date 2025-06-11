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
    } else if (profession == 'UI/UX Designer') {
      categories.value = [
        'Design Principles',
        'User Research',
        'Wireframing',
        'Prototyping',
        'Design Tools',
        'Usability Testing'
      ];
    } else if (profession == 'Data Scientist') {
      categories.value = [
        'Python for Data Science',
        'Machine Learning',
        'Statistics',
        'Data Visualization',
        'Data Analysis',
        'Big Data Tools'
      ];
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

  // Get category description for better UX
  String getCategoryDescription(String profession, String category) {
    final descriptions = {
      'Frontend Developer': {
        'HTML': 'Structure and markup of web pages',
        'CSS': 'Styling and layout of web interfaces',
        'JavaScript': 'Interactive functionality and client-side logic',
        'Frameworks': 'React, Vue, Angular and other frontend frameworks',
        'Tools': 'Build tools, bundlers, and development utilities'
      },
      'Backend Developer': {
        'Node.js': 'Server-side JavaScript development',
        'Python': 'Backend development with Python frameworks',
        'Databases': 'SQL and NoSQL database management',
        'Server': 'Server configuration and deployment',
        'Tools': 'Backend development tools and utilities'
      },
      'UI/UX Designer': {
        'Design Principles': 'Fundamental design concepts and theory',
        'User Research': 'Understanding user needs and behaviors',
        'Wireframing': 'Creating structural blueprints for interfaces',
        'Prototyping': 'Building interactive design mockups',
        'Design Tools': 'Figma, Sketch, Adobe XD and other design software',
        'Usability Testing': 'Testing and validating design decisions'
      },
      'Data Scientist': {
        'Python for Data Science':
            'Python libraries like Pandas, NumPy, Scikit-learn',
        'Machine Learning': 'ML algorithms, model training and evaluation',
        'Statistics': 'Statistical analysis and hypothesis testing',
        'Data Visualization':
            'Creating charts and graphs with tools like Matplotlib',
        'Data Analysis': 'Exploratory data analysis and insights extraction',
        'Big Data Tools': 'Spark, Hadoop, and distributed computing'
      }
    };

    return descriptions[profession]?[category] ?? 'Learn more about this topic';
  }

  // Get icon for category (for better visual representation)
  String getCategoryIcon(String profession, String category) {
    final icons = {
      'Frontend Developer': {
        'HTML': 'language',
        'CSS': 'palette',
        'JavaScript': 'code',
        'Frameworks': 'view_module',
        'Tools': 'build'
      },
      'Backend Developer': {
        'Node.js': 'dns',
        'Python': 'smart_toy',
        'Databases': 'storage',
        'Server': 'cloud',
        'Tools': 'settings'
      },
      'UI/UX Designer': {
        'Design Principles': 'design_services',
        'User Research': 'people',
        'Wireframing': 'crop_landscape',
        'Prototyping': 'view_quilt',
        'Design Tools': 'brush',
        'Usability Testing': 'fact_check'
      },
      'Data Scientist': {
        'Python for Data Science': 'code',
        'Machine Learning': 'psychology',
        'Statistics': 'analytics',
        'Data Visualization': 'bar_chart',
        'Data Analysis': 'insights',
        'Big Data Tools': 'cloud_queue'
      }
    };

    return icons[profession]?[category] ?? 'help_outline';
  }
}
