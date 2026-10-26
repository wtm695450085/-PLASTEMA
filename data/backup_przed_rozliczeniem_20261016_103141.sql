--
-- PostgreSQL database dump
--

\restrict iNhExvhcFNsL1hwuBiW4odYzVBNyNqJpZbneTQ43PvQo1taJploJxIgrzjqeGGP

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- Name: app_settings; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.app_settings (
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.app_settings OWNER TO magazyn_app;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.clients (
    id bigint NOT NULL,
    code character(3) NOT NULL,
    short_name text NOT NULL,
    name text NOT NULL,
    industry text,
    contact_person text,
    contact_position text,
    phone text,
    phone_central text,
    email text,
    website text,
    street text,
    postal_code text,
    city text,
    voivodeship text,
    nip text,
    regon text,
    krs text,
    iban text,
    since date,
    data_status text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT clients_code_check CHECK ((code ~ '^[0-9]{3}$'::text))
);


ALTER TABLE public.clients OWNER TO magazyn_app;

--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clients_id_seq OWNER TO magazyn_app;

--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: colors; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.colors (
    id bigint NOT NULL,
    code character(3) NOT NULL,
    name text NOT NULL,
    notes text,
    CONSTRAINT colors_code_check CHECK ((code ~ '^[0-9]{3}$'::text))
);


ALTER TABLE public.colors OWNER TO magazyn_app;

--
-- Name: colors_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.colors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.colors_id_seq OWNER TO magazyn_app;

--
-- Name: colors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.colors_id_seq OWNED BY public.colors.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    supplier_id bigint NOT NULL,
    contact_name text,
    phone text,
    email text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    "position" text,
    CONSTRAINT contacts_contact_required CHECK (((NULLIF(contact_name, (chr(39) || chr(39))) IS NOT NULL) OR (NULLIF(phone, (chr(39) || chr(39))) IS NOT NULL) OR (NULLIF(email, (chr(39) || chr(39))) IS NOT NULL) OR (NULLIF("position", (chr(39) || chr(39))) IS NOT NULL) OR (NULLIF(notes, (chr(39) || chr(39))) IS NOT NULL)))
);


ALTER TABLE public.contacts OWNER TO magazyn_app;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contacts_id_seq OWNER TO magazyn_app;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: inventories; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.inventories (
    id bigint NOT NULL,
    number text NOT NULL,
    count_date date NOT NULL,
    scope text DEFAULT 'ALL'::text NOT NULL,
    status text DEFAULT 'OTWARTA'::text NOT NULL,
    counted_by text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    approved_at timestamp with time zone
);


ALTER TABLE public.inventories OWNER TO magazyn_app;

--
-- Name: inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.inventories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventories_id_seq OWNER TO magazyn_app;

--
-- Name: inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.inventories_id_seq OWNED BY public.inventories.id;


--
-- Name: inventory_lines; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.inventory_lines (
    id bigint NOT NULL,
    inventory_id bigint NOT NULL,
    material_id bigint NOT NULL,
    expected_kg numeric(14,3),
    counted_kg numeric(14,3),
    unit_price numeric(12,4),
    notes text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    diff_reason text,
    diff_explanation text,
    diff_explained_by text,
    diff_explained_at timestamp with time zone
);


ALTER TABLE public.inventory_lines OWNER TO magazyn_app;

--
-- Name: inventory_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.inventory_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_lines_id_seq OWNER TO magazyn_app;

--
-- Name: inventory_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.inventory_lines_id_seq OWNED BY public.inventory_lines.id;


--
-- Name: machine_doc_lines; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.machine_doc_lines (
    id bigint NOT NULL,
    doc_id bigint NOT NULL,
    material_id bigint NOT NULL,
    qty_kg numeric(14,3) DEFAULT 0 NOT NULL,
    notes text,
    CONSTRAINT machine_doc_lines_qty_kg_check CHECK ((qty_kg >= (0)::numeric))
);


ALTER TABLE public.machine_doc_lines OWNER TO magazyn_app;

--
-- Name: machine_doc_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.machine_doc_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.machine_doc_lines_id_seq OWNER TO magazyn_app;

--
-- Name: machine_doc_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.machine_doc_lines_id_seq OWNED BY public.machine_doc_lines.id;


--
-- Name: machine_docs; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.machine_docs (
    id bigint NOT NULL,
    number text NOT NULL,
    doc_type text NOT NULL,
    machine_id smallint NOT NULL,
    status text DEFAULT 'OTWARTY'::text NOT NULL,
    doc_date date DEFAULT CURRENT_DATE NOT NULL,
    shift text,
    order_ref text,
    reason text,
    notes text,
    created_by text,
    realized_by text,
    realized_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.machine_docs OWNER TO magazyn_app;

--
-- Name: machine_docs_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.machine_docs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.machine_docs_id_seq OWNER TO magazyn_app;

--
-- Name: machine_docs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.machine_docs_id_seq OWNED BY public.machine_docs.id;


--
-- Name: machines; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.machines (
    id smallint NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.machines OWNER TO magazyn_app;

--
-- Name: materials; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.materials (
    id bigint NOT NULL,
    material_index text NOT NULL,
    ordinal integer,
    supplier_id bigint,
    supplier_no text,
    supplier_name text,
    supplier_short_name text,
    material_type text,
    kind text,
    origin_code integer,
    symbol text,
    color text,
    internal_name text,
    unit_price numeric(12,4),
    currency text,
    price_pln numeric(12,4),
    unit text,
    lead_time_days integer,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.materials OWNER TO magazyn_app;

--
-- Name: materials_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.materials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.materials_id_seq OWNER TO magazyn_app;

--
-- Name: materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.materials_id_seq OWNED BY public.materials.id;


--
-- Name: mold_events; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.mold_events (
    id bigint NOT NULL,
    mold_id bigint NOT NULL,
    event_date date DEFAULT CURRENT_DATE NOT NULL,
    event_type text NOT NULL,
    description text,
    performed_by text,
    cost_pln numeric(12,2),
    downtime_h numeric(8,1),
    cycles_at integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.mold_events OWNER TO magazyn_app;

--
-- Name: mold_events_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.mold_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mold_events_id_seq OWNER TO magazyn_app;

--
-- Name: mold_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.mold_events_id_seq OWNED BY public.mold_events.id;


--
-- Name: mold_photos; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.mold_photos (
    id bigint NOT NULL,
    mold_id bigint NOT NULL,
    slot smallint NOT NULL,
    filename text,
    width integer,
    height integer,
    data bytea NOT NULL,
    thumb bytea NOT NULL,
    uploaded_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mold_photos_slot_check CHECK (((slot >= 1) AND (slot <= 7)))
);


ALTER TABLE public.mold_photos OWNER TO magazyn_app;

--
-- Name: mold_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.mold_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mold_photos_id_seq OWNER TO magazyn_app;

--
-- Name: mold_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.mold_photos_id_seq OWNED BY public.mold_photos.id;


--
-- Name: molds; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.molds (
    id bigint NOT NULL,
    mold_no character(3) NOT NULL,
    ordinal integer,
    name text NOT NULL,
    dim_1 numeric(10,1),
    dim_2 numeric(10,1),
    dim_3 numeric(10,1),
    weight_kg numeric(10,1),
    storage text,
    status text DEFAULT 'SPRAWNA'::text NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    client_id bigint,
    owner text,
    maker text,
    drawing_no text,
    inventory_no text,
    made_year integer,
    received_date date,
    value_pln numeric(14,2),
    mold_type text,
    cavities integer,
    runner text,
    hot_zones integer,
    gate_type text,
    slides text,
    ejection text,
    inserts text,
    steel text,
    hardness_hrc text,
    surface text,
    mold_height_mm numeric(14,2),
    opening_stroke_mm numeric(14,2),
    centering_ring_mm numeric(14,2),
    nozzle_radius_mm numeric(14,2),
    clamp_force_t numeric(14,2),
    machines text,
    cooling_circuits integer,
    tool_temp_c text,
    connections text,
    cycle_s numeric(14,2),
    shot_weight_g numeric(14,2),
    material_hint text,
    spi_class text,
    guaranteed_cycles integer,
    initial_cycles integer,
    service_interval_cycles integer,
    CONSTRAINT molds_mold_no_check CHECK ((mold_no ~ '^[0-9]{3}$'::text))
);


ALTER TABLE public.molds OWNER TO magazyn_app;

--
-- Name: molds_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.molds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.molds_id_seq OWNER TO magazyn_app;

--
-- Name: molds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.molds_id_seq OWNED BY public.molds.id;


--
-- Name: order_lines; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.order_lines (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    lp integer DEFAULT 1 NOT NULL,
    product_id bigint,
    product_name text NOT NULL,
    qty integer,
    color_id bigint,
    mold_id bigint,
    material_id bigint,
    colorant_id bigint,
    material_kg numeric(14,3),
    colorant_kg numeric(14,3),
    machine_no smallint,
    planned_start timestamp without time zone,
    planned_end timestamp without time zone,
    is_new_pair boolean,
    production_code text,
    full_code text,
    batch_code text,
    prod_start date,
    prod_end date,
    notes text
);


ALTER TABLE public.order_lines OWNER TO magazyn_app;

--
-- Name: order_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.order_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_lines_id_seq OWNER TO magazyn_app;

--
-- Name: order_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.order_lines_id_seq OWNED BY public.order_lines.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    number text NOT NULL,
    client_id bigint NOT NULL,
    seq integer NOT NULL,
    order_date date NOT NULL,
    requested_date date,
    channel text,
    received_by text,
    ordered_by text,
    ordered_email text,
    client_ref text,
    source_ref text,
    internal_no text,
    status text DEFAULT 'NOWE'::text NOT NULL,
    planned_start timestamp without time zone,
    planned_end timestamp without time zone,
    delivery_date date,
    notes text,
    accepted_at timestamp with time zone,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.orders OWNER TO magazyn_app;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO magazyn_app;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.products (
    id bigint NOT NULL,
    code integer NOT NULL,
    client_id bigint NOT NULL,
    name text NOT NULL,
    material_text text,
    colorant_text text,
    material_id bigint,
    colorant_id bigint,
    colorant_pct numeric(6,2),
    color_id bigint,
    mold_id bigint,
    mold_match text,
    pattern_no text,
    net_g numeric(12,3),
    gross_g numeric(12,3),
    cavities numeric(6,0),
    cycle_s numeric(10,2),
    per_shift numeric(12,0),
    pcs_per_carton numeric(12,0),
    carton_type text,
    carton_kg numeric(10,2),
    machines text,
    orders_count integer,
    produced_total numeric(14,0),
    first_production date,
    last_production date,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT products_code_check CHECK (((code >= 1) AND (code <= 9999)))
);


ALTER TABLE public.products OWNER TO magazyn_app;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO magazyn_app;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: receipt_lines; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.receipt_lines (
    id bigint NOT NULL,
    receipt_id bigint NOT NULL,
    material_id bigint NOT NULL,
    qty_kg numeric(14,3) DEFAULT 0 NOT NULL,
    unit_price numeric(12,4),
    lot text,
    notes text,
    CONSTRAINT receipt_lines_qty_kg_check CHECK ((qty_kg >= (0)::numeric))
);


ALTER TABLE public.receipt_lines OWNER TO magazyn_app;

--
-- Name: receipt_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.receipt_lines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.receipt_lines_id_seq OWNER TO magazyn_app;

--
-- Name: receipt_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.receipt_lines_id_seq OWNED BY public.receipt_lines.id;


--
-- Name: receipts; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.receipts (
    id bigint NOT NULL,
    number text NOT NULL,
    supplier_id bigint,
    supplier_name text,
    doc_date date DEFAULT CURRENT_DATE NOT NULL,
    delivery_doc text,
    order_ref text,
    notes text,
    created_by text,
    received_by text,
    status text DEFAULT 'OTWARTY'::text NOT NULL,
    realized_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.receipts OWNER TO magazyn_app;

--
-- Name: receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.receipts_id_seq OWNER TO magazyn_app;

--
-- Name: receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.receipts_id_seq OWNED BY public.receipts.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: magazyn_app
--

CREATE TABLE public.suppliers (
    id bigint NOT NULL,
    ordinal integer,
    name text NOT NULL,
    short_name text,
    supplier_no text,
    material_type text,
    address text,
    postal_code text,
    city text,
    country text,
    nip text,
    phone text,
    website text,
    payment_terms text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.suppliers OWNER TO magazyn_app;

--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: magazyn_app
--

CREATE SEQUENCE public.suppliers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_id_seq OWNER TO magazyn_app;

--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: magazyn_app
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: colors id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.colors ALTER COLUMN id SET DEFAULT nextval('public.colors_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: inventories id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventories ALTER COLUMN id SET DEFAULT nextval('public.inventories_id_seq'::regclass);


--
-- Name: inventory_lines id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventory_lines ALTER COLUMN id SET DEFAULT nextval('public.inventory_lines_id_seq'::regclass);


--
-- Name: machine_doc_lines id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_doc_lines ALTER COLUMN id SET DEFAULT nextval('public.machine_doc_lines_id_seq'::regclass);


--
-- Name: machine_docs id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_docs ALTER COLUMN id SET DEFAULT nextval('public.machine_docs_id_seq'::regclass);


--
-- Name: materials id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.materials ALTER COLUMN id SET DEFAULT nextval('public.materials_id_seq'::regclass);


--
-- Name: mold_events id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.mold_events ALTER COLUMN id SET DEFAULT nextval('public.mold_events_id_seq'::regclass);


--
-- Name: mold_photos id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.mold_photos ALTER COLUMN id SET DEFAULT nextval('public.mold_photos_id_seq'::regclass);


--
-- Name: molds id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.molds ALTER COLUMN id SET DEFAULT nextval('public.molds_id_seq'::regclass);


--
-- Name: order_lines id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines ALTER COLUMN id SET DEFAULT nextval('public.order_lines_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: receipt_lines id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipt_lines ALTER COLUMN id SET DEFAULT nextval('public.receipt_lines_id_seq'::regclass);


--
-- Name: receipts id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipts ALTER COLUMN id SET DEFAULT nextval('public.receipts_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.app_settings (key, value) FROM stdin;
diff_threshold_pct	5
plan_shifts	3
plan_days	5
plan_setup_h	4
plan_delivery_days	2
plan_lead_days	7
plan_scrap_pct	3
molds_passport_v1	1
colors_v2	1
colors_v3	1
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.clients (id, code, short_name, name, industry, contact_person, contact_position, phone, phone_central, email, website, street, postal_code, city, voivodeship, nip, regon, krs, iban, since, data_status, notes, created_at, updated_at) FROM stdin;
1	000	FIBOO	Fiboo Spółka z ograniczoną odpowiedzialnością	Akcesoria dla zwierząt (ekologiczne)	Jakub Majchrzak	CEO / Prezes Zarządu	+48 515 195 808	+48 515 195 808	sklep@fiboo.pl	www.fiboo.pl	ul. Obornicka 1B	62-090	Bytkowo	Wielkopolskie	7773261657	364261610	0000614314	— (nie publikowany)	\N	DANE RZECZYWISTE (zweryfikowane w KRS/CEIDG)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
2	017	OKIDAY	OKIDAY S.A.	Produkcja artykułów dla dzieci	Paweł Król	Menedżer ds. Współpracy z Dostawcami	+48 75 144 68 78	+48 27 487 20 80	pawel.krol@okiday.pl	www.okiday.pl	ul. Portowa 71	00-350	Warszawa	Mazowieckie	1338908381	637940260	0054235116	PL49593103413164752553419283	2018-08-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
3	016	MOBILUS	MOBILUS Sp.j.	Motoryzacja / akcesoria mobilne	Krzysztof Pawłowski	Specjalista ds. Łańcucha Dostaw	+48 58 864 84 64	+48 86 508 56 38	krzysztof.pawlowski@mobilus.pl	www.mobilus.pl	ul. Technologiczna 177	20-670	Lublin	Lubelskie	3503056419	395376727		PL28710122691669784801845146	2018-08-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
4	009	HOLYPIT	HOLYPIT S.A.	Artykuły sportowe i rekreacyjne	Grzegorz Wiśniewski	Specjalista ds. Łańcucha Dostaw	+48 74 228 26 94	+48 72 662 31 43	grzegorz.wisniewski@holypit.pl	www.holypit.pl	ul. Portowa 68	44-612	Rybnik	Śląskie	2814893252	288095709	0015430391	PL89638346578713315098393010	2019-02-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
5	020	REGAL TAGS	REGAL TAGS S.A.	Zawieszki i etykiety odzieżowe	Krzysztof Pawłowski	Dyrektor Handlowy	+48 54 532 33 45	+48 71 355 19 66	krzysztof.pawlowski@regaltags.pl	www.regaltags.pl	ul. Logistyczna 132	40-343	Katowice	Śląskie	4738299734	763116565	0067010651	PL81080132677360260647468723	2020-04-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
6	004	EUROSTER	EUROSTER S.A.	Automatyka i termostaty HVAC	Tomasz Woźniak	Dyrektor Handlowy	+48 60 869 19 11	+48 70 736 82 22	tomasz.wozniak@euroster.pl	www.euroster.pl	ul. Portowa 139	10-162	Olsztyn	Warmińsko-Mazurskie	8121913614	939909166	0099854353	PL18384251354278498084124118	2018-05-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
7	015	MARMITE	MARMITE Sp. z o.o. Sp.k.	Akcesoria kuchenne i AGD	Magdalena Mazur	Kierownik Produkcji	+48 51 415 56 15	+48 57 315 97 41	magdalena.mazur@marmite.pl	www.marmite.pl	ul. Handlowa 88	45-308	Opole	Opolskie	4874016403	052427867	0080112805	PL15869232260256342160733754	2019-04-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
8	023	TIMBERNESS	TIMBERNESS S.A.	Branża meblarska / drewno	Agnieszka Szymański	Dyrektor Zakupów	+48 72 546 10 76	+48 80 803 95 35	agnieszka.szymanski@timberness.pl	www.timberness.pl	ul. Handlowa 103	33-436	Tarnów	Małopolskie	4145868509	142940196	0065569816	PL56159514846564823662994680	2020-05-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
9	005	EVR	EVR Sp. z o.o.	Komponenty elektrotechniczne	Rafał Lewandowski	Główny Technolog	+48 65 509 41 28	+48 12 868 23 64	rafal.lewandowski@evr.pl	www.evr.pl	ul. Chemiczna 149	26-721	Radom	Mazowieckie	5777387213	489513433	0032003791	PL32870831727889579868727743	2020-09-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
10	010	IVT	IVT Sp.j.	Systemy wentylacyjne	Grzegorz Mazur	Dyrektor Zakupów	+48 56 952 63 59	+48 86 812 12 83	grzegorz.mazur@ivt.pl	www.ivt.pl	ul. Kolejowa 71	09-550	Płock	Mazowieckie	1434558127	236231662		PL67054668893734670656272980	2022-10-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
11	022	SCOOPTEC	SCOOPTEC	Sprzęt ogrodowy i narzędzia	Dariusz Nowak	Koordynator Zamówień	+48 57 765 18 93	+48 17 872 13 41	dariusz.nowak@scooptec.pl	www.scooptec.pl	ul. Przemysłowa 22	33-758	Tarnów	Małopolskie	6272046539	755646418		PL30923271937452991241904966	2019-02-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
12	012	L&P	L&P	Opakowania i akcesoria przemysłowe	Ewa Kowalczyk	Główny Technolog	+48 55 851 76 93	+48 46 730 78 71	ewa.kowalczyk@lp.pl	www.lp.pl	ul. Technologiczna 63	65-204	Zielona Góra	Lubuskie	4919058655	185067160		PL76945314737996507527354549	2020-09-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
13	021	ROSA	ROSA S.A.	Kosmetyki i akcesoria łazienkowe	Michał Zieliński	Specjalista ds. Zamówień	+48 73 297 50 25	+48 80 880 98 33	michal.zielinski@rosa.pl	www.rosa.pl	ul. Handlowa 22	35-347	Rzeszów	Podkarpackie	6783777014	436349570	0088568557	PL33749894134352408240084271	2016-10-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
14	007	HIC	HIC Sp. z o.o. Sp.k.	Komponenty do mebli tapicerowanych	Grzegorz Woźniak	Główny Technolog	+48 59 682 89 17	+48 24 881 36 90	grzegorz.wozniak@hic.pl	www.hic.pl	ul. Ceramiczna 113	25-448	Kielce	Świętokrzyskie	2047116718	902294130	0018699938	PL34123281206797403447134936	2017-09-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
15	019	RAIS	RAIS Sp. z o.o.	Urządzenia grzewcze / kominki	Krzysztof Michalski	Dyrektor Zakupów	+48 74 788 44 83	+48 17 881 32 70	krzysztof.michalski@rais.pl	www.rais.pl	ul. Spedycyjna 69	09-946	Płock	Mazowieckie	2102499470	174648878	0071906594	PL87429671756551256746807154	2021-02-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
16	001	APP	APP Sp.j.	Akcesoria biurowe i opakowania	Ewa Wójcik	Dyrektor Zakupów	+48 70 723 40 30	+48 51 664 11 80	ewa.wojcik@app.pl	www.app.pl	ul. Przemysłowa 169	35-990	Rzeszów	Podkarpackie	8760385978	703482472		PL61317127484677378263982146	2021-09-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
17	025	ŁUKASIK	ŁUKASIK Sp. z o.o. Sp.k.	Artykuły gospodarstwa domowego	Magdalena Piotrowski	Dyrektor Zakupów	+48 54 614 85 52	+48 24 995 66 22	magdalena.piotrowski@lukasik.pl	www.lukasik.pl	ul. Składowa 77	00-957	Warszawa	Mazowieckie	9972787558	886753390	0063605766	PL87026217459615865780913431	2022-02-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
18	002	BIT	BIT S.A.	Elektronika i podzespoły	Paweł Michalski	Menedżer ds. Współpracy z Dostawcami	+48 70 534 98 42	+48 70 965 48 35	pawel.michalski@bit.pl	www.bit.pl	ul. Magazynowa 178	87-406	Toruń	Kujawsko-Pomorskie	3869222192	693792375	0047407482	PL67136959440640909743953394	2018-11-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
19	006	FIBERLAB	FIBERLAB S.A.	Materiały kompozytowe	Krzysztof Jankowski	Specjalista ds. Łańcucha Dostaw	+48 61 192 60 11	+48 45 649 25 68	krzysztof.jankowski@fiberlab.pl	www.fiberlab.pl	ul. Technologiczna 11	09-416	Płock	Mazowieckie	7095214568	232858849	0024745171	PL54965137098593174612004711	2019-09-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
20	003	COFORMA	COFORMA Sp. z o.o.	Formy wtryskowe i komponenty techniczne	Ewa Wiśniewski	Dyrektor Operacyjny	+48 70 754 86 12	+48 18 905 52 41	ewa.wisniewski@coforma.pl	www.coforma.pl	ul. Centralna 95	42-786	Częstochowa	Śląskie	8692617961	405377352	0015850643	PL29318393352904228421020539	2021-01-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
21	008	HICTRANS	HICTRANS Sp. z o.o.	Transport i logistyka komponentów	Ewa Wiśniewski	Specjalista ds. Zamówień	+48 60 722 28 18	+48 28 381 89 91	ewa.wisniewski@hictrans.pl	www.hictrans.pl	ul. Fabryczna 33	20-859	Lublin	Lubelskie	6811775896	178390840	0070076617	PL98569847896118367365766156	2021-11-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
22	011	KM	KM Sp. z o.o. Sp.k.	Komponenty metalowo-plastikowe	Magdalena Piotrowski	Dyrektor Operacyjny	+48 77 210 54 81	+48 59 217 45 83	magdalena.piotrowski@km.pl	www.km.pl	ul. Spedycyjna 176	81-585	Gdynia	Pomorskie	1111615283	098851658	0060494519	PL36899809402445502296120183	2022-07-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
23	014	MARBO	MARBO Sp.j.	Artykuły dla zwierząt	Dariusz Wójcik	Koordynator Zamówień	+48 63 213 46 96	+48 87 598 77 95	dariusz.wojcik@marbo.pl	www.marbo.pl	ul. Magazynowa 95	40-419	Katowice	Śląskie	5991022903	147679762		PL40369003432445107622683885	2017-07-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
24	024	TOPBRIDGE	TOPBRIDGE S.A.	Akcesoria budowlane	Barbara Zieliński	Koordynator Zamówień	+48 74 272 19 75	+48 26 643 75 34	barbara.zielinski@topbridge.pl	www.topbridge.pl	ul. Przemysłowa 118	26-179	Radom	Mazowieckie	5969664163	052975161	0013696816	PL55231243292127799799552717	2023-11-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
25	013	LIDERPOOL	LIDERPOOL Sp. z o.o. Sp.k.	Baseny i akcesoria basenowe	Tomasz Nowak	Dyrektor Handlowy	+48 53 930 53 20	+48 76 761 32 15	tomasz.nowak@liderpool.pl	www.liderpool.pl	ul. Transportowa 152	59-157	Legnica	Dolnośląskie	5814770054	411998670	0098079359	PL37788925546659051518644925	2017-10-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
26	018	PALISANDER	PALISANDER Sp. z o.o.	Meble i akcesoria drewniane	Piotr Grabowski	Specjalista ds. Łańcucha Dostaw	+48 76 856 77 14	+48 55 997 89 26	piotr.grabowski@palisander.pl	www.palisander.pl	ul. Składowa 168	81-815	Gdynia	Pomorskie	6291486529	816850540	0023573322	PL96222927065379473834735977	2020-07-01	Dane fikcyjne (przykładowe)	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
\.


--
-- Data for Name: colors; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.colors (id, code, name, notes) FROM stdin;
1	000	NATURALNY / BEZ BARWNIKA	\N
2	001	BEŻOWY	\N
3	002	BIAŁY	\N
4	003	BORDOWY	\N
5	004	BRĄZOWY	\N
6	005	CIEMNOSZARY	\N
7	006	CZARNY	\N
8	007	CZERWONY	\N
9	008	FIOLETOWY	\N
10	009	GRAFITOWY	\N
11	010	GRANATOWY	\N
12	011	JASNOSZARY	\N
13	012	LIMONKOWY	\N
14	013	MIĘTOWY	\N
15	014	NIEBIESKI	\N
16	015	POMARAŃCZOWY	\N
17	016	RÓŻOWY	\N
18	017	SZARY	\N
19	018	TRANSPARENTNY	\N
20	019	TURKUSOWY	\N
21	020	WANILIOWY	\N
22	021	ZIELONY	\N
23	022	ŻÓŁTY	\N
24	023	CIEMNONIEBIESKI	\N
25	024	CIEMNOZIELONY	\N
26	025	SZAROFIOLETOWY	\N
27	026	SZAROZIELONY	\N
28	027	JASNONIEBIESKI	\N
29	028	KORALOWY	\N
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.contacts (id, supplier_id, contact_name, phone, email, notes, created_at, updated_at, "position") FROM stdin;
1	1	Marcin Świderski	696124499	marcin@polimerprojekt.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
2	2	Irina Hipetinger		Irina.hipetinger@kraiburg-tpe.com		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
4	4	Joanna Balcerzak	507084415	joanna.balcerzak@bcd-polymers.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
5	5	Magdalena Migut	453012379	Magdalena.Migut@terplastics.com		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
6	6	Jarosław Stoliński	601997647	biuro@emipak.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
7	7	Sławomir Puzio	790440125	slawomir.puzio@ekobasket.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
8	8	Konrad Skuza	880766022	Konrad.Skuza@resinex.com		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
9	8	Jakub Bubelski	880766022	Konrad.Skuza@resinex.com		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
10	9	Sylwia Miter	574760980	sylwia.miter@ppc.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
11	10	Barbara Ciesielska	882-112-172	Barbara.Ciesielska@petrecyclingteam.eu		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
12	11	Jakub Meyer	793533333	jakub.mejer@argusjm.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
13	12	Bartosz Głowacki	664995559	bartosz@plastpro.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
14	18			Ivan@plasticsolutions.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
15	19	Maria Bohdziewicz-Sikorska		m.sikorska@plastoplan.pl		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
16	24	Bartosz Rusicki	+48 664 596 988	bartosz.rusicki@benvic.com		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
17	29	Konrad Brywczyński	538517508	konrad.brywczynski@ultrapolymers.com		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00	\N
3	3	Grzegorz Szczypka	605061220	szczypka.g@granpol.com.pl		2026-09-25 14:40:57.734205+00	2026-09-29 08:14:30.351057+00	
\.


--
-- Data for Name: inventories; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.inventories (id, number, count_date, scope, status, counted_by, notes, created_at, approved_at) FROM stdin;
1	INW/2026/001	2026-08-31	ALL	ZATWIERDZONA	import z Excela	Import z pliku Inwentura_09.2026_TUTAJ_UZUPENIA.xlsx	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
2	INW/2026/002	2026-09-11	SUROWIEC SYPKI	ZATWIERDZONA	import z Excela	Import z pliku Inwentura_09.2026_TUTAJ_UZUPENIA.xlsx	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
3	INW/2026/003	2026-09-18	SUROWIEC SYPKI	ZATWIERDZONA	import z Excela	Import z pliku Inwentura_09.2026_TUTAJ_UZUPENIA.xlsx	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
4	INW/2026/004	2026-09-25	SUROWIEC SYPKI	ZATWIERDZONA	import z Excela	Import z pliku Inwentura_09.2026_TUTAJ_UZUPENIA.xlsx	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
5	INW/2026/005	2026-10-01	ALL	OTWARTA			2026-10-01 08:05:25.251353+00	\N
\.


--
-- Data for Name: inventory_lines; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.inventory_lines (id, inventory_id, material_id, expected_kg, counted_kg, unit_price, notes, updated_at, diff_reason, diff_explanation, diff_explained_by, diff_explained_at) FROM stdin;
1	1	44	\N	570.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
2	1	45	\N	500.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
3	1	46	\N	154.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
4	1	47	\N	283.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
5	1	48	\N	0.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
6	1	49	\N	150.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
7	1	25	\N	1250.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
8	1	71	\N	3550.000	5.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
9	1	26	\N	450.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
10	1	40	\N	9400.000	4.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
11	1	29	\N	100.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
12	1	192	\N	0.000	11.9190	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
13	1	30	\N	575.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
14	1	59	\N	475.000	12.5900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
15	1	54	\N	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
16	1	31	\N	1275.000	9.3025	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
17	1	193	\N	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
18	1	55	\N	500.000	18.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
19	1	20	\N	25.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
20	1	1	\N	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
21	1	73	\N	2075.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
22	1	60	\N	20.000	12.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
23	1	23	\N	600.000	11.9625	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
24	1	2	\N	125.000	11.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
25	1	3	\N	250.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
26	1	4	\N	50.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
27	1	5	\N	0.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
28	1	61	\N	55.000	10.4500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
29	1	12	\N	875.000	9.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
30	1	64	\N	600.000	15.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
31	1	65	\N	1700.000	9.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
32	1	43	\N	1000.000	6.0200	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
33	1	70	\N	2700.000	7.0400	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
34	1	32	\N	450.000	8.0475	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
35	1	33	\N	225.000	10.0050	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
36	1	21	\N	325.000	7.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
37	1	6	\N	25.000	6.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
38	1	22	\N	0.000	8.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
39	1	41	\N	2700.000	3.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
40	1	42	\N	1700.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
41	1	63	\N	2000.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
42	1	7	\N	2400.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
43	1	34	\N	4725.000	7.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
44	1	35	\N	0.000	1.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
45	1	194	\N	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
46	1	36	\N	1450.000	8.4825	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
47	1	37	\N	0.000	10.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
48	1	27	\N	3400.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
49	1	8	\N	0.000	5.8500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
50	1	72	\N	3350.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
51	1	66	\N	1500.000	7.2500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
52	1	67	\N	500.000	6.0700	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
53	1	62	\N	4000.000	4.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
54	1	9	\N	60.000	8.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
55	1	10	\N	0.000	7.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
56	1	50	\N	4000.000	6.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
57	1	24	\N	1700.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
58	1	28	\N	0.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
59	1	51	\N	2380.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
60	1	53	\N	0.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
61	1	52	\N	0.000	6.3000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
62	1	13	\N	700.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
63	1	38	\N	70.000	18.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
64	1	56	\N	400.000	10.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
65	1	195	\N	800.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
66	1	68	\N	400.000	9.0800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
67	1	14	\N	300.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
68	1	15	\N	16020.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
69	1	17	\N	0.000	12.3500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
70	1	18	\N	2700.000	13.0500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
71	1	19	\N	350.000	14.3800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
72	1	16	\N	2850.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
73	1	69	\N	1570.000	7.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
74	1	39	\N	0.000	16.9650	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
75	1	57	\N	1060.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
76	1	58	\N	1020.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
77	1	196	\N	3952.000	17.0520	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
78	1	80	\N	9.000	26.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
79	1	81	\N	22.000	57.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
80	1	82	\N	42.000	33.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
81	1	83	\N	15.000	120.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
82	1	84	\N	21.000	75.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
83	1	85	\N	16.000	69.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
84	1	86	\N	24.000	71.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
85	1	87	\N	34.000	71.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
86	1	88	\N	0.000	59.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
87	1	89	\N	26.000	116.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
88	1	90	\N	15.000	75.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
89	1	91	\N	16.000	75.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
90	1	92	\N	28.500	75.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
91	1	93	\N	7.500	75.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
92	1	94	\N	15.000	14.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
93	1	95	\N	50.000	16.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
94	1	96	\N	25.000	73.6300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
95	1	97	\N	0.000	43.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
96	1	98	\N	9.000	86.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
97	1	99	\N	23.000	15.2900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
98	1	100	\N	9.000	16.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
99	1	101	\N	0.000	32.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
100	1	102	\N	17.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
101	1	103	\N	0.000	16.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
102	1	104	\N	82.000	14.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
103	1	105	\N	29.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
104	1	106	\N	79.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
105	1	107	\N	15.500	27.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
106	1	108	\N	35.000	27.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
107	1	109	\N	27.000	33.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
108	1	110	\N	58.000	23.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
109	1	111	\N	78.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
110	1	112	\N	47.000	21.5500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
111	1	113	\N	43.000	21.5500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
112	1	114	\N	35.000	25.4600	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
113	1	115	\N	0.000	22.9800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
114	1	116	\N	73.000	37.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
115	1	117	\N	72.000	22.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
116	1	118	\N	25.000	30.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
117	1	119	\N	25.000	30.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
118	1	120	\N	51.000	58.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
119	1	121	\N	53.000	31.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
120	1	122	\N	39.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
121	1	123	\N	64.000	29.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
122	1	124	\N	90.000	47.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
123	1	125	\N	70.000	78.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
124	1	126	\N	1.000	31.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
125	1	127	\N	0.000	68.6500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
126	1	128	\N	13.000	31.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
127	1	129	\N	8.000	28.3300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
128	1	130	\N	25.000	29.1300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
129	1	131	\N	20.000	59.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
130	1	132	\N	51.000	29.1300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
131	1	133	\N	1.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
132	1	134	\N	15.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
133	1	135	\N	8.000	32.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
134	1	136	\N	9.000	10.6500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
135	1	137	\N	21.000	38.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
136	1	138	\N	29.000	57.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
137	1	139	\N	12.000	72.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
138	1	140	\N	56.000	60.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
139	1	141	\N	12.000	33.5400	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
140	1	142	\N	9.000	29.6400	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
141	1	143	\N	23.000	67.3000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
142	1	144	\N	28.000	36.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
143	1	145	\N	16.000	29.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
144	1	146	\N	29.000	30.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
145	1	147	\N	27.000	31.0700	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
146	1	148	\N	0.000	30.1200	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
147	1	149	\N	7.000	29.4500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
148	1	150	\N	33.000	39.0600	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
149	1	151	\N	28.000	49.9700	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
150	1	152	\N	77.000	84.5500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
151	1	153	\N	30.000	76.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
152	1	154	\N	63.000	49.2900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
153	1	155	\N	46.000	35.1500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
154	1	156	\N	41.000	33.3500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
155	1	157	\N	45.000	39.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
156	1	158	\N	70.000	36.5800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
157	1	159	\N	20.000	28.3700	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
158	1	160	\N	20.000	13.8900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
159	1	161	\N	42.000	29.9300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
160	1	162	\N	25.000	32.3000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
161	1	163	\N	58.000	13.8900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
162	1	164	\N	60.000	29.9300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
163	1	165	\N	8.000	27.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
164	1	166	\N	80.000	39.4300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
165	1	167	\N	35.000	38.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
166	1	168	\N	105.000	65.7500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
167	1	169	\N	120.000	72.3800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
168	1	170	\N	31.000	65.7500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
169	1	171	\N	0.000	66.0200	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
170	1	172	\N	25.000	38.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
171	1	173	\N	16.000	38.4500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
172	1	174	\N	12.000	24.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
173	1	175	\N	25.000	63.5600	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
174	1	176	\N	0.000	18.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
175	1	177	\N	0.000	18.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
176	1	178	\N	30.000	18.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
177	1	179	\N	16.000	15.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
178	1	180	\N	11.000	9.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
179	1	181	\N	13.000	29.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
180	1	182	\N	21.000	14.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
181	1	183	\N	25.000	34.8800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
182	1	184	\N	25.000	35.7200	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
183	1	185	\N	25.000	32.4900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
184	1	186	\N	25.000	29.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
185	1	187	\N	25.000	27.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
186	1	188	\N	25.000	32.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
187	1	189	\N	50.000	\N	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
188	1	190	\N	13.000	\N	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
189	1	191	\N	0.000	\N	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
190	2	44	570.000	570.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
191	2	45	500.000	500.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
192	2	46	154.000	154.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
193	2	47	283.000	283.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
194	2	48	0.000	0.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
195	2	49	150.000	150.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
196	2	25	1250.000	1250.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
197	2	71	3550.000	3750.000	5.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
198	2	26	450.000	450.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
199	2	40	9400.000	9400.000	4.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
200	2	29	100.000	675.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
201	2	192	0.000	0.000	11.9190	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
202	2	30	575.000	575.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
203	2	59	475.000	475.000	12.5900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
204	2	54	0.000	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
205	2	31	1275.000	1350.000	9.3025	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
206	2	193	0.000	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
207	2	55	500.000	500.000	18.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
208	2	20	25.000	25.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
209	2	1	0.000	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
210	2	73	2075.000	1700.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
211	2	60	20.000	20.000	12.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
212	2	23	600.000	2400.000	11.9625	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
213	2	2	125.000	125.000	11.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
214	2	3	250.000	650.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
215	2	4	50.000	50.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
216	2	5	0.000	0.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
217	2	61	55.000	55.000	10.4500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
218	2	12	875.000	800.000	9.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
219	2	64	600.000	600.000	15.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
220	2	65	1700.000	1700.000	9.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
221	2	43	1000.000	1000.000	6.0200	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
222	2	70	2700.000	2700.000	7.0400	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
223	2	32	450.000	450.000	8.0475	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
224	2	33	225.000	275.000	10.0050	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
225	2	21	325.000	420.000	5.9800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
226	2	6	25.000	25.000	6.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
227	2	22	0.000	0.000	8.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
228	2	41	2700.000	2700.000	3.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
229	2	42	1700.000	1700.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
230	2	63	2000.000	2000.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
231	2	7	2400.000	2275.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
232	2	34	4725.000	4700.000	7.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
233	2	35	0.000	0.000	1.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
234	2	194	0.000	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
235	2	36	1450.000	800.000	8.4825	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
236	2	37	0.000	0.000	10.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
237	2	27	3400.000	3400.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
238	2	8	0.000	0.000	5.8500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
239	2	72	3350.000	2850.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
240	2	66	1500.000	1500.000	7.2500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
241	2	67	500.000	500.000	6.0700	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
242	2	62	4000.000	4000.000	4.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
243	2	9	60.000	60.000	8.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
244	2	10	0.000	0.000	7.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
245	2	50	4000.000	3900.000	6.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
246	2	24	1700.000	1500.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
247	2	28	0.000	0.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
248	2	51	2380.000	980.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
249	2	53	0.000	0.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
250	2	52	0.000	0.000	6.3000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
251	2	13	700.000	525.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
252	2	38	70.000	70.000	18.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
253	2	56	400.000	400.000	10.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
254	2	195	800.000	800.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
255	2	68	400.000	400.000	9.0800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
256	2	14	300.000	300.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
257	2	15	16020.000	14640.000	17.7480	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
258	2	17	0.000	0.000	12.3500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
259	2	18	2700.000	4325.000	12.9195	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
260	2	19	350.000	350.000	14.3800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
261	2	16	2850.000	3420.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
262	2	69	1570.000	1570.000	7.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
263	2	39	0.000	0.000	16.9650	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
264	2	57	1060.000	1060.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
265	2	58	1020.000	1020.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
266	2	196	3952.000	3952.000	17.0520	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
267	3	44	570.000	570.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
268	3	45	500.000	500.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
269	3	46	154.000	154.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
270	3	47	283.000	283.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
271	3	48	0.000	0.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
272	3	49	150.000	150.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
273	3	25	1250.000	1250.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
274	3	71	3750.000	3750.000	5.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
275	3	26	450.000	450.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
276	3	40	9400.000	9400.000	4.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
277	3	29	675.000	625.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
278	3	192	0.000	0.000	11.9190	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
279	3	30	575.000	575.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
280	3	59	475.000	475.000	12.5900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
281	3	54	0.000	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
282	3	31	1350.000	1350.000	9.3025	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
283	3	193	0.000	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
284	3	55	500.000	500.000	18.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
285	3	20	25.000	25.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
286	3	1	0.000	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
287	3	73	1700.000	1700.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
288	3	60	20.000	20.000	12.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
289	3	23	2400.000	2400.000	11.9625	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
290	3	2	125.000	125.000	11.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
291	3	3	650.000	650.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
292	3	4	50.000	50.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
293	3	5	0.000	0.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
294	3	61	55.000	55.000	10.4500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
295	3	12	800.000	800.000	9.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
296	3	64	600.000	600.000	15.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
297	3	65	1700.000	1700.000	9.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
298	3	43	1000.000	300.000	6.0200	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
299	3	70	2700.000	2700.000	7.0400	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
300	3	32	450.000	450.000	8.0475	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
301	3	33	275.000	275.000	10.0050	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
302	3	21	420.000	420.000	7.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
303	3	6	25.000	25.000	6.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
304	3	22	0.000	0.000	8.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
305	3	41	2700.000	2700.000	3.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
306	3	42	1700.000	1700.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
307	3	63	2000.000	2000.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
308	3	7	2275.000	2275.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
309	3	34	4700.000	4675.000	7.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
310	3	35	0.000	0.000	1.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
311	3	194	0.000	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
312	3	36	800.000	800.000	8.4825	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
313	3	37	0.000	0.000	10.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
314	3	27	3400.000	3400.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
315	3	8	0.000	0.000	5.8500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
316	3	72	2850.000	2850.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
317	3	66	1500.000	1500.000	7.2500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
318	3	67	500.000	500.000	6.0700	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
319	3	62	4000.000	4000.000	4.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
320	3	9	60.000	60.000	8.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
321	3	10	0.000	0.000	7.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
322	3	50	3900.000	3900.000	6.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
323	3	24	1500.000	1500.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
324	3	28	0.000	0.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
325	3	51	980.000	980.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
326	3	53	0.000	0.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
327	3	52	0.000	0.000	6.3000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
328	3	13	525.000	1250.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
329	3	38	70.000	70.000	18.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
330	3	56	400.000	400.000	10.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
331	3	195	800.000	800.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
332	3	68	400.000	400.000	9.0800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
333	3	14	300.000	300.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
334	3	15	14640.000	12620.000	17.7480	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
335	3	17	0.000	0.000	12.3500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
336	3	18	4325.000	3075.000	12.9195	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
337	3	19	350.000	350.000	14.3800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
338	3	16	3420.000	3420.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
339	3	69	1570.000	1570.000	7.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
340	3	39	0.000	0.000	16.9650	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
341	3	57	1060.000	1060.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
342	3	58	1020.000	1020.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
343	3	196	3952.000	3952.000	17.0520	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
344	4	44	570.000	570.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
345	4	45	500.000	500.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
346	4	46	154.000	154.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
347	4	47	283.000	283.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
348	4	48	0.000	0.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
349	4	49	150.000	150.000	12.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
350	4	25	1250.000	1250.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
351	4	71	3750.000	3750.000	5.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
352	4	26	450.000	450.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
353	4	40	9400.000	9550.000	4.2000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
354	4	29	625.000	625.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
355	4	192	0.000	0.000	11.9190	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
356	4	30	575.000	1575.000	13.2675	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
357	4	59	475.000	475.000	12.5900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
358	4	54	0.000	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
359	4	31	1350.000	1350.000	9.3025	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
360	4	193	0.000	0.000	12.1900	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
361	4	55	500.000	500.000	18.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
362	4	20	25.000	25.000	8.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
363	4	1	0.000	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
364	4	73	1700.000	1700.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
365	4	60	20.000	20.000	12.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
366	4	23	2400.000	2150.000	11.9625	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
367	4	2	125.000	1275.000	11.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
368	4	3	650.000	650.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
369	4	4	50.000	50.000	13.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
370	4	5	0.000	0.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
371	4	61	55.000	55.000	10.4500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
372	4	12	800.000	800.000	9.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
373	4	64	600.000	600.000	15.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
374	4	65	1700.000	1700.000	9.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
375	4	43	300.000	300.000	6.0200	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
376	4	70	2700.000	2700.000	7.0400	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
377	4	32	450.000	450.000	8.0475	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
378	4	33	275.000	275.000	10.0050	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
379	4	21	420.000	1775.000	7.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
380	4	6	25.000	25.000	6.4000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
381	4	22	0.000	0.000	8.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
382	4	41	2700.000	2700.000	3.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
383	4	42	1700.000	1550.000	5.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
384	4	63	2000.000	2000.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
385	4	7	2275.000	2225.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
386	4	34	4675.000	4650.000	7.8300	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
387	4	35	0.000	0.000	1.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
388	4	194	0.000	0.000	5.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
389	4	36	800.000	750.000	8.4825	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
390	4	37	0.000	0.000	10.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
391	4	27	3400.000	3400.000	3.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
392	4	8	0.000	0.000	5.8500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
393	4	72	2850.000	2200.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
394	4	66	1500.000	1500.000	7.2500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
395	4	67	500.000	500.000	6.0700	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
396	4	62	4000.000	4000.000	4.6000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
397	4	9	60.000	60.000	8.1000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
398	4	10	0.000	0.000	7.8000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
399	4	50	3900.000	3900.000	6.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
400	4	24	1500.000	1500.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
401	4	28	0.000	0.000	6.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
402	4	51	980.000	980.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
403	4	53	0.000	0.000	6.0000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
404	4	52	0.000	0.000	6.3000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
405	4	13	1250.000	1150.000	11.5000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
406	4	38	70.000	70.000	18.4800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
407	4	56	400.000	400.000	10.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
408	4	195	800.000	800.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
409	4	68	400.000	400.000	9.0800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
410	4	14	300.000	300.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
411	4	15	12620.000	11080.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
412	4	17	0.000	0.000	12.3500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
413	4	18	3075.000	1625.000	13.0500	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
414	4	19	350.000	350.000	14.3800	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
415	4	16	3420.000	3420.000	17.4435	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
416	4	69	1570.000	1570.000	7.9000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
417	4	39	0.000	0.000	16.9650	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
418	4	57	1060.000	1060.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
419	4	58	1020.000	1020.000	8.7000	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
420	4	196	3952.000	3952.000	17.0520	\N	2026-09-29 07:45:53.388955+00	\N	\N	\N	\N
913	5	80	9.000	\N	26.7000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
914	5	81	22.000	\N	57.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
915	5	82	42.000	\N	33.7000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
916	5	83	15.000	\N	120.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
917	5	84	21.000	\N	75.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
918	5	85	16.000	\N	69.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
919	5	86	24.000	\N	71.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
920	5	87	34.000	\N	71.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
921	5	88	0.000	\N	59.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
922	5	89	26.000	\N	116.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
923	5	90	15.000	\N	75.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
924	5	91	16.000	\N	75.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
925	5	92	28.500	\N	75.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
926	5	93	-115.500	\N	75.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
927	5	94	15.000	\N	14.6000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
928	5	95	50.000	\N	16.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
929	5	96	25.000	\N	73.6300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
930	5	97	0.000	\N	43.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
931	5	98	9.000	\N	86.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
932	5	99	23.000	\N	15.2900	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
933	5	100	9.000	\N	16.9000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
934	5	101	0.000	\N	32.1000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
935	5	102	17.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
936	5	103	0.000	\N	16.9000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
937	5	104	82.000	\N	14.1000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
938	5	105	29.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
939	5	106	79.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
940	5	107	15.500	\N	27.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
941	5	108	35.000	\N	27.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
942	5	109	27.000	\N	33.4000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
943	5	110	58.000	\N	23.2000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
944	5	28	0.000	\N	0.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
945	5	111	78.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
946	5	112	47.000	\N	21.5500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
947	5	113	43.000	\N	21.5500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
948	5	114	35.000	\N	25.4600	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
949	5	115	0.000	\N	22.9800	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
950	5	116	73.000	\N	37.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
951	5	117	72.000	\N	22.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
952	5	118	25.000	\N	30.1000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
953	5	119	25.000	\N	30.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
954	5	120	51.000	\N	58.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
955	5	121	53.000	\N	31.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
956	5	122	39.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
957	5	123	64.000	\N	29.9000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
958	5	124	90.000	\N	47.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
959	5	125	70.000	\N	78.6000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
960	5	126	1.000	\N	31.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
961	5	127	0.000	\N	68.6500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
962	5	128	13.000	\N	31.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
963	5	129	8.000	\N	28.3300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
964	5	130	25.000	\N	29.1300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
965	5	131	20.000	\N	59.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
966	5	132	51.000	\N	29.1300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
967	5	133	1.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
968	5	134	15.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
969	5	135	8.000	\N	32.2000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
970	5	136	9.000	\N	10.6500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
971	5	137	21.000	\N	38.8300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
972	5	138	29.000	\N	57.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
973	5	139	12.000	\N	72.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
974	5	140	56.000	\N	60.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
975	5	141	12.000	\N	33.5400	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
976	5	142	9.000	\N	29.6400	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
977	5	1	0.000	\N	5.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
978	5	2	1275.000	\N	11.4000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
979	5	36	750.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
980	5	3	650.000	\N	13.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
981	5	4	50.000	\N	13.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
982	5	5	0.000	\N	11.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
983	5	6	25.000	\N	6.4000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
984	5	7	2225.000	\N	6.7000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
985	5	8	0.000	\N	5.8500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
986	5	9	60.000	\N	8.1000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
987	5	10	0.000	\N	7.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
988	5	11	\N	\N	10.9000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
989	5	12	800.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
990	5	13	1150.000	\N	11.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
991	5	14	300.000	\N	34.5825	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
992	5	15	11080.000	\N	16.0080	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
993	5	16	3420.000	\N	16.3560	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
994	5	17	0.000	\N	53.7225	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
995	5	18	1625.000	\N	56.9415	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
996	5	19	350.000	\N	62.5530	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
997	5	20	25.000	\N	8.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
998	5	21	1775.000	\N	5.9800	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
999	5	22	0.000	\N	5.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1000	5	23	2150.000	\N	11.9625	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1001	5	24	1500.000	\N	6.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1002	5	25	1250.000	\N	0.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1003	5	26	450.000	\N	0.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1004	5	27	3400.000	\N	0.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1005	5	29	625.000	\N	4.2000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1006	5	30	1575.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1007	5	31	1350.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1008	5	32	450.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1009	5	33	275.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1010	5	34	4650.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1011	5	35	0.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1012	5	37	0.000	\N	5.8725	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1013	5	38	70.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1014	5	39	0.000	\N	16.9650	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1015	5	40	9550.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1016	5	41	2700.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1017	5	42	1550.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1018	5	43	300.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1019	5	44	570.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1020	5	45	500.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1021	5	46	154.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1022	5	47	283.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1023	5	48	0.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1024	5	49	150.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1025	5	50	3900.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1026	5	51	980.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1027	5	52	0.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1028	5	53	0.000	\N	6.3000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1029	5	54	0.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1030	5	55	500.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1031	5	56	400.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1032	5	57	1060.000	\N	8.7000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1033	5	58	1020.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1034	5	59	475.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1035	5	60	20.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1036	5	61	55.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1037	5	62	4000.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1038	5	63	2000.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1039	5	64	600.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1040	5	65	1700.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1041	5	66	1500.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1042	5	67	500.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1043	5	68	400.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1044	5	69	1570.000	\N	7.9000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1045	5	70	2700.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1046	5	71	3750.000	\N	5.2000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1047	5	72	2200.000	\N	6.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1048	5	73	1700.000	\N	5.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1049	5	143	23.000	\N	67.3000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1050	5	144	28.000	\N	36.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1051	5	145	16.000	\N	29.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1052	5	146	29.000	\N	30.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1053	5	147	27.000	\N	31.0700	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1054	5	148	0.000	\N	30.1200	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1055	5	149	7.000	\N	29.4500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1056	5	150	33.000	\N	39.0600	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1057	5	151	28.000	\N	49.9700	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1058	5	152	77.000	\N	84.5500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1059	5	153	30.000	\N	76.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1060	5	154	63.000	\N	49.2900	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1061	5	155	46.000	\N	35.1500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1062	5	156	41.000	\N	33.3500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1063	5	157	45.000	\N	39.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1064	5	158	70.000	\N	36.5800	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1065	5	159	20.000	\N	28.3700	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1066	5	160	20.000	\N	13.8900	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1067	5	161	42.000	\N	29.9300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1068	5	162	25.000	\N	32.3000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1069	5	163	58.000	\N	13.8900	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1070	5	164	60.000	\N	29.9300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1071	5	165	8.000	\N	27.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1072	5	166	80.000	\N	39.4300	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1073	5	167	35.000	\N	38.6000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1074	5	168	105.000	\N	65.7500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1075	5	169	120.000	\N	72.3800	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1076	5	170	31.000	\N	65.7500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1077	5	171	0.000	\N	66.0200	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1078	5	172	25.000	\N	38.7000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1079	5	176	0.000	\N	18.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1080	5	183	25.000	\N	34.8800	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1081	5	184	25.000	\N	35.7200	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1082	5	187	25.000	\N	27.1000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1083	5	188	25.000	\N	32.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1084	5	181	13.000	\N	29.1000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1085	5	186	25.000	\N	29.9000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1086	5	185	25.000	\N	32.4900	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1087	5	182	21.000	\N	14.5000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1088	5	175	25.000	\N	63.5600	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1089	5	180	11.000	\N	9.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1090	5	179	16.000	\N	15.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1091	5	178	30.000	\N	18.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1092	5	177	0.000	\N	18.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1093	5	174	12.000	\N	24.0000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1094	5	173	16.000	\N	38.4500	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1095	5	189	50.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1096	5	190	13.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1097	5	191	0.000	\N	\N	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1098	5	192	0.000	\N	11.9190	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1099	5	193	0.000	\N	12.1900	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1100	5	194	0.000	\N	5.8000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1101	5	195	800.000	\N	8.7000	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
1102	5	196	3952.000	\N	17.0520	\N	2026-10-01 08:05:25.251353+00	\N	\N	\N	\N
\.


--
-- Data for Name: machine_doc_lines; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.machine_doc_lines (id, doc_id, material_id, qty_kg, notes) FROM stdin;
1	1	93	123.000	
4	8	93	123.000	\N
\.


--
-- Data for Name: machine_docs; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.machine_docs (id, number, doc_type, machine_id, status, doc_date, shift, order_ref, reason, notes, created_by, realized_by, realized_at, created_at) FROM stdin;
1	WM/2026/001	WYDANIE	1	ZREALIZOWANY	2026-09-29	23	q112	\N		gałązka Zbigniew	gałązka Zbigniew	2026-09-29 08:41:24.378957+00	2026-09-29 08:39:20.339836+00
2	WM/2026/002	WYDANIE	1	OTWARTY	2026-09-29	\N	\N	\N	\N	\N	\N	\N	2026-09-29 08:42:22.422734+00
3	UZ/2026/001	UZUPELNIENIE	1	OTWARTY	2026-09-29	\N	\N	\N	\N	\N	\N	\N	2026-09-29 08:54:46.194475+00
4	UZ/2026/002	UZUPELNIENIE	2	OTWARTY	2026-09-30	\N	\N	\N	\N	\N	\N	\N	2026-09-30 09:36:00.36791+00
5	ZU/2026/001	ZUZYCIE	1	OTWARTY	2026-09-30	\N	\N	\N	\N	\N	\N	\N	2026-09-30 13:44:09.955349+00
6	UZ/2026/003	UZUPELNIENIE	1	OTWARTY	2026-09-30	\N	\N	\N	\N	\N	\N	\N	2026-09-30 13:45:10.146078+00
7	ZU/2026/002	ZUZYCIE	1	OTWARTY	2026-09-30	\N	\N	\N	\N	\N	\N	\N	2026-09-30 13:45:14.389363+00
8	ZW/2026/001	ZWROT	1	OTWARTY	2026-09-30	\N	\N	\N	\N	\N	\N	\N	2026-09-30 13:45:20.165345+00
\.


--
-- Data for Name: machines; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.machines (id, name) FROM stdin;
1	Maszyna 1
2	Maszyna 2
3	Maszyna 3
4	Maszyna 4
5	Maszyna 5
6	Maszyna 6
7	Maszyna 7
8	Maszyna 8
9	Maszyna 9
\.


--
-- Data for Name: materials; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.materials (id, material_index, ordinal, supplier_id, supplier_no, supplier_name, supplier_short_name, material_type, kind, origin_code, symbol, color, internal_name, unit_price, currency, price_pln, unit, lead_time_days, notes, created_at, updated_at) FROM stdin;
80	BT001	1	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SB5GA4087	NIEBIESKI	GABRIEL CHEMIE-SB5GA4087-NIEBIESKI	26.7000	PLN	26.7000	KG	\N	Inwentura 31.08.2026: 9 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
81	BT002	2	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SB2GA1517	ŻÓŁTY	GABRIEL CHEMIE-SB2GA1517-ŻÓŁTY	57.0000	PLN	57.0000	KG	\N	Inwentura 31.08.2026: 22 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
82	BT003	3	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SB6GA3507	ZIELONY	GABRIEL CHEMIE-SB6GA3507-ZIELONY	33.7000	PLN	33.7000	KG	\N	Inwentura 31.08.2026: 42 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
83	BT004	4	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SB3GA1217	POMARAŃCZOWY	GABRIEL CHEMIE-SB3GA1217-POMARAŃCZOWY	120.0000	PLN	120.0000	KG	\N	Inwentura 31.08.2026: 15 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
84	BT005	5	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SAN8GA8287	KREMOWY CIEMNY	GABRIEL CHEMIE-SAN8GA8287-KREMOWY CIEMNY	75.0000	PLN	75.0000	KG	\N	Inwentura 31.08.2026: 21 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
85	BT006	6	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SAN9GA9517	GRAFITOWY	GABRIEL CHEMIE-SAN9GA9517-GRAFITOWY	69.0000	PLN	69.0000	KG	\N	Inwentura 31.08.2026: 16 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
86	BT007	7	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SAN8GA8327	KREMOWY JASNY	GABRIEL CHEMIE-SAN8GA8327-KREMOWY JASNY	71.0000	PLN	71.0000	KG	\N	Inwentura 31.08.2026: 24 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
87	BT008	8	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	PA9017/16	CZARNY	GABRIEL CHEMIE-PA9017/16-CZARNY	71.0000	PLN	71.0000	KG	\N	Inwentura 31.08.2026: 34 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
88	BT009	9	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SAN9017/16	CZARNY	GABRIEL CHEMIE-SAN9017/16-CZARNY	59.0000	PLN	59.0000	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
89	BT010	10	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SAN3GA4757	POMARAŃCZOWY	GABRIEL CHEMIE-SAN3GA4757-POMARAŃCZOWY	116.0000	PLN	116.0000	KG	\N	Inwentura 31.08.2026: 26 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
90	BT011	11	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SAN8GA8267	CIEMNY BRĄZ	GABRIEL CHEMIE-SAN8GA8267-CIEMNY BRĄZ	75.0000	PLN	75.0000	KG	\N	Inwentura 31.08.2026: 15 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
91	BT012	12	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	SAN8GA7957	BEŻOWY	GABRIEL CHEMIE-SAN8GA7957-BEŻOWY	75.0000	PLN	75.0000	KG	\N	Inwentura 31.08.2026: 16 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
92	BT013	13	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	HP400331/40	CZERWONY	GABRIEL CHEMIE-HP400331/40-CZERWONY	75.0000	PLN	75.0000	KG	\N	Inwentura 31.08.2026: 28.5 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
93	BT014	14	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	HP300121/40	POMARAŃCZOWY	GABRIEL CHEMIE-HP300121/40-POMARAŃCZOWY	75.0000	PLN	75.0000	KG	\N	Inwentura 31.08.2026: 7.5 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
94	BT015	15	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	HP9EA1331	SZARY	GABRIEL CHEMIE-HP9EA1331-SZARY	14.6000	PLN	14.6000	KG	\N	Inwentura 31.08.2026: 15 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
95	BT016	16	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	HP99611	CZARNY	GABRIEL CHEMIE-HP99611-CZARNY	16.0000	PLN	16.0000	KG	\N	Inwentura 31.08.2026: 50 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
96	BT017	17	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	HP1GA2787UV	BIAŁY	GABRIEL CHEMIE-HP1GA2787UV-BIAŁY	73.6300	PLN	73.6300	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
97	BT018	18	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	BIOL6EB3907	TURKUSOWY	GABRIEL CHEMIE-BIOL6EB3907-TURKUSOWY	43.0000	PLN	43.0000	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
98	BT019	19	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	PET 19997	BIAŁY	GABRIEL CHEMIE-PET 19997-BIAŁY	86.0000	PLN	86.0000	KG	\N	Inwentura 31.08.2026: 9 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
99	BT020	20	26	DB002	GABRIEL CHEMIE	GABRIEL	BARWNIK TWORZYWA		\N	PC5GB4867	NIEBIESKI	GABRIEL CHEMIE-PC5GB4867-NIEBIESKI	15.2900	PLN	15.2900	KG	\N	Inwentura 31.08.2026: 23 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
100	BT021	21	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-80669B	CIEMNY SZARY	GM COLOR-GM-80669B-CIEMNY SZARY	16.9000	PLN	16.9000	KG	\N	Inwentura 31.08.2026: 9 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
101	BT022	22	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-43357E	ZIELONY	GM COLOR-GM-43357E-ZIELONY	32.1000	PLN	32.1000	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
102	BT023	23	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-32807E	CZERWONY	GM COLOR-GM-32807E-CZERWONY	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 17 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
103	BT024	24	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-326	(F) CZARNY	GM COLOR-GM-326-(F) CZARNY	16.9000	PLN	16.9000	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
104	BT025	25	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM 378E	(F) CZARNY	GM COLOR-GM 378E-(F) CZARNY	14.1000	PLN	14.1000	KG	\N	Inwentura 31.08.2026: 82 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
105	BT026	26	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-447	(F) BIAŁY	GM COLOR-GM-447-(F) BIAŁY	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 29 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
106	BT027	27	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-80295	(F) SZARY	GM COLOR-GM-80295-(F) SZARY	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 79 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
107	BT028	28	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-41373P	(F) ZIELONY	GM COLOR-GM-41373P-(F) ZIELONY	27.8000	PLN	27.8000	KG	\N	Inwentura 31.08.2026: 15.5 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
108	BT029	28	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-43676E	(F) ZIELONY	GM COLOR-GM-43676E-(F) ZIELONY	27.8000	PLN	27.8000	KG	\N	Inwentura 31.08.2026: 35 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
109	BT030	29	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-51519P	(F) NIEBIESKI	GM COLOR-GM-51519P-(F) NIEBIESKI	33.4000	PLN	33.4000	KG	\N	Inwentura 31.08.2026: 27 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
110	BT031	30	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-81052P	(F) SZARY	GM COLOR-GM-81052P-(F) SZARY	23.2000	PLN	23.2000	KG	\N	Inwentura 31.08.2026: 58 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
28	SS028	28	7	DT007	EKOBASKET	EKOBASKET	SUROWIEC SYPKI	PC	2	PC	BIAŁY	2-EKOBASKET-PC-BIAŁY	\N	PLN	0.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
111	BT032	31	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-10683P	(F) BEŻOWY	GM COLOR-GM-10683P-(F) BEŻOWY	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 78 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
112	BT033	32	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-80690E	C.SZARY	GM COLOR-GM-80690E-C.SZARY	21.5500	PLN	21.5500	KG	\N	Inwentura 31.08.2026: 47 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
113	BT034	33	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-32218E	(F) RÓŻOWY	GM COLOR-GM-32218E-(F) RÓŻOWY	21.5500	PLN	21.5500	KG	\N	Inwentura 31.08.2026: 43 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
114	BT035	34	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-81071P	(F) GRAFITOWY	GM COLOR-GM-81071P-(F) GRAFITOWY	25.4600	PLN	25.4600	KG	\N	Inwentura 31.08.2026: 35 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
115	BT036	35	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-10684P	(F) ŻÓŁTY	GM COLOR-GM-10684P-(F) ŻÓŁTY	22.9800	PLN	22.9800	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
116	BT037	35	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-12485E	(F) ŻÓŁTY	GM COLOR-GM-12485E-(F) ŻÓŁTY	37.5000	PLN	37.5000	KG	\N	Inwentura 31.08.2026: 73 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
117	BT038	36	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM - 12197E	(F) BEŻOWY	GM COLOR-GM - 12197E-(F) BEŻOWY	22.5000	PLN	22.5000	KG	\N	Inwentura 31.08.2026: 72 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
118	BT039	37	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM - 30669	GRANATOWY	GM COLOR-GM - 30669-GRANATOWY	30.1000	PLN	30.1000	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
119	BT040	38	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM - 20057E	POMARAŃCZOWY	GM COLOR-GM - 20057E-POMARAŃCZOWY	30.5000	PLN	30.5000	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
120	BT041	39	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-43107E	(F) CIEMNO ZIELONY	GM COLOR-GM-43107E-(F) CIEMNO ZIELONY	58.8000	PLN	58.8000	KG	\N	Inwentura 31.08.2026: 51 kg; Uwagi: cemno zielony	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
121	BT042	40	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-43114E	(F)TURKUSOWY	GM COLOR-GM-43114E-(F)TURKUSOWY	31.8000	PLN	31.8000	KG	\N	Inwentura 31.08.2026: 53 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
122	BT043	41	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM- 6979E	(F) RÓŻOWY	GM COLOR-GM- 6979E-(F) RÓŻOWY	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 39 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
123	BT044	42	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM - 53281E	(F)NIEBIESKI	GM COLOR-GM - 53281E-(F)NIEBIESKI	29.9000	PLN	29.9000	KG	\N	Inwentura 31.08.2026: 64 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
124	BT045	43	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-32747E	(F)RÓŻOWY	GM COLOR-GM-32747E-(F)RÓŻOWY	47.0000	PLN	47.0000	KG	\N	Inwentura 31.08.2026: 90 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
125	BT046	44	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-20225E	(F)POMARAŃCZOWY	GM COLOR-GM-20225E-(F)POMARAŃCZOWY	78.6000	PLN	78.6000	KG	\N	Inwentura 31.08.2026: 70 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
126	BT047	45	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-80721B	J.SZARY	GM COLOR-GM-80721B-J.SZARY	31.8000	PLN	31.8000	KG	\N	Inwentura 31.08.2026: 1 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
127	BT048	46	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-51745P	NIEBIESKI	GM COLOR-GM-51745P-NIEBIESKI	68.6500	PLN	68.6500	KG	\N	Inwentura 31.08.2026: 0 kg; Uwagi: zmiana nośnika barwnika na GM-53578E	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
128	BT049	47	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-80779S	SZARY	GM COLOR-GM-80779S-SZARY	31.8000	PLN	31.8000	KG	\N	Inwentura 31.08.2026: 13 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
129	BT050	48	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM 31539V	RÓŻOWY	GM COLOR-GM 31539V-RÓŻOWY	28.3300	PLN	28.3300	KG	\N	Inwentura 31.08.2026: 8 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
130	BT051	49	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM 41815V	ZIELONY	GM COLOR-GM 41815V-ZIELONY	29.1300	PLN	29.1300	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
131	BT052	50	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM71079V	BRĄZOWY	GM COLOR-GM71079V-BRĄZOWY	59.0000	PLN	59.0000	KG	\N	Inwentura 31.08.2026: 20 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
132	BT053	51	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-10483B	WANILIOWY	GM COLOR-GM-10483B-WANILIOWY	29.1300	PLN	29.1300	KG	\N	Inwentura 31.08.2026: 51 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
133	BT054	52	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-91237E	SREBRNY BROKAT	GM COLOR-GM-91237E-SREBRNY BROKAT	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 1 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
134	BT055	53	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-90631S	BIAŁY	GM COLOR-GM-90631S-BIAŁY	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 15 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
135	BT056	54	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-9766	BIAŁY	GM COLOR-GM-9766-BIAŁY	32.2000	PLN	32.2000	KG	\N	Inwentura 31.08.2026: 8 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
136	BT057	55	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-51310S	NIEBIESKI	GM COLOR-GM-51310S-NIEBIESKI	10.6500	PLN	10.6500	KG	\N	Inwentura 31.08.2026: 9 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
137	BT058	56	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-11145E	POMARAŃCZOWY	GM COLOR-GM-11145E-POMARAŃCZOWY	38.8300	PLN	38.8300	KG	\N	Inwentura 31.08.2026: 21 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
138	BT059	57	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-418	BIAŁY	GM COLOR-GM-418-BIAŁY	57.0000	PLN	57.0000	KG	\N	Inwentura 31.08.2026: 29 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
139	BT060	58	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-415	BIAŁY	GM COLOR-GM-415-BIAŁY	72.0000	PLN	72.0000	KG	\N	Inwentura 31.08.2026: 12 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
140	BT061	59	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-31188D	RÓŻOWY	GM COLOR-GM-31188D-RÓŻOWY	60.0000	PLN	60.0000	KG	\N	Inwentura 31.08.2026: 56 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
141	BT062	60	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-9198	\N	GM COLOR-GM-9198	33.5400	PLN	33.5400	KG	\N	Inwentura 31.08.2026: 12 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
142	BT063	61	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W2-127L	ŻÓŁTY	WEST-W2-127L-ŻÓŁTY	29.6400	PLN	29.6400	KG	\N	Inwentura 31.08.2026: 9 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
1	SS001	1	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	HDPE	1	HDPE - HOSTALEN GC 7260	NATURALNY	1-POLIMER-HDPE-HOSTALEN-GC-7260-NATURAL	5.8000	PLN	5.8000	KG	3	PC 12.80 UR - transparentne tworzywo, Wykorzystujemy je do produkcji : KHG - wszystkie elementy ; L&P oraz HIC - do produkcji ŁAPKA (PL, DE,AT) ; LIDERPOOL (zaślepka basenowa)	2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
2	SS002	2	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PA6 GF 30%	1	PA6 - PLASTMID 6 B28 G6	CZARNY	1-POLIMER-PA6-GF30%-PLASTAMID-6-B28-G6-CZARNY	11.4000	PLN	11.4000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
36	SS036	36	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	PP GF 30%	1	SCOLEFIN 53-G	NATURALNY	1-RESINEX-PP-GF30%-SCOLEFIN-53G-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
3	SS003	3	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PA6 GF 25%	1	PA6 - PLASTMID 6 B28 G5	NATURALNY	1-POLIMER-PA6-GF25%-PLASTAMID-6 B28-G5-NATURAL	13.0000	PLN	13.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
4	SS004	4	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PA6 GF 50%	1	PA6 - PLASTMID 6 B28 G1	NATURALNY	1-POLIMER-PA6-GF50%-PLASTAMID-6-B28-G10-NATURAL	13.0000	PLN	13.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
5	SS005	5	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PA6	1	PA6 - PLASTMID 6 B28 CR	NATURALNY	1-POLIMER-PA6-PLASTAMID-6-B28-CR-NATURAL	11.5000	PLN	11.5000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
6	SS006	6	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PP	1	PP TATREN RM 45 55	NATURALNY	1-POLIMER-PP-TATREN-RM-4555-NATURAL	6.4000	PLN	6.4000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
7	SS007	7	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PP	1	PP MOPLEN EP548R	BIAŁY	1-POLIMER-PP-MOPLEN-EP548R-BIAŁY	6.7000	PLN	6.7000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
8	SS008	8	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PP HOMO	1	TATREN HT 2511	NATURALNY	1-POLIMER-PP-HOMO-TATREN-HT-2511-NATURAL	5.8500	PLN	5.8500	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
9	SS009	9	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PS	1	SYNTHOS PS HI 552 M	NATURALNY	1-POLIMER-PS-SYNTHOS-PS-HI-552 M-NATURAL	8.1000	PLN	8.1000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
10	SS010	10	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PS	1	SYNTHOS PS GP-525	NATURALNY	1-POLIMER-PS-SYNTHOS PS GP 525-NATURAL	7.8000	PLN	7.8000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
11	SS011	11	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PC	1	12.20 UR	TRANSPARENT	1-POLIMER-PC-12.20 UR-TRANSPARENT	10.9000	PLN	10.9000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
12	SS012	\N	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PA6	1	PA6 bez włókna - B1	NATURALNY	1-POLIMER-PA6	\N		\N		\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
13	SS013	12	1	DT001	POLIMER PROJEKT Sp. z o.o.	POLIMER	SUROWIEC SYPKI	PC	1	12.80 UR	TRANSPARENT	1-POLIMER-PC-12.80 UR-TRANSPARENT	11.5000	PLN	11.5000	KG	3	PC 12.80 UR - transparentne tworzywo, Wykorzystujemy je do produkcji : KHG - wszystkie elementy ; L&P oraz HIC - do produkcji ŁAPKA (PL, DE,AT) ; LIDERPOOL (zaślepka basenowa)	2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
14	SS014	13	2	DT002	KRAIBURG TPE GmbH&Co	KRAIBURG	SUROWIEC SYPKI	TPE-S	1	TF6OQD-LCNT_B102	NATURALNY	1-KRAIBURG-TPE-S_TF6OQD-LCNT_B102-NATURAL	7.9500	EUR	34.5825	KG	60		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
15	SS015	14	2	DT002	KRAIBURG TPE GmbH&Co	KRAIBURG	SUROWIEC SYPKI	TPE-S	1	HRC9480/230	NATURALNY	1-KRAIBURG-TPE-S_HRC9480/230-NATURAL	3.6800	EUR	16.0080	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
16	SS016	15	2	DT002	KRAIBURG TPE GmbH&Co	KRAIBURG	SUROWIEC SYPKI	TPE-S	1	HRC9480/451	NATURALNY	1-KRAIBURG-TPE-S_HRC9480/451-NATURAL	3.7600	EUR	16.3560	KG	50		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
17	SS017	16	3	DT003	GRANPOL Sp. Z o.o.	GRANPOL	SUROWIEC SYPKI	TPE-S	1	GPL-GRANSEB -  45G/000/139	NATURALNY	1-GRANPOL-TPE-S_GPL-GRANSEB-45G/000/139-NATURAL	12.3500	EUR	53.7225	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
18	SS018	17	3	DT003	GRANPOL Sp. Z o.o.	GRANPOL	SUROWIEC SYPKI	TPE-S	1	GPL-GRANSEB - 80G/000/139	NATURALNY	1-GRANPOL-TPE-S_GPL-GRANSEB-80G/000/139-NATURAL	13.0900	EUR	56.9415	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
19	SS019	18	3	DT003	GRANPOL Sp. Z o.o.	GRANPOL	SUROWIEC SYPKI	TPE-S	1	GPL-GRANSEB 75G/transp1/139	NATURALNY	1-GRANPOL-TPE-S_GPL-GRANSEB-75G/transp1/139-NATURAL	14.3800	EUR	62.5530	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
20	SS020	19	4	DT004	BCD Polymers Sp. z o.o.	BCD	SUROWIEC SYPKI	HDPE	1	HDPE - SIBUR PE	NATURALNY	1-BCD-HDPE-SIBUR-PE-NATURAL	8.0000	PLN	8.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
21	SS021	20	4	DT004	BCD Polymers Sp. z o.o.	BCD	SUROWIEC SYPKI	PP	1	Tipplen K 295 A	NATURALNY	1-BCD-PP-TIPPLEN-K295A-NATURAL	5.9800	PLN	5.9800	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
22	SS022	21	4	DT004	BCD Polymers Sp. z o.o.	BCD	SUROWIEC SYPKI	PP	1	TATREN- IM2263	NATURALNY	1-BCD-PP-TATREN-IM2263-NATURAL	5.5000	PLN	5.5000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
23	SS023	22	5	DT005	TER Plastics	TER	SUROWIEC SYPKI	PA6	1	TEREZ B305	NATURALNY	1-TERPLASTICS-PA6-TEREZ-B305-NATURAL	2.7500	EUR	11.9625	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
24	SS024	23	6	DT006	EMIPAK Jarosław Stoliński	EMIPAK	SUROWIEC SYPKI	PC	2	PC	BIAŁY	2-EMIPAK-PC-BIAŁY	6.0000	PLN	6.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
25	SS025	25	7	DT007	EKOBASKET	EKOBASKET	SUROWIEC SYPKI	ABS	2	ABS	BIAŁY	2-EKOBASKET-ABS-BIAŁY	\N	PLN	0.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
26	SS026	26	7	DT007	EKOBASKET	EKOBASKET	SUROWIEC SYPKI	ABS	2	ABS	NATURALNY	2-EKOBASKET-ABS-NATURAL	\N	PLN	0.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
27	SS027	27	7	DT007	EKOBASKET	EKOBASKET	SUROWIEC SYPKI	PP+20T	2	PP+20T	CZARNY	2-EKOBASKET-PP+20T-CZARNY	\N	PLN	0.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
29	SS029	29	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	ABS	1	ABS HI 121H	NATURALNY	1-RESINEX-ABS-HI121H-NATURAL	4.2000	PLN	4.2000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
30	SS030	30	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	ABS	1	ABS HF380	BIAŁY	1-RESINEX-ABS-HF380-BIAŁY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
31	SS031	31	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	ASA	1	ASA  LG CHEM LI911	NATURALNY	1-RESINEX-ASA-LG-CHEM-LI911-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
32	SS032	32	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	POM	1	POM C27N	NATURALNY	1-RESINEX-POM-C27N-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
33	SS033	33	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	POM	1	HOSTAFORM C9021	NATURALNY	1-RESINEX-POM-HOSTAFORM-C9021-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
34	SS034	34	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	PP	1	PP RANDOM YUPLENE R392Y	NATURALNY	1-RESINEX-PP-RANDOM-YUPLENE-R392Y-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
35	SS035	35	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	PP	1	PP RANDOM ADVANCE 400	NATURALNY	1-RESINEX-PP-RANDOM-ADVANCE-400-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
37	SS037	37	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	PP GF 30%	1	Mafill CR HG 3541	NATURALNY	1-RESINEX-PP-GF30%-MAFILL-CR-HG3541-NATURAL	1.3500	EUR	5.8725	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
38	SS038	38	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	TPE	1	ELASTOMER 30A RAVAGO	NATURALNY	1-RESINEX-TPE-ELASTOMER 30A RAVAGO-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
39	SS039	38	8	DT008	RESINEX	RESINEX	SUROWIEC SYPKI	TPU	1	RAVATHANE 130A93	NATURALNY	1-RESINEX-TPU-RAVATHANE-130A93	3.9000	EUR	16.9650	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
40	SS040	39	9	DT009	PROGRESS POLYMER COMPOUNDS Julia Trzebuniak	PROGRESS	SUROWIEC SYPKI	ABS	2	ABS	CZARNY	2-PROGRESS-ABS-CZARNY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
41	SS041	40	9	DT009	PROGRESS POLYMER COMPOUNDS Julia Trzebuniak	PROGRESS	SUROWIEC SYPKI	PP	2	rPP CZARNY	CZARNY	2-PROGRESS-PP-CZARNY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
42	SS042	41	9	DT009	PROGRESS POLYMER COMPOUNDS Julia Trzebuniak	PROGRESS	SUROWIEC SYPKI	PP	2	rPP BIAŁY	BIAŁY	2-PROGRESS-PP-BIAŁY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
43	SS043	42	10	DT010	PRT RADOMSKO	RADOMSKO	SUROWIEC SYPKI	PET	2	r+PET CL80	NATURALNY	2-RADOMSKO-PET-CL80-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
44	SS044	43	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	ABS	1	ABS	RÓŻOWY	1-ARGUS-ABS-RÓŻOWY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
45	SS045	44	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	ABS	1	ABS	ŻÓŁTY	1-ARGUS-ABS-ŻÓŁTY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
46	SS046	45	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	ABS	1	ABS	MIĘTA	1-ARGUS-ABS-MIĘTA	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
47	SS047	46	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	ABS	1	ABS	CORAL	1-ARGUS-ABS-CORAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
48	SS048	47	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	ABS	1	ABS	LIME	1-ARGUS-ABS-LIME	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
49	SS049	48	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	ABS	1	ABS	CLOUD	1-ARGUS-ABS-CLOUD	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
50	SS050	49	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	PC	2	rPC	CZARNY	2-ARGUS-PC-CZARNY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
51	SS051	50	11	DT011	Jakub Mejer Argus	ARGUS	SUROWIEC SYPKI	PC	2	rPC	BIAŁY	2-ARGUS-PC-BIAŁY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
52	SS052	51	12	DT012	PLASTPRO	PLASTPRO	SUROWIEC SYPKI	PC	2	PC	BIAŁY	1-PLASTPRO-PC-BIAŁY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
53	SS053	52	12	DT012	PLASTPRO	PLASTPRO	SUROWIEC SYPKI	PC	1	PC	BIAŁY	2-PLASTPRO-PC-BIAŁY	\N		6.3000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
54	SS054	53	13	DT013	KGL S.A.	KGL	SUROWIEC SYPKI	ASA	1	ASA - STAREX WR-9120 NP.	NATURALNY	1-KGLSA-ASA-STAREX-WR-9120NP-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
55	SS055	54	13	DT013	KGL S.A.	KGL	SUROWIEC SYPKI	ASA	1	ASA - STAREX WR9120 W94848	BIAŁY	1-KGLSA-ASA-STAREX-WR9120-W94848-BIAŁY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
56	SS056	55	14	DT014	EKOCHEM	EKOCHEM	SUROWIEC SYPKI	TPE	2	TPE	NATURALNY	2-EKOCHEM-TPE-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
57	SS057	56	15	DT015	HEXPOL	HEXPOL	SUROWIEC SYPKI	TPE	1	TPE	TRANSPARENT	1-HEXPOL-TPE-DRYFLEX-UV-403731-TRANSPARENT	2.0000	EUR	8.7000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
58	SS058	57	15	DT015	HEXPOL	HEXPOL	SUROWIEC SYPKI		1	DRYFLEX-UV-803731-1	TRANSPARENT	1-HEXPOL-DRYFLEX-UV-803731-1_TRANSPARENT	\N		\N		\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
59	SS059	58	16	DT016	NEXEO PLASTICS	NEXEO	SUROWIEC SYPKI		1	ABS MAGNUM 8391	NATURALNY	1-NEXEO-ABS-MAGNUM8391-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
60	SS060	59	17	DT017	GRUPA AZOTY	AZOTY	SUROWIEC SYPKI	PA6	1	PA6 - TARNAMID T27	NATURALNY	1-AZOTY-PA6-TARNAMID-T27-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
61	SS061	60	17	DT017	GRUPA AZOTY	AZOTY	SUROWIEC SYPKI	PA6 GF 25%	1	PA6 - TARNAMID T-27 GF25	NATURALNY	1-AZOTY-PA6-GF25%-TERNAMID-T-27-GF25-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
62	SS062	61	18	DT018	PLASTICS SOLUTION	Plastics	SUROWIEC SYPKI	PS	2	PS	CZARNY	2-PLASTICS-PS-CZARNY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
63	SS063	62	19	DT019	ALFA-PLAST	ALFAPLAST	SUROWIEC SYPKI	PP	2	PP	BIAŁY	2-ALFAPLAST-PP-BIAŁY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
64	SS064	63	20	DT020	PACYGA	PACYGA	SUROWIEC SYPKI	PA6	1	PA6 + 15% DREWNA	NATURALNY	1-PACYGA-PA6-15% DREWNA-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
65	SS065	64	20	DT020	PACYGA	PACYGA	SUROWIEC SYPKI	PLA	2	PLA Z KONOPIĄ	NATURALNY	2-PACYGA-PLA-KONOPIA-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
66	SS066	65	21	DT021	A&P	A&P	SUROWIEC SYPKI	PS	2	PS HIPS	BIAŁY	2-A&P-PS-HIPS-WIESZAKI-BIAŁY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
67	SS067	66	22	DT022	H&Z	H&Z	SUROWIEC SYPKI	PS	2	PS HIPS	CZARNY	2-H&Z-PS-HIPS-CZARNY	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
68	SS068	67	23	DT023	KIPIOT	KIPIOT	SUROWIEC SYPKI	TPU	2	APILON 52A 6505	NATURALNY	2-KIPIOT-TPU-APILON 52A 6505-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
69	SS069	68	24	DT024	BENVIC	BENVIC	SUROWIEC SYPKI	PVC	1	PVC-ST/P81CZ-O	CZARNY	1-BENVIC-PVC-ST/P81CZ-O-CZARNY	7.9000	PLN	7.9000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
70	SS070	69	29	DT025	LOOPLIFE POLYMERS	LOOPLIFE	SUROWIEC SYPKI	PLA	2	R-PLA05A-30-MK	NATURALNY	2-LOOPLIFE-PLA-05A30-MK-NATURAL	\N		\N	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
71	SS071	70	9	DT009	PROGRESS POLYMER COMPOUNDS Julia Trzebuniak	PROGRESS	SUROWIEC SYPKI	ABS	2	ABS	BIAŁY	2-PROGRESS-ABS-BIAŁY	5.2000	PLN	5.2000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
72	SS072	71	4	DT004	BCD Polymers Sp. z o.o.	BCD	SUROWIEC SYPKI	PP	1	TATREN HT 2511	NATURALNY	1-BCD-PP-TATREN-HT-2511-NATURAL	6.0000	PLN	6.0000	KG	\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
73	SS073	72	4	DT004	BCD Polymers Sp. z o.o.	BCD	SUROWIEC SYPKI	HDPE	1		NATURALNY	1-BCD-HDPE-HOSTALEN-GC-7260-NATURAL	5.5000	PLN	5.5000		\N		2026-09-25 14:52:56.982746+00	2026-09-25 14:57:25.490839+00
143	BT064	62	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W7-259L	ZIELONY	WEST-W7-259L-ZIELONY	67.3000	PLN	67.3000	KG	\N	Inwentura 31.08.2026: 23 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
144	BT065	63	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W7131	ZIELONY	WEST-W7131-ZIELONY	36.8000	PLN	36.8000	KG	\N	Inwentura 31.08.2026: 28 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
145	BT066	64	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W707	GROSZKOWY	WEST-W707-GROSZKOWY	29.0000	PLN	29.0000	KG	\N	Inwentura 31.08.2026: 16 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
146	BT067	65	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W9-60U	SZARY	WEST-W9-60U-SZARY	30.0000	PLN	30.0000	KG	\N	Inwentura 31.08.2026: 29 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
147	BT068	66	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W9-36U	SZARY	WEST-W9-36U-SZARY	31.0700	PLN	31.0700	KG	\N	Inwentura 31.08.2026: 27 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
148	BT069	67	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	ŚRODEK EPRP50PS	SPIENIACZ	WEST-ŚRODEK EPRP50PS-SPIENIACZ	30.1200	PLN	30.1200	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
149	BT070	68	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W3-18/1	POMARAŃCZOWY	WEST-W3-18/1-POMARAŃCZOWY	29.4500	PLN	29.4500	KG	\N	Inwentura 31.08.2026: 7 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
150	BT071	69	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W9-67U	SZARY	WEST-W9-67U-SZARY	39.0600	PLN	39.0600	KG	\N	Inwentura 31.08.2026: 33 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
151	BT072	70	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W8-43/1	BRĄZOWY	WEST-W8-43/1-BRĄZOWY	49.9700	PLN	49.9700	KG	\N	Inwentura 31.08.2026: 28 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
152	BT073	71	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W6-125	(F) NIEBIESKI	WEST-W6-125-(F) NIEBIESKI	84.5500	PLN	84.5500	KG	\N	Inwentura 31.08.2026: 77 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
153	BT074	72	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W7-76	(F) ZIELONY	WEST-W7-76-(F) ZIELONY	76.0000	PLN	76.0000	KG	\N	Inwentura 31.08.2026: 30 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
154	BT075	73	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W2-73/1	(F) ŻÓŁTY	WEST-W2-73/1-(F) ŻÓŁTY	49.2900	PLN	49.2900	KG	\N	Inwentura 31.08.2026: 63 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
155	BT076	74	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W5-17	(F)FIOLETOWY	WEST-W5-17-(F)FIOLETOWY	35.1500	PLN	35.1500	KG	\N	Inwentura 31.08.2026: 46 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
156	BT077	75	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W5-25	(F)FIOLETOWY	WEST-W5-25-(F)FIOLETOWY	33.3500	PLN	33.3500	KG	\N	Inwentura 31.08.2026: 41 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
157	BT078	76	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W6-146	(F)TURKUSOWY	WEST-W6-146-(F)TURKUSOWY	39.0000	PLN	39.0000	KG	\N	Inwentura 31.08.2026: 45 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
158	BT079	77	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W6-69	(F)NIEBIESKI	WEST-W6-69-(F)NIEBIESKI	36.5800	PLN	36.5800	KG	\N	Inwentura 31.08.2026: 70 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
159	BT080	78	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W4-62	(F)BORDOWY	WEST-W4-62-(F)BORDOWY	28.3700	PLN	28.3700	KG	\N	Inwentura 31.08.2026: 20 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
160	BT081	79	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W4-154U	(F) CZERWONY	WEST-W4-154U-(F) CZERWONY	13.8900	PLN	13.8900	KG	\N	Inwentura 31.08.2026: 20 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
161	BT082	80	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W2-68	(F) ŻÓŁTY	WEST-W2-68-(F) ŻÓŁTY	29.9300	PLN	29.9300	KG	\N	Inwentura 31.08.2026: 42 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
162	BT083	81	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W9-173	SZARY	WEST-W9-173-SZARY	32.3000	PLN	32.3000	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
163	BT084	82	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W003/1	EKO BIAŁY	WEST-W003/1-EKO BIAŁY	13.8900	PLN	13.8900	KG	\N	Inwentura 31.08.2026: 58 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
164	BT085	83	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W4-99	RÓŻOWY	WEST-W4-99-RÓŻOWY	29.9300	PLN	29.9300	KG	\N	Inwentura 31.08.2026: 60 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
165	BT086	84	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W9-41	SZARY	WEST-W9-41-SZARY	27.0000	PLN	27.0000	KG	\N	Inwentura 31.08.2026: 8 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
166	BT087	85	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W2334	POMARAŃCZOWY	WEST-W2334-POMARAŃCZOWY	39.4300	PLN	39.4300	KG	\N	Inwentura 31.08.2026: 80 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
167	BT088	86	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W2-01	ŻÓŁTY	WEST-W2-01-ŻÓŁTY	38.6000	PLN	38.6000	KG	\N	Inwentura 31.08.2026: 35 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
168	BT089	87	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	UV DREWNIAK	UV	WEST-UV DREWNIAK-UV	65.7500	PLN	65.7500	KG	\N	Inwentura 31.08.2026: 105 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
169	BT090	88	25	DB001	LIFO COLOR	LIFOCOLOR	BARWNIK TWORZYWA		\N	20-91147F PC	BIAŁY	LIFO COLOR-20-91147F PC-BIAŁY	72.3800	PLN	72.3800	KG	\N	Inwentura 31.08.2026: 120 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
170	BT091	89	25	DB001	LIFO COLOR	LIFOCOLOR	BARWNIK TWORZYWA		\N	20-91568F PA	BIAŁY	LIFO COLOR-20-91568F PA-BIAŁY	65.7500	PLN	65.7500	KG	\N	Inwentura 31.08.2026: 31 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
171	BT092	90	25	DB001	LIFO COLOR	LIFOCOLOR	BARWNIK TWORZYWA		\N	30-431962 ROUGE	CZERWONY	LIFO COLOR-30-431962 ROUGE-CZERWONY	66.0200	PLN	66.0200	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
172	BT093	91	25	DB001	LIFO COLOR	LIFOCOLOR	BARWNIK TWORZYWA		\N	33521F PET	(F) RÓŻOWY	LIFO COLOR-33521F PET-(F) RÓŻOWY	38.7000	PLN	38.7000	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
176	BT097	95	25	DB001	LIFO COLOR	LIFOCOLOR	BARWNIK TWORZYWA		\N	SCHWARZ 2620 PC	CZARNY	LIFO COLOR-SCHWARZ 2620 PC-CZARNY	18.0000	PLN	18.0000	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
183	BT104	102	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W5-02	FIOLETOWY	WEST-W5-02-FIOLETOWY	34.8800	PLN	34.8800	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
184	BT105	103	28	DB004	WEST	WEST	BARWNIK TWORZYWA		\N	W7-272	ZIELONY PASTEL	WEST-W7-272-ZIELONY PASTEL	35.7200	PLN	35.7200	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
187	BT108	106	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-53578E	NIEBIESKI	GM COLOR-GM-53578E-NIEBIESKI	27.1000	PLN	27.1000	KG	\N	Inwentura 31.08.2026: 25 kg; Uwagi: zmiana nośnika barwnika GM-51745P	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
188	BT109	107	27	DB003	GM COLOR	GM	BARWNIK TWORZYWA		\N	GM-50977	NIEBIESKI	GM COLOR-GM-50977-NIEBIESKI	32.8000	PLN	32.8000	KG	\N	Inwentura 31.08.2026: 25 kg; Uwagi: MODUŁY	2026-09-29 06:57:09.187198+00	2026-09-29 06:57:09.187198+00
181	BT102	100	5	DT005	TER PLASTICS	TER	BARWNIK TWORZYWA		\N	TEREZ XG DE 9000	CZARNY	TER PLASTICS-TEREZ XG DE 9000-CZARNY	29.1000	PLN	29.1000	KG	\N	Inwentura 31.08.2026: 13 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
186	BT107	105	35	DB005	COLOR TONE	COLOR TONE	BARWNIK TWORZYWA		\N	C7226	ZIELONY	COLOR TONE-C7226-ZIELONY	29.9000	PLN	29.9000	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
185	BT106	104	35	DB005	COLOR TONE	COLOR TONE	BARWNIK TWORZYWA		\N	C4146	RÓŻOWY	COLOR TONE-C4146-RÓŻOWY	32.4900	PLN	32.4900	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
182	BT103	101	35	DB005	COLOR TONE	COLOR TONE	BARWNIK TWORZYWA		\N	BIAŁY C001	BIAŁY	COLOR TONE-BIAŁY C001-BIAŁY	14.5000	PLN	14.5000	KG	\N	Inwentura 31.08.2026: 21 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
175	BT096	94	35	DB005	COLOR TONE	COLOR TONE	BARWNIK TWORZYWA		\N	C7010/1	KORAL	COLOR TONE-C7010/1-KORAL	63.5600	PLN	63.5600	KG	\N	Inwentura 31.08.2026: 25 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
180	BT101	99	36	DB006	COLOR PLAST	COLOR PLAST	BARWNIK TWORZYWA		\N	ME 80000 - UNIWERS	BIAŁY	COLOR PLAST-ME 80000 - UNIWERS-BIAŁY	9.0000	PLN	9.0000	KG	\N	Inwentura 31.08.2026: 11 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
179	BT100	98	36	DB006	COLOR PLAST	COLOR PLAST	BARWNIK TWORZYWA		\N	YPE 9437 - UNIWERS	SZARY	COLOR PLAST-YPE 9437 - UNIWERS-SZARY	15.0000	PLN	15.0000	KG	\N	Inwentura 31.08.2026: 16 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
178	BT099	97	36	DB006	COLOR PLAST	COLOR PLAST	BARWNIK TWORZYWA		\N	PE 4353 - UNIWERS	BRĄZOWY	COLOR PLAST-PE 4353 - UNIWERS-BRĄZOWY	18.0000	PLN	18.0000	KG	\N	Inwentura 31.08.2026: 30 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
177	BT098	96	36	DB006	COLOR PLAST	COLOR PLAST	BARWNIK TWORZYWA		\N	TOSAF- WHITE MB - UNIWERS	BRĄZOWY	COLOR PLAST-TOSAF- WHITE MB - UNIWERS-BRĄZOWY	18.0000	PLN	18.0000	KG	\N	Inwentura 31.08.2026: 0 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
174	BT095	93	37	DB007	GLOBAL COLORS	GLOBAL COLORS	BARWNIK TWORZYWA		\N	POLI-CH PINK 36-0527	RÓŻOWY	GLOBAL COLORS-POLI-CH PINK 36-0527-RÓŻOWY	24.0000	PLN	24.0000	KG	\N	Inwentura 31.08.2026: 12 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
173	BT094	92	37	DB007	GLOBAL COLORS	GLOBAL COLORS	BARWNIK TWORZYWA		\N	POLI-CH PINK PS 36-0492	RÓZOWY	GLOBAL COLORS-POLI-CH PINK PS 36-0492-RÓZOWY	38.4500	PLN	38.4500	KG	\N	Inwentura 31.08.2026: 16 kg	2026-09-29 06:57:09.187198+00	2026-09-29 06:59:47.446517+00
189	BT110	\N	\N	\N	(wymaga uzupełnienia)	(wymaga uzupełnienia)	BARWNIK TWORZYWA		\N	191384	BEŻOWY	191384-BEŻOWY (wymaga uzupełnienia)	\N	PLN	\N	KG	\N	Inwentura 31.08.2026: 50 kg; Uwagi: pozycja spod sumy arkusza Barwniki — uzupełnić dostawcę i cenę	2026-09-29 06:59:47.446517+00	2026-09-29 06:59:47.446517+00
190	BT111	\N	\N	\N	(wymaga uzupełnienia)	(wymaga uzupełnienia)	BARWNIK TWORZYWA		\N	191385	SZARY	191385-SZARY (wymaga uzupełnienia)	\N	PLN	\N	KG	\N	Inwentura 31.08.2026: 13 kg; Uwagi: pozycja spod sumy arkusza Barwniki — uzupełnić dostawcę i cenę	2026-09-29 06:59:47.446517+00	2026-09-29 06:59:47.446517+00
191	BT112	\N	\N	\N	(wymaga uzupełnienia)	(wymaga uzupełnienia)	BARWNIK TWORZYWA		\N	191378	J.SZARY	191378-J.SZARY (wymaga uzupełnienia)	\N	PLN	\N	KG	\N	Inwentura 31.08.2026: 0 kg; Uwagi: pozycja spod sumy arkusza Barwniki — uzupełnić dostawcę i cenę	2026-09-29 06:59:47.446517+00	2026-09-29 06:59:47.446517+00
192	SS074	\N	19	DT019	PLASTOPLAN	PLASTOPLAN	SUROWIEC SYPKI	ABS	1	ABS HI 121H	NATURALNY	1-PLASTOPLAN-ABS-HI121H-NATURAL	11.9190	PLN	11.9190	KG	\N	Karta utworzona z inwentury 09.2026 (wymaga uzupełnienia: czas dostawy, dane techniczne)	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
193	SS075	\N	19	DT019	PLASTOPLAN	PLASTOPLAN	SUROWIEC SYPKI	ASA	1	ASA LG CHEM LI911	NATURALNY	1-PLASTOPLAN-ASA-LG-LI911-NP.	12.1900	PLN	12.1900	KG	\N	Karta utworzona z inwentury 09.2026 (wymaga uzupełnienia: czas dostawy, dane techniczne)	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
194	SS076	\N	4	DT004	BCD	BCD	SUROWIEC SYPKI	PP	1	RANDOM TIPPLEN R960A	NATURALNY	1-BCD-PP-TIPPLEN-R960A-NATURAL	5.8000	PLN	5.8000	KG	\N	Karta utworzona z inwentury 09.2026 (wymaga uzupełnienia: czas dostawy, dane techniczne)	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
195	SS077	\N	14	DT014	EKOCHEM	EKOCHEM	SUROWIEC SYPKI	TPE	2	TPE	NATURALNY	2-EKOCHEM-TPE-NATURAL (partia 8,70 zł/kg)	8.7000	PLN	8.7000	KG	\N	Karta utworzona z inwentury 09.2026 (wymaga uzupełnienia: czas dostawy, dane techniczne)	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
196	SS078	\N	15	DT015	HEXPOL	HEXPOL	SUROWIEC SYPKI	TPE	1	Dryflex-PCR-403621-2	TRANSPARENT	1-HEXPOL-DRYFLEX-PCR-403621-2_TRANSPARENT	17.0520	PLN	17.0520	KG	\N	Karta utworzona z inwentury 09.2026 (wymaga uzupełnienia: czas dostawy, dane techniczne); zamiennik Kraiburga HRC9480/230	2026-09-29 07:45:53.388955+00	2026-09-29 07:45:53.388955+00
\.


--
-- Data for Name: mold_events; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.mold_events (id, mold_id, event_date, event_type, description, performed_by, cost_pln, downtime_h, cycles_at, created_at) FROM stdin;
\.


--
-- Data for Name: mold_photos; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.mold_photos (id, mold_id, slot, filename, width, height, data, thumb, uploaded_at) FROM stdin;
\.


--
-- Data for Name: molds; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.molds (id, mold_no, ordinal, name, dim_1, dim_2, dim_3, weight_kg, storage, status, notes, created_at, updated_at, client_id, owner, maker, drawing_no, inventory_no, made_year, received_date, value_pln, mold_type, cavities, runner, hot_zones, gate_type, slides, ejection, inserts, steel, hardness_hrc, surface, mold_height_mm, opening_stroke_mm, centering_ring_mm, nozzle_radius_mm, clamp_force_t, machines, cooling_circuits, tool_temp_c, connections, cycle_s, shot_weight_g, material_hint, spi_class, guaranteed_cycles, initial_cycles, service_interval_cycles) FROM stdin;
205	218	205	FIBOO MATA FISHKA (RYBA)	\N	\N	\N	\N		SPRAWNA	MATRYCA OD TALERZYKA PIZZY	2026-10-16 06:19:15.934581+00	2026-10-16 08:05:07.646795+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	MATRYCA OD TALERZYKA PIZZY	\N	\N	\N	\N	\N	\N	\N	\N	3, 4	\N	\N	\N	39.80	62.60	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	\N	\N	\N	\N
76	087	76	WINAB	156.0	206.0	208.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1	001	1	RAIS rączka 2 - elastomer	155.0	205.0	167.0	31.0	Z6	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2	002	2	RAIS rączka 3 - elastomer	155.0	205.0	200.0	38.0	Z6	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	003	3	RAIS rączka 4 - elastomer	195.0	245.0	210.0	62.0	Z6	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4	004	4	RAIS rączka 6 - elastomer	195.0	245.0	208.0	68.0	Z6	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5	005	5	RAIS rączka 2 - PP	358.0	346.0	230.0	155.0	Z6	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6	006	6	RAIS rączka 3 - PP	360.0	346.0	230.0	91.0	Z6	SPRAWNA	Rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7	007	7	RAIS rączka 6 - PP	290.0	345.0	230.0	113.0	Z6	SPRAWNA	Rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8	008	8	RAIS rączka 4 - PP	346.0	346.0	212.0	113.0	Z6	SPRAWNA	Rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
9	009	9	Liderpool - pasek elastomerowy	346.0	296.0	217.0	143.0	Z5	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	25	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	\N	\N	44.70	77.00	HRC9480/230 KRAIBURG 55% PP TIPPLEN K295 BCD 45%	\N	\N	\N	\N
10	010	10	Liderpool - zaślepka ABS	245.0	295.0	237.0	107.0	Z5	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	25	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	34.86	50.20	ASA LI911 NATURAL	\N	\N	\N	\N
11	011	11	Liderpool - zaślepkI profilu PVC	196.0	246.0	224.0	64.0	Z5	SPRAWNA	Obracana matryca (bez logo / logo)	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	25	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	Obracana matryca (bez logo / logo)	\N	\N	\N	\N	\N	\N	\N	\N	4, 6	\N	\N	\N	45.70	58.50	ASA STAREX WR9120	\N	\N	\N	\N
12	012	12	Liderpool - zaślepka profilu PVC 181106-B	196.0	246.0	218.0	64.0	Z5	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	25	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4, 5, 6	\N	\N	\N	57.40	90.40	PVC-ST/P81CZ-0	\N	\N	\N	\N
13	013	13	FIBERLAB - korek PVC PRIME	155.0	205.0	190.0	37.0	Z5	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	014	14	FIBERLAB - korek PVC EXPERT	155.0	205.0	175.0	35.0	Z5	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
15	015	15	FIBERLAB - korek PVC SELECT	155.0	205.0	175.0	34.0	Z5	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
16	016	16	FIBERLAB - BOK SZPULI	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	19	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 7	\N	\N	\N	43.60	129.90	REGLANULAT ABS BIAŁY	\N	\N	\N	\N
17	018	17	Wekta - klawisze	155.0	205.0	170.0	32.0	Y3	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
18	019	18	Wekta - video	396.0	446.0	354.0	\N	Y3	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
19	020	19	Wekta - domofon	345.0	345.0	320.0	220.0	Y3	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
20	021	20	Wekta - słuchawka	295.0	275.0	220.0	109.0	Y3	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
21	022	21	Mobilus - koprus	302.0	280.0	337.0	173.0	Z1	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
22	023	22	Mobilus - pierścień	300.0	356.0	356.0	224.0	Z1	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	3	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	31.74	42.30	POM C27N RESINEX	\N	\N	\N	\N
23	024	23	Mobilus - płytka	300.0	275.0	292.0	140.0	Z1	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	3	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	37.42	12.90	ABS HI121H RESINEX	\N	\N	\N	\N
24	025	24	Szczęka duża	243.0	297.0	368.0	168.0	Z1	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
25	026	25	Szczęka mała	197.0	297.0	286.0	90.0	Z1	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
26	027	26	Klimapartner - Bar	156.0	206.0	177.0	33.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
27	028	27	Klimapartner - Klappe	197.0	247.0	216.0	62.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
28	029	28	Euroster - szybka	156.0	206.0	192.0	36.0	Z4	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
29	030	29	Euroster - przycisk szary	155.0	205.0	170.0	34.0	Z4	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
30	031	30	Euroster - przycisk biały	156.0	202.0	175.0	33.0	Z4	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
31	032	31	Euroster - korpus	276.0	296.0	275.0	136.0	Z4	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	6	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	44.31	58.10	ABS HF380 WHITE RESINEX	\N	\N	\N	\N
32	033	32	Euroster - noga + plecy	345.0	245.0	255.0	135.0	Z4	SPRAWNA	Rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	6	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	33.45	42.20	RESINEX-ABS HI121H NATURAL; ABS HF380 WHITE RESINEX	\N	\N	\N	\N
33	034	33	Euroster - front	295.0	275.0	245.0	125.0	Z4	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	6	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	35.55	38.50	RESINEX ABS HF380 WHITE; ABS HF380 WHITE RESINEX	\N	\N	\N	\N
34	035	34	Newmero - klocek żółty	245.0	295.0	215.0	99.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
35	036	35	Newmero - klocek zielony	295.0	345.0	210.0	138.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
36	037	36	Newmero - klocek niebieski	347.0	391.0	216.0	197.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
93	104	93	Regaltags - lizak TPU	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
37	038	37	Newmero - klocek pomarańczowy	345.0	295.0	225.0	147.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
38	039	38	Zortrax - szpula	795.0	450.0	450.0	745.0	Z1	SPRAWNA	Rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
39	040	39	FIBOO - gumka duża	196.0	206.0	172.0	32.0	Z2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
40	041	40	FIBOO - gumka mała	196.0	206.0	180.0	32.0	Z2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
41	042	41	FIBOO - gumka obwodowa	246.0	296.0	261.0	133.0	Z2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
42	043	42	FIBOO - mata 32 x 32 [cm]	430.0	430.0	252.0	133.0	Z2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 7, 8, 9	\N	\N	\N	56.20	250.00	HRC9480/230 KRAIBURG	\N	\N	\N	\N
43	045	43	FIBOO - miska S	200.0	250.0	165.0	51.0	Z2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	34.55	65.00	R+PET CL-80M PRT RADOMSKO	\N	\N	\N	\N
44	046	44	FIBOO - miska M	245.0	295.0	165.0	82.0	Y2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 4	\N	\N	\N	45.60	126.50	R+PET CL-80M PRT RADOMSKO	\N	\N	\N	\N
45	047	45	FIBOO - miska L	245.0	295.0	170.0	86.0	Y2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	45.20	154.80	R+PET CL-80M PRT RADOMSKO	\N	\N	\N	\N
46	048	46	FIBOO- szczotka kot	295.0	205.0	180.0	40.0	Y2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 4	\N	\N	\N	61.20	111.40	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	\N	\N	\N	\N
47	049	47	FIBOO - spowalniacz	197.0	246.0	269.0	87.0	Y2	SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
48	050	48	FIBOO - miska płytka	200.0	250.0	155.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
49	051	49	Scoop V1	196.0	246.0	205.0	65.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
50	052	50	Scoop V2	\N	\N	\N	\N		SPRAWNA	Rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
51	053	51	Scoop V3	156.0	206.0	240.0	47.0		SPRAWNA	Rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
52	061	52	Liderpool - Zaślepka nowa	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	25	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	31.00	48.40	ASA LI911 NATURAL	\N	\N	\N	\N
53	062	53	Regaltags - anglik obtrysk	197.0	247.0	236.0	65.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
54	063	54	Regaltags - klapka ABS	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
55	064	55	Litwin	347.0	540.0	260.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
56	065	56	Dozownik - Piston	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
57	066	57	Dozownik - Stem	297.0	296.0	271.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
58	067	58	Dozownik - Needle	347.0	347.0	338.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
59	068	59	Dozownik - Switch	396.0	296.0	258.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
60	070	60	Dozownik - Actuator	700.0	450.0	536.0	\N		SPRAWNA	7 grzanych kanałów	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	z gorącymi kanałami	\N	gorące kanały	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
61	071	61	Dozownik - Closure	500.0	450.0	359.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
62	073	62	Holypit - Top	247.0	298.0	276.0	\N		SPRAWNA	6 grzanych kanałów	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	4	\N	\N	\N	\N	\N	\N	\N	z gorącymi kanałami	4	gorące kanały	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	18.90	37.60	ABS CLOUD ARGUS	\N	\N	\N	\N
63	074	63	Holypit - Mid	446.0	346.0	330.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	4	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	26.70	68.80	ABS CLOUD ARGUS	\N	\N	\N	\N
64	075	64	Holypit - Bottom	247.0	296.0	230.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	4	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	21.34	31.40	ABS MAGNUM 8391	\N	\N	\N	\N
65	076	65	Fiberlab - spinka M-Clip 5 mm	346.0	346.0	308.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
66	077	66	IVT - pokrywa	396.0	346.0	376.0	\N		SPRAWNA	1 grzany kanał, rdzenie hydrauliczne	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	10	\N	\N	\N	\N	\N	\N	\N	z gorącymi kanałami	1	gorące kanały	1	\N	rdzenie hydrauliczne	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	\N	\N	\N	41.40	222.50	rABS CZARNY PROGRESS	\N	\N	\N	\N
67	078	67	IVT - kondensat	302.0	346.0	386.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	10	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	\N	\N	\N	45.60	287.80	rABS CZARNY PROGRESS	\N	\N	\N	\N
68	079	68	IVT - redukcja - piramida 150	246.0	296.0	378.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	10	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 2	\N	\N	\N	45.90	172.60	PP COPO PROGRESS; rPP CZARNY PROGRESS	\N	\N	\N	\N
69	080	69	IVT - podstawa blachy UP	347.0	347.0	324.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	10	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	\N	\N	\N	27.20	117.20	rABS CZARNY PROGRESS	\N	\N	\N	\N
70	081	70	IVT - podstawa blachy N / BV	345.0	295.0	296.0	\N		SPRAWNA	Wymienna matryca i wypychacze	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wymienna matryca i wypychacze	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
71	082	71	IVT - wkład	298.0	347.0	428.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	10	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	\N	\N	\N	41.00	\N	rABS CZARNY PROGRESS	\N	\N	\N	\N
72	083	72	K&M - pochłaniacz zapachu	346.0	346.0	294.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
73	084	73	HiC - LISTWA RAMKI REJESTRACYJNEJ	596.0	295.0	310.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
74	085	74	Palisander DREWNIIAK- belka	346.0	346.0	372.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
75	086	75	Palisander DREWNIAK - listwa	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	26	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 7	\N	\N	\N	34.90	95.10	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	\N	\N	\N	\N
77	088	77	L&P - Kluczyk S1	156.0	206.0	176.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	17.29	17.90	PRZEMIAŁ POM C27N	\N	\N	\N	\N
78	089	78	L&P - Lapka AT	196.0	296.0	210.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
79	090	79	L&P - Lapka DE	296.0	210.0	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
80	091	80	HARBEST - Plecki 65x25 mm	\N	\N	\N	\N		SPRAWNA	Wymienna matryca	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wymienna matryca	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
81	092	81	HARBEST - Ramka 60x21 mm	\N	\N	\N	\N		SPRAWNA	Wymienna matryca	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wymienna matryca	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
82	093	82	HARBEST - Ramka 70x25 mm	\N	\N	\N	\N		SPRAWNA	Wymienna matryca	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Wymienna matryca	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
83	094	83	EVR 46L	\N	\N	\N	\N		SPRAWNA	6 grzanych kanałów	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	9	\N	\N	\N	\N	\N	\N	\N	z gorącymi kanałami	32	gorące kanały	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 8	\N	\N	\N	20.00	48.50	TEREZ B 305 NATURAL	\N	\N	\N	\N
84	095	84	EVR 56L	\N	\N	\N	\N		SPRAWNA	6 grzanych kanałów	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	9	\N	\N	\N	\N	\N	\N	\N	z gorącymi kanałami	32	gorące kanały	6	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 7, 8	\N	\N	\N	23.30	77.60	TEREZ B 305 NATURAL	\N	\N	\N	\N
85	096	85	Harpo - płaszcz (obudowa) drukarki	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
86	097	86	Szpula mała - Łukasik	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
87	098	87	Szpula duża - Łukasik	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	17	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 8	\N	\N	\N	38.70	222.50	rABS PROGRESS	\N	\N	\N	\N
88	099	88	FIBOO - mata S	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
89	100	89	FIBOO - mata M	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
90	101	90	FIBOO - mata L	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
91	102	91	FIBOO - MATA LOLIPOP (mata do lizania)	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
92	103	92	PODKŁAD TABLICY- L&P - PP+20T BENIAMIN 520	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 7	\N	\N	\N	44.80	112.00	rABS CZARNY PROGRESS	\N	\N	\N	\N
94	105	94	IVT - redukcja Typ IVT/ Typ C	\N	\N	\N	\N		SPRAWNA	Wymienna matryca	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	10	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	Wymienna matryca	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	\N	\N	33.30	147.80	rPP CZARNY PROGRESS	\N	\N	\N	\N
95	106	95	MARMITE - ZP190903A0 - 0 stopni	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	7	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4, 6	\N	\N	\N	19.20	29.90	PP COPO BIAŁY	\N	\N	\N	\N
96	107	96	MARMITE - ZP190903A2- 2 stopnie	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	7	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	13.50	15.70	PP COPO REGLANULAT	\N	\N	\N	\N
97	108	97	MARMITE - ZP190903A3_5- 3,5 stopnie	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
98	109	98	MARMITE - ZP190903A108/A135	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
99	110	99	MARMITE - ZP211118A_BOTTOM/TOP/01A	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
100	111	100	Lapka PL HIC !!!	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
101	112	101	EVR - GM	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
102	113	102	Bio Top hanger	433.0	296.0	546.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
103	114	103	Bio Jacket hanger	501.0	246.0	546.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
104	115	104	Bio haak	201.0	246.0	196.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
105	116	105	EVR - 46PL	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	9	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	20.43	16.70	K295 BCD	\N	\N	\N	\N
106	117	106	Dozownik - Housing	447.0	346.0	378.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
107	118	107	Profim - przegub	295.0	295.0	300.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
108	119	108	Liderpool - korek PVC B2412N	200.0	245.0	240.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
109	120	109	FIBOO - MATA LOLIPOP MINI	180.0	220.0	190.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4, 6	\N	\N	\N	36.10	45.80	HRC9480/230 KRAIBURG	\N	\N	\N	\N
110	121	110	FIBOO - FIBOONE DENTAL . DENTAL MAŁA	250.0	250.0	240.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 7, 8	\N	\N	\N	53.20	224.80	GPL-GRANSEB 80G/000/139 GRANPOL	\N	\N	\N	\N
111	122	111	L&P - Obwódka do rejestracji 520	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
112	123	112	Harpo - FRONT KLAWIATURY	300.0	300.0	230.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
113	124	113	Zortrax - szpula	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
114	125	114	Fiberlab - Korek PVC NOWY - FOREST	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
115	126	115	FIBOO - SNACK FIBOOL MAŁA PIŁKA	250.0	210.0	285.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 7, 8	\N	\N	\N	64.30	152.50	HRC9480/230 KRAIBURG	\N	\N	\N	\N
116	127	116	FIBOO - SZARPAK	300.0	250.0	180.0	\N		SPRAWNA	MASZYNA 7,8 DODATKOWA PŁYTA DYSTANSOWA DO FORMY	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4, 8, 9	\N	\N	\N	59.50	160.00	GPL-GRANSEB 80G/000/139 GRANPOL	\N	\N	\N	\N
117	128	117	Euroster - obudowa NOWA	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
118	129	118	Pochłaniacz wilgoci - dół	350.0	350.0	350.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
119	130	119	Pochłaniacz wilgoci - środek	300.0	350.0	215.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
120	131	120	Pochłaniacz wilgoci - góra	345.0	350.0	370.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
121	132	121	HOOKS - ERDING - FLAT SHAPE PANTS HANGER	300.0	400.0	310.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
122	133	122	HOOKS -TOPHANGER TICKNESS	500.0	300.0	190.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
123	134	123	HOOKS -BARBY	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
124	135	124	HOOKS - ADENAU	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
125	136	125	FIBOO - Kość M	200.0	250.0	170.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
126	137	126	FIBOO - Kość S	200.0	200.0	170.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
127	138	127	KHG - P08	200.0	360.0	250.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
128	139	128	OKIDAY - Podstawa	450.0	400.0	255.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
129	140	129	OKIDAY - Elementy wewnętrzne	160.0	210.0	205.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
130	141	130	OKIDAY - Pokrętło	250.0	200.0	210.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
131	142	131	OKIDAY - Wstawka środkowa - Klapka	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
132	143	132	OKIDAY - Obudowa duża	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	2	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	47.00	143.60	ABS MAGNUM 8391 NEXEO PLASTICS	\N	\N	\N	\N
133	144	133	OKIDAY - Pedał dół	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
134	145	134	OKIDAY - Pedał góra	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
135	146	135	KHG - P01	245.0	245.0	200.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
136	148	136	HOOKS - CAPRI	510.0	260.0	310.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
137	149	137	KHG - P05	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
138	150	138	MARMITE - CROSSWATER - FLANGE DO ODPŁYWU BR VITO	200.0	155.0	200.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	7	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	\N	\N	\N	16.30	9.50	ABS HF380 WHITE	\N	\N	\N	\N
139	151	139	APP- Eckverbinder – forma 2131	245.0	300.0	260.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	16	\N	\N	\N	\N	\N	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 4, 5, 6	\N	\N	\N	39.40	34.10	PA6 BEZ WŁÓKNA PLASTAMID 6 B1	\N	\N	\N	\N
140	152	140	APP - Abdeckung – forma 2132	245.0	300.0	275.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
141	153	141	KHG - P09	205.0	155.0	190.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
142	154	142	HOOKS -BOTTOM HANGER	500.0	300.0	190.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
143	155	143	FIBOO - KOŚĆ L	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
144	156	144	FIBOO - FRISBEE	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
145	157	145	SZPULA ROSA	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	13	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	\N	\N	\N	27.40	111.30	REGLANULAT PC BIAŁY EMIPAK; PC BIAŁY PLASTPRO LUPOY ER1000LN; PC BIAŁY REGLANUTAT ARGUS; rPC BIAŁY ARGUS	\N	\N	\N	\N
146	158	146	FIBOO - MISKOMATA S - FIBOOWL S	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 4, 6	\N	\N	\N	36.75	58.70	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	\N	\N	\N	\N
147	159	147	KOREK PVC E8929	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
148	160	148	FIBOO - KUBEK - SNACK FIBEEK	345.0	295.0	295.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4, 8, 9	\N	\N	\N	79.10	221.00	GPL-GRANSEB 80G/000/139 GRANPOL	\N	\N	\N	\N
149	161	149	FIBOO - MATA JEŻ - FIBOOWL SPIKY	295.0	345.0	245.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3	\N	\N	\N	50.80	160.50	HRC9480/230 KRAIBURG	\N	\N	\N	\N
150	162	150	FIBOO - MATA SNOOPY	345.0	395.0	225.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
151	163	151	FIBOO - MISKOMATA M - FIBOOWL M	295.0	345.0	245.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 3, 4	\N	\N	\N	50.50	126.50	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	\N	\N	\N	\N
152	164	152	FIBOO - MATA HAPPY DOG	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	71.50	111.30	HRC9480/230 KRAIBURG 90% PP MOPLEN EP548 R 10 %	\N	\N	\N	\N
153	165	153	HIC - RAMKA DO REJESTRACJI (wymienne wkładki )	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
154	166	154	FIBOO - MISKOMATA L - FIBOOWL L	295.0	345.0	225.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 8, 9	\N	\N	\N	62.00	253.40	HRC9480/230 KRAIBURG	\N	\N	\N	\N
155	167	155	FIBOO - NASADKS NA KUBEK PEŁNA/OTWÓR	\N	\N	\N	\N		SPRAWNA	WYMIENNA MATRYCA	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	WYMIENNA MATRYCA	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
156	168	156	FIBOO - PUZZLE	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
157	169	157	FIBOO - FOREMKA DO LODU	\N	\N	\N	\N		SPRAWNA	POWIETRZE STEMPEL	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	POWIETRZE STEMPEL	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
158	170	158	FIBOO - MATA 43x 22	495.0	295.0	200.0	217.0		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
159	171	159	FIBOO - MATA 47X30	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8, 9	\N	\N	\N	76.30	400.50	HRC9480/230 KRAIBURG	\N	\N	\N	\N
160	172	160	FIBOO - KOSMOS -SPACE FIP	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
161	173	161	FIBOO - PIZZA - FIZZA	\N	\N	\N	\N		SPRAWNA	MATRTYCA RYBA TALEFRZYK	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
162	174	162	L&P - PODKŁAD MOTOCYKLOWY 180x200 11-022	295.0	345.0	265.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 5, 6	\N	\N	\N	27.60	100.20	rABS CZARNY PROGRESS	\N	\N	\N	\N
163	175	163	L&P - OBWÓDKA RAMKI 180x200 11-023	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 5	\N	\N	\N	26.92	32.20	rABS CZARNY PROGRESS	\N	\N	\N	\N
164	176	164	L&P - OBWÓDKA RAMKA 255/240x130 11-025	\N	\N	\N	\N		SPRAWNA	WYMIENNA MATRYCA STEMPEL	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	WYMIENNA MATRYCA STEMPEL	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
165	178	165	L&P - PODKŁAD MOTOCYKLOWY 255/240 11-024	\N	\N	\N	\N		SPRAWNA	WYMIENNE WKŁADY	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	WYMIENNE WKŁADY	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	24.52	81.70	rABS CZARNY PROGRESS	\N	\N	\N	\N
166	179	166	KHG - P07	245.0	275.0	210.0	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
167	180	167	KHG - P04	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
168	181	168	KHG - P03	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
169	182	169	KHG - P02	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
170	183	170	KHG - P06	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
171	184	171	FIBOO - FOREMKA DO LODU FUTTERHAUS	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2, 3, 4, 5, 7	\N	\N	\N	78.90	233.90	GPL-GRANSEB 80G/000/139 GRANPOL	\N	\N	\N	\N
172	185	172	FIBOO - FRINGO0 MINI	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	36.60	63.30	GRANSEB-80 GRANPOL	\N	\N	\N	\N
173	186	173	FIBOO - PIŁKA DUŻA SNACK FIBOOL JUMBO	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	\N	\N	86.50	376.50	HRC9480/230 KRAIBURG	\N	\N	\N	\N
174	187	174	FIBOO - FIBOONE DENTAL MONSTER DENTAL DUŻA	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8, 9	\N	\N	\N	68.80	496.40	GPL-GRANSEB 80G/000/139 GRANPOL	\N	\N	\N	\N
175	188	175	FIBOO - FIBOONE PUPPY (NAJMNIEJSZA KOŚĆ SZCZENIAK)	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	37.64	28.80	HRC9480/230 KRAIBURG	\N	\N	\N	\N
176	189	176	L&P PODKŁAD REJESTRACJI ABS . DE , PL, AT, 460X110 DE	\N	\N	\N	\N		SPRAWNA	WYMIENNE WKLŁADY M/ST WYPYCHACZE W BIURZE	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	WYMIENNE WKLŁADY M/ST WYPYCHACZE W BIURZE	\N	\N	\N	\N	\N	\N	\N	\N	2, 6, 7, 8	\N	\N	\N	37.70	150.00	rABS CZARNY PROGRESS	\N	\N	\N	\N
177	190	177	UNIWERS ZATYCZKA ZDP	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
178	191	178	UNIWERS KOREK ZDP PEŁNY/OTWÓR	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
179	192	179	UNIWERS UCHWYT ZRP L/P ZAŚLEPKA OTWÓR/B-OTWORU	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
180	193	180	UNIWERS NÓŻKA ZSP L/P KOREK ZSP OTWR/PEŁNY	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
181	194	181	UNIWERS PRZYLEPIEC ZDR/ZSP/ZRP	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
182	195	182	UNIWERS NÓŻKA L/P DUŻA	\N	\N	\N	\N		SPRAWNA	NR W SZAFIE	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
183	196	183	UNIWERS LINIJKA	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
184	197	184	FIBOO MATA LOLIPOP BRIT	\N	\N	\N	\N		SPRAWNA	MATRYCA UNIWERSALNA OD LOLIPOP	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	MATRYCA UNIWERSALNA OD LOLIPOP	\N	\N	\N	\N	\N	\N	\N	\N	9	\N	\N	\N	50.70	0.40	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	\N	\N	\N	\N
185	198	185	FIBOO MATA LOLIPOP STICKY	\N	\N	\N	\N		SPRAWNA	PRZYSSAWKI	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 4	\N	\N	\N	49.10	129.40	HRC9480/230 KRAIBURG	\N	\N	\N	\N
186	199	186	FIBOO MATA ŚWIATECZNA CHOINKA	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
187	200	187	FIBOO - SNACK FIBOONE/BIG PUPPY KOŚĆ	\N	\N	\N	\N		SPRAWNA	WYMIENNY STEMPEL	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	WYMIENNY STEMPEL	\N	\N	\N	\N	\N	\N	\N	\N	4, 5, 6	\N	\N	\N	34.25	110.70	HRC9480/230 KRAIBURG	\N	\N	\N	\N
188	201	188	APP HALTERUNG BRUCKE SCHWARZ	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	16	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4, 5, 6	\N	\N	\N	33.26	34.40	PA6+50GF PLASTAMID 6B1 BK NATURAL	\N	\N	\N	\N
189	202	189	APP BETATIGER LINKS/RECHTS	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	16	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5, 6	\N	\N	\N	28.56	22.20	PA6+50GF-PLASTAMID 6B1 G10 BK	\N	\N	\N	\N
190	203	190	APP RESTERUNG/BRUCKE SCHWARZ SECURE INNENSCHLOSS	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	16	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5	\N	\N	\N	33.26	30.10	POLIMER PA6-GF30%-PLASTAMID 6 B28-G6	\N	\N	\N	\N
191	204	191	FIBOO SLOW/ LICK FIBOOWL	\N	\N	\N	\N		SPRAWNA	WYMIENNY STEMPEL	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	WYMIENNY STEMPEL	\N	\N	\N	\N	\N	\N	\N	\N	1, 2, 3, 4, 7, 9	\N	\N	\N	78.70	212.90	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	\N	\N	\N	\N
192	205	192	FIBOO BOOMERANG	\N	\N	\N	\N		SPRAWNA	WYPYCHACZ W BIURZE	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
193	206	193	BIT ŁĄCZNIK KRÓTKI + DŁUGI	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	18	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 4	\N	\N	\N	33.60	21.90	rPP BIAŁY PROGRESS	\N	\N	\N	\N
194	207	194	FIBOO - FIJO (JAJKO)	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
195	208	195	FIBOO - FRINGO DUŻE	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	46.10	24.00	GRANSEB 75G/TRANSP./1/139 GRANPOL	\N	\N	\N	\N
196	209	196	FIBOO FIPLOO - TALERZYK	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	54.40	117.50	HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 10%	\N	\N	\N	\N
197	210	197	FIBOO FFEET	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
198	211	198	FIBOO SLOW/LICK FIBOOWL MINI	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 4	\N	\N	\N	50.40	107.70	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	\N	\N	\N	\N
199	212	199	FIBOO PRZYKRYWKA - FLIP FIBOOWL	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	\N	\N	\N	56.00	134.20	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	\N	\N	\N	\N
200	213	200	FIBOO SZARPAK KONICZYNA - FIBSY	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	\N	\N	\N	48.60	227.90	GPL-GRANSEB-80G/000/139	\N	\N	\N	\N
201	214	201	TOPBRIDGE MOCOWANIE PLEXY	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	24	\N	\N	\N	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	4, 5	\N	\N	\N	34.37	25.30	TPE-E HRC9480/230	\N	\N	\N	\N
202	215	202	FIBOO FLIP FIBOOWL	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
203	216	203	FIBOO FRISBEE MINI	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	5, 6	\N	\N	\N	31.50	57.40	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	\N	\N	\N	\N
204	217	204	FIBOO LOLLIPOP WALLY	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 3, 4	\N	\N	\N	49.00	131.30	HRC9480/230 KRAIBURG	\N	\N	\N	\N
206	219	206	MARBO SPINKA POM (CZERWONA KRATKA)	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	23	\N	\N	\N	\N	\N	\N	\N	\N	12	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	6	\N	\N	\N	19.68	33.30	POM C27N RESINEX	\N	\N	\N	\N
207	220	207	FIBOO FISHKA WOW	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
208	221	208	FIBOO FIBINKA ( szarpak choinka )	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
209	222	209	CORFORMA MODUŁ M50 L100 KRÓTKI	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	20	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7, 8	\N	\N	\N	57.80	267.80	POM HOSTAFORM C9021 RESINEX	\N	\N	\N	\N
210	223	210	CORFORMA MODUŁ M50 L200 DŁUGI (WYMIENNA MATRYCA)	\N	\N	\N	\N		SPRAWNA	WYMIENNA MATRYCA WYPUSTKI /GŁADKI	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	20	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	WYMIENNA MATRYCA WYPUSTKI /GŁADKI	\N	\N	\N	\N	\N	\N	\N	\N	2, 7, 8	\N	\N	\N	49.60	271.00	PP MOPLEN EP 548R	\N	\N	\N	\N
211	224	211	APP 41	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
212	225	212	APP 42	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
213	226	213	TRZPIEŃ	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
214	227	214	L&P ŁAPKA DE - 2K OBTRYSK ELASTOMER dwukomponentowa	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	3, 4, 5, 6	\N	\N	\N	33.70	22.00	HRC9480/230 KRAIBURG	\N	\N	\N	\N
215	228	215	L&P ŁAPKA DE - 2K RDZEŃ PC dwukomponentowa	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
216	229	216	L&P PODKŁAD AT NOWY 520X120	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	\N	\N	33.10	127.00	rABS CZARNY PROGRESS	\N	\N	\N	\N
217	230	217	L&P LISTWA SZEROKA PODKŁAD AT NOWY 520X120	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	12	\N	\N	\N	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	7	\N	\N	\N	38.20	109.00	rABS CZARNY PROGRESS	\N	\N	\N	\N
218	231	218	L&P LISTWA CIENKA PODKŁAD AT NOWY 520X120	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
219	232	219	FIBERLAB NOWY BOK SZPULI WERSJA ŻEŃSKA (DUZY KOŁNIERZ)	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	19	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	1, 7	\N	\N	\N	37.50	122.80	REGLANULAT ABS BIAŁY	\N	\N	\N	\N
220	233	220	FIBERLAB NOWY BOK SZPULI WERSJA MĘSKA (MAŁY KOŁNIERZ)	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
221	234	221	FIBOO MATA PRZED KUWETĘ FIBLITTER	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	9	\N	\N	\N	50.70	450.30	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	\N	\N	\N	\N
222	235	222	FIBOO MATA 47X30 PETFOOD GREEN	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	1	\N	\N	\N	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	8	\N	\N	\N	71.30	400.00	HRC9480/230 KRAIBURG	\N	\N	\N	\N
223	236	223	FIBOO TRZPIEŃ	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
224	237	224	FIBOO 32X32 MATRYCA FUTERHAUSE	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
225	238	225	FIBOO 32X32 STEMPEL GREEN PETFOOD	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
226	239	226	FIBOO SLOWFIBOOWL ANTIBOO	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
227	240	227	FIBOO FIBOOWL M ANTIBOO	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
228	241	228	FIBOO SZARPAK NOWY ANTIBOO	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
229	242	229	L&P PODKŁAD ABCD ,BCDA,BDCA,DBCA	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
230	243	230	L*P OBWODKA ABCD ,BCDA,BDCA,DBCA	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
231	244	231	FIBOO LOLIPOP ANTIBOO	\N	\N	\N	\N		SPRAWNA		2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: order_lines; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.order_lines (id, order_id, lp, product_id, product_name, qty, color_id, mold_id, material_id, colorant_id, material_kg, colorant_kg, machine_no, planned_start, planned_end, is_new_pair, production_code, full_code, batch_code, prod_start, prod_end, notes) FROM stdin;
1	1	1	1	OBUDOWA DUŻA	1012	\N	132	59	88	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-10-06	2026-10-06	
2	2	1	4	PŁYTKA KORPUSU	13000	\N	23	29	100	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-25	2026-09-29	
3	3	1	2	KORPUS	12600	1	\N	2	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-09-25	2026-10-06	
4	4	1	3	PIERŚCIEŃ MOB-G0445-02	13000	\N	22	32	104	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-29	2026-10-01	
5	5	1	6	BOTTOOM CLOUD	1000	1	\N	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-17	2026-08-18	
6	5	2	5	BOTTOM LIME	11000	13	64	59	130	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-18	2026-08-19	
7	6	1	9	TOP CLOUD	3100	1	62	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-20	2026-08-21	
8	7	1	7	MID CLOUD	3400	1	63	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-21	2026-08-21	
9	8	1	10	TOP LIME	11000	13	62	59	130	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-19	2026-08-20	
10	9	1	8	MID LIME	11000	13	63	59	130	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-21	2026-08-25	
11	10	1	12	CABLE LOCK ZIELONY	12500	22	\N	5	143	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-05-07	2026-05-25	
12	10	2	11	CABLE LOCK CZERWONY	17500	8	\N	5	92	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-05-26	2026-06-19	
13	10	3	13	CABLE LOCK ŻÓLTY	15000	\N	\N	5	142	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-06-19	2026-07-09	
14	11	1	20	NOGA REGULATORA	5000	\N	32	29	147	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-29	2026-04-05	
15	11	2	21	PLECY REGULATORA	5000	\N	32	29	147	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-29	2026-05-05	
16	12	1	22	PRZEŁACZNIK	10000	\N	\N	29	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-29	
17	12	2	24	SWITCH	10000	\N	\N	29	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-29	
18	12	3	23	PUDEŁKO	10000	\N	\N	29	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-29	
19	13	1	18	KORPUS REGULATORA	5000	1	31	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-05-06	2026-05-12	
20	13	2	19	KORPUS TRANSMITERA	5000	1	31	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-05-06	2026-05-12	
21	14	1	14	FRONT REGULATORA	5000	1	33	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-05-13	2026-05-18	
22	14	2	15	FRONT TRANSMITERA	5000	1	33	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-05-13	2026-05-18	
23	15	1	17	KLAWISZ MAŁY OKRĄGŁY	12000	1	\N	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-15	2026-07-17	
24	15	2	16	KLAWISZ DUŻY OKRĄGŁY	13200	1	\N	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-15	2026-07-17	
25	16	1	14	FRONT REGULATORA	5000	1	33	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-20	2026-07-23	
26	16	2	15	FRONT TRANSMITERA	4680	1	33	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-20	2026-07-23	
27	17	1	18	KORPUS REGULATORA	4700	1	31	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-23	2026-07-30	
28	17	2	19	KORPUS TRANSMITERA	5030	1	31	30	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-23	2026-07-30	
29	18	1	20	NOGA REGULATORA	4820	\N	32	29	147	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-30	2026-08-05	
30	18	2	21	PLECY REGULATORA	5100	\N	32	29	147	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-30	\N	
31	19	1	22	PRZEŁACZNIK	8000	\N	\N	29	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-12	2026-08-17	
32	19	2	24	SWITCH	9000	\N	\N	29	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-12	2026-08-17	
33	19	3	23	PUDEŁKO	9000	\N	\N	29	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-12	2026-08-17	
34	20	1	27	ZP190903A2-2stopni	20000	1	96	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-04-22	2026-04-24	
35	21	1	26	ZP190903A0-0stopni	40000	1	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-05	2026-08-07	
36	22	1	25	CROSSWATER-DO ODPŁYWU	5100	1	138	30	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-10-07	2026-10-08	
37	23	1	26	ZP190903A0-0stopni	0	1	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-08	\N	Ilość w zamówieniu: 
38	24	1	28	ZP190903A3_50-3,5 STOPNI	12000	1	95	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-10-06	2026-10-08	
39	25	1	29	KOREK PVC SELECT T KOR-180	20000	1	\N	69	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-04-07	2026-04-10	
40	26	1	30	SPINKA /KLIPS :MCLIP	50100	\N	\N	5	95	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-04-12	2026-04-15	
41	27	1	37	GMPA	105000	\N	\N	23	95	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-19	2026-02-23	
42	27	2	38	GMPP	201000	\N	\N	21	146	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-23	2026-02-26	
43	28	1	32	46LPA6	300000	\N	\N	23	95	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-02-20	2026-02-26	
44	29	1	33	46PL PP	60000	\N	105	21	146	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-27	2026-03-04	
45	30	1	31	46L PA6	142500	\N	83	23	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-22	2026-05-25	
46	31	1	34	56L PA6	160000	\N	84	23	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-25	2026-05-26	
47	32	1	31	46L PA6	260000	\N	83	23	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-26	2026-07-01	
48	33	1	34	56L PA6	247000	\N	84	23	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-14	2026-07-16	
49	34	1	31	46L PA6	405000	\N	83	23	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24	2026-10-05	
50	35	1	35	GM PA6	292000	\N	\N	23	95	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-29	
51	36	1	36	GM PP	290000	\N	\N	\N	146	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-09-29	2026-10-05	
52	37	1	34	56L PA6	310000	\N	84	23	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-05	2026-10-09	
53	38	1	42	REDUKCJA PIRAMIDA	4096	1	68	41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-10	2026-02-16	
54	39	1	42	REDUKCJA PIRAMIDA	4096	1	68	41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17	2026-04-21	
55	40	1	42	REDUKCJA PIRAMIDA	11264	1	68	41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-21	2026-04-30	
56	41	1	43	REDUKCJA TYP C	4224	1	94	41	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-04	2026-05-06	
57	42	1	44	REDUKCJA TYP IVT	3168	1	94	41	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-06	2026-05-08	
58	43	1	40	PODSTAWA UP	2000	1	69	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-06-03	2026-07-03	
59	44	1	45	WKŁAD	5040	1	71	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-06-16	2026-06-22	
60	45	1	41	POKRYWA	5040	1	66	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-06-29	2026-07-02	
61	46	1	39	KONDENSAT	5040	1	67	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-06-22	2026-06-29	
62	47	1	42	REDUKCJA PIRAMIDA	4096	1	68	41	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-18	2026-08-24	
63	48	1	49	093012 V1 SLIDEBLOC DIN 18R	80000	\N	\N	\N	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-05	2026-02-17	
64	49	1	49	093012 V1 SLIDEBLOC DIN 18R	80000	\N	\N	\N	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-17	2026-02-27	
65	50	1	46	091002 V1 PULLBLOC DIN 18L	10000	\N	\N	\N	104	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-09	
66	50	2	47	091012 V1 PULLBLOC DIN 18R	10000	\N	\N	\N	104	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-09	
67	50	3	49	093012 V1 SLIDEBLOC DIN 18R	39600	\N	\N	\N	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-09	
68	51	1	49	093012 V1 SLIDEBLOC DIN 18R	20000	\N	\N	\N	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-27	2026-03-03	
69	51	2	48	093002 V1 SLIDEBLOC DIN 18L	5000	\N	\N	\N	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-27	2026-03-03	
70	52	1	52	095013-8 V2 8x8 mm R	5000	1	\N	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-10	2026-03-13	
71	52	2	50	095003-8 V2 8x8 mm L	5000	1	\N	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-10	2026-03-13	
72	53	1	53	095100-9 V3 9x9U	5000	1	\N	2	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-21	2026-04-24	
73	53	2	54	095113-9 V3 9x9 R	5000	1	\N	2	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-21	2026-04-24	
74	54	1	51	095003-8 V2 8x8 mm L 095013-8 V2 8x8 mm R	10000	\N	\N	2	104	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-06-17	2026-06-23	
75	55	1	49	093012 V1 SLIDEBLOC DIN 18R	20000	\N	\N	\N	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-21	2026-07-22	
76	55	2	48	093002 V1 SLIDEBLOC DIN 18L	5000	\N	\N	\N	104	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-21	2026-07-22	
77	56	1	56	SLIDEBLOC 093012 V1 DIN 18R	80000	\N	\N	\N	104	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-26	2026-09-07	
78	56	2	55	PULLBLOC 091002 V1 DIN 18L	20000	\N	\N	\N	104	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-26	2026-09-07	
79	57	1	92	ŁAPKA DE A0070-1	5100	1	214	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-02	2026-02-04	
80	58	1	91	ŁAPKA DE A0070-0	4000	1	214	13	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-05	2026-02-05	
81	59	1	89	ŁAPKA AT A0071-1	3200	1	214	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-06	2026-02-09	
82	60	1	90	ŁAPKA DE 2KOMPONENTOWA PC	0	1	214	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-19	2026-03-24	Ilość w zamówieniu: 
83	61	1	72	PODKŁAD ABS AT 520x120	3250	1	176	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	\N	2026-03-24	
84	62	1	96	ŁAPKA DE OBTRYSK ZIELONY	1000	22	214	15	153	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-25	2026-03-25	
85	62	2	95	ŁAPKA DE OBTRYSK RÓŻOWY	1000	17	214	15	124	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-25	2026-03-25	
86	62	3	103	ŁAPKA DE OPTRYSK ŻÓŁTY	1000	23	214	15	154	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-25	2026-03-26	
87	62	4	101	ŁAPKA DE OPTRYSK POMARAŃCZ	1000	\N	214	15	125	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-26	2026-03-26	
88	62	5	100	ŁAPKA DE OPTRYSK CZERWONY	6000	8	214	15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-26	2026-03-27	
89	62	6	98	ŁAPKA DE OPTRYSK C.SZARY	1000	6	214	15	112	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-27	2026-03-27	
90	62	7	99	ŁAPKA DE OPTRYSK CZARNY	1500	7	214	15	104	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-30	2026-03-30	
91	63	1	58	LISTWA SZERROKA	1500	1	217	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-25	2026-03-25	
92	64	1	59	LISTWA WĄSKA	1500	1	217	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-26	2026-03-26	
93	65	1	57	KLUCZYK S1	63000	1	77	32	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-10	2026-04-14	
94	66	1	73	PODKŁAD AT 520x120	5515	1	216	\N	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-14	2026-04-16	
95	67	1	75	PODKŁAD DE 460x110	5500	1	176	\N	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-10	2026-04-14	
96	68	1	64	OBWÓDKA DO TABLICY 520x110 CZARNA	6500	7	92	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-04-22	2026-04-27	
97	69	1	68	OBWÓDKA RAMKI MOTOCYKLOWEJ 255x130	4300	1	163	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-04-29	2026-05-04	
98	70	1	63	OBWÓDKA DO TABLICY 520x110 BIAŁA	759	3	92	29	105	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-27	
99	71	1	65	OBWÓDKA RAMKI MOTOCYKLOWEJ 180x200 ABS	6510	1	163	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-24	2026-04-28	
100	72	1	80	PODKŁAD RAMKI MOTOCYKLOWEJ 180x200	17040	1	162	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-27	2026-05-08	
101	73	1	79	PODKŁAD POD TABLICE 520x110	17000	\N	92	27	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-04-27	2026-05-14	
102	74	1	66	OBWÓDKA RAMKI MOTOCYKLOWEJ 240x130	3040	1	163	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-04-28	2026-04-29	
103	75	1	83	PODKŁAD RAMKI MOTOCYKLOWEJ 255x130	4320	1	162	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-04	2026-05-05	
104	76	1	82	PODKŁAD RAMKI MOTOCYKLOWEJ 240x130	5625	1	162	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-06	2026-05-08	
105	77	1	108	ŁAPKI DE TRANSPARENT	5000	19	\N	13	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-05-18	2026-05-20	
106	78	1	107	ŁAPKI DE CZARNY	5000	7	\N	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-05-20	2026-05-21	
107	79	1	106	ŁAPKI DE 2 KOMPONENTOWA	15000	1	\N	\N	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-06-01	2026-06-08	
108	80	1	100	ŁAPKA DE OPTRYSK CZERWONY	4000	8	214	15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-09	2026-06-11	
109	80	2	102	ŁAPKA DE OPTRYSK RÓŻOWY	1500	17	214	15	124	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-06-11	2026-06-11	
110	80	3	97	ŁAPKA DE OBTRYSK ŻÓŁTY	3000	23	214	15	154	\N	\N	3	\N	\N	\N	\N	\N	\N	\N	2026-06-12	
111	80	4	96	ŁAPKA DE OBTRYSK ZIELONY	2500	22	214	15	153	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-12	2026-06-12	
112	80	5	93	ŁAPKA DE OBTRYSK C.SZARY	2500	6	214	15	112	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-06-15	2026-06-16	
113	80	6	94	ŁAPKA DE OBTRYSK CZARNY	1500	7	214	15	104	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-06-16	2026-06-17	
114	81	1	77	PODKŁAD DE 520x110 ABS	5213	1	176	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	\N	2026-06-17	
115	82	1	74	PODKŁAD AT 525x125 ABS	5200	1	176	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-06-08	2026-06-11	
116	83	1	76	PODKŁAD DE 460x110 ABS	5250	1	176	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-06-17	2026-06-23	
117	84	1	62	OBWÓDKA DO TABLICY 520 CZARNY	10602	7	92	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-06-23	2026-07-01	
118	85	1	80	PODKŁAD RAMKI MOTOCYKLOWEJ 180x200	11040	1	162	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-02	2026-07-09	
119	86	1	61	OBWÓDKA DO TABLICY 520 BIAŁA	2052	3	92	29	105	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-07-01	2026-07-03	
120	87	1	78	PODKŁAD POD TABLICE 520	23000	1	92	27	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-07-03	2026-07-22	
121	88	1	68	OBWÓDKA RAMKI MOTOCYKLOWEJ 255x130	4560	1	163	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-07-06	2026-07-08	
122	89	1	81	PODKŁAD RAMKI MOTOCYKLOWEJ 240/130 ABS	5810	1	165	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-09	2026-07-13	
123	90	1	65	OBWÓDKA RAMKI MOTOCYKLOWEJ 180x200 ABS	5500	1	163	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-08	2026-07-10	
124	91	1	67	OBWÓDKA RAMKI MOTOCYKLOWEJ 240x130 ABS	2720	1	163	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-07-13	\N	
125	92	1	84	PODKŁAD RAMKI MOTOCYKLOWEJ 255x130 ABS	4560	1	176	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-13	2026-07-14	
126	93	1	109	ŁAPKI PL 2 KOMPONENTOWE	2750	1	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-18	2026-08-19	
127	94	1	105	ŁAPKA UK OBTRYSK	2870	\N	214	15	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-26	2026-08-27	
128	95	1	110	ŁAPKI UK 2 KOMPONENTOWA PC	800	1	\N	\N	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-19	2026-08-20	
129	96	1	104	ŁAPKA PL OBTRYSK	2450	\N	214	15	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-27	2026-08-28	
130	97	1	88	PODKŁAD TABLICY SAMOCHODOWEJ 460x111	2550	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-17	2026-09-21	
131	98	1	71	OBWÓDKA TABLICY SAMOCHODOWEJ 460x111	2508	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-22	2026-09-24	
132	99	1	87	PODKŁAD TABLICY SAMOCHODOWEJ 420x111	1500	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-22	
133	100	1	70	OBWÓDKA TABLICY SAMOCHODOWEJ 420x111	1600	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-28	2026-09-29	
134	101	1	86	PODKŁAD TABLICY SAMOCHODOWEJ 400x111	1560	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-25	2026-09-25	
135	102	1	69	OBWÓDKA TABLICY SAMOCHODOWEJ 380x111	1089	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-10-01	2026-10-02	
136	103	1	60	OBOWÓDKA TABLICY SAMOCHODOWEJ 400 x111	1512	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-30	2026-10-01	
137	104	1	85	PODKŁAD TABLICY SAMOCHODOWEJ 380x111	1000	1	92	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-29	2026-09-30	
138	105	1	78	PODKŁAD POD TABLICE 520	0	1	92	27	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-10-09	\N	Ilość w zamówieniu: 
139	106	1	111	SZPULA ROSA	40320	\N	145	\N	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-01-29	2026-02-26	
140	107	1	111	SZPULA ROSA	40320	\N	145	\N	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-02-26	2026-03-26	
141	108	1	111	SZPULA ROSA	40320	\N	145	\N	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-27	
142	109	1	111	SZPULA ROSA	40320	\N	145	\N	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-22	2026-08-17	
143	110	1	111	SZPULA ROSA	40362	\N	145	\N	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-08-17	2026-09-14	
144	111	1	113	ŁAPKI PL CZARNY	10000	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-29	2026-02-02	
145	112	1	113	ŁAPKI PL CZARNY	20000	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-07	2026-04-09	
146	113	1	114	ŁAPKI PL TRANSPARENTNY	4000	19	\N	13	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-09	2026-04-09	
147	114	1	113	ŁAPKI PL CZARNY	10000	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-08	2026-09-10	
148	115	1	114	ŁAPKI PL TRANSPARENTNY	4000	19	\N	13	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-09-10	2026-09-11	
149	116	1	112	PODKŁAD 460 WKŁADKA LP	4320	1	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-09-14	2026-09-17	
150	117	1	116	RAIS UCHWYT 3 PP	12000	\N	\N	\N	104	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-01-27	2026-02-02	
151	118	1	115	RAIS UCHWYT 3 OBTRYSK	10700	\N	\N	\N	145	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-02-03	2026-02-11	
152	119	1	117	RAIS UCHWYT 4 PP	6000	\N	\N	\N	104	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-24	2026-04-27	
153	120	1	120	UCHWYT 4 OBTRYSK	5715	\N	\N	\N	145	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-05-04	2026-05-06	
154	121	1	119	UCHWYT 3 PP	2500	\N	\N	\N	104	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-06-01	2026-06-01	
155	122	1	118	UCHWYT 3 OBTRYSK	2050	\N	\N	\N	92	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-06-08	2026-06-09	
156	123	1	133	HALTERUNG BRUCKE SCHWARZ Zg-Nr 12_6818F	6000	7	188	\N	95	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-01-22	2026-01-23	
157	124	1	123	ECKVERBINDER (1) 7202	12000	\N	139	3	170	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-01-29	2026-02-05	
158	125	1	121	BETATIGER RECHTS 7501 BETATIGER LINKS 7502	5000	\N	189	4	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-26	2026-01-29	
159	126	1	125	ECKVERBINDER (3) 7205	12000	\N	139	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-16	2026-03-02	
160	127	1	131	ECKVERBINER (3) 7202	12000	\N	\N	3	170	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-13	2026-03-19	
161	128	1	125	ECKVERBINDER (3) 7205	12000	\N	139	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-16	2026-04-21	
162	129	1	132	HALTERUNG BRUCKE SCHWARZ 73,6818,75	10000	7	188	\N	95	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-29	2026-04-30	
163	130	1	124	ECKVERBINDER (3) 12_7202	12000	\N	139	3	170	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-08	2026-05-14	
164	131	1	134	RESTERUNG 12_7184	7600	1	190	2	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-14	2026-05-21	
165	131	2	122	BRUCKE 12_7194	7600	1	188	2	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-14	\N	
166	132	1	125	ECKVERBINDER (3) 7205	12000	\N	139	5	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-23	2026-07-02	
167	133	1	126	ECKVERBINDER 12_7202	12000	\N	139	3	170	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-26	2026-07-02	
168	134	1	121	BETATIGER RECHTS 7501 BETATIGER LINKS 7502	5000	\N	189	4	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-27	2026-07-29	
169	135	1	128	ECKVERBINDER 7205	12000	\N	139	12	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-31	2026-09-11	
170	135	2	129	ECKVERBINDER LINKS 7206	6000	\N	139	12	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-31	2026-09-04	
171	135	3	130	ECKVERBINDER RECHTS 7207	6200	\N	139	12	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-31	2026-09-04	
172	136	1	126	ECKVERBINDER 12_7202	12600	\N	139	3	170	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-11	2026-09-18	
173	137	1	127	ECKVERBINDER 12_7205	0	\N	139	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-10-13	\N	Ilość w zamówieniu: 
174	138	1	135	SZPULA ABS DUŻA	8400	1	87	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-20	2026-01-28	
175	139	1	135	SZPULA ABS DUŻA	18400	1	87	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-05	2026-03-24	
176	140	1	136	ŁĄCZNIK DŁUGI	10000	1	193	42	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-01-19	2026-01-21	
177	141	1	137	ŁĄCZNIK KRÓTKI	10000	1	193	42	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-02	2026-07-03	
178	142	1	138	SZPULA BOK	20400	1	16	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-01-14	2026-01-29	
179	143	1	138	SZPULA BOK	40800	1	16	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-01-29	2026-03-03	
180	144	1	140	SZPULA BOK ŻEŃSKI	2400	1	219	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-10	2026-03-17	
181	144	2	139	SZPULA BOK MĘSKI	2337	1	16	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-03-11	2026-03-12	
182	145	1	138	SZPULA BOK	22360	1	16	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-19	
183	146	1	140	SZPULA BOK ŻEŃSKI	16016	1	219	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-31	2026-04-23	
184	147	1	139	SZPULA BOK MĘSKI	16000	1	16	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-20	
185	148	1	139	SZPULA BOK MĘSKI	18200	1	16	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-05-07	2026-06-09	
186	149	1	141	SZPULA BOK ŻĘSKI	16000	1	16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-14	2026-05-28	
187	150	1	139	SZPULA BOK MĘSKI	18200	1	16	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-06-09	2026-07-15	
188	151	1	141	SZPULA BOK ŻĘSKI	18720	1	16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-19	2026-07-09	
189	152	1	139	SZPULA BOK MĘSKI	18200	1	16	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-07-15	2026-07-30	
190	153	1	141	SZPULA BOK ŻĘSKI	18720	1	16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-16	2026-07-31	
191	154	1	139	SZPULA BOK MĘSKI	18200	1	16	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-07-30	2026-08-18	
192	155	1	140	SZPULA BOK ŻEŃSKI	18720	1	219	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-31	2026-08-21	
193	156	1	141	SZPULA BOK ŻĘSKI	16640	1	16	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-07	
194	157	1	139	SZPULA BOK MĘSKI	15600	1	16	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-08-24	2026-09-09	
195	158	1	144	MODUŁ 200	9318	\N	209	33	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-01-13	2026-01-19	
196	159	1	146	MODUŁ M50 L200 PP	3036	\N	210	7	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-25	2026-06-26	
197	160	1	145	MODUŁ M50 L200 POM	2936	\N	210	33	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-06	2026-08-07	
198	161	1	148	MODUŁ M50 L200 PP biały	2750	3	210	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-05	2026-08-05	
199	161	2	147	MODUŁ M50 L200 PP NIEBIESKI	1078	15	210	7	188	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-05	2026-08-05	
200	162	1	145	MODUŁ M50 L200 POM	2800	\N	210	33	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-17	2026-08-18	
201	163	1	149	MODUŁ M50L200 PP NIEBIESKI	1000	15	209	7	188	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-08-18	2026-08-19	
202	164	1	145	MODUŁ M50 L200 POM	12008	\N	210	33	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-05	2026-10-13	
203	165	1	147	MODUŁ M50 L200 PP NIEBIESKI	2003	15	210	7	188	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-01	2026-10-01	
204	166	1	148	MODUŁ M50 L200 PP biały	4002	3	210	7	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-01	2026-10-05	
205	167	1	143	MASKOWNICA MICKEY J.SZARA	630	\N	\N	7	191	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-10-06	2026-10-07	
206	167	2	142	MASKOWNICA MICKEY C.SZARA	1404	\N	\N	7	190	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-10-07	2026-10-09	
207	168	1	176	RENAULT PASSION 35	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-01-13	2026-01-14	
208	168	2	160	FORD PERFORMANCE 33	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-01-13	2026-01-14	
209	168	3	166	MERCEDES BENZ 1	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-01-14	2026-01-16	
210	168	4	165	MERCEDES AMG 44	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-01-14	2026-01-16	
211	168	5	178	TOYOTA 14	2000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-16	2026-01-20	
212	168	6	162	HYUNDAI 13	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-01-16	2026-01-20	
213	169	1	173	PODKŁAD REJESTRACJI HIC-LP	4320	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-16	2026-04-20	
214	169	2	172	PODKŁAD REJESTRACJI HIC-GŁADKA	4320	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-21	2026-04-23	
215	170	1	167	MERCEDES-BENZ 1	2000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-27	
216	170	2	150	AUDI 3	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-27	\N	
217	170	3	151	BMW 2	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-28	
218	170	4	175	RENAULT 10	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-28	
219	170	5	159	FORD 12	2000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-28	2026-04-29	
220	170	6	161	HONDA 16	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-28	2026-04-29	
221	170	7	177	SEAT 18	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-29	2026-04-30	
222	170	8	168	MITSUBISHI MOTORS 17	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-29	2026-04-30	
223	170	9	153	CITROEN 19	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-30	2026-05-04	
224	170	10	163	MAZDA 20	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-04-30	2026-05-04	
225	170	11	169	NISSAN 22	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-05-04	2026-05-05	
226	170	12	174	RANGE ROVER 40	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-05-04	2026-05-05	
227	170	13	179	VOLKSWAGEN 46	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-05-05	2026-05-06	
228	170	14	164	MERCEDES AMG 4	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-05-05	2026-05-06	
229	171	1	180	VOLKSWAGEN 7	3000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-03	2026-07-07	
230	171	2	178	TOYOTA 14	4000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-03	2026-07-07	
231	171	3	155	DACIA 26	4000	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-07-07	2026-07-09	
232	171	4	181	VOLVO 21	3000	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-07-07	2026-07-09	
233	171	5	152	BYD 58	1000	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-07-09	2026-07-09	
234	171	6	154	CUPRA 57	1000	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-07-09	2026-07-09	
235	171	7	158	FIAT SPORT 41	4000	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-07-09	2026-07-13	
236	171	8	156	DACIA 48	4000	1	\N	\N	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-07-09	2026-07-13	
237	172	1	171	PODKŁAD DO REJESTRACJI 460 LP	10800	1	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-07-22	2026-08-03	
238	173	1	167	MERCEDES-BENZ 1	4000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-07	2026-08-11	
239	173	2	159	FORD 12	4000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-07	2026-08-11	
240	173	3	157	FIAT 15	2000	1	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-08-11	2026-08-12	
241	173	4	180	VOLKSWAGEN 7	2000	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-11	2026-08-12	
242	174	1	151	BMW 2	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-10-09	2026-10-13	
243	174	2	170	PEUGEOT 8	2000	1	\N	\N	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-10-09	2026-10-13	
244	175	1	186	GÓRA POCHŁANIACZA WILGOCI RÓŻOWY	13200	17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-12	2026-01-15	
245	175	2	185	GÓRA POCHŁANIACZA WILGOCI BIAŁY	13135	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-15	2026-01-20	
246	176	1	182	DÓŁ POCHŁANIACZA WILGOCI	38200	1	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-26	2026-03-10	
247	177	1	188	ŚRODEK POCHŁANIACZA WILGOCI	90000	1	\N	34	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-23	2026-04-07	
248	178	1	187	GÓRA POCHŁANIACZA WILGOCI SZARY	20100	18	\N	\N	162	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-10	
249	178	2	183	GÓRA POCHŁANAICZA WILGOCI RÓŻOWY	2005	17	\N	\N	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-04-10	2026-04-14	
250	178	3	185	GÓRA POCHŁANIACZA WILGOCI BIAŁY	21000	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-14	2026-04-16	
251	179	1	182	DÓŁ POCHŁANIACZA WILGOCI	60282	1	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-14	2026-05-27	
252	180	1	184	GÓRA POCHŁANAICZA WILGOCI SZARY	43780	18	\N	\N	162	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-05-27	2026-07-24	
253	180	2	187	GÓRA POCHŁANIACZA WILGOCI SZARY	43780	18	\N	\N	162	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-20	2026-07-27	
254	180	3	185	GÓRA POCHŁANIACZA WILGOCI BIAŁY	19028	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-27	2026-07-29	
255	180	4	186	GÓRA POCHŁANIACZA WILGOCI RÓŻOWY	19130	17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-29	2026-08-03	
256	181	1	182	DÓŁ POCHŁANIACZA WILGOCI	79000	1	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-03	2026-08-25	
257	182	1	188	ŚRODEK POCHŁANIACZA WILGOCI	79000	1	\N	34	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-07-29	2026-08-10	
258	183	1	186	GÓRA POCHŁANIACZA WILGOCI RÓŻOWY	21185	17	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-16	2026-09-21	
259	183	2	185	GÓRA POCHŁANIACZA WILGOCI BIAŁY	22285	3	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-24	
260	183	3	187	GÓRA POCHŁANIACZA WILGOCI SZARY	26100	18	\N	\N	162	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24	2026-09-30	
261	184	1	188	ŚRODEK POCHŁANIACZA WILGOCI	65000	1	\N	34	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-10-02	2026-10-12	
262	185	1	182	DÓŁ POCHŁANIACZA WILGOCI	0	1	\N	34	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-02	\N	Ilość w zamówieniu: 
263	186	1	189	SPINKA	155400	\N	206	32	92	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-01-12	2026-01-21	
264	187	1	189	SPINKA	151200	\N	206	32	92	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-02-19	2026-02-26	
265	188	1	190	MOCOWANIE PLEXA 30x15/15x15	12000	1	201	15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-01-12	2026-01-14	
266	189	1	190	MOCOWANIE PLEXA 30x15/15x15	65000	1	201	15	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-14	2026-07-27	
267	190	1	196	ZAŚLEPKA ASA BIAŁA	8000	3	10	55	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2025-01-12	2026-01-14	
268	190	2	194	ZAŚLEPKA ASA J.SZARY	10200	12	10	31	126	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-01-14	2026-01-19	
269	190	3	197	ZAŚLEPKA ASA C.SZARY	10000	6	10	31	128	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-01-20	2026-01-23	
270	190	4	203	ZAŚLEPKA ASA WANILIOWY	5000	21	10	31	132	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-01-23	2026-01-26	
271	190	5	195	ZAŚLEPKA ASA BEŻ	5200	2	10	31	91	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-01-27	2026-01-28	
272	191	1	208	ZAŚLEPKA PROFILU PC CZARNY	20000	7	12	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-21	2026-05-27	
273	192	1	213	ZAŚLEPKA PROFILU PC TRANSP.	8000	1	12	13	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-27	2026-05-29	
274	192	2	209	ZAŚLEPKA PROFILU PC NIEBIESKI	4000	15	12	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-05-29	2026-06-01	
275	193	1	202	ZAŚLEPKA ASA NOWA WANILIA	4000	\N	52	31	132	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-06-01	2026-06-01	
276	193	2	198	ZAŚLEPKA ASA NOWA BEŻOWA	4000	2	52	31	91	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-06-02	2026-06-02	
277	193	3	200	ZAŚLEPKA ASA NOWA CIEMNO SZARY	14000	18	52	31	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-06-02	2026-06-09	
278	193	4	201	ZAŚLEPKA ASA NOWA JASNO SZARA	14000	18	52	31	126	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-06-09	2026-06-15	
279	194	1	199	ZAŚLEPKA ASA NOWA BIAŁA	7000	3	52	55	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-06-15	2026-06-17	
280	195	1	208	ZAŚLEPKA PROFILU PC CZARNY	66000	7	12	\N	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-06-17	2026-07-02	Ilość w zamówieniu: L 30000 P 36000
281	196	1	191	PASEK ELASTOMEROWY	30000	\N	9	15	146	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-29	2026-07-13	
282	197	1	214	ZAŚLEPKA PROFILU PC TRANSPARENT	8000	19	12	13	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-07-02	2026-07-06	
283	198	1	206	ZAŚLEPKA PROFILU KOŃCOWEGO B2410	6000	1	12	69	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-09	2026-07-13	
284	199	1	207	ZAŚLEPKA PROFILU KOŃCOWEGO B2410L LOGO BB	8000	1	12	69	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-13	2026-07-14	
285	200	1	215	ZAŚLEPKA PROFILU ŚRODKOWEGO B2412N	15400	1	12	69	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-17	2026-07-23	
286	201	1	216	ZAŚLEPKA PROFILU ŚRODKOWEGO EXTRA-TOP-B2414	4200	1	12	69	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-14	2026-07-16	
287	202	1	193	ZASLEPKA PROFILU NAPĘDOWEGO B2411	5000	1	11	69	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-16	2026-07-17	
288	203	1	217	ZAŚLEPKA PROFILU ŚRODKOWEGO PLAT-SECTION B2415	3000	1	12	69	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-23	2026-07-24	
289	204	1	212	ZAŚLEPKA PROFILU PC NOWA TRANSPARENT	14400	19	12	13	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-09-11	2026-09-17	Ilość w zamówieniu: 14400 P+L
290	205	1	210	ZAŚLEPKA PROFILU PC NOWA CZARNY	14400	7	12	\N	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-09-17	2026-09-23	Ilość w zamówieniu: 14400 P+L
291	206	1	211	ZAŚLEPKA PROFILU PC NOWA NIEBIESKA	14400	15	12	13	99	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-29	Ilość w zamówieniu: 14400 P+L
292	207	1	192	ZASLEPKA PROFILU ASA BIAŁA	14400	3	11	55	\N	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-09-29	2026-10-05	Ilość w zamówieniu: 14400 P+L
293	208	1	204	ZAŚLEPKA PROFILU ASA C.SZARY	14400	6	12	31	128	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-10-05	2026-10-09	Ilość w zamówieniu: 14400 P+L
294	208	2	205	ZAŚLEPKA PROFILU ASA J.SZARY	0	12	12	31	126	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-10-09	\N	Ilość w zamówieniu: 
295	209	1	427	MATA LOLLIPOP MINI RÓŻ	1005	\N	109	15	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-01-14	2026-01-15	
296	209	2	428	MATA LOLLIPOP MINI ZIELONY	1020	22	109	15	107	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-01-15	2026-01-16	
297	209	3	429	MATA LOLLIPOP MINI ŻÓŁTY	600	23	109	15	115	\N	\N	4	\N	\N	\N	\N	\N	\N	2025-01-16	2026-01-19	
298	210	1	263	FIBOOWL M BETTERCAT	6000	\N	151	15	117	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-01-14	2026-01-21	
299	211	1	258	FIBOOWL L FUTTERHAUS RÓŻ	850	\N	154	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-20	2026-01-21	
300	211	2	257	FIBOOWL L FUTTERHAUS C.SZARY	1300	6	154	15	112	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-21	2026-01-22	
301	212	1	262	FIBOOWL M BEŻ	500	2	151	15	117	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-01-23	2026-01-26	
302	212	2	268	FIBOOWL M RÓŻOWY	920	17	151	15	123	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-01-26	\N	
303	212	3	264	FIBOOWL M C.NIEBIESKI	1000	\N	151	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-27	2026-01-28	
304	212	4	265	FIBOOWL M C.ZIELONY	1000	\N	151	15	120	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-01-28	2026-01-29	
305	213	1	255	FIBOOWL L C.SZARY	323	6	154	15	112	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-22	2026-01-23	
306	213	2	254	FIBOOWL L C.NIEBIESKI	555	\N	154	15	123	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-01-23	2026-01-23	
307	213	3	260	FIBOOWL L ZIELONY	504	22	154	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-26	2026-01-26	
308	214	1	459	SLOW FIBOOWL C.NIEBIESKI	501	\N	191	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-27	\N	
309	214	2	465	SLOW FIBOOWL FIOLETOWY	520	9	191	15	156	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-27	2026-01-28	
310	214	3	477	SLOW FIBOOWL RÓŻOWY	1200	17	191	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-28	2026-01-30	
311	214	4	479	SLOW FIBOOWL ŻÓŁTY	500	23	191	15	115	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-01-30	2026-02-02	
312	214	5	460	SLOW FIBOOWL C.SZARY	1248	6	191	15	112	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-02-02	2026-02-03	
313	215	1	277	FIBOOWL S GREENPETFOOD	5218	\N	146	15	117	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-01-21	2026-01-26	
314	216	1	404	MATA 47x30 GREEN PETFOOD	5100	22	222	15	106	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-01-23	2026-02-04	
315	217	1	443	MISKA M RÓŻOWY	1285	17	44	43	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-01-29	2026-01-30	
316	217	2	444	MISKA M ZIELONY	1225	22	44	43	107	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-02	2026-02-03	
317	217	3	442	MISKA M J.NIEBIESKI	800	\N	44	43	127	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-03	2026-02-03	
318	217	4	439	MISKA M C.NIEBIESKI	600	\N	44	43	109	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-04	2026-02-04	
319	217	5	440	MISKA M C.SZARA	500	\N	44	43	114	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-04	2026-02-05	
320	218	1	468	SLOW FIBOOWL LOGO POKUSA	3000	\N	191	15	144	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-02-04	2026-02-10	
321	219	1	441	MISKA M GREENPETFOOD	7800	\N	44	43	111	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-05	2026-02-16	
322	220	1	393	MATA 32x32 J.SZARY	1005	12	42	15	106	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-10	2026-02-11	
323	220	2	385	MATA 32x32 C.SZARY	800	6	42	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-11	2026-02-12	
324	220	3	388	MATA 32x32 CZARNY	560	7	42	15	104	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-12	2026-02-12	
325	221	1	450	MISKA S RÓŻOWY	1235	17	43	43	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-09	2026-02-11	
326	221	2	452	MISKA S ZIELONY	1038	22	43	43	107	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-11	2026-02-13	
327	221	3	451	MISKA S SZARY	2005	18	43	43	107	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-16	2026-02-17	
328	221	4	448	MISKA S C.SZARY	700	6	43	43	114	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-17	2026-02-17	
329	221	5	445	MISKA S BEŻ	546	2	43	43	111	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-02-18	2026-02-18	
330	222	1	399	MATA 47x30 FUTTERHAUS	800	\N	159	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-04	2026-02-05	
331	222	2	399	MATA 47x30 FUTTERHAUS	800	\N	159	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-05	2026-02-09	
332	222	3	399	MATA 47x30 FUTTERHAUS	800	\N	159	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-09	2026-02-10	
333	223	1	431	MATA LOLLIPOP STICKY RÓŻ	1035	\N	185	15	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-02-11	2026-02-12	
334	223	2	430	MATA LOLLIPOP STICKY C.SZARY	1024	6	185	15	112	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-02-12	2026-02-13	
335	224	1	392	MATA 32x32 GREENPETFOOD	5120	\N	222	15	103	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-16	2026-02-23	
336	225	1	455	SLOW FIBFEEDER	2284	1	191	39	\N	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-02-17	2026-02-18	
337	226	1	266	FIBOOWL M GAMEDOG	3100	\N	151	15	123	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-02-17	2026-02-19	
338	227	1	509	SZARPAK FIB POMARAŃCZOWY	916	16	116	18	125	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-02	2026-03-03	
339	227	2	510	SZARPAK FIB RÓŻOWY	1006	17	116	18	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-04	
340	227	3	519	SZARPAK FIB ŻÓŁTY	518	23	116	18	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-04	2026-03-04	
341	227	4	517	SZARPAK FIB ZIOELONY	808	\N	116	18	153	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-04	2026-03-05	
342	227	5	507	SZARPAK FIB NIEBIESKI	1103	15	116	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-05	2026-03-06	
343	227	6	503	SZARPAK FIB FIOLETOWY	914	9	116	18	156	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-06	2026-03-09	
344	228	1	390	MATA 32x32 FUTTERHAUS C.SZ	800	\N	42	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-24	2026-02-25	
345	228	2	389	MATA 32x32 FUTTERHAUS BEŻ	800	2	42	15	117	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-25	2026-02-26	
346	228	3	391	MATA 32x32 FUTTERHAUS RÓŻ	800	\N	42	15	113	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-26	2026-02-27	
347	229	1	400	MATA 47x30 FUTTERHAUS BEŻ	1000	2	159	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-02-27	2026-03-02	
348	229	2	401	MATA 47x30 FUTTERHAUS C.SZ	470	\N	159	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-03-02	2026-03-05	
349	230	1	229	FIBOONE BIG PUPPY POARAŃCZ	1009	\N	187	15	125	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-26	2026-02-26	
350	230	2	230	FIBOONE BIG PUPPY RÓŻ	424	\N	187	15	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-26	2026-02-27	
351	230	3	233	FIBOONE BIG PUPPY ŻÓŁTY	200	23	187	15	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-27	2026-02-27	
352	230	4	232	FIBOONE BIG PUPPY ZIELONY	210	22	187	15	153	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-27	2026-02-27	
353	230	5	228	FIBOONE BIG PUPPY NIEBIESKI	215	15	187	15	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-27	2026-02-27	
354	231	1	336	FRISBOO POMARAŃCZOWY	1000	16	\N	18	125	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-06-27	2026-02-27	
355	231	2	337	FRISBOO RÓŻOWY	1200	17	\N	18	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-02-27	2026-03-02	
356	231	3	339	FRISBOO ŻÓŁTY	1120	23	\N	18	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-02	2026-03-02	
357	231	4	338	FRISBOO ZIELONY	1000	22	\N	18	153	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-03	
358	231	5	335	FRISBOO NIEBIESKI	1200	15	\N	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-04	
359	232	1	328	FRISBOO FUTTERHAUS RÓŻOWY	2000	17	171	18	124	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-09	2026-03-10	
360	232	2	327	FRISBOO FUTTERHAUS NIEBIESKI	2003	15	171	18	154	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-10	2026-03-12	
361	232	3	329	FRISBOO FUTTERHAUS ŻÓŁTY	2000	23	171	18	154	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-12	2026-03-13	
362	233	1	218	FIBBOWL MAT 43x22 J.SZARY	800	12	\N	15	106	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-03-03	2026-03-04	
363	234	1	492	SNACK FIBOOLL SOFT FUTTERHAUS NIEBIESKI	3685	15	115	15	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-04	2026-03-06	
364	234	2	493	SNACK FIBOOLL SOFT FUTTERHAUS RÓŻOWY	3600	17	115	15	124	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-06	2026-03-10	
365	234	3	494	SNACK FIBOOLL SOFT FUTTERHAUS ŻÓŁTY	3635	23	115	15	154	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-11	2026-03-13	
366	235	1	341	GUMKI MAŁE	34500	1	\N	19	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-05	2026-03-11	
367	236	1	237	FIBOONE DENTAL FUTTERHAUS ŻÓŁTY	4200	23	110	18	154	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-13	2026-03-17	
368	236	2	236	FIBOONE DENTAL FUTTERHAUS RÓŻOWY	4200	17	110	18	124	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-18	2026-03-20	
369	236	3	235	FIBOONE DENTAL FUTTERHAUS NIEBIESKI	4200	15	110	18	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-23	\N	
370	237	1	314	FRINGOO FUTTERHAUS NIEBIESKI	2240	15	171	18	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-11	2026-03-12	
371	237	2	316	FRINGOO FUTTERHAUS ŻÓŁTY	2208	23	171	18	154	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-12	2026-03-16	
372	237	3	315	FRINGOO FUTTERHAUS RÓŻOWY	2208	17	171	18	124	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-16	2026-03-18	
373	238	1	339	FRISBOO ŻÓŁTY	600	23	\N	18	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-13	2026-03-13	
374	238	2	338	FRISBOO ZIELONY	615	22	\N	18	153	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-13	2026-03-16	
375	238	3	335	FRISBOO NIEBIESKI	800	15	\N	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-16	2026-03-16	
376	238	4	337	FRISBOO RÓŻOWY	800	17	\N	18	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-17	2026-03-18	
377	238	5	326	FRISBO POMARAŃCZOWY	800	16	\N	18	125	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-18	2026-03-18	
378	239	1	511	SZARPAK FIB RÓŻOWY FUTTERHAUS	2434	17	116	18	124	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-19	2026-03-24	
379	239	2	508	SZARPAK FIB NIEBIESKI FUTTERHAUS	2200	15	116	18	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-24	2026-03-27	
380	239	3	518	SZARPAK FIB ŻÓLTY FUTTERHAUS	2200	\N	116	18	154	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-27	2026-04-01	
381	240	1	325	FRINGOO ŻÓŁTY	512	23	\N	18	154	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-16	2026-03-16	
382	240	2	312	FRINGOO RÓŻOWY	1216	17	\N	18	124	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-18	2026-03-18	
383	240	3	322	FRINGOO NIEBIESKI	800	15	\N	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-19	\N	
384	240	4	323	FRINGOO POMARAŃCZOWY	1024	16	\N	18	125	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-19	2026-03-20	
385	240	5	324	FRINGOO ZIELONY	1563	22	\N	18	153	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-03-20	2026-06-23	
386	241	1	463	SLOW FIBOOWL CZERWONY	468	8	191	15	92	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-03-17	2026-03-17	
387	241	2	478	SLOW FIBOOWL ZIELONY	1144	22	191	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-18	2026-03-18	
388	242	1	457	SLOW FIBOOWL BRIT ZIELONY	1600	22	191	15	107	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-03-19	2026-03-23	
389	242	2	458	SLOW FIBOOWL BRIT ŻÓŁTY	1612	23	191	15	115	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-03-23	2026-03-26	
390	243	1	251	FIBOONE DENTAL ŻÓŁTY	2531	23	110	18	154	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-17	2026-03-18	
391	243	2	248	FIBOONE DENTAL RÓZOWY	1613	\N	110	18	124	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-20	2026-03-23	
392	243	3	246	FIBOONE DENTAL NIEBIESKI	1995	15	110	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-25	2026-03-26	
393	243	4	247	FIBOONE DENTAL POMARAŃCZ	1500	\N	110	18	125	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-26	2026-03-27	
394	244	1	282	FIBOOWL SPIKY FUTTERHAUS RÓŻOWY	800	17	149	15	113	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-03-26	2026-03-27	
395	244	2	281	FIBOOWL SPIKY FUTTERHAUS C.SZARY	809	6	149	15	112	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-03-27	2026-03-30	
396	245	1	219	FIBEEK BEZ OTWORU	2081	\N	148	18	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-03-18	2026-03-18	
397	246	1	344	LICK FIBOOWL C.NIEBIESKI	520	\N	191	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-30	2026-03-30	
398	246	2	355	LICK FIBOOWL ZIELONY	510	22	191	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-26	2026-03-27	
399	246	3	354	LICK FIBOOWL RÓŻOWY	1000	17	191	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-27	2026-03-30	
400	247	1	226	FIBOOM ŻÓŁTY FUTTERHAUS	2213	23	171	18	154	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-03-30	2026-04-01	
401	247	2	224	FIBOOM NIEBIESKI FUTTERHAUS	2204	15	171	18	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-04-01	2026-04-03	
402	247	3	225	FIBOOM RÓŻOWY FUTTERHAUS	2201	17	171	18	124	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-04-03	2026-04-08	
403	248	1	271	FIBOOWL S ZIELONY	775	22	146	15	107	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-30	2026-03-31	
404	248	2	272	FIBOOWL S BEŻOWY	525	2	146	15	117	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-03-31	2026-03-31	
405	248	3	286	FIBOOWL ŻÓŁTY	800	23	146	15	115	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-03-31	2026-04-01	
406	248	4	278	FIBOOWL S RÓŻOWY	600	17	146	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-01	2026-04-01	
407	248	5	276	FIBOOWL S C.SZARY	800	6	146	15	112	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-01	2026-04-02	
408	249	1	291	FIJOO C.NIEBIESKI	800	\N	\N	15	123	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-27	2026-03-27	
409	249	2	293	FIJOO FIOLETOWY	800	9	\N	15	156	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-27	2026-03-30	
410	249	3	296	FIJOO RÓŻOWY	1004	17	\N	15	113	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-30	2026-03-31	
411	249	4	298	FIJOO ŻÓŁTY	800	23	\N	15	115	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-31	2026-03-31	
412	249	5	297	FIJOO ZIELONY	1008	22	\N	15	107	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-03-31	2026-04-01	
413	250	1	299	FIJOO ŻÓŁTY FUTTERHAUS	2700	23	171	15	154	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-01	2026-04-03	
414	250	2	295	FIJOO NIEBIESKI FUTTERHAUS	2700	15	171	15	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-03	2026-04-08	
415	251	1	240	FIBOONE DENTAL MONSTER FUTTERHAUS NIEBIESKI	2805	15	174	18	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	\N	2026-04-07	
416	251	2	241	FIBOONE DENTAL MONSTER FUTTERHAUS ŻÓŁTY	2800	23	174	18	154	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-08	
417	251	3	244	FIBOONE DENTAL MONSTER RÓŻOWY	2814	17	174	18	124	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-10	
418	252	1	483	SNACK FIBOOL JUMBO SOFT FUTTERHAUS NIEBIESKI	2040	15	173	15	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-03-27	2026-03-31	
419	252	2	485	SNACK FIBOOL JUMBO SOFT FUTTERHAUS ŻÓŁTY	2005	23	173	15	154	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-03-31	2026-04-02	
420	252	3	484	SNACK FIBOOL JUMBO SOFT FUTTERHAUS RÓŻOWY	2006	17	173	15	124	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-02	2026-04-03	
421	253	1	466	SLOW FIBOOWL FUTTERHAUS C.SZARY	1000	6	191	15	112	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-04-02	2026-04-03	
422	254	1	516	SZARPAK FIB ZIELONY	810	22	116	18	153	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-01	2026-04-02	
423	254	2	509	SZARPAK FIB POMARAŃCZOWY	1000	16	116	18	125	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-02	2026-04-03	
424	255	1	280	FIBOOWL SPIKY C.SZARY	812	6	149	15	112	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-03-30	2026-03-30	
425	255	2	283	FIBOOWL SPIKY NIEBIESKI	812	15	149	15	123	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-03-30	2026-03-31	
426	255	3	284	FIBOOWL SPIKY RÓŻOWY	812	17	149	15	113	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-03-31	\N	
427	255	4	285	FIBOOWL SPIKY ZIELONY	1008	22	149	15	107	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-04-01	2026-04-02	
428	256	1	368	LOLLIPOP STICKY C.SZARY FUTTERHAUS	1504	6	171	15	112	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-04-03	2026-04-07	
429	256	2	370	LOLLIPOP STICKY RÓŻOWY FUTTERHAUS	1504	17	171	15	113	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-04-07	2026-04-08	
430	257	1	267	FIBOOWL M PSI BUFET	552	\N	151	15	115	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-03	2026-04-07	
431	258	1	482	SNACK FIBOOL JUMBO RÓŻOWY	809	17	173	18	124	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-03	2026-04-07	
432	258	2	481	SNACK FIBOOL JUMBO POMARAŃCZOWY	500	16	173	18	125	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-07	2026-04-07	
433	259	1	330	FRISBOO MINI NIEBIESKI	801	15	203	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-02	2026-04-02	
434	259	2	332	FRISBOO MINI RÓŻOWY	1008	17	203	18	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-02	2026-04-03	
435	259	3	334	FRISBOO MINI ŻÓŁTY	500	23	203	18	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-03	2026-04-03	
436	259	4	331	FRISBOO MINI POMARAŃCZ	800	\N	203	18	125	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-03	2026-04-03	
437	260	1	270	FIBOOWL M ŻÓŁTY	400	23	151	15	115	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-07	2026-04-07	
438	260	2	264	FIBOOWL M C.NIEBIESKI	1000	\N	151	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-07	2026-04-08	
439	260	3	287	FIBOWL M J.SZARY	800	12	44	15	112	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-08	
440	261	1	422	MATA FISHKA TURKUSOWY	1009	20	205	15	157	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-08	
441	261	2	418	MATA FISHKA FIOLETOWY	1010	9	205	15	155	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-09	2026-04-10	
442	261	3	419	MATA FISHKA GRANATOWY	2207	11	205	15	158	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-10	2026-04-10	
443	261	4	416	MATA FISHKA BEŻOWY	874	2	205	15	111	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-12	2026-04-13	
444	261	5	420	MATA FISHKA J.SZARY	600	12	205	15	106	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-13	2026-04-13	
445	262	1	227	FIBOONE BIG PUPPY EUROPRIS	11000	\N	187	15	124	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-14	2026-04-17	
446	263	1	292	FIJOO EUROPRIS	3972	\N	\N	15	156	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-08	2026-04-13	
447	264	1	244	FIBOONE DENTAL MONSTER RÓŻOWY	1000	17	174	18	124	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-17	2026-04-17	
448	264	2	243	FIBOONE DENTAL MONSTER POMARAŃCZOWY	1000	16	174	18	125	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-17	2026-04-19	
449	264	3	245	FIBOONE DENTAL MONSTER ŻÓŁTY	700	23	174	18	154	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-20	2026-04-20	
450	264	4	242	FIBOONE DENTAL MONSTER NIEBIESKI	835	15	174	18	152	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-20	2026-04-20	
451	265	1	474	SLOW FIBOOWL MINI RÓŻOWY	958	17	198	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-13	2026-04-14	
452	265	2	472	SLOW FIBOOWL MINI FIOLET	904	\N	198	15	156	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-14	2026-04-14	
453	265	3	470	SLOW FIBOOWL MINI C.NIEBIESKI	836	\N	198	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-14	2026-04-15	
454	265	4	476	SLOW FIBOOWL MINI ŻÓŁTY	810	23	198	15	115	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-15	2026-04-15	
455	265	5	475	SLOW FIBOOWL MINI ZIELONY	748	22	198	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-15	2026-04-16	
456	265	6	471	SLOW FIBOOWL MINI C.ZIELONY	805	\N	198	15	120	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-16	2026-04-16	
457	265	7	469	SLOW FIBOOWL MINI BORDOWY	809	4	198	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-16	2026-04-17	
458	265	8	473	SLOW FIBOOWL MINI GRANAT	612	\N	198	15	158	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17	2026-04-17	
459	266	1	290	FIBSY NIEBIESKI FUTTERHAUS	1900	15	171	18	\N	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-13	2026-04-14	
460	266	2	288	FIBSY FUTTERHAUS RÓŻOWY	1920	17	171	18	124	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-14	2026-04-15	
461	266	3	289	FIBSY FUTTERHAUS ŻÓLTY	1900	\N	171	18	154	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-15	2026-04-16	
462	267	1	252	FIBOONE PUPPY RÓŻ	1558	\N	175	15	124	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-19	2026-04-19	
463	268	1	353	LICK FIBOOWL MINI ŻÓŁTY	658	23	198	15	115	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-17	2026-04-20	
464	269	1	351	LICK FIBOOWL MINI RÓŻOWY	1000	17	198	15	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-20	2026-04-20	
465	269	2	352	LICK FIBOOWL MINI ZIELONY	704	22	198	15	107	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-20	2026-04-20	
466	269	3	348	LICK FIBOOWL MINI C.ZIELONY	525	\N	198	15	120	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-20	2026-04-20	
467	269	4	349	LICK FIBOOWL MINI FIOLETOWY	1100	9	198	15	156	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-21	2026-04-21	
468	269	5	344	LICK FIBOOWL C.NIEBIESKI	800	\N	191	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-21	2026-04-21	
469	270	1	230	FIBOONE BIG PUPPY RÓŻ	500	\N	187	15	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-04-17	2026-04-17	
470	271	1	313	FRINGOO EUROPRIS	10300	\N	\N	18	124	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-04-20	2026-04-27	
471	272	1	239	FIBOONE DENTAL MONSTER EUROPRIS	4790	\N	174	18	124	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-04-21	2026-04-22	
472	273	1	249	FIBOONE DENTAL RÓŻOWY	9000	17	110	18	124	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-23	2026-04-27	
473	274	1	234	FIBOONE DENTAL EUROPLIS	6300	\N	110	18	124	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-27	2026-04-29	
474	275	1	267	FIBOOWL M PSI BUFET	500	\N	151	15	115	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-04-28	2026-04-28	
475	276	1	423	MATA FIZZA	1717	\N	42	15	167	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-04-30	2026-05-04	
476	277	1	435	MATA SPACEFIB	1200	\N	42	15	158	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-05-04	2026-05-05	
477	278	1	464	SLOW FIBOOWL EUROPRIS	5040	\N	191	15	158	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-05-05	2026-05-13	
478	279	1	530	SZCZOTKA MIEKKA EUROPRIS	7080	\N	46	15	166	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-05-12	2026-05-18	
479	280	1	480	SNACK FIBEEK FUTTERHAUS	1740	\N	148	18	112	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-11	2026-05-12	
480	281	1	533	SZCZOTKA TWARDA	1726	\N	46	15	106	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-05-11	2026-05-12	
481	282	1	486	SNACK FIBOOL SOFT EUROPRIS	6912	\N	115	15	122	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-12	2026-05-18	
482	283	1	456	SLOW FIBOOWL BORDOWY	1010	4	191	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-13	2026-05-14	
483	283	2	477	SLOW FIBOOWL RÓŻOWY	1008	17	191	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-14	2026-05-15	
484	283	3	467	SLOW FIBOOWL GRANATOWY	500	11	191	15	158	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-15	2026-05-18	
485	283	4	459	SLOW FIBOOWL C.NIEBIESKI	500	\N	191	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-18	2026-05-19	
486	283	5	461	SLOW FIBOOWL C.ZIELONY	516	\N	191	15	120	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-05-19	2026-05-19	
487	283	6	465	SLOW FIBOOWL FIOLETOWY	520	9	191	15	156	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-20	2026-05-20	
488	284	1	376	LOLLIPOP WALLY EUROPRIS	9918	\N	204	15	158	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-05-18	2026-05-27	
489	285	1	491	SNACK FIBOOLL SOFT FIOLETOWY	800	9	115	15	122	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-18	2026-05-18	
490	285	2	496	SNACK FIBOOLL SOFT MIĘTOWY	822	14	115	15	121	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-18	2026-05-19	
491	285	3	495	SNACK FIBOOLL SOFT KORALOWY	755	\N	115	15	160	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-19	2026-05-19	
492	286	1	490	SNACK FIBOOLL POMARAŃCZOWY	802	16	115	\N	125	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-20	2026-05-20	
493	286	2	489	SNACK FIBOOLL NIEBIESKI	1010	15	115	\N	152	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-20	2026-05-20	
494	286	3	497	SNACK FIBOOLL ZIELONY	600	22	115	\N	153	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-20	2026-05-20	
495	286	4	498	SNACK FIBOOLL ŻÓLTY	1005	\N	115	\N	154	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-21	2026-05-21	
496	286	5	499	SNAK FIBOOL RÓŻOWY	1018	17	115	\N	124	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-22	2026-05-22	
497	287	1	223	FIBOOFFET SZARY	1007	18	\N	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-28	2026-05-29	
498	287	2	222	FIBOOFFET RÓŻOWY	528	17	\N	15	113	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-29	2026-05-29	
499	288	1	403	MATA 47x30 FUTTERHAUS SZARA	1010	18	159	15	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-05-27	2026-05-28	
500	289	1	384	MATA 32x32 C.NIEBIESKI	508	\N	42	15	123	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-01	2026-06-01	
501	289	2	394	MATA 32x32 JASNO SZARY	1006	18	42	15	106	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-02	2026-06-02	
502	289	3	388	MATA 32x32 CZARNY	527	7	42	15	104	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-02	2026-06-02	
503	290	1	386	MATA 32x32 C.SZARY FUTTERHAUS	1003	6	42	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-03	2026-06-03	
504	290	2	383	MATA 32x32 BEŻ FUTTERHAUS	1009	2	42	15	117	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-03	2026-06-08	
505	290	3	396	MATA 32x32 RÓŻOWY FUTTERHAUS	706	17	42	15	113	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-08	2026-06-09	
506	291	1	377	LOLLIPOP WALLY GRANATOWY	500	11	204	15	158	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-27	2026-05-27	
507	291	2	375	LOLLIPOP WALLY C.ZIELONY	504	\N	204	15	120	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-28	2026-05-28	
508	291	3	372	LOLLIPOP WALLY BORDOWY	500	4	204	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-28	2026-05-28	
509	291	4	381	LOLLIPOP WALLY ŻÓŁTY	500	23	204	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-28	\N	
510	291	5	379	LOLLIPOP WALLY RÓŻOWY	500	17	204	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-29	2026-05-29	
511	291	6	380	LOLLIPOP WALLY ZIELONY	510	22	204	15	113	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-05-29	2026-05-29	
512	292	1	438	MISKA L ZIELONA	1045	22	45	43	107	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-06-02	2026-06-02	
513	293	1	437	MISKA L NIEBIESKA	736	15	45	43	127	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-06-02	2026-06-03	
514	293	2	436	MISKA L CIEMNO SZARY	1000	18	45	43	114	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-06-03	2026-06-03	
515	294	1	259	FIBOOWL L RÓŻOWY	606	17	154	15	113	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-09	2026-06-10	
516	294	2	256	FIBOOWL L CIEMNO NIEBIESKI	607	15	154	15	123	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-10	2026-06-11	
517	294	3	261	FIBOOWL L ŻÓŁTY	600	23	154	15	115	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-11	2026-06-11	
518	294	4	253	FIBOOWL L BEŻOWY	630	2	154	15	117	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-12	2026-06-12	
519	294	5	260	FIBOOWL L ZIELONY	1027	22	154	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-12	2026-06-15	
520	294	6	255	FIBOOWL L C.SZARY	420	6	154	15	112	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-15	2026-06-16	
521	295	1	496	SNACK FIBOOLL SOFT MIĘTOWY	8190	14	115	15	121	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-16	2026-06-23	
522	296	1	242	FIBOONE DENTAL MONSTER NIEBIESKI	825	15	174	18	152	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-23	2026-06-24	
523	296	2	221	FIBONNE DENTAL MONSTER ZIELONY	1500	22	174	18	153	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-24	2026-06-25	
524	296	3	220	FIBONNE DENTAL MONSTER POMARAŃCZOWY	585	16	174	18	125	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-06-25	2026-06-25	
525	297	1	275	FIBOOWL S C.NIEBIESKI	800	\N	146	15	123	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-03	2026-07-03	
526	297	2	278	FIBOOWL S RÓŻOWY	810	17	146	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-03	2026-07-06	
527	297	3	272	FIBOOWL S BEŻOWY	700	2	146	15	117	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-06	2026-07-06	
528	297	4	271	FIBOOWL S ZIELONY	500	22	146	15	107	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-07-06	2026-07-06	
529	297	5	273	FIBOOWL S BORDOWY	435	4	146	15	159	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-06	2026-07-06	
530	297	6	279	FIBOOWL S ŻÓŁTY	410	23	146	15	115	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-07	2026-07-07	
531	297	7	274	FIBOOWL S BUTELKOWA ZIELEŃ	400	\N	146	15	120	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-07	2026-07-07	
532	298	1	263	FIBOOWL M BETTERCAT	3000	\N	151	15	117	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-08	2026-07-10	
533	299	1	269	FIBOOWL M ZIELONY	1240	22	151	15	107	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-07	2026-07-08	
534	300	1	402	MATA 47x30 FUTTERHAUS RÓŻOWY	800	17	159	15	113	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-07-15	2026-07-16	
535	300	2	400	MATA 47x30 FUTTERHAUS BEŻ	1000	2	159	15	112	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-07-16	2026-07-17	
536	301	1	477	SLOW FIBOOWL RÓŻOWY	103	17	191	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-17	2026-07-20	
537	302	1	357	LOLLIPOP BETTERCAT ŚWIĄTECZNY	4200	\N	204	15	144	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-10	2026-07-15	
538	303	1	250	FIBOONE DENTAL ZIELONY	1039	22	110	18	153	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-07-14	2026-07-14	
539	303	2	246	FIBOONE DENTAL NIEBIESKI	1129	15	110	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-14	2026-07-14	
540	304	1	425	MATA LOLIPOOP STICKY RÓŻOWY	1012	17	185	15	113	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-15	2026-07-15	
541	304	2	424	MATA LOLIPOOP STICKY NIEBIESKA	800	15	185	15	123	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-16	2026-07-17	
542	304	3	426	MATA LOLLIPOP C.SZARY	800	6	42	15	112	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-07-17	2026-07-17	
543	305	1	408	MATA FIBLITTER 44x44 BEŻ	559	2	221	15	117	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-21	2026-07-21	
544	305	2	415	MATA FIBLITTER 44x44 RÓŻOWA	532	17	221	15	113	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-21	2026-07-21	
545	305	3	413	MATA FIBLITTER 44x44 J.SZARY	550	12	221	15	106	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-22	2026-07-22	
546	305	4	410	MATA FIBLITTER 44x44 C.SZARY	517	6	221	15	112	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-22	2026-07-22	
547	305	5	414	MATA FIBLITTER 44x44 NIEBIESKI	576	15	221	15	123	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-22	2026-07-23	
548	305	6	412	MATA FIBLITTER 44x44 FIOLET	518	\N	221	15	156	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-23	2026-07-24	
549	305	7	411	MATA FIBLITTER 44x44 CZARNY	513	7	221	15	95	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-24	2026-07-24	
550	306	1	407	MATA FIBLITTER 44x44 BETTERCAT	3000	\N	221	15	117	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-16	2026-07-20	
551	307	1	345	LICK FIBOOWL FIOLETOWY	920	9	191	15	156	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-27	2026-07-28	
552	307	2	346	LICK FIBOOWL GRANATOWY	720	11	191	15	158	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-28	2026-07-28	
553	307	3	342	LICK FIBOOWL BORDOWY	726	4	191	15	159	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-28	2026-07-28	
554	307	4	343	LICK FIBOOWL BUTELKOWA ZIELEŃ	760	\N	191	15	120	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-28	2026-07-29	
555	307	5	344	LICK FIBOOWL C.NIEBIESKI	734	\N	191	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-29	2026-07-30	
556	307	6	355	LICK FIBOOWL ZIELONY	735	22	191	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-07-30	2026-07-31	
557	307	7	356	LICK FIBOOWL ŻÓŁTY	779	23	191	15	\N	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-31	2026-08-03	
558	307	8	354	LICK FIBOOWL RÓŻOWY	726	17	191	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-03	2026-08-03	
559	308	1	382	LOLLIPOP ZIELONY	1200	22	204	15	107	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-29	2026-07-30	
560	308	2	365	LOLLIPOP NIEBIESKI	620	15	204	15	123	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-30	2026-07-30	
561	308	3	358	LOLLIPOP GRANATOWY	600	11	204	15	158	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-31	2026-07-31	
562	308	4	366	LOLLIPOP RÓŻOWY	600	17	204	15	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-31	2026-08-03	
563	308	5	359	LOLLIPOP J.SZARY	600	12	204	15	106	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-03	2026-08-03	
564	309	1	319	FRINGOO MINI RÓŻOWY	1405	17	172	\N	124	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-24	2026-07-24	
565	309	2	317	FRINGOO MINI NIEBIESKI	1250	15	172	\N	152	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-24	2026-07-27	
566	309	3	318	FRINGOO MINI POMARAŃCZ	1098	\N	172	\N	125	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-27	2026-07-28	
567	309	4	321	FRINGOO MINI ŻÓŁTY	1004	23	172	\N	154	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-28	2026-07-28	
568	309	5	320	FRINGOO MINI ZIELONY	804	22	172	\N	153	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-07-28	2026-07-29	
569	310	1	409	MATA FIBLITTER 44x44 BRIT	615	\N	184	15	123	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-07-24	2026-07-24	
570	311	1	347	LICK FIBOOWL MINI BORDOWY	968	4	198	15	159	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-03	2026-08-04	
571	311	2	350	LICK FIBOOWL MINI GRANATOWY	1024	11	198	15	158	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-04	2026-08-05	
572	312	1	479	SLOW FIBOOWL ŻÓŁTY	812	23	191	15	115	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-04	2026-08-04	
573	312	2	478	SLOW FIBOOWL ZIELONY	1018	22	191	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-05	2026-08-05	
574	312	3	465	SLOW FIBOOWL FIOLETOWY	821	9	191	15	156	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-05	2026-08-06	
575	312	4	456	SLOW FIBOOWL BORDOWY	714	4	191	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-06	2026-08-07	
576	312	5	462	SLOW FIBOOWL CIEMNO ZIELONY	724	22	191	15	120	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-07	2026-08-10	
577	313	1	361	LOLLIPOP MINI C.NIEBIESKI	1076	\N	109	15	123	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-07	2026-08-07	
578	313	2	360	LOLLIPOP MINI BEŻOWY	1000	2	109	15	117	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-07	2026-08-10	
579	313	3	363	LOLLIPOP MINI J.SZARY	1000	12	109	15	106	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-10	2026-08-10	
580	313	4	362	LOLLIPOP MINI C.SZARY	1000	6	109	15	112	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-10	2026-08-11	
581	313	5	364	LOLLIPOP MINI ZIELONY	1000	22	109	15	108	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-08-11	2026-08-11	
582	314	1	340	GUMKI DO MISEK DUŻE	60000	1	195	19	\N	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-05	\N	
583	315	1	305	FLIP FIBOOWL BUTELKOWA ZIELEŃ	528	\N	199	15	120	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-10	2026-08-10	
584	315	2	307	FLIP FIBOOWL FIOLETOWY	1056	9	199	15	156	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-10	2026-08-11	
585	315	3	309	FLIP FIBOOWL RÓŻOWY	900	17	199	15	113	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-11	2026-08-11	
586	315	4	304	FLIP FIBOOWL BORDOWY	540	4	199	15	123	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-12	2026-08-12	
587	315	5	306	FLIP FIBOOWL C.NIEBIESKI	707	\N	199	15	123	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-13	2026-08-13	
588	315	6	308	FLIP FIBOOWL GRANATOWY	500	11	199	15	158	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-13	2026-08-17	
589	315	7	311	FLIP FIBOOWL ŻÓŁTY	702	23	199	15	116	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-18	2026-08-18	
590	316	1	310	FLIP FIBOOWL ZIELONY	616	22	199	15	107	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-17	2026-08-18	
591	317	1	367	LOLLIPOP STICKY C.SZARY	1504	6	185	15	112	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-20	2026-08-24	
592	317	2	369	LOLLIPOP STICKY RÓŻOWY	1504	17	185	15	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-24	2026-08-25	
593	318	1	454	POKRYWKA FIBOO LID FIBEEK PEŁNY	3000	\N	148	\N	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-08-17	2026-08-17	
594	319	1	394	MATA 32x32 JASNO SZARY	1505	18	42	15	106	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-26	2026-08-28	
595	319	2	395	MATA 32x32 RÓŻOWY	900	17	42	15	113	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-28	2026-08-31	
596	319	3	387	MATA 32x32 CIEMNO SZARY	1500	18	42	15	112	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-31	2026-09-02	
597	320	1	398	MATA 47x30 CIEMNO SZARY FUTTERHAS	1000	18	159	15	112	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-19	2026-08-20	
598	321	1	397	MATA 47x30 CIEMNO SZARY	920	18	159	15	112	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-20	2026-08-24	
599	321	2	406	MATA 47x30 RÓZOWY	910	\N	159	15	113	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-24	2026-08-25	
600	321	3	405	MATA 47x30 JASNO SZARY	860	18	159	15	106	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-08-25	2026-08-26	
601	322	1	432	MATA POD MISKI FIOLETOWY	280	9	42	57	185	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-08-26	2026-08-27	
602	322	2	433	MATA POD MISKI SZAROFIOLETOWY	255	\N	42	57	\N	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-08-25	2026-08-25	
603	322	3	434	MATA POD MISKI SZAROZIELONY	255	\N	42	57	185	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-08-27	2026-08-27	
604	323	1	519	SZARPAK FIB ŻÓŁTY	805	23	116	18	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-28	2026-08-28	
605	323	2	507	SZARPAK FIB NIEBIESKI	2000	15	116	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-28	2026-09-01	
606	323	3	504	SZARPAK FIB GRANATOWY	1000	11	116	18	158	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-01	2026-09-02	
607	324	1	501	SZARPAK FIB BUTELKOWA ZIELEŃ	1014	\N	116	18	120	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-02	2026-09-03	
608	324	2	500	SZARPAK FIB BORDOWY	1027	4	116	18	159	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-03	2026-09-04	
609	324	3	502	SZARPAK FIB CZERWONY	1016	8	116	18	92	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-04	2026-09-07	
610	324	4	509	SZARPAK FIB POMARAŃCZOWY	1007	16	116	18	125	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-07	2026-09-08	
611	324	5	510	SZARPAK FIB RÓŻOWY	1058	17	116	18	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-08	2026-09-09	
612	325	1	257	FIBOOWL L FUTTERHAUS C.SZARY	500	6	154	15	112	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-02	2026-09-02	
613	325	2	258	FIBOOWL L FUTTERHAUS RÓŻ	770	\N	154	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-03	2026-09-03	
614	326	1	467	SLOW FIBOOWL GRANATOWY	2548	11	191	15	158	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-08	2026-09-11	
615	326	2	459	SLOW FIBOOWL C.NIEBIESKI	427	\N	191	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-11	\N	
616	327	1	487	SNACK FIBOOL SOFT FIOLETOWY	3105	9	115	15	122	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-08	2026-09-09	
617	327	2	488	SNACK FIBOOL SOFT MIODOWY	1120	\N	115	15	161	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-10	2026-09-10	
618	328	1	480	SNACK FIBEEK FUTTERHAUS	2542	\N	148	18	112	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-03	2026-09-08	
619	329	1	512	SZARPAK FIB SOFT FIOLETOWY	1040	9	116	15	122	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-09	2026-09-10	
620	329	2	515	SZARPAK FIB SOFT MIĘTOWY	1000	14	116	15	121	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-10	2026-09-11	
621	329	3	514	SZARPAK FIB SOFT MIODOWY	967	\N	116	15	161	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-11	2026-09-15	
622	329	4	513	SZARPAK FIB SOFT KORALOWY	1000	\N	116	15	160	\N	\N	8	\N	\N	\N	\N	\N	\N	2026-09-15	2026-09-16	
623	330	1	377	LOLLIPOP WALLY GRANATOWY	4066	11	204	15	158	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-09	2026-09-15	
624	330	2	372	LOLLIPOP WALLY BORDOWY	846	4	204	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-15	2026-09-15	
625	330	3	379	LOLLIPOP WALLY RÓŻOWY	1037	17	204	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-15	2026-09-16	
626	330	4	381	LOLLIPOP WALLY ŻÓŁTY	851	23	204	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-16	2026-09-17	
627	330	5	371	LOLLIPOP WALLY BEŻOWY	1037	2	204	15	117	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-09-17	2026-09-18	
628	330	6	378	LOLLIPOP WALLY J.SZARY	874	12	204	15	106	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-09-18	2026-09-18	
629	330	7	374	LOLLIPOP WALLY C.SZARY	856	6	204	15	112	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-21	
630	330	8	375	LOLLIPOP WALLY C.ZIELONY	836	\N	204	15	120	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-22	
631	330	9	373	LOLLIPOP WALLY C. NIEBIESKI	1005	15	204	15	123	\N	\N	1	\N	\N	\N	\N	\N	\N	2026-09-22	2026-09-23	
632	331	1	293	FIJOO FIOLETOWY	3110	9	\N	15	156	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-10	2026-09-15	
633	332	1	238	FIBOONE DENTAL MONSTER	2520	\N	174	18	124	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-14	2026-09-15	
634	333	1	523	SZARPAK FIBSY RÓŻOWY	801	17	200	18	124	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-18	2026-09-21	
635	333	2	520	SZARPAK FIBSY FIOLETOWY	813	9	200	18	156	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-21	
636	333	3	529	SZARPAK FIBSY ŻÓŁTY	737	23	200	18	154	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-21	
637	333	4	528	SZARPAK FIBSY ZIELONY	740	22	200	18	152	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-22	2026-09-23	
638	333	5	521	SZARPAK FIBSY NIEBIESKI	813	15	200	18	152	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-24	
639	333	6	522	SZARPAK FIBSY POMARAŃCZ	815	\N	200	18	125	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-24	2026-09-24	
640	334	1	263	FIBOOWL M BETTERCAT	3000	\N	151	15	117	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-09-14	2026-09-16	
641	335	1	470	SLOW FIBOOWL MINI C.NIEBIESKI	1036	\N	198	15	123	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-17	2026-09-18	
642	335	2	473	SLOW FIBOOWL MINI GRANAT	660	\N	198	15	158	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18	2026-09-18	
643	335	3	469	SLOW FIBOOWL MINI BORDOWY	890	4	198	15	159	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-18	2026-09-21	
644	335	4	471	SLOW FIBOOWL MINI C.ZIELONY	862	\N	198	15	120	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-22	
645	335	5	472	SLOW FIBOOWL MINI FIOLET	836	\N	198	15	156	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-22	2026-09-22	
646	335	6	474	SLOW FIBOOWL MINI RÓŻOWY	836	17	198	15	113	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-24	
647	335	7	475	SLOW FIBOOWL MINI ZIELONY	704	22	198	15	107	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24	2026-09-24	
648	335	8	476	SLOW FIBOOWL MINI ŻÓŁTY	616	23	198	15	115	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-24	2026-09-25	
649	336	1	452	MISKA S ZIELONY	1840	22	43	43	107	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-15	2026-09-16	
650	336	2	447	MISKA S C.NIEBIESKI	960	\N	43	43	109	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-16	2026-09-16	
651	336	3	453	MISKA S ŻÓŁTY	960	23	43	43	116	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-17	2026-09-17	
652	336	4	449	MISKA S JASNO NIEBIESKI	1005	15	43	43	187	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-17	2026-09-18	
653	336	5	446	MISKA S BIAŁY	480	3	43	43	139	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-18	2026-09-18	
654	336	6	448	MISKA S C.SZARY	640	6	43	43	114	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-18	2026-09-18	
655	336	7	450	MISKA S RÓŻOWY	1440	17	43	43	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-22	
656	337	1	312	FRINGOO RÓŻOWY	3104	17	\N	18	124	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-09-17	2026-09-21	
657	337	2	322	FRINGOO NIEBIESKI	1049	15	\N	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-22	
658	338	1	249	FIBOONE DENTAL RÓŻOWY	3055	17	110	18	124	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-09-15	2026-09-16	
659	339	1	231	FIBOONE BIG PUPPY RÓŻOWY	3500	17	187	15	124	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-09-18	2026-09-23	
660	339	2	229	FIBOONE BIG PUPPY POARAŃCZ	1040	\N	187	15	125	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-21	2026-09-22	
661	339	3	233	FIBOONE BIG PUPPY ŻÓŁTY	1286	23	187	15	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-22	2026-09-22	
662	339	4	228	FIBOONE BIG PUPPY NIEBIESKI	1570	15	187	15	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-22	2026-09-23	
663	339	5	232	FIBOONE BIG PUPPY ZIELONY	559	22	187	15	153	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-23	
664	340	1	527	SZARPAK FIBSY SOFT MIĘTOWY	720	14	200	15	121	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-24	2026-09-25	
665	340	2	526	SZARPAK FIBSY SOFT MIODOWY	711	\N	200	15	161	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-25	2026-09-25	
666	340	3	525	SZARPAK FIBSY SOFT KORALOWY	700	\N	200	15	160	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-28	2026-09-28	
667	340	4	524	SZARPAK FIBSY SOFT FIOLETOWY	700	9	200	15	122	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-28	2026-09-29	
668	341	1	531	SZCZOTKA MIEKKA ŻÓŁTY	3000	23	46	15	166	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-25	
669	342	1	332	FRISBOO MINI RÓŻOWY	1130	17	203	18	124	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-22	2026-09-23	
670	342	2	331	FRISBOO MINI POMARAŃCZ	1033	\N	203	18	125	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-23	
671	342	3	334	FRISBOO MINI ŻÓŁTY	800	23	203	18	154	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-23	2026-09-24	
672	342	4	333	FRISBOO MINI ZIELONY	852	22	203	18	153	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-09-24	2026-09-24	
673	342	5	330	FRISBOO MINI NIEBIESKI	1020	15	203	18	152	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-25	2026-09-25	
674	343	1	532	SZCZOTKA MIĘKKA HAPPY DOG	5273	\N	152	15	158	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-09-25	2026-10-01	
675	344	1	294	FIJOO JUSTRUSSEL	5280	\N	\N	15	102	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-09-30	2026-10-06	
676	345	1	506	SZARPAK FIB JUSTRASSEL	5200	\N	116	\N	102	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-10-06	2026-10-12	
677	346	1	301	FIPLOO RÓŻOWY	1077	17	196	15	113	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-10-01	2026-10-02	
678	346	2	303	FIPLOO ŻÓŁTY	522	23	196	15	115	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-10-02	2026-10-02	
679	346	3	302	FIPLOO ZIELONY	764	22	196	15	108	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-10-02	2026-10-05	
680	346	4	300	FIPLOO FIOLETOWY	740	9	196	15	156	\N	\N	4	\N	\N	\N	\N	\N	\N	2026-10-05	2026-10-06	
681	347	1	417	MATA FISHKA C.NIEBIESKI	520	\N	205	15	\N	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-10-08	2026-10-09	
682	347	2	422	MATA FISHKA TURKUSOWY	1097	20	205	15	157	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-09	2026-10-12	
683	347	3	418	MATA FISHKA FIOLETOWY	1039	9	205	15	155	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-10-12	2026-10-12	
684	347	4	421	MATA FISHKA JASNO SZARY	0	18	205	15	106	\N	\N	3	\N	\N	\N	\N	\N	\N	2026-10-13	\N	Ilość w zamówieniu: 
685	348	1	505	SZARPAK FIB HUSSE	0	\N	116	18	144	\N	\N	9	\N	\N	\N	\N	\N	\N	2026-10-13	\N	Ilość w zamówieniu: 
686	349	1	546	LISTWA GRUBA BRĄZOWA	10250	5	75	36	151	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-20	2026-05-27	
687	349	2	541	LISTWA CIENKA BRĄZOWY	10250	5	75	36	151	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-20	2026-05-27	
688	349	3	539	LISTAW GRUBA GRAFIT	10700	10	\N	36	150	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-05-27	2026-06-02	
689	349	4	543	LISTWA CIENKA GRAFIT	10700	10	75	36	150	\N	\N	7	\N	\N	\N	\N	\N	\N	2026-05-27	2026-06-02	
690	349	5	547	LISTWA GRUBA CZARNY	12800	7	75	36	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-03	2026-06-16	
691	349	6	542	LISTWA CIENKA CZARNY	12800	7	75	36	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-03	2026-06-16	
692	350	1	535	BOK PRAWY LEWY BRĄZ	25000	5	\N	1	151	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-05-21	2026-05-29	
693	350	2	537	BOK PRAWY LEWY GRAFIT	27800	10	\N	1	150	\N	\N	6	\N	\N	\N	\N	\N	\N	2026-05-29	2026-06-12	
694	350	3	536	BOK PRAWY LEWY CZARNY	55000	7	\N	1	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-12	2026-06-26	Ilość w zamówieniu: 25000 prawy 30000 lewy
695	351	1	538	BOK PRAWY LEWY GRAFITOWY	25000	10	\N	1	150	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-08-10	2026-08-20	
696	351	2	535	BOK PRAWY LEWY BRĄZ	17500	5	\N	1	151	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-20	2026-08-28	
697	351	3	534	BOK PRAWY LEWY BIAŁY	7500	3	\N	1	\N	\N	\N	5	\N	\N	\N	\N	\N	\N	2026-08-28	2026-09-02	
698	351	4	536	BOK PRAWY LEWY CZARNY	50370	7	\N	1	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-02	2026-09-14	Ilość w zamówieniu: 25370 lewy 25000 prawy
699	352	1	547	LISTWA GRUBA CZARNY	10000	7	75	36	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-17	2026-08-25	
700	352	2	542	LISTWA CIENKA CZARNY	10300	7	75	36	95	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-08-17	2026-08-25	
701	352	3	544	LISTWA CIENKA GRAFITOWY	10000	10	75	36	150	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-08-25	2026-09-02	
702	352	4	546	LISTWA GRUBA BRĄZOWA	7000	5	75	36	151	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-02	2026-09-09	
703	352	5	541	LISTWA CIENKA BRĄZOWY	7000	5	75	36	151	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-02	2026-09-09	
704	352	6	545	LISTWA GRUBA BIAŁY	3000	3	75	36	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-09-09	2026-09-11	
705	352	7	540	LISTWA CIENKA BIAŁY	3000	3	75	36	\N	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-09-09	2026-09-11	
706	353	1	548	LISTWA GRUBA GRAFITOWY	10000	10	75	36	150	\N	\N	2	\N	\N	\N	\N	\N	\N	2026-08-25	2026-09-02	
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.orders (id, number, client_id, seq, order_date, requested_date, channel, received_by, ordered_by, ordered_email, client_ref, source_ref, internal_no, status, planned_start, planned_end, delivery_date, notes, accepted_at, started_at, finished_at, created_at) FROM stdin;
1	ZK 017 26 09 26 001	2	1	2026-09-26	2026-10-06	e-mail	\N	Paweł Król	pawel.krol@okiday.pl	\N	ZK/OKIDAY/001/2026	352/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
2	ZK 016 26 09 14 001	3	1	2026-09-14	2026-09-29	e-mail	\N	Krzysztof Pawłowski	krzysztof.pawlowski@mobilus.pl	\N	ZK/MOBILUS/001/2026	335/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
3	ZK 016 26 09 19 003	3	3	2026-09-19	2026-10-06	formularz zamówieniowy (strona WWW)	\N	Krzysztof Pawłowski	krzysztof.pawlowski@mobilus.pl	\N	ZK/MOBILUS/003/2026	333/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
4	ZK 016 26 09 23 002	3	2	2026-09-23	2026-10-01	platforma B2B / EDI	\N	Krzysztof Pawłowski	krzysztof.pawlowski@mobilus.pl	\N	ZK/MOBILUS/002/2026	334/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
5	ZK 009 26 08 03 001	4	1	2026-08-03	2026-08-19	e-mail	\N	Grzegorz Wiśniewski	grzegorz.wisniewski@holypit.pl	\N	ZK/HOLYPIT/001/2026	275/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
6	ZK 009 26 08 07 002	4	2	2026-08-07	2026-08-21	e-mail	\N	Grzegorz Wiśniewski	grzegorz.wisniewski@holypit.pl	\N	ZK/HOLYPIT/002/2026	278/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
7	ZK 009 26 08 10 004	4	4	2026-08-10	2026-08-21	telefon + potwierdzenie e-mail	\N	Grzegorz Wiśniewski	grzegorz.wisniewski@holypit.pl	\N	ZK/HOLYPIT/004/2026	279/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
8	ZK 009 26 08 14 003	4	3	2026-08-14	2026-08-20	e-mail	\N	Grzegorz Wiśniewski	grzegorz.wisniewski@holypit.pl	\N	ZK/HOLYPIT/003/2026	277/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
9	ZK 009 26 08 15 005	4	5	2026-08-15	2026-08-25	e-mail	\N	Grzegorz Wiśniewski	grzegorz.wisniewski@holypit.pl	\N	ZK/HOLYPIT/005/2026	280/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
10	ZK 020 26 05 01 001	5	1	2026-05-01	2026-07-09	platforma B2B / EDI	\N	Krzysztof Pawłowski	krzysztof.pawlowski@regaltags.pl	\N	ZK/RTG/001/2026	157/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
11	ZK 004 26 04 15 002	6	2	2026-04-15	2026-05-05	e-mail	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/002/2026	147/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
12	ZK 004 26 04 16 001	6	1	2026-04-16	2026-04-29	e-mail	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/001/2026	124/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
13	ZK 004 26 05 01 004	6	4	2026-05-01	2026-05-12	platforma B2B / EDI	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/004/2026	146/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
14	ZK 004 26 05 05 003	6	3	2026-05-05	2026-05-18	platforma B2B / EDI	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/003/2026	140/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
15	ZK 004 26 07 01 005	6	5	2026-07-01	2026-07-17	telefon + potwierdzenie e-mail	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/005/2026	231/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
16	ZK 004 26 07 15 006	6	6	2026-07-15	2026-07-23	e-mail	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/006/2026	236/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
17	ZK 004 26 07 18 007	6	7	2026-07-18	2026-07-30	platforma B2B / EDI	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/007/2026	237/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
18	ZK 004 26 07 23 008	6	8	2026-07-23	2026-08-08	formularz zamówieniowy (strona WWW)	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/008/2026	238/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
19	ZK 004 26 08 01 009	6	9	2026-08-01	2026-08-17	e-mail	\N	Tomasz Woźniak	tomasz.wozniak@euroster.pl	\N	ZK/EUROSTER/009/2026	272/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
20	ZK 015 26 04 09 001	7	1	2026-04-09	2026-04-24	e-mail	\N	Magdalena Mazur	magdalena.mazur@marmite.pl	\N	ZK/MARMITE/001/2026	120/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
21	ZK 015 26 07 22 002	7	2	2026-07-22	2026-08-07	formularz zamówieniowy (strona WWW)	\N	Magdalena Mazur	magdalena.mazur@marmite.pl	\N	ZK/MARMITE/002/2026	265/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
22	ZK 015 26 09 24 003	7	3	2026-09-24	2026-10-08	e-mail	\N	Magdalena Mazur	magdalena.mazur@marmite.pl	\N	ZK/MARMITE/003/2026	353/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
23	ZK 015 26 09 24 005	7	5	2026-09-24	\N	e-mail	\N	Magdalena Mazur	magdalena.mazur@marmite.pl	\N	ZK/MARMITE/005/2026	355/2026	W PRODUKCJI	\N	\N	\N	\N	2026-09-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
24	ZK 015 26 09 30 004	7	4	2026-09-30	2026-10-08	platforma B2B / EDI	\N	Magdalena Mazur	magdalena.mazur@marmite.pl	\N	ZK/MARMITE/004/2026	354/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
25	ZK 023 26 03 28 001	8	1	2026-03-28	2026-04-10	e-mail	\N	Agnieszka Szymański	agnieszka.szymanski@timberness.pl	\N	ZK/TIMBERNE/001/2026	100/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
26	ZK 023 26 03 30 002	8	2	2026-03-30	2026-04-15	e-mail	\N	Agnieszka Szymański	agnieszka.szymanski@timberness.pl	\N	ZK/TIMBERNE/002/2026	101/82026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
27	ZK 005 26 02 05 001	9	1	2026-02-05	2026-02-26	e-mail	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/001/2026	44/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
28	ZK 005 26 02 06 002	9	2	2026-02-06	2026-02-26	e-mail	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/002/2026	45/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
29	ZK 005 26 02 15 003	9	3	2026-02-15	2026-03-04	platforma B2B / EDI	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/003/2026	55/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
30	ZK 005 26 05 11 004	9	4	2026-05-11	2026-05-25	formularz zamówieniowy (strona WWW)	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/004/2026	181/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
31	ZK 005 26 05 13 005	9	5	2026-05-13	2026-05-26	platforma B2B / EDI	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/005/2026	182/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
32	ZK 005 26 06 14 006	9	6	2026-06-14	2026-07-01	formularz zamówieniowy (strona WWW)	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/006/2026	215/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
33	ZK 005 26 07 05 007	9	7	2026-07-05	2026-07-16	e-mail	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/007/2026	242/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
34	ZK 005 26 09 15 010	9	10	2026-09-15	2026-10-05	platforma B2B / EDI	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/010/2026	298/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
35	ZK 005 26 09 16 008	9	8	2026-09-16	2026-09-29	e-mail	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/008/2026	323/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
36	ZK 005 26 09 17 011	9	11	2026-09-17	2026-10-05	formularz zamówieniowy (strona WWW)	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/011/2026	324/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
37	ZK 005 26 09 29 009	9	9	2026-09-29	2026-10-09	platforma B2B / EDI	\N	Rafał Lewandowski	rafal.lewandowski@evr.pl	\N	ZK/EVR/009/2026	297/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
38	ZK 010 26 01 29 001	10	1	2026-01-29	2026-02-16	formularz zamówieniowy (strona WWW)	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/001/2026	35/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
39	ZK 010 26 04 03 002	10	2	2026-04-03	2026-04-21	e-mail	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/002/2026	116/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
40	ZK 010 26 04 15 003	10	3	2026-04-15	2026-04-30	platforma B2B / EDI	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/003/2026	117/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
41	ZK 010 26 04 23 004	10	4	2026-04-23	2026-05-06	e-mail	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/004/2026	139/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
42	ZK 010 26 04 26 005	10	5	2026-04-26	2026-05-08	e-mail	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/005/2026	160/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
43	ZK 010 26 05 24 009	10	9	2026-05-24	2026-07-03	formularz zamówieniowy (strona WWW)	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/009/2026	193/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
44	ZK 010 26 06 04 006	10	6	2026-06-04	2026-06-22	telefon + potwierdzenie e-mail	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/006/2026	190/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-04 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
45	ZK 010 26 06 16 008	10	8	2026-06-16	2026-07-02	platforma B2B / EDI	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/008/2026	192/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
46	ZK 010 26 06 17 007	10	7	2026-06-17	2026-06-29	e-mail	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/007/2026	191/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
47	ZK 010 26 08 08 010	10	10	2026-08-08	2026-08-24	platforma B2B / EDI	\N	Grzegorz Mazur	grzegorz.mazur@ivt.pl	\N	ZK/IVT/010/2026	252/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
48	ZK 022 26 01 24 001	11	1	2026-01-24	2026-02-17	platforma B2B / EDI	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/001/2026	30/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
49	ZK 022 26 02 05 002	11	2	2026-02-05	2026-02-27	e-mail	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/002/2026	31/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
50	ZK 022 26 02 19 004	11	4	2026-02-19	2026-03-09	e-mail	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/004/2026	50/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
51	ZK 022 26 02 21 003	11	3	2026-02-21	2026-03-03	formularz zamówieniowy (strona WWW)	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/003/2026	32/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
52	ZK 022 26 03 05 005	11	5	2026-03-05	2026-03-13	formularz zamówieniowy (strona WWW)	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/005/2026	60/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
53	ZK 022 26 04 07 006	11	6	2026-04-07	2026-04-24	telefon + potwierdzenie e-mail	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/006/2026	119/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
54	ZK 022 26 06 08 007	11	7	2026-06-08	2026-06-23	telefon + potwierdzenie e-mail	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/007/2026	195/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
55	ZK 022 26 07 11 008	11	8	2026-07-11	2026-07-22	e-mail	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/008/2026	239/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
56	ZK 022 26 08 14 009	11	9	2026-08-14	2026-09-07	formularz zamówieniowy (strona WWW)	\N	Dariusz Nowak	dariusz.nowak@scooptec.pl	\N	ZK/SCOOPTEC/009/2026	291/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
57	ZK 012 26 01 26 001	12	1	2026-01-26	2026-02-04	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/001/2026	27/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
58	ZK 012 26 01 30 002	12	2	2026-01-30	2026-02-05	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/002/2026	33/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
59	ZK 012 26 02 01 003	12	3	2026-02-01	2026-02-09	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/003/2026	34/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
60	ZK 012 26 03 10 004	12	4	2026-03-10	2026-03-24	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/004/2026	64/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
61	ZK 012 26 03 12 005	12	5	2026-03-12	2026-03-24	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/005/2026	79/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
62	ZK 012 26 03 13 008	12	8	2026-03-13	2026-03-30	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/008/2026	65/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
63	ZK 012 26 03 14 006	12	6	2026-03-14	2026-03-25	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/006/2026	80/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
64	ZK 012 26 03 20 007	12	7	2026-03-20	2026-03-26	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/007/2026	81/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
65	ZK 012 26 03 28 009	12	9	2026-03-28	2026-04-14	formularz zamówieniowy (strona WWW)	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/009/2026	109/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
66	ZK 012 26 04 01 011	12	11	2026-04-01	2026-04-16	formularz zamówieniowy (strona WWW)	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/011/2026	125/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
67	ZK 012 26 04 03 010	12	10	2026-04-03	2026-04-14	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/010/2026	110/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
68	ZK 012 26 04 11 012	12	12	2026-04-11	2026-04-27	formularz zamówieniowy (strona WWW)	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/012/2026	141/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
69	ZK 012 26 04 15 018	12	18	2026-04-15	2026-05-04	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/018/2026	122/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
70	ZK 012 26 04 16 013	12	13	2026-04-16	2026-04-27	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/013/2026	142/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
71	ZK 012 26 04 17 014	12	14	2026-04-17	2026-04-28	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/014/2026	121/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
72	ZK 012 26 04 19 016	12	16	2026-04-19	2026-05-08	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/016/2026	118/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
73	ZK 012 26 04 20 015	12	15	2026-04-20	2026-05-14	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/015/2026	145/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
74	ZK 012 26 04 23 017	12	17	2026-04-23	2026-04-29	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/017/2026	123/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
75	ZK 012 26 04 25 019	12	19	2026-04-25	2026-05-05	formularz zamówieniowy (strona WWW)	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/019/2026	162/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
76	ZK 012 26 05 01 020	12	20	2026-05-01	2026-05-08	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/020/2026	163/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
77	ZK 012 26 05 07 021	12	21	2026-05-07	2026-05-20	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/021/2026	177/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
78	ZK 012 26 05 10 022	12	22	2026-05-10	2026-05-21	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/022/2026	178/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
79	ZK 012 26 05 18 023	12	23	2026-05-18	2026-06-08	formularz zamówieniowy (strona WWW)	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/023/2026	184/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
80	ZK 012 26 05 26 025	12	25	2026-05-26	2026-06-17	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/025/2026	189/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
81	ZK 012 26 05 30 026	12	26	2026-05-30	2026-06-17	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/026/2026	197/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
82	ZK 012 26 06 01 024	12	24	2026-06-01	2026-06-11	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/024/2026	198/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
83	ZK 012 26 06 06 027	12	27	2026-06-06	2026-06-23	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/027/2026	196/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
84	ZK 012 26 06 12 028	12	28	2026-06-12	2026-07-01	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/028/2026	203/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
85	ZK 012 26 06 21 030	12	30	2026-06-21	2026-07-09	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/030/2026	218/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
86	ZK 012 26 06 25 029	12	29	2026-06-25	2026-07-03	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/029/2026	206/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
87	ZK 012 26 06 25 031	12	31	2026-06-25	2026-07-22	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/031/2026	216/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
88	ZK 012 26 06 28 032	12	32	2026-06-28	2026-07-08	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/032/2026	222/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
89	ZK 012 26 06 29 034	12	34	2026-06-29	2026-07-13	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/034/2026	220/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
90	ZK 012 26 07 01 033	12	33	2026-07-01	2026-07-10	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/033/2026	221/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
91	ZK 012 26 07 08 035	12	35	2026-07-08	2026-07-14	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/035/2026	223/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
92	ZK 012 26 07 08 036	12	36	2026-07-08	2026-07-14	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/036/2026	219/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
93	ZK 012 26 08 11 037	12	37	2026-08-11	2026-08-19	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/037/2026	284/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
94	ZK 012 26 08 12 039	12	39	2026-08-12	2026-08-27	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/039/2026	285/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
95	ZK 012 26 08 13 038	12	38	2026-08-13	2026-08-20	formularz zamówieniowy (strona WWW)	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/038/2026	283/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
96	ZK 012 26 08 21 040	12	40	2026-08-21	2026-08-28	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/040/2026	286/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
97	ZK 012 26 09 03 041	12	41	2026-09-03	2026-09-21	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/041/2026	332/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
98	ZK 012 26 09 12 043	12	43	2026-09-12	2026-09-24	platforma B2B / EDI	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/043/2026	327/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
99	ZK 012 26 09 14 042	12	42	2026-09-14	2026-09-22	formularz zamówieniowy (strona WWW)	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/042/2026	340/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
100	ZK 012 26 09 16 046	12	46	2026-09-16	2026-09-29	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/046/2026	337/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
101	ZK 012 26 09 19 045	12	45	2026-09-19	2026-09-25	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/045/2026	341/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
102	ZK 012 26 09 19 047	12	47	2026-09-19	2026-10-02	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/047/2026	339/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
103	ZK 012 26 09 20 044	12	44	2026-09-20	2026-10-01	telefon + potwierdzenie e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/044/2026	338/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
104	ZK 012 26 09 20 048	12	48	2026-09-20	2026-09-30	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/048/2026	342/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
105	ZK 012 26 10 02 049	12	49	2026-10-02	\N	e-mail	\N	Ewa Kowalczyk	ewa.kowalczyk@lp.pl	\N	ZK/LP/049/2026	358/2026	W PRODUKCJI	\N	\N	\N	\N	2026-10-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
106	ZK 021 26 01 19 001	13	1	2026-01-19	2026-02-26	formularz zamówieniowy (strona WWW)	\N	Michał Zieliński	michal.zielinski@rosa.pl	\N	ZK/ROSA/001/2026	13/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
107	ZK 021 26 02 14 002	13	2	2026-02-14	2026-03-26	e-mail	\N	Michał Zieliński	michal.zielinski@rosa.pl	\N	ZK/ROSA/002/2026	47/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
108	ZK 021 26 03 26 003	13	3	2026-03-26	2026-04-27	e-mail	\N	Michał Zieliński	michal.zielinski@rosa.pl	\N	ZK/ROSA/003/2026	48/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
109	ZK 021 26 07 14 004	13	4	2026-07-14	2026-08-17	platforma B2B / EDI	\N	Michał Zieliński	michal.zielinski@rosa.pl	\N	ZK/ROSA/004/2026	244/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
110	ZK 021 26 08 07 005	13	5	2026-08-07	2026-09-14	e-mail	\N	Michał Zieliński	michal.zielinski@rosa.pl	\N	ZK/ROSA/005/2026	268/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
111	ZK 007 26 01 16 001	14	1	2026-01-16	2026-02-02	e-mail	\N	Grzegorz Woźniak	grzegorz.wozniak@hic.pl	\N	ZK/HIC/001/2026	23/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
112	ZK 007 26 03 25 002	14	2	2026-03-25	2026-04-09	formularz zamówieniowy (strona WWW)	\N	Grzegorz Woźniak	grzegorz.wozniak@hic.pl	\N	ZK/HIC/002/2026	102/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
113	ZK 007 26 04 03 003	14	3	2026-04-03	2026-04-09	formularz zamówieniowy (strona WWW)	\N	Grzegorz Woźniak	grzegorz.wozniak@hic.pl	\N	ZK/HIC/003/2026	111/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
114	ZK 007 26 08 26 004	14	4	2026-08-26	2026-09-10	formularz zamówieniowy (strona WWW)	\N	Grzegorz Woźniak	grzegorz.wozniak@hic.pl	\N	ZK/HIC/004/2026	313/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
115	ZK 007 26 09 03 005	14	5	2026-09-03	2026-09-11	formularz zamówieniowy (strona WWW)	\N	Grzegorz Woźniak	grzegorz.wozniak@hic.pl	\N	ZK/HIC/005/2026	314/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
116	ZK 007 26 09 06 006	14	6	2026-09-06	2026-09-17	platforma B2B / EDI	\N	Grzegorz Woźniak	grzegorz.wozniak@hic.pl	\N	ZK/HIC/006/2026	315/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
117	ZK 019 26 01 14 001	15	1	2026-01-14	2026-02-02	platforma B2B / EDI	\N	Krzysztof Michalski	krzysztof.michalski@rais.pl	\N	ZK/RAIS/001/2026	19/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
118	ZK 019 26 01 24 002	15	2	2026-01-24	2026-02-11	e-mail	\N	Krzysztof Michalski	krzysztof.michalski@rais.pl	\N	ZK/RAIS/002/2026	20/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
119	ZK 019 26 04 10 003	15	3	2026-04-10	2026-04-27	e-mail	\N	Krzysztof Michalski	krzysztof.michalski@rais.pl	\N	ZK/RAIS/003/2026	148/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
120	ZK 019 26 04 26 004	15	4	2026-04-26	2026-05-06	telefon + potwierdzenie e-mail	\N	Krzysztof Michalski	krzysztof.michalski@rais.pl	\N	ZK/RAIS/004/2026	153/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
121	ZK 019 26 05 24 005	15	5	2026-05-24	2026-06-01	e-mail	\N	Krzysztof Michalski	krzysztof.michalski@rais.pl	\N	ZK/RAIS/005/2026	171/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
122	ZK 019 26 05 26 006	15	6	2026-05-26	2026-06-09	telefon + potwierdzenie e-mail	\N	Krzysztof Michalski	krzysztof.michalski@rais.pl	\N	ZK/RAIS/006/2026	172/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
123	ZK 001 26 01 12 001	16	1	2026-01-12	2026-01-23	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/001/2026	11/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
124	ZK 001 26 01 17 003	16	3	2026-01-17	2026-02-05	formularz zamówieniowy (strona WWW)	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/003/2026	25/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
125	ZK 001 26 01 21 002	16	2	2026-01-21	2026-01-29	formularz zamówieniowy (strona WWW)	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/002/2026	22/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
126	ZK 001 26 02 08 004	16	4	2026-02-08	2026-03-02	platforma B2B / EDI	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/004/2026	43/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
127	ZK 001 26 03 03 005	16	5	2026-03-03	2026-03-19	telefon + potwierdzenie e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/005/2026	68/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
128	ZK 001 26 04 06 006	16	6	2026-04-06	2026-04-21	formularz zamówieniowy (strona WWW)	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/006/2026	87/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
129	ZK 001 26 04 23 007	16	7	2026-04-23	2026-04-30	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/007/2026	152/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
130	ZK 001 26 05 02 008	16	8	2026-05-02	2026-05-14	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/008/2026	164/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
131	ZK 001 26 05 02 009	16	9	2026-05-02	2026-05-21	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/009/2026	170/2026	W PRODUKCJI	\N	\N	\N	\N	2026-05-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
132	ZK 001 26 06 13 010	16	10	2026-06-13	2026-07-02	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/010/2026	185/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
133	ZK 001 26 06 14 011	16	11	2026-06-14	2026-07-02	platforma B2B / EDI	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/011/2026	208/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
134	ZK 001 26 07 13 012	16	12	2026-07-13	2026-07-29	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/012/2026	245/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
135	ZK 001 26 08 19 013	16	13	2026-08-19	2026-09-11	formularz zamówieniowy (strona WWW)	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/013/2026	292/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
136	ZK 001 26 09 05 014	16	14	2026-09-05	2026-09-18	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/014/2026	301/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
137	ZK 001 26 10 02 015	16	15	2026-10-02	\N	e-mail	\N	Ewa Wójcik	ewa.wojcik@app.pl	\N	ZK/APP/015/2026	359/2026	W PRODUKCJI	\N	\N	\N	\N	2026-10-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
138	ZK 025 26 01 08 001	17	1	2026-01-08	2026-01-28	e-mail	\N	Magdalena Piotrowski	magdalena.piotrowski@lukasik.pl	\N	ZK/LUK/001/2026	10/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
139	ZK 025 26 02 22 002	17	2	2026-02-22	2026-03-24	formularz zamówieniowy (strona WWW)	\N	Magdalena Piotrowski	magdalena.piotrowski@lukasik.pl	\N	ZK/LUK/002/2026	59/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
140	ZK 002 26 01 13 001	18	1	2026-01-13	2026-01-21	telefon + potwierdzenie e-mail	\N	Paweł Michalski	pawel.michalski@bit.pl	\N	ZK/BIT/001/2026	12/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
141	ZK 002 26 06 20 002	18	2	2026-06-20	2026-07-03	telefon + potwierdzenie e-mail	\N	Paweł Michalski	pawel.michalski@bit.pl	\N	ZK/BIT/002/2026	207/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
142	ZK 006 26 01 08 001	19	1	2026-01-08	2026-01-29	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/001/2026	09/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
143	ZK 006 26 01 22 002	19	2	2026-01-22	2026-03-03	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/002/2026	24/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
144	ZK 006 26 02 24 004	19	4	2026-02-24	2026-03-17	telefon + potwierdzenie e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/004/2026	69/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
145	ZK 006 26 02 26 003	19	3	2026-02-26	2026-03-19	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/003/2026	56/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
146	ZK 006 26 03 24 005	19	5	2026-03-24	2026-04-23	platforma B2B / EDI	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/005/2026	93/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
147	ZK 006 26 03 25 006	19	6	2026-03-25	2026-04-20	telefon + potwierdzenie e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/006/2026	92/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
148	ZK 006 26 04 27 007	19	7	2026-04-27	2026-06-09	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/007/2026	144/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-27 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
149	ZK 006 26 05 01 008	19	8	2026-05-01	2026-05-28	platforma B2B / EDI	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/008/2026	149/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
150	ZK 006 26 06 02 009	19	9	2026-06-02	2026-07-15	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/009/2026	187/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
151	ZK 006 26 06 14 010	19	10	2026-06-14	2026-07-09	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/010/2026	188/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
152	ZK 006 26 07 02 011	19	11	2026-07-02	2026-07-30	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/011/2026	235/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
153	ZK 006 26 07 05 012	19	12	2026-07-05	2026-07-31	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/012/2026	233/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
154	ZK 006 26 07 22 013	19	13	2026-07-22	2026-08-18	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/013/2026	246/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
155	ZK 006 26 07 22 014	19	14	2026-07-22	2026-08-21	e-mail	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/014/2026	243/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
156	ZK 006 26 08 13 016	19	16	2026-08-13	2026-09-07	platforma B2B / EDI	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/016/2026	269/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
157	ZK 006 26 08 15 015	19	15	2026-08-15	2026-09-09	platforma B2B / EDI	\N	Krzysztof Jankowski	krzysztof.jankowski@fiberlab.pl	\N	ZK/FIBERLAB/015/2026	270/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
158	ZK 003 26 01 03 001	20	1	2026-01-03	2026-01-19	formularz zamówieniowy (strona WWW)	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/001/2026	05/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
159	ZK 003 26 06 12 002	20	2	2026-06-12	2026-06-26	telefon + potwierdzenie e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/002/2026	209/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
160	ZK 003 26 07 27 004	20	4	2026-07-27	2026-08-07	telefon + potwierdzenie e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/004/2026	261/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-27 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
161	ZK 003 26 07 29 003	20	3	2026-07-29	2026-08-05	e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/003/2026	260/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
162	ZK 003 26 08 03 005	20	5	2026-08-03	2026-08-18	platforma B2B / EDI	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/005/2026	288/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
163	ZK 003 26 08 07 006	20	6	2026-08-07	2026-08-19	platforma B2B / EDI	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/006/2026	290/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
164	ZK 003 26 09 22 009	20	9	2026-09-22	2026-10-13	e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/009/2026	356/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
165	ZK 003 26 09 24 007	20	7	2026-09-24	2026-10-01	platforma B2B / EDI	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/007/2026	347/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
166	ZK 003 26 09 24 008	20	8	2026-09-24	2026-10-05	platforma B2B / EDI	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/008/2026	351/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
167	ZK 003 26 09 24 010	20	10	2026-09-24	2026-10-09	e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@coforma.pl	\N	ZK/COFORMA/010/2026	346/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
168	ZK 008 25 12 30 001	21	1	2025-12-30	2026-01-20	e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@hictrans.pl	\N	ZK/HTR/001/2026	03/2026	ZREALIZOWANE	\N	\N	\N	\N	2025-12-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
169	ZK 008 26 04 09 002	21	2	2026-04-09	2026-04-23	e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@hictrans.pl	\N	ZK/HTR/002/2026	126/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
170	ZK 008 26 04 20 003	21	3	2026-04-20	2026-05-06	telefon + potwierdzenie e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@hictrans.pl	\N	ZK/HTR/003/2026	143/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
171	ZK 008 26 06 19 004	21	4	2026-06-19	2026-07-13	e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@hictrans.pl	\N	ZK/HTR/004/2026	232/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
172	ZK 008 26 07 09 005	21	5	2026-07-09	2026-08-03	e-mail	\N	Ewa Wiśniewski	ewa.wisniewski@hictrans.pl	\N	ZK/HTR/005/2026	234/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
173	ZK 008 26 07 28 006	21	6	2026-07-28	2026-08-12	platforma B2B / EDI	\N	Ewa Wiśniewski	ewa.wisniewski@hictrans.pl	\N	ZK/HTR/006/2026	267/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
174	ZK 008 26 09 26 007	21	7	2026-09-26	2026-10-13	platforma B2B / EDI	\N	Ewa Wiśniewski	ewa.wisniewski@hictrans.pl	\N	ZK/HTR/007/2026	357/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
175	ZK 011 25 12 31 001	22	1	2025-12-31	2026-01-20	e-mail	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/001/2026	325/2025	ZREALIZOWANE	\N	\N	\N	\N	2025-12-31 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
176	ZK 011 26 02 13 002	22	2	2026-02-13	2026-03-10	e-mail	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/002/2026	46/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
177	ZK 011 26 03 15 003	22	3	2026-03-15	2026-04-07	e-mail	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/003/2026	78/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
178	ZK 011 26 03 30 004	22	4	2026-03-30	2026-04-16	e-mail	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/004/2026	88/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
179	ZK 011 26 05 08 005	22	5	2026-05-08	2026-05-27	platforma B2B / EDI	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/005/2026	150/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
180	ZK 011 26 05 15 006	22	6	2026-05-15	2026-08-03	platforma B2B / EDI	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/006/2026	251/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
181	ZK 011 26 07 22 008	22	8	2026-07-22	2026-08-25	formularz zamówieniowy (strona WWW)	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/008/2026	259/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
182	ZK 011 26 07 24 007	22	7	2026-07-24	2026-08-10	e-mail	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/007/2026	258/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
183	ZK 011 26 09 02 009	22	9	2026-09-02	2026-09-30	platforma B2B / EDI	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/009/2026	326/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
184	ZK 011 26 09 18 010	22	10	2026-09-18	2026-10-12	platforma B2B / EDI	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/010/2026	328/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
185	ZK 011 26 09 24 011	22	11	2026-09-24	\N	formularz zamówieniowy (strona WWW)	\N	Magdalena Piotrowski	magdalena.piotrowski@km.pl	\N	ZK/KM/011/2026	329/2026	W PRODUKCJI	\N	\N	\N	\N	2026-09-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
186	ZK 014 25 12 31 001	23	1	2025-12-31	2026-01-21	platforma B2B / EDI	\N	Dariusz Wójcik	dariusz.wojcik@marbo.pl	\N	ZK/MARBO/001/2026	1/2026	ZREALIZOWANE	\N	\N	\N	\N	2025-12-31 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
187	ZK 014 26 02 06 002	23	2	2026-02-06	2026-02-26	telefon + potwierdzenie e-mail	\N	Dariusz Wójcik	dariusz.wojcik@marbo.pl	\N	ZK/MARBO/002/2026	37/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
188	ZK 024 24 12 30 001	24	1	2024-12-30	2026-01-14	e-mail	\N	Barbara Zieliński	barbara.zielinski@topbridge.pl	\N	ZK/TOPBRIDG/001/2026		ZREALIZOWANE	\N	\N	\N	\N	2024-12-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
189	ZK 024 26 07 01 002	24	2	2026-07-01	2026-07-27	formularz zamówieniowy (strona WWW)	\N	Barbara Zieliński	barbara.zielinski@topbridge.pl	\N	ZK/TOPBRIDG/002/2026	230/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
190	ZK 013 24 12 30 001	25	1	2024-12-30	2026-01-28	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/001/2026	02/2026	ZREALIZOWANE	\N	\N	\N	\N	2024-12-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
191	ZK 013 26 05 09 002	25	2	2026-05-09	2026-05-27	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/002/2026	173/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
192	ZK 013 26 05 16 003	25	3	2026-05-16	2026-06-01	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/003/2026	174/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
193	ZK 013 26 05 21 004	25	4	2026-05-21	2026-06-15	telefon + potwierdzenie e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/004/2026	175/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
194	ZK 013 26 06 05 005	25	5	2026-06-05	2026-06-17	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/005/2026	176/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
195	ZK 013 26 06 09 006	25	6	2026-06-09	2026-07-02	telefon + potwierdzenie e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/006/2026	199/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
196	ZK 013 26 06 23 007	25	7	2026-06-23	2026-07-13	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/007/2026	194/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
197	ZK 013 26 06 23 008	25	8	2026-06-23	2026-07-06	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/008/2026	200/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
198	ZK 013 26 07 02 009	25	9	2026-07-02	2026-07-13	formularz zamówieniowy (strona WWW)	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/009/2026	224/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
199	ZK 013 26 07 06 010	25	10	2026-07-06	2026-07-14	formularz zamówieniowy (strona WWW)	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/010/2026	223/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
200	ZK 013 26 07 06 013	25	13	2026-07-06	2026-07-23	telefon + potwierdzenie e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/013/2026	228/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
201	ZK 013 26 07 07 011	25	11	2026-07-07	2026-07-16	telefon + potwierdzenie e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/011/2026	226/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
202	ZK 013 26 07 08 012	25	12	2026-07-08	2026-07-17	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/012/2026	227/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
203	ZK 013 26 07 16 014	25	14	2026-07-16	2026-07-24	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/014/2026	229/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
204	ZK 013 26 09 04 015	25	15	2026-09-04	2026-09-17	telefon + potwierdzenie e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/015/2026	317/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-04 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
205	ZK 013 26 09 04 016	25	16	2026-09-04	2026-09-23	telefon + potwierdzenie e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/016/2026	319/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-04 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
206	ZK 013 26 09 13 017	25	17	2026-09-13	2026-09-29	telefon + potwierdzenie e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/017/2026	318/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
207	ZK 013 26 09 21 018	25	18	2026-09-21	2026-10-05	formularz zamówieniowy (strona WWW)	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/018/2026	320/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
208	ZK 013 26 09 25 019	25	19	2026-09-25	2026-10-09	e-mail	\N	Tomasz Nowak	tomasz.nowak@liderpool.pl	\N	ZK/LIDERPOO/019/2026	321/2026	W PRODUKCJI	\N	\N	\N	\N	2026-09-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
209	ZK 000 25 01 06 001	1	1	2025-01-06	2026-01-19	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/001/2026	08/2026	ZREALIZOWANE	\N	\N	\N	\N	2025-01-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
210	ZK 000 26 01 04 002	1	2	2026-01-04	2026-01-21	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/002/2026	07/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-04 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
211	ZK 000 26 01 08 003	1	3	2026-01-08	2026-01-22	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/003/2026	14/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
212	ZK 000 26 01 09 006	1	6	2026-01-09	2026-01-29	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/006/2026	18/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
213	ZK 000 26 01 12 005	1	5	2026-01-12	2026-01-26	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/005/2026	16/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
214	ZK 000 26 01 14 007	1	7	2026-01-14	2026-02-03	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/007/2026	17/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
215	ZK 000 26 01 16 004	1	4	2026-01-16	2026-01-26	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/004/2026	15/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
216	ZK 000 26 01 17 008	1	8	2026-01-17	2026-02-04	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/008/2026	21/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
217	ZK 000 26 01 23 009	1	9	2026-01-23	2026-02-05	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/009/2026	26/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
218	ZK 000 26 01 26 010	1	10	2026-01-26	2026-02-10	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/010/2026	04/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
219	ZK 000 26 01 27 012	1	12	2026-01-27	2026-02-16	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/012/2026	28/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-27 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
220	ZK 000 26 01 28 015	1	15	2026-01-28	2026-02-12	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/015/2026	40/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
221	ZK 000 26 01 29 013	1	13	2026-01-29	2026-02-18	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/013/2026	39/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
222	ZK 000 26 01 30 011	1	11	2026-01-30	2026-02-10	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/011/2026	29/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
223	ZK 000 26 01 31 014	1	14	2026-01-31	2026-02-13	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/014/2026	36/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-01-31 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
224	ZK 000 26 02 02 016	1	16	2026-02-02	2026-02-23	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/016/2026	38/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
225	ZK 000 26 02 07 017	1	17	2026-02-07	2026-02-18	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/017/2026	42/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
226	ZK 000 26 02 08 018	1	18	2026-02-08	2026-02-19	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/018/2026	41/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
227	ZK 000 26 02 16 023	1	23	2026-02-16	2026-03-09	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/023/2026	53/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
228	ZK 000 26 02 17 019	1	19	2026-02-17	2026-02-27	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/019/2026	51/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
229	ZK 000 26 02 18 022	1	22	2026-02-18	2026-03-05	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/022/2026	49/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
230	ZK 000 26 02 20 020	1	20	2026-02-20	2026-02-27	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/020/2026	54/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
231	ZK 000 26 02 22 021	1	21	2026-02-22	2026-03-04	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/021/2026	52/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
232	ZK 000 26 02 24 027	1	27	2026-02-24	2026-03-13	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/027/2026	66/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
233	ZK 000 26 02 25 024	1	24	2026-02-25	2026-03-04	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/024/2026	58/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
234	ZK 000 26 02 26 025	1	25	2026-02-26	2026-03-13	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/025/2026	61/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
235	ZK 000 26 02 28 026	1	26	2026-02-28	2026-03-11	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/026/2026	57/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-02-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
236	ZK 000 26 02 28 030	1	30	2026-02-28	2026-03-20	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/030/2026	62/2026	W PRODUKCJI	\N	\N	\N	\N	2026-02-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
237	ZK 000 26 03 02 028	1	28	2026-03-02	2026-03-18	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/028/2026	67/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
238	ZK 000 26 03 06 029	1	29	2026-03-06	2026-03-18	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/029/2026	70/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
239	ZK 000 26 03 06 035	1	35	2026-03-06	2026-04-01	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/035/2026	76/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
240	ZK 000 26 03 07 032	1	32	2026-03-07	2026-06-23	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/032/2026	71/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
241	ZK 000 26 03 10 033	1	33	2026-03-10	2026-03-18	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/033/2026	72/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
242	ZK 000 26 03 10 034	1	34	2026-03-10	2026-03-26	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/034/2026	74/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
243	ZK 000 26 03 11 031	1	31	2026-03-11	2026-03-27	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/031/2026	73/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
244	ZK 000 26 03 13 037	1	37	2026-03-13	2026-03-30	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/037/2026	85/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
245	ZK 000 26 03 13 041	1	41	2026-03-13	2026-03-18	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/041/2026	84/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
246	ZK 000 26 03 17 036	1	36	2026-03-17	2026-03-30	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/036/2026	75/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
247	ZK 000 26 03 17 042	1	42	2026-03-17	2026-04-08	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/042/2026	63/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
248	ZK 000 26 03 17 043	1	43	2026-03-17	2026-04-02	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/043/2026	94/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-17 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
249	ZK 000 26 03 18 038	1	38	2026-03-18	2026-04-01	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/038/2026	90/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
250	ZK 000 26 03 20 046	1	46	2026-03-20	2026-04-08	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/046/2026	96/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
251	ZK 000 26 03 20 052	1	52	2026-03-20	2026-04-10	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/052/2026	82/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
252	ZK 000 26 03 22 039	1	39	2026-03-22	2026-04-03	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/039/2026	91/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
253	ZK 000 26 03 22 047	1	47	2026-03-22	2026-04-03	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/047/2026	104/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
254	ZK 000 26 03 24 044	1	44	2026-03-24	2026-04-03	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/044/2026	77/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
255	ZK 000 26 03 25 040	1	40	2026-03-25	2026-04-02	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/040/2026	86/2026	W PRODUKCJI	\N	\N	\N	\N	2026-03-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
256	ZK 000 26 03 25 048	1	48	2026-03-25	2026-04-08	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/048/2026	105/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
257	ZK 000 26 03 26 049	1	49	2026-03-26	2026-04-07	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/049/2026	89/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
258	ZK 000 26 03 26 050	1	50	2026-03-26	2026-04-07	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/050/2026	103/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
259	ZK 000 26 03 27 045	1	45	2026-03-27	2026-04-03	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/045/2026	95/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-27 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
260	ZK 000 26 03 27 051	1	51	2026-03-27	2026-04-08	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/051/2026	98/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-27 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
261	ZK 000 26 03 30 054	1	54	2026-03-30	2026-04-13	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/054/2026	99/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-03-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
262	ZK 000 26 04 01 057	1	57	2026-04-01	2026-04-17	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/057/2026	112/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-01 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
263	ZK 000 26 04 03 053	1	53	2026-04-03	2026-04-13	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/053/2026	97/2025	ZREALIZOWANE	\N	\N	\N	\N	2026-04-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
264	ZK 000 26 04 03 058	1	58	2026-04-03	2026-04-20	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/058/2026	128/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
265	ZK 000 26 04 06 055	1	55	2026-04-06	2026-04-17	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/055/2026	106/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
266	ZK 000 26 04 07 056	1	56	2026-04-07	2026-04-16	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/056/2026	83/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
267	ZK 000 26 04 07 062	1	62	2026-04-07	2026-04-19	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/062/2026	138/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
268	ZK 000 26 04 08 059	1	59	2026-04-08	2026-04-20	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/059/2026	114/82026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
269	ZK 000 26 04 08 060	1	60	2026-04-08	2026-04-21	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/060/2026	114/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
270	ZK 000 26 04 10 061	1	61	2026-04-10	2026-04-17	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/061/2026	130/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
271	ZK 000 26 04 11 063	1	63	2026-04-11	2026-04-27	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/063/2026	113/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
272	ZK 000 26 04 11 064	1	64	2026-04-11	2026-04-22	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/064/2026	131/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
273	ZK 000 26 04 13 065	1	65	2026-04-13	2026-04-27	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/065/2026	127/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
274	ZK 000 26 04 19 067	1	67	2026-04-19	2026-04-29	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/067/2026	135/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
275	ZK 000 26 04 23 066	1	66	2026-04-23	2026-04-28	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/066/2026	156/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
276	ZK 000 26 04 23 068	1	68	2026-04-23	2026-05-04	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/068/2026	154/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
277	ZK 000 26 04 24 069	1	69	2026-04-24	2026-05-05	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/069/2026	155/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
278	ZK 000 26 04 29 070	1	70	2026-04-29	2026-05-13	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/070/2026	136/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-04-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
279	ZK 000 26 04 29 073	1	73	2026-04-29	2026-05-18	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/073/2026	132/2025	ZREALIZOWANE	\N	\N	\N	\N	2026-04-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
280	ZK 000 26 05 02 071	1	71	2026-05-02	2026-05-12	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/071/2026	115/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
281	ZK 000 26 05 03 072	1	72	2026-05-03	2026-05-12	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/072/2026	133/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
282	ZK 000 26 05 06 074	1	74	2026-05-06	2026-05-18	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/074/2026	137/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
283	ZK 000 26 05 07 075	1	75	2026-05-07	2026-05-20	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/075/2026	161/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
284	ZK 000 26 05 07 076	1	76	2026-05-07	2026-05-27	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/076/2026	134/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
285	ZK 000 26 05 13 077	1	77	2026-05-13	2026-05-19	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/077/2026	165/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
286	ZK 000 26 05 15 078	1	78	2026-05-15	2026-05-22	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/078/2026	166/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
287	ZK 000 26 05 15 081	1	81	2026-05-15	2026-05-29	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/081/2026	186/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
288	ZK 000 26 05 18 079	1	79	2026-05-18	2026-05-28	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/079/2026	167/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
289	ZK 000 26 05 18 082	1	82	2026-05-18	2026-06-02	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/082/2026	168/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
290	ZK 000 26 05 20 085	1	85	2026-05-20	2026-06-09	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/085/2026	169/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
291	ZK 000 26 05 21 080	1	80	2026-05-21	2026-05-29	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/080/2026	179/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
292	ZK 000 26 05 23 083	1	83	2026-05-23	2026-06-02	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/083/2026	183/26	ZREALIZOWANE	\N	\N	\N	\N	2026-05-23 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
293	ZK 000 26 05 26 084	1	84	2026-05-26	2026-06-03	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/084/2026	183/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
294	ZK 000 26 06 04 086	1	86	2026-06-04	2026-06-16	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/086/2026	201/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-04 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
295	ZK 000 26 06 05 087	1	87	2026-06-05	2026-06-23	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/087/2026	205/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
296	ZK 000 26 06 16 088	1	88	2026-06-16	2026-06-25	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/088/2026	202/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
297	ZK 000 26 06 20 089	1	89	2026-06-20	2026-07-07	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/089/2026	217/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-20 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
298	ZK 000 26 06 30 091	1	91	2026-06-30	2026-07-10	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/091/2026	210/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-06-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
299	ZK 000 26 07 02 090	1	90	2026-07-02	2026-07-08	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/090/2026	211/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
300	ZK 000 26 07 03 095	1	95	2026-07-03	2026-07-17	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/095/2026	250/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
301	ZK 000 26 07 04 097	1	97	2026-07-04	2026-07-20	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/097/2026	249/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-04 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
302	ZK 000 26 07 05 092	1	92	2026-07-05	2026-07-15	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/092/2026	212/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
303	ZK 000 26 07 07 093	1	93	2026-07-07	2026-07-14	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/093/2026	241/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-07 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
304	ZK 000 26 07 09 094	1	94	2026-07-09	2026-07-17	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/094/2026	248/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
305	ZK 000 26 07 09 098	1	98	2026-07-09	2026-07-24	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/098/2026	214/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
306	ZK 000 26 07 11 096	1	96	2026-07-11	2026-07-20	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/096/2026	213/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
307	ZK 000 26 07 14 101	1	101	2026-07-14	2026-08-03	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/101/2026	255/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
308	ZK 000 26 07 16 102	1	102	2026-07-16	2026-08-03	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/102/2026	256/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
309	ZK 000 26 07 18 100	1	100	2026-07-18	2026-07-29	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/100/2026	253/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
310	ZK 000 26 07 19 099	1	99	2026-07-19	2026-07-24	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/099/2026	254/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
311	ZK 000 26 07 22 103	1	103	2026-07-22	2026-08-05	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/103/2026	257/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
312	ZK 000 26 07 29 104	1	104	2026-07-29	2026-08-10	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/104/2026	262/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-29 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
313	ZK 000 26 07 30 105	1	105	2026-07-30	2026-08-11	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/105/2026	204/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
314	ZK 000 26 07 30 108	1	108	2026-07-30	\N	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/108/2026	264/2026	W PRODUKCJI	\N	\N	\N	\N	2026-07-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
315	ZK 000 26 08 02 106	1	106	2026-08-02	2026-08-18	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/106/2026	263/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
316	ZK 000 26 08 05 107	1	107	2026-08-05	2026-08-18	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/107/2026	263/2025	ZREALIZOWANE	\N	\N	\N	\N	2026-08-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
317	ZK 000 26 08 06 110	1	110	2026-08-06	2026-08-25	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/110/2026	281/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
318	ZK 000 26 08 08 109	1	109	2026-08-08	2026-08-17	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/109/2026	273/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
319	ZK 000 26 08 12 114	1	114	2026-08-12	2026-09-02	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/114/2026	287/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
320	ZK 000 26 08 13 111	1	111	2026-08-13	2026-08-20	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/111/2026	274/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
321	ZK 000 26 08 13 112	1	112	2026-08-13	2026-08-26	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/112/2026	282/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-13 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
322	ZK 000 26 08 16 113	1	113	2026-08-16	2026-08-27	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/113/2026	289/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-16 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
323	ZK 000 26 08 21 115	1	115	2026-08-21	2026-09-02	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/115/2026	293/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
324	ZK 000 26 08 21 116	1	116	2026-08-21	2026-09-09	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/116/2026	239/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
325	ZK 000 26 08 21 117	1	117	2026-08-21	2026-09-03	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/117/2026	294/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-21 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
326	ZK 000 26 08 26 120	1	120	2026-08-26	2026-09-14	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/120/2026	311/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-26 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
327	ZK 000 26 08 27 119	1	119	2026-08-27	2026-09-10	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/119/2026	303/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-27 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
328	ZK 000 26 08 28 118	1	118	2026-08-28	2026-09-08	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/118/2026	295/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
329	ZK 000 26 08 28 121	1	121	2026-08-28	2026-09-16	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/121/2026	322/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
330	ZK 000 26 08 28 122	1	122	2026-08-28	2026-09-23	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/122/2026	296/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
331	ZK 000 26 08 28 123	1	123	2026-08-28	2026-09-15	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/123/2026	304/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-28 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
332	ZK 000 26 09 02 125	1	125	2026-09-02	2026-09-15	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/125/2026	312/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-02 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
333	ZK 000 26 09 04 131	1	131	2026-09-04	2026-09-24	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/131/2026	330/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-04 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
334	ZK 000 26 09 05 124	1	124	2026-09-05	2026-09-16	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/124/2026	300/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
335	ZK 000 26 09 05 128	1	128	2026-09-05	2026-09-25	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/128/2026	307/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-05 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
336	ZK 000 26 09 06 126	1	126	2026-09-06	2026-09-22	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/126/2026	316/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
337	ZK 000 26 09 06 129	1	129	2026-09-06	2026-09-22	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/129/2026	299/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
338	ZK 000 26 09 09 127	1	127	2026-09-09	2026-09-16	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/127/2026	305/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-09 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
339	ZK 000 26 09 10 130	1	130	2026-09-10	2026-09-23	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/130/2026	306/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-10 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
340	ZK 000 26 09 11 135	1	135	2026-09-11	2026-09-29	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/135/2026	331/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-11 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
341	ZK 000 26 09 14 133	1	133	2026-09-14	2026-09-25	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/133/2026	302/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-14 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
342	ZK 000 26 09 15 132	1	132	2026-09-15	2026-09-25	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/132/2026	325/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-15 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
343	ZK 000 26 09 18 134	1	134	2026-09-18	2026-10-01	platforma B2B / EDI	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/134/2026	336/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-18 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
344	ZK 000 26 09 22 137	1	137	2026-09-22	2026-10-06	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/137/2026	344/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-22 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
345	ZK 000 26 09 24 138	1	138	2026-09-24	2026-10-12	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/138/2026	345/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-24 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
346	ZK 000 26 09 25 136	1	136	2026-09-25	2026-10-06	formularz zamówieniowy (strona WWW)	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/136/2026	343/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-09-25 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
347	ZK 000 26 10 03 139	1	139	2026-10-03	2026-10-12	e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/139/2026	349/2026	W PRODUKCJI	\N	\N	\N	\N	2026-10-03 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
348	ZK 000 26 10 08 140	1	140	2026-10-08	\N	telefon + potwierdzenie e-mail	\N	Jakub Majchrzak	sklep@fiboo.pl	\N	ZK/FIBOO/140/2026	361/2026	W PRODUKCJI	\N	\N	\N	\N	2026-10-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
349	ZK 018 26 05 08 001	26	1	2026-05-08	2026-06-16	telefon + potwierdzenie e-mail	\N	Piotr Grabowski	piotr.grabowski@palisander.pl	\N	ZK/PALISAND/001/2026	180/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-08 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
350	ZK 018 26 05 12 002	26	2	2026-05-12	2026-06-26	e-mail	\N	Piotr Grabowski	piotr.grabowski@palisander.pl	\N	ZK/PALISAND/002/2026	158/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-05-12 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
351	ZK 018 26 07 30 003	26	3	2026-07-30	2026-09-14	formularz zamówieniowy (strona WWW)	\N	Piotr Grabowski	piotr.grabowski@palisander.pl	\N	ZK/PALISAND/003/2026	271/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-07-30 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
352	ZK 018 26 08 06 004	26	4	2026-08-06	2026-09-11	formularz zamówieniowy (strona WWW)	\N	Piotr Grabowski	piotr.grabowski@palisander.pl	\N	ZK/PALISAND/004/2026	266/2026	ZREALIZOWANE	\N	\N	\N	\N	2026-08-06 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
353	ZK 018 26 08 19 005	26	5	2026-08-19	2026-09-02	formularz zamówieniowy (strona WWW)	\N	Piotr Grabowski	piotr.grabowski@palisander.pl	\N	ZK/PALISAND/005/2026	266/2025	ZREALIZOWANE	\N	\N	\N	\N	2026-08-19 00:00:00+00	\N	\N	2026-10-16 06:19:15.934581+00
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.products (id, code, client_id, name, material_text, colorant_text, material_id, colorant_id, colorant_pct, color_id, mold_id, mold_match, pattern_no, net_g, gross_g, cavities, cycle_s, per_shift, pcs_per_carton, carton_type, carton_kg, machines, orders_count, produced_total, first_production, last_production, notes, created_at, updated_at) FROM stdin;
2	505	3	KORPUS	PA6+30GF PLASTAMID 6B28 G6 BK		2	\N	\N	1	\N	\N	26/10-A	35.800	45.400	2	53.90	1068	400	P2	15.00	3	1	12600	2026-09-25	2026-10-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
5	399	4	BOTTOM LIME	ABS MAGNUM 8391	GM-41815V	59	130	4.00	13	64	AUTO	26/08-B	7.300	7.850	4	21.34	5398	1000	KM	8.30	6	1	11000	2026-08-18	2026-08-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
6	400	4	BOTTOOM CLOUD	ABS CLOUD ARGUS		\N	\N	\N	1	\N	\N	26/08-A	7.500	8.125	4	21.34	5398	1000	KM	8.50	6	1	1000	2026-08-17	2026-08-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
7	401	4	MID CLOUD	ABS CLOUD ARGUS		\N	\N	\N	1	63	AUTO	26/08-A	17.200	17.200	4	26.70	4314	700	KM	12.70	6	1	3400	2026-08-21	2026-08-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
8	402	4	MID LIME	ABS MAGNUM 8391	GM-41815V	59	130	4.00	13	63	AUTO	26/08-B	16.400	16.375	4	26.21	4395	700	KM	12.70	6	1	11000	2026-08-21	2026-08-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
9	403	4	TOP CLOUD	ABS CLOUD ARGUS		\N	\N	\N	1	62	AUTO	26/08-A	9.400	9.400	4	18.90	6095	1000	KM	10.20	6	1	3100	2026-08-20	2026-08-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
10	404	4	TOP LIME	ABS MAGNUM 8391	GM-41815V	59	130	4.00	13	62	AUTO	26/08-B	8.900	8.900	4	18.90	6095	1000	KM	10.20	6	1	11000	2026-08-19	2026-08-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
11	530	5	CABLE LOCK CZERWONY	PA6 PLASTAMID B28 CR NR	HP 400331/40	5	92	2.00	8	\N	\N	26/05-B	40.400	40.650	2	52.50	548	400	P2	16.75	4	1	17500	2026-05-26	2026-06-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
12	531	5	CABLE LOCK ZIELONY	PA6 PLASTAMID B28 CR NR	W7-259L	5	143	2.00	22	\N	\N	26/05-A	40.400	40.650	2	52.50	548	400	P2	16.75	4	1	12500	2026-05-07	2026-05-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
14	341	6	FRONT REGULATORA	RESINEX ABS HF380 WHITE; ABS HF380 WHITE RESINEX		30	\N	\N	1	33	AUTO	26/05-A; 26/07-A	17.100	38.500	1	35.55	810	250	P2	5.25	6	2	10000	2026-05-13	2026-07-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
15	342	6	FRONT TRANSMITERA	RESINEX ABS HF380 WHITE; ABS HF380 WHITE RESINEX		30	\N	\N	1	33	AUTO	26/05-A; 26/07-A	19.700	38.500	1	35.55	810	180	P2	4.45	6	2	9680	2026-05-13	2026-07-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
16	343	6	KLAWISZ DUŻY OKRĄGŁY	ABS HF380 WHITE RESINEX		30	\N	\N	1	\N	\N	26/07-A	2.800	4.450	2	25.86	2230	1700	P5	5.05	6	1	13200	2026-07-15	2026-07-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
17	344	6	KLAWISZ MAŁY OKRĄGŁY	ABS HF380 WHITE RESINEX		30	\N	\N	1	\N	\N	26/07-A	1.000	4.450	2	25.86	2230	8000	P2	8.25	6	1	12000	2026-07-15	2026-07-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
18	345	6	KORPUS REGULATORA	ABS HF380 WHITE RESINEX		30	\N	\N	1	31	AUTO	26/05-B; 26/07-B	24.500	58.100	1	44.31	650	150	P2	4.60	6	2	9700	2026-05-06	2026-07-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
19	346	6	KORPUS TRANSMITERA	ABS HF380 WHITE RESINEX		30	\N	\N	1	31	AUTO	26/05-B; 26/07-B	27.700	58.100	1	44.31	650	100	P2	3.50	6	2	10030	2026-05-06	2026-07-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
22	349	6	PRZEŁACZNIK	RESINEX-ABS HI121H NATURAL; ABS HI121H-NATURAL RESINEX	W9-36	29	\N	2.00	\N	\N	\N	26/04-A; 26/08-A	0.500	4.150	2	34.35	1676	4000	WOREK STRUNOWY	2.00	6	2	18000	2026-04-27	2026-08-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
23	350	6	PUDEŁKO	RESINEX-ABS HI121H NATURAL; ABS HI121H-NATURAL RESINEX	W9-36	29	\N	2.00	\N	\N	\N	26/04-A; 26/08-A	2.200	4.150	2	34.35	1676	2000	P2	5.00	6	2	19000	2026-04-27	2026-08-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
24	351	6	SWITCH	RESINEX-ABS HI121H NATURAL; ABS HI121H-NATURAL RESINEX	W9-36	29	\N	2.00	\N	\N	\N	26/04-A; 26/08-A	0.300	4.150	2	34.35	1676	8000	WOREK STRUNOWY	2.40	6	2	19000	2026-04-27	2026-08-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
25	501	7	CROSSWATER-DO ODPŁYWU	ABS HF380 WHITE		30	\N	\N	1	138	AUTO	26/10-A	8.500	9.500	1	16.30	1760	600	P2	5.80	3	1	5100	2026-10-07	2026-10-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
26	502	7	ZP190903A0-0stopni	PP COPO REGLANULAT; PP COPO BIAŁY		\N	\N	\N	1	95	AUTO	26/08-A; 26/10-A	6.600	7.475	4	14.47	7960	600	P2	4.60	4, 6	2	40000	2026-08-05	2026-08-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
27	503	7	ZP190903A2-2stopni	PP COPO REGLANULAT		\N	\N	\N	1	96	AUTO	26/04-A	6.500	7.850	2	13.50	4266	600	P2	4.60	5	1	20000	2026-04-22	2026-04-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
28	504	7	ZP190903A3_50-3,5 STOPNI	PP COPO BIAŁY		\N	\N	\N	1	95	AUTO	26/10-A	6.800	8.150	2	19.20	3000	600	P2	4.70	4	1	12000	2026-10-06	2026-10-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
29	545	8	KOREK PVC SELECT T KOR-180	1-PVC-PVC-ST/P81CZ-0		69	\N	\N	1	\N	\N	26/04-A	5.700	6.900	2	25.04	2300	1000	P5	6.25	5	1	20000	2026-04-07	2026-04-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
69	431	12	OBWÓDKA TABLICY SAMOCHODOWEJ 380x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-D	39.000	39.000	1	35.80	820	120	P1	\N	7	1	1089	2026-10-01	2026-10-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
32	353	9	46LPA6	TEREZ B 305 NATURAL	HP99611	23	95	1.00	7	\N	\N	26/02-A	1.300	1.491	32	21.80	1321	\N	KM	30.00	2	1	300000	2026-02-20	2026-02-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
39	405	10	KONDENSAT	rABS CZARNY PROGRESS		\N	\N	\N	1	67	AUTO	26/06-B	286.700	287.800	1	45.60	630	120	80/118/77	\N	7	1	5040	2026-06-22	2026-06-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
40	406	10	PODSTAWA UP	rABS CZARNY PROGRESS		\N	\N	\N	1	69	AUTO	26/07-A	112.000	117.200	1	27.20	1058	40	KM	5.50	7	1	2000	2026-06-03	2026-07-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
41	407	10	POKRYWA	rABS CZARNY PROGRESS		\N	\N	\N	1	66	AUTO	26/06-C	222.500	222.500	1	41.40	695	192	80/118/77	\N	7	1	5040	2026-06-29	2026-07-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
42	408	10	REDUKCJA PIRAMIDA	PP COPO PROGRESS; rPP CZARNY PROGRESS		41	\N	\N	1	68	AUTO	26/02-A; 26/04-A; 26/08-A	172.600	172.600	1	45.90	627	512	80/118/77	\N	1, 2	4	23552	2026-02-10	2026-08-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
43	409	10	REDUKCJA TYP C	rPP CZARNY PROGRESS		41	\N	\N	1	94	AUTO	26/05-A	99.000	104.400	1	33.30	864	264	80/118/77	\N	8	1	4224	2026-05-04	2026-05-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
44	410	10	REDUKCJA TYP IVT	rPP CZARNY PROGRESS		41	\N	\N	1	94	AUTO	26/05-A	142.600	147.800	1	33.20	867	264	80/118/77	\N	8	1	3168	2026-05-06	2026-05-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
45	411	10	WKŁAD	rABS CZARNY PROGRESS		\N	\N	\N	1	71	AUTO	26/06-A	238.500	0.000	1	41.00	702	140	80/118/77	\N	7	1	5040	2026-06-16	2026-06-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
50	538	11	095003-8 V2 8x8 mm L	PA6+30GF PLASTAMID 6B28 BK		\N	\N	\N	1	\N	\N	26/03-A	9.700	10.000	2	32.08	897	1300	P2	13.10	6	1	5000	2026-03-10	2026-03-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
52	540	11	095013-8 V2 8x8 mm R	PA6+30GF PLASTAMID 6B28 BK		\N	\N	\N	1	\N	\N	26/03-A	9.700	10.000	2	32.08	897	1300	P2	13.10	6	1	5000	2026-03-10	2026-03-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
53	541	11	095100-9 V3 9x9U	PA6+30%GF PLASTAMID 6B28 G6		2	\N	\N	1	\N	\N	26/04-A	7.100	7.700	2	30.90	932	2200	P2	15.10	4	1	5000	2026-04-21	2026-04-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
54	542	11	095113-9 V3 9x9 R	PA6+30%GF PLASTAMID 6B28 G6		2	\N	\N	1	\N	\N	26/04-A	8.400	7.700	2	30.90	932	1600	P2	13.20	4	1	5000	2026-04-21	2026-04-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
57	419	12	KLUCZYK S1	PRZEMIAŁ POM C27N		32	\N	\N	1	77	AUTO	26/04-A	2.300	2.557	7	17.29	11660	9500	P2	24.00	6	1	63000	2026-04-10	2026-04-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
58	420	12	LISTWA SZERROKA	rABS CZARNY PROGRESS		\N	\N	\N	1	217	AUTO	26/03-A	52.500	54.500	2	38.20	753	550	KM	29.90	7	1	1500	2026-03-25	2026-03-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
59	421	12	LISTWA WĄSKA	rABS CZARNY PROGRESS		\N	\N	\N	1	217	AUTO	26/03-A	23.200	25.250	2	37.20	768	1500	KM	385.80	7	1	1500	2026-03-26	2026-03-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
60	422	12	OBOWÓDKA TABLICY SAMOCHODOWEJ 400 x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-C	40.600	40.600	1	37.30	772	114	P1	\N	7	1	1512	2026-09-30	2026-10-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
61	423	12	OBWÓDKA DO TABLICY 520 BIAŁA	HI 121H RESINEX	GM 447	29	105	2.00	3	92	AUTO	26/07-A	44.100	47.700	1	30.70	938	114	P1	2.55	2	1	2052	2026-07-01	2026-07-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
62	424	12	OBWÓDKA DO TABLICY 520 CZARNY	rABS CZARNY PROGRESS		\N	\N	\N	7	92	AUTO	26/06-A	43.600	46.800	1	30.70	938	114	P1	2.55	2	1	10602	2026-06-23	2026-07-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
63	425	12	OBWÓDKA DO TABLICY 520x110 BIAŁA	ABS HI 121H RESINEX	GM-447	29	105	2.00	3	92	AUTO	26/04-B	43.400	34.400	1	31.00	116	114	P1	5.85	2	1	759	2026-04-27	2026-04-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
64	426	12	OBWÓDKA DO TABLICY 520x110 CZARNA	REGLANULAT ABS PROGRESS CZARNY		\N	\N	\N	7	92	AUTO	26/04-A	42.900	46.100	1	31.10	920	114	P1	5.85	2	1	6500	2026-04-22	2026-04-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
65	427	12	OBWÓDKA RAMKI MOTOCYKLOWEJ 180x200 ABS	rABS CZARNY PROGRESS		\N	\N	\N	1	163	AUTO	26/04-A; 26/07-B	25.700	32.200	1	26.90	1070	70	P2	2.40	2, 5	2	12010	2026-04-24	2026-07-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
66	428	12	OBWÓDKA RAMKI MOTOCYKLOWEJ 240x130	rABS CZARNY PROGRESS		\N	\N	\N	1	163	AUTO	26/04-A	25.200	30.300	1	25.20	1152	80	P2	2.55	5	1	3040	2026-04-28	2026-04-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
67	429	12	OBWÓDKA RAMKI MOTOCYKLOWEJ 240x130 ABS	rABS CZARNY PROGRESS		\N	\N	\N	1	163	AUTO	26/07-A	25.500	25.500	1	26.92	1068	80	P2	2.60	5	1	2720	2026-07-13	2026-07-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
68	430	12	OBWÓDKA RAMKI MOTOCYKLOWEJ 255x130	rABS CZARNY PROGRESS		\N	\N	\N	1	163	AUTO	26/04-A; 26/07-A	26.000	26.000	1	26.90	1070	80	P2	2.90	5	2	8860	2026-04-29	2026-07-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
70	432	12	OBWÓDKA TABLICY SAMOCHODOWEJ 420x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-B	42.000	42.000	1	35.50	810	114	P1	\N	7	1	1600	2026-09-28	2026-09-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
71	433	12	OBWÓDKA TABLICY SAMOCHODOWEJ 460x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-A	45.300	45.300	1	44.80	642	114	P1	6.00	7	1	2508	2026-09-22	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
72	434	12	PODKŁAD ABS AT 520x120	rABS CZARNY PROGRESS		\N	\N	\N	1	176	AUTO	26/03-A	150.000	150.000	1	30.30	950	130	KM	\N	7	1	3250	\N	2026-03-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
73	435	12	PODKŁAD AT 520x120	rABS CZARNY PROGRESS		\N	\N	\N	1	216	AUTO	26/04-B	127.000	127.000	1	33.10	870	130	KM	19.50	8	1	5515	2026-04-14	2026-04-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
74	436	12	PODKŁAD AT 525x125 ABS	rABS CZARNY PROGRESS		\N	\N	\N	1	176	AUTO	26/06-A	130.400	130.400	1	33.80	852	150	KM	20.40	2	1	5200	2026-06-08	2026-06-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
75	437	12	PODKŁAD DE 460x110	REGLANULAT PC CZARNY		\N	\N	\N	1	176	AUTO	26/04-A	104.500	104.500	1	31.30	920	150	KM	17.50	8	1	5500	2026-04-10	2026-04-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
76	438	12	PODKŁAD DE 460x110 ABS	rABS CZARNY PROGRESS		\N	\N	\N	1	176	AUTO	26/06-A	106.200	106.200	1	35.50	811	150	KM	17.50	2	1	5250	2026-06-17	2026-06-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
77	439	12	PODKŁAD DE 520x110 ABS	rABS CZARNY PROGRESS		\N	\N	\N	1	176	AUTO	26/06-A	120.000	120.000	1	37.70	763	150	KM	19.05	2	1	5213	\N	2026-06-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
78	440	12	PODKŁAD POD TABLICE 520	rPP+20T EKO BASKET 90% PP+30GF RESINEX 10%		27	\N	\N	1	92	AUTO	26/07-A; 26/10-A	102.000	102.000	1	39.20	734	150	KM	16.30	2	2	23000	2026-07-03	2026-07-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
79	441	12	PODKŁAD POD TABLICE 520x110	rPP+20T EKO BASKET	PP-GF30% SCOLEFIN 53G NATURAL	27	\N	\N	\N	92	AUTO	26/04-A	96.200	96.200	1	39.60	720	150	KM	15.50	2	1	17000	2026-04-27	2026-05-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
80	442	12	PODKŁAD RAMKI MOTOCYKLOWEJ 180x200	rABS CZARNY PROGRESS		\N	\N	\N	1	162	AUTO	26/04-A; 26/07-A	100.200	100.200	1	27.60	1043	80	P2	8.50	3, 6	2	28080	2026-04-27	2026-07-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
81	443	12	PODKŁAD RAMKI MOTOCYKLOWEJ 240/130 ABS	rABS CZARNY PROGRESS		\N	\N	\N	1	165	AUTO	26/07-A	81.700	81.700	1	24.52	1168	80	P2	7.00	6	1	5810	2026-07-09	2026-07-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
82	444	12	PODKŁAD RAMKI MOTOCYKLOWEJ 240x130	rABS CZARNY PROGRESS		\N	\N	\N	1	162	AUTO	26/05-A	79.200	79.200	1	21.22	1357	90	P2	7.60	5	1	5625	2026-05-06	2026-05-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
83	445	12	PODKŁAD RAMKI MOTOCYKLOWEJ 255x130	rABS CZARNY PROGRESS		\N	\N	\N	1	162	AUTO	26/04-B	86.000	86.000	1	21.28	1353	80	P2	3.65	5	1	4320	2026-05-04	2026-05-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
84	446	12	PODKŁAD RAMKI MOTOCYKLOWEJ 255x130 ABS	rABS CZARNY PROGRESS		\N	\N	\N	1	176	AUTO	26/07-A	84.200	84.200	1	23.18	1242	80	P2	3.65	6	1	4560	2026-07-13	2026-07-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
85	447	12	PODKŁAD TABLICY SAMOCHODOWEJ 380x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-D	89.500	89.500	1	35.50	810	195	KM	\N	7	1	1000	2026-09-29	2026-09-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
86	448	12	PODKŁAD TABLICY SAMOCHODOWEJ 400x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-C	93.500	93.500	1	32.10	897	195	KM	\N	7	1	1560	2026-09-25	2026-09-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
87	449	12	PODKŁAD TABLICY SAMOCHODOWEJ 420x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-B	97.000	97.000	1	29.50	975	210	KM	21.15	7	1	1500	2026-09-21	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
88	450	12	PODKŁAD TABLICY SAMOCHODOWEJ 460x111	rABS CZARNY PROGRESS		\N	\N	\N	1	92	AUTO	26/09-A	112.000	112.000	1	32.00	900	150	KM	17.80	7	1	2550	2026-09-17	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
89	451	12	ŁAPKA AT A0071-1	REGLANULAT PC CZARNY		\N	\N	\N	1	214	AUTO	26/02-C	10.400	11.000	2	29.30	982	400	P5	4.50	5	1	3200	2026-02-06	2026-02-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
90	452	12	ŁAPKA DE 2KOMPONENTOWA PC	2-ARGUS-rPC CZARNY		\N	\N	\N	1	214	AUTO	26/03-A	5.100	5.900	2	18.37	1567	800	P5	4.35	6	1	0	2026-03-19	2026-03-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
91	453	12	ŁAPKA DE A0070-0	PC12.80 UR		13	\N	\N	1	214	AUTO	26/02-B	9.600	10.400	2	28.74	1002	400	P5	4.50	5	1	4000	2026-02-05	2026-02-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
92	454	12	ŁAPKA DE A0070-1	REGLANULAT PC CZARNY		\N	\N	\N	1	214	AUTO	26/02-A	10.500	10.150	2	28.04	1027	400	P5	4.50	5	1	5100	2026-02-02	2026-02-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
93	455	12	ŁAPKA DE OBTRYSK C.SZARY	HRC9480/230 KRAIBURG	GM-80690E	15	112	2.00	6	214	AUTO	26/06-E	6.600	8.000	2	33.70	1709	500	P5	19.05	3	1	2500	2026-06-15	2026-06-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
94	456	12	ŁAPKA DE OBTRYSK CZARNY	HRC9480/230 KRAIBURG	GM-378E	15	104	2.00	7	214	AUTO	26/06-F	6.600	8.000	2	33.70	1709	500	P5	19.05	3	1	1500	2026-06-16	2026-06-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
95	457	12	ŁAPKA DE OBTRYSK RÓŻOWY	HRC9480/230 KRAIBURG	GM-32747E	15	124	2.00	17	214	AUTO	26/03-B	6.600	8.150	2	32.25	892	500	P5	3.60	6	1	1000	2026-03-25	2026-03-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
96	458	12	ŁAPKA DE OBTRYSK ZIELONY	HRC9480/230 KRAIBURG	W7-76	15	153	2.00	22	214	AUTO	26/03-A; 26/06-D	6.600	8.000	2	33.70	1709	500	P5	19.05	3, 6	2	3500	2026-03-25	2026-06-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
97	459	12	ŁAPKA DE OBTRYSK ŻÓŁTY	HRC9480/230 KRAIBURG	W2-73/1	15	154	2.00	23	214	AUTO	26/06-C	6.600	8.000	2	33.70	1709	500	P5	19.05	3	1	3000	\N	2026-06-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
98	460	12	ŁAPKA DE OPTRYSK C.SZARY	HRC9480/230 KRAIBURG	GM-80690E	15	112	2.00	6	214	AUTO	26/03-F	6.600	8.150	2	32.25	896	500	P5	3.60	6	1	1000	2026-03-27	2026-03-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
99	461	12	ŁAPKA DE OPTRYSK CZARNY	HRC9480/230 KRAIBURG	GM-378E	15	104	2.00	7	214	AUTO	26/03-G	6.600	8.150	2	32.25	896	500	P5	3.60	6	1	1500	2026-03-30	2026-03-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
100	462	12	ŁAPKA DE OPTRYSK CZERWONY	HRC9480/230 KRAIBURG	W4-16	15	\N	2.00	8	214	AUTO	26/03-E; 26/06-A	6.600	8.150	2	33.70	1709	500	P5	6.30	3, 6	2	10000	2026-03-26	2026-06-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
102	464	12	ŁAPKA DE OPTRYSK RÓŻOWY	HRC9480/230 KRAIBURG	GM-32747E	15	124	2.00	17	214	AUTO	26/06-B	6.600	8.000	2	33.70	1709	500	P5	6.30	3	1	1500	2026-06-11	2026-06-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
103	465	12	ŁAPKA DE OPTRYSK ŻÓŁTY	HRC9480/230 KRAIBURG	W2-73/1	15	154	2.00	23	214	AUTO	26/03-C	6.600	8.150	2	32.25	896	500	P5	3.60	6	1	1000	2026-03-25	2026-03-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
104	466	12	ŁAPKA PL OBTRYSK	HRC9480/230 KRAIBURG	W4-16	15	\N	2.00	\N	214	AUTO	26/08-B	6.800	8.400	2	29.60	1945	500	P5	3.70	4	1	2450	2026-08-27	2026-08-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
105	467	12	ŁAPKA UK OBTRYSK	HRC9480/230 KRAIBURG	W4-16	15	\N	2.00	\N	214	AUTO	26/08-A	6.600	8.300	2	29.60	1945	500	P5	3.60	4	1	2870	2026-08-26	2026-08-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
106	468	12	ŁAPKI DE 2 KOMPONENTOWA	2-ARGUS-rPC CZARNY		\N	\N	\N	1	\N	\N	26/06-A	5.000	5.850	2	21.40	2691	800	P5	4.35	3	1	15000	2026-06-01	2026-06-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
107	469	12	ŁAPKI DE CZARNY	PC CZARNY REGLANULAT		\N	\N	\N	7	\N	\N	26/05-B	9.600	10.400	2	30.87	1865	400	P5	4.10	6	1	5000	2026-05-20	2026-05-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
108	470	12	ŁAPKI DE TRANSPARENT	PC 12.80 UR		13	\N	\N	19	\N	\N	26/05-A	9.600	10.450	2	31.03	1856	400	P5	4.20	6	1	5000	2026-05-18	2026-05-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
109	471	12	ŁAPKI PL 2 KOMPONENTOWE	rABS CZARNY PROGRESS		\N	\N	\N	1	\N	\N	26/08-A	5.300	6.050	2	24.40	2360	800	P5	4.50	4	1	2750	2026-08-18	2026-08-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
110	472	12	ŁAPKI UK 2 KOMPONENTOWA PC	rPC CZARNY ARGUS		\N	\N	\N	1	\N	\N	26/08-B	5.200	6.050	2	24.40	2360	800	P5	4.50	4	1	800	2026-08-19	2026-08-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
111	533	13	SZPULA ROSA	REGLANULAT PC BIAŁY EMIPAK; PC BIAŁY PLASTPRO LUPOY ER1000LN; PC BIAŁY REGLANUTAT ARGUS; rPC BIAŁY ARGUS	WEISS 20-91147F PC	\N	\N	\N	\N	145	AUTO	26/01-A; 26/02-A; 26/04-A; 26/07-A; 26/08-A	106.600	111.300	1	27.40	1048	42	ROSA	5.10	3	5	201642	2026-01-29	2026-09-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
112	364	14	PODKŁAD 460 WKŁADKA LP	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/09-A	178.000	178.000	1	36.50	790	90	P1	16.80	2	1	4320	2026-09-14	2026-09-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
113	365	14	ŁAPKI PL CZARNY	PC REGRANULAT CZARNY ARGUS; rPC CZARNE ARGUS		\N	\N	\N	7	\N	\N	26/01-A; 26/04-A; 26/09-A	9.700	10.450	2	21.40	2690	400	P5	4.30	5, 6	3	40000	2026-01-29	2026-09-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
114	366	14	ŁAPKI PL TRANSPARENTNY	PC 1280 UR TRANSPARENT		13	\N	\N	19	\N	\N	26/04-B; 26/09-A	9.700	10.500	2	21.37	2695	400	P5	4.30	6	2	8000	2026-04-09	2026-09-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
115	524	15	RAIS UCHWYT 3 OBTRYSK	TF60QD-LCN KRAIBURG	W707	\N	145	2.00	\N	\N	\N	26/02-A	17.300	17.250	2	59.37	485	1300	P1	23.50	4	1	10700	2026-02-03	2026-02-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
120	529	15	UCHWYT 4 OBTRYSK	TF60QD-LCN KRAIBURG	W707	\N	145	2.00	\N	\N	\N	26/05-A	31.500	31.500	2	43.40	1327	500	P1	16.75	4	1	5715	2026-05-04	2026-05-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
122	318	16	BRUCKE 12_7194	POLIMER PA6-GF30%-PLASTAMID 6 B28-G6		2	\N	\N	1	188	AUTO	26/05-A	34.400	34.400	1	33.26	865	450	P1	16.40	5	1	7600	2026-05-14	2026-05-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
125	321	16	ECKVERBINDER (3) 7205	PA6 BEZ WŁÓKNA PLASTAMID 6 B28 CR; PA6 BEZ WŁÓKNA PLASTAMID 6 B1N	91568F PA	5	\N	2.00	\N	139	AUTO	26/02-A; 26/03-A; 26/06-A	9.300	12.300	1	27.70	1039	1700	P1	17.50	3, 4, 5	3	36000	2026-02-16	2026-07-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
127	323	16	ECKVERBINDER 12_7205	PA6 BEZ WŁÓKNA PLASTAMID 6 B1N	LIFOCOLOR 91568F PA	\N	\N	2.00	\N	139	AUTO	26/10-A	9.900	13.000	1	\N	\N	1700	P1	17.50	5	1	0	2026-10-13	2026-10-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
128	324	16	ECKVERBINDER 7205	PA6 BEZ WŁÓKNA PLASTAMID 6 B1	LIFOCOLOR 91568F PA	12	\N	3.00	\N	139	AUTO	26/08-A	9.500	11.367	3	35.50	820	1700	P1	17.50	4	1	12000	2026-08-31	2026-09-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
129	325	16	ECKVERBINDER LINKS 7206	PA6 BEZ WŁÓKNA PLASTAMID 6 B1	LIFOCOLOR 91568F PA	12	\N	3.00	\N	139	AUTO	26/08-A	9.800	11.367	3	39.40	730	1600	P1	16.90	4	1	6000	2026-08-31	2026-09-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
130	326	16	ECKVERBINDER RECHTS 7207	PA6 BEZ WŁÓKNA PLASTAMID 6 B1	LIFOCOLOR 91568F PA	12	\N	3.00	\N	139	AUTO	26/08-A	9.800	11.367	3	39.40	730	1600	P1	16.90	4	1	6200	2026-08-31	2026-09-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
132	328	16	HALTERUNG BRUCKE SCHWARZ 73,6818,75	PA6+50GF PLASTAMID 6B1 BK NATURAL	HP99611	\N	95	2.00	7	188	AUTO	26/04-A	6.100	7.150	2	26.00	2215	4000	P1	25.50	4	1	10000	2026-04-29	2026-04-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
133	329	16	HALTERUNG BRUCKE SCHWARZ Zg-Nr 12_6818F	PLASTAMID 6B1G10BK NATURAL	HP99611	\N	95	2.00	7	188	AUTO	26/01-A	6.100	7.150	2	26.99	2134	4000	P1	25.40	6	1	6000	2026-01-22	2026-01-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
134	330	16	RESTERUNG 12_7184	POLIMER PA6-GF30%-PLASTAMID 6 B28-G6		2	\N	\N	1	190	AUTO	26/05-A	30.100	30.100	1	33.26	865	700	P1	21.90	5	1	7600	2026-05-14	2026-05-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
135	548	17	SZPULA ABS DUŻA	rABS PROGRESS		\N	\N	\N	1	87	AUTO	26/1-A; 26/03-A	217.800	222.500	1	38.70	744	30	PRZEKŁADKI	\N	1, 8	2	26800	2026-01-20	2026-03-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
136	331	18	ŁĄCZNIK DŁUGI	rPP BIAŁY PROGRESS		42	\N	\N	1	193	AUTO	26/1-A	4.000	5.475	4	33.60	3428	1500	P5	6.25	4	1	10000	2026-01-19	2026-01-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
137	332	18	ŁĄCZNIK KRÓTKI	rPP BIAŁY PROGRESS		42	\N	\N	1	193	AUTO	26/07-A	1.600	2.675	4	30.20	3814	4000	P5	6.65	3	1	10000	2026-07-02	2026-07-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
138	360	19	SZPULA BOK	REGLANULAT PC BIAŁY		\N	\N	\N	1	16	AUTO	26/01-A; 26/03-A	127.200	129.900	1	26.60	973	80	P1	12.50	7	3	83560	2026-01-14	2026-03-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
139	361	19	SZPULA BOK MĘSKI	REGLANULAT ABS BIAŁY		\N	\N	\N	1	16	AUTO	26/03-B; 26/04-B; 26/05-A; 26/06-A; 26/07-A; 26/07-B; 26/08-A	119.800	119.800	1	43.60	660	130	595/395/400	16.55	1	7	106737	2026-03-11	2026-09-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
140	362	19	SZPULA BOK ŻEŃSKI	REGLANULAT ABS BIAŁY		\N	\N	\N	1	219	AUTO	26/03-A; 26/08-A	122.800	122.800	1	37.50	768	104	595/395/400	12.45	1, 7	3	37136	2026-03-10	2026-08-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
141	363	19	SZPULA BOK ŻĘSKI	REGLANULAT ABS BIAŁY		\N	\N	\N	1	16	AUTO	26/05-B; 26/06-B; 26/07-A	122.800	122.800	1	38.00	757	104	595/395/400	12.45	1, 7	3	53440	2026-05-14	2026-07-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
144	335	20	MODUŁ 200	POM HOSTAFORM C9021 RESINEX	C001	33	\N	2.00	\N	209	AUTO	26/01-A	130.300	133.900	2	50.60	1138	2765	SKRZYNIA	\N	8	1	9318	2026-01-13	2026-01-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
145	336	20	MODUŁ M50 L200 POM	HOSTAFORM C9021	C001	33	\N	2.00	\N	210	AUTO	26/08-A	131.900	135.500	2	44.70	1288	2765	SKRZYNIA	\N	2, 7	2	5736	2026-08-06	2026-08-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
146	337	20	MODUŁ M50 L200 PP	PP MOPLEN EP 548R	C001	7	\N	2.00	\N	210	AUTO	26/06-A	86.700	89.700	2	43.50	1324	2528	SKRZYNIA	\N	8	1	3036	2026-06-25	2026-06-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
147	339	20	MODUŁ M50 L200 PP NIEBIESKI	PP MOPLEN EP 548R	GM-50977	7	188	2.00	15	210	AUTO	26/08-B; 26/10-A	84.000	88.000	2	49.60	1160	2765	SKRZYNIA	\N	2, 8	2	3081	2026-08-05	2026-10-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
148	338	20	MODUŁ M50 L200 PP biały	PP MOPLEN EP 548R	C001	7	\N	2.00	3	210	AUTO	26/08-A; 26/10-A	85.000	87.600	2	49.60	1160	2765	SKRZYNIA	\N	2, 8	2	6752	2026-08-05	2026-10-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
149	340	20	MODUŁ M50L200 PP NIEBIESKI	PP MOPLEN EP 548R	GM-50977	7	188	2.00	15	209	AUTO	26/08-B	83.800	87.500	2	57.80	996	2765	SKRZYNIA	\N	7	1	1000	2026-08-18	2026-08-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
150	367	21	AUDI 3	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/04-B	41.900	41.900	1	31.50	571	500	KM	22.20	1	1	2000	2026-04-27	2026-04-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
151	368	21	BMW 2	PS PLASTICSOLUTION; rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/04-C; 26/10-A	40.900	81.600	1	33.70	854	500	KM	21.50	1	2	4000	2026-04-27	2026-10-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
152	369	21	BYD 58	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-E	44.800	44.800	1	30.90	932	500	KM	23.50	7	1	1000	2026-07-09	2026-07-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
153	370	21	CITROEN 19	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/04-I	38.400	38.400	1	31.50	571	500	KM	21.30	1	1	2000	2026-04-30	2026-05-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
154	371	21	CUPRA 57	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-F	37.700	37.700	1	30.90	932	500	KM	19.90	7	1	1000	2026-07-09	2026-07-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
155	372	21	DACIA 26	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-C	38.600	38.600	1	30.90	932	500	KM	20.30	7	1	4000	2026-07-07	2026-07-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
156	373	21	DACIA 48	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-H	40.600	40.600	1	30.90	932	500	KM	21.30	7	1	4000	2026-07-09	2026-07-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
157	374	21	FIAT 15	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/08-C	37.000	76.200	1	33.40	862	500	KM	19.50	2	1	2000	2026-08-11	2026-08-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
158	375	21	FIAT SPORT 41	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-G	38.400	38.400	1	30.90	932	500	KM	20.20	7	1	4000	2026-07-09	2026-07-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
159	376	21	FORD 12	PS PLASTICSOLUTION; rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/04-E; 26/08-A	39.000	77.300	1	33.00	872	500	KM	20.50	1, 2	2	6000	2026-04-28	2026-08-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
160	377	21	FORD PERFORMANCE 33	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/01-B	39.000	19.500	2	32.50	886	500	KM	20.50	1	1	2000	2026-01-13	2026-01-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
161	378	21	HONDA 16	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/04-F	37.700	37.700	1	31.50	571	500	KM	19.90	1	1	2000	2026-04-28	2026-04-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
162	379	21	HYUNDAI 13	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/01-F	39.000	19.500	2	32.40	886	500	KM	20.50	1	1	2000	2026-01-16	2026-01-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
163	380	21	MAZDA 20	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/04-J	38.900	38.900	1	31.50	571	500	KM	20.40	1	1	2000	2026-04-30	2026-05-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
164	381	21	MERCEDES AMG 4	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/05-M	44.900	44.900	1	31.50	571	500	KM	23.50	1	1	2000	2026-05-05	2026-05-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
165	382	21	MERCEDES AMG 44	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/01-D	39.500	19.750	2	32.40	886	500	KM	21.00	1	1	2000	2026-01-14	2026-01-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
166	383	21	MERCEDES BENZ 1	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/01-C	38.500	19.250	2	32.40	886	500	KM	20.30	1	1	2000	2026-01-14	2026-01-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
167	384	21	MERCEDES-BENZ 1	PS PLASTICSOLUTION; rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/04-A; 26/08-B	39.000	77.300	1	33.00	872	500	KM	20.50	1, 2	2	6000	2026-04-27	2026-08-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
168	385	21	MITSUBISHI MOTORS 17	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/04-H	38.900	38.900	1	31.50	571	500	KM	20.45	1	1	2000	2026-04-29	2026-04-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
169	386	21	NISSAN 22	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/05-K	38.300	38.300	1	31.50	571	500	KM	20.20	1	1	2000	2026-05-04	2026-05-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
170	387	21	PEUGEOT 8	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/10-B	40.600	81.600	1	33.70	854	500	KM	21.30	1	1	2000	2026-10-09	2026-10-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
171	388	21	PODKŁAD DO REJESTRACJI 460 LP	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-A	172.600	172.600	1	37.80	760	90	P1	16.80	2	1	10800	2026-07-22	2026-08-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
172	389	21	PODKŁAD REJESTRACJI HIC-GŁADKA	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/01-B	176.500	176.500	1	35.40	813	90	P1	17.20	7	1	4320	2026-04-21	2026-04-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
173	390	21	PODKŁAD REJESTRACJI HIC-LP	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/01-A	172.600	172.600	1	35.40	813	90	P1	16.80	7	1	4320	2026-04-16	2026-04-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
174	391	21	RANGE ROVER 40	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/05-L	38.800	38.800	1	31.50	571	500	KM	20.40	1	1	2000	2026-05-04	2026-05-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
175	392	21	RENAULT 10	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/04-D	38.800	38.800	1	31.50	571	500	KM	20.40	1	1	2000	2026-04-27	2026-04-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
176	393	21	RENAULT PASSION 35	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/01-A	39.000	19.500	2	32.50	886	500	KM	20.50	1	1	2000	2026-01-13	2026-01-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
177	394	21	SEAT 18	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/04-G	36.700	36.700	1	31.50	571	500	KM	19.45	1	1	2000	2026-04-29	2026-04-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
178	395	21	TOYOTA 14	PS PLASTICSOLUTION; rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/01-E; 26/07-B	39.400	39.400	1	30.90	932	500	KM	20.70	1, 7	2	6000	2026-01-16	2026-07-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
179	396	21	VOLKSWAGEN 46	PS PLASTICSOLUTION		\N	\N	\N	1	\N	\N	26/05-Ł	41.300	41.300	1	31.50	571	500	KM	21.60	1	1	2000	2026-05-05	2026-05-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
180	397	21	VOLKSWAGEN 7	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-A; 26/08-D	39.200	76.200	1	33.40	862	500	KM	20.60	2, 7	2	5000	2026-07-03	2026-08-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
181	398	21	VOLVO 21	rHIPS PLASTICS SOLUTION		\N	\N	\N	1	\N	\N	26/07-D	38.000	38.000	1	30.90	932	500	KM	20.00	7	1	3000	2026-07-07	2026-07-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
182	412	22	DÓŁ POCHŁANIACZA WILGOCI	PP RANDOM YUPLENE R392Y RESINEX; PP RANDOM TIPPLEN-R960A		34	\N	\N	1	\N	\N	26/02-A; 26/05-A; 26/08-A; 26/10-A	41.300	41.350	2	23.20	2482	200	KM	9.25	1, 2, 7, 8	4	177482	2026-02-26	2026-08-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
183	413	22	GÓRA POCHŁANAICZA WILGOCI RÓŻOWY	PP HT 25 11	W4-99U	\N	\N	\N	17	\N	\N	26/04-B	27.300	27.300	2	18.90	3047	300	KM	9.45	2	1	2005	2026-04-10	2026-04-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
184	414	22	GÓRA POCHŁANAICZA WILGOCI SZARY	PP HT 25 11	W9-173	\N	162	2.00	18	\N	\N	26/05-A	27.300	27.300	2	18.90	3047	300	KM	9.45	2	1	43780	2026-05-27	2026-07-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
185	415	22	GÓRA POCHŁANIACZA WILGOCI BIAŁY	PP HT 25 11	W003	\N	\N	2.00	3	\N	\N	26/01-C; 26/04-C; 26/07-B; 26/09-B	27.600	27.750	2	15.60	3690	300	KM	9.45	2, 8	4	75448	2026-01-15	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
186	416	22	GÓRA POCHŁANIACZA WILGOCI RÓŻOWY	PP HT 25 11	W4-99U	\N	\N	4.00	17	\N	\N	26/01-B; 26/07-C; 26/09-A	27.500	27.500	2	15.90	3620	300	KM	9.45	2, 8	3	53515	2026-01-12	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
187	417	22	GÓRA POCHŁANIACZA WILGOCI SZARY	PP HT 25 11	W9-173	\N	162	2.00	18	\N	\N	26/04-A; 26/07-A; 26/09-C	27.600	27.700	2	15.60	3690	300	KM	9.45	2, 8	3	89980	2026-04-08	2026-09-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
188	418	22	ŚRODEK POCHŁANIACZA WILGOCI	PP RANDOM ADVANCE 400; PP RANDOM TIPPLEN-R960A; PP RANDOM YUPLENE R392Y RESINEX		34	\N	\N	1	\N	\N	26/03-A; 26/07-A; 26/10-A	9.100	9.200	4	18.00	6400	1000	KM	10.00	5	3	234000	2026-03-23	2026-10-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
190	547	24	MOCOWANIE PLEXA 30x15/15x15	TPE-E HRC9480/230		15	\N	\N	1	201	AUTO	26/01-A; 26/07-A	5.800	6.325	4	34.37	3350	1300	P2	8.00	4, 5	1	77000	2025-01-12	2026-07-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
192	474	25	ZASLEPKA PROFILU ASA BIAŁA	ASA STAREX WR9120	W94848	55	\N	\N	3	11	AUTO	26/09-A	10.500	12.075	4	31.54	3652	600	P5	7.15	6	1	14400	2026-09-29	2026-10-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
193	475	25	ZASLEPKA PROFILU NAPĘDOWEGO B2411	PVC-ST/P81CZ-0		69	\N	\N	1	11	AUTO	26/07-D	14.600	14.625	4	45.70	2520	900	P2	13.70	4	1	5000	2026-07-16	2026-07-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
194	479	25	ZAŚLEPKA ASA J.SZARY	ASA LI911 NATURAL	GM80721B	31	126	2.00	12	10	AUTO	26/01-B	10.700	12.275	4	33.45	926	600	P5	6.70	5	1	10200	2026-01-14	2026-01-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
195	476	25	ZAŚLEPKA ASA BEŻ	ASA LI911 NATURAL	SAN8GA7957	31	91	2.00	2	10	AUTO	26/01-E	10.600	12.250	4	34.31	839	600	P5	6.70	5	1	5200	2026-01-27	2026-01-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
196	477	25	ZAŚLEPKA ASA BIAŁA	STAREX WR9120 W94848 KGL		55	\N	\N	3	10	AUTO	26/01-A	10.700	12.275	4	33.45	926	600	P5	6.70	5	1	8000	2025-01-12	2026-01-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
197	478	25	ZAŚLEPKA ASA C.SZARY	ASA LI911 NATURAL	GM80779S	31	128	2.00	6	10	AUTO	26/01-C	12.400	12.550	4	34.86	826	600	P5	6.70	5	1	10000	2026-01-20	2026-01-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
198	480	25	ZAŚLEPKA ASA NOWA BEŻOWA	ASA LI911 NATURAL	SAN8GA7957	31	91	2.00	2	52	AUTO	26/06-B	10.400	11.925	4	30.00	3827	600	P5	6.60	5	1	4000	2026-06-02	2026-06-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
199	481	25	ZAŚLEPKA ASA NOWA BIAŁA	ASA STAREX WR9120	W94848	55	\N	\N	3	52	AUTO	26/06-E	10.500	12.075	4	31.00	3716	600	P5	6.60	5	1	7000	2026-06-15	2026-06-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
203	485	25	ZAŚLEPKA ASA WANILIOWY	ASA LI911 NATURAL	GM10483B	31	132	2.00	21	10	AUTO	26/01-D	10.600	12.250	4	34.37	838	600	P5	6.70	5	1	5000	2026-01-23	2026-01-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
204	486	25	ZAŚLEPKA PROFILU ASA C.SZARY	ASA LI911 NATURAL	GM-80779S	31	128	2.00	6	12	AUTO	26/10-B	10.400	11.950	4	32.22	3574	600	P5	7.15	6	1	14400	2026-10-05	2026-10-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
205	487	25	ZAŚLEPKA PROFILU ASA J.SZARY	ASA LI911 NATURAL	GM-80721B	31	126	2.00	12	12	AUTO	26/10-C	10.400	11.925	4	\N	\N	600	P5	6.60	6	1	0	2026-10-09	2026-10-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
189	500	23	SPINKA	POM C27N RESINEX	HP400331/40	32	92	1.00	8	206	AUTO	26/01-A	2.200	2.775	12	19.68	17560	1400	P5	3.20	6	1	155400	2026-01-12	2026-01-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
191	473	25	PASEK ELASTOMEROWY	HRC9480/230 KRAIBURG 55% PP TIPPLEN K295 BCD 45%	W9-60U	15	146	2.00	18	9	AUTO	26/06-A	38.400	38.500	2	44.70	1288	240	P5	9.40	8	1	30000	2026-06-29	2026-07-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
206	488	25	ZAŚLEPKA PROFILU KOŃCOWEGO B2410	PVC-ST/P81CZ-0		69	\N	\N	1	12	AUTO	26/07-A	21.500	22.600	4	48.00	2400	600	P2	13.65	4	1	6000	2026-07-09	2026-07-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
207	489	25	ZAŚLEPKA PROFILU KOŃCOWEGO B2410L LOGO BB	PVC-ST/P81CZ-0		69	\N	\N	1	12	AUTO	26/07-B	21.400	22.425	4	51.00	2558	600	P2	13.55	4	1	8000	2026-07-13	2026-07-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
208	490	25	ZAŚLEPKA PROFILU PC CZARNY	PC CZARNY REGLANULAT		\N	\N	\N	7	12	AUTO	26/06-A	11.400	13.075	4	31.38	1835	600	P5	6.60	5	1	66000	2026-06-17	2026-07-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
209	491	25	ZAŚLEPKA PROFILU PC NIEBIESKI	PC5GB4867		\N	\N	\N	15	12	AUTO	26/05-C	11.400	13.150	4	30.80	1870	600	P5	7.10	5	1	4000	2026-05-29	2026-06-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
210	492	25	ZAŚLEPKA PROFILU PC NOWA CZARNY	PC CZARNY REGLANULAT		\N	\N	\N	7	12	AUTO	26/09-B	11.300	13.000	4	24.70	4660	600	P5	7.15	6	1	14400	2026-09-17	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
211	493	25	ZAŚLEPKA PROFILU PC NOWA NIEBIESKA	PC 12.80 UR POLIMER PROJEKT	PC5GB4867	13	99	2.00	15	12	AUTO	26/09-C	11.500	13.225	4	28.98	3975	600	P5	7.15	6	1	14400	2026-09-23	2026-09-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
212	494	25	ZAŚLEPKA PROFILU PC NOWA TRANSPARENT	PC 12.80 UR POLIMER PROJEKT		13	\N	\N	19	12	AUTO	26/09-A	11.500	13.125	4	24.71	4660	600	P5	7.15	6	1	14400	2026-09-11	2026-09-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
213	495	25	ZAŚLEPKA PROFILU PC TRANSP.	PC 12.80 UR POLIMER PROJEKT		13	\N	\N	1	12	AUTO	26/05-B	11.300	13.025	4	30.77	935	600	P5	7.10	5	1	8000	2026-05-27	2026-05-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
214	496	25	ZAŚLEPKA PROFILU PC TRANSPARENT	PC 12.80 UR POLIMER PROJEKT		13	\N	\N	19	12	AUTO	26/07-A	11.500	13.175	4	32.34	1781	600	P5	7.15	5	1	8000	2026-07-02	2026-07-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
215	497	25	ZAŚLEPKA PROFILU ŚRODKOWEGO B2412N	PVC-ST/P81CZ-0		69	\N	\N	1	12	AUTO	26/07-E	17.300	17.325	4	57.40	2006	700	P2	12.70	4	1	15400	2026-07-17	2026-07-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
216	498	25	ZAŚLEPKA PROFILU ŚRODKOWEGO EXTRA-TOP-B2414	PVC-ST/P81CZ-0		69	\N	\N	1	12	AUTO	26/07-C	17.700	18.675	4	50.50	2280	700	P2	13.00	4	1	4200	2026-07-14	2026-07-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
217	499	25	ZAŚLEPKA PROFILU ŚRODKOWEGO PLAT-SECTION B2415	PVC-ST/P81CZ-0		69	\N	\N	1	12	AUTO	26/07-F	3.600	4.675	4	52.20	2206	3000	P2	11.40	4	1	3000	2026-07-23	2026-07-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
218	1	1	FIBBOWL MAT 43x22 J.SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	3.00	12	\N	\N	26/03-A	170.000	170.500	1	44.40	648	70	P7	12.00	8	1	800	2026-03-03	2026-03-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
220	3	1	FIBONNE DENTAL MONSTER POMARAŃCZOWY	GRANPOL TPE-S-GRANSEB 80G/000/139	GM-20225E	18	125	5.00	16	174	AUTO	26/06-C	245.600	246.650	2	64.50	894	45	P2	11.80	8	1	585	2026-06-25	2026-06-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
221	4	1	FIBONNE DENTAL MONSTER ZIELONY	GRANPOL TPE-S-GRANSEB 80G/000/139	W7-76	18	153	3.00	22	174	AUTO	26/06-B	248.200	248.100	2	64.50	894	45	P2	11.80	8	1	1500	2026-06-24	2026-06-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
222	5	1	FIBOOFFET RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	\N	\N	26/05-B	427.500	427.500	1	45.70	630	33	KM	2.40	8	1	528	2026-05-29	2026-05-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
223	6	1	FIBOOFFET SZARY	HRC9480/230 KRAIBURG	GM-80690E	15	112	2.00	18	\N	\N	26/05-A	427.500	427.500	1	45.70	630	33	KM	2.40	8	1	1007	2026-05-28	2026-05-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
224	7	1	FIBOOM NIEBIESKI FUTTERHAUS	GPL-GRANSEB 80G/000/139 GRANPOL	W6-253	18	\N	3.00	15	171	AUTO	26/04-B	134.600	139.200	1	47.70	602	60	P6	9.20	2	1	2204	2026-04-01	2026-04-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
225	8	1	FIBOOM RÓŻOWY FUTTERHAUS	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	171	AUTO	26/04-C	134.600	139.300	1	46.30	622	60	P6	9.20	2	1	2201	2026-04-03	2026-04-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
226	9	1	FIBOOM ŻÓŁTY FUTTERHAUS	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	171	AUTO	26/03-A	134.600	139.200	1	47.80	602	60	P6	9.20	2	1	2213	2026-03-30	2026-04-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
228	11	1	FIBOONE BIG PUPPY NIEBIESKI	HRC9480/230 KRAIBURG	W6-125	15	152	3.00	15	187	AUTO	26/02-E; 26/09-D	54.500	55.150	2	29.80	1930	250	P2	14.00	4, 5	2	1785	2026-02-27	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
231	14	1	FIBOONE BIG PUPPY RÓŻOWY	HRC9480/230 KRAIBURG	GM-32747E	15	124	4.00	17	187	AUTO	26/09-A	54.000	54.700	2	29.80	1930	250	P2	14.00	4	1	3500	2026-09-18	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
232	15	1	FIBOONE BIG PUPPY ZIELONY	HRC9480/230 KRAIBURG	W7-76	15	153	3.00	22	187	AUTO	26/02-D; 26/09-E	54.700	55.350	2	29.80	1930	250	P2	14.00	4, 5	2	769	2026-02-27	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
233	16	1	FIBOONE BIG PUPPY ŻÓŁTY	HRC9480/230 KRAIBURG	W2-73/1	15	154	3.00	23	187	AUTO	26/02-C; 26/09-C	54.300	55.150	2	29.80	1930	250	P2	14.00	4, 5	2	1486	2026-02-27	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
235	18	1	FIBOONE DENTAL FUTTERHAUS NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL	W6-253	18	\N	3.00	15	110	AUTO	26/03-C	108.400	109.350	2	53.20	541	100	P6	11.50	2	1	4200	2026-03-23	2026-03-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
236	19	1	FIBOONE DENTAL FUTTERHAUS RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	110	AUTO	26/03-B	108.500	109.350	2	53.20	541	100	P6	11.50	2	1	4200	2026-03-18	2026-03-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
219	2	1	FIBEEK BEZ OTWORU	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32218E	18	113	2.00	17	148	AUTO	26/03-A	26.000	26.900	2	28.90	996	176	P5	4.60	4	1	2081	2026-03-18	2026-03-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
227	10	1	FIBOONE BIG PUPPY EUROPRIS	HRC9480/230 KRAIBURG	GM-32747E	15	124	4.00	17	187	AUTO	26/04-A	53.400	54.250	2	34.25	1680	250	P2	14.00	6	1	11000	2026-04-14	2026-04-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
237	20	1	FIBOONE DENTAL FUTTERHAUS ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	110	AUTO	26/03-A	108.700	109.500	2	53.20	541	100	P6	11.50	2	1	4200	2026-03-13	2026-03-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
240	23	1	FIBOONE DENTAL MONSTER FUTTERHAUS NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL	W6-253	18	\N	3.00	15	174	AUTO	26/03-A	247.200	248.200	2	68.80	837	50	P6	12.50	8	1	2805	\N	2026-04-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
241	24	1	FIBOONE DENTAL MONSTER FUTTERHAUS ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	174	AUTO	26/03-B	246.600	241.550	2	61.60	935	50	P6	12.50	8	1	2800	2026-04-08	2026-04-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
242	25	1	FIBOONE DENTAL MONSTER NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL TPE-S-GRANSEB 80G/000/139	W6-125	18	152	3.00	15	174	AUTO	26/04-D; 26/06-A	247.300	248.100	2	64.40	894	45	P2	11.80	8	2	1660	2026-04-20	2026-06-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
243	26	1	FIBOONE DENTAL MONSTER POMARAŃCZOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-20225E	18	125	4.00	16	174	AUTO	26/04-B	241.000	243.650	2	64.20	897	50	P2	12.50	8	1	1000	2026-04-17	2026-04-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
244	27	1	FIBOONE DENTAL MONSTER RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	5.00	17	174	AUTO	26/03-C; 26/04-A	242.800	243.750	2	64.20	897	50	P2	12.50	8	2	3814	2026-04-08	2026-04-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
245	28	1	FIBOONE DENTAL MONSTER ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	174	AUTO	26/04-C	224.500	245.350	2	65.60	878	50	P2	12.50	8	1	700	2026-04-20	2026-04-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
246	29	1	FIBOONE DENTAL NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL TPE-S-GRANSEB 80G/000/139	W6-125	18	152	3.00	15	110	AUTO	26/03-C; 26/07-B	113.500	112.400	2	46.20	1240	100	P2	11.50	2, 8	2	3124	2026-03-25	2026-07-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
249	32	1	FIBOONE DENTAL RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL TPE-S-GRANSEB 80G/000/139	GM-32747E	18	124	4.00	17	110	AUTO	26/04-A; 26/09-A	108.000	108.300	2	41.60	173	100	P2	11.50	7	2	12055	2026-04-23	2026-09-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
250	33	1	FIBOONE DENTAL ZIELONY	GRANPOL TPE-S-GRANSEB 80G/000/139	W7-76	18	153	3.00	22	110	AUTO	26/07-A	111.300	112.300	2	46.20	1240	100	P2	\N	8	1	1039	2026-07-14	2026-07-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
251	34	1	FIBOONE DENTAL ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	110	AUTO	26/03-A	108.780	109.500	2	53.20	541	100	P6	11.50	2	1	2531	2026-03-17	2026-03-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
253	36	1	FIBOOWL L BEŻOWY	HRC9480/230 KRAIBURG	GM-12197E	15	117	2.00	2	154	AUTO	26/06-D	249.000	249.800	1	54.30	530	30	P2	7.95	8	1	630	2026-06-12	2026-06-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
255	38	1	FIBOOWL L C.SZARY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%; HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	154	AUTO	26/01-A; 26/06-F	249.000	249.800	1	54.30	530	30	P2	7.95	2, 8	2	743	2026-01-22	2026-06-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
257	40	1	FIBOOWL L FUTTERHAUS C.SZARY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	GM-80690E; GM80690E	15	112	2.00	6	154	AUTO	26/01-B; 26/09-A	240.500	238.900	1	46.50	620	30	P2	8.00	2, 9	2	1800	2026-01-21	2026-09-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
259	42	1	FIBOOWL L RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	154	AUTO	26/06-A	205.200	205.800	1	50.60	569	30	P2	7.95	8	1	606	2026-06-09	2026-06-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
260	43	1	FIBOOWL L ZIELONY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%; HRC9480/230 KRAIBURG	GM41373P	15	107	2.00	22	154	AUTO	26/01-C; 26/06-E	249.000	249.800	1	62.00	464	30	P2	7.95	2, 8	2	1531	2026-01-26	2026-06-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
261	44	1	FIBOOWL L ŻÓŁTY	HRC9480/230 KRAIBURG	GM10684P	15	115	2.00	23	154	AUTO	26/06-C	250.000	250.800	1	51.80	556	30	P2	7.95	8	1	600	2026-06-11	2026-06-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
262	46	1	FIBOOWL M BEŻ	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	GM-12197E	15	117	2.00	2	151	AUTO	26/01-A	122.100	123.400	1	48.00	600	40	P5	5.10	3	1	500	2026-01-23	2026-01-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
238	21	1	FIBOONE DENTAL MONSTER	GRANPOL TPE-S-GRANSEB 80G/000/139	GM-32747E	18	124	5.00	17	174	AUTO	26/09-A	246.600	122.600	2	54.30	1060	45	P2	12.00	9	1	2520	2026-09-14	2026-09-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
239	22	1	FIBOONE DENTAL MONSTER EUROPRIS	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	174	AUTO	26/04-A	244.700	245.650	2	60.70	948	50	P2	12.50	8	1	4790	2026-04-21	2026-04-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
263	45	1	FIBOOWL M BETTERCAT	HRC9480/230 KRAIBURG; HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R BCD 5%	GM12197E; GM-12197E	15	117	2.00	2	151	AUTO	26/01-A; 26/07-A; 26/09-B	123.000	123.400	1	46.60	620	40	P5	5.00	3	3	12000	2026-01-14	2026-09-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
268	51	1	FIBOOWL M RÓŻOWY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	GM-53281E	15	123	2.00	17	151	AUTO	26/01-B	123.000	123.700	1	47.90	601	40	P5	5.10	3	1	920	2026-01-26	2026-01-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
269	52	1	FIBOOWL M ZIELONY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	GM-41373P	15	107	2.00	22	151	AUTO	26/07-A	118.800	126.000	1	45.90	627	40	P2	5.00	3	1	1240	2026-07-07	2026-07-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
270	53	1	FIBOOWL M ŻÓŁTY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM10684P	15	115	2.00	23	151	AUTO	26/04-A	125.800	126.300	1	45.60	631	40	P5	5.00	4	1	400	2026-04-07	2026-04-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
271	61	1	FIBOOWL S ZIELONY	HRC9480/230 KRAIBURG PP TATREN IM2263 BCD	GM41373P	15	107	2.00	22	146	AUTO	26/03-A	57.200	57.700	1	35.79	804	175	P6	10.70	6	1	775	2026-03-30	2026-03-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
272	54	1	FIBOOWL S BEŻOWY	HRC9480/230 KRAIBURG PP TATREN IM 2263 BCD; HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM-12197E	15	117	2.00	2	146	AUTO	26/03-B; 26/07-C	56.100	56.900	1	32.30	890	175	P6	10.70	3, 6	2	1225	2026-03-31	2026-07-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
273	55	1	FIBOOWL S BORDOWY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	W4-62	15	159	2.00	4	146	AUTO	26/07-E	57.200	57.900	1	32.30	890	175	P6	10.70	3	1	435	2026-07-06	2026-07-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
276	58	1	FIBOOWL S C.SZARY	HRC9480/230 KRAIBURG PP TATREN IM 2263 BCD	GM80690E	15	112	2.00	6	146	AUTO	26/04-E	57.200	58.700	1	36.46	790	175	P6	10.70	6	1	800	2026-04-01	2026-04-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
278	60	1	FIBOOWL S RÓŻOWY	HRC9480/230 KRAIBURG PP TATREN IM2263 BCD; HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM-32218E	15	113	2.00	17	146	AUTO	26/04-D; 26/07-B	56.800	57.300	1	31.40	912	175	P6	10.70	3, 6	2	1410	2026-04-01	2026-07-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
279	62	1	FIBOOWL S ŻÓŁTY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM10684P	15	115	2.00	23	146	AUTO	26/07-F	57.800	58.500	1	32.30	890	175	P6	10.70	3	1	410	2026-07-07	2026-07-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
280	63	1	FIBOOWL SPIKY C.SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	3.00	6	149	AUTO	26/03-A	153.000	153.400	1	50.40	571	28	P5	4.55	3	1	812	2026-03-30	2026-03-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
281	64	1	FIBOOWL SPIKY FUTTERHAUS C.SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	3.00	6	149	AUTO	26/03-B	156.800	160.500	1	49.70	578	28	P5	4.55	3	1	809	2026-03-27	2026-03-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
282	65	1	FIBOOWL SPIKY FUTTERHAUS RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	3.00	17	149	AUTO	26/03-A	156.800	160.500	1	49.80	578	28	P5	4.55	3	1	800	2026-03-26	2026-03-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
283	66	1	FIBOOWL SPIKY NIEBIESKI	HRC9480/230 KRAIBURG	GM-53281E	15	123	3.00	15	149	AUTO	26/03-B	153.900	154.200	1	50.40	571	28	P5	4.55	3	1	812	2026-03-30	2026-03-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
284	67	1	FIBOOWL SPIKY RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	3.00	17	149	AUTO	26/03-C	154.100	154.600	1	50.40	571	28	P5	4.55	3	1	812	2026-03-31	2026-03-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
285	68	1	FIBOOWL SPIKY ZIELONY	HRC9480/230 KRAIBURG	GM41373P	15	107	3.00	22	149	AUTO	26/03-D	153.900	154.100	1	50.80	567	28	P5	4.55	3	1	1008	2026-04-01	2026-04-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
286	69	1	FIBOOWL ŻÓŁTY	HRC9480/230 KRAIBURG PP TATREN IM2263 BCD	GM10684P	15	115	2.00	23	146	AUTO	26/03-C	57.800	58.300	1	36.75	783	175	P6	10.70	6	1	800	2026-03-31	2026-04-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
287	70	1	FIBOWL M J.SZARY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM 80690E	15	112	2.00	12	44	AUTO	26/04-C	126.100	126.500	1	45.60	631	40	P5	5.00	4	1	800	2026-04-08	2026-04-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
288	71	1	FIBSY FUTTERHAUS RÓŻOWY	TPE-S-GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	171	AUTO	26/04-B	228.000	230.500	1	41.20	700	20	P6	5.00	7	1	1920	2026-04-14	2026-04-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
290	73	1	FIBSY NIEBIESKI FUTTERHAUS	TPE-S-GPL-GRANSEB 80G/000/139 GRANPOL	W6-253	18	\N	3.00	15	171	AUTO	26/04-A	232.100	232.100	1	41.20	700	20	P6	5.00	7	1	1900	2026-04-13	2026-04-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
293	76	1	FIJOO FIOLETOWY	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	W5-25	15	156	3.00	9	\N	\N	26/03-B; 26/09-A	82.900	83.900	2	79.00	729	80	P2	7.20	7	2	3910	2026-03-27	2026-09-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
266	49	1	FIBOOWL M GAMEDOG	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	GM-53281E	15	123	2.00	15	151	AUTO	26/02-A	119.200	121.100	1	50.50	570	46	P2	6.45	2	1	3100	2026-02-17	2026-02-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
267	50	1	FIBOOWL M PSI BUFET	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM 10684P; GM10684P	15	115	2.00	23	151	AUTO	26/04-A	123.800	124.400	1	43.40	663	40	P5	5.50	4	2	1052	2026-04-03	2026-04-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
277	59	1	FIBOOWL S GREENPETFOOD	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	GM-12197E	15	117	2.00	2	146	AUTO	26/01-A	56.700	57.200	1	33.10	870	175	P6	10.70	4	1	5218	2026-01-21	2026-01-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
292	75	1	FIJOO EUROPRIS	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	W5-25	15	156	3.00	9	\N	\N	26/04-C	82.900	84.200	2	78.70	731	80	P2	7.20	7	1	3972	2026-04-08	2026-04-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
295	78	1	FIJOO NIEBIESKI FUTTERHAUS	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	W6-253	15	\N	3.00	15	171	AUTO	26/04-B	81.500	82.850	2	78.90	730	80	P6	7.20	7	1	2700	2026-04-03	2026-04-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
296	79	1	FIJOO RÓŻOWY	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	GM-32218E	15	113	3.00	17	\N	\N	26/03-C	81.700	83.100	2	78.10	368	80	P6	7.20	7	1	1004	2026-03-30	2026-03-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
297	80	1	FIJOO ZIELONY	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	GM41373P	15	107	3.00	22	\N	\N	26/03-E	81.900	83.200	2	79.00	364	80	P6	7.20	7	1	1008	2026-03-31	2026-04-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
298	81	1	FIJOO ŻÓŁTY	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	GM10684P	15	115	3.00	23	\N	\N	26/03-D	81.900	83.200	2	78.10	368	80	P6	7.20	7	1	800	2026-03-31	2026-03-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
299	82	1	FIJOO ŻÓŁTY FUTTERHAUS	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	W2-73/1	15	154	3.00	23	171	AUTO	26/04-A	81.700	83.050	2	78.90	730	80	P6	7.20	7	1	2700	2026-04-01	2026-04-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
300	83	1	FIPLOO FIOLETOWY	HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 10%	W5-25	15	156	2.00	9	196	AUTO	26/10-D	155.200	115.600	1	54.40	635	58	P7	7.10	4	1	740	2026-10-05	2026-10-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
301	84	1	FIPLOO RÓŻOWY	HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 10%	GM-32218E	15	113	2.00	17	196	AUTO	26/10-A	115.000	115.300	1	45.40	635	58	P7	7.10	4	1	1077	2026-10-01	2026-10-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
302	85	1	FIPLOO ZIELONY	HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 10%	GM-43676E	15	108	2.00	22	196	AUTO	26/10-C	117.000	117.500	1	54.40	635	58	P7	7.10	4	1	764	2026-10-02	2026-10-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
303	86	1	FIPLOO ŻÓŁTY	HRC9480/230 KRAIBURG 95%PP MOPLEN EP 548R 10%	GM10684P	15	115	2.00	23	196	AUTO	26/10-B	114.600	115.200	1	54.40	635	58	P7	7.10	4	1	522	2026-10-02	2026-10-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
304	87	1	FLIP FIBOOWL BORDOWY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	GM-53281E	15	123	2.00	4	199	AUTO	26/08-D	133.800	133.800	1	54.20	530	48	P6	7.05	9	1	540	2026-08-12	2026-08-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
307	90	1	FLIP FIBOOWL FIOLETOWY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	W5-25	15	156	2.00	9	199	AUTO	26/08-B	133.500	133.500	1	50.10	574	48	P6	7.05	9	1	1056	2026-08-10	2026-08-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
308	91	1	FLIP FIBOOWL GRANATOWY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	W6-69	15	158	2.00	11	199	AUTO	26/08-F	133.500	133.500	1	56.00	514	48	P6	7.05	9	1	500	2026-08-13	2026-08-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
309	92	1	FLIP FIBOOWL RÓŻOWY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	GM-32218E	15	113	2.00	17	199	AUTO	26/08-C	134.200	134.200	1	52.10	552	48	P6	7.05	9	1	900	2026-08-11	2026-08-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
310	93	1	FLIP FIBOOWL ZIELONY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	GM41373P	15	107	2.00	22	199	AUTO	26/08-G	131.500	131.500	1	49.80	587	48	P6	7.05	9	1	616	2026-08-17	2026-08-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
311	94	1	FLIP FIBOOWL ŻÓŁTY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	GM-12485E	15	116	2.00	23	199	AUTO	26/08-H	132.200	132.200	1	49.80	587	48	P6	7.05	9	1	702	2026-08-18	2026-08-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
312	106	1	FRINGOO RÓŻOWY	GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	GM-32747E	18	124	4.00	17	\N	\N	26/09-A	121.000	126.600	1	35.90	800	32	P2	4.65	2	1	3104	2026-09-17	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
314	96	1	FRINGOO FUTTERHAUS NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL	W6-253	18	\N	3.00	15	171	AUTO	26/03-A	119.700	125.500	1	35.75	805	32	P2	4.65	5	1	2240	2026-03-11	2026-03-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
315	97	1	FRINGOO FUTTERHAUS RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	5.00	17	171	AUTO	26/03-C	119.100	130.000	1	35.72	805	32	P6	4.65	5	1	2208	2026-03-16	2026-03-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
316	98	1	FRINGOO FUTTERHAUS ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	171	AUTO	26/03-B	125.400	126.200	1	35.72	805	32	P2	4.65	5	1	2208	2026-03-12	2026-03-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
317	99	1	FRINGOO MINI NIEBIESKI	GRANSEB-80 GRANPOL	W6-125	\N	152	3.00	15	172	AUTO	26/07-B	58.800	63.300	1	36.60	786	120	P2	7.55	4	1	1250	2026-07-24	2026-07-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
319	101	1	FRINGOO MINI RÓŻOWY	GRANSEB -80 GRANPOL	GM-32747E	\N	124	4.00	17	172	AUTO	26/07-A	58.800	63.300	1	36.50	789	120	P2	7.55	4	1	1405	2026-07-24	2026-07-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
320	102	1	FRINGOO MINI ZIELONY	GRANSEB-80 GRANPOL	W7-76	\N	153	3.00	22	172	AUTO	26/07-E	59.000	62.800	1	36.60	786	120	P2	7.55	4	1	804	2026-07-28	2026-07-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
321	103	1	FRINGOO MINI ŻÓŁTY	GRANSEB-80 GRANPOL	W2-73/1	\N	154	3.00	23	172	AUTO	26/07-D	58.700	62.600	1	36.60	786	120	P2	7.55	4	1	1004	2026-07-28	2026-07-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
322	104	1	FRINGOO NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	W6-125	18	152	3.00	15	\N	\N	26/03-C; 26/09-B	120.600	126.400	1	35.90	800	32	P2	4.65	2, 5	2	1849	2026-03-19	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
323	105	1	FRINGOO POMARAŃCZOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-20225E	18	125	3.00	16	\N	\N	26/03-D	125.400	126.200	1	35.72	806	32	P6	4.65	5	1	1024	2026-03-19	2026-03-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
294	77	1	FIJOO JUSTRUSSEL	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	GM-32807E	15	102	2.00	8	\N	\N	26/10-A	80.900	82.150	2	75.80	760	80	P2	7.20	9	1	5280	2026-09-30	2026-10-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
313	95	1	FRINGOO EUROPRIS	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	\N	\N	26/04-A	122.500	124.700	1	37.92	759	32	P2	4.65	6	1	10300	2026-04-20	2026-04-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
324	107	1	FRINGOO ZIELONY	GPL-GRANSEB 80G/000/139 GRANPOL	W7-76	18	153	3.00	22	\N	\N	26/03-E	125.400	126.200	1	35.72	806	32	P6	4.65	5	1	1563	2026-03-20	2026-06-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
325	108	1	FRINGOO ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	\N	\N	26/03-A	125.400	126.200	1	35.72	806	32	P6	4.65	5	1	512	2026-03-16	2026-03-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
326	109	1	FRISBO POMARAŃCZOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-20225E	18	125	4.00	16	\N	\N	26/02-A	119.700	124.000	1	37.70	763	40	P6	5.50	4	1	800	2026-03-18	2026-03-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
327	110	1	FRISBOO FUTTERHAUS NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	15	171	AUTO	26/03-B	117.500	121.900	1	40.30	714	40	P2	5.50	4	1	2003	2026-03-10	2026-03-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
328	111	1	FRISBOO FUTTERHAUS RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	171	AUTO	26/03-A	117.300	121.400	1	35.10	820	40	P6	5.50	4	1	2000	2026-03-09	2026-03-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
329	112	1	FRISBOO FUTTERHAUS ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	171	AUTO	26/03-C	117.200	121.600	1	36.20	795	40	P2	5.50	4	1	2000	2026-03-12	2026-03-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
330	113	1	FRISBOO MINI NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	W6-125	18	152	3.00	15	203	AUTO	26/04-A; 26/09-E	53.200	57.300	1	31.50	915	60	P6	3.50	5, 6	2	1821	2026-04-02	2026-09-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
332	115	1	FRISBOO MINI RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	GM-32747E	18	124	4.00	17	203	AUTO	26/04-B; 26/09-A	53.400	57.400	1	31.25	920	60	P6	3.50	5, 6	2	2138	2026-04-02	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
333	116	1	FRISBOO MINI ZIELONY	GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	W7-76	18	153	3.00	22	203	AUTO	26/09-D	53.300	57.300	1	31.50	915	60	P6	3.50	5	1	852	2026-09-24	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
334	117	1	FRISBOO MINI ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	W2-73/1	18	154	3.00	23	203	AUTO	26/04-C; 26/09-C	53.000	57.200	1	31.50	915	60	P6	3.50	5, 6	2	1300	2026-04-03	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
335	118	1	FRISBOO NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL	W6-125	18	152	3.00	15	\N	\N	26/03-E	124.200	124.800	1	37.70	763	40	P2	5.50	2, 4	2	2000	2026-03-03	2026-03-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
336	119	1	FRISBOO POMARAŃCZOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-20225E	18	125	4.00	16	\N	\N	26/02-A	119.300	124.000	1	32.90	875	40	P6	5.50	2	1	1000	2026-06-27	2026-02-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
337	120	1	FRISBOO RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	5.00	17	\N	\N	26/02-B; 26/03-B	118.500	123.000	1	37.70	763	40	P6	5.50	2, 4	2	2000	2026-02-27	2026-03-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
338	121	1	FRISBOO ZIELONY	GPL-GRANSEB 80G/000/139 GRANPOL	W7-76	18	153	3.00	22	\N	\N	26/03-D	124.300	124.900	1	36.30	795	40	P2	5.50	2, 4	2	1615	2026-03-03	2026-03-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
339	122	1	FRISBOO ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	\N	\N	26/03-C	117.200	121.600	1	36.20	795	40	P2	5.50	2, 4	2	1720	2026-03-02	2026-03-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
340	123	1	GUMKI DO MISEK DUŻE	GRANSEB 75G/TRANSP./1/139 GRANPOL		19	\N	\N	1	195	AUTO	26/08-A	1.700	3.000	8	46.10	4997	18000	P1	31.60	4	1	60000	2026-08-05	2026-08-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
341	124	1	GUMKI MAŁE	GRANSEB-75G/TRANSPARENTNY 1/139 GRANPOL		19	\N	\N	1	\N	\N	26/03/A	0.600	1.457	7	34.06	845	\N	P1	\N	5	1	34500	2026-03-05	2026-03-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
342	125	1	LICK FIBOOWL BORDOWY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	W4-62	15	159	2.00	4	191	AUTO	26/07-C	141.700	141.900	1	50.70	568	40	KM	7.40	9	1	726	2026-07-28	2026-07-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
345	128	1	LICK FIBOOWL FIOLETOWY	HRC9480/230 KRAIBURG 90% PPCOPO IM 2263 10%	W5-25	15	156	2.00	9	191	AUTO	26/07-A	141.500	142.000	1	50.70	568	40	KM	7.40	9	1	920	2026-07-27	2026-07-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
346	129	1	LICK FIBOOWL GRANATOWY	HRC9480/230 KRAIBURG 90% PPCOPO IM2263 BCD 10%	W6-69	15	158	3.00	11	191	AUTO	26/07-B	142.000	142.500	1	50.70	568	40	KM	7.40	9	1	720	2026-07-28	2026-07-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
347	130	1	LICK FIBOOWL MINI BORDOWY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	W4-62	15	159	2.00	4	198	AUTO	26/08-A	72.000	72.500	1	48.00	600	32	P6	32.50	4	1	968	2026-08-03	2026-08-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
349	132	1	LICK FIBOOWL MINI FIOLETOWY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	W5-25	15	156	2.00	9	198	AUTO	26/04-E	72.000	72.300	1	35.20	818	32	P6	3.25	4	1	1100	2026-04-21	2026-04-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
350	133	1	LICK FIBOOWL MINI GRANATOWY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	W6-69	15	158	2.00	11	198	AUTO	26/08-B	71.500	71.900	1	48.00	600	32	P6	32.50	4	1	1024	2026-08-04	2026-08-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
351	134	1	LICK FIBOOWL MINI RÓŻOWY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM-32218E	15	113	2.00	17	198	AUTO	26/04-B	72.000	72.400	1	35.40	508	32	P6	3.25	4	1	1000	2026-04-20	2026-04-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
352	135	1	LICK FIBOOWL MINI ZIELONY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM41373P	15	107	2.00	22	198	AUTO	26/04-C	72.000	72.400	1	35.40	508	32	P6	3.25	4	1	704	2026-04-20	2026-04-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
353	136	1	LICK FIBOOWL MINI ŻÓŁTY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM10684P	15	115	2.00	23	198	AUTO	26/04-A	72.000	72.400	1	35.40	508	32	P6	3.25	4	1	658	2026-04-17	2026-04-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
354	137	1	LICK FIBOOWL RÓŻOWY	HRC9480/230 KRAIBURG 85% PP TATREN IM2263 BCD 15%; HRC9480/230 KRAIBURG 90% PP TATREN IM2263 10%	GM-32218E	15	113	2.00	17	191	AUTO	26/03-B; 26/07-H	142.000	142.600	1	50.70	568	40	KM	7.40	1, 9	2	1726	2026-03-27	2026-08-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
355	138	1	LICK FIBOOWL ZIELONY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM41373P; GM-43676E	15	107	2.00	22	191	AUTO	26/03-A; 26/07-F	141.200	141.600	1	50.70	568	40	KM	7.40	1, 9	2	1245	2026-03-26	2026-07-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
356	139	1	LICK FIBOOWL ŻÓŁTY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%		15	\N	2.00	23	191	AUTO	26/07-G	141.900	142.300	1	50.70	568	40	KM	7.40	9	1	779	2026-07-31	2026-08-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
358	141	1	LOLLIPOP GRANATOWY	HRC9480/230 KRAIBURG	W6-69	15	158	2.00	11	204	AUTO	26/07-C	119.300	119.600	1	48.00	600	50	P2	6.15	4	1	600	2026-07-31	2026-07-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
359	142	1	LOLLIPOP J.SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	12	204	AUTO	26/07-E	119.300	119.900	1	48.00	600	50	P2	6.15	4	1	600	2026-08-03	2026-08-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
360	143	1	LOLLIPOP MINI BEŻOWY	HRC9480/230 KRAIBURG	GM-12197E	15	117	2.00	2	109	AUTO	26/08-B	44.000	44.500	1	34.68	830	175	P2	8.50	6	1	1000	2026-08-07	2026-08-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
362	145	1	LOLLIPOP MINI C.SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	109	AUTO	26/08-D	44.200	44.600	1	34.68	830	175	P2	8.50	6	1	1000	2026-08-10	2026-08-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
363	146	1	LOLLIPOP MINI J.SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	12	109	AUTO	26/08-C	44.000	44.800	1	34.68	830	175	P2	8.50	6	1	1000	2026-08-10	2026-08-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
364	147	1	LOLLIPOP MINI ZIELONY	HRC9480/230 KRAIBURG	GM-43676E	15	108	2.00	22	109	AUTO	26/08-E	44.100	44.600	1	34.68	830	175	P2	8.50	6	1	1000	2026-08-11	2026-08-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
365	148	1	LOLLIPOP NIEBIESKI	HRC9480/230 KRAIBURG	GM-53281E	15	123	2.00	15	204	AUTO	26/07-B	119.100	120.000	1	48.00	600	50	P2	6.15	4	1	620	2026-07-30	2026-07-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
366	149	1	LOLLIPOP RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	204	AUTO	26/07-D	119.400	119.800	1	48.00	600	50	P2	6.15	4	1	600	2026-07-31	2026-08-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
367	150	1	LOLLIPOP STICKY C.SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	185	AUTO	26/08-A	127.300	127.900	1	46.50	619	32	P5	4.35	4	1	1504	2026-08-20	2026-08-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
368	151	1	LOLLIPOP STICKY C.SZARY FUTTERHAUS	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	171	AUTO	26/04-A	127.800	128.100	1	38.50	748	32	P5	4.30	3	1	1504	2026-04-03	2026-04-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
369	152	1	LOLLIPOP STICKY RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	185	AUTO	26/08-B	127.000	127.000	1	46.50	619	32	P5	4.35	4	1	1504	2026-08-24	2026-08-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
370	153	1	LOLLIPOP STICKY RÓŻOWY FUTTERHAUS	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	171	AUTO	26/04-B	128.600	129.000	1	38.50	748	32	P5	4.30	3	1	1504	2026-04-07	2026-04-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
371	154	1	LOLLIPOP WALLY BEŻOWY	HRC9480/230 KRAIBURG	GM 12197E	15	117	2.00	2	204	AUTO	26/09-E	128.400	129.300	1	43.60	660	38	P5	5.50	1	1	1037	2026-09-17	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
372	155	1	LOLLIPOP WALLY BORDOWY	HRC9480/230 KRAIBURG	W4-62	15	159	2.00	4	204	AUTO	26/05-C; 26/09-B	126.500	127.700	1	43.60	660	38	P5	5.50	1, 3	2	1346	2026-05-28	2026-09-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
374	157	1	LOLLIPOP WALLY C.SZARY	HRC9480/230 KRAIBURG	GM 80690E	15	112	2.00	6	204	AUTO	26/09-G	128.000	129.300	1	43.50	662	38	P5	5.50	1	1	856	2026-09-21	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
377	160	1	LOLLIPOP WALLY GRANATOWY	HRC9480/230 KRAIBURG	W6-69	15	158	2.00	11	204	AUTO	26/05-A; 26/09-A	129.900	131.000	1	43.60	660	38	P5	5.50	1, 3	2	4566	2026-05-27	2026-09-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
378	161	1	LOLLIPOP WALLY J.SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	12	204	AUTO	26/09-F	128.000	129.700	1	43.60	660	38	P5	5.50	1	1	874	2026-09-18	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
379	162	1	LOLLIPOP WALLY RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E; GM 32218E	15	113	2.00	17	204	AUTO	26/05-E; 26/09-C	129.000	130.000	1	43.60	660	38	P5	5.50	1, 3	2	1537	2026-05-29	2026-09-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
380	163	1	LOLLIPOP WALLY ZIELONY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	22	204	AUTO	26/05-F	130.900	131.300	1	42.50	677	38	P5	5.50	3	1	510	2026-05-29	2026-05-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
381	164	1	LOLLIPOP WALLY ŻÓŁTY	HRC9480/230 KRAIBURG	W4-62; GM 12485E	15	159	2.00	23	204	AUTO	26/05-D; 26/09-D	129.000	130.000	1	43.60	660	38	P5	5.50	1, 3	2	1351	2026-05-28	2026-09-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
382	165	1	LOLLIPOP ZIELONY	HRC9480/230 KRAIBURG	GM41373P	15	107	2.00	22	204	AUTO	26/07-A	119.200	120.000	1	48.00	600	50	P2	6.15	4	1	1200	2026-07-29	2026-07-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
357	140	1	LOLLIPOP BETTERCAT ŚWIĄTECZNY	HRC9480/230 KRAIBURG	W7131	15	144	2.00	22	204	AUTO	26/07-A	109.100	109.700	1	49.00	587	50	P2	6.10	3	1	4200	2026-07-10	2026-07-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
376	159	1	LOLLIPOP WALLY EUROPRIS	HRC9480/230 KRAIBURG	W6-69	15	158	2.00	15	204	AUTO	26/05-A	129.200	129.800	1	48.70	590	38	P5	\N	3	1	9918	2026-05-18	2026-05-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
383	166	1	MATA 32x32 BEŻ FUTTERHAUS	HRC9480/230 KRAIBURG	GM-12197E	15	117	2.00	2	42	AUTO	26/06-B	241.200	241.700	1	48.30	596	80	P6	19.05	8	1	1009	2026-06-03	2026-06-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
385	168	1	MATA 32x32 C.SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	42	AUTO	26/02-B	240.300	241.300	1	41.50	693	80	P6	19.05	8	1	800	2026-02-11	2026-02-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
386	169	1	MATA 32x32 C.SZARY FUTTERHAUS	HRC9480/230 KRAIBURG	GM-80690E	15	112	2.00	6	42	AUTO	26/06-A	241.200	241.600	1	50.30	572	80	P6	19.05	8	1	1003	2026-06-03	2026-06-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
388	171	1	MATA 32x32 CZARNY	HRC9480/230 KRAIBURG	GM 378E	15	104	2.00	7	42	AUTO	26/02-C; 26/06-C	241.000	241.300	1	56.20	512	80	P6	19.05	8	2	1087	2026-02-12	2026-06-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
389	172	1	MATA 32x32 FUTTERHAUS BEŻ	HRC9480/230 KRAIBURG	GM-12197E	15	117	2.00	2	42	AUTO	26/02-B	231.800	234.500	1	42.30	680	20	32/32/9	4.90	8	1	800	2026-02-25	2026-02-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
393	176	1	MATA 32x32 J.SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	12	42	AUTO	26/02-A	240.300	241.300	1	42.20	682	80	P6	19.05	8	1	1005	2026-02-10	2026-02-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
395	178	1	MATA 32x32 RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	42	AUTO	26/08-B	250.000	250.000	1	44.80	642	80	P6	19.05	9	1	900	2026-08-28	2026-08-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
396	179	1	MATA 32x32 RÓŻOWY FUTTERHAUS	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	42	AUTO	26/06-C	241.200	241.700	1	52.60	547	80	P6	19.05	8	1	706	2026-06-08	2026-06-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
400	183	1	MATA 47x30 FUTTERHAUS BEŻ	HRC9480/230 KRAIBURG	GM80690E; GM-12197E	15	112	2.00	2	159	AUTO	26/03-A; 26/07-B	398.000	400.400	1	67.60	425	20	FIBOO	\N	8	2	2000	2026-02-27	2026-07-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
402	185	1	MATA 47x30 FUTTERHAUS RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	159	AUTO	26/07-A	400.000	400.500	1	67.70	425	20	FIBOO	\N	8	1	800	2026-07-15	2026-07-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
403	186	1	MATA 47x30 FUTTERHAUS SZARA	HRC9480/230 KRAIBURG		15	\N	\N	18	159	AUTO	26/05-A	398.700	400.000	1	45.70	630	20	94/35/6	8.20	8	1	1010	2026-05-27	2026-05-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
404	187	1	MATA 47x30 GREEN PETFOOD	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	22	222	AUTO	26/01-A	398.700	400.000	1	71.30	404	20	94/35/6	8.20	8	1	5100	2026-01-23	2026-02-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
408	191	1	MATA FIBLITTER 44x44 BEŻ	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	GM-12197E	15	117	2.00	2	221	AUTO	26/07-A	0.450	0.450	1	47.00	615	15	FIBOO	7.75	9	1	559	2026-07-21	2026-07-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
410	193	1	MATA FIBLITTER 44x44 C.SZARY	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	GM80690E	15	112	2.00	6	221	AUTO	26/07-D	0.450	0.450	1	50.70	568	15	FIBOO	7.75	9	1	517	2026-07-22	2026-07-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
411	194	1	MATA FIBLITTER 44x44 CZARNY	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	HP99611	15	95	2.00	7	221	AUTO	26/07-G	0.450	0.450	1	50.70	568	35	FIBOO	16.50	9	1	513	2026-07-24	2026-07-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
392	175	1	MATA 32x32 GREENPETFOOD	HRC9480/230 KRAIBURG	GM-326	15	103	2.00	7	222	AUTO	26/02-A	235.500	238.900	1	54.00	533	80	P6	19.05	8	1	5120	2026-02-16	2026-02-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
399	182	1	MATA 47x30 FUTTERHAUS	HRC9480/230 KRAIBURG	GM80690E; GM-12197E; GM-32218E	15	112	2.00	6	159	AUTO	26/02-A; 26/02-B; 26/02-C	398.700	400.000	1	76.30	377	20	94/35/6	8.20	8	1	2400	2026-02-04	2026-02-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
407	190	1	MATA FIBLITTER 44x44 BETTERCAT	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	GM-12197E	15	117	2.00	2	221	AUTO	26/07-A	450.000	450.300	1	47.00	615	15	FIBOO	7.75	9	1	3000	2026-07-16	2026-07-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
409	192	1	MATA FIBLITTER 44x44 BRIT	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	GM-53281E	15	123	2.00	15	184	AUTO	26/07-A	0.450	0.450	1	50.70	568	15	FIBOO	7.75	9	1	615	2026-07-24	2026-07-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
413	196	1	MATA FIBLITTER 44x44 J.SZARY	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	GM 80295	15	106	2.00	12	221	AUTO	26/07-C	0.450	0.450	1	47.00	615	15	FIBOO	7.75	9	1	550	2026-07-22	2026-07-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
414	197	1	MATA FIBLITTER 44x44 NIEBIESKI	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	GM-53281E	15	123	2.00	15	221	AUTO	26/07-E	0.450	0.450	1	50.70	568	15	FIBOO	7.75	9	1	576	2026-07-22	2026-07-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
415	198	1	MATA FIBLITTER 44x44 RÓŻOWA	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	GM-32218E	15	113	2.00	17	221	AUTO	26/07-B	0.450	0.450	1	47.00	615	15	FIBOO	7.75	9	1	532	2026-07-21	2026-07-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
416	199	1	MATA FISHKA BEŻOWY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM 10683P	15	111	2.00	2	205	AUTO	26/04-D	61.300	61.800	1	37.30	842	75	P5	4.75	4	1	874	2026-04-12	2026-04-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
418	201	1	MATA FISHKA FIOLETOWY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%; HRC9480/230 KRAIBURG	W5-17	15	155	2.00	9	205	AUTO	26/04-B; 26/10-C	60.900	61.400	1	39.80	720	75	P5	4.75	3, 4	2	2049	2026-04-09	2026-10-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
419	202	1	MATA FISHKA GRANATOWY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	W6-69	15	158	2.00	11	205	AUTO	26/04-C	61.800	62.200	1	34.30	842	75	P5	4.75	4	1	2207	2026-04-10	2026-04-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
420	203	1	MATA FISHKA J.SZARY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM 80295	15	106	2.00	12	205	AUTO	26/04-E	62.100	62.600	1	37.30	842	75	P5	4.75	4	1	600	2026-04-13	2026-04-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
422	205	1	MATA FISHKA TURKUSOWY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%; HRC9480/230 KRAIBURG	W6-146	15	157	2.00	20	205	AUTO	26/04-A; 26/10-B	61.900	62.400	1	39.80	723	75	P5	4.75	3, 4	2	2106	2026-04-08	2026-10-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
424	207	1	MATA LOLIPOOP STICKY NIEBIESKA	HRC9480/230 KRAIBURG	GM-53281E	15	123	2.00	15	185	AUTO	26/07-B	128.100	128.600	1	37.50	768	32	P5	4.35	3	1	800	2026-07-16	2026-07-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
425	208	1	MATA LOLIPOOP STICKY RÓŻOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	185	AUTO	26/07-A	128.300	128.900	1	37.50	768	32	P5	4.35	3	1	1012	2026-07-15	2026-07-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
426	209	1	MATA LOLLIPOP C.SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	42	AUTO	26/07-c	128.300	128.900	1	37.50	768	32	p5	4.35	3	1	800	2026-07-17	2026-07-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
428	211	1	MATA LOLLIPOP MINI ZIELONY	HRC9480/230 KRAIBURG	GM41373P	15	107	3.00	22	109	AUTO	26/01-B	45.300	45.800	1	36.10	797	175	P5	8.05	4	1	1020	2026-01-15	2026-01-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
429	212	1	MATA LOLLIPOP MINI ŻÓŁTY	HRC9480/230 KRAIBURG	GM10684P	15	115	2.00	23	109	AUTO	25/01-C	45.000	45.500	1	36.10	797	175	P5	8.05	4	1	600	2025-01-16	2026-01-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
430	213	1	MATA LOLLIPOP STICKY C.SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	185	AUTO	26/02-B	128.800	129.400	1	49.10	589	32	P5	4.35	4	1	1024	2026-02-12	2026-02-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
432	215	1	MATA POD MISKI FIOLETOWY	DRYFLEX-UV-403731	C4146	57	185	2.00	9	42	AUTO	26/08-B	250.000	250.000	1	52.80	545	15	FIBOO	4.30	8	1	280	2026-08-26	2026-08-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
437	220	1	MISKA L NIEBIESKA	R+PET CL-80M PRT RADOMSKO	GM51745P	43	127	2.00	15	45	AUTO	26/06-B	154.200	154.600	1	45.20	637	46	P7	7.65	2	1	736	2026-06-02	2026-06-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
438	221	1	MISKA L ZIELONA	R+PET CL-80M PRT RADOMSKO	GM41373P	43	107	2.00	22	45	AUTO	26/06-A	154.400	154.800	1	45.20	637	46	P7	7.65	2	1	1045	2026-06-02	2026-06-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
421	204	1	MATA FISHKA JASNO SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	12	205	AUTO	26/10-D	61.000	61.600	1	\N	\N	75	P5	4.75	3	1	0	2026-10-13	2026-10-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
423	206	1	MATA FIZZA	HRC9480/230 KRAIBURG	W2-01	15	167	2.00	23	42	AUTO	26/04-A	131.000	131.600	1	42.00	685	10	22;22;6	1.40	7	1	1717	2026-04-30	2026-05-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
435	218	1	MATA SPACEFIB	HRC9480/230 KRAIBURG	W6-69	15	158	2.00	15	42	AUTO	26/05-A	122.000	122.500	1	39.00	460	10	22;22;6	1.40	7	1	1200	2026-05-04	2026-05-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
441	224	1	MISKA M GREENPETFOOD	R+PET CL-80M PRT RADOMSKO	GM10683P	43	111	2.00	2	44	AUTO	25/02-A	101.500	102.700	1	45.10	638	100	P6	10.85	1	1	7800	2026-02-05	2026-02-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
443	226	1	MISKA M RÓŻOWY	R+PET CL-80M PRT RADOMSKO	20-33521F PET	43	\N	2.00	17	44	AUTO	26/01/-A	104.400	107.000	1	44.70	644	100	P6	10.85	1	1	1285	2026-01-29	2026-01-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
444	227	1	MISKA M ZIELONY	R+PET CL-80M PRT RADOMSKO	GM41373P	43	107	2.00	22	44	AUTO	26/02-B	100.900	101.800	1	44.70	644	100	P6	10.85	1	1	1225	2026-02-02	2026-02-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
445	228	1	MISKA S BEŻ	R+PET CL-80M PRT RADOMSKO	GM10683P	43	111	2.00	2	43	AUTO	25/02-E	61.800	63.300	1	34.55	833	160	P2	10.30	5	1	546	2026-02-18	2026-02-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
446	229	1	MISKA S BIAŁY	R+PET CL-80M PRT RADOMSKO	GM415	43	139	2.00	3	43	AUTO	26/09-E	61.500	63.100	1	30.73	937	160	P2	10.50	5	1	480	2026-09-18	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
448	231	1	MISKA S C.SZARY	R+PET CL-80M PRT RADOMSKO	GM 801071P; GM 81071P	43	114	2.00	6	43	AUTO	25/02-D; 26/09-F	61.200	63.500	1	30.73	937	160	P2	10.50	5	2	1340	2026-02-17	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
450	233	1	MISKA S RÓŻOWY	R+PET CL-80M PRT RADOMSKO	20-33521F PET	43	\N	3.00	17	43	AUTO	25/02-A; 26/09-G	63.500	65.000	1	34.20	840	160	P2	10.50	5	2	2675	2026-02-09	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
451	234	1	MISKA S SZARY	R+PET CL-80M PRT RADOMSKO	GM41373P	43	107	2.00	18	43	AUTO	25/02-C	61.500	63.100	1	34.55	833	160	P2	10.30	5	1	2005	2026-02-16	2026-02-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
452	235	1	MISKA S ZIELONY	R+PET CL-80M PRT RADOMSKO	GM41373P	43	107	2.00	22	43	AUTO	25/02-B; 26/09-A	60.500	62.000	1	30.46	945	160	P2	10.50	5	2	2878	2026-02-11	2026-09-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
453	236	1	MISKA S ŻÓŁTY	R+PET CL-80M PRT RADOMSKO	GM12485E	43	116	3.00	23	43	AUTO	26/09-C	61.300	62.800	1	30.81	934	160	P2	10.50	5	1	960	2026-09-17	2026-09-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
455	238	1	SLOW FIBFEEDER	RAVATHANE 130 A93 RESINEX		39	\N	\N	1	191	AUTO	26/02-A	97.400	99.100	1	50.40	571	50	P6	5.50	1	1	2284	2026-02-17	2026-02-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
456	239	1	SLOW FIBOOWL BORDOWY	HRC9480/230 KRAIBURG 95% PP TATRENIM2263 BCD 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	W4-62	15	159	2.00	4	191	AUTO	26/05-A; 26/08-D	209.000	209.400	1	61.50	447	52	KM	12.00	7, 9	2	1724	2026-05-13	2026-08-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
457	240	1	SLOW FIBOOWL BRIT ZIELONY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	GM41373P	15	107	2.00	22	191	AUTO	26/03-C	208.600	208.900	1	78.70	366	52	KM	12.00	1	1	1600	2026-03-19	2026-03-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
458	241	1	SLOW FIBOOWL BRIT ŻÓŁTY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	GM10684P	15	115	2.00	23	191	AUTO	26/03-D	211.800	211.800	1	74.70	385	52	KM	12.00	1	1	1612	2026-03-23	2026-03-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
460	243	1	SLOW FIBOOWL C.SZARY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 5%	GM80690E	15	112	2.00	6	191	AUTO	26/02-E	211.900	212.200	1	75.60	380	52	KM	11.90	2	1	1248	2026-02-02	2026-02-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
463	246	1	SLOW FIBOOWL CZERWONY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	HP400331/40	15	92	4.00	8	191	AUTO	26/03-A	210.900	210.900	1	64.60	445	52	KM	12.00	1	1	468	2026-03-17	2026-03-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
465	248	1	SLOW FIBOOWL FIOLETOWY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%; HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	W5-25	15	156	2.00	9	191	AUTO	26/01-B; 26/05-E; 26/08-C	208.600	209.000	1	61.50	447	52	KM	12.00	2, 7, 9	3	1861	2026-01-27	2026-08-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
466	249	1	SLOW FIBOOWL FUTTERHAUS C.SZARY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	GM80690E	15	112	2.00	6	191	AUTO	26/04-A	209.000	209.200	1	64.90	443	52	KM	12.00	3	1	1000	2026-04-02	2026-04-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
467	250	1	SLOW FIBOOWL GRANATOWY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	W6-69	15	158	2.00	11	191	AUTO	26/05-A; 26/09-A	207.500	207.500	1	62.20	463	52	KM	12.00	7, 9	2	3048	2026-05-15	2026-09-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
469	252	1	SLOW FIBOOWL MINI BORDOWY	HRC9480/230 KRAIBURG 95% TATREN IM2263 5%; HRC9480/230 KRAIBURG95% PP MOPLEN EP 548 R 5%	W4-62	15	159	2.00	4	198	AUTO	26/04-G; 26/09-C	106.000	106.800	1	50.40	570	44	P6	5.30	3, 4	2	1699	2026-04-16	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
454	237	1	POKRYWKA FIBOO LID FIBEEK PEŁNY	GRANSEB-80 GRANPOL	GM-32218E	\N	113	2.00	17	148	AUTO	26/08-A	26.300	26.900	2	36.40	1582	176	P5	4.60	4	1	3000	2026-08-17	2026-08-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
464	247	1	SLOW FIBOOWL EUROPRIS	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	W6-69	15	158	2.00	15	191	AUTO	26/05-A	211.700	212.000	1	59.70	482	52	KM	2.50	7	1	5040	2026-05-05	2026-05-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
468	251	1	SLOW FIBOOWL LOGO POKUSA	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 5%	W7131	15	144	3.00	22	191	AUTO	26/02-A	212.100	212.800	1	75.90	380	48	60/40/30	11.15	2	1	3000	2026-02-04	2026-02-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
474	257	1	SLOW FIBOOWL MINI RÓŻOWY	HRC94180/230 KRAIBURG 95% TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	GM-32218E	15	113	2.00	17	198	AUTO	26/04-A; 26/09-F	106.000	106.900	1	50.40	570	44	P6	5.30	3, 4	2	1794	2026-04-13	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
475	258	1	SLOW FIBOOWL MINI ZIELONY	HRC9480/230 KRAIBURG 95% TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	GM41373P	15	107	2.00	22	198	AUTO	26/04-E; 26/09-G	106.200	107.000	1	50.40	570	44	P6	5.30	3, 4	2	1452	2026-04-15	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
476	259	1	SLOW FIBOOWL MINI ŻÓŁTY	HRC9480/230 KRAIBURG 95% TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	GM10684P	15	115	2.00	23	198	AUTO	26/04-D; 260/09-H	106.000	107.000	1	50.40	570	44	P6	5.30	3, 4	2	1426	2026-04-15	2026-09-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
477	260	1	SLOW FIBOOWL RÓŻOWY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%; HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	GM-32218E	15	113	2.00	17	191	AUTO	26/01-C; 26/05-B; 26/07-A	208.000	208.300	1	64.10	450	52	KM	12.00	2, 3, 7	3	2311	2026-01-28	2026-07-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
478	261	1	SLOW FIBOOWL ZIELONY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	GM41373P; GM-43357E	15	107	2.00	22	191	AUTO	26/03-B; 26/08-B	206.500	207.000	1	64.40	447	52	KM	12.00	1, 9	2	2162	2026-03-18	2026-08-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
479	262	1	SLOW FIBOOWL ŻÓŁTY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	GM10684P	15	115	2.00	23	191	AUTO	26/01-D; 26/08-A	141.900	142.300	1	64.40	447	52	KM	12.00	2, 9	2	1312	2026-01-30	2026-08-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
481	264	1	SNACK FIBOOL JUMBO POMARAŃCZOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-20225E	18	125	4.00	16	173	AUTO	26/04-A	187.300	188.250	2	66.80	837	60	P6	12.60	8	1	500	2026-04-07	2026-04-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
482	265	1	SNACK FIBOOL JUMBO RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	173	AUTO	26/04-A	187.300	188.250	2	68.80	837	60	P6	12.60	8	1	809	2026-04-03	2026-04-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
483	266	1	SNACK FIBOOL JUMBO SOFT FUTTERHAUS NIEBIESKI	HRC9480/230 KRAIBURG	W6-253	15	\N	3.00	15	173	AUTO	26/03-A	172.200	173.100	2	86.50	332	60	P6	11.15	8	1	2040	2026-03-27	2026-03-31	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
484	267	1	SNACK FIBOOL JUMBO SOFT FUTTERHAUS RÓŻOWY	HRC9480/230 KRAIBURG	GM-32747E	15	124	4.00	17	173	AUTO	26/04-C	171.800	173.200	2	82.00	351	60	P6	11.15	8	1	2006	2026-04-02	2026-04-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
485	268	1	SNACK FIBOOL JUMBO SOFT FUTTERHAUS ŻÓŁTY	HRC9480/230 KRAIBURG	W2-73/1	15	154	3.00	23	173	AUTO	26/03-B	173.800	174.800	2	84.80	339	60	P6	11.15	8	1	2005	2026-03-31	2026-04-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
487	270	1	SNACK FIBOOL SOFT FIOLETOWY	HRC9480/230 KRAIBURG	GM-6979E	15	122	3.00	9	115	AUTO	26/09-A	65.000	67.200	2	56.90	1012	140	P2	10.00	7	1	3105	2026-09-08	2026-09-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
489	272	1	SNACK FIBOOLL NIEBIESKI	GRANSEB 80 GRANPOL	W6-125	\N	152	3.00	15	115	AUTO	26/05-B	73.200	75.600	2	37.50	1540	140	P2	11.00	8	1	1010	2026-05-20	2026-05-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
490	273	1	SNACK FIBOOLL POMARAŃCZOWY	GRANSEB 80 GRANPOL	GM-20225E	\N	125	2.00	16	115	AUTO	26/05-A	74.200	76.250	2	37.50	1540	140	P2	11.00	8	1	802	2026-05-20	2026-05-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
491	274	1	SNACK FIBOOLL SOFT FIOLETOWY	HRC9480/230 KRAIBURG	GM-6979E	15	122	3.00	9	115	AUTO	26/05-A	66.700	69.000	2	58.60	982	140	P2	10.00	8	1	800	2026-05-18	2026-05-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
492	275	1	SNACK FIBOOLL SOFT FUTTERHAUS NIEBIESKI	HRC9480/230 KRAIBURG	W6-253	15	\N	3.00	15	115	AUTO	26/03-A	66.500	68.300	2	56.20	512	140	P2	10.00	2	1	3685	2026-03-04	2026-03-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
493	276	1	SNACK FIBOOLL SOFT FUTTERHAUS RÓŻOWY	HRC9480/230 KRAIBURG	GM-32747E	15	124	3.00	17	115	AUTO	26/03-B	66.700	68.250	2	56.20	512	140	P2	10.00	2	1	3600	2026-03-06	2026-03-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
494	277	1	SNACK FIBOOLL SOFT FUTTERHAUS ŻÓŁTY	HRC9480/230 KRAIBURG	W2-73/1	15	154	3.00	23	115	AUTO	26/03-C	66.400	68.300	2	56.20	512	140	P2	10.00	2	1	3635	2026-03-11	2026-03-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
496	279	1	SNACK FIBOOLL SOFT MIĘTOWY	HRC9480/230 KRAIBURG	GM-43114E	15	121	2.00	14	115	AUTO	26/05-B; 26/06-A	68.000	69.800	2	56.80	1014	140	P2	10.00	8	2	9012	2026-05-18	2026-06-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
497	280	1	SNACK FIBOOLL ZIELONY	GRANSEB 80 GRANPOL	W7-76	\N	153	3.00	22	115	AUTO	26/05-C	73.200	75.600	2	37.50	1540	140	P2	11.00	8	1	600	2026-05-20	2026-05-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
480	263	1	SNACK FIBEEK FUTTERHAUS	GRANPOL TPE-S-GRANSEB 80G/000/139	GM-80690E	18	112	4.00	6	148	AUTO	26/05-A; 26/09-A	109.000	110.500	2	79.10	728	60	P2	7.10	8, 9	2	4282	2026-05-11	2026-09-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
486	269	1	SNACK FIBOOL SOFT EUROPRIS	HRC9480/230 KRAIBURG	GM-6979E	15	122	3.00	17	115	AUTO	26/05-A	66.700	69.000	2	58.60	984	140	P2	10.00	8	1	6912	2026-05-12	2026-05-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
488	271	1	SNACK FIBOOL SOFT MIODOWY	HRC9480/230 KRAIBURG	W2-68	15	161	3.00	23	115	AUTO	26/09-B	67.200	68.800	2	56.30	1020	140	P2	10.00	7	1	1120	2026-09-10	2026-09-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
499	282	1	SNAK FIBOOL RÓŻOWY	GRANSEB 80 GRANPOL	GM-32747E	\N	124	5.00	17	115	AUTO	26/05-E	73.500	75.450	2	38.80	1484	140	P2	11.00	8	1	1018	2026-05-22	2026-05-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
500	283	1	SZARPAK FIB BORDOWY	GPL-GRANSEB 80G/000/139 GRANPOL	W4-62	18	159	2.00	4	116	AUTO	29/09-E	158.100	158.500	1	45.10	638	40	P2	6.50	8	1	1027	2026-09-03	2026-09-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
502	285	1	SZARPAK FIB CZERWONY	GPL-GRANSEB 80G/000/139 GRANPOL	HP400331/40	18	92	2.00	8	116	AUTO	26/09-F	158.200	158.800	1	45.10	638	40	P2	6.50	8	1	1016	2026-09-04	2026-09-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
503	286	1	SZARPAK FIB FIOLETOWY	GPL-GRANSEB 80G/000/139 GRANPOL	W5-25	18	156	2.00	9	116	AUTO	26/03-F	156.900	157.500	1	43.80	657	40	P2	6.65	4	1	914	2026-03-06	2026-03-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
504	287	1	SZARPAK FIB GRANATOWY	GPL-GRANSEB 80G/000/139 GRANPOL	W6-69	18	158	2.00	11	116	AUTO	28/09-C	159.900	160.000	1	45.10	638	40	P2	6.65	8	1	1000	2026-09-01	2026-09-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
507	290	1	SZARPAK FIB NIEBIESKI	GPL-GRANSEB 80G/000/139 GRANPOL	W6-125	18	152	3.00	15	116	AUTO	26/03-E; 26/08-B	156.900	156.900	1	46.10	624	40	P2	6.65	4, 8	2	3103	2026-03-05	2026-09-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
508	291	1	SZARPAK FIB NIEBIESKI FUTTERHAUS	GPL-GRANSEB 80G/000/139 GRANPOL	W6-253	18	\N	3.00	15	116	AUTO	26/03-C	156.000	156.400	1	58.60	491	40	P2	6.65	4	1	2200	2026-03-24	2026-03-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
509	292	1	SZARPAK FIB POMARAŃCZOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-20225E	18	125	5.00	16	116	AUTO	26/03-A; 26/04-B; 26/09-G	158.000	158.600	1	45.10	638	40	P2	6.50	4, 8	3	2923	2026-03-02	2026-09-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
510	293	1	SZARPAK FIB RÓŻOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	5.00	17	116	AUTO	26/03-B; 26/09-H	158.200	158.600	1	45.10	638	40	P2	6.50	4, 8	2	2064	2026-03-03	2026-09-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
511	294	1	SZARPAK FIB RÓŻOWY FUTTERHAUS	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	5.00	17	116	AUTO	26/03-B	156.000	156.400	1	43.80	657	40	P2	6.65	4	1	2434	2026-03-19	2026-03-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
512	295	1	SZARPAK FIB SOFT FIOLETOWY	HRC9480/230 KRAIBURG	GM-6979E	15	122	3.00	9	116	AUTO	26/09-A	142.500	142.900	1	59.50	490	40	P2	6.50	8	1	1040	2026-09-09	2026-09-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
515	298	1	SZARPAK FIB SOFT MIĘTOWY	HRC9480/230 KRAIBURG	GM-43114E	15	121	3.00	14	116	AUTO	26/09-B	142.500	142.900	1	59.50	490	40	P2	6.50	8	1	1000	2026-09-10	2026-09-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
516	299	1	SZARPAK FIB ZIELONY	GPL-GRANSEB 80G/000/139 GRANPOL	W7-76	18	153	3.00	22	116	AUTO	26/04-A	158.200	158.600	1	58.00	496	40	P6	9.10	4	1	810	2026-04-01	2026-04-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
519	302	1	SZARPAK FIB ŻÓŁTY	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	116	AUTO	26/03-C; 26/08-A	157.000	157.000	1	46.10	624	40	P2	6.65	4, 8	2	1323	2026-03-04	2026-08-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
520	303	1	SZARPAK FIBSY FIOLETOWY	GPL-GRANSEB-80G/000/139	W5-25	18	156	3.00	9	200	AUTO	26/09-B	227.000	227.900	1	40.90	704	20	P6	5.00	9	1	813	2026-09-21	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
521	304	1	SZARPAK FIBSY NIEBIESKI	GPL-GRANSEB-80G/000/139	W6-125	18	152	3.00	15	200	AUTO	26/09-E	226.000	227.900	1	40.90	704	20	P6	5.00	9	1	813	2026-09-23	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
523	306	1	SZARPAK FIBSY RÓŻOWY	GPL-GRANSEB-80G/000/139	GM-32747E	18	124	4.00	17	200	AUTO	26/09-A	223.000	223.600	1	40.90	704	20	P6	5.00	9	1	801	2026-09-18	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
524	307	1	SZARPAK FIBSY SOFT FIOLETOWY	HRC9480/230 KRAIBURG	GM-6979E	15	122	2.00	9	200	AUTO	26/09-D	201.300	201.300	1	48.60	592	20	P6	4.80	9	1	700	2026-09-28	2026-09-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
527	310	1	SZARPAK FIBSY SOFT MIĘTOWY	HRC9480/230 KRAIBURG	GM-43114E	15	121	2.00	14	200	AUTO	26/09-A	202.500	202.500	1	48.60	592	20	P6	4.80	9	1	720	2026-09-24	2026-09-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
528	311	1	SZARPAK FIBSY ZIELONY	GPL-GRANSEB-80G/000/139	W6-125	18	152	3.00	22	200	AUTO	26/09-D	226.000	227.900	1	40.90	704	20	P6	5.00	9	1	740	2026-09-22	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
529	312	1	SZARPAK FIBSY ŻÓŁTY	GPL-GRANSEB-80G/000/139	W2-73/1	18	154	3.00	23	200	AUTO	26/09-C	226.300	227.800	1	40.90	704	20	P6	5.00	9	1	737	2026-09-21	2026-09-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
505	288	1	SZARPAK FIB HUSSE	GPL-GRANSEB 80G/000/139 GRANPOL	W7131	18	144	2.00	22	116	AUTO	26/10-A	154.000	154.700	1	\N	\N	40	P2	6.60	9	1	0	2026-10-13	2026-10-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
506	289	1	SZARPAK FIB JUSTRASSEL	GRANSEB-80 GRANPOL	GM-32807E	\N	102	2.00	8	116	AUTO	26/10-A	154.000	154.600	1	41.70	690	40	P2	6.60	9	1	5200	2026-10-06	2026-10-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
514	297	1	SZARPAK FIB SOFT MIODOWY	HRC9480/230 KRAIBURG	W2-68	15	161	3.00	23	116	AUTO	26/09-C	143.800	144.000	1	54.30	530	40	P2	6.50	8	1	967	2026-09-11	2026-09-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
517	300	1	SZARPAK FIB ZIOELONY	GPL-GRANSEB 80G/000/139 GRANPOL	W7-76	18	153	3.00	22	116	AUTO	26/03-D	156.200	156.600	1	43.80	657	40	P2	6.65	4	1	808	2026-03-04	2026-03-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
526	309	1	SZARPAK FIBSY SOFT MIODOWY	HRC9480/230 KRAIBURG	W2-68	15	161	2.00	23	200	AUTO	26/09-B	212.300	212.300	1	48.60	592	20	P6	4.80	9	1	711	2026-09-25	2026-09-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
531	314	1	SZCZOTKA MIEKKA ŻÓŁTY	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	W2334	15	166	2.00	23	46	AUTO	26/09-A	55.300	55.650	2	61.20	940	120	P5	6.90	4	1	3000	2026-09-23	2026-09-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
534	509	26	BOK PRAWY LEWY BIAŁY	HOSTALEN GC7260 STABILIZATOR UV 2%	HP1GA278UV	1	\N	2.00	3	\N	\N	26/08-C	14.800	16.250	4	36.72	3130	900	KM	14.05	5	1	7500	2026-08-28	2026-09-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
535	510	26	BOK PRAWY LEWY BRĄZ	HOSTALEN GC7260 STABILIZATOR UV 2%	W8-43/1	1	151	2.00	5	\N	\N	26/05-A; 26/08-B	14.800	16.200	4	36.96	3120	900	KM	14.05	5, 6	2	42500	2026-05-21	2026-08-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
536	511	26	BOK PRAWY LEWY CZARNY	HOSTALEN GC7260 STABILIZATOR UV 2%	HP99611	1	95	2.00	7	\N	\N	26/06-C; 26/09-D	14.800	16.250	4	36.72	3130	900	KM	14.05	5, 6	2	105370	2026-06-12	2026-09-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
537	512	26	BOK PRAWY LEWY GRAFIT	HOSTALEN GC7260 STABILIZATOR UV 2%	W9-67U/1	1	150	2.00	10	\N	\N	26/06-B	14.600	16.150	4	36.85	1563	900	KM	14.20	6	1	27800	2026-05-29	2026-06-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
538	513	26	BOK PRAWY LEWY GRAFITOWY	HOSTALEN GC7260 STABILIZATOR UV 2%	W9-67U/1	1	150	2.00	10	\N	\N	26/08-A	14.800	16.350	4	36.93	3120	900	KM	14.05	5	1	25000	2026-08-10	2026-08-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
539	514	26	LISTAW GRUBA GRAFIT	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	W9-67U/1	36	150	2.00	10	\N	\N	26/05-B	52.900	47.550	2	33.40	862	500	KM	28.00	7	1	10700	2026-05-27	2026-06-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
540	515	26	LISTWA CIENKA BIAŁY	SCOLEFIN 53 G 10-0 NATURAL	HP1GA278UV	36	\N	\N	3	75	AUTO	26/09-D	26.700	47.150	2	34.60	832	1500	KM	41.05	2	1	3000	2026-09-09	2026-09-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
541	516	26	LISTWA CIENKA BRĄZOWY	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	W8-43/1	36	151	2.00	5	75	AUTO	26/05-A; 26/,9-C	26.800	47.500	2	34.60	832	1500	KM	41.50	2, 7	2	17250	2026-05-20	2026-09-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
542	517	26	LISTWA CIENKA CZARNY	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	HP99611	36	95	2.00	7	75	AUTO	26-06-C; 26/08-A	26.400	46.250	2	34.80	827	1500	KM	40.60	2, 7	2	23100	2026-06-03	2026-08-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
543	518	26	LISTWA CIENKA GRAFIT	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	W9-67U/1	36	150	2.00	10	75	AUTO	26/05-B	26.800	47.550	2	33.40	862	1400	KM	39.00	7	1	10700	2026-05-27	2026-06-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
544	519	26	LISTWA CIENKA GRAFITOWY	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	W9-67U/1	36	150	2.00	10	75	AUTO	26/08-B	52.500	47.050	2	34.90	827	1500	KM	40.60	2	1	10000	2026-08-25	2026-09-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
545	520	26	LISTWA GRUBA BIAŁY	SCOLEFIN 53G 10-0 NATURAL	HP1GA278UV	36	\N	\N	3	75	AUTO	26/09-D	52.500	47.150	2	34.60	832	500	KM	27.50	2	1	3000	2026-09-09	2026-09-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
546	521	26	LISTWA GRUBA BRĄZOWA	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	W8-43/1	36	151	2.00	5	75	AUTO	26/05-A; 26/09-C	52.800	47.500	2	34.60	832	500	KM	27.50	2, 7	2	17250	2026-05-20	2026-09-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
547	522	26	LISTWA GRUBA CZARNY	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	HP99611	36	95	2.00	7	75	AUTO	26/06-C; 26/08-A	52.100	46.250	2	34.80	827	500	KM	27.50	2, 7	2	22800	2026-06-03	2026-08-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
548	523	26	LISTWA GRUBA GRAFITOWY	SCOLEFIN 53G 10-0 NATURAL STABILIZATOR UV2%	W9-67U/1	36	150	2.00	10	75	AUTO	26/08-B	52.400	47.050	2	34.90	827	500	KM	27.50	2	1	10000	2026-08-25	2026-09-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
13	532	5	CABLE LOCK ŻÓLTY	PA6 PLASTAMID B28 CR NR	W2-127L	5	142	2.00	23	\N	\N	26/06-C	40.500	41.800	2	52.50	548	400	P2	16.75	4	1	15000	2026-06-19	2026-07-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
101	463	12	ŁAPKA DE OPTRYSK POMARAŃCZ	HRC9480/230 KRAIBURG	GM-20225E	15	125	2.00	16	214	AUTO	26/03-D	6.600	8.150	2	32.25	896	500	P5	3.60	6	1	1000	2026-03-26	2026-03-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
142	333	20	MASKOWNICA MICKEY C.SZARA	PP MOPLEN EP 548R ELASTOMER RAVAGO	191385	7	190	2.00	6	\N	\N	26/10-B	250.000	250.000	1	61.50	486	18	36/37/55	4.85	2	1	1404	2026-10-07	2026-10-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
143	334	20	MASKOWNICA MICKEY J.SZARA	PP MOPLEN EP 548R ELASTOMER RAVAGO	191378	7	191	2.00	12	\N	\N	26/10-A	250.000	250.000	1	62.20	465	18	36/37/55	4.85	2	1	630	2026-10-06	2026-10-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
200	482	25	ZAŚLEPKA ASA NOWA CIEMNO SZARY	ASA LI911 NATURAL	GM-807795	31	\N	\N	6	52	AUTO	26/06-C	10.400	11.925	4	30.00	3827	600	P5	6.60	5	1	14000	2026-06-02	2026-06-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
201	483	25	ZAŚLEPKA ASA NOWA JASNO SZARA	ASA LI911 NATURAL	GM-80721B	31	126	2.00	12	52	AUTO	26/06-D	10.400	11.900	4	30.00	3827	600	P5	6.60	5	1	14000	2026-06-09	2026-06-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
202	484	25	ZAŚLEPKA ASA NOWA WANILIA	ASA LI911 NATURAL	GM-10483B	31	132	2.00	21	52	AUTO	26/06-A	10.500	12.100	4	30.10	3827	600	P5	6.60	5	1	4000	2026-06-01	2026-06-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
229	12	1	FIBOONE BIG PUPPY POARAŃCZ	HRC9480/230 KRAIBURG	GM-20225E	15	125	4.00	16	187	AUTO	26/02-A; 26/09-B	54.000	54.500	2	29.80	1930	250	P2	14.00	4, 5	2	2049	2026-02-26	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
230	13	1	FIBOONE BIG PUPPY RÓŻ	HRC9480/230 KRAIBURG	GM-32747E	15	124	5.00	17	187	AUTO	26/02-B; 26/04-A	53.400	54.250	2	33.25	1732	250	P2	14.00	5, 6	2	924	2026-02-26	2026-04-17	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
247	30	1	FIBOONE DENTAL POMARAŃCZ	GPL-GRANSEB 80G/000/139 GRANPOL	GM-20225E	18	125	5.00	16	110	AUTO	26/03-D	107.900	108.850	2	53.20	541	100	P6	11.50	2	1	1500	2026-03-26	2026-03-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
248	31	1	FIBOONE DENTAL RÓZOWY	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	110	AUTO	26/03-B	108.500	109.350	2	53.20	541	100	P6	11.50	2	1	1613	2026-03-20	2026-03-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
252	35	1	FIBOONE PUPPY RÓŻ	HRC9480/230 KRAIBURG	GM-32747E	15	124	5.00	17	175	AUTO	26/04-A	14.000	14.400	2	37.64	1530	500	P5	7.15	6	1	1558	2026-04-19	2026-04-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
254	37	1	FIBOOWL L C.NIEBIESKI	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	GM-53281E	15	123	2.00	24	154	AUTO	26/01-B	244.400	253.400	1	45.50	633	25	P2	6.75	2	1	555	2026-01-23	2026-01-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
256	39	1	FIBOOWL L CIEMNO NIEBIESKI	HRC9480/230 KRAIBURG	GM-53281E	15	123	2.00	24	154	AUTO	26/06-B	249.000	249.800	1	50.60	569	30	P2	7.95	8	1	607	2026-06-10	2026-06-11	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
258	41	1	FIBOOWL L FUTTERHAUS RÓŻ	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	GM-32218E	15	113	2.00	17	154	AUTO	26/01-A; 26/09-B	240.000	240.000	1	46.50	620	30	P2	8.00	2, 9	2	1620	2026-01-20	2026-09-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
264	47	1	FIBOOWL M C.NIEBIESKI	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%; HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM-53281E	15	123	2.00	24	151	AUTO	26/01-C; 26/04-B	126.100	126.500	1	45.60	631	40	P5	5.00	3, 4	2	2000	2026-01-27	2026-04-08	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
265	48	1	FIBOOWL M C.ZIELONY	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 5%	GM43107E	15	120	2.00	25	151	AUTO	26/01-D	122.300	123.000	1	48.20	597	40	P5	5.10	3	1	1000	2026-01-28	2026-01-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
274	56	1	FIBOOWL S BUTELKOWA ZIELEŃ	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM43107E	15	120	2.00	22	146	AUTO	26/07-G	57.600	58.400	1	32.30	890	175	P6	10.70	3	1	400	2026-07-07	2026-07-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
275	57	1	FIBOOWL S C.NIEBIESKI	HRC9480/230 KRAIBURG 95% PP TATREN IM 2263 BCD 5%	GM-53281E	15	123	2.00	24	146	AUTO	26/07-A	56.400	57.100	1	31.40	912	175	P6	10.70	3	1	800	2026-07-03	2026-07-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
289	72	1	FIBSY FUTTERHAUS ŻÓLTY	TPE-S-GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	171	AUTO	26/04-C	230.900	233.900	1	41.20	700	20	P6	5.00	7	1	1900	2026-04-15	2026-04-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
291	74	1	FIJOO C.NIEBIESKI	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%	GM-53281E	15	123	3.00	24	\N	\N	26/03-A	81.100	82.400	2	78.50	366	80	P6	7.20	7	1	800	2026-03-27	2026-03-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
305	88	1	FLIP FIBOOWL BUTELKOWA ZIELEŃ	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	GM43107E	15	120	2.00	22	199	AUTO	26/08-A	130.500	130.500	1	50.10	574	48	P6	7.05	9	1	528	2026-08-10	2026-08-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
306	89	1	FLIP FIBOOWL C.NIEBIESKI	HRC9480/230 KRAIBURG 90% PP MOPLEN EP 548 R 10%	GM-53281E	15	123	2.00	24	199	AUTO	26/08-E	133.200	133.200	1	56.00	514	48	P6	7.05	9	1	707	2026-08-13	2026-08-13	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
318	100	1	FRINGOO MINI POMARAŃCZ	GRANSEB-80 GRANPOL	GM-20225E	\N	125	3.00	16	172	AUTO	26/07-C	58.600	62.500	1	36.60	786	120	P2	7.55	4	1	1098	2026-07-27	2026-07-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
331	114	1	FRISBOO MINI POMARAŃCZ	GPL-GRANSEB 80G/000/139 GRANPOL; GRANPOL-TPE-S GPL-GRANSEB-80G/000/139-NATURAL	GM-20225E	18	125	4.00	16	203	AUTO	26/04-D; 26/09-B	53.000	57.200	1	30.87	935	60	P6	3.50	5, 6	2	1833	2026-04-03	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
343	126	1	LICK FIBOOWL BUTELKOWA ZIELEŃ	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM43107E	15	120	2.00	22	191	AUTO	20/07-D	142.600	143.500	1	50.70	568	40	KM	7.40	9	1	760	2026-07-28	2026-07-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
344	127	1	LICK FIBOOWL C.NIEBIESKI	HRC9480/230 KRAIBURG 50% HRC9480/451 KRAIBURG 50%; HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM-53281E	15	123	2.00	24	191	AUTO	26/03-C; 26/04-F; 20/07-E	141.800	142.000	1	50.70	568	40	KM	7.40	1, 4, 9	3	2054	2026-03-30	2026-07-30	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
348	131	1	LICK FIBOOWL MINI C.ZIELONY	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM43107E	15	120	2.00	25	198	AUTO	26/04-D	72.000	72.400	1	35.40	508	32	P6	3.25	4	1	525	2026-04-20	2026-04-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
361	144	1	LOLLIPOP MINI C.NIEBIESKI	HRC9480/230 KRAIBURG	GM-53281E	15	123	2.00	24	109	AUTO	26/08-A	44.100	44.600	1	34.68	830	175	P2	8.50	6	1	1076	2026-08-07	2026-08-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
373	156	1	LOLLIPOP WALLY C. NIEBIESKI	HRC9480/230 KRAIBURG	GM 53281E	15	123	2.00	24	204	AUTO	26/09-I	128.300	129.100	1	43.50	662	38	P5	5.50	1	1	1005	2026-09-22	2026-09-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
375	158	1	LOLLIPOP WALLY C.ZIELONY	HRC9480/230 KRAIBURG	GM43107E; GM 43107E	15	120	2.00	25	204	AUTO	26/05-B; 26/09-H	128.000	128.900	1	43.50	662	38	P5	5.50	1, 3	2	1340	2026-05-28	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
384	167	1	MATA 32x32 C.NIEBIESKI	HRC9480/230 KRAIBURG	GM-53281E	15	123	2.00	24	42	AUTO	26/06-A	214.600	214.600	1	53.30	538	80	P6	19.05	8	1	508	2026-06-01	2026-06-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
387	170	1	MATA 32x32 CIEMNO SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	42	AUTO	26/08-c	250.000	250.000	1	44.80	642	80	p6	19.05	9	1	1500	2026-08-31	2026-09-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
390	173	1	MATA 32x32 FUTTERHAUS C.SZ	HRC9480/230 KRAIBURG	GM-80690E	15	112	2.00	6	42	AUTO	26/02-A	232.600	233.000	1	42.20	682	20	32/32/9	4.90	8	1	800	2026-02-24	2026-02-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
391	174	1	MATA 32x32 FUTTERHAUS RÓŻ	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	42	AUTO	26/02-C	233.100	233.700	1	42.30	680	20	32/32/9	4.90	8	1	800	2026-02-26	2026-02-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
394	177	1	MATA 32x32 JASNO SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	12	42	AUTO	26/06-B; 26/08-A	250.000	250.000	1	44.80	642	80	P6	19.05	8, 9	2	2511	2026-06-02	2026-08-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
397	180	1	MATA 47x30 CIEMNO SZARY	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	159	AUTO	26/08-A	400.000	400.300	1	55.80	516	20	FIBOO	8.20	9	1	920	2026-08-20	2026-08-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
398	181	1	MATA 47x30 CIEMNO SZARY FUTTERHAS	HRC9480/230 KRAIBURG	GM-80690E	15	112	2.00	6	159	AUTO	26/08-A	400.000	400.300	1	55.80	516	20	FIBOO	8.20	9	1	1000	2026-08-19	2026-08-20	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
401	184	1	MATA 47x30 FUTTERHAUS C.SZ	HRC9480/230 KRAIBURG	GM80690E	15	112	2.00	6	159	AUTO	26/03-B	398.700	400.000	1	65.90	437	110	KM	\N	8	1	470	2026-03-02	2026-03-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
405	188	1	MATA 47x30 JASNO SZARY	HRC9480/230 KRAIBURG	GM 80295	15	106	2.00	12	159	AUTO	26/08-C	400.000	400.300	1	56.20	512	20	FIBOO	8.20	9	1	860	2026-08-25	2026-08-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
406	189	1	MATA 47x30 RÓZOWY	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	159	AUTO	26/08-B	400.000	400.300	1	55.80	516	20	FIBOO	8.20	9	1	910	2026-08-24	2026-08-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
412	195	1	MATA FIBLITTER 44x44 FIOLET	HRC9480/230 KRAIBURG 80% PP TATREN IM2263 BCD 20%	W5-25	15	156	2.00	9	221	AUTO	26/07-F	0.450	0.450	1	50.70	568	15	FIBOO	7.75	9	1	518	2026-07-23	2026-07-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
417	200	1	MATA FISHKA C.NIEBIESKI	HRC9480/230 KRAIBURG	GM-535281E	15	\N	2.00	24	205	AUTO	26/10-A	61.000	61.700	1	39.40	730	75	P5	4.75	3	1	520	2026-10-08	2026-10-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
427	210	1	MATA LOLLIPOP MINI RÓŻ	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	109	AUTO	26/01-A	45.200	45.700	1	36.00	800	175	P5	8.05	4	1	1005	2026-01-14	2026-01-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
431	214	1	MATA LOLLIPOP STICKY RÓŻ	HRC9480/230 KRAIBURG	GM-32218E	15	113	2.00	17	185	AUTO	26/02-A	128.800	129.400	1	49.10	586	32	P5	4.35	4	1	1035	2026-02-11	2026-02-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
433	216	1	MATA POD MISKI SZAROFIOLETOWY	DRYFLEX-UV-403731	W9-240	57	\N	2.00	26	42	AUTO	26/08-A	250.000	250.000	1	52.80	545	15	FIBOO	4.30	8	1	255	2026-08-25	2026-08-25	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
434	217	1	MATA POD MISKI SZAROZIELONY	DRYFLEX-UV-403731	C4146	57	185	2.00	27	42	AUTO	26/08-C	250.000	250.000	1	52.80	545	15	FIBOO	4.30	8	1	255	2026-08-27	2026-08-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
436	219	1	MISKA L CIEMNO SZARY	R+PET CL-80M PRT RADOMSKO	GM 81071P	43	114	2.00	6	45	AUTO	26/06-C	154.600	154.800	1	45.20	637	46	P7	7.65	2	1	1000	2026-06-03	2026-06-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
439	222	1	MISKA M C.NIEBIESKI	R+PET CL-80M PRT RADOMSKO	GM51519P	43	109	2.00	24	44	AUTO	26/02-D	101.600	102.500	1	44.70	644	100	P6	10.85	1	1	600	2026-02-04	2026-02-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
440	223	1	MISKA M C.SZARA	R+PET CL-80M PRT RADOMSKO	GM 81071P	43	114	2.00	6	44	AUTO	26/02-E	101.900	102.800	1	44.70	644	100	P6	10.85	1	1	500	2026-02-04	2026-02-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
442	225	1	MISKA M J.NIEBIESKI	R+PET CL-80M PRT RADOMSKO	GM51745P	43	127	2.00	28	44	AUTO	26/02-C	101.800	102.700	1	44.70	644	100	P6	10.85	1	1	800	2026-02-03	2026-02-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
447	230	1	MISKA S C.NIEBIESKI	R+PET CL-80M PRT RADOMSKO	GM51519P	43	109	2.00	24	43	AUTO	26/09-B	61.500	63.000	1	30.46	945	160	P2	10.50	5	1	960	2026-09-16	2026-09-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
449	232	1	MISKA S JASNO NIEBIESKI	R+PET CL-80M PRT RADOMSKO	GM-53578E	43	187	2.00	28	43	AUTO	26/09-D	61.700	63.200	1	30.46	945	160	P2	10.50	5	1	1005	2026-09-17	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
459	242	1	SLOW FIBOOWL C.NIEBIESKI	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	GM-53281E	15	123	2.00	24	191	AUTO	26/01-A; 26/05-C; 29/09-B	207.000	207.500	1	62.20	463	52	KM	12.00	2, 7, 9	3	1428	2026-01-27	2026-05-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
461	244	1	SLOW FIBOOWL C.ZIELONY	HRC9480/230 KRAIBURG 95% PP TATREN IM2263 BCD 5%	GM43107E	15	120	2.00	25	191	AUTO	26/05-D	219.200	212.900	1	60.70	948	52	KM	12.00	7	1	516	2026-05-19	2026-05-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
462	245	1	SLOW FIBOOWL CIEMNO ZIELONY	HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548 R 5%	GM43107E	15	120	2.00	25	191	AUTO	26/08-E	208.400	208.400	1	61.50	447	52	KM	12.00	9	1	724	2026-08-07	2026-08-10	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
470	253	1	SLOW FIBOOWL MINI C.NIEBIESKI	HRC9480/230 KRAIBURG 95%% TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	GM-53281E	15	123	2.00	24	198	AUTO	26/04-C; 26/09-A	107.300	107.700	1	50.40	570	44	P6	5.30	3, 4	2	1872	2026-04-14	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
471	254	1	SLOW FIBOOWL MINI C.ZIELONY	HRC9480/230 KRAIBURG 95% TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	GM43107E; CGM43107E	15	120	2.00	25	198	AUTO	26/04-F; 26/09-D	106.200	106.900	1	50.40	570	44	P6	5.30	3, 4	2	1667	2026-04-16	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
472	255	1	SLOW FIBOOWL MINI FIOLET	HRC9480/230 KRAIBURG 95% TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	W5-25	15	156	2.00	9	198	AUTO	26/04-B; 26/09-E	106.000	106.900	1	50.40	570	44	P6	5.30	3, 4	2	1740	2026-04-14	2026-09-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
473	256	1	SLOW FIBOOWL MINI GRANAT	HRC9480/230 KRAIBURG 95% TATREN IM2263 5%; HRC9480/230 KRAIBURG 95% PP MOPLEN EP 548R 5%	W6-69	15	158	2.00	11	198	AUTO	26/04-H; 26/09-B	106.500	107.000	1	50.40	570	44	P6	5.30	3, 4	2	1272	2026-04-17	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
495	278	1	SNACK FIBOOLL SOFT KORALOWY	HRC9480/230 KRAIBURG	W4-154U	15	160	3.00	29	115	AUTO	26/05-C	67.600	69.250	2	64.30	895	140	P2	10.00	8	1	755	2026-05-19	2026-05-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
498	281	1	SNACK FIBOOLL ŻÓLTY	GRANSEB 80 GRANPOL	W2-73/1	\N	154	3.00	23	115	AUTO	26/05-D	73.500	75.450	2	37.50	1540	140	P2	11.00	8	1	1005	2026-05-21	2026-05-21	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
501	284	1	SZARPAK FIB BUTELKOWA ZIELEŃ	GPL-GRANSEB 80G/000/139 GRANPOL	GM43107E	18	120	2.00	22	116	AUTO	29/09-D	157.400	157.500	1	45.10	638	40	P2	6.50	8	1	1014	2026-09-02	2026-09-03	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
513	296	1	SZARPAK FIB SOFT KORALOWY	HRC9480/230 KRAIBURG	W4-154U	15	160	3.00	29	116	AUTO	26/09-D	143.200	143.700	1	53.90	534	40	P2	6.50	8	1	1000	2026-09-15	2026-09-16	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
518	301	1	SZARPAK FIB ŻÓLTY FUTTERHAUS	GPL-GRANSEB 80G/000/139 GRANPOL	W2-73/1	18	154	3.00	23	116	AUTO	26/03-D	159.000	159.300	1	58.50	490	40	P2	6.65	4	1	2200	2026-03-27	2026-04-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
522	305	1	SZARPAK FIBSY POMARAŃCZ	GPL-GRANSEB-80G/000/139	GM-20225E	18	125	4.00	16	200	AUTO	26/09-F	224.000	225.900	1	40.90	704	20	P6	5.00	9	1	815	2026-09-24	2026-09-24	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
525	308	1	SZARPAK FIBSY SOFT KORALOWY	HRC9480/230 KRAIBURG	W4-154U	15	160	2.00	29	200	AUTO	26/09-C	203.000	203.000	1	48.60	592	20	P6	4.80	9	1	700	2026-09-28	2026-09-28	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
1	508	2	OBUDOWA DUŻA	ABS MAGNUM 8391 NEXEO PLASTICS	SAN9017/16	59	88	1.00	7	132	AUTO	26/10-A	143.000	143.600	1	47.00	612	44	KM	7.50	2	1	1012	2026-10-06	2026-10-06	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
3	506	3	PIERŚCIEŃ MOB-G0445-02	POM C27N RESINEX	GM-378E	32	104	2.00	7	22	AUTO	26/09-A	10.600	10.575	4	31.74	3629	1400	P1	16.00	5	1	13000	2026-09-29	2026-10-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
4	507	3	PŁYTKA KORPUSU	ABS HI121H RESINEX	GM-80669B	29	100	2.00	6	23	AUTO	26/09-A	3.200	3.225	4	37.42	3078	5000	P1	17.00	5	1	13000	2026-09-25	2026-09-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
20	347	6	NOGA REGULATORA	RESINEX-ABS HI121H NATURAL; ABS HF380 WHITE RESINEX	W9-36; W9-36U	29	147	2.00	18	32	AUTO	26/04-B; 26/07-C	21.900	42.200	1	33.45	860	150	P2	4.10	6	2	9820	2026-04-29	2026-08-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
21	348	6	PLECY REGULATORA	RESINEX-ABS HI121H NATURAL; ABS HF380 WHITE RESINEX	W9-36; W9-36U	29	147	2.00	18	32	AUTO	26/04-B; 26/07-C	16.500	42.200	1	33.45	860	150	P2	4.10	6	2	10100	2026-04-29	2026-05-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
30	546	8	SPINKA /KLIPS :MCLIP	PA6 BEZ WŁÓKNA PLASTAMID 6 B28 CR	HP99611 2%	5	95	2.00	7	\N	\N	26/04-A	4.400	4.386	7	30.95	6513	330	P2	15.10	5	1	50100	2026-04-12	2026-04-15	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
31	352	9	46L PA6	TEREZ B 305 NATURAL	HP99611	23	95	1.00	7	83	AUTO	26/05-A; 26/06-A; 26/09-A	1.300	1.516	32	20.00	46080	\N	KM	30.00	1, 8, PAWEŁ	3	807500	2026-05-22	2026-10-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
33	354	9	46PL PP	K295 BCD	W9-60U	21	146	1.00	18	105	AUTO	26/02-A	1.900	2.088	8	20.43	1409	\N	KM	28.00	5	1	60000	2026-02-27	2026-03-04	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
34	355	9	56L PA6	TEREZ B 305 NATURAL	HP99611	23	95	1.00	7	84	AUTO	26/05-B; 26/07-A; 26/10-A	2.200	2.425	32	23.30	39550	\N	KM	\N	1, 7, 8	3	717000	2026-05-25	2026-10-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
35	356	9	GM PA6	TEREZ B 305 NATURAL	HP99611	23	95	1.00	7	\N	\N	26/09-A	1.800	1.969	32	21.80	42275	\N	KM	\N	2	1	292000	2026-09-23	2026-09-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
36	357	9	GM PP	PP K295	W9-60U	\N	146	1.00	18	\N	\N	26/09-A	1.400	1.634	32	21.30	43300	\N	KM	\N	2	1	290000	2026-09-29	2026-10-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
37	358	9	GMPA	TEREZ B 305 NATURAL	HP99611	23	95	1.00	7	\N	\N	26/02-A	1.400	1.516	32	28.30	1017	\N	KM	30.00	1	1	105000	2026-02-19	2026-02-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
38	359	9	GMPP	K295 BCD	W9-60U	21	146	1.00	18	\N	\N	26/02-B	1.400	1.516	32	28.10	1025	\N	KM	30.00	1	1	201000	2026-02-23	2026-02-26	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
46	534	11	091002 V1 PULLBLOC DIN 18L	POM C27 RESINEX	GM378E	\N	104	2.00	7	\N	\N	26/03-B	6.100	6.950	6	21.44	1343	1800	P2	11.75	6	1	10000	2026-03-03	2026-03-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
47	535	11	091012 V1 PULLBLOC DIN 18R	POM C27 RESINEX	GM378E	\N	104	2.00	7	\N	\N	26/03-B	6.100	6.950	6	21.44	1343	1800	P2	11.75	6	1	10000	2026-03-03	2026-03-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
48	536	11	093002 V1 SLIDEBLOC DIN 18L	POM C27 RESINEX	GM378E	\N	104	1.00	7	\N	\N	26/03-A; 26/07-A	6.100	34.700	1	19.40	558	1800	P2	11.75	3, 6	2	10000	2026-02-27	2026-07-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
49	537	11	093012 V1 SLIDEBLOC DIN 18R	POM C27 RESINEX	GM378E	\N	104	1.00	7	\N	\N	26/02-A; 26/02-B; 26/03-A; 26/03-B; 26/07-A	6.100	8.675	4	19.40	2234	1800	P2	11.75	3, 6	5	239600	2026-02-05	2026-07-22	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
51	539	11	095003-8 V2 8x8 mm L 095013-8 V2 8x8 mm R	PA6 GF30% PLASTAMID 6-B28-G6	GM378E	2	104	2.00	7	\N	\N	26/06-A	9.700	10.000	2	34.40	1674	1300	P2	13.20	3	1	10000	2026-06-17	2026-06-23	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
55	543	11	PULLBLOC 091002 V1 DIN 18L	POM C27 RESINEX	GM378E	\N	104	1.00	7	\N	\N	26/08-A	6.200	7.060	5	21.80	6600	1800	P2	11.80	6	1	20000	2026-08-26	2026-09-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
56	544	11	SLIDEBLOC 093012 V1 DIN 18R	POM C27 RESINEX	GM378E	\N	104	1.00	7	\N	\N	26/08-A	6.100	7.060	5	21.80	6600	1800	P2	11.80	6	1	80000	2026-08-26	2026-09-07	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
116	525	15	RAIS UCHWYT 3 PP	100% PRZEMIAŁ PP	GM-378E	\N	104	2.00	7	\N	\N	26/01-A	13.000	14.550	2	68.10	423	1700	P1	23.10	4	1	12000	2026-01-27	2026-02-02	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
117	526	15	RAIS UCHWYT 4 PP	PP COPO IM 2263BCD	GM-378E	\N	104	2.00	7	\N	\N	26/04-A	25.200	26.700	2	43.40	1327	900	P1	23.60	4	1	6000	2026-04-24	2026-04-27	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
118	527	15	UCHWYT 3 OBTRYSK	TF60QD-LCN KRAIBURG	HP 400331/40	\N	92	2.00	8	\N	\N	26/06-A	16.800	17.900	2	38.70	750	1300	P1	23.00	3	1	2050	2026-06-08	2026-06-09	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
119	528	15	UCHWYT 3 PP	PP COPO IM 2263BCD	GM-378E	\N	104	2.00	7	\N	\N	26/06-A	12.600	14.100	2	43.90	1312	1700	P1	23.10	3	1	2500	2026-06-01	2026-06-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
121	317	16	BETATIGER RECHTS 7501 BETATIGER LINKS 7502	PA6+50GF-PLASTAMID 6B1 G10 BK	HP99611	4	95	2.00	7	189	AUTO	26/01-A; 26/07-A	9.200	11.100	2	28.56	1008	1800	P2	17.00	5, 6	2	10000	2026-01-26	2026-07-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
123	319	16	ECKVERBINDER (1) 7202	PLASTAMID 6 NATURAL B28 G5	20-91568F PA	3	170	2.00	3	139	AUTO	26/01-A	12.400	16.400	1	17.51	1644	1400	P1	19.00	6	1	12000	2026-01-29	2026-02-05	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
124	320	16	ECKVERBINDER (3) 12_7202	PLASTAMID 6 NATURAL B28 G5	20-91568F PA	3	170	2.00	3	139	AUTO	26/05-A	12.900	17.000	1	19.46	1480	1400	P1	19.00	5	1	12000	2026-05-08	2026-05-14	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
126	322	16	ECKVERBINDER 12_7202	PA6+25GF PLASTAMID 6 NATURAL B28 G5	20-91568FPA; 20-91568F PA	3	170	2.00	3	139	AUTO	26/06-A; 26/09-A	12.800	16.900	1	35.40	820	1400	P1	19.00	4, 6	2	24600	2026-06-26	2026-09-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
131	327	16	ECKVERBINER (3) 7202	PLASTAMID 6 NATURAL B28 G5	20-91568F PA	3	170	2.00	3	\N	\N	26/03-A	12.800	16.700	1	17.74	1623	1400	P1	19.00	6	1	12000	2026-03-13	2026-03-19	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
234	17	1	FIBOONE DENTAL EUROPLIS	GPL-GRANSEB 80G/000/139 GRANPOL	GM-32747E	18	124	4.00	17	110	AUTO	26/04-A	108.200	109.000	2	41.20	1398	100	P2	11.45	7	1	6300	2026-04-27	2026-04-29	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
530	313	1	SZCZOTKA MIEKKA EUROPRIS	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 10%	W2334	15	166	2.00	16	46	AUTO	26/05-B	55.400	55.700	2	56.50	1020	120	P5	6.85	3	1	7080	2026-05-12	2026-05-18	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
532	315	1	SZCZOTKA MIĘKKA HAPPY DOG	HRC9480/230 KRAIBURG 90% PP MOPLEN EP548 R 10 %	W6-69	15	158	2.00	15	152	AUTO	26/09-A	55.600	55.650	2	71.50	800	84	P5	\N	4	1	5273	2026-09-25	2026-10-01	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
533	316	1	SZCZOTKA TWARDA	HRC9480/230 KRAIBURG 90% PP TATREN IM2263 BCD 10%	GM 80295	15	106	2.00	18	46	AUTO	26/05-A	55.200	55.600	2	56.50	1020	120	P5	6.85	3	1	1726	2026-05-11	2026-05-12	\N	2026-10-16 06:19:15.934581+00	2026-10-16 06:19:15.934581+00
\.


--
-- Data for Name: receipt_lines; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.receipt_lines (id, receipt_id, material_id, qty_kg, unit_price, lot, notes) FROM stdin;
4	5	2	1000.000	11.4000	\N	\N
5	6	1	500.000	5.8000	\N	\N
\.


--
-- Data for Name: receipts; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.receipts (id, number, supplier_id, supplier_name, doc_date, delivery_doc, order_ref, notes, created_by, received_by, status, realized_at, created_at) FROM stdin;
3	PZ/2026/001	\N	\N	2026-09-29	\N	\N	\N	\N	\N	OTWARTY	\N	2026-09-29 09:12:42.338556+00
4	PZ/2026/002	\N	\N	2026-09-30	\N	\N	\N	\N	\N	OTWARTY	\N	2026-09-30 13:41:20.234075+00
5	PZ/2026/003	8	RESINEX	2026-10-01					\N	OTWARTY	\N	2026-10-01 09:16:18.859197+00
6	PZ/2026/004	10	PRT RADOMSKO	2026-10-01					\N	OTWARTY	\N	2026-10-01 09:23:22.379215+00
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: magazyn_app
--

COPY public.suppliers (id, ordinal, name, short_name, supplier_no, material_type, address, postal_code, city, country, nip, phone, website, payment_terms, notes, created_at, updated_at) FROM stdin;
1	1	POLIMER PROJEKT Sp. z o.o.	POLIMER	DT001	TWORZYWO	ul. Obrońców Tobruku 21	61-695	Poznań	Polska	7811940812	48575511412	www.polimerprojekt.pl	60 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
2	2	KRAIBURG TPE GmbH&Co	KRAIBURG	DT002	TWORZYWO	Friedrich-Schmidt-Str. 2	84478	Waldkraiburg	Niemcy				60 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
3	3	GRANPOL Sp. Z o.o.	GRANPOL	DT003	TWORZYWO	uL. Jana Pawła II 2a	87-853	Kruszyn	Polska	8881003651	48 54 2528388	www.granpol.com.pl	90 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
4	4	BCD Polymers Sp. z o.o.	BCD	DT004	TWORZYWO	ul. Obornicka 39	62-002	Suchy Las	Polska	7772903697	61 895 65 80	www.bcd-polymers.pl			2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
5	5	TER Plastics	TER	DT005	TWORZYWO	ul. Innowacyjna 8	36-060	Glogów Malopolski	Polska	5170366748	17 773 53 00	www.terplastics.pl	30 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
6	6	EMIPAK Jarosław Stoliński	EMIPAK	DT006	TWORZYWO	Sielec 6	88-160	Janikowo	Polska	5571452028	48601997647	https://emipak.pl/			2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
7	7	EKO BASKET	EKOB	DT007	TWORZYWO	ul. Goplan 12	52-340	Wrocław	Polska	8992733080					2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
8	8	RESINEX	RESINEX	DT008	TWORZYWO	ul. Powązkowska 44C	01-797	Warszawa	Polska	6762016988					2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
9	9	PROGRESS POLYMER COMPOUNDS Julia Trzebuniak	PROGRESS	DT009	TWORZYWO	ul. Krapokowicka 15b	45-760	Opole	Polska	6472486421					2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
10	10	PRT RADOMSKO	RADOMSKO	DT010	TWORZYWO	Ul. Geodetów 8	97-500	Radomsko	Polska	7773261798	44 / 3072 - 603	www.petrecyclingteam.eu	30 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
11	11	Jakub Mejer Argus	ARGUS	DT011	TWORZYWO	UL. Stoczniowców 8	84-230	Rumia	Polska	9581266890			45 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
12	12	PLASTpro	PLASTRO	DT012	TWORZYWO	ul. Azotowa 15 B	41-50	Chorzów	Polska	6272773392	48664995559	http://plastpro.pl/	30 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
13	13	KGL	KGL	DT013	TWORZYWO	Klaudyn, Gen. W.Sikorskiego 17	05-080	Izabelin	Polska	1181624643			30 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
14	14	EKOCHEM	EKOCHEM	DT014	TWORZYWO										2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
15	15	HEXPOL	HEXPOL	DT015	TWORZYWO	Max-Planck-Str. 3	96215	Lichtenfels	Niemcy						2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
16	16	NEXEO PLASTICS	NEXEO	DT016	TWORZYWO										2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
17	17	GRUPA AZOTY	AZOTY	DT017	TWORZYWO										2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
18	18	Plastics Solution	PLASTICS	DT018	TWORZYWO	ul. Franklina Roosevelta 120	62-200	Gniezno	Polska	9532678807					2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
19	19	PLASTOPLAN POLSKA Sp. Z o.o.	PLASTOPLAN	DT019	TWORZYWO	Al. Księcia J. Poniatowskiego 1	03-901	Warszawa	Polska	1080010158	222959231				2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
20	20	PACYGA	PACYGA	DT020	TWORZYWO	Poleczki 23	02-822	Warszawa	Polska						2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
21	21	A&P	A&P	DT021	TWORZYWO										2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
22	22	H&Z	H&Z	DT022	TWORZYWO										2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
23	23	KIPIOT	KIPIOT	DT023	TWORZYWO										2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
24	24	BENVIC	BENVIC	DT024	TWORZYWO	Poleczki 23	02-822	Warszawa	Polska						2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
29	25	ULTRA POLYMERS	ULTRA POLYMERS	DT025	TWORZYWO	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-09-25 14:40:57.734205+00	2026-09-25 14:40:57.734205+00
25	1	LIFOCOLOR Farbplast Sp. Z o.o.	LIFOCOLOR	DB001	BARWNIK	ul. B. Raczkowskiego 2	85-862	Bydgoszcz	Polska	9532191399	+48 52 323 81 60	www.lifocolor.de/pl	30 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:44:04.469495+00
26	2	GABRIEL CHEMIE	GABRIEL	DB002	BARWNIK	ul. Obywatelska 128/152	94-104	Łódź	Polska	5342284782	42 253 73 55	www.gabriel-chemie.com/	30 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:44:04.469495+00
27	3	GM COLOR	GM	DB003	BARWNIK	ul.Wojska Polskiego 65A	85-825	Bydgoszcz	Polska	9671196532	52 515 35 35	office@gmcolor.pl	30 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:44:04.469495+00
28	4	WEST sp. Z o.o.	WEST	DB004	BARWNIK	ul. Fabryczna 4	62-020	Gortatowo	Polska	7772341472	61 817 33 16		45 dni		2026-09-25 14:40:57.734205+00	2026-09-25 14:44:04.469495+00
35	5	COLOR TONE (wymaga uzupełnienia)	COLOR TONE	DB005	BARWNIK	\N	\N	\N	\N	\N	\N	\N	\N	Dodany z inwentury 09.2026 — uzupełnić: pełną nazwę firmy, adres, NIP, telefon, stronę www, warunki płatności oraz osobę kontaktową.	2026-09-29 06:59:47.446517+00	2026-09-29 06:59:47.446517+00
36	6	COLOR PLAST (wymaga uzupełnienia)	COLOR PLAST	DB006	BARWNIK	\N	\N	\N	\N	\N	\N	\N	\N	Dodany z inwentury 09.2026 — uzupełnić: pełną nazwę firmy, adres, NIP, telefon, stronę www, warunki płatności oraz osobę kontaktową. W zamówieniach występuje z barwnikami UNIWERS.	2026-09-29 06:59:47.446517+00	2026-09-29 06:59:47.446517+00
37	7	GLOBAL COLORS (wymaga uzupełnienia)	GLOBAL COLORS	DB007	BARWNIK	\N	\N	\N	\N	\N	\N	\N	\N	Dodany z inwentury 09.2026 — uzupełnić: pełną nazwę firmy, adres, NIP, telefon, stronę www, warunki płatności oraz osobę kontaktową.	2026-09-29 06:59:47.446517+00	2026-09-29 06:59:47.446517+00
\.


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.clients_id_seq', 26, true);


--
-- Name: colors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.colors_id_seq', 29, true);


--
-- Name: contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.contacts_id_seq', 19, true);


--
-- Name: inventories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.inventories_id_seq', 5, true);


--
-- Name: inventory_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.inventory_lines_id_seq', 1102, true);


--
-- Name: machine_doc_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.machine_doc_lines_id_seq', 4, true);


--
-- Name: machine_docs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.machine_docs_id_seq', 8, true);


--
-- Name: materials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.materials_id_seq', 196, true);


--
-- Name: mold_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.mold_events_id_seq', 2, true);


--
-- Name: mold_photos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.mold_photos_id_seq', 4, true);


--
-- Name: molds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.molds_id_seq', 231, true);


--
-- Name: order_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.order_lines_id_seq', 709, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.orders_id_seq', 355, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.products_id_seq', 548, true);


--
-- Name: receipt_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.receipt_lines_id_seq', 5, true);


--
-- Name: receipts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.receipts_id_seq', 6, true);


--
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: magazyn_app
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 37, true);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (key);


--
-- Name: clients clients_code_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_code_key UNIQUE (code);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: colors colors_code_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT colors_code_key UNIQUE (code);


--
-- Name: colors colors_name_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT colors_name_key UNIQUE (name);


--
-- Name: colors colors_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.colors
    ADD CONSTRAINT colors_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: inventories inventories_number_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_number_key UNIQUE (number);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (id);


--
-- Name: inventory_lines inventory_lines_inventory_id_material_id_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventory_lines
    ADD CONSTRAINT inventory_lines_inventory_id_material_id_key UNIQUE (inventory_id, material_id);


--
-- Name: inventory_lines inventory_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventory_lines
    ADD CONSTRAINT inventory_lines_pkey PRIMARY KEY (id);


--
-- Name: machine_doc_lines machine_doc_lines_doc_id_material_id_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_doc_lines
    ADD CONSTRAINT machine_doc_lines_doc_id_material_id_key UNIQUE (doc_id, material_id);


--
-- Name: machine_doc_lines machine_doc_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_doc_lines
    ADD CONSTRAINT machine_doc_lines_pkey PRIMARY KEY (id);


--
-- Name: machine_docs machine_docs_number_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_docs
    ADD CONSTRAINT machine_docs_number_key UNIQUE (number);


--
-- Name: machine_docs machine_docs_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_docs
    ADD CONSTRAINT machine_docs_pkey PRIMARY KEY (id);


--
-- Name: machines machines_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machines
    ADD CONSTRAINT machines_pkey PRIMARY KEY (id);


--
-- Name: materials materials_material_index_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_material_index_key UNIQUE (material_index);


--
-- Name: materials materials_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_pkey PRIMARY KEY (id);


--
-- Name: mold_events mold_events_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.mold_events
    ADD CONSTRAINT mold_events_pkey PRIMARY KEY (id);


--
-- Name: mold_photos mold_photos_mold_id_slot_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.mold_photos
    ADD CONSTRAINT mold_photos_mold_id_slot_key UNIQUE (mold_id, slot);


--
-- Name: mold_photos mold_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.mold_photos
    ADD CONSTRAINT mold_photos_pkey PRIMARY KEY (id);


--
-- Name: molds molds_mold_no_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.molds
    ADD CONSTRAINT molds_mold_no_key UNIQUE (mold_no);


--
-- Name: molds molds_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.molds
    ADD CONSTRAINT molds_pkey PRIMARY KEY (id);


--
-- Name: order_lines order_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_pkey PRIMARY KEY (id);


--
-- Name: orders orders_number_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_number_key UNIQUE (number);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_client_id_name_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_client_id_name_key UNIQUE (client_id, name);


--
-- Name: products products_code_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_code_key UNIQUE (code);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: receipt_lines receipt_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipt_lines
    ADD CONSTRAINT receipt_lines_pkey PRIMARY KEY (id);


--
-- Name: receipt_lines receipt_lines_receipt_id_material_id_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipt_lines
    ADD CONSTRAINT receipt_lines_receipt_id_material_id_key UNIQUE (receipt_id, material_id);


--
-- Name: receipts receipts_number_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_number_key UNIQUE (number);


--
-- Name: receipts receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_supplier_no_key; Type: CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_supplier_no_key UNIQUE (supplier_no);


--
-- Name: contacts_supplier_id_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX contacts_supplier_id_idx ON public.contacts USING btree (supplier_id);


--
-- Name: inventory_lines_material_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX inventory_lines_material_idx ON public.inventory_lines USING btree (material_id);


--
-- Name: machine_doc_lines_material_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX machine_doc_lines_material_idx ON public.machine_doc_lines USING btree (material_id);


--
-- Name: machine_docs_machine_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX machine_docs_machine_idx ON public.machine_docs USING btree (machine_id, status);


--
-- Name: materials_search_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX materials_search_idx ON public.materials USING btree (kind, color, symbol);


--
-- Name: materials_supplier_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX materials_supplier_idx ON public.materials USING btree (supplier_id);


--
-- Name: mold_events_mold_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX mold_events_mold_idx ON public.mold_events USING btree (mold_id, event_date);


--
-- Name: order_lines_order_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX order_lines_order_idx ON public.order_lines USING btree (order_id);


--
-- Name: order_lines_product_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX order_lines_product_idx ON public.order_lines USING btree (product_id);


--
-- Name: orders_client_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX orders_client_idx ON public.orders USING btree (client_id, order_date);


--
-- Name: orders_status_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX orders_status_idx ON public.orders USING btree (status);


--
-- Name: products_client_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX products_client_idx ON public.products USING btree (client_id);


--
-- Name: receipt_lines_material_idx; Type: INDEX; Schema: public; Owner: magazyn_app
--

CREATE INDEX receipt_lines_material_idx ON public.receipt_lines USING btree (material_id);


--
-- Name: contacts contacts_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;


--
-- Name: inventory_lines inventory_lines_inventory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventory_lines
    ADD CONSTRAINT inventory_lines_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES public.inventories(id) ON DELETE CASCADE;


--
-- Name: inventory_lines inventory_lines_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.inventory_lines
    ADD CONSTRAINT inventory_lines_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materials(id) ON DELETE CASCADE;


--
-- Name: machine_doc_lines machine_doc_lines_doc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_doc_lines
    ADD CONSTRAINT machine_doc_lines_doc_id_fkey FOREIGN KEY (doc_id) REFERENCES public.machine_docs(id) ON DELETE CASCADE;


--
-- Name: machine_doc_lines machine_doc_lines_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_doc_lines
    ADD CONSTRAINT machine_doc_lines_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materials(id) ON DELETE RESTRICT;


--
-- Name: machine_docs machine_docs_machine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.machine_docs
    ADD CONSTRAINT machine_docs_machine_id_fkey FOREIGN KEY (machine_id) REFERENCES public.machines(id);


--
-- Name: materials materials_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- Name: mold_events mold_events_mold_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.mold_events
    ADD CONSTRAINT mold_events_mold_id_fkey FOREIGN KEY (mold_id) REFERENCES public.molds(id) ON DELETE CASCADE;


--
-- Name: mold_photos mold_photos_mold_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.mold_photos
    ADD CONSTRAINT mold_photos_mold_id_fkey FOREIGN KEY (mold_id) REFERENCES public.molds(id) ON DELETE CASCADE;


--
-- Name: molds molds_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.molds
    ADD CONSTRAINT molds_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;


--
-- Name: order_lines order_lines_color_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_color_id_fkey FOREIGN KEY (color_id) REFERENCES public.colors(id) ON DELETE SET NULL;


--
-- Name: order_lines order_lines_colorant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_colorant_id_fkey FOREIGN KEY (colorant_id) REFERENCES public.materials(id) ON DELETE SET NULL;


--
-- Name: order_lines order_lines_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materials(id) ON DELETE SET NULL;


--
-- Name: order_lines order_lines_mold_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_mold_id_fkey FOREIGN KEY (mold_id) REFERENCES public.molds(id) ON DELETE SET NULL;


--
-- Name: order_lines order_lines_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_lines order_lines_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.order_lines
    ADD CONSTRAINT order_lines_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: orders orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE RESTRICT;


--
-- Name: products products_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE RESTRICT;


--
-- Name: products products_color_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_color_id_fkey FOREIGN KEY (color_id) REFERENCES public.colors(id) ON DELETE SET NULL;


--
-- Name: products products_colorant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_colorant_id_fkey FOREIGN KEY (colorant_id) REFERENCES public.materials(id) ON DELETE SET NULL;


--
-- Name: products products_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materials(id) ON DELETE SET NULL;


--
-- Name: products products_mold_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_mold_id_fkey FOREIGN KEY (mold_id) REFERENCES public.molds(id) ON DELETE SET NULL;


--
-- Name: receipt_lines receipt_lines_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipt_lines
    ADD CONSTRAINT receipt_lines_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.materials(id) ON DELETE RESTRICT;


--
-- Name: receipt_lines receipt_lines_receipt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipt_lines
    ADD CONSTRAINT receipt_lines_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES public.receipts(id) ON DELETE CASCADE;


--
-- Name: receipts receipts_supplier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: magazyn_app
--

ALTER TABLE ONLY public.receipts
    ADD CONSTRAINT receipts_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict iNhExvhcFNsL1hwuBiW4odYzVBNyNqJpZbneTQ43PvQo1taJploJxIgrzjqeGGP

