import sandgarden_runtime
from psycopg2.extras import RealDictCursor
from pydantic import BaseModel

class EscalateCheckerOutput(BaseModel):
    escalate: bool

def handler(input, sandgarden):
    conn = sandgarden.get_connectors('tickets-postgres')
    openai = sandgarden.get_connectors('tickets-openai')
    
    ticket_id = input.get('ticket_id') or input.get('$.ticket_id')

    ticket, messages = get_ticket_history(conn, ticket_id)
    context = build_context(ticket, messages)
    response = run_ai(openai, context)
    result = response.choices[0].message.parsed

    return {"ticket_id": ticket_id, "escalate": result.escalate}

def system_prompt():
    return """
    You are an AI assistant. Analyze the following message history and determine if the customer's issue requires escalation to a manager.

    Criteria
    - The customer has to keep repeating their request
    - The customer is frustrated, angry, or hostile
    - The customer is asking for a manager or supervisor
    - The agent is not able to provide a solution
    - The agent is not being friendly, helpful, or empathetic

    If any of the above criteria are met, "escalate" should be true, otherwise it should be false.
    """

def get_ticket_history(conn, ticket_id):
    ticket = get_ticket(conn, ticket_id)
    messages = get_message_history(conn, ticket_id)
    return ticket, messages

def get_message_history(conn, ticket_id):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT * FROM messages WHERE ticket_id = %s ORDER BY id ASC", (ticket_id,))
        messages = cur.fetchall()
        return messages

def get_ticket(conn, ticket_id):
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT * FROM tickets WHERE id = %s", (ticket_id,))
        ticket = cur.fetchone()
        return ticket

def build_context(ticket, messages):
    str_buf = f"""
    Subject: {ticket['subject']}
    Status: {ticket['status']}
    Priority: {ticket['priority']}

    """

    for message in messages:
        role = "Customer" if message['sender_type'] == 'customer' else "Agent"
        str_buf += f"{role}: {message['content']}\n"

    return str_buf


def run_ai(openai, context):
    return openai.beta.chat.completions.parse(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": system_prompt()},
            {"role": "user", "content": context}
        ],
        response_format=EscalateCheckerOutput
    )
