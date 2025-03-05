-- Drop tables if they exist
DROP TABLE IF EXISTS messages;

DROP TABLE IF EXISTS tickets;

DROP TABLE IF EXISTS customers;

DROP TABLE IF EXISTS agents;

-- Create Tickets table
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    subject VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL, -- new, awaiting_customer, awaiting_agent, on_hold, closed
    priority VARCHAR(50), -- "1 - Low", "2 - Medium", "3 - High"
    customer_id INTEGER NOT NULL,
    needs_escalation BOOLEAN DEFAULT NULL
);

-- Create Messages table
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    ticket_id INTEGER NOT NULL,
    sender_type VARCHAR(50) NOT NULL, -- 'customer' or 'agent'
    sender_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets (id)
);

-- Create Customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    plan VARCHAR(255) -- "basic", "premium", "professional", "enterprise"
);

-- Create Agents table
CREATE TABLE agents (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);

INSERT INTO
    customers (id, name, email)
values (
        1,
        'Lise Heatlie',
        'lheatlie0@multiply.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        2,
        'Cassi Matitiaho',
        'cmatitiaho1@samsung.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        3,
        'Vikki Joney',
        'vjoney2@noaa.gov'
    );

INSERT INTO
    customers (id, name, email)
values (
        4,
        'Helen-elizabeth McGragh',
        'hmcgragh3@yelp.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        5,
        'Pinchas Lacy',
        'placy4@instagram.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        6,
        'Tomasina Geist',
        'tgeist5@printfriendly.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        7,
        'Ellwood McDonough',
        'emcdonough6@prnewswire.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        8,
        'Carolyne Connerry',
        'cconnerry7@hao123.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        9,
        'Torre Kennealy',
        'tkennealy8@sun.com'
    );

INSERT INTO
    customers (id, name, email)
values (
        10,
        'Alfi Dalglish',
        'adalglish9@sina.com.cn'
    );

INSERT INTO
    agents (id, name, email)
values (
        1,
        'Staci Spearett',
        'sspearett0@alexa.com'
    );

INSERT INTO
    agents (id, name, email)
values (
        2,
        'Wynn Blyth',
        'wblyth1@sogou.com'
    );

INSERT INTO
    agents (id, name, email)
values (
        3,
        'Trish Yanson',
        'tyanson2@utexas.edu'
    );

INSERT INTO
    agents (id, name, email)
values (
        4,
        'Antonietta Martland',
        'amartland3@dmoz.org'
    );

INSERT INTO
    agents (id, name, email)
values (
        5,
        'Charlton Soughton',
        'csoughton4@reddit.com'
    );

INSERT INTO
    agents (id, name, email)
values (
        6,
        'Godfree Gronav',
        'ggronav5@dmoz.org'
    );

INSERT INTO
    agents (id, name, email)
values (
        7,
        'Sinclair Hacking',
        'shacking6@nhs.uk'
    );

INSERT INTO
    agents (id, name, email)
values (
        8,
        'Zacharie Crookshank',
        'zcrookshank7@tinypic.com'
    );

INSERT INTO
    agents (id, name, email)
values (
        9,
        'Patrick Threadgold',
        'pthreadgold8@icq.com'
    );

INSERT INTO
    agents (id, name, email)
