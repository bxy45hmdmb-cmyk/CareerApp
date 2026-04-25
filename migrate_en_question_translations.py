"""
Populate question_translations table with English translations.
"""
import sqlite3
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = sqlite3.connect('career_db.sqlite')
c = conn.cursor()

# Ensure table exists
c.execute('''
CREATE TABLE IF NOT EXISTS question_translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    lang TEXT NOT NULL,
    text TEXT NOT NULL,
    options TEXT NOT NULL DEFAULT '[]'
)
''')
c.execute('CREATE INDEX IF NOT EXISTS ix_q_trans_qid ON question_translations(question_id)')

# English translations: question_id -> (text_en, [options_en])
en_data = {
    1: (
        'What do you enjoy doing in your free time?',
        ['💻 Building programs or games on a computer',
         '🎨 Drawing or doing design work',
         '📚 Reading books and learning new things',
         '🤝 Socialising and making new friends'],
    ),
    2: (
        'Which school subject comes easiest to you?',
        ['➗ Maths and Physics',
         '🧬 Biology and Chemistry',
         '🗣️ Languages (Kazakh, English)',
         '🏛️ History and Geography'],
    ),
    3: (
        'What role do you prefer in a group project?',
        ['🎯 Leader',
         '🔬 Researcher',
         '✏️ Executor',
         '🤝 Organiser'],
    ),
    4: (
        'What would you like to do in the future?',
        ['🌍 Build technologies that change the world',
         '❤️ Help people and heal them',
         '🎭 Work in art, design, or music',
         '📊 Start a business and influence the economy'],
    ),
    5: (
        'What kind of work environment suits you?',
        ['🏠 Remote work from home',
         '🏢 A large team in an office',
         '🏥 Direct work with people',
         '🔬 A laboratory or scientific environment'],
    ),
    6: (
        'How do you think when solving problems?',
        ['🧮 Through logic and numbers',
         '🎨 With a creative approach',
         '📖 By researching and gathering information',
         '💬 By consulting others'],
    ),
    7: (
        'Which achievement matters more to you?',
        ['💡 Invent something new',
         '🏆 Win a competition',
         '❤️ Be useful to people',
         '💰 Earn a lot of money'],
    ),
    8: (
        'Which olympiad or competition would you like to enter?',
        ['🖥️ Computer Science olympiad',
         '🔭 Physics or Maths olympiad',
         '🎨 Creative competitions',
         '🗣️ Debates'],
    ),
    9: (
        'Which project would interest you the most?',
        ['💻 Build a mobile app or website',
         '🏗️ Design a building or mechanical structure',
         '❤️ Medical research to treat people',
         '📊 A business plan or startup'],
    ),
    10: (
        'Which physics topic interests you?',
        ['⚡ Electricity and electronics',
         '🚀 Mechanics and laws of motion',
         '🌊 Thermodynamics and heat transfer',
         '🌌 Astrophysics and space'],
    ),
    11: (
        'What do you think people will remember you for?',
        ['🚀 Creating a great technology or invention',
         '🎨 Creating a great work of art',
         '⚖️ Contributing to justice in society',
         '💰 Running a successful business and creating jobs'],
    ),
    12: (
        'What do you do during summer or winter holidays?',
        ['🖥️ Study programming or new technologies',
         '🎭 Do theatre, film, or music',
         '🏆 Organise sports competitions or events',
         '🔭 Read science books and conduct research'],
    ),
    13: (
        'What do you do before making an important decision?',
        ['📊 Gather data and analyse carefully',
         '🤝 Consult friends or family',
         '🖊️ Write down pros and cons',
         '💡 Trust my intuition'],
    ),
    14: (
        'What do you think about laws and regulations?',
        ['⚖️ Laws should protect people — I want to improve them',
         '💻 Technology law is very important',
         '🏥 Medical ethics and law are very complex',
         '💼 An entrepreneur needs to know business law'],
    ),
    15: (
        'What do you enjoy studying in chemistry?',
        ['🧪 Running laboratory experiments',
         '💊 Pharmacology — about medicines',
         '🔋 Electrochemistry and materials science',
         '🌿 Organic chemistry and natural substances'],
    ),
    16: (
        'When you meet someone new, what do you ask them first?',
        ['💻 What technologies do you work with?',
         '🎨 Tell me about your hobbies and creative interests',
         '💼 What business or project are you running?',
         '📚 What are you studying or researching?'],
    ),
    17: (
        'What type of responsibility do you prefer to take on?',
        ['🔧 Responsibility for a technical system',
         '👥 Responsibility for team members',
         '📋 Responsibility for a project result or process',
         '🎨 Responsibility for the quality of a creative project'],
    ),
    18: (
        'Which scientific or technological advancement excites you?',
        ['🤖 Artificial intelligence and machine learning',
         '🧬 Genetic engineering and biotechnology',
         '🌱 Green energy and eco-friendly solutions',
         '🌍 Space exploration'],
    ),
    19: (
        'Which area of maths do you enjoy?',
        ['📐 Geometry and spatial thinking',
         '📊 Statistics and probability theory',
         '🔢 Algebra and systems of equations',
         '∫ Calculus (integrals and derivatives)'],
    ),
    20: (
        'When you receive feedback on your work...',
        ['📝 I ask for detailed written feedback',
         '💬 I prefer a face-to-face conversation',
         '📊 Numbers and metrics are enough for me',
         '🎨 Creative freedom is what matters most'],
    ),
    21: (
        'Which period of history interests you?',
        ['🏛️ Ancient civilisations and cultures',
         '⚔️ Wars and political revolutions',
         '🔭 Scientific revolutions and inventions',
         '💰 Economic development and trade routes'],
    ),
    22: (
        'When you give someone advice...',
        ['🔍 I base it on facts and research',
         '❤️ I show empathy and understand their feelings',
         '📋 I offer a concrete plan and steps',
         '⚖️ I consider it from a legal or ethical angle'],
    ),
    23: (
        'How do you use English?',
        ['💻 I read technical documentation and IT materials',
         '🎬 I watch films and listen to music',
         '📰 I read news and legal texts',
         '🤝 I handle international business communications'],
    ),
    24: (
        'Have you done any project at school or home? Which one?',
        ['🖥️ Built a website, bot, or program',
         '🎨 Created a drawing, video, or piece of music',
         '🤝 Organised an event or volunteered',
         '💡 Came up with a business idea or small venture'],
    ),
    25: (
        'What do you consider most important in life?',
        ['💡 Making discoveries and inventions',
         '❤️ Giving people health and happiness',
         '⚖️ Establishing equality and justice',
         '💰 Financial stability and freedom'],
    ),
    26: (
        'Which activities do you take part in at school?',
        ['🖥️ Hackathons or IT competitions',
         '🎭 Creative festivals or arts evenings',
         '🗣️ Debates or simulation games',
         '💼 Young Entrepreneurs Club or Model UN'],
    ),
    27: (
        'If you could solve one of the world\'s biggest problems...',
        ['🌡️ I would create a system to stop climate change',
         '🧬 I would find a cure for cancer or infectious diseases',
         '⚖️ I would establish international laws and peace',
         '🚀 I would create technology for humanity to explore space'],
    ),
    28: (
        'What is your greatest strength?',
        ['🧩 Solving complex technical problems',
         '🎨 Coming up with original ideas',
         '🤝 Getting along well with people',
         '📢 Expressing my thoughts clearly and confidently'],
    ),
    29: (
        'What shows or podcasts do you listen to for leisure?',
        ['🤖 About technology, programming, and AI',
         '🎨 About art, design, music, or film',
         '⚖️ About politics, law, and society',
         '💼 About business, investing, and entrepreneurship'],
    ),
    30: (
        'Which profession would you be proud of in the future?',
        ['👨‍💻 IT specialist, engineer, or scientist',
         '🎭 Artist, designer, or musician',
         '⚖️ Lawyer, judge, or diplomat',
         '👩‍⚕️ Doctor, psychologist, or pharmacist'],
    ),
}

# Delete existing English rows and re-insert
c.execute("DELETE FROM question_translations WHERE lang='en'")

inserted = 0
for q_id, (text, options) in en_data.items():
    c.execute('SELECT id FROM questions WHERE id=?', (q_id,))
    if not c.fetchone():
        print(f'  Question {q_id} not found, skipping')
        continue
    c.execute(
        '''INSERT INTO question_translations (question_id, lang, text, options)
           VALUES (?, 'en', ?, ?)''',
        (q_id, text, json.dumps(options, ensure_ascii=False))
    )
    inserted += 1

conn.commit()
conn.close()
print(f'Inserted {inserted} English question translations')
print('Done!')
