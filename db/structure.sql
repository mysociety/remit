--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: dissemination_category_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE dissemination_category_type AS ENUM (
    'internal',
    'external'
);


--
-- Name: study_stage; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE study_stage AS ENUM (
    'concept',
    'protocol_erb',
    'delivery',
    'output',
    'completion',
    'withdrawn_postponed'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    namespace character varying,
    body text,
    resource_id character varying NOT NULL,
    resource_type character varying NOT NULL,
    author_id integer,
    author_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE activities (
    id integer NOT NULL,
    trackable_id integer,
    trackable_type character varying,
    owner_id integer,
    owner_type character varying,
    key character varying,
    parameters text,
    recipient_id integer,
    recipient_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE activities_id_seq OWNED BY activities.id;


--
-- Name: dissemination_categories; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE dissemination_categories (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    dissemination_category_type dissemination_category_type NOT NULL
);


--
-- Name: dissemination_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dissemination_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dissemination_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dissemination_categories_id_seq OWNED BY dissemination_categories.id;


--
-- Name: disseminations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE disseminations (
    id integer NOT NULL,
    dissemination_category_id integer NOT NULL,
    study_id integer NOT NULL,
    details text NOT NULL,
    fed_back_to_field boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_dissemination_category text
);


--
-- Name: disseminations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE disseminations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disseminations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE disseminations_id_seq OWNED BY disseminations.id;


--
-- Name: document_types; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE document_types (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: document_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE document_types_id_seq OWNED BY document_types.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE documents (
    id integer NOT NULL,
    document_type_id integer NOT NULL,
    study_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: enabler_barriers; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE enabler_barriers (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: enabler_barriers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE enabler_barriers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enabler_barriers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE enabler_barriers_id_seq OWNED BY enabler_barriers.id;


--
-- Name: erb_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE erb_statuses (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: erb_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE erb_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: erb_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE erb_statuses_id_seq OWNED BY erb_statuses.id;


--
-- Name: impact_types; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE impact_types (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: impact_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE impact_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: impact_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE impact_types_id_seq OWNED BY impact_types.id;


--
-- Name: msf_locations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE msf_locations (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: msf_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE msf_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: msf_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE msf_locations_id_seq OWNED BY msf_locations.id;


--
-- Name: publications; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE publications (
    id integer NOT NULL,
    study_id integer,
    doi_number text,
    lead_author text NOT NULL,
    article_title text NOT NULL,
    book_or_journal_title text NOT NULL,
    publication_year integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE publications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE publications_id_seq OWNED BY publications.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: studies; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE studies (
    id integer NOT NULL,
    title text NOT NULL,
    reference_number text NOT NULL,
    study_type_id integer NOT NULL,
    study_setting_id integer NOT NULL,
    research_team text,
    concept_paper_date date NOT NULL,
    protocol_needed boolean NOT NULL,
    pre_approved_protocol boolean,
    erb_status_id integer,
    erb_reference text,
    erb_approval_expiry date,
    local_erb_submitted date,
    local_erb_approved date,
    completed date,
    local_collaborators text,
    international_collaborators text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_study_type text,
    principal_investigator_id integer,
    research_manager_id integer,
    country_code text,
    feedback_and_suggestions text,
    study_topic_id integer NOT NULL,
    study_stage study_stage DEFAULT 'concept'::study_stage NOT NULL
);


--
-- Name: studies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE studies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: studies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE studies_id_seq OWNED BY studies.id;


--
-- Name: study_enabler_barriers; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE study_enabler_barriers (
    id integer NOT NULL,
    study_id integer NOT NULL,
    enabler_barrier_id integer NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_enabler_barriers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_enabler_barriers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_enabler_barriers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_enabler_barriers_id_seq OWNED BY study_enabler_barriers.id;


--
-- Name: study_impacts; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE study_impacts (
    id integer NOT NULL,
    study_id integer NOT NULL,
    impact_type_id integer NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_impacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_impacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_impacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_impacts_id_seq OWNED BY study_impacts.id;


--
-- Name: study_notes; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE study_notes (
    id integer NOT NULL,
    notes text NOT NULL,
    study_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_notes_id_seq OWNED BY study_notes.id;


--
-- Name: study_settings; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE study_settings (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: study_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_settings_id_seq OWNED BY study_settings.id;


--
-- Name: study_topics; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE study_topics (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: study_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_topics_id_seq OWNED BY study_topics.id;


--
-- Name: study_types; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE study_types (
    id integer NOT NULL,
    name text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: study_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE study_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE study_types_id_seq OWNED BY study_types.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name text NOT NULL,
    msf_location_id integer,
    external_location text,
    is_admin boolean DEFAULT false NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY activities ALTER COLUMN id SET DEFAULT nextval('activities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dissemination_categories ALTER COLUMN id SET DEFAULT nextval('dissemination_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY disseminations ALTER COLUMN id SET DEFAULT nextval('disseminations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY document_types ALTER COLUMN id SET DEFAULT nextval('document_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY enabler_barriers ALTER COLUMN id SET DEFAULT nextval('enabler_barriers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY erb_statuses ALTER COLUMN id SET DEFAULT nextval('erb_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY impact_types ALTER COLUMN id SET DEFAULT nextval('impact_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY msf_locations ALTER COLUMN id SET DEFAULT nextval('msf_locations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY publications ALTER COLUMN id SET DEFAULT nextval('publications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies ALTER COLUMN id SET DEFAULT nextval('studies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_enabler_barriers ALTER COLUMN id SET DEFAULT nextval('study_enabler_barriers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_impacts ALTER COLUMN id SET DEFAULT nextval('study_impacts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_notes ALTER COLUMN id SET DEFAULT nextval('study_notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_settings ALTER COLUMN id SET DEFAULT nextval('study_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_topics ALTER COLUMN id SET DEFAULT nextval('study_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_types ALTER COLUMN id SET DEFAULT nextval('study_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: dissemination_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY dissemination_categories
    ADD CONSTRAINT dissemination_categories_pkey PRIMARY KEY (id);


--
-- Name: disseminations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY disseminations
    ADD CONSTRAINT disseminations_pkey PRIMARY KEY (id);


--
-- Name: document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: enabler_barriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY enabler_barriers
    ADD CONSTRAINT enabler_barriers_pkey PRIMARY KEY (id);


--
-- Name: erb_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY erb_statuses
    ADD CONSTRAINT erb_statuses_pkey PRIMARY KEY (id);


--
-- Name: impact_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY impact_types
    ADD CONSTRAINT impact_types_pkey PRIMARY KEY (id);


--
-- Name: msf_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY msf_locations
    ADD CONSTRAINT msf_locations_pkey PRIMARY KEY (id);


--
-- Name: publications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: studies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT studies_pkey PRIMARY KEY (id);


--
-- Name: study_enabler_barriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY study_enabler_barriers
    ADD CONSTRAINT study_enabler_barriers_pkey PRIMARY KEY (id);


--
-- Name: study_impacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY study_impacts
    ADD CONSTRAINT study_impacts_pkey PRIMARY KEY (id);


--
-- Name: study_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY study_notes
    ADD CONSTRAINT study_notes_pkey PRIMARY KEY (id);


--
-- Name: study_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY study_settings
    ADD CONSTRAINT study_settings_pkey PRIMARY KEY (id);


--
-- Name: study_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY study_topics
    ADD CONSTRAINT study_topics_pkey PRIMARY KEY (id);


--
-- Name: study_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY study_types
    ADD CONSTRAINT study_types_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_activities_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_activities_on_owner_id_and_owner_type ON activities USING btree (owner_id, owner_type);


--
-- Name: index_activities_on_recipient_id_and_recipient_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_activities_on_recipient_id_and_recipient_type ON activities USING btree (recipient_id, recipient_type);


--
-- Name: index_activities_on_trackable_id_and_trackable_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_activities_on_trackable_id_and_trackable_type ON activities USING btree (trackable_id, trackable_type);


--
-- Name: index_dissemination_categories_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_dissemination_categories_on_name ON dissemination_categories USING btree (name);


--
-- Name: index_disseminations_on_dissemination_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_disseminations_on_dissemination_category_id ON disseminations USING btree (dissemination_category_id);


--
-- Name: index_disseminations_on_study_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_disseminations_on_study_id ON disseminations USING btree (study_id);


--
-- Name: index_document_types_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_document_types_on_name ON document_types USING btree (name);


--
-- Name: index_documents_on_document_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_documents_on_document_type_id ON documents USING btree (document_type_id);


--
-- Name: index_documents_on_study_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_documents_on_study_id ON documents USING btree (study_id);


--
-- Name: index_enabler_barriers_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_enabler_barriers_on_name ON enabler_barriers USING btree (name);


--
-- Name: index_erb_statuses_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_erb_statuses_on_name ON erb_statuses USING btree (name);


--
-- Name: index_impact_types_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_impact_types_on_name ON impact_types USING btree (name);


--
-- Name: index_msf_locations_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_msf_locations_on_name ON msf_locations USING btree (name);


--
-- Name: index_publications_on_study_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_publications_on_study_id ON publications USING btree (study_id);


--
-- Name: index_studies_on_erb_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_studies_on_erb_status_id ON studies USING btree (erb_status_id);


--
-- Name: index_studies_on_principal_investigator_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_studies_on_principal_investigator_id ON studies USING btree (principal_investigator_id);


--
-- Name: index_studies_on_research_manager_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_studies_on_research_manager_id ON studies USING btree (research_manager_id);


--
-- Name: index_studies_on_study_setting_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_studies_on_study_setting_id ON studies USING btree (study_setting_id);


--
-- Name: index_studies_on_study_topic_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_studies_on_study_topic_id ON studies USING btree (study_topic_id);


--
-- Name: index_studies_on_study_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_studies_on_study_type_id ON studies USING btree (study_type_id);


--
-- Name: index_study_enabler_barriers_on_enabler_barrier_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_study_enabler_barriers_on_enabler_barrier_id ON study_enabler_barriers USING btree (enabler_barrier_id);


--
-- Name: index_study_enabler_barriers_on_study_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_study_enabler_barriers_on_study_id ON study_enabler_barriers USING btree (study_id);


--
-- Name: index_study_impacts_on_impact_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_study_impacts_on_impact_type_id ON study_impacts USING btree (impact_type_id);


--
-- Name: index_study_impacts_on_study_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_study_impacts_on_study_id ON study_impacts USING btree (study_id);


--
-- Name: index_study_notes_on_study_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_study_notes_on_study_id ON study_notes USING btree (study_id);


--
-- Name: index_study_settings_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_study_settings_on_name ON study_settings USING btree (name);


--
-- Name: index_study_topics_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_study_topics_on_name ON study_topics USING btree (name);


--
-- Name: index_study_types_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_study_types_on_name ON study_types USING btree (name);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_msf_location_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_users_on_msf_location_id ON users USING btree (msf_location_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_03e5ee9cba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_03e5ee9cba FOREIGN KEY (msf_location_id) REFERENCES msf_locations(id);


--
-- Name: fk_rails_0e2a1a9789; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT fk_rails_0e2a1a9789 FOREIGN KEY (study_id) REFERENCES studies(id);


--
-- Name: fk_rails_2cbe0621cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disseminations
    ADD CONSTRAINT fk_rails_2cbe0621cc FOREIGN KEY (dissemination_category_id) REFERENCES dissemination_categories(id);


--
-- Name: fk_rails_467a05ce2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_notes
    ADD CONSTRAINT fk_rails_467a05ce2c FOREIGN KEY (study_id) REFERENCES studies(id);


--
-- Name: fk_rails_529dd6c0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT fk_rails_529dd6c0d7 FOREIGN KEY (principal_investigator_id) REFERENCES users(id);


--
-- Name: fk_rails_656a38bbd9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_impacts
    ADD CONSTRAINT fk_rails_656a38bbd9 FOREIGN KEY (impact_type_id) REFERENCES impact_types(id);


--
-- Name: fk_rails_7c525ebb16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT fk_rails_7c525ebb16 FOREIGN KEY (study_topic_id) REFERENCES study_topics(id);


--
-- Name: fk_rails_81b054efe8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_enabler_barriers
    ADD CONSTRAINT fk_rails_81b054efe8 FOREIGN KEY (enabler_barrier_id) REFERENCES enabler_barriers(id);


--
-- Name: fk_rails_84b1d4daed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_impacts
    ADD CONSTRAINT fk_rails_84b1d4daed FOREIGN KEY (study_id) REFERENCES studies(id);


--
-- Name: fk_rails_99700bf9f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT fk_rails_99700bf9f1 FOREIGN KEY (research_manager_id) REFERENCES users(id);


--
-- Name: fk_rails_b2c97bc5e8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY disseminations
    ADD CONSTRAINT fk_rails_b2c97bc5e8 FOREIGN KEY (study_id) REFERENCES studies(id);


--
-- Name: fk_rails_c0b00bc50e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT fk_rails_c0b00bc50e FOREIGN KEY (erb_status_id) REFERENCES erb_statuses(id);


--
-- Name: fk_rails_c6a7362db2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT fk_rails_c6a7362db2 FOREIGN KEY (study_setting_id) REFERENCES study_settings(id);


--
-- Name: fk_rails_dc8ad7f727; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY studies
    ADD CONSTRAINT fk_rails_dc8ad7f727 FOREIGN KEY (study_type_id) REFERENCES study_types(id);


--
-- Name: fk_rails_e77e122717; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT fk_rails_e77e122717 FOREIGN KEY (document_type_id) REFERENCES document_types(id);


--
-- Name: fk_rails_eb4617db9d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY study_enabler_barriers
    ADD CONSTRAINT fk_rails_eb4617db9d FOREIGN KEY (study_id) REFERENCES studies(id);


--
-- Name: fk_rails_fd8844a90c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY publications
    ADD CONSTRAINT fk_rails_fd8844a90c FOREIGN KEY (study_id) REFERENCES studies(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20160108112933');

INSERT INTO schema_migrations (version) VALUES ('20160114173551');

INSERT INTO schema_migrations (version) VALUES ('20160114175311');

INSERT INTO schema_migrations (version) VALUES ('20160119150601');

INSERT INTO schema_migrations (version) VALUES ('20160121123326');

INSERT INTO schema_migrations (version) VALUES ('20160122111240');

