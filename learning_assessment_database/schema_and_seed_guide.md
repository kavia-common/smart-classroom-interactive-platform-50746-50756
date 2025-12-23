# learning_assessment_database: Schema + minimal seed (Step 2.1)

This container uses PostgreSQL and MUST be accessed via the connection string in:

- `db_connection.txt` (expected port **5001**)

## Connection

```bash
CONN="$(cat db_connection.txt)"
$CONN -c "SELECT current_database(), inet_server_port(), current_user;"
```

## Notes about this environment

- The database already contains several tables (e.g., `roles`, `users`, `classrooms`, `questions`, `tags`, `question_choices`, `question_tags` mapping).
- This guide describes the **target** schema needed by the app, plus minimal demo seed data.
- Per platform rules, execute statements **one-by-one** using `psql ... -c "SQL"`.

---

## 1) Core extensions

```bash
$CONN -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

---

## 2) Required tables (target schema)

### 2.1 Users / Roles

The existing schema uses `roles(id smallint)` + `users(role_id smallint)`.

Minimum requirements:
- roles: `teacher`, `student`, `admin`
- users: email/username/display_name/password_hash/is_active + role_id FK

Recommended index:
```bash
$CONN -c "CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);"
```

### 2.2 Classrooms

Existing schema uses:
- `classrooms(created_by UUID NULL REFERENCES users(id))`
- `classroom_students(classroom_id, student_id)` (join table)

Recommended index:
```bash
$CONN -c "CREATE INDEX IF NOT EXISTS idx_classrooms_created_by ON classrooms(created_by);"
```

### 2.3 Question bank (difficulty, tags, optional media)

Existing schema uses:
- `questions(difficulty smallint, media_url text, ...)`
- `tags(id uuid, name text unique)`
- `question_tags(question_id, tag_id)` mapping table
- `question_choices(question_id, choice_text, is_correct, position, ...)`

To support accessibility for media, ensure:
```bash
$CONN -c "ALTER TABLE questions ADD COLUMN IF NOT EXISTS media_alt_text TEXT;"
```

Recommended indexes:
```bash
$CONN -c "CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON questions(difficulty);"
$CONN -c "CREATE INDEX IF NOT EXISTS idx_questions_type ON questions(question_type);"
```

Optional additional mapping (if you prefer a separate name):
```bash
$CONN -c "CREATE TABLE IF NOT EXISTS question_tag_map ( \
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE, \
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE, \
  PRIMARY KEY (question_id, tag_id) \
);"
```

### 2.4 Quiz/exam sessions + teacher navigation state

Existing schema already includes:
- `quiz_sessions(... navigation_locked boolean, current_question_index int, ...)`
- `quiz_session_questions(session_id, question_id, position, points)`
- `teacher_navigation_state(session_id PK, current_question_index, navigation_locked, show_answers, updated_at)`

Recommended index:
```bash
$CONN -c "CREATE INDEX IF NOT EXISTS idx_quiz_sessions_classroom ON quiz_sessions(classroom_id);"
```

### 2.5 Answers/results with scoring

Existing schema uses `answers(user_id, selected_choice_id, free_text_answer, is_correct, ...)`.
If scoring is needed later, extend via `ALTER TABLE` (not required for seed).

Existing schema already includes:
- `session_results(session_id, user_id, total_score, max_score, percent_score, completed_at)`

### 2.6 Memory game sessions + moves

Existing schema includes:
- `memory_game_sessions(classroom_id, created_by, status, grid_size, created_at, ended_at)`
- `memory_game_moves(session_id, user_id, move_number, first_pick, second_pick, is_match, moved_at)`

Additional required table for “pairs/cards”:
```bash
$CONN -c "CREATE TABLE IF NOT EXISTS memory_game_pairs ( \
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), \
  session_id UUID NOT NULL REFERENCES memory_game_sessions(id) ON DELETE CASCADE, \
  pair_key TEXT NOT NULL, \
  front_media_url TEXT, \
  back_media_url TEXT, \
  back_text TEXT, \
  UNIQUE(session_id, pair_key) \
);"
```

---

## 3) Minimal seed data (demo)

Execute each statement separately.

### 3.1 Roles
```bash
$CONN -c "INSERT INTO roles (id, name, description) VALUES \
  (1,'teacher','Teacher'),(2,'student','Student'),(3,'admin','Administrator') \
  ON CONFLICT (id) DO NOTHING;"
```

### 3.2 Demo users
Use UPSERT by username to avoid unique conflicts:

```bash
$CONN -c "INSERT INTO users (email, username, display_name, password_hash, role_id, is_active) VALUES \
  ('teacher1@demo.local','teacher1','Ms. Rivera','demo_password_hash',1,TRUE) \
  ON CONFLICT (username) DO UPDATE SET \
    email=EXCLUDED.email, display_name=EXCLUDED.display_name, role_id=EXCLUDED.role_id, is_active=EXCLUDED.is_active;"
