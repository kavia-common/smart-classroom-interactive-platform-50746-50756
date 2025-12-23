--
-- PostgreSQL database dump
--

\restrict yhFK7RJuzNWCD0ZwXysP1YRcBoZzW6tHkZ4zMiZbOaaHdu0pDrAacIQvlwxEjKm

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS myapp;
--
-- Name: myapp; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE myapp WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE myapp OWNER TO postgres;

\unrestrict yhFK7RJuzNWCD0ZwXysP1YRcBoZzW6tHkZ4zMiZbOaaHdu0pDrAacIQvlwxEjKm
\connect myapp
\restrict yhFK7RJuzNWCD0ZwXysP1YRcBoZzW6tHkZ4zMiZbOaaHdu0pDrAacIQvlwxEjKm

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: appuser
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;


ALTER FUNCTION public.set_updated_at() OWNER TO appuser;

--
-- Name: touch_nav_updated_at(); Type: FUNCTION; Schema: public; Owner: appuser
--

CREATE FUNCTION public.touch_nav_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;


ALTER FUNCTION public.touch_nav_updated_at() OWNER TO appuser;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: answers; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.answers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    question_id uuid NOT NULL,
    user_id uuid,
    selected_choice_id uuid,
    free_text_answer text,
    is_correct boolean,
    answered_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.answers OWNER TO appuser;

--
-- Name: classroom_members; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.classroom_members (
    classroom_id uuid NOT NULL,
    user_id uuid NOT NULL,
    member_role text DEFAULT 'student'::text NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.classroom_members OWNER TO appuser;

--
-- Name: classroom_students; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.classroom_students (
    classroom_id uuid NOT NULL,
    student_id uuid NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.classroom_students OWNER TO appuser;

--
-- Name: classrooms; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.classrooms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    grade_level text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.classrooms OWNER TO appuser;

--
-- Name: memory_game_moves; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.memory_game_moves (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    user_id uuid,
    move_no integer NOT NULL,
    move_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.memory_game_moves OWNER TO appuser;

--
-- Name: memory_game_pairs; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.memory_game_pairs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    pair_key text NOT NULL,
    front_media_url text,
    back_media_url text,
    back_text text
);


ALTER TABLE public.memory_game_pairs OWNER TO appuser;

--
-- Name: memory_game_sessions; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.memory_game_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    classroom_id uuid,
    created_by uuid,
    status text DEFAULT 'created'::text NOT NULL,
    grid_size smallint DEFAULT 4 NOT NULL,
    theme text,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    started_at timestamp with time zone,
    ended_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT memory_game_sessions_grid_size_check CHECK ((grid_size = ANY (ARRAY[2, 4, 6, 8])))
);


ALTER TABLE public.memory_game_sessions OWNER TO appuser;

--
-- Name: question_choices; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.question_choices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    question_id uuid NOT NULL,
    choice_text text NOT NULL,
    is_correct boolean DEFAULT false NOT NULL,
    "position" smallint DEFAULT 1 NOT NULL,
    media_url text
);


ALTER TABLE public.question_choices OWNER TO appuser;

--
-- Name: question_tag_map; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.question_tag_map (
    question_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.question_tag_map OWNER TO appuser;

--
-- Name: question_tags; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.question_tags (
    question_id uuid NOT NULL,
    tag_id uuid NOT NULL
);


ALTER TABLE public.question_tags OWNER TO appuser;

--
-- Name: questions; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prompt text NOT NULL,
    question_type text DEFAULT 'multiple_choice'::text NOT NULL,
    difficulty smallint DEFAULT 1 NOT NULL,
    explanation text,
    media_url text,
    created_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    media_alt_text text,
    CONSTRAINT questions_difficulty_check CHECK (((difficulty >= 1) AND (difficulty <= 5)))
);


ALTER TABLE public.questions OWNER TO appuser;

--
-- Name: quiz_session_questions; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.quiz_session_questions (
    session_id uuid NOT NULL,
    question_id uuid NOT NULL,
    "position" smallint DEFAULT 1 NOT NULL,
    points smallint DEFAULT 1 NOT NULL
);


ALTER TABLE public.quiz_session_questions OWNER TO appuser;

