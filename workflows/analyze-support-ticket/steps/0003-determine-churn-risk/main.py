from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List, Dict
    
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
    
class ChurnRiskFactors(BaseModel):
    sentiment_indicators: List[str]
    technical_factors: List[str]
    account_factors: List[str]
    historical_factors: List[str]

class ChurnRiskAssessment(BaseModel):
    risk_level: str  # high, medium, low
    confidence: float
    risk_factors: ChurnRiskFactors
    recommendations: List[str]
    priority_score: int  # 1-100

class ChurnRiskResponse(BaseModel):
    ticket: Ticket
    summary: str
    sentiment: SentimentAnalysis
    account: Optional[Account] = None
    risk_assessment: ChurnRiskAssessment

def handler(input, sandgarden):
    """
    Assess the risk of customer churn based on ticket content and sentiment.

    This handler analyzes multiple factors to determine churn risk:
    1. Current ticket severity and sentiment
    2. Account characteristics (size, tier, history)
    3. Technical impact and affected systems
    4. Historical patterns and satisfaction indicators

    Args:
        input: Dict containing ticket, summary, sentiment analysis, and account data
        sandgarden: SandGarden context with connectors and prompts

    Returns:
        Dict containing all previous analysis plus:
        - Churn risk assessment
        - Contributing factors
        - Recommendations
    """
    # Parse input
    ticket_data = TicketSentimentResponse(**input)
    
    # Get LLM client and prompt
    llm = sandgarden.get_connector('ticket-summarizer-model')
    prompt = sandgarden.get_prompt('assess-churn-risk')
    
    # Prepare content for analysis
    analysis_content = sandgarden.render_prompt(
        'churn-analysis-data', 
        {
            "ticket": ticket_data.ticket.__dict__, 
            "summary": ticket_data.summary, 
            "account": ticket_data.account.__dict__,
            "analysis": ticket_data.analysis.__dict__
        })
    
    # Get structured churn risk assessment from LLM
    risk_assessment = llm.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": prompt},
            {"role": "user", "content": analysis_content}
        ],
        response_format=ChurnRiskAssessment
    ).choices[0].message.parsed
    
    # Return all data plus risk assessment
    return sandgarden.out(ChurnRiskResponse(
        ticket=ticket_data.ticket,
        summary=ticket_data.summary,
        sentiment=ticket_data.analysis,
        account=ticket_data.account,
        risk_assessment=risk_assessment
    ))
