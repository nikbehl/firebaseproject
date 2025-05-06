import 'package:get/get.dart';

class PromptController extends GetxController {
  // Observable variable for prompt
  final RxString prompt = ''.obs;

  // Set prompt text
  void setPrompt(String text) {
    prompt.value = text;
  }

  // Clear prompt
  void clearPrompt() {
    prompt.value = '';
  }

  // Validate prompt (can be extended based on requirements)
  bool isPromptValid() {
    return prompt.value.trim().isNotEmpty;
  }
}
