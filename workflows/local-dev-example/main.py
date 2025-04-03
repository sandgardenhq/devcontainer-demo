from datetime import datetime
def handler(input, sandgarden):
    resp = sandgarden.get_connector('tickets-openai').chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "user", "content": sandgarden.get_prompt('hello_world_haiku')},
        ],
    )
    haiku = resp.choices[0].message.content

    # return sandgarden.out(haiku)
    return sandgarden.out({"haiku": haiku, "generated_by": "Sandgarden", "generated_at": datetime.now().isoformat()})