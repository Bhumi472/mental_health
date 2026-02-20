import re
from typing import Tuple, List

class ContentModerationService:
    
    PROFANITY_LIST = [
        'fuck', 'shit', 'bitch', 'ass', 'damn', 'hell', 'bastard', 'crap',
        'dick', 'pussy', 'cock', 'slut', 'whore', 'fag', 'nigger', 'retard',
    ]
    
    HATE_SPEECH_INDICATORS = [
        'kill yourself', 'kys', 'die', 'hate you', 'worthless', 'pathetic loser',
    ]
    
    SPAM_INDICATORS = [
        r'(http|https|www\.)\S+',
        r'\b[A-Z]{5,}\b',
        r'(.)\1{4,}',
    ]
    
    @staticmethod
    def detect_profanity(text: str) -> Tuple[bool, List[str]]:
        text_lower = text.lower()
        found_words = []
        
        for word in ContentModerationService.PROFANITY_LIST:
            pattern = r'\b' + re.escape(word) + r'\b'
            if re.search(pattern, text_lower):
                found_words.append(word)
        
        return len(found_words) > 0, found_words
    
    @staticmethod
    def detect_hate_speech(text: str) -> Tuple[bool, List[str]]:
        text_lower = text.lower()
        found_patterns = []
        
        for pattern in ContentModerationService.HATE_SPEECH_INDICATORS:
            if pattern.lower() in text_lower:
                found_patterns.append(pattern)
        
        return len(found_patterns) > 0, found_patterns
    
    @staticmethod
    def detect_spam(text: str) -> Tuple[bool, List[str]]:
        indicators_found = []
        
        for pattern in ContentModerationService.SPAM_INDICATORS:
            matches = re.findall(pattern, text)
            if matches:
                indicators_found.append(f"Pattern: {pattern}")
        
        words = text.split()
        if len(words) > 0:
            word_counts = {}
            for word in words:
                word_counts[word] = word_counts.get(word, 0) + 1
            max_repetition = max(word_counts.values())
            if max_repetition > 10:
                indicators_found.append("Excessive word repetition")
        
        return len(indicators_found) > 0, indicators_found
    
    @staticmethod
    def moderate_content(text: str, title: str = None) -> Tuple[bool, str, dict]:
        full_text = f"{title or ''} {text}".strip()
        
        has_profanity, profane_words = ContentModerationService.detect_profanity(full_text)
        has_hate_speech, hate_patterns = ContentModerationService.detect_hate_speech(full_text)
        is_spam, spam_indicators = ContentModerationService.detect_spam(full_text)
        
        details = {
            'profanity': {'detected': has_profanity, 'words': profane_words},
            'hate_speech': {'detected': has_hate_speech, 'patterns': hate_patterns},
            'spam': {'detected': is_spam, 'indicators': spam_indicators}
        }
        
        if has_hate_speech:
            return False, "Content contains hate speech or harmful language", details
        if has_profanity:
            return False, "Content contains inappropriate language", details
        if is_spam:
            return False, "Content appears to be spam", details
        if len(text.strip()) < 10:
            return False, "Content is too short (minimum 10 characters)", details
        if len(text) > 10000:
            return False, "Content is too long (maximum 10000 characters)", details
        
        return True, "", details
    
    @staticmethod
    def sanitize_content(text: str) -> str:
        text = re.sub(r'<[^>]+>', '', text)
        text = re.sub(r'\s+', ' ', text)
        return text.strip()