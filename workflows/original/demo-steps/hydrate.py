from psycopg2.extras import RealDictCursor

def handler(input, sandgarden):
    conn = sandgarden.get_connector('tickets-postgres')
    print(f"Hydrating {input}")

    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        # Load the schema.sql and run it
        print("Loading schema.sql")
        with open('schema.sql', 'r') as f:
            schema = f.read()
        result = cur.execute(schema)

        # Get the count of messages
        cur.execute("SELECT COUNT(*) FROM messages;")
        message_count = cur.fetchone()['count']
        cur.execute("SELECT COUNT(*) FROM tickets;")
        ticket_count = cur.fetchone()['count']

        # You must commit the transaction to save the changes
        conn.commit()

    return {"status": "ok", "message_count": message_count, "ticket_count": ticket_count}
