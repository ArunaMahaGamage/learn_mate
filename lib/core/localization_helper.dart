
import 'package:flutter/material.dart';

class LocalizationHelper {

  static Locale getLocaleFromLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'தமிழ்':
        return const Locale('ta', 'IN');
      case 'සිංහල':
        return const Locale('si', 'LK');
      case 'english':
      default:
        return const Locale('en', 'US');
    }
  }


  static Map<String, dynamic> getLocalizedStrings(String language) {
    switch (language.toLowerCase()) {
      case 'தமிழ்':
        return _tamilStrings;
      case 'සිංහල':
        return _sinhalaStrings;
      case 'english':
      default:
        return _englishStrings;
    }
  }
}

final _englishStrings = {
  'app_name': 'LearnMate',
  'home': 'Home',
  'profile': 'Profile',
  'settings': 'Settings',
  'logout': 'Logout',
  'language': 'Language',
  'theme': 'Theme',
  'notifications': 'Notifications',
  'edit_profile': 'Edit Profile',
  'save': 'Save',
  'cancel': 'Cancel',
  'hello': 'Hello',
  'welcome': 'Welcome to LearnMate',
  'select_language': 'Select Language',
  'select_theme': 'Select Theme',
  'light': 'Light',
  'dark': 'Dark',
  'system': 'System',
  'login': 'Login',
  'signup': 'Sign Up',
  'planner': 'Study Planner',
  'forum': 'Community Q&A',
  'quiz': 'Quiz',
  'flashcards': 'Flashcards',
  'resources': 'Resources',
  'version': 'Version',
  'terms': 'Terms of Service',
  'take_photo': 'Take Photo',
  'choose_gallery': 'Choose from Gallery',
  'pending_tasks':'Pending Tasks',
  'no_pending_tasks': 'You have no pending tasks! Great job.',
  'completed':'Completed',
  'no_completed_tasks': 'No completed tasks yet.',
  'add_new_card': 'Add New Card',
  'no_flashcards_found': 'No flashcards found.',
  'start_adding_cards_for_your_exams': 'Start adding cards for your exams!',
  'ai_assistant': 'AI Assistant',
  'you_are_currently_offline': 'You are currently offline',
  'ask_me_anything_about_your_studies': 'Ask me anything about your studies!',
  'try_explain_newton_third_law': 'Try: "Explain Newton\'s Third Law"',
  'type_your_question': 'Type your question...',
  'app_theme': 'App Theme',
  'general_preferences': 'General Preferences',
  'about': 'About',
  'delete': 'Delete',
  'title': 'Title',
  'description': 'Description',
  'tags': 'Tags',
  'new_flashcard': 'New Flashcard',
  'front_question': 'Front (Question)',
  'back_answer': 'Back (Answer)',
  'display_name': 'Display Name',
  'enter_your_name': 'Enter your name',
  'select_image_source': 'Select Image Source',
};

final _tamilStrings = {
  'app_name': 'கற்றுக்கொள்ளுங்கள்',
  'home': 'முகப்பு',
  'profile': 'சுயவிவரம்',
  'settings': 'அமைப்புகள்',
  'logout': 'வெளியேறு',
  'language': 'மொழி',
  'theme': 'தீம்',
  'notifications': 'அறிவிப்புகள்',
  'edit_profile': 'சுயவிவரத்தை திருத்து',
  'save': 'சேமிக்க',
  'cancel': 'ரத்துசெய்',
  'hello': 'வணக்கம்',
  'welcome': 'LearnMate க்கு வரவேற்கிறோம்',
  'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
  'select_theme': 'தீமைத் தேர்ந்தெடுக்கவும்',
  'light': 'ஒளி',
  'dark': 'இருட்டு',
  'system': 'கணினி',
  'login': 'உள்நுழைக',
  'signup': 'பதிவுசெய்க',
  'planner': 'கற்றுக்கொள்ளும் திட்டமிடல்',
  'forum': 'சமூக கேள்வி ও பதில்',
  'quiz': 'விரைப்பரீட்சை',
  'flashcards': 'ஃப்ளாஷ்கார்டு',
  'resources': 'வளங்கள்',
  'version': 'பதிப்பு',
  'terms': 'சேவை விதிமுறைகள்',
  'take_photo': 'புகைப்படம் எடுக்கவும்',
  'choose_gallery': 'கேலரியிலிருந்து தேர்ந்தெடுக்கவும்',
  'pending_tasks':'நிலுவையில் உள்ள பணிகள்',
  'no_pending_tasks': 'நீங்கள் எந்த நிலுவையில் உள்ள பணிகளும் இல்லை! நல்ல வேலை.',
  'completed':'முடிந்தவை',
  'no_completed_tasks': 'இன்னும் முடிந்த பணிகள் இல்லை.',
  'add_new_card': 'புதிய அட்டை சேர்க்கவும்',
  'no_flashcards_found': 'ஃப்ளாஷ்கார்டுகள் காணப்படவில்லை.',
  'start_adding_cards_for_your_exams': 'உங்கள் பரீட்சைகளுக்காக அட்டைகளைச் சேர்க்கத் தொடங்குங்கள்!',
  'ai_assistant': 'ஏ.ஐ உதவியாளர்',
  'you_are_currently_offline': 'நீங்கள் தற்போது ஆஃப்லைனில் இருக்கிறீர்கள்',
  'ask_me_anything_about_your_studies': 'உங்கள் படிப்புகள் பற்றி என்னிடம் எதையும் கேளுங்கள்!',
  'try_explain_newton_third_law': 'முயற்சி: "நியூட்டனின் மூன்றாவது சட்டத்தை விளக்கவும்"',
  'type_your_question': 'உங்கள் கேள்வியை தட்டச்சு செய்யவும்...',
  'app_theme': 'யாப்பு தீம்',
  'general_preferences': 'பொது விருப்பங்கள்',
  'about': 'எங்களைப் பற்றி',
  'delete': 'அழிக்கவும்',
  'title': 'தலைப்பு',
  'description': 'விளக்கம்',
  'tags': 'குறிச்சொற்கள்',
  'new_flashcard': 'புதிய அட்டை',
  'front_question': 'முன்னணி (கேள்வி)',
  'back_answer': 'பின்னணி (பதில்)',
  'display_name': 'காட்சி பெயர்',
  'enter_your_name': 'உங்கள் பெயரை உள்ளிடவும்',
  'select_image_source': 'பட மூலத்தைத் தேர்ந்தெடுக்கவும்',
};

