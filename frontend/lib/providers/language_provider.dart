import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'English';

  String get currentLanguage => _currentLanguage;

  final Map<String, Map<String, String>> _localizedStrings = {
    'English': {
      'welcome': 'Welcome to MindfulCare',
      'tagline': 'Your personalized mental health companion',
      'continue': 'Continue',
      'sign_up': 'Sign Up',
      'step': 'Step',
      'of': 'of',
      'next': 'Next',
      'create_account': 'Create Account',
      'user_type_title': 'Choose your account type',
      'org': 'Organization',
      'fam': 'Family',
      'ind': 'Individual',
      'age_group_title': "What's your age group?",
      'language_title': 'Choose your preferred language',
      'profile_title': 'Complete your profile',
      'landing2_title': 'Track Your Mood',
      'landing2_sub': 'Monitor your emotional well-being daily with ease',
      'landing3_title': 'Professional Support',
      'landing3_sub': 'Connect with experts and helpful resources anytime',
    },
    'हिन्दी': {
      'welcome': 'माइंडफुलकेयर में स्वागत है',
      'tagline': 'आपका व्यक्तिगत मानसिक स्वास्थ्य साथी',
      'continue': 'आगे बढ़ें',
      'sign_up': 'साइन अप करें',
      'step': 'चरण',
      'of': 'का',
      'next': 'अगला',
      'create_account': 'खाता बनाएं',
      'user_type_title': 'अपने खाते का प्रकार चुनें',
      'org': 'संगठन',
      'fam': 'परिवार',
      'ind': 'व्यक्तिगत',
      'age_group_title': "आपका आयु वर्ग क्या है?",
      'language_title': 'अपनी पसंदीदा भाषा चुनें',
      'profile_title': 'अपनी प्रोफ़ाइल पूरी करें',
      'landing2_title': 'अपने मूड को ट्रैक करें',
      'landing2_sub': 'आसानी से अपने भावनात्मक स्वास्थ्य की निगरानी करें',
      'landing3_title': 'पेशेवर समर्थन',
      'landing3_sub': 'किसी भी समय विशेषज्ञों और संसाधनों से जुड़ें',
    },
    'मराठी': {
      'welcome': 'माइंडफुलकेअरमध्ये स्वागत आहे',
      'tagline': 'तुमचा वैयक्तिक मानसिक आरोग्य सोबती',
      'continue': 'पुढे चला',
      'sign_up': 'साइन अप करा',
      'step': 'पायरी',
      'of': 'पैकी',
      'next': 'पुढील',
      'create_account': 'खाते तयार करा',
      'user_type_title': 'तुमच्या खात्याचा प्रकार निवडा',
      'org': 'संस्था',
      'fam': 'कुटुंब',
      'ind': 'वैयक्तिक',
      'age_group_title': "तुमचा वयोगट काय आहे?",
      'language_title': 'तुमची पसंतीचे भाषा निवडा',
      'profile_title': 'तुमची प्रोफाइल पूर्ण करा',
      'landing2_title': 'तुमचा मूड ट्रॅक करा',
      'landing2_sub': 'दररोज आपल्या भावनिक स्वास्थ्यावर देखरेख करा',
      'landing3_title': 'व्यावसायिक समर्थन',
      'landing3_sub': 'तज्ज्ञ आणि संसाधनांशी कधीही जोडा',
    },
  };

  void setLanguage(String lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? _localizedStrings['English']?[key] ?? key;
  }
}
