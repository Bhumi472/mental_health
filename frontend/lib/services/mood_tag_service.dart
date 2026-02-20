import 'package:shared_preferences/shared_preferences.dart';

class MoodTagService {
  static const String _storageKeyPrefix = 'mood_tags_';

  // Default tags mapping
  static final Map<String, List<String>> _defaultTags = {
    'Angry': ['Humiliated', 'Frustrated', 'Aggressive', 'Mad', 'Bitter', 'Betrayed'],
    'Scared': ['Anxious', 'Weak', 'Rejected', 'Insecure', 'Threatened', 'Overwhelmed'],
    'Sad': ['Lonely', 'Vulnerable', 'Guilty', 'Hurt', 'Depressed', 'Mentally Exhausted', 'Ashamed'],
    'Neutral': ['Numb', 'Tired', 'Flat', 'Unmotivated', 'Uncertain', 'Foggy'],
    'Good': ['Content', 'Relaxed', 'Hopeful', 'Safe', 'Calm', 'Confident'],
    'Great': ['Joyful', 'Excited', 'Loved', 'Accomplished', 'Inspired', 'Blissful'],
  };

  Future<List<String>> getTagsForMood(String moodLabel) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> customTags = prefs.getStringList('$_storageKeyPrefix$moodLabel') ?? [];
    
    // Combine default and custom tags, removing duplicates
    final Set<String> allTags = {...?_defaultTags[moodLabel], ...customTags};
    return allTags.toList();
  }

  Future<void> addCustomTag(String moodLabel, String newTag) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = '$_storageKeyPrefix$moodLabel';
    final List<String> currentCustomTags = prefs.getStringList(key) ?? [];
    
    if (!currentCustomTags.contains(newTag) && !(_defaultTags[moodLabel]?.contains(newTag) ?? false)) {
      currentCustomTags.add(newTag);
      await prefs.setStringList(key, currentCustomTags);
    }
  }
}