final _sinhalaStrings = {
  'app_name': 'LearnMate',
  'home': 'උපකරණ පුවරුව',
  'profile': 'පැතිකඩ',
  'settings': 'සැකසුම්',
  'logout': 'ඉවත් වන්න',
  'language': 'භාෂාව',
  'theme': 'තේමාව',
  'notifications': 'දැනුම්දීම්',
  'edit_profile': 'පැතිකඩ සංස්කරණය කරන්න',
  'save': 'සුරකින්න',
  'cancel': 'අවලංගු කරන්න',
  'hello': 'ආයුබෝවන්',
  'welcome': 'LearnMate වෙත සාදරයෙන් පිළිගනිමු',
  'select_language': 'භාෂාව තෝරන්න',
  'select_theme': 'තේමාව තෝරන්න',
  'light': 'ආලෝකය',
  'dark': 'අඳුරු',
  'system': 'පද්ධතිය',
  'login': 'පිවිසෙන්න',
  'signup': 'ලියාපදිංචි වන්න',
  'planner': 'අධ්‍යයන සැලසුම්',
  'forum': 'සංසදය',
  'quiz': 'ප්‍රශ්නාවලිය',
  'flashcards': 'ෆ්ලැෂ් කාඩ්',
  'resources': 'සම්පත්',
  'version': 'සංස්කරණය',
  'terms': 'සේවා කොන්දේසි',
  'take_photo': 'ඡායාරූපය ගන්න',
  'choose_gallery': 'ගැලරි තෝරන්න',
  'pending_tasks':'පොරොත්තු කාර්යයන්',
  'no_pending_tasks': 'ඔබට පොරොත්තු කාර්යයන් නොමැත!',
  'completed':'සම්පූර්ණයි',
  'no_completed_tasks': 'තවමත් සම්පූර්ණ කළ කාර්යයන් නොමැත.',
  'add_new_card': 'නව කාඩ්පතක් එක් කරන්න',
  'no_flashcards_found': 'ෆ්ලැෂ් කාඩ් නොපැවතියි.',
  'start_adding_cards_for_your_exams': 'ඔබේ විභාග සඳහා කාඩ්පත් එක් කිරීමට ආරම්භ කරන්න!',
  'ai_assistant': 'AI සහකරු',
  'you_are_currently_offline': 'ඔබ දැනටමත් ඔෆ්ලයින් වෙයි',
  'ask_me_anything_about_your_studies': 'ඔබේ අධ්‍යයන පිළිබඳ මට කිසිවක් අසන්න!',
  'try_explain_newton_third_law': 'පැය: "නියුටන්ගේ තෙවැනි නීතිය විස්තර කරන්න"',
  'type_your_question': 'ඔබේ ප්‍රශ්නය ටයිප් කරන්න...',
  'app_theme': 'යෙදුම් තේමාව',
  'general_preferences': 'පොදු මනාප',
  'about': 'අපි ගැන',
  'delete': 'මකා දමන්න',
  'title': 'මාතෘකාව',
  'description': 'විස්තරය',
  'tags': 'ටැග්ස්',
  'new_flashcard': 'නව ෆ්ලැෂ් කාඩ්පත',
  'front_question': 'ඉදිරිපස (ප්‍රශ්නය)', 
  'back_answer': 'පසුපස (පිළිතුර)',
  'display_name': 'ප්‍රදර්ශන නාමය',
  'enter_your_name': 'ඔබේ නම ඇතුළත් කරන්න',
  'select_image_source': 'පින්තූර මූලාශ්‍රය තෝරන්න',
};

