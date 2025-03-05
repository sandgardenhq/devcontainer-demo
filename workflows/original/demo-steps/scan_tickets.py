from psycopg2.extras import RealDictCursor

def handler(input, sandgarden):
    conn = sandgarden.get_connector('tickets-postgres')

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("SELECT id FROM tickets")
        tickets = cur.fetchall()

    ticket_ids = [ticket['id'] for ticket in tickets]
    return {"ticket_id": ticket_ids}