--
-- Name: quiz_sessions; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.quiz_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    classroom_id uuid,
    created_by uuid,
    mode text DEFAULT 'quiz'::text NOT NULL,
    status text DEFAULT 'created'::text NOT NULL,
    title text,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    started_at timestamp with time zone,
    ended_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.quiz_sessions OWNER TO appuser;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.roles (
    id smallint NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.roles OWNER TO appuser;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: appuser
--

CREATE SEQUENCE public.roles_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO appuser;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: appuser
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: session_results; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.session_results (
    session_id uuid NOT NULL,
    user_id uuid NOT NULL,
    score numeric(6,2) DEFAULT 0 NOT NULL,
    max_score numeric(6,2) DEFAULT 0 NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.session_results OWNER TO appuser;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tags OWNER TO appuser;

--
-- Name: teacher_navigation_state; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.teacher_navigation_state (
    session_id uuid NOT NULL,
    current_position smallint DEFAULT 1 NOT NULL,
    phase text DEFAULT 'question'::text NOT NULL,
    reveal_answer boolean DEFAULT false NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.teacher_navigation_state OWNER TO appuser;

--
-- Name: users; Type: TABLE; Schema: public; Owner: appuser
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email text,
    username text,
    display_name text NOT NULL,
    password_hash text,
    role_id smallint NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT users_check CHECK (((email IS NOT NULL) OR (username IS NOT NULL)))
);


ALTER TABLE public.users OWNER TO appuser;

--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Data for Name: answers; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.answers (id, session_id, question_id, user_id, selected_choice_id, free_text_answer, is_correct, answered_at) FROM stdin;
\.


--
-- Data for Name: classroom_members; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.classroom_members (classroom_id, user_id, member_role, joined_at) FROM stdin;
cf47f78e-d3fe-4b57-9b19-3f1b598a852d	b816d1ca-a28a-4ffb-a667-909fb59029ed	teacher	2025-12-23 01:27:46.771278+00
cf47f78e-d3fe-4b57-9b19-3f1b598a852d	cf07cd6d-db82-46c2-85e7-4aca6f3330b1	student	2025-12-23 01:27:48.909181+00
\.


--
-- Data for Name: classroom_students; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.classroom_students (classroom_id, student_id, joined_at) FROM stdin;
\.


--
-- Data for Name: classrooms; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.classrooms (id, name, grade_level, created_by, created_at, updated_at) FROM stdin;
cf47f78e-d3fe-4b57-9b19-3f1b598a852d	Demo Classroom	Grade 5	b816d1ca-a28a-4ffb-a667-909fb59029ed	2025-12-23 01:27:44.337891+00	2025-12-23 01:27:44.337891+00
\.


--
-- Data for Name: memory_game_moves; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.memory_game_moves (id, session_id, user_id, move_no, move_data, created_at) FROM stdin;
\.


--
-- Data for Name: memory_game_pairs; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.memory_game_pairs (id, session_id, pair_key, front_media_url, back_media_url, back_text) FROM stdin;
\.


--
-- Data for Name: memory_game_sessions; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.memory_game_sessions (id, classroom_id, created_by, status, grid_size, theme, settings, started_at, ended_at, created_at) FROM stdin;
\.


--
-- Data for Name: question_choices; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.question_choices (id, question_id, choice_text, is_correct, "position", media_url) FROM stdin;
84bc82a2-a3e6-4860-8eae-2f10d0d579b1	2547c1b9-a6a9-4dfc-83a5-83afb75f5001	54	f	1	\N
023fde1a-94f2-41a8-beb8-29114da18e8e	2547c1b9-a6a9-4dfc-83a5-83afb75f5001	56	t	2	\N
c907455e-2eea-4d67-87e3-161c3309f850	2547c1b9-a6a9-4dfc-83a5-83afb75f5001	64	f	3	\N
258a3375-a9c9-434f-be8d-da70c544008c	2547c1b9-a6a9-4dfc-83a5-83afb75f5001	58	f	4	\N
\.


--
-- Data for Name: question_tag_map; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.question_tag_map (question_id, tag_id) FROM stdin;
\.


--
-- Data for Name: question_tags; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.question_tags (question_id, tag_id) FROM stdin;
2547c1b9-a6a9-4dfc-83a5-83afb75f5001	9bc83279-5eec-4ae5-a211-ced4284dd1fe
\.


--
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.questions (id, prompt, question_type, difficulty, explanation, media_url, created_by, is_active, created_at, updated_at, media_alt_text) FROM stdin;
2547c1b9-a6a9-4dfc-83a5-83afb75f5001	What is 7 × 8?	multiple_choice	1	7×8=56	\N	b816d1ca-a28a-4ffb-a667-909fb59029ed	t	2025-12-23 01:27:55.212886+00	2025-12-23 01:27:55.212886+00	\N
\.


--
-- Data for Name: quiz_session_questions; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.quiz_session_questions (session_id, question_id, "position", points) FROM stdin;
c706618d-9363-414d-887b-9d6b054b0657	2547c1b9-a6a9-4dfc-83a5-83afb75f5001	1	1
\.


--
-- Data for Name: quiz_sessions; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.quiz_sessions (id, classroom_id, created_by, mode, status, title, settings, started_at, ended_at, created_at) FROM stdin;
c706618d-9363-414d-887b-9d6b054b0657	cf47f78e-d3fe-4b57-9b19-3f1b598a852d	b816d1ca-a28a-4ffb-a667-909fb59029ed	quiz	active	Demo Quiz	{"shuffle": false, "time_limit_seconds": 0}	2025-12-23 01:28:07.194236+00	\N	2025-12-23 01:28:07.194236+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.roles (id, name, description) FROM stdin;
1	admin	Platform administrator
2	teacher	Teacher/Facilitator
3	student	Student
\.


--
-- Data for Name: session_results; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.session_results (session_id, user_id, score, max_score, details, computed_at) FROM stdin;
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.tags (id, name, created_at) FROM stdin;
9bc83279-5eec-4ae5-a211-ced4284dd1fe	math	2025-12-23 01:27:51.47013+00
da43313c-7d13-47fa-9cd9-f7e46cfd6f1c	science	2025-12-23 01:27:51.47013+00
cde34bad-ce6f-4b46-bbcd-fa207481d790	history	2025-12-23 01:27:51.47013+00
\.


--
-- Data for Name: teacher_navigation_state; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.teacher_navigation_state (session_id, current_position, phase, reveal_answer, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: appuser
--

COPY public.users (id, email, username, display_name, password_hash, role_id, is_active, created_at, updated_at) FROM stdin;
30b73645-25a2-4761-864e-9591f549c2d3	admin@example.com	admin	Admin	\N	1	t	2025-12-23 01:27:42.025896+00	2025-12-23 01:27:42.025896+00
b816d1ca-a28a-4ffb-a667-909fb59029ed	teacher1@demo.local	teacher1	Ms. Rivera	\N	1	t	2025-12-23 01:27:42.025896+00	2025-12-23 01:31:54.115305+00
cf07cd6d-db82-46c2-85e7-4aca6f3330b1	student1@demo.local	student1	Ava Student	\N	2	t	2025-12-23 01:27:42.025896+00	2025-12-23 01:31:56.57907+00
\.


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: appuser
--

SELECT pg_catalog.setval('public.roles_id_seq', 3, true);


--
-- Name: answers answers_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: answers answers_session_id_question_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_session_id_question_id_user_id_key UNIQUE (session_id, question_id, user_id);


--
-- Name: classroom_members classroom_members_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classroom_members
    ADD CONSTRAINT classroom_members_pkey PRIMARY KEY (classroom_id, user_id);


--
-- Name: classroom_students classroom_students_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classroom_students
    ADD CONSTRAINT classroom_students_pkey PRIMARY KEY (classroom_id, student_id);


--
-- Name: classrooms classrooms_name_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_name_key UNIQUE (name);


--
-- Name: classrooms classrooms_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_pkey PRIMARY KEY (id);


--
-- Name: memory_game_moves memory_game_moves_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_moves
    ADD CONSTRAINT memory_game_moves_pkey PRIMARY KEY (id);


--
-- Name: memory_game_moves memory_game_moves_session_id_user_id_move_no_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_moves
    ADD CONSTRAINT memory_game_moves_session_id_user_id_move_no_key UNIQUE (session_id, user_id, move_no);


--
-- Name: memory_game_pairs memory_game_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_pairs
    ADD CONSTRAINT memory_game_pairs_pkey PRIMARY KEY (id);


--
-- Name: memory_game_pairs memory_game_pairs_session_id_pair_key_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_pairs
    ADD CONSTRAINT memory_game_pairs_session_id_pair_key_key UNIQUE (session_id, pair_key);


--
-- Name: memory_game_sessions memory_game_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_sessions
    ADD CONSTRAINT memory_game_sessions_pkey PRIMARY KEY (id);


--
-- Name: question_choices question_choices_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_choices
    ADD CONSTRAINT question_choices_pkey PRIMARY KEY (id);


--
-- Name: question_tag_map question_tag_map_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_tag_map
    ADD CONSTRAINT question_tag_map_pkey PRIMARY KEY (question_id, tag_id);


--
-- Name: question_tags question_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_tags
    ADD CONSTRAINT question_tags_pkey PRIMARY KEY (question_id, tag_id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: quiz_session_questions quiz_session_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.quiz_session_questions
    ADD CONSTRAINT quiz_session_questions_pkey PRIMARY KEY (session_id, question_id);


--
-- Name: quiz_sessions quiz_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: session_results session_results_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.session_results
    ADD CONSTRAINT session_results_pkey PRIMARY KEY (session_id, user_id);


--
-- Name: tags tags_name_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_name_key UNIQUE (name);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: teacher_navigation_state teacher_navigation_state_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.teacher_navigation_state
    ADD CONSTRAINT teacher_navigation_state_pkey PRIMARY KEY (session_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_answers_session_question; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_answers_session_question ON public.answers USING btree (session_id, question_id);


--
-- Name: idx_classroom_members_user; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_classroom_members_user ON public.classroom_members USING btree (user_id);


--
-- Name: idx_classrooms_created_by; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_classrooms_created_by ON public.classrooms USING btree (created_by);


--
-- Name: idx_memory_game_sessions_status; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_memory_game_sessions_status ON public.memory_game_sessions USING btree (status);


--
-- Name: idx_question_choices_question; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_question_choices_question ON public.question_choices USING btree (question_id);


--
-- Name: idx_question_tags_tag; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_question_tags_tag ON public.question_tags USING btree (tag_id);


--
-- Name: idx_questions_difficulty; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_questions_difficulty ON public.questions USING btree (difficulty);


--
-- Name: idx_questions_type; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_questions_type ON public.questions USING btree (question_type);


--
-- Name: idx_quiz_sessions_classroom; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_quiz_sessions_classroom ON public.quiz_sessions USING btree (classroom_id);


--
-- Name: idx_quiz_sessions_status; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_quiz_sessions_status ON public.quiz_sessions USING btree (status);


--
-- Name: idx_session_results_session; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_session_results_session ON public.session_results USING btree (session_id);


--
-- Name: idx_users_role_id; Type: INDEX; Schema: public; Owner: appuser
--

CREATE INDEX idx_users_role_id ON public.users USING btree (role_id);


--
-- Name: uq_question_choices_position; Type: INDEX; Schema: public; Owner: appuser
--

CREATE UNIQUE INDEX uq_question_choices_position ON public.question_choices USING btree (question_id, "position");


--
-- Name: uq_session_question_position; Type: INDEX; Schema: public; Owner: appuser
--

CREATE UNIQUE INDEX uq_session_question_position ON public.quiz_session_questions USING btree (session_id, "position");


--
-- Name: classrooms trg_classrooms_updated_at; Type: TRIGGER; Schema: public; Owner: appuser
--

CREATE TRIGGER trg_classrooms_updated_at BEFORE UPDATE ON public.classrooms FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: questions trg_questions_updated_at; Type: TRIGGER; Schema: public; Owner: appuser
--

CREATE TRIGGER trg_questions_updated_at BEFORE UPDATE ON public.questions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: teacher_navigation_state trg_teacher_navigation_state_updated_at; Type: TRIGGER; Schema: public; Owner: appuser
--

CREATE TRIGGER trg_teacher_navigation_state_updated_at BEFORE UPDATE ON public.teacher_navigation_state FOR EACH ROW EXECUTE FUNCTION public.touch_nav_updated_at();


--
-- Name: users trg_users_updated_at; Type: TRIGGER; Schema: public; Owner: appuser
--

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: answers answers_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE RESTRICT;


--
-- Name: answers answers_selected_choice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_selected_choice_id_fkey FOREIGN KEY (selected_choice_id) REFERENCES public.question_choices(id) ON DELETE SET NULL;


--
-- Name: answers answers_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.quiz_sessions(id) ON DELETE CASCADE;


--
-- Name: answers answers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: classroom_members classroom_members_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classroom_members
    ADD CONSTRAINT classroom_members_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE CASCADE;


--
-- Name: classroom_members classroom_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classroom_members
    ADD CONSTRAINT classroom_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: classroom_students classroom_students_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classroom_students
    ADD CONSTRAINT classroom_students_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE CASCADE;


--
-- Name: classroom_students classroom_students_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classroom_students
    ADD CONSTRAINT classroom_students_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: classrooms classrooms_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.classrooms
    ADD CONSTRAINT classrooms_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: memory_game_moves memory_game_moves_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_moves
    ADD CONSTRAINT memory_game_moves_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.memory_game_sessions(id) ON DELETE CASCADE;


--
-- Name: memory_game_moves memory_game_moves_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_moves
    ADD CONSTRAINT memory_game_moves_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: memory_game_pairs memory_game_pairs_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_pairs
    ADD CONSTRAINT memory_game_pairs_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.memory_game_sessions(id) ON DELETE CASCADE;


--
-- Name: memory_game_sessions memory_game_sessions_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_sessions
    ADD CONSTRAINT memory_game_sessions_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE SET NULL;


--
-- Name: memory_game_sessions memory_game_sessions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.memory_game_sessions
    ADD CONSTRAINT memory_game_sessions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: question_choices question_choices_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_choices
    ADD CONSTRAINT question_choices_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: question_tag_map question_tag_map_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_tag_map
    ADD CONSTRAINT question_tag_map_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: question_tag_map question_tag_map_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_tag_map
    ADD CONSTRAINT question_tag_map_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: question_tags question_tags_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_tags
    ADD CONSTRAINT question_tags_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- Name: question_tags question_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.question_tags
    ADD CONSTRAINT question_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: questions questions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: quiz_session_questions quiz_session_questions_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.quiz_session_questions
    ADD CONSTRAINT quiz_session_questions_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE RESTRICT;


--
-- Name: quiz_session_questions quiz_session_questions_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.quiz_session_questions
    ADD CONSTRAINT quiz_session_questions_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.quiz_sessions(id) ON DELETE CASCADE;


--
-- Name: quiz_sessions quiz_sessions_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES public.classrooms(id) ON DELETE SET NULL;


--
-- Name: quiz_sessions quiz_sessions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: session_results session_results_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.session_results
    ADD CONSTRAINT session_results_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.quiz_sessions(id) ON DELETE CASCADE;


--
-- Name: session_results session_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.session_results
    ADD CONSTRAINT session_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: teacher_navigation_state teacher_navigation_state_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.teacher_navigation_state
    ADD CONSTRAINT teacher_navigation_state_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.quiz_sessions(id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: appuser
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: DATABASE myapp; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE myapp TO appuser;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO appuser;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea) TO appuser;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO appuser;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.crypt(text, text) TO appuser;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dearmor(text) TO appuser;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(bytea, text) TO appuser;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(text, text) TO appuser;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO appuser;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_uuid() TO appuser;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text) TO appuser;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO appuser;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(text, text, text) TO appuser;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO appuser;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO appuser;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO appuser;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TYPES TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO appuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO appuser;


--
-- PostgreSQL database dump complete
--

\unrestrict yhFK7RJuzNWCD0ZwXysP1YRcBoZzW6tHkZ4zMiZbOaaHdu0pDrAacIQvlwxEjKm

