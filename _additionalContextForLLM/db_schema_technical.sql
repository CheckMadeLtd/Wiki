--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Homebrew)
-- Dumped by pg_dump version 16.9 (Homebrew)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agent_role_bindings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_role_bindings (
    id integer NOT NULL,
    role_id integer NOT NULL,
    user_id bigint NOT NULL,
    chat_id bigint NOT NULL,
    status smallint NOT NULL,
    interaction_mode smallint NOT NULL,
    activation_date timestamp with time zone NOT NULL,
    deactivation_date timestamp with time zone
);


--
-- Name: agent_role_bindings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.agent_role_bindings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agent_role_bindings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.agent_role_bindings_id_seq OWNED BY public.agent_role_bindings.id;


--
-- Name: derived_workflow_bridges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.derived_workflow_bridges (
    id integer NOT NULL,
    src_input_id integer NOT NULL,
    dst_chat_id bigint NOT NULL,
    dst_message_id integer NOT NULL
);


--
-- Name: derived_workflow_bridges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.derived_workflow_bridges_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: derived_workflow_bridges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.derived_workflow_bridges_id_seq OWNED BY public.derived_workflow_bridges.id;


--
-- Name: derived_workflow_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.derived_workflow_states (
    id integer NOT NULL,
    resultant_workflow character varying(6) NOT NULL,
    inputs_id integer,
    in_state character varying(6) NOT NULL
);


--
-- Name: derived_workflow_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.derived_workflow_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: derived_workflow_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.derived_workflow_states_id_seq OWNED BY public.derived_workflow_states.id;


--
-- Name: inputs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inputs (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    details jsonb NOT NULL,
    chat_id bigint NOT NULL,
    interaction_mode smallint NOT NULL,
    input_type smallint NOT NULL,
    role_id integer,
    live_event_id integer,
    workflow_guid uuid,
    message_id integer NOT NULL,
    date timestamp with time zone NOT NULL
);


--
-- Name: inputs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inputs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inputs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inputs_id_seq OWNED BY public.inputs.id;


--
-- Name: live_event_series; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.live_event_series (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    status smallint NOT NULL
);


--
-- Name: live_event_series_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.live_event_series_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: live_event_series_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.live_event_series_id_seq OWNED BY public.live_event_series.id;


--
-- Name: live_event_venues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.live_event_venues (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    status smallint NOT NULL
);


--
-- Name: live_event_venues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.live_event_venues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: live_event_venues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.live_event_venues_id_seq OWNED BY public.live_event_venues.id;


--
-- Name: live_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.live_events (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    venue_id integer NOT NULL,
    live_event_series_id integer NOT NULL,
    status smallint NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL
);


--
-- Name: live_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.live_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: live_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.live_events_id_seq OWNED BY public.live_events.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    token character varying(6) NOT NULL,
    status smallint NOT NULL,
    user_id integer NOT NULL,
    live_event_id integer NOT NULL,
    role_type character varying(6) NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: roles_to_spheres_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles_to_spheres_assignments (
    id integer NOT NULL,
    role_id integer NOT NULL,
    sphere_id integer NOT NULL,
    assigned_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    unassigned_date timestamp with time zone,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    status smallint NOT NULL,
    CONSTRAINT roles_to_spheres_assignments_check CHECK ((((status <> 1) AND (unassigned_date IS NOT NULL)) OR ((status = 1) AND (unassigned_date IS NULL))))
);


--
-- Name: roles_to_spheres_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_to_spheres_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_to_spheres_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_to_spheres_assignments_id_seq OWNED BY public.roles_to_spheres_assignments.id;


--
-- Name: spheres_of_action; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spheres_of_action (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    trade character varying(6) NOT NULL,
    live_event_id integer NOT NULL,
    details jsonb NOT NULL,
    status smallint NOT NULL
);


--
-- Name: spheres_of_action_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.spheres_of_action_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: spheres_of_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.spheres_of_action_id_seq OWNED BY public.spheres_of_action.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    mobile character varying(20) NOT NULL,
    first_name character varying(255) NOT NULL,
    middle_name character varying(255),
    last_name character varying(255) NOT NULL,
    email character varying(255),
    status smallint NOT NULL,
    language_setting smallint DEFAULT 0 NOT NULL,
    details jsonb NOT NULL
);


--
-- Name: users_employment_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_employment_history (
    id integer NOT NULL,
    user_id integer NOT NULL,
    vendor_id integer NOT NULL,
    details jsonb NOT NULL,
    status smallint NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone
);


--
-- Name: users_employment_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_employment_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_employment_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_employment_history_id_seq OWNED BY public.users_employment_history.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vendors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendors (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    details jsonb NOT NULL,
    status smallint NOT NULL
);


--
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vendors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vendors_id_seq OWNED BY public.vendors.id;


--
-- Name: agent_role_bindings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_role_bindings ALTER COLUMN id SET DEFAULT nextval('public.agent_role_bindings_id_seq'::regclass);


--
-- Name: derived_workflow_bridges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.derived_workflow_bridges ALTER COLUMN id SET DEFAULT nextval('public.derived_workflow_bridges_id_seq'::regclass);


