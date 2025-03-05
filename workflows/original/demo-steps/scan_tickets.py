import sandgarden_runtime
from psycopg2.extras import RealDictCursor

def handler(input, sandgarden, context):
    sandgarden_runtime.initialize_connectors(['tickets-postgres'], sandgarden)
    conn = sandgarden.connectors['tickets-postgres']

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT id FROM tickets")
        tickets = cur.fetchall()

    ticket_ids = [ticket['id'] for ticket in tickets]
    return {"ticket_id": ticket_ids}
