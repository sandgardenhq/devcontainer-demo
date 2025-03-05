from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List, Dict, Any

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
    
class TicketSummaryResponse(BaseModel):
    ticket: Ticket
    summary: str
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

def handler(input, sandgarden):
    """
    Analyze a support ticket and generate an AI-powered summary of its content.

    This handler processes a Zendesk support ticket by:
    1. Validating the input ticket data
    2. Extracting relevant content for analysis
    3. Using an LLM to generate a structured summary
    4. Assessing the ticket's severity and impact

    Args:
        input: Dict containing Zendesk ticket data
        sandgarden: SandGarden context with connectors and prompts
        runtime_context: Runtime execution context

    Returns:
        Dict containing:
        - ticket: The original ticket data
        - summary: Structured analysis including technical summary and severity assessment
    """
    # Parse input
    ticket = Ticket(**input)
    # Return validated response with JSON serialization
    # Get LLM client and prompt
    llm = sandgarden.get_connector('ticket-summarizer-model')
    prompt = sandgarden.get_prompt('summarize-ticket')
    
    # Prepare ticket content for summarization
    ticket_content = f"""
Ticket ID: {ticket.id}
Subject: {ticket.subject}
Status: {ticket.status}
Priority: {ticket.priority or 'Not set'}
Description: {ticket.description or 'No description provided'}

Customer Details:
- Email: {ticket.email}
- Organization: {ticket.organization or 'Not specified'}
- Organization Details: {ticket.organization_details or 'Not specified'}
- Organization Notes: {ticket.organization_notes or 'None'}

Metadata:
- URL: {ticket.url or 'Not available'}
- Tags: {', '.join(ticket.tags) if ticket.tags else 'None'}
- Last Updated: {ticket.updated_at}
"""
    
    # Get summary from LLM
    summary = llm.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": prompt},
            {"role": "user", "content": ticket_content}
        ]
    ).choices[0].message.content
        
    # Return validated response with JSON serialization
    return sandgarden.out(TicketSummaryResponse(
        ticket=ticket,
        summary=summary
    ))