--
-- Name: derived_workflow_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.derived_workflow_states ALTER COLUMN id SET DEFAULT nextval('public.derived_workflow_states_id_seq'::regclass);


--
-- Name: inputs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inputs ALTER COLUMN id SET DEFAULT nextval('public.inputs_id_seq'::regclass);


--
-- Name: live_event_series id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_event_series ALTER COLUMN id SET DEFAULT nextval('public.live_event_series_id_seq'::regclass);


--
-- Name: live_event_venues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_event_venues ALTER COLUMN id SET DEFAULT nextval('public.live_event_venues_id_seq'::regclass);


--
-- Name: live_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_events ALTER COLUMN id SET DEFAULT nextval('public.live_events_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: roles_to_spheres_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_to_spheres_assignments ALTER COLUMN id SET DEFAULT nextval('public.roles_to_spheres_assignments_id_seq'::regclass);


--
-- Name: spheres_of_action id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spheres_of_action ALTER COLUMN id SET DEFAULT nextval('public.spheres_of_action_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_employment_history id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_employment_history ALTER COLUMN id SET DEFAULT nextval('public.users_employment_history_id_seq'::regclass);


--
-- Name: vendors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors ALTER COLUMN id SET DEFAULT nextval('public.vendors_id_seq'::regclass);


--
-- Name: agent_role_bindings agent_role_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_role_bindings
    ADD CONSTRAINT agent_role_bindings_pkey PRIMARY KEY (id);


--
-- Name: derived_workflow_bridges derived_workflow_bridges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.derived_workflow_bridges
    ADD CONSTRAINT derived_workflow_bridges_pkey PRIMARY KEY (id);


--
-- Name: derived_workflow_states derived_workflow_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.derived_workflow_states
    ADD CONSTRAINT derived_workflow_states_pkey PRIMARY KEY (id);


--
-- Name: inputs inputs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inputs
    ADD CONSTRAINT inputs_pkey PRIMARY KEY (id);


--
-- Name: live_event_series live_event_series_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_event_series
    ADD CONSTRAINT live_event_series_name_key UNIQUE (name);


--
-- Name: live_event_series live_event_series_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_event_series
    ADD CONSTRAINT live_event_series_pkey PRIMARY KEY (id);


--
-- Name: live_event_venues live_event_venues_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_event_venues
    ADD CONSTRAINT live_event_venues_name_key UNIQUE (name);


--
-- Name: live_event_venues live_event_venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_event_venues
    ADD CONSTRAINT live_event_venues_pkey PRIMARY KEY (id);


--
-- Name: live_events live_events_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_events
    ADD CONSTRAINT live_events_name_key UNIQUE (name);


--
-- Name: live_events live_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_events
    ADD CONSTRAINT live_events_pkey PRIMARY KEY (id);


--
-- Name: derived_workflow_bridges logical_unique_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.derived_workflow_bridges
    ADD CONSTRAINT logical_unique_constraint UNIQUE (dst_chat_id, dst_message_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles_to_spheres_assignments roles_to_spheres_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_to_spheres_assignments
    ADD CONSTRAINT roles_to_spheres_assignments_pkey PRIMARY KEY (id);


--
-- Name: spheres_of_action spheres_of_action_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spheres_of_action
    ADD CONSTRAINT spheres_of_action_pkey PRIMARY KEY (id);


--
-- Name: roles token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT token_unique UNIQUE (token);


--
-- Name: users_employment_history users_employment_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_employment_history
    ADD CONSTRAINT users_employment_history_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendors vendors_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_name_key UNIQUE (name);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: agent_role_bindings_role_user_chat_mode_when_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX agent_role_bindings_role_user_chat_mode_when_active ON public.agent_role_bindings USING btree (role_id, user_id, chat_id, interaction_mode) WHERE (status = 1);


--
-- Name: idx_roles_live_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_roles_live_event_id ON public.roles USING btree (live_event_id);


--
-- Name: inputs_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inputs_user_id ON public.inputs USING btree (user_id);


--
-- Name: inputs_workflow_guid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX inputs_workflow_guid ON public.inputs USING btree (workflow_guid);


--
-- Name: roles_to_spheres_role_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roles_to_spheres_role_idx ON public.roles_to_spheres_assignments USING btree (role_id);


--
-- Name: roles_to_spheres_sphere_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX roles_to_spheres_sphere_idx ON public.roles_to_spheres_assignments USING btree (sphere_id);


--
-- Name: roles_to_spheres_unique_when_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roles_to_spheres_unique_when_active ON public.roles_to_spheres_assignments USING btree (role_id, sphere_id) WHERE (status = 1);


--
-- Name: roles_type_user_live_event_when_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX roles_type_user_live_event_when_active ON public.roles USING btree (role_type, user_id, live_event_id) WHERE (status = 1);


--
-- Name: spheres_of_action_live_event_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX spheres_of_action_live_event_name ON public.spheres_of_action USING btree (live_event_id, name);


--
-- Name: users_employment_history_user_vendor_when_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_employment_history_user_vendor_when_active ON public.users_employment_history USING btree (user_id, vendor_id) WHERE (status = 1);


--
-- Name: users_mobile_key_when_active; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_mobile_key_when_active ON public.users USING btree (mobile) WHERE (status = 1);


--
-- Name: agent_role_bindings agent_role_bindings_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_role_bindings
    ADD CONSTRAINT agent_role_bindings_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: derived_workflow_bridges derived_workflow_bridges_src_input_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.derived_workflow_bridges
    ADD CONSTRAINT derived_workflow_bridges_src_input_id_fkey FOREIGN KEY (src_input_id) REFERENCES public.inputs(id);


--
-- Name: derived_workflow_states derived_workflow_states_inputs_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.derived_workflow_states
    ADD CONSTRAINT derived_workflow_states_inputs_id_fkey FOREIGN KEY (inputs_id) REFERENCES public.inputs(id);


--
-- Name: inputs inputs_live_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inputs
    ADD CONSTRAINT inputs_live_event_id_fkey FOREIGN KEY (live_event_id) REFERENCES public.live_events(id);


--
-- Name: inputs inputs_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inputs
    ADD CONSTRAINT inputs_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: live_events live_events_live_event_series_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_events
    ADD CONSTRAINT live_events_live_event_series_id_fkey FOREIGN KEY (live_event_series_id) REFERENCES public.live_event_series(id);


--
-- Name: live_events live_events_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_events
    ADD CONSTRAINT live_events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.live_event_venues(id);


--
-- Name: roles roles_live_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_live_event_id_fkey FOREIGN KEY (live_event_id) REFERENCES public.live_events(id);


--
-- Name: roles_to_spheres_assignments roles_to_spheres_assignments_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_to_spheres_assignments
    ADD CONSTRAINT roles_to_spheres_assignments_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: roles_to_spheres_assignments roles_to_spheres_assignments_sphere_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles_to_spheres_assignments
    ADD CONSTRAINT roles_to_spheres_assignments_sphere_id_fkey FOREIGN KEY (sphere_id) REFERENCES public.spheres_of_action(id);


--
-- Name: roles roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: spheres_of_action spheres_of_action_live_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spheres_of_action
    ADD CONSTRAINT spheres_of_action_live_event_id_fkey FOREIGN KEY (live_event_id) REFERENCES public.live_events(id);


--
-- Name: users_employment_history users_employment_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_employment_history
    ADD CONSTRAINT users_employment_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users_employment_history users_employment_history_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_employment_history
    ADD CONSTRAINT users_employment_history_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id);


--
-- Name: TABLE agent_role_bindings; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.agent_role_bindings TO cmappuser;


--
-- Name: SEQUENCE agent_role_bindings_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.agent_role_bindings_id_seq TO cmappuser;


--
-- Name: TABLE derived_workflow_bridges; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.derived_workflow_bridges TO cmappuser;


--
-- Name: SEQUENCE derived_workflow_bridges_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.derived_workflow_bridges_id_seq TO cmappuser;


--
-- Name: TABLE derived_workflow_states; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.derived_workflow_states TO cmappuser;


--
-- Name: SEQUENCE derived_workflow_states_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.derived_workflow_states_id_seq TO cmappuser;


--
-- Name: TABLE inputs; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inputs TO cmappuser;


--
-- Name: SEQUENCE inputs_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.inputs_id_seq TO cmappuser;


--
-- Name: TABLE live_event_series; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.live_event_series TO cmappuser;


--
-- Name: SEQUENCE live_event_series_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.live_event_series_id_seq TO cmappuser;


--
-- Name: TABLE live_event_venues; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.live_event_venues TO cmappuser;


--
-- Name: SEQUENCE live_event_venues_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.live_event_venues_id_seq TO cmappuser;


--
-- Name: TABLE live_events; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.live_events TO cmappuser;


--
-- Name: SEQUENCE live_events_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.live_events_id_seq TO cmappuser;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.roles TO cmappuser;


--
-- Name: SEQUENCE roles_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.roles_id_seq TO cmappuser;


--
-- Name: TABLE roles_to_spheres_assignments; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.roles_to_spheres_assignments TO cmappuser;


--
-- Name: SEQUENCE roles_to_spheres_assignments_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.roles_to_spheres_assignments_id_seq TO cmappuser;


--
-- Name: TABLE spheres_of_action; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.spheres_of_action TO cmappuser;


--
-- Name: SEQUENCE spheres_of_action_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.spheres_of_action_id_seq TO cmappuser;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users TO cmappuser;


--
-- Name: TABLE users_employment_history; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.users_employment_history TO cmappuser;


--
-- Name: SEQUENCE users_employment_history_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.users_employment_history_id_seq TO cmappuser;


--
-- Name: SEQUENCE users_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.users_id_seq TO cmappuser;


--
-- Name: TABLE vendors; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vendors TO cmappuser;


--
-- Name: SEQUENCE vendors_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.vendors_id_seq TO cmappuser;


--
-- PostgreSQL database dump complete
--

