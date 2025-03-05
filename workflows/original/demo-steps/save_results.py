from psycopg2.extras import RealDictCursor

def handler(input, sandgarden):
    conn = sandgarden.get_connector('tickets-postgres')

    main_key = list(input.keys())[0]
    results = input[main_key]
    ticket_ids = []

    for result in results:
        ticket_id = result['ticket_id']
        escalate = result['escalate']
        update_ticket(conn, ticket_id, escalate)
        ticket_ids.append(ticket_id)

    return {"ticket_ids": ticket_ids}

def update_ticket(conn, ticket_id, escalate):
    with conn.cursor() as cur:
        cur.execute("UPDATE tickets SET needs_escalation = %s WHERE id = %s", (escalate, ticket_id))
        conn.commit()
