import json
import os

BASE_DIR = os.path.dirname(__file__)
QUESTION_BANK_PATH = os.path.join(BASE_DIR, "question_bank")


class Orchestrator:

    def load_questions(self, test_type: str):
        file_path = os.path.join(QUESTION_BANK_PATH, f"{test_type}.json")

        with open(file_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        return data["questions"]

    def get_first_question(self, test_type: str):
        questions = self.load_questions(test_type)
        return questions[0]

    def get_next_question(self, test_type: str, current_id: str, answer: str):
        questions = self.load_questions(test_type)

        current_question = None
        for q in questions:
            if q["id"] == current_id:
                current_question = q
                break

        if not current_question:
            return None

        severity_value = current_question["severity_map"].get(answer)

        if severity_value is None:
            return None

        # Determine next level based on severity
        if severity_value <= 1:
            level = "low"
        elif severity_value == 2:
            level = "medium"
        else:
            level = "high"

        next_id = current_question["next"].get(level)

        if next_id == "END":
            return {"end": True}

        for q in questions:
            if q["id"] == next_id:
                return q

        return None

    def analyze_results(self, test_type: str, score: int, num_questions: int):
        """
        Calculates interpretation based on total score and number of questions.
        Normalizes score to handle dynamic question counts.
        """
        if num_questions == 0:
            return "Minimal"

        # Max average severity per question is usually around 4
        # We'll normalize the score to a 0-100 scale assuming max potential of 4 per question
        normalized_score = (score / (num_questions * 4)) * 100

        if normalized_score < 25:
            return "Minimal"
        elif normalized_score < 50:
            return "Mild"
        elif normalized_score < 75:
            return "Moderate"
        else:
            return "Severe"