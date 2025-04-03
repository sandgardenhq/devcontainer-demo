import sandgarden_runtime
from psycopg2.extras import RealDictCursor
from pydantic import BaseModel

class EscalateCheckerOutput(BaseModel):
    escalate: bool

def handler(input, sandgarden):
    conn = sandgarden.get_connector('tickets-postgres')
    openai = sandgarden.get_connector('tickets-openai')
    prompt = sandgarden.prompts['escalate']
    
    ticket_id = input.get('ticket_id') or input.get('$.ticket_id')

    ticket, messages = get_ticket_history(conn, ticket_id)
    context = build_context(ticket, messages)
    response = run_ai(openai, context, prompt)
    result = response.choices[0].message.parsed

    return {"ticket_id": ticket_id, "escalate": result.escalate}


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


def run_ai(openai, context, prompt):
    return openai.beta.chat.completions.parse(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": prompt},
            {"role": "user", "content": context}
        ],
        response_format=EscalateCheckerOutput
    )