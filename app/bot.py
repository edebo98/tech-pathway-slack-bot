from app.knowledge import find_answer

FALLBACK_MESSAGE = (
    "I don't have an answer for that in my knowledge base. "
    "Please reach out to your tech lead for more information."
)


def handle_message(text: str) -> str:
    if not text:
        return FALLBACK_MESSAGE

    answer = find_answer(text)

    if answer:
        return answer

    return FALLBACK_MESSAGE