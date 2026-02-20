from app.ai.orchestrator import Orchestrator

orch = Orchestrator()

# Get first question
first = orch.get_first_question("stress")
print("FIRST QUESTION:")
print(first)
print("\n------------------\n")

# Simulate user answering first question
answer = "Often"
next_q = orch.get_next_question("stress", first["id"], answer)

print("NEXT QUESTION AFTER ANSWER =", answer)
print(next_q)