```

```bash
$CONN -c "INSERT INTO users (email, username, display_name, password_hash, role_id, is_active) VALUES \
  ('student1@demo.local','student1','Ava Student','demo_password_hash',2,TRUE) \
  ON CONFLICT (username) DO UPDATE SET \
    email=EXCLUDED.email, display_name=EXCLUDED.display_name, role_id=EXCLUDED.role_id, is_active=EXCLUDED.is_active;"
```

### 3.3 Demo classroom + enrollment
```bash
$CONN -c "INSERT INTO classrooms (name, grade_level, created_by) VALUES \
  ('Demo Classroom A','Grade 4',(SELECT id FROM users WHERE username='teacher1')) \
  ON CONFLICT (name) DO UPDATE SET grade_level=EXCLUDED.grade_level, created_by=EXCLUDED.created_by;"
```

```bash
$CONN -c "INSERT INTO classroom_students (classroom_id, student_id) VALUES \
  ((SELECT id FROM classrooms WHERE name='Demo Classroom A'), (SELECT id FROM users WHERE username='student1')) \
  ON CONFLICT DO NOTHING;"
```

### 3.4 Tags
```bash
$CONN -c "INSERT INTO tags (name) VALUES ('math') ON CONFLICT (name) DO NOTHING;"
$CONN -c "INSERT INTO tags (name) VALUES ('science') ON CONFLICT (name) DO NOTHING;"
$CONN -c "INSERT INTO tags (name) VALUES ('geography') ON CONFLICT (name) DO NOTHING;"
```

### 3.5 Questions + choices + tag mapping

Create questions:
```bash
$CONN -c "INSERT INTO questions (prompt, question_type, difficulty, explanation, media_url, media_alt_text, created_by) VALUES \
  ('What is 2 + 2?','multiple_choice',1,'Basic addition.',NULL,NULL,(SELECT id FROM users WHERE username='teacher1')) \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO questions (prompt, question_type, difficulty, explanation, media_url, media_alt_text, created_by) VALUES \
  ('The Earth orbits the Sun.','true_false',1,'Heliocentric model.',NULL,NULL,(SELECT id FROM users WHERE username='teacher1')) \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO questions (prompt, question_type, difficulty, explanation, media_url, media_alt_text, created_by) VALUES \
  ('What is the capital of France?','multiple_choice',2,'Paris is the capital city of France.',NULL,NULL,(SELECT id FROM users WHERE username='teacher1')) \
  ON CONFLICT DO NOTHING;"
```

Create choices (idempotent best-effort; if your `question_choices` has a unique constraint, `ON CONFLICT DO NOTHING` will work):
```bash
$CONN -c "INSERT INTO question_choices (question_id, choice_text, is_correct, position) \
SELECT q.id, c.choice_text, c.is_correct, c.position \
FROM questions q \
CROSS JOIN LATERAL (VALUES \
  ('2',FALSE,0),('3',FALSE,1),('4',TRUE,2),('5',FALSE,3) \
) AS c(choice_text,is_correct,position) \
WHERE q.prompt='What is 2 + 2?' \
ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO question_choices (question_id, choice_text, is_correct, position) \
SELECT q.id, c.choice_text, c.is_correct, c.position \
FROM questions q \
CROSS JOIN LATERAL (VALUES ('True',TRUE,0),('False',FALSE,1)) AS c(choice_text,is_correct,position) \
WHERE q.prompt='The Earth orbits the Sun.' \
ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO question_choices (question_id, choice_text, is_correct, position) \
SELECT q.id, c.choice_text, c.is_correct, c.position \
FROM questions q \
CROSS JOIN LATERAL (VALUES \
  ('Paris',TRUE,0),('Berlin',FALSE,1),('Rome',FALSE,2),('Madrid',FALSE,3) \
) AS c(choice_text,is_correct,position) \
WHERE q.prompt='What is the capital of France?' \
ON CONFLICT DO NOTHING;"
```

Map tags (use `question_tags` if present in your schema; otherwise `question_tag_map`):
```bash
$CONN -c "INSERT INTO question_tags (question_id, tag_id) VALUES \
  ((SELECT id FROM questions WHERE prompt='What is 2 + 2?'), (SELECT id FROM tags WHERE name='math')) \
  ON CONFLICT DO NOTHING;"
```
```bash
$CONN -c "INSERT INTO question_tags (question_id, tag_id) VALUES \
  ((SELECT id FROM questions WHERE prompt='The Earth orbits the Sun.'), (SELECT id FROM tags WHERE name='science')) \
  ON CONFLICT DO NOTHING;"
```
```bash
$CONN -c "INSERT INTO question_tags (question_id, tag_id) VALUES \
  ((SELECT id FROM questions WHERE prompt='What is the capital of France?'), (SELECT id FROM tags WHERE name='geography')) \
  ON CONFLICT DO NOTHING;"
