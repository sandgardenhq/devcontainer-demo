from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List
import json
import os

class Account(BaseModel):
    id: str
    name: str
    acv: int
    tier: str
    industry: str
    support_level: str
    critical_systems: List[str]
    region: str

class SentimentAnalysis(BaseModel):
    sentiment: str  # positive, negative, neutral
    confidence: float
    key_phrases: List[str]
    emotion_indicators: List[str]
    urgency_level: str  # high, medium, low
    satisfaction_indicators: List[str]

class Ticket(BaseModel):
    id: int
    email: str
    subject: str
    description: Optional[str] = None
    status: str
    priority: Optional[str] = None
    updated_at: str
    organization: Optional[str] = None
    organization_details: Optional[str] = None
    organization_notes: Optional[str] = None
    url: Optional[str] = None
    tags: List[str] = Field(default_factory=list)
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }
        
class TicketSentimentResponse(BaseModel):
    ticket: Ticket
    analysis: SentimentAnalysis
    account: Optional[Account] = None
    summary: str

class TicketInput(BaseModel):
    ticket: Ticket
    summary: str

def handler(input, sandgarden):
    """
    Analyze customer sentiment from support ticket content.

    This handler processes a support ticket to:
    1. Extract customer communication tone and emotion
    2. Identify key sentiment indicators
    3. Assess urgency and satisfaction levels
    4. Highlight important phrases indicating customer state

    Args:
        input: Dict containing ticket data and summary
        sandgarden: SandGarden context with connectors and prompts
        runtime_context: Runtime execution context

    Returns:
        Dict containing sentiment analysis results including:
        - Overall sentiment classification
        - Confidence score
        - Key emotional indicators
        - Urgency assessment
    """
    # Parse input
    ticket_data = TicketInput(**input)
    
    # get the current directory
    current_dir = os.path.dirname(os.path.abspath(__file__))    
    # Load accounts data
    with open(os.path.join(current_dir, 'accounts.json')) as f:
        accounts_data = json.load(f)
    
    # Find matching account
    account = None
    org_name = ticket_data.ticket.organization
    if org_name:
        account = next(
            (Account(**acc) for acc in accounts_data['accounts'] 
             if acc['name'] == org_name),
            None
        )
    
    # Get LLM client and prompt
    llm = sandgarden.get_connector('ticket-summarizer-model')
    prompt = sandgarden.get_prompt('analyze-sentiment')

    # Prepare content for analysis
    analysis_content = sandgarden.render_prompt(
        'enriched-text-summary', 
        {
            "ticket": ticket_data.ticket.__dict__, 
            "summary": ticket_data.summary, 
            "account": account.__dict__
        })
    
    # Get structured sentiment analysis from LLM
    sentiment_data = llm.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": prompt},
            {"role": "user", "content": analysis_content}
        ],
        response_format=SentimentAnalysis
    ).choices[0].message.parsed
    
    # Return validated response with JSON serialization
    return sandgarden.out(TicketSentimentResponse(
        ticket=ticket_data.ticket,
        analysis=sentiment_data,  # Already a SentimentAnalysis instance
        account=account,
        summary=ticket_data.summary
    ))