values (
        10,
        'Raviv Edeler',
        'redeler9@amazon.de'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        1,
        'Adding new line to account',
        'closed',
        '2 - Medium',
        1
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        1,
        'customer',
        1,
        'Hi, I would like to add a new line to my account please.'
    ),
    (
        1,
        'agent',
        4,
        'Hello, thank you for reaching out. What type of new line are you looking for?'
    ),
    (
        1,
        'customer',
        1,
        'I''m thinking maybe an extra 10GB of data per month.'
    ),
    (
        1,
        'agent',
        4,
        'That sounds like a great idea! I''ve added the new line to your account. Your new plan will take effect immediately.'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        2,
        'Trouble accessing data while abroad',
        'closed',
        '3 - High',
        1
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        2,
        'customer',
        1,
        'I''m having trouble accessing my data when I travel abroad.'
    ),
    (
        2,
        'agent',
        3,
        'Hi there, can you tell me more about the issue you''re experiencing?'
    ),
    (
        2,
        'customer',
        1,
        'Yeah, it says my account is blocked or something. I don''t know what to do.'
    ),
    (
        2,
        'agent',
        3,
        'I''ve checked on our end and it seems like there was a temporary block due to international roaming. It should be resolved now. Can you try again?'
    ),
    (
        2,
        'customer',
        1,
        'I suppose that worked... I don''t know.'
    ),
    (
        2,
        'agent',
        3,
        'Okay, sorry to hear that it wasn''t a more satisfying solution for you. If you have any other issues in the future, please don''t hesitate to reach out.'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        4,
        'Device Swap or Upgrade Inquiry',
        'closed',
        '2 - Medium',
        10
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        4,
        'customer',
        10,
        'Hi, I was thinking about upgrading my current phone to a newer model. How does this process work, and am I eligible for any special deals or discounts?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        4,
        'agent',
        2,
        'Hello! Upgrading your phone is a straightforward process. You can either swap it for a different model or choose one of our latest releases. Let me check your eligibility for any upgrade deals.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        4,
        'agent',
        2,
        'Thanks for waiting. It looks like you qualify for our standard upgrade plan, which allows you to change your device after a year. However, there are no special discounts available at the moment.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        4,
        'customer',
        10,
        'Alright, thanks for the information. I''ll have to think about it and decide what to do next.'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        6,
        'Account Security Concerns',
        'closed',
        '3 - High',
        7
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        6,
        'customer',
        7,
        'I think my account might be hacked. I received notifications about unfamiliar login attempts. How do I change my password and set up extra security measures?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        6,
        'agent',
        3,
        'Hello, I see. Let me quickly check on that for you. Can you confirm your account details?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        6,
        'customer',
        7,
        'I confirmed those details when I called earlier! I need solutions, not more questions. This is really frustrating.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        6,
        'agent',
        3,
        'I apologize for the inconvenience. You can change your password in the account settings. For extra security measures, I think you can enable two-factor authentication, but I need to confirm the exact steps.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        6,
        'customer',
        7,
        'This isn''t helpful! I need real assistance, not guesses. Can someone else help?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        6,
        'agent',
        3,
        'I understand your frustration. I will escalate this issue to a specialist who can better assist you. Thank you for your patience.'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        7,
        'Family Plan Update',
        'closed',
        '2 - Medium',
        5
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        7,
        'customer',
        5,
        'Hi, I want to update my family plan to either add or remove members, but I''m not quite sure how to do this on your website or the mobile app. Can you help?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        7,
        'agent',
        3,
        'Hello! Sure, I can help with that. Normally, you can manage family plan members from the account management section on our website. Let me guide you through the steps.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        7,
        'agent',
        3,
        'First, log into your account, then navigate to "Manage Plans". There should be options to add or remove members. Sometimes, due to account settings, certain options might not be visible.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        7,
        'customer',
        5,
        'I followed these steps, but I don''t see the options. Am I missing something?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        7,
        'agent',
        3,
        'It is possible that your account might require additional permissions to make changes. Let me check on that for you and get back with a definitive process.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        7,
        'customer',
        5,
        'Okay, thanks. I appreciate your help. I''ll wait for further instructions.'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        8,
        'Phone Damaged in Accident - Repair or Replacement Options',
        'awaiting_customer',
        '2 - Medium',
        3
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        8,
        'customer',
        3,
        'Hi, I accidentally dropped my phone, and the screen is cracked. What are my options for getting it repaired or replaced?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        8,
        'agent',
        3,
        'Hello, I''m sorry to hear about your phone! You can visit one of our authorized repair centers for assistance. They will be able to assess the damage and suggest repair options.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        8,
        'customer',
        3,
        'Thanks. Do I need to make an appointment, or can I just walk in?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        8,
        'agent',
        3,
        'Appointments are preferred, but walk-ins are also welcome. Let me check if there are any specific requirements. One moment please...'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        8,
        'customer',
        3,
        'Alright, thanks. I''m a little confused, though. Can you confirm if I can claim through any insurance or if it''s strictly out-of-pocket?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        8,
        'agent',
        3,
        'Unfortunately, I don''t have that information right now. Let me find out for you and get back to you as soon as possible. Apologies for the confusion.'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        9,
        'Upgraded Phone Missing Features Previously Available',
        'closed',
        '2 - Medium',
        5
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        9,
        'customer',
        5,
        'Hello, I recently upgraded to a new phone but I noticed I''m missing some features that I had on my old device, like the XYZ app. Can someone help me with this?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        9,
        'agent',
        1,
        'Hi there! I understand how important it is to have all the features you''re used to. Let''s see what we can do to get those back for you.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        9,
        'agent',
        1,
        'The XYZ app might not be pre-installed on your new device, but you can download it from the App Store. Here’s how you can do that...'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        9,
        'customer',
        5,
        'Thank you, that worked! What about the functionality that seems a bit different, is there anything I can do to tweak it?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        9,
        'agent',
        1,
        'You can customize the settings of many apps and functions to match what you''re used to. Let me guide you through the settings menu to adjust those preferences.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        9,
        'customer',
        5,
        'Great, that really helped. I appreciate the assistance and feel more comfortable with my new phone now.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        9,
        'agent',
        1,
        'I''m glad I could help! If there''s anything else you need, feel free to reach out anytime.'
    );

INSERT INTO
    tickets (
        id,
        subject,
        status,
        priority,
        customer_id
    )
VALUES (
        10,
        'Trouble Setting Up Payments Through Company''s Payment Plan',
        'closed',
        '3 - High',
        4
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        10,
        'customer',
        4,
        'Hi, I''m having trouble setting up my payments through your payment plan options. Can someone help me resolve this?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        10,
        'agent',
        5,
        'Hello! I''d love to help you out with that. Let''s get this sorted for you as quickly as possible! Could you tell me what seems to be the issue?'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        10,
        'customer',
        4,
        'When I try to set it up, it just doesn''t process and I get an error message. Not sure what I''m doing wrong.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        10,
        'agent',
        5,
        'No worries! Sometimes this can happen if the payment method isn''t verified or there’s a small glitch. Let me walk you through the steps to fix this.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        10,
        'agent',
        5,
        'Could you please try removing the payment method and adding it back, making sure that all the details are correct? Once done, let''s try processing a small payment.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        10,
        'customer',
        4,
        'I did what you said, and it worked! Thanks for the cheerful guidance, I was really starting to worry about this.'
    );

INSERT INTO
    messages (
        ticket_id,
        sender_type,
        sender_id,
        content
    )
VALUES (
        10,
        'agent',
        5,
        'Yay! I''m so happy to hear that it''s working now. If there''s anything else at all, feel free to reach out. Have a fantastic day!'
    );