```

### 3.6 Demo quiz session + navigation state
```bash
$CONN -c "INSERT INTO quiz_sessions (classroom_id, created_by, mode, title, status, navigation_locked, current_question_index, started_at) VALUES \
  ((SELECT id FROM classrooms WHERE name='Demo Classroom A'), (SELECT id FROM users WHERE username='teacher1'), \
   'quiz', 'Demo Quiz 1', 'active', FALSE, 0, now()) \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO quiz_session_questions (session_id, question_id, position, points) VALUES \
  ((SELECT id FROM quiz_sessions WHERE title='Demo Quiz 1' ORDER BY created_at DESC LIMIT 1), (SELECT id FROM questions WHERE prompt='What is 2 + 2?'), 0, 1) \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO quiz_session_questions (session_id, question_id, position, points) VALUES \
  ((SELECT id FROM quiz_sessions WHERE title='Demo Quiz 1' ORDER BY created_at DESC LIMIT 1), (SELECT id FROM questions WHERE prompt='The Earth orbits the Sun.'), 1, 1) \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO quiz_session_questions (session_id, question_id, position, points) VALUES \
  ((SELECT id FROM quiz_sessions WHERE title='Demo Quiz 1' ORDER BY created_at DESC LIMIT 1), (SELECT id FROM questions WHERE prompt='What is the capital of France?'), 2, 1) \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO teacher_navigation_state (session_id, current_question_index, navigation_locked, show_answers) VALUES \
  ((SELECT id FROM quiz_sessions WHERE title='Demo Quiz 1' ORDER BY created_at DESC LIMIT 1), 0, FALSE, FALSE) \
  ON CONFLICT (session_id) DO UPDATE SET \
    current_question_index=EXCLUDED.current_question_index, navigation_locked=EXCLUDED.navigation_locked, show_answers=EXCLUDED.show_answers, updated_at=now();"
```

### 3.7 Demo answer + result
```bash
$CONN -c "INSERT INTO answers (session_id, question_id, user_id, selected_choice_id, free_text_answer, is_correct) VALUES \
  ((SELECT id FROM quiz_sessions WHERE title='Demo Quiz 1' ORDER BY created_at DESC LIMIT 1), \
   (SELECT id FROM questions WHERE prompt='What is 2 + 2?'), \
   (SELECT id FROM users WHERE username='student1'), \
   (SELECT id FROM question_choices qc JOIN questions q ON q.id=qc.question_id WHERE q.prompt='What is 2 + 2?' AND qc.choice_text='4' LIMIT 1), \
   NULL, TRUE) \
  ON CONFLICT (session_id, question_id, user_id) DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO session_results (session_id, user_id, total_score, max_score, percent_score, completed_at) VALUES \
  ((SELECT id FROM quiz_sessions WHERE title='Demo Quiz 1' ORDER BY created_at DESC LIMIT 1), \
   (SELECT id FROM users WHERE username='student1'), \
   1, 3, 33.33, now()) \
  ON CONFLICT (session_id, user_id) DO UPDATE SET \
    total_score=EXCLUDED.total_score, max_score=EXCLUDED.max_score, percent_score=EXCLUDED.percent_score, completed_at=EXCLUDED.completed_at;"
```

### 3.8 Demo memory game session + pairs + move
```bash
$CONN -c "INSERT INTO memory_game_sessions (classroom_id, created_by, status, grid_size) VALUES \
  ((SELECT id FROM classrooms WHERE name='Demo Classroom A'), (SELECT id FROM users WHERE username='teacher1'), 'active', 4) \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO memory_game_pairs (session_id, pair_key, front_media_url, back_media_url, back_text) VALUES \
  ((SELECT id FROM memory_game_sessions ORDER BY created_at DESC LIMIT 1), 'pair1', NULL, NULL, 'Cat') \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO memory_game_pairs (session_id, pair_key, front_media_url, back_media_url, back_text) VALUES \
  ((SELECT id FROM memory_game_sessions ORDER BY created_at DESC LIMIT 1), 'pair2', NULL, NULL, 'Dog') \
  ON CONFLICT DO NOTHING;"
```

```bash
$CONN -c "INSERT INTO memory_game_moves (session_id, user_id, move_number, first_pick, second_pick, is_match) VALUES \
  ((SELECT id FROM memory_game_sessions ORDER BY created_at DESC LIMIT 1), (SELECT id FROM users WHERE username='student1'), 1, 'pair1', 'pair2', FALSE) \
  ON CONFLICT DO NOTHING;"
```

---

## 4) Quick verification queries

```bash
$CONN -c "SELECT name FROM roles ORDER BY id;"
$CONN -c "SELECT username, email FROM users ORDER BY created_at DESC LIMIT 5;"
$CONN -c "SELECT name, grade_level FROM classrooms ORDER BY created_at DESC LIMIT 5;"
$CONN -c "SELECT prompt, difficulty FROM questions ORDER BY created_at DESC LIMIT 10;"
$CONN -c "SELECT title, status, current_question_index, navigation_locked FROM quiz_sessions ORDER BY created_at DESC LIMIT 5;"
$CONN -c "SELECT COUNT(*) FROM memory_game_pairs;"
```
