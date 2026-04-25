"""
Populate profession_translations table with English translations.
"""
import sqlite3
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

conn = sqlite3.connect('career_db.sqlite')
c = conn.cursor()

# Ensure table exists (created by migrate_translations.py)
c.execute('''
CREATE TABLE IF NOT EXISTS profession_translations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    profession_id INTEGER NOT NULL REFERENCES professions(id) ON DELETE CASCADE,
    lang TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    required_skills TEXT NOT NULL DEFAULT '[]',
    future_opportunities TEXT NOT NULL DEFAULT '[]'
)
''')
c.execute('CREATE INDEX IF NOT EXISTS ix_prof_trans_pid ON profession_translations(profession_id)')

# English translations for all 15 professions
en_data = {
    1: (
        'Software Developer',
        'Software developers create computer programs and applications. They work with algorithms and data structures, writing code in various programming languages.',
        'Technology',
        ['Logical thinking', 'Mathematics', 'Creativity', 'Teamwork'],
        ['Building AI systems', 'Creating mobile apps', 'Remote work at global companies', 'Founding an IT startup'],
    ),
    2: (
        'Doctor',
        'Doctors maintain people\'s health and treat diseases. Medicine is constantly advancing with new technologies and treatment methods.',
        'Medicine',
        ['Empathy', 'Attentiveness', 'Patience', 'Analytical thinking'],
        ['Medical research', 'Specialisation in a narrow field', 'International career', 'Telemedicine'],
    ),
    3: (
        'Designer',
        'Designers create visual communication. They work in UI/UX, graphic, and industrial design.',
        'Art & Design',
        ['Creative thinking', 'Aesthetic sense', 'Figma', 'Adobe'],
        ['UI/UX at leading companies', 'Freelancing', 'Brand design', 'Running your own studio'],
    ),
    4: (
        'Engineer',
        'Engineers design, build, and improve technological systems.',
        'Engineering',
        ['Mathematical thinking', 'Technical knowledge', '3D modelling'],
        ['Working on large-scale projects', 'Smart city design', 'Engineering innovation', 'International experience'],
    ),
    5: (
        'Lawyer',
        'Lawyers provide legal advice and represent clients in court proceedings.',
        'Law',
        ['Rhetoric', 'Analytical thinking', 'Communication'],
        ['International law', 'Corporate lawyer', 'Judge or prosecutor', 'Diplomacy'],
    ),
    6: (
        'Entrepreneur',
        'Entrepreneurs bring new business ideas to life, managing teams and resources.',
        'Business',
        ['Leadership', 'Communication', 'Strategic thinking'],
        ['Starting your own business', 'Attracting investment', 'Team management', 'International expansion'],
    ),
    7: (
        'Data Scientist',
        'Data scientists analyse large datasets and build predictive models using machine learning algorithms.',
        'Technology',
        ['Statistics', 'Python', 'SQL', 'Machine learning', 'Data visualisation'],
        ['Data Scientist at major companies', 'AI research', 'Business analytics', 'Academic research'],
    ),
    8: (
        'Cybersecurity Specialist',
        'Cybersecurity specialists protect computer systems, networks, and data from hackers.',
        'Technology',
        ['Network security', 'Ethical hacking', 'Cryptography', 'Linux'],
        ['Protecting corporate systems', 'Penetration testing', 'Government cybersecurity', 'International certifications'],
    ),
    9: (
        'Psychologist',
        'Psychologists help people maintain mental health and resolve behavioural issues.',
        'Medicine',
        ['Empathy', 'Active listening', 'Analytical thinking', 'Communication'],
        ['Clinical psychology', 'School psychology', 'HR field', 'Psychotherapy'],
    ),
    10: (
        'Biotechnologist',
        'Biotechnologists use living organisms to create new medicines, vaccines, and products.',
        'Medicine',
        ['Biochemistry', 'Molecular biology', 'Laboratory techniques', 'GMO technologies'],
        ['Drug development', 'Gene therapy', 'Food biotechnology', 'Scientific research'],
    ),
    11: (
        'Architect',
        'Architects design buildings and spaces, combining functionality with aesthetics.',
        'Engineering',
        ['3D modelling', 'Technical drawing', 'Mathematics', 'Creative thinking'],
        ['Smart building design', 'Urban planning', 'Eco-architecture', 'International projects'],
    ),
    12: (
        'Journalist',
        'Journalists gather, process, and deliver important news to society. Freedom of speech is the foundation of the profession.',
        'Art & Design',
        ['Writing skills', 'Interviewing', 'Research', 'Communication'],
        ['Digital journalism', 'Podcasts and vlogs', 'International media', 'Founding a media startup'],
    ),
    13: (
        'Game Developer',
        'Game developers design, program, and create video games. Creativity and technology come together.',
        'Art & Design',
        ['Unity/Unreal Engine', 'Programming', '3D modelling', 'Game design'],
        ['AAA game development', 'VR/AR projects', 'Game startups', 'Running your own studio'],
    ),
    14: (
        'Marketing Specialist',
        'Marketing specialists promote products and services to consumers and shape brand identity. Digital marketing is a key area.',
        'Business',
        ['SMM', 'SEO', 'Data analysis', 'Creativity', 'Communication'],
        ['Digital marketing', 'Brand management', 'Marketing agencies', 'International companies'],
    ),
    15: (
        'Financial Analyst',
        'Financial analysts assess the financial health of companies and develop investment strategies.',
        'Business',
        ['Financial analysis', 'Excel', 'Mathematics', 'Economics', 'Analytical thinking'],
        ['Investment banking', 'Asset management', 'Fintech', 'Running your own investment fund'],
    ),
}

# Delete existing English rows and re-insert
c.execute("DELETE FROM profession_translations WHERE lang='en'")

for prof_id, (title, desc, cat, skills, opps) in en_data.items():
    c.execute('SELECT id FROM professions WHERE id=?', (prof_id,))
    if not c.fetchone():
        print(f'  Profession {prof_id} not found, skipping')
        continue
    c.execute(
        '''INSERT INTO profession_translations
           (profession_id, lang, title, description, category, required_skills, future_opportunities)
           VALUES (?, 'en', ?, ?, ?, ?, ?)''',
        (prof_id, title, desc, cat,
         json.dumps(skills, ensure_ascii=False),
         json.dumps(opps, ensure_ascii=False))
    )

conn.commit()
conn.close()
print(f'Inserted {len(en_data)} English profession translations')
print('Done!')
