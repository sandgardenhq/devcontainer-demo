from pydantic import BaseModel
from typing import List, Optional

class ParagraphReference(BaseModel):
    string: str

class AnswerAnnotation(BaseModel):
    paragraph_reference: ParagraphReference

class Question(BaseModel):
    question_text: str
    paragraph_text: str
    annotation: Optional[AnswerAnnotation]
    question_id: str

class Answer(BaseModel):
    question: Question
    answer: str

class HandlerResponse(BaseModel):
    answers: List[Answer]

class Judgment(BaseModel):
    question_id: str
    correct: bool
    explanation: str