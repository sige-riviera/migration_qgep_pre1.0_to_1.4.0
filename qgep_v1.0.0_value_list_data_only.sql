--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: access_aid_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.access_aid_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5357	5357	other	andere	autre	altro	altul	O	A	AU			t
243	243	pressurized_door	Drucktuere	porte_etanche	zzz_Drucktuere	usa_presurizata	PD	D	PE			t
92	92	none	keine	aucun_equipement_d_acces	nessuno	inexistent		K	AN			t
240	240	ladder	Leiter	echelle	zzz_Leiter	scara		L	EC			t
241	241	step_iron	Steigeisen	echelons	zzz_Steigeisen	esaloane		S	ECO			t
3473	3473	staircase	Treppe	escalier	zzz_Treppe	structura_scari		R	ES			t
91	91	footstep_niches	Trittnischen	marchepieds	zzz_Trittnischen	trepte		N	N			t
3230	3230	door	Tuere	porte	porta	usa		T	P			t
3048	3048	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: backflow_prevention_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.backflow_prevention_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5760	5760	other	andere	autres	altri							t
5759	5759	pump	Pumpe	pompe	pompa							t
5757	5757	backflow_flap	Rueckstauklappe	clapet_de_non_retour_a_battant	zzz_Rueckstauklappe							t
5758	5758	gate_shield	Stauschild	plaque_de_retenue	paratoia_cilindrica							t
\.


--
-- Data for Name: benching_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.benching_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5319	5319	other	andere	autre	altro	alta						t
94	94	double_sided	beidseitig	double	zzz_beidseitig	dubla	DS	BB	D			t
93	93	one_sided	einseitig	simple	zzz_einseitig	simpla	OS	EB	S			t
3231	3231	none	kein	aucun	nessuno	niciun		KB	AN			t
3033	3033	unknown	unbekannt	inconnu	sconosciuto	necunoscuta		U	I			t
\.


--
-- Data for Name: catchment_area_direct_discharge_current; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_direct_discharge_current (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5457	5457	yes	ja	oui	si							t
5458	5458	no	nein	non	no							t
5463	5463	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_direct_discharge_planned; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_direct_discharge_planned (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5459	5459	yes	ja	oui	si							t
5460	5460	no	nein	non	no							t
5464	5464	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_drainage_system_current; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_drainage_system_current (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5186	5186	mixed_system	Mischsystem	systeme_unitaire	sistema_misto							t
5188	5188	modified_system	ModifiziertesSystem	systeme_modifie	sistema_modificato							t
5185	5185	not_connected	nicht_angeschlossen	non_raccorde	non_collegato							t
5537	5537	not_drained	nicht_entwaessert	non_evacue	non_evacuato							t
5187	5187	separated_system	Trennsystem	systeme_separatif	sistema_separato	rrr_Trennsystem						t
5189	5189	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_drainage_system_planned; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_drainage_system_planned (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5191	5191	mixed_system	Mischsystem	systeme_unitaire	sistema_misto							t
5193	5193	modified_system	ModifiziertesSystem	systeme_modifie	sistema_modificato	rrr_ModifiziertesSystem						t
5194	5194	not_connected	nicht_angeschlossen	non_raccorde	non_collegato							t
5536	5536	not_drained	nicht_entwaessert	non_evacue	non_evacuato							t
5192	5192	separated_system	Trennsystem	systeme_separatif	sistema_separato							t
5195	5195	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_infiltration_current; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_infiltration_current (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5452	5452	yes	ja	oui	si							t
5453	5453	no	nein	non	no							t
5165	5165	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_infiltration_planned; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_infiltration_planned (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5461	5461	yes	ja	oui	si							t
5462	5462	no	nein	non	no							t
5170	5170	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_retention_current; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_retention_current (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5467	5467	yes	ja	oui	si							t
5468	5468	no	nein	non	no							t
5469	5469	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_retention_planned; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_retention_planned (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5470	5470	yes	ja	oui	si							t
5471	5471	no	nein	non	no							t
5472	5472	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: catchment_area_text_plantype; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_text_plantype (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7844	7844	pipeline_registry	Leitungskataster	cadastre_des_conduites_souterraines	catasto_delle_canalizzazioni							t
7846	7846	overviewmap.om10	Uebersichtsplan.UeP10	plan_d_ensemble.pe10	piano_di_insieme.pi10							t
7847	7847	overviewmap.om2	Uebersichtsplan.UeP2	plan_d_ensemble.pe2	piano_di_insieme.pi2							t
7848	7848	overviewmap.om5	Uebersichtsplan.UeP5	plan_d_ensemble.pe5	piano_di_insieme.pi5							t
7845	7845	network_plan	Werkplan	plan_de_reseau								t
\.


--
-- Data for Name: catchment_area_text_texthali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_text_texthali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7850	7850	0	0	0	0	0						t
7851	7851	1	1	1	1	1						t
7852	7852	2	2	2	2	2						t
\.


--
-- Data for Name: catchment_area_text_textvali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.catchment_area_text_textvali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7853	7853	0	0	0	0	0						t
7854	7854	1	1	1	1	1						t
7855	7855	2	2	2	2	2						t
7856	7856	3	3	3	3	3						t
7857	7857	4	4	4	4	4						t
\.


--
-- Data for Name: channel_bedding_encasement; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.channel_bedding_encasement (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5325	5325	other	andere	autre	altro	altul						t
5332	5332	in_soil	erdverlegt	enterre	zzz_erdverlegt	pamant	IS	EV	ET			t
5328	5328	in_channel_suspended	in_Kanal_aufgehaengt	suspendu_dans_le_canal	zzz_in_Kanal_aufgehaengt	suspendat_in_canal		IKA	CS			t
5339	5339	in_channel_concrete_casted	in_Kanal_einbetoniert	betonne_dans_le_canal	zzz_in_Kanal_einbetoniert	beton_in_canal		IKB	CB			t
5331	5331	in_walk_in_passage	in_Leitungsgang	en_galerie	zzz_in_Leitungsgang	galerie		ILG	G			t
5337	5337	in_jacking_pipe_concrete	in_Vortriebsrohr_Beton	en_pousse_tube_en_beton	zzz_in_Vortriebsrohr_Beton	beton_presstube		IVB	TB			t
5336	5336	in_jacking_pipe_steel	in_Vortriebsrohr_Stahl	en_pousse_tube_en_acier	zzz_in_Vortriebsrohr_Stahl	otel_presstube		IVS	TA			t
5335	5335	sand	Sand	sable	zzz_Sand	nisip		SA	SA			t
5333	5333	sia_type_1	SIA_Typ1	SIA_type_1	SIA_tippo1	SIA_tip_1		B1	B1			t
5330	5330	sia_type_2	SIA_Typ2	SIA_type_2	SIA_tippo2	SIA_tip_2		B2	B2			t
5334	5334	sia_type_3	SIA_Typ3	SIA_type_3	SIA_tippo3	SIA_tip_3		B3	B3			t
5340	5340	sia_type_4	SIA_Typ4	SIA_type_4	SIA_tippo4	SIA_tip_4		B4	B4			t
5327	5327	bed_plank	Sohlbrett	radier_en_planches	zzz_Sohlbrett	pat_de_pamant		SB	RP			t
5329	5329	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: channel_connection_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.channel_connection_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5341	5341	other	andere	autre	altro	altul	O	A	AU			t
190	190	electric_welded_sleeves	Elektroschweissmuffen	manchon_electrosoudable	zzz_Elektroschweissmuffen	manson_electrosudabil	EWS	EL	MSA			t
187	187	flat_sleeves	Flachmuffen	manchon_plat	zzz_Flachmuffen	mason_plat		FM	MP			t
193	193	flange	Flansch	bride	zzz_Flansch	flansa		FL	B			t
185	185	bell_shaped_sleeves	Glockenmuffen	emboitement_a_cloche	zzz_Glockenmuffen	imbinare_tip_clopot		GL	EC			t
192	192	coupling	Kupplung	raccord	zzz_Kupplung	racord		KU	R			t
194	194	screwed_sleeves	Schraubmuffen	manchon_visse	zzz_Schraubmuffen	manson_insurubat		SC	MV			t
189	189	butt_welded	spiegelgeschweisst	manchon_soude_au_miroir	zzz_spiegelgeschweisst	manson_sudat_cap_la_cap		SP	MSM			t
186	186	beaked_sleeves	Spitzmuffen	emboitement_simple	zzz_Spitzmuffen	imbinare_simpla		SM	ES			t
191	191	push_fit_sleeves	Steckmuffen	raccord_a_serrage	zzz_Steckmuffen	racord_de_prindere		ST	RS			t
188	188	slip_on_sleeves	Ueberschiebmuffen	manchon_coulissant	zzz_Ueberschiebmuffen	manson_culisant		UE	MC			t
3036	3036	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
3666	3666	jacking_pipe_coupling	Vortriebsrohrkupplung	raccord_pour_tube_de_pousse_tube	zzz_Vortriebsrohrkupplung	racord_prin_presstube		VK	RTD			t
\.


--
-- Data for Name: channel_function_hierarchic; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.channel_function_hierarchic (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active, order_fct_hierarchic) FROM stdin;
5062	5062	pwwf.renovation_conduction	PAA.Sanierungsleitung	OAP.conduite_d_assainissement	IPS.condotta_risanamento	pwwf.conducta						t	5
5063	5063	swwf.renovation_conduction	SAA.Sanierungsleitung	OAS.conduite_d_assainissement	ISS.condotta_risanamento	swwf.racord						t	7
5064	5064	pwwf.residential_drainage	PAA.Liegenschaftsentwaesserung	OAP.evacuation_bien_fonds	IPS.samltimento_acque_fondi	pwwf.evacuare_rezidentiala						t	6
5065	5065	swwf.residential_drainage	SAA.Liegenschaftsentwaesserung	OAS.evacuation_bien_fonds	ISS.smaltimento_acque_fondi	swwf.evacuare_rezidentiala						t	8
5066	5066	pwwf.other	PAA.andere	OAP.autre	IPS.altro	pwwf.alta						t	10
5067	5067	swwf.other	SAA.andere	OAS.autre	ISS.altro	swwf.alta						t	13
5068	5068	pwwf.water_bodies	PAA.Gewaesser	OAP.cours_d_eau	IPS.corpo_acqua	pwwf.curs_de_apa						t	1
5069	5069	pwwf.main_drain	PAA.Hauptsammelkanal	OAP.collecteur_principal	IPS.collettore_principale	pwwf.colector_principal						t	3
5070	5070	pwwf.main_drain_regional	PAA.Hauptsammelkanal_regional	OAP.collecteur_principal_regional	IPS.collettore_principale_regionale	pwwf.colector_principal_regional						t	2
5071	5071	pwwf.collector_sewer	PAA.Sammelkanal	OAP.collecteur	IPS.collettore	pwwf.colector						t	4
5072	5072	pwwf.road_drainage	PAA.Strassenentwaesserung	OAP.evacuation_des_eaux_de_routes	IPS.samltimento_acque_stradali	pwwf.rigola_drum						t	9
5073	5073	swwf.road_drainage	SAA.Strassenentwaesserung	OAS.evacuation_des_eaux_de_routes	ISS.smaltimento_acque_strade	swwf.evacuare_ape_rigole						t	12
5074	5074	pwwf.unknown	PAA.unbekannt	OAP.inconnue	IPS.sconosciuto	pwwf.necunoscuta						t	11
5075	5075	swwf.unknown	SAA.unbekannt	OAS.inconnue	ISS.sconosciuto	swwf.necunoscuta						t	14
\.


--
-- Data for Name: channel_function_hydraulic; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.channel_function_hydraulic (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5320	5320	other	andere	autre	altro	alta						t
2546	2546	drainage_transportation_pipe	Drainagetransportleitung	conduite_de_transport_pour_le_drainage	condotta_trasporto_drenaggi	conducta_transport_dren	DTP	DT	CTD			t
22	22	restriction_pipe	Drosselleitung	conduite_d_etranglement	condotta_strozzamento	conducta_redusa	RP	DR	CE			t
3610	3610	inverted_syphon	Duekerleitung	siphon_inverse	canalizzazione_sifone	sifon_inversat	IS	DU	S			t
367	367	gravity_pipe	Freispiegelleitung	conduite_a_ecoulement_gravitaire	canalizzazione_gravita	conducta_gravitationala		FL	CEL			t
23	23	pump_pressure_pipe	Pumpendruckleitung	conduite_de_refoulement	canalizzazione_pompaggio	conducta_de_refulare		DL	CR			t
145	145	seepage_water_drain	Sickerleitung	conduite_de_drainage	canalizzazione_drenaggio	conducta_drenaj	SP	SI	CI			t
21	21	retention_pipe	Speicherleitung	conduite_de_retention	canalizzazione_ritenzione	conducta_de_retentie		SK	CA			t
144	144	jetting_pipe	Spuelleitung	conduite_de_rincage	canalizzazione_spurgo	conducta_de_spalare	JP	SL	CC			t
5321	5321	unknown	unbekannt	inconnue	sconosciuto	necunoscuta						t
3655	3655	vacuum_pipe	Vakuumleitung	conduite_sous_vide	canalizzazione_sotto_vuoto	conducta_vidata		VL	CV			t
\.


--
-- Data for Name: channel_usage_current; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.channel_usage_current (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active, order_usage_current) FROM stdin;
4514	4514	clean_wastewater	Reinabwasser	eaux_claires	acque_chiare	ape_conventional_curate		KW	EUR			t	5
4516	4516	discharged_combined_wastewater	entlastetes_Mischabwasser	eaux_mixtes_deversees	acque_miste_scaricate	ape_mixte_deversate	DCW	EW	EUD			t	3
4518	4518	creek_water	Bachwasser	eaux_cours_d_eau	acqua_corso_acqua	ape_curs_de_apa						t	7
4520	4520	rain_wastewater	Regenabwasser	eaux_pluviales	acque_meteoriche	apa_meteorica		RW	EUP			t	6
4522	4522	combined_wastewater	Mischabwasser	eaux_mixtes	acque_miste	ape_mixte		MW	EUM			t	2
4524	4524	industrial_wastewater	Industrieabwasser	eaux_industrielles	acque_industriali	ape_industriale		CW	EUC			t	4
4526	4526	wastewater	Schmutzabwasser	eaux_usees	acque_luride	ape_uzate		SW	EU			t	1
4571	4571	unknown	unbekannt	inconnu	sconosciuto	necunoscuta		U	I			t	8
5322	5322	other	andere	autre	altro	alta						t	9
\.


--
-- Data for Name: channel_usage_planned; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.channel_usage_planned (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5323	5323	other	andere	autre	altro	alta						t
4519	4519	creek_water	Bachwasser	eaux_cours_d_eau	acqua_corso_acqua	ape_curs_de_apa						t
4517	4517	discharged_combined_wastewater	entlastetes_Mischabwasser	eaux_mixtes_deversees	acque_miste_scaricate	ape_mixte_deversate	DCW	EW	EUD			t
4525	4525	industrial_wastewater	Industrieabwasser	eaux_industrielles	acque_industriali	ape_industriale		CW	EUC			t
4523	4523	combined_wastewater	Mischabwasser	eaux_mixtes	acque_miste	ape_mixte		MW	EUM			t
4521	4521	rain_wastewater	Regenabwasser	eaux_pluviales	acque_meteoriche	apa_meteorica		RW	EUP			t
4515	4515	clean_wastewater	Reinabwasser	eaux_claires	acque_chiare	ape_conventional_curate		KW	EUR			t
4527	4527	wastewater	Schmutzabwasser	eaux_usees	acque_luride	ape_uzate		SW	EU			t
4569	4569	unknown	unbekannt	inconnu	sconosciuto	necunoscuta		U	I			t
\.


--
-- Data for Name: chute_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.chute_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3591	3591	artificial	kuenstlich	artificiel	zzz_kuenstlich							t
3592	3592	natural	natuerlich	naturel	zzz_natuerlich							t
3593	3593	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: chute_material; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.chute_material (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2633	2633	other	andere	autres	altri							t
409	409	concrete_or_rock_pavement	Beton_Steinpflaesterung	beton_pavage_de_pierres	zzz_Beton_Steinpflaesterung							t
411	411	rocks_or_boulders	Fels_Steinbloecke	rocher_blocs_de_rocher	zzz_Fels_Steinbloecke							t
408	408	wood	Holz	bois	zzz_Holz							t
410	410	natural_none	natuerlich_kein	naturel_aucun	zzz_natuerlich_kein							t
3061	3061	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: cover_cover_shape; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.cover_cover_shape (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5353	5353	other	andere	autre	altro	altul	O	A	AU			t
3499	3499	rectangular	eckig	anguleux	zzz_eckig	dreptunghic	R	E	AX			t
3498	3498	round	rund	rond	zzz_rund	rotund		R	R			t
5354	5354	unknown	unbekannt	inconnue	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: cover_fastening; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.cover_fastening (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5350	5350	not_bolted	nicht_verschraubt	non_vissee	zzz_nicht_verschraubt	neinsurubata		NVS	NVS			t
5351	5351	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
5352	5352	bolted	verschraubt	vissee	zzz_verschraubt	insurubata		VS	VS			t
\.


--
-- Data for Name: cover_material; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.cover_material (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5355	5355	other	andere	autre	altro	altul	O	A	AU			t
234	234	concrete	Beton	beton	zzz_Beton	beton	C	B	B			t
233	233	cast_iron	Guss	fonte	zzz_Guss	fonta		G	F			t
5547	5547	cast_iron_with_pavement_filling	Guss_mit_Belagsfuellung	fonte_avec_remplissage_en_robe	zzz_Guss_mit_Belagsfuellung	fonta_cu_umplutura	CIP	GBL	FRE			t
235	235	cast_iron_with_concrete_filling	Guss_mit_Betonfuellung	fonte_avec_remplissage_en_beton	zzz_Guss_mit_Betonfuellung	fonta_cu_umplutura_beton		GBT	FRB			t
3015	3015	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: cover_positional_accuracy; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.cover_positional_accuracy (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3243	3243	more_than_50cm	groesser_50cm	plusque_50cm	maggiore_50cm	mai_mare_50cm		G50	S50			t
3241	3241	plusminus_10cm	plusminus_10cm	plus_moins_10cm	piu_meno_10cm	plus_minus_10cm		P10	P10			t
3236	3236	plusminus_3cm	plusminus_3cm	plus_moins_3cm	piu_meno_3cm	plus_minus_3cm		P03	P03			t
3242	3242	plusminus_50cm	plusminus_50cm	plus_moins_50cm	piu_meno_50cm	plus_minus_50cm		P50	P50			t
5349	5349	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
\.


--
-- Data for Name: cover_sludge_bucket; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.cover_sludge_bucket (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
423	423	inexistent	nicht_vorhanden	inexistant	zzz_nicht_vorhanden	inexistent		NV	IE			t
3066	3066	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
422	422	existent	vorhanden	existant	zzz_vorhanden	existent		V	E			t
\.


--
-- Data for Name: cover_venting; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.cover_venting (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
229	229	vented	entlueftet	aere	zzz_entlueftet	cu_aerisire		EL	AE			t
230	230	not_vented	nicht_entlueftet	non_aere	zzz_nicht_entlueftet	fara_aerisire		NEL	NAE			t
5348	5348	unknown	unbekannt	inconnue	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: dam_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.dam_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
416	416	retaining_weir	Stauwehr	digue_reservoir	zzz_Stauwehr							t
417	417	spillway	Streichwehr	deversoir_lateral	sfioratore_laterale							t
419	419	dam	Talsperre	barrage	zzz_Talsperre							t
418	418	tyrolean_weir	Tirolerwehr	prise_tyrolienne	zzz_Tirolerwehr							t
3064	3064	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: damage_channel_channel_damage_code; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.damage_channel_channel_damage_code (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4103	4103	AECXA	AECXA	AECXA	\N	\N				\N	\N	t
4104	4104	AECXB	AECXB	AECXB	\N	\N				\N	\N	t
4105	4105	AECXC	AECXC	AECXC	\N	\N				\N	\N	t
4106	4106	AECXD	AECXD	AECXD	\N	\N				\N	\N	t
4107	4107	AECXE	AECXE	AECXE	\N	\N				\N	\N	t
4108	4108	AECXF	AECXF	AECXF	\N	\N				\N	\N	t
4109	4109	AECXG	AECXG	AECXG	\N	\N				\N	\N	t
4110	4110	AECXH	AECXH	AECXH	\N	\N				\N	\N	t
4111	4111	AEDXA	AEDXA	AEDXA	\N	\N				\N	\N	t
4112	4112	AEDXB	AEDXB	AEDXB	\N	\N				\N	\N	t
4113	4113	AEDXC	AEDXC	AEDXC	\N	\N				\N	\N	t
4114	4114	AEDXD	AEDXD	AEDXD	\N	\N				\N	\N	t
4115	4115	AEDXE	AEDXE	AEDXE	\N	\N				\N	\N	t
4116	4116	AEDXF	AEDXF	AEDXF	\N	\N				\N	\N	t
4117	4117	AEDXG	AEDXG	AEDXG	\N	\N				\N	\N	t
4118	4118	AEDXH	AEDXH	AEDXH	\N	\N				\N	\N	t
4119	4119	AEDXI	AEDXI	AEDXI	\N	\N				\N	\N	t
4120	4120	AEDXJ	AEDXJ	AEDXJ	\N	\N				\N	\N	t
4121	4121	AEDXK	AEDXK	AEDXK	\N	\N				\N	\N	t
4122	4122	AEDXL	AEDXL	AEDXL	\N	\N				\N	\N	t
4123	4123	AEDXM	AEDXM	AEDXM	\N	\N				\N	\N	t
4124	4124	AEDXN	AEDXN	AEDXN	\N	\N				\N	\N	t
4125	4125	AEDXO	AEDXO	AEDXO	\N	\N				\N	\N	t
4126	4126	AEDXP	AEDXP	AEDXP	\N	\N				\N	\N	t
4127	4127	AEDXQ	AEDXQ	AEDXQ	\N	\N				\N	\N	t
4128	4128	AEDXR	AEDXR	AEDXR	\N	\N				\N	\N	t
4129	4129	AEDXS	AEDXS	AEDXS	\N	\N				\N	\N	t
4130	4130	AEDXT	AEDXT	AEDXT	\N	\N				\N	\N	t
4131	4131	AEDXU	AEDXU	AEDXU	\N	\N				\N	\N	t
4132	4132	AEDXV	AEDXV	AEDXV	\N	\N				\N	\N	t
4133	4133	AEDXW	AEDXW	AEDXW	\N	\N				\N	\N	t
4134	4134	AEDXX	AEDXX	AEDXX	\N	\N				\N	\N	t
4135	4135	AEF	AEF	AEF	\N	\N				\N	\N	t
3900	3900	BAAA	BAAA	BAAA	\N	\N				\N	\N	t
3901	3901	BAAB	BAAB	BAAB	\N	\N				\N	\N	t
3902	3902	BABAA	BABAA	BABAA	\N	\N				\N	\N	t
3903	3903	BABAB	BABAB	BABAB	\N	\N				\N	\N	t
3904	3904	BABAC	BABAC	BABAC	\N	\N				\N	\N	t
3905	3905	BABAD	BABAD	BABAD	\N	\N				\N	\N	t
3906	3906	BABBA	BABBA	BABBA	\N	\N				\N	\N	t
3907	3907	BABBB	BABBB	BABBB	\N	\N				\N	\N	t
3908	3908	BABBC	BABBC	BABBC	\N	\N				\N	\N	t
3909	3909	BABBD	BABBD	BABBD	\N	\N				\N	\N	t
3910	3910	BABCA	BABCA	BABCA	\N	\N				\N	\N	t
3911	3911	BABCB	BABCB	BABCB	\N	\N				\N	\N	t
3912	3912	BABCC	BABCC	BABCC	\N	\N				\N	\N	t
3913	3913	BABCD	BABCD	BABCD	\N	\N				\N	\N	t
3914	3914	BACA	BACA	BACA	\N	\N				\N	\N	t
3915	3915	BACB	BACB	BACB	\N	\N				\N	\N	t
3916	3916	BACC	BACC	BACC	\N	\N				\N	\N	t
3917	3917	BADA	BADA	BADA	\N	\N				\N	\N	t
3918	3918	BADB	BADB	BADB	\N	\N				\N	\N	t
3919	3919	BADC	BADC	BADC	\N	\N				\N	\N	t
3920	3920	BADD	BADD	BADD	\N	\N				\N	\N	t
3921	3921	BAE	BAE	BAE	\N	\N				\N	\N	t
3922	3922	BAFAA	BAFAA	BAFAA	\N	\N				\N	\N	t
3923	3923	BAFAB	BAFAB	BAFAB	\N	\N				\N	\N	t
3924	3924	BAFAC	BAFAC	BAFAC	\N	\N				\N	\N	t
3925	3925	BAFAD	BAFAD	BAFAD	\N	\N				\N	\N	t
3926	3926	BAFAE	BAFAE	BAFAE	\N	\N				\N	\N	t
3927	3927	BAFBA	BAFBA	BAFBA	\N	\N				\N	\N	t
3928	3928	BAFBE	BAFBE	BAFBE	\N	\N				\N	\N	t
3929	3929	BAFCA	BAFCA	BAFCA	\N	\N				\N	\N	t
3930	3930	BAFCB	BAFCB	BAFCB	\N	\N				\N	\N	t
3931	3931	BAFCC	BAFCC	BAFCC	\N	\N				\N	\N	t
3932	3932	BAFCD	BAFCD	BAFCD	\N	\N				\N	\N	t
3933	3933	BAFCE	BAFCE	BAFCE	\N	\N				\N	\N	t
3934	3934	BAFDA	BAFDA	BAFDA	\N	\N				\N	\N	t
3935	3935	BAFDB	BAFDB	BAFDB	\N	\N				\N	\N	t
3936	3936	BAFDC	BAFDC	BAFDC	\N	\N				\N	\N	t
3937	3937	BAFDD	BAFDD	BAFDD	\N	\N				\N	\N	t
3938	3938	BAFDE	BAFDE	BAFDE	\N	\N				\N	\N	t
3939	3939	BAFEA	BAFEA	BAFEA	\N	\N				\N	\N	t
3940	3940	BAFEB	BAFEB	BAFEB	\N	\N				\N	\N	t
3941	3941	BAFEC	BAFEC	BAFEC	\N	\N				\N	\N	t
3942	3942	BAFED	BAFED	BAFED	\N	\N				\N	\N	t
3943	3943	BAFEE	BAFEE	BAFEE	\N	\N				\N	\N	t
3944	3944	BAFFA	BAFFA	BAFFA	\N	\N				\N	\N	t
3945	3945	BAFFB	BAFFB	BAFFB	\N	\N				\N	\N	t
3946	3946	BAFFC	BAFFC	BAFFC	\N	\N				\N	\N	t
3947	3947	BAFFD	BAFFD	BAFFD	\N	\N				\N	\N	t
3948	3948	BAFFE	BAFFE	BAFFE	\N	\N				\N	\N	t
3949	3949	BAFGA	BAFGA	BAFGA	\N	\N				\N	\N	t
3950	3950	BAFGB	BAFGB	BAFGB	\N	\N				\N	\N	t
3951	3951	BAFGC	BAFGC	BAFGC	\N	\N				\N	\N	t
3952	3952	BAFGD	BAFGD	BAFGD	\N	\N				\N	\N	t
3953	3953	BAFGE	BAFGE	BAFGE	\N	\N				\N	\N	t
3954	3954	BAFHB	BAFHB	BAFHB	\N	\N				\N	\N	t
3955	3955	BAFHC	BAFHC	BAFHC	\N	\N				\N	\N	t
3956	3956	BAFHD	BAFHD	BAFHD	\N	\N				\N	\N	t
3957	3957	BAFHE	BAFHE	BAFHE	\N	\N				\N	\N	t
3958	3958	BAFIA	BAFIA	BAFIA	\N	\N				\N	\N	t
3959	3959	BAFIB	BAFIB	BAFIB	\N	\N				\N	\N	t
3960	3960	BAFIC	BAFIC	BAFIC	\N	\N				\N	\N	t
3961	3961	BAFID	BAFID	BAFID	\N	\N				\N	\N	t
3962	3962	BAFIE	BAFIE	BAFIE	\N	\N				\N	\N	t
3963	3963	BAFJB	BAFJB	BAFJB	\N	\N				\N	\N	t
3964	3964	BAFJC	BAFJC	BAFJC	\N	\N				\N	\N	t
3965	3965	BAFJD	BAFJD	BAFJD	\N	\N				\N	\N	t
3966	3966	BAFJE	BAFJE	BAFJE	\N	\N				\N	\N	t
3967	3967	BAFZA	BAFZA	BAFZA	\N	\N				\N	\N	t
3968	3968	BAFZB	BAFZB	BAFZB	\N	\N				\N	\N	t
3969	3969	BAFZC	BAFZC	BAFZC	\N	\N				\N	\N	t
3970	3970	BAFZD	BAFZD	BAFZD	\N	\N				\N	\N	t
3971	3971	BAFZE	BAFZE	BAFZE	\N	\N				\N	\N	t
3972	3972	BAGA	BAGA	BAGA	\N	\N				\N	\N	t
3973	3973	BAHA	BAHA	BAHA	\N	\N				\N	\N	t
3974	3974	BAHB	BAHB	BAHB	\N	\N				\N	\N	t
3975	3975	BAHC	BAHC	BAHC	\N	\N				\N	\N	t
3976	3976	BAHD	BAHD	BAHD	\N	\N				\N	\N	t
3977	3977	BAHE	BAHE	BAHE	\N	\N				\N	\N	t
3978	3978	BAHZ	BAHZ	BAHZ	\N	\N				\N	\N	t
3979	3979	BAIAA	BAIAA	BAIAA	\N	\N				\N	\N	t
3980	3980	BAIAB	BAIAB	BAIAB	\N	\N				\N	\N	t
3981	3981	BAIAC	BAIAC	BAIAC	\N	\N				\N	\N	t
3982	3982	BAIAD	BAIAD	BAIAD	\N	\N				\N	\N	t
3983	3983	BAIZ	BAIZ	BAIZ	\N	\N				\N	\N	t
3984	3984	BAJA	BAJA	BAJA	\N	\N				\N	\N	t
3985	3985	BAJB	BAJB	BAJB	\N	\N				\N	\N	t
3986	3986	BAJC	BAJC	BAJC	\N	\N				\N	\N	t
3987	3987	BAKA	BAKA	BAKA	\N	\N				\N	\N	t
3988	3988	BAKB	BAKB	BAKB	\N	\N				\N	\N	t
3989	3989	BAKC	BAKC	BAKC	\N	\N				\N	\N	t
3990	3990	BAKDA	BAKDA	BAKDA	\N	\N				\N	\N	t
3991	3991	BAKDB	BAKDB	BAKDB	\N	\N				\N	\N	t
3992	3992	BAKDC	BAKDC	BAKDC	\N	\N				\N	\N	t
3993	3993	BAKE	BAKE	BAKE	\N	\N				\N	\N	t
3994	3994	BAKZ	BAKZ	BAKZ	\N	\N				\N	\N	t
3995	3995	BALA	BALA	BALA	\N	\N				\N	\N	t
3996	3996	BALB	BALB	BALB	\N	\N				\N	\N	t
3997	3997	BALZ	BALZ	BALZ	\N	\N				\N	\N	t
3998	3998	BAMA	BAMA	BAMA	\N	\N				\N	\N	t
3999	3999	BAMB	BAMB	BAMB	\N	\N				\N	\N	t
4000	4000	BAMC	BAMC	BAMC	\N	\N				\N	\N	t
4001	4001	BAN	BAN	BAN	\N	\N				\N	\N	t
4002	4002	BAO	BAO	BAO	\N	\N				\N	\N	t
4003	4003	BAP	BAP	BAP	\N	\N				\N	\N	t
4004	4004	BBAA	BBAA	BBAA	\N	\N				\N	\N	t
4005	4005	BBAB	BBAB	BBAB	\N	\N				\N	\N	t
4006	4006	BBAC	BBAC	BBAC	\N	\N				\N	\N	t
4007	4007	BBBA	BBBA	BBBA	\N	\N				\N	\N	t
4008	4008	BBBB	BBBB	BBBB	\N	\N				\N	\N	t
4009	4009	BBBC	BBBC	BBBC	\N	\N				\N	\N	t
4010	4010	BBBZ	BBBZ	BBBZ	\N	\N				\N	\N	t
4011	4011	BBCA	BBCA	BBCA	\N	\N				\N	\N	t
4012	4012	BBCB	BBCB	BBCB	\N	\N				\N	\N	t
4013	4013	BBCC	BBCC	BBCC	\N	\N				\N	\N	t
4014	4014	BBCZ	BBCZ	BBCZ	\N	\N				\N	\N	t
4015	4015	BBDA	BBDA	BBDA	\N	\N				\N	\N	t
4016	4016	BBDB	BBDB	BBDB	\N	\N				\N	\N	t
4017	4017	BBDC	BBDC	BBDC	\N	\N				\N	\N	t
4018	4018	BBDD	BBDD	BBDD	\N	\N				\N	\N	t
4019	4019	BBDZ	BBDZ	BBDZ	\N	\N				\N	\N	t
4020	4020	BBEA	BBEA	BBEA	\N	\N				\N	\N	t
4021	4021	BBEB	BBEB	BBEB	\N	\N				\N	\N	t
4022	4022	BBEC	BBEC	BBEC	\N	\N				\N	\N	t
4023	4023	BBED	BBED	BBED	\N	\N				\N	\N	t
4024	4024	BBEE	BBEE	BBEE	\N	\N				\N	\N	t
4025	4025	BBEF	BBEF	BBEF	\N	\N				\N	\N	t
4026	4026	BBEG	BBEG	BBEG	\N	\N				\N	\N	t
4027	4027	BBEH	BBEH	BBEH	\N	\N				\N	\N	t
4028	4028	BBEZ	BBEZ	BBEZ	\N	\N				\N	\N	t
4029	4029	BBFA	BBFA	BBFA	\N	\N				\N	\N	t
4030	4030	BBFB	BBFB	BBFB	\N	\N				\N	\N	t
4031	4031	BBFC	BBFC	BBFC	\N	\N				\N	\N	t
4032	4032	BBFD	BBFD	BBFD	\N	\N				\N	\N	t
4033	4033	BBG	BBG	BBG	\N	\N				\N	\N	t
4034	4034	BBHAA	BBHAA	BBHAA	\N	\N				\N	\N	t
4035	4035	BBHAB	BBHAB	BBHAB	\N	\N				\N	\N	t
4036	4036	BBHAC	BBHAC	BBHAC	\N	\N				\N	\N	t
4037	4037	BBHAZ	BBHAZ	BBHAZ	\N	\N				\N	\N	t
4038	4038	BBHBA	BBHBA	BBHBA	\N	\N				\N	\N	t
4039	4039	BBHBB	BBHBB	BBHBB	\N	\N				\N	\N	t
4040	4040	BBHBC	BBHBC	BBHBC	\N	\N				\N	\N	t
4041	4041	BBHBZ	BBHBZ	BBHBZ	\N	\N				\N	\N	t
4042	4042	BBHZA	BBHZA	BBHZA	\N	\N				\N	\N	t
4043	4043	BBHZB	BBHZB	BBHZB	\N	\N				\N	\N	t
4044	4044	BBHZC	BBHZC	BBHZC	\N	\N				\N	\N	t
4045	4045	BBHZZ	BBHZZ	BBHZZ	\N	\N				\N	\N	t
4046	4046	BCAAA	BCAAA	BCAAA	\N	\N				\N	\N	t
4047	4047	BCAAB	BCAAB	BCAAB	\N	\N				\N	\N	t
4048	4048	BCABA	BCABA	BCABA	\N	\N				\N	\N	t
4049	4049	BCABB	BCABB	BCABB	\N	\N				\N	\N	t
4050	4050	BCACA	BCACA	BCACA	\N	\N				\N	\N	t
4051	4051	BCACB	BCACB	BCACB	\N	\N				\N	\N	t
4052	4052	BCADA	BCADA	BCADA	\N	\N				\N	\N	t
4053	4053	BCADB	BCADB	BCADB	\N	\N				\N	\N	t
4054	4054	BCAEA	BCAEA	BCAEA	\N	\N				\N	\N	t
4055	4055	BCAEB	BCAEB	BCAEB	\N	\N				\N	\N	t
4056	4056	BCAFA	BCAFA	BCAFA	\N	\N				\N	\N	t
4057	4057	BCAFB	BCAFB	BCAFB	\N	\N				\N	\N	t
4058	4058	BCAGA	BCAGA	BCAGA	\N	\N				\N	\N	t
4059	4059	BCAGB	BCAGB	BCAGB	\N	\N				\N	\N	t
4060	4060	BCAZA	BCAZA	BCAZA	\N	\N				\N	\N	t
4061	4061	BCAZB	BCAZB	BCAZB	\N	\N				\N	\N	t
4062	4062	BCBA	BCBA	BCBA	\N	\N				\N	\N	t
4063	4063	BCBB	BCBB	BCBB	\N	\N				\N	\N	t
4064	4064	BCBC	BCBC	BCBC	\N	\N				\N	\N	t
4065	4065	BCBD	BCBD	BCBD	\N	\N				\N	\N	t
4066	4066	BCBE	BCBE	BCBE	\N	\N				\N	\N	t
4067	4067	BCBZ	BCBZ	BCBZ	\N	\N				\N	\N	t
4068	4068	BCCAA	BCCAA	BCCAA	\N	\N				\N	\N	t
4069	4069	BCCAB	BCCAB	BCCAB	\N	\N				\N	\N	t
4070	4070	BCCAY	BCCAY	BCCAY	\N	\N				\N	\N	t
4071	4071	BCCBA	BCCBA	BCCBA	\N	\N				\N	\N	t
4072	4072	BCCBB	BCCBB	BCCBB	\N	\N				\N	\N	t
4073	4073	BCCBY	BCCBY	BCCBY	\N	\N				\N	\N	t
4074	4074	BCCYA	BCCYA	BCCYA	\N	\N				\N	\N	t
4075	4075	BCCYB	BCCYB	BCCYB	\N	\N				\N	\N	t
4076	4076	BCD	BCD	BCD	\N	\N				\N	\N	t
4077	4077	BCE	BCE	BCE	\N	\N				\N	\N	t
4078	4078	BDA	BDA	BDA	\N	\N				\N	\N	t
4079	4079	BDB	BDB	BDB	\N	\N				\N	\N	t
4136	4136	BDBA	BDBA	BDBA	\N	\N				\N	\N	t
4137	4137	BDBB	BDBB	BDBB	\N	\N				\N	\N	t
4138	4138	BDBC	BDBC	BDBC	\N	\N				\N	\N	t
4139	4139	BDBD	BDBD	BDBD	\N	\N				\N	\N	t
4140	4140	BDBE	BDBE	BDBE	\N	\N				\N	\N	t
4141	4141	BDBF	BDBF	BDBF	\N	\N				\N	\N	t
4142	4142	BDBG	BDBG	BDBG	\N	\N				\N	\N	t
4143	4143	BDBH	BDBH	BDBH	\N	\N				\N	\N	t
4144	4144	BDBI	BDBI	BDBI	\N	\N				\N	\N	t
4145	4145	BDBJ	BDBJ	BDBJ	\N	\N				\N	\N	t
4146	4146	BDBK	BDBK	BDBK	\N	\N				\N	\N	t
4147	4147	BDBL	BDBL	BDBL	\N	\N				\N	\N	t
4080	4080	BDCA	BDCA	BDCA	\N	\N				\N	\N	t
4081	4081	BDCB	BDCB	BDCB	\N	\N				\N	\N	t
4082	4082	BDCC	BDCC	BDCC	\N	\N				\N	\N	t
4083	4083	BDCZ	BDCZ	BDCZ	\N	\N				\N	\N	t
4084	4084	BDDA	BDDA	BDDA	\N	\N				\N	\N	t
4085	4085	BDDB	BDDB	BDDB	\N	\N				\N	\N	t
4086	4086	BDEAA	BDEAA	BDEAA	\N	\N				\N	\N	t
4087	4087	BDEAB	BDEAB	BDEAB	\N	\N				\N	\N	t
4088	4088	BDEAC	BDEAC	BDEAC	\N	\N				\N	\N	t
4089	4089	BDEBA	BDEBA	BDEBA	\N	\N				\N	\N	t
4090	4090	BDEBB	BDEBB	BDEBB	\N	\N				\N	\N	t
4091	4091	BDEBC	BDEBC	BDEBC	\N	\N				\N	\N	t
4092	4092	BDEYA	BDEYA	BDEYA	\N	\N				\N	\N	t
4093	4093	BDEYB	BDEYB	BDEYB	\N	\N				\N	\N	t
4094	4094	BDEYY	BDEYY	BDEYY	\N	\N				\N	\N	t
4095	4095	BDFA	BDFA	BDFA	\N	\N				\N	\N	t
4096	4096	BDFB	BDFB	BDFB	\N	\N				\N	\N	t
4097	4097	BDFC	BDFC	BDFC	\N	\N				\N	\N	t
4098	4098	BDFZ	BDFZ	BDFZ	\N	\N				\N	\N	t
4099	4099	BDGA	BDGA	BDGA	\N	\N				\N	\N	t
4100	4100	BDGB	BDGB	BDGB	\N	\N				\N	\N	t
4101	4101	BDGC	BDGC	BDGC	\N	\N				\N	\N	t
4102	4102	BDGZ	BDGZ	BDGZ	\N	\N				\N	\N	t
\.


--
-- Data for Name: damage_connection; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.damage_connection (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
8498	8498	yes	ja	oui	\N	\N				\N	\N	t
8499	8499	no	nein	non	\N	\N				\N	\N	t
\.


--
-- Data for Name: damage_manhole_manhole_damage_code; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.damage_manhole_manhole_damage_code (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4148	4148	DAAA	DAAA	DAAA	\N	\N				\N	\N	t
4149	4149	DAAB	DAAB	DAAB	\N	\N				\N	\N	t
4150	4150	DABAA	DABAA	DABAA	\N	\N				\N	\N	t
4151	4151	DABAB	DABAB	DABAB	\N	\N				\N	\N	t
4152	4152	DABAC	DABAC	DABAC	\N	\N				\N	\N	t
4153	4153	DABAD	DABAD	DABAD	\N	\N				\N	\N	t
4154	4154	DABBA	DABBA	DABBA	\N	\N				\N	\N	t
4155	4155	DABBB	DABBB	DABBB	\N	\N				\N	\N	t
4156	4156	DABBC	DABBC	DABBC	\N	\N				\N	\N	t
4157	4157	DABBD	DABBD	DABBD	\N	\N				\N	\N	t
4158	4158	DABCA	DABCA	DABCA	\N	\N				\N	\N	t
4159	4159	DABCB	DABCB	DABCB	\N	\N				\N	\N	t
4160	4160	DABCC	DABCC	DABCC	\N	\N				\N	\N	t
4161	4161	DABCD	DABCD	DABCD	\N	\N				\N	\N	t
4162	4162	DACA	DACA	DACA	\N	\N				\N	\N	t
4163	4163	DACB	DACB	DACB	\N	\N				\N	\N	t
4164	4164	DACC	DACC	DACC	\N	\N				\N	\N	t
4165	4165	DADA	DADA	DADA	\N	\N				\N	\N	t
4166	4166	DADB	DADB	DADB	\N	\N				\N	\N	t
4167	4167	DADC	DADC	DADC	\N	\N				\N	\N	t
4168	4168	DAE	DAE	DAE	\N	\N				\N	\N	t
4169	4169	DAFAA	DAFAA	DAFAA	\N	\N				\N	\N	t
4170	4170	DAFAB	DAFAB	DAFAB	\N	\N				\N	\N	t
4171	4171	DAFAC	DAFAC	DAFAC	\N	\N				\N	\N	t
4172	4172	DAFAD	DAFAD	DAFAD	\N	\N				\N	\N	t
4173	4173	DAFAE	DAFAE	DAFAE	\N	\N				\N	\N	t
4174	4174	DAFBA	DAFBA	DAFBA	\N	\N				\N	\N	t
4175	4175	DAFBE	DAFBE	DAFBE	\N	\N				\N	\N	t
4176	4176	DAFCA	DAFCA	DAFCA	\N	\N				\N	\N	t
4177	4177	DAFCB	DAFCB	DAFCB	\N	\N				\N	\N	t
4178	4178	DAFCC	DAFCC	DAFCC	\N	\N				\N	\N	t
4179	4179	DAFCD	DAFCD	DAFCD	\N	\N				\N	\N	t
4180	4180	DAFCE	DAFCE	DAFCE	\N	\N				\N	\N	t
4181	4181	DAFDA	DAFDA	DAFDA	\N	\N				\N	\N	t
4182	4182	DAFDB	DAFDB	DAFDB	\N	\N				\N	\N	t
4183	4183	DAFDC	DAFDC	DAFDC	\N	\N				\N	\N	t
4184	4184	DAFDD	DAFDD	DAFDD	\N	\N				\N	\N	t
4185	4185	DAFDE	DAFDE	DAFDE	\N	\N				\N	\N	t
4186	4186	DAFEA	DAFEA	DAFEA	\N	\N				\N	\N	t
4187	4187	DAFEB	DAFEB	DAFEB	\N	\N				\N	\N	t
4188	4188	DAFEC	DAFEC	DAFEC	\N	\N				\N	\N	t
4189	4189	DAFED	DAFED	DAFED	\N	\N				\N	\N	t
4190	4190	DAFEE	DAFEE	DAFEE	\N	\N				\N	\N	t
4191	4191	DAFFA	DAFFA	DAFFA	\N	\N				\N	\N	t
4192	4192	DAFFB	DAFFB	DAFFB	\N	\N				\N	\N	t
4193	4193	DAFFC	DAFFC	DAFFC	\N	\N				\N	\N	t
4194	4194	DAFFD	DAFFD	DAFFD	\N	\N				\N	\N	t
4195	4195	DAFFE	DAFFE	DAFFE	\N	\N				\N	\N	t
4196	4196	DAFGA	DAFGA	DAFGA	\N	\N				\N	\N	t
4197	4197	DAFGB	DAFGB	DAFGB	\N	\N				\N	\N	t
4198	4198	DAFGC	DAFGC	DAFGC	\N	\N				\N	\N	t
4199	4199	DAFGD	DAFGD	DAFGD	\N	\N				\N	\N	t
4200	4200	DAFGE	DAFGE	DAFGE	\N	\N				\N	\N	t
4201	4201	DAFHB	DAFHB	DAFHB	\N	\N				\N	\N	t
4202	4202	DAFHC	DAFHC	DAFHC	\N	\N				\N	\N	t
4203	4203	DAFHD	DAFHD	DAFHD	\N	\N				\N	\N	t
4204	4204	DAFHE	DAFHE	DAFHE	\N	\N				\N	\N	t
4205	4205	DAFIA	DAFIA	DAFIA	\N	\N				\N	\N	t
4206	4206	DAFIB	DAFIB	DAFIB	\N	\N				\N	\N	t
4207	4207	DAFIC	DAFIC	DAFIC	\N	\N				\N	\N	t
4208	4208	DAFID	DAFID	DAFID	\N	\N				\N	\N	t
4209	4209	DAFIE	DAFIE	DAFIE	\N	\N				\N	\N	t
4210	4210	DAFJB	DAFJB	DAFJB	\N	\N				\N	\N	t
4211	4211	DAFJC	DAFJC	DAFJC	\N	\N				\N	\N	t
4212	4212	DAFJD	DAFJD	DAFJD	\N	\N				\N	\N	t
4213	4213	DAFJE	DAFJE	DAFJE	\N	\N				\N	\N	t
4214	4214	DAFZA	DAFZA	DAFZA	\N	\N				\N	\N	t
4215	4215	DAFZB	DAFZB	DAFZB	\N	\N				\N	\N	t
4216	4216	DAFZC	DAFZC	DAFZC	\N	\N				\N	\N	t
4217	4217	DAFZD	DAFZD	DAFZD	\N	\N				\N	\N	t
4218	4218	DAFZE	DAFZE	DAFZE	\N	\N				\N	\N	t
4219	4219	DAG	DAG	DAG	\N	\N				\N	\N	t
4220	4220	DAHA	DAHA	DAHA	\N	\N				\N	\N	t
4221	4221	DAHB	DAHB	DAHB	\N	\N				\N	\N	t
4222	4222	DAHC	DAHC	DAHC	\N	\N				\N	\N	t
4223	4223	DAHD	DAHD	DAHD	\N	\N				\N	\N	t
4224	4224	DAHE	DAHE	DAHE	\N	\N				\N	\N	t
4225	4225	DAHZ	DAHZ	DAHZ	\N	\N				\N	\N	t
4226	4226	DAIAA	DAIAA	DAIAA	\N	\N				\N	\N	t
4227	4227	DAIAB	DAIAB	DAIAB	\N	\N				\N	\N	t
4228	4228	DAIAC	DAIAC	DAIAC	\N	\N				\N	\N	t
4229	4229	DAIZ	DAIZ	DAIZ	\N	\N				\N	\N	t
4230	4230	DAJA	DAJA	DAJA	\N	\N				\N	\N	t
4231	4231	DAJB	DAJB	DAJB	\N	\N				\N	\N	t
4232	4232	DAJC	DAJC	DAJC	\N	\N				\N	\N	t
4233	4233	DAKA	DAKA	DAKA	\N	\N				\N	\N	t
4234	4234	DAKB	DAKB	DAKB	\N	\N				\N	\N	t
4235	4235	DAKC	DAKC	DAKC	\N	\N				\N	\N	t
4236	4236	DAKDA	DAKDA	DAKDA	\N	\N				\N	\N	t
4237	4237	DAKDB	DAKDB	DAKDB	\N	\N				\N	\N	t
4238	4238	DAKDC	DAKDC	DAKDC	\N	\N				\N	\N	t
4239	4239	DAKE	DAKE	DAKE	\N	\N				\N	\N	t
4240	4240	DAKZ	DAKZ	DAKZ	\N	\N				\N	\N	t
4241	4241	DALA	DALA	DALA	\N	\N				\N	\N	t
4242	4242	DALB	DALB	DALB	\N	\N				\N	\N	t
4243	4243	DALZ	DALZ	DALZ	\N	\N				\N	\N	t
4244	4244	DAMA	DAMA	DAMA	\N	\N				\N	\N	t
4245	4245	DAMB	DAMB	DAMB	\N	\N				\N	\N	t
4246	4246	DAMC	DAMC	DAMC	\N	\N				\N	\N	t
4247	4247	DAN	DAN	DAN	\N	\N				\N	\N	t
4248	4248	DAO	DAO	DAO	\N	\N				\N	\N	t
4249	4249	DAP	DAP	DAP	\N	\N				\N	\N	t
4250	4250	DAQA	DAQA	DAQA	\N	\N				\N	\N	t
4251	4251	DAQB	DAQB	DAQB	\N	\N				\N	\N	t
4252	4252	DAQC	DAQC	DAQC	\N	\N				\N	\N	t
4253	4253	DAQD	DAQD	DAQD	\N	\N				\N	\N	t
4254	4254	DAQE	DAQE	DAQE	\N	\N				\N	\N	t
4255	4255	DAQF	DAQF	DAQF	\N	\N				\N	\N	t
4256	4256	DAQG	DAQG	DAQG	\N	\N				\N	\N	t
4257	4257	DAQH	DAQH	DAQH	\N	\N				\N	\N	t
4258	4258	DAQI	DAQI	DAQI	\N	\N				\N	\N	t
4259	4259	DAQJ	DAQJ	DAQJ	\N	\N				\N	\N	t
4260	4260	DAQK	DAQK	DAQK	\N	\N				\N	\N	t
4261	4261	DAQZ	DAQZ	DAQZ	\N	\N				\N	\N	t
4262	4262	DARA	DARA	DARA	\N	\N				\N	\N	t
4263	4263	DARB	DARB	DARB	\N	\N				\N	\N	t
4264	4264	DARC	DARC	DARC	\N	\N				\N	\N	t
4265	4265	DARD	DARD	DARD	\N	\N				\N	\N	t
4266	4266	DARE	DARE	DARE	\N	\N				\N	\N	t
4267	4267	DARF	DARF	DARF	\N	\N				\N	\N	t
4268	4268	DARG	DARG	DARG	\N	\N				\N	\N	t
4269	4269	DARH	DARH	DARH	\N	\N				\N	\N	t
4270	4270	DARZ	DARZ	DARZ	\N	\N				\N	\N	t
4271	4271	DBAA	DBAA	DBAA	\N	\N				\N	\N	t
4272	4272	DBAB	DBAB	DBAB	\N	\N				\N	\N	t
4273	4273	DBAC	DBAC	DBAC	\N	\N				\N	\N	t
4274	4274	DBBA	DBBA	DBBA	\N	\N				\N	\N	t
4275	4275	DBBB	DBBB	DBBB	\N	\N				\N	\N	t
4276	4276	DBBC	DBBC	DBBC	\N	\N				\N	\N	t
4277	4277	DBBZ	DBBZ	DBBZ	\N	\N				\N	\N	t
4278	4278	DBCA	DBCA	DBCA	\N	\N				\N	\N	t
4279	4279	DBCB	DBCB	DBCB	\N	\N				\N	\N	t
4280	4280	DBCC	DBCC	DBCC	\N	\N				\N	\N	t
4281	4281	DBCZ	DBCZ	DBCZ	\N	\N				\N	\N	t
4282	4282	DBD	DBD	DBD	\N	\N				\N	\N	t
4283	4283	DBEA	DBEA	DBEA	\N	\N				\N	\N	t
4284	4284	DBEB	DBEB	DBEB	\N	\N				\N	\N	t
4285	4285	DBEC	DBEC	DBEC	\N	\N				\N	\N	t
4286	4286	DBED	DBED	DBED	\N	\N				\N	\N	t
4287	4287	DBEE	DBEE	DBEE	\N	\N				\N	\N	t
4288	4288	DBEF	DBEF	DBEF	\N	\N				\N	\N	t
4289	4289	DBEG	DBEG	DBEG	\N	\N				\N	\N	t
4290	4290	DBEH	DBEH	DBEH	\N	\N				\N	\N	t
4291	4291	DBEZ	DBEZ	DBEZ	\N	\N				\N	\N	t
4292	4292	DBFAA	DBFAA	DBFAA	\N	\N				\N	\N	t
4293	4293	DBFAB	DBFAB	DBFAB	\N	\N				\N	\N	t
4294	4294	DBFAC	DBFAC	DBFAC	\N	\N				\N	\N	t
4295	4295	DBFBA	DBFBA	DBFBA	\N	\N				\N	\N	t
4296	4296	DBFBB	DBFBB	DBFBB	\N	\N				\N	\N	t
4297	4297	DBFBC	DBFBC	DBFBC	\N	\N				\N	\N	t
4298	4298	DBFCA	DBFCA	DBFCA	\N	\N				\N	\N	t
4299	4299	DBFCB	DBFCB	DBFCB	\N	\N				\N	\N	t
4300	4300	DBFCC	DBFCC	DBFCC	\N	\N				\N	\N	t
4301	4301	DBFDA	DBFDA	DBFDA	\N	\N				\N	\N	t
4302	4302	DBFDB	DBFDB	DBFDB	\N	\N				\N	\N	t
4303	4303	DBFDC	DBFDC	DBFDC	\N	\N				\N	\N	t
4304	4304	DBG	DBG	DBG	\N	\N				\N	\N	t
4305	4305	DBHAA	DBHAA	DBHAA	\N	\N				\N	\N	t
4306	4306	DBHAB	DBHAB	DBHAB	\N	\N				\N	\N	t
4307	4307	DBHAC	DBHAC	DBHAC	\N	\N				\N	\N	t
4308	4308	DBHAZ	DBHAZ	DBHAZ	\N	\N				\N	\N	t
4309	4309	DBHBA	DBHBA	DBHBA	\N	\N				\N	\N	t
4310	4310	DBHBB	DBHBB	DBHBB	\N	\N				\N	\N	t
4311	4311	DBHBC	DBHBC	DBHBC	\N	\N				\N	\N	t
4312	4312	DBHBZ	DBHBZ	DBHBZ	\N	\N				\N	\N	t
4313	4313	DBHZA	DBHZA	DBHZA	\N	\N				\N	\N	t
4314	4314	DBHZB	DBHZB	DBHZB	\N	\N				\N	\N	t
4315	4315	DBHZC	DBHZC	DBHZC	\N	\N				\N	\N	t
4316	4316	DBHZZ	DBHZZ	DBHZZ	\N	\N				\N	\N	t
4317	4317	DCAA	DCAA	DCAA	\N	\N				\N	\N	t
4318	4318	DCAB	DCAB	DCAB	\N	\N				\N	\N	t
4319	4319	DCAC	DCAC	DCAC	\N	\N				\N	\N	t
4320	4320	DCAD	DCAD	DCAD	\N	\N				\N	\N	t
4321	4321	DCAE	DCAE	DCAE	\N	\N				\N	\N	t
4322	4322	DCAF	DCAF	DCAF	\N	\N				\N	\N	t
4323	4323	DCAZ	DCAZ	DCAZ	\N	\N				\N	\N	t
4324	4324	DCBA	DCBA	DCBA	\N	\N				\N	\N	t
4325	4325	DCBB	DCBB	DCBB	\N	\N				\N	\N	t
4326	4326	DCBC	DCBC	DCBC	\N	\N				\N	\N	t
4327	4327	DCBZ	DCBZ	DCBZ	\N	\N				\N	\N	t
4328	4328	DCFA	DCFA	DCFA	\N	\N				\N	\N	t
4329	4329	DCFB	DCFB	DCFB	\N	\N				\N	\N	t
4330	4330	DCFC	DCFC	DCFC	\N	\N				\N	\N	t
4331	4331	DCFD	DCFD	DCFD	\N	\N				\N	\N	t
4332	4332	DCFE	DCFE	DCFE	\N	\N				\N	\N	t
4333	4333	DCFF	DCFF	DCFF	\N	\N				\N	\N	t
4334	4334	DCFG	DCFG	DCFG	\N	\N				\N	\N	t
4335	4335	DCFH	DCFH	DCFH	\N	\N				\N	\N	t
4336	4336	DCFI	DCFI	DCFI	\N	\N				\N	\N	t
4337	4337	DCFJ	DCFJ	DCFJ	\N	\N				\N	\N	t
4338	4338	DCFK	DCFK	DCFK	\N	\N				\N	\N	t
4339	4339	DCFL	DCFL	DCFL	\N	\N				\N	\N	t
4340	4340	DCFM	DCFM	DCFM	\N	\N				\N	\N	t
4341	4341	DCFN	DCFN	DCFN	\N	\N				\N	\N	t
4342	4342	DCFO	DCFO	DCFO	\N	\N				\N	\N	t
4343	4343	DCFP	DCFP	DCFP	\N	\N				\N	\N	t
4344	4344	DCFQ	DCFQ	DCFQ	\N	\N				\N	\N	t
4345	4345	DCFR	DCFR	DCFR	\N	\N				\N	\N	t
4346	4346	DCFS	DCFS	DCFS	\N	\N				\N	\N	t
4347	4347	DCFT	DCFT	DCFT	\N	\N				\N	\N	t
4348	4348	DCFU	DCFU	DCFU	\N	\N				\N	\N	t
4349	4349	DCFV	DCFV	DCFV	\N	\N				\N	\N	t
4350	4350	DCFW	DCFW	DCFW	\N	\N				\N	\N	t
4351	4351	DCFX	DCFX	DCFX	\N	\N				\N	\N	t
4352	4352	DCGAA	DCGAA	DCGAA	\N	\N				\N	\N	t
4353	4353	DCGAB	DCGAB	DCGAB	\N	\N				\N	\N	t
4354	4354	DCGAC	DCGAC	DCGAC	\N	\N				\N	\N	t
4355	4355	DCGBA	DCGBA	DCGBA	\N	\N				\N	\N	t
4356	4356	DCGBB	DCGBB	DCGBB	\N	\N				\N	\N	t
4357	4357	DCGBC	DCGBC	DCGBC	\N	\N				\N	\N	t
4358	4358	DCGCA	DCGCA	DCGCA	\N	\N				\N	\N	t
4359	4359	DCGCB	DCGCB	DCGCB	\N	\N				\N	\N	t
4360	4360	DCGCC	DCGCC	DCGCC	\N	\N				\N	\N	t
4361	4361	DCGXA	DCGXA	DCGXA	\N	\N				\N	\N	t
4364	4364	DCGXAA	DCGXAA	DCGXAA	\N	\N				\N	\N	t
4365	4365	DCGXAB	DCGXAB	DCGXAB	\N	\N				\N	\N	t
4366	4366	DCGXAC	DCGXAC	DCGXAC	\N	\N				\N	\N	t
4362	4362	DCGXB	DCGXB	DCGXB	\N	\N				\N	\N	t
4367	4367	DCGXBA	DCGXBA	DCGXBA	\N	\N				\N	\N	t
4368	4368	DCGXBB	DCGXBB	DCGXBB	\N	\N				\N	\N	t
4369	4369	DCGXBC	DCGXBC	DCGXBC	\N	\N				\N	\N	t
4363	4363	DCGXC	DCGXC	DCGXC	\N	\N				\N	\N	t
4370	4370	DCGXCA	DCGXCA	DCGXCA	\N	\N				\N	\N	t
4371	4371	DCGXCB	DCGXCB	DCGXCB	\N	\N				\N	\N	t
4372	4372	DCGXCC	DCGXCC	DCGXCC	\N	\N				\N	\N	t
4373	4373	DCGYA	DCGYA	DCGYA	\N	\N				\N	\N	t
4374	4374	DCGYB	DCGYB	DCGYB	\N	\N				\N	\N	t
4375	4375	DCGYC	DCGYC	DCGYC	\N	\N				\N	\N	t
4376	4376	DCGZA	DCGZA	DCGZA	\N	\N				\N	\N	t
4377	4377	DCGZB	DCGZB	DCGZB	\N	\N				\N	\N	t
4378	4378	DCGZC	DCGZC	DCGZC	\N	\N				\N	\N	t
4379	4379	DCHA	DCHA	DCHA	\N	\N				\N	\N	t
4380	4380	DCHAA	DCHAA	DCHAA	\N	\N				\N	\N	t
4381	4381	DCHAB	DCHAB	DCHAB	\N	\N				\N	\N	t
4382	4382	DCHB	DCHB	DCHB	\N	\N				\N	\N	t
4383	4383	DCIA	DCIA	DCIA	\N	\N				\N	\N	t
4384	4384	DCIB	DCIB	DCIB	\N	\N				\N	\N	t
4385	4385	DCLAA	DCLAA	DCLAA	\N	\N				\N	\N	t
4386	4386	DCLAB	DCLAB	DCLAB	\N	\N				\N	\N	t
4387	4387	DCLBA	DCLBA	DCLBA	\N	\N				\N	\N	t
4388	4388	DCLBB	DCLBB	DCLBB	\N	\N				\N	\N	t
4389	4389	DCLCA	DCLCA	DCLCA	\N	\N				\N	\N	t
4390	4390	DCLCB	DCLCB	DCLCB	\N	\N				\N	\N	t
4391	4391	DCMA	DCMA	DCMA	\N	\N				\N	\N	t
4392	4392	DCMB	DCMB	DCMB	\N	\N				\N	\N	t
4393	4393	DCMC	DCMC	DCMC	\N	\N				\N	\N	t
4394	4394	DDA	DDA	DDA	\N	\N				\N	\N	t
4395	4395	DDB	DDB	DDB	\N	\N				\N	\N	t
4396	4396	DDCA	DDCA	DDCA	\N	\N				\N	\N	t
4397	4397	DDCB	DDCB	DDCB	\N	\N				\N	\N	t
4398	4398	DDCC	DDCC	DDCC	\N	\N				\N	\N	t
4399	4399	DDCD	DDCD	DDCD	\N	\N				\N	\N	t
4400	4400	DDCZ	DDCZ	DDCZ	\N	\N				\N	\N	t
4401	4401	DDD	DDD	DDD	\N	\N				\N	\N	t
4402	4402	DDEAA	DDEAA	DDEAA	\N	\N				\N	\N	t
4403	4403	DDEAB	DDEAB	DDEAB	\N	\N				\N	\N	t
4404	4404	DDEAC	DDEAC	DDEAC	\N	\N				\N	\N	t
4405	4405	DDEBA	DDEBA	DDEBA	\N	\N				\N	\N	t
4406	4406	DDEBB	DDEBB	DDEBB	\N	\N				\N	\N	t
4407	4407	DDEBC	DDEBC	DDEBC	\N	\N				\N	\N	t
4408	4408	DDEYA	DDEYA	DDEYA	\N	\N				\N	\N	t
4409	4409	DDEYB	DDEYB	DDEYB	\N	\N				\N	\N	t
4410	4410	DDEYY	DDEYY	DDEYY	\N	\N				\N	\N	t
4411	4411	DDFA	DDFA	DDFA	\N	\N				\N	\N	t
4412	4412	DDFB	DDFB	DDFB	\N	\N				\N	\N	t
4413	4413	DDFC	DDFC	DDFC	\N	\N				\N	\N	t
4414	4414	DDFZ	DDFZ	DDFZ	\N	\N				\N	\N	t
4416	4416	DDGA	DDGA	DDGA	\N	\N				\N	\N	t
4417	4417	DDGB	DDGB	DDGB	\N	\N				\N	\N	t
4418	4418	DDGC	DDGC	DDGC	\N	\N				\N	\N	t
4419	4419	DDGZ	DDGZ	DDGZ	\N	\N				\N	\N	t
\.


--
-- Data for Name: damage_manhole_manhole_shaft_area; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.damage_manhole_manhole_shaft_area (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3743	3743	A	A	A	\N	\N				\N	\N	t
3744	3744	B	B	B	\N	\N				\N	\N	t
3745	3745	D	D	D	\N	\N				\N	\N	t
3746	3746	F	F	F	\N	\N				\N	\N	t
3747	3747	H	H	H	\N	\N				\N	\N	t
3748	3748	I	I	I	\N	\N				\N	\N	t
3749	3749	J	J	J	\N	\N				\N	\N	t
\.


--
-- Data for Name: damage_single_damage_class; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.damage_single_damage_class (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3707	3707	EZ0	EZ0	EZ0	\N	\N				\N	\N	t
3708	3708	EZ1	EZ1	EZ1	\N	\N				\N	\N	t
3709	3709	EZ2	EZ2	EZ2	\N	\N				\N	\N	t
3710	3710	EZ3	EZ3	EZ3	\N	\N				\N	\N	t
3711	3711	EZ4	EZ4	EZ4	\N	\N				\N	\N	t
4561	4561	unknown	unbekannt	inconnu	\N	\N				\N	\N	t
\.


--
-- Data for Name: data_media_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.data_media_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3784	3784	other	andere	autre	\N	\N				\N	\N	t
3785	3785	CD	CD	CD	\N	\N				\N	\N	t
3786	3786	floppy_disc	Diskette	disquette	\N	\N				\N	\N	t
3787	3787	dvd	DVD	DVD	\N	\N				\N	\N	t
3788	3788	harddisc	Festplatte	disque_dur	\N	\N				\N	\N	t
3789	3789	server	Server	serveur	\N	\N				\N	\N	t
3790	3790	videotape	Videoband	bande_video	\N	\N				\N	\N	t
\.


--
-- Data for Name: discharge_point_relevance; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.discharge_point_relevance (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5580	5580	relevant_for_water_course	gewaesserrelevant	pertinent_pour_milieu_recepteur	zzz_gewaesserrelevant	relevanta_pentru_mediul_receptor						t
5581	5581	non_relevant_for_water_course	nicht_gewaesserrelevant	insignifiant_pour_milieu_recepteur	zzz_nicht_gewaesserrelevant	nerelevanta_pentru_mediul_receptor						t
\.


--
-- Data for Name: drainage_system_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.drainage_system_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4783	4783	amelioration	Melioration	melioration	zzz_Melioration							t
2722	2722	mixed_system	Mischsystem	systeme_unitaire	sistema_misto							t
2724	2724	modified_system	ModifiziertesSystem	systeme_modifie	sistema_modificato							t
4544	4544	not_connected	nicht_angeschlossen	non_raccorde	non_collegato							t
2723	2723	separated_system	Trennsystem	systeme_separatif	sistema_separato							t
3060	3060	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: dryweather_flume_material; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.dryweather_flume_material (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3221	3221	other	andere	autres	altri	alta	O	A	AU			t
354	354	combined	kombiniert	combine	zzz_kombiniert	combinata		KOM	COM			t
5356	5356	plastic	Kunststoff	matiere_synthetique	zzz_Kunststoff	materie_sintetica		KU	MS			t
238	238	stoneware	Steinzeug	gres	gres	gresie		STZ	GR			t
3017	3017	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
237	237	cement_mortar	Zementmoertel	mortier_de_ciment	zzz_Zementmoertel	mortar_ciment		ZM	MC			t
\.


--
-- Data for Name: electric_equipment_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.electric_equipment_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2980	2980	other	andere	autres	altri							t
376	376	illumination	Beleuchtung	eclairage	zzz_Beleuchtung							t
3255	3255	remote_control_system	Fernwirkanlage	installation_de_telecommande	zzz_Fernwirkanlage							t
378	378	radio_unit	Funk	radio	zzz_Funk							t
377	377	phone	Telephon	telephone	telefono							t
3038	3038	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: electromechanical_equipment_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.electromechanical_equipment_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2981	2981	other	andere	autres	altri							t
380	380	leakage_water_pump	Leckwasserpumpe	pompe_d_epuisement	zzz_Leckwasserpumpe							t
337	337	air_dehumidifier	Luftentfeuchter	deshumidificateur	zzz_Luftentfeuchter							t
381	381	scraper_installation	Raeumeinrichtung	dispositif_de_curage	zzz_Raeumeinrichtung							t
3072	3072	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: examination_recording_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.examination_recording_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3681	3681	other	andere	autre	\N	\N				\N	\N	t
3682	3682	field_visit	Begehung	parcours	\N	\N				\N	\N	t
3683	3683	deformation_measurement	Deformationsmessung	mesure_deformation	\N	\N				\N	\N	t
3684	3684	leak_test	Dichtheitspruefung	examen_etancheite	\N	\N				\N	\N	t
3685	3685	georadar	Georadar	georadar	\N	\N				\N	\N	t
3686	3686	channel_TV	Kanalfernsehen	camera_canalisations	\N	\N				\N	\N	t
3687	3687	unknown	unbekannt	inconnu	\N	\N				\N	\N	t
\.


--
-- Data for Name: examination_weather; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.examination_weather (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3699	3699	covered_rainy	bedeckt_regnerisch	couvert_pluvieux	\N	\N				\N	\N	t
3700	3700	drizzle	Nieselregen	bruine	\N	\N				\N	\N	t
3701	3701	rain	Regen	pluie	\N	\N				\N	\N	t
3702	3702	snowfall	Schneefall	chute_neige	\N	\N				\N	\N	t
3703	3703	nice_dry	schoen_trocken	beau_sec	\N	\N				\N	\N	t
3704	3704	unknown	unbekannt	inconnu	\N	\N				\N	\N	t
\.


--
-- Data for Name: file_class; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.file_class (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3800	3800	throttle_shut_off_unit	Absperr_Drosselorgan	LIMITEUR_DEBIT	\N	\N				\N	\N	t
3801	3801	wastewater_structure	Abwasserbauwerk	OUVRAGE_RESEAU_AS	\N	\N				\N	\N	t
3802	3802	waster_water_treatment	Abwasserbehandlung	TRAITEMENT_EAUX_USEES	\N	\N				\N	\N	t
3803	3803	wastewater_node	Abwasserknoten	NOEUD_RESEAU	\N	\N				\N	\N	t
3804	3804	wastewater_networkelement	Abwassernetzelement	ELEMENT_RESEAU_EVACUATION	\N	\N				\N	\N	t
3805	3805	waste_water_treatment_plant	Abwasserreinigungsanlage	STATION_EPURATION	\N	\N				\N	\N	t
3806	3806	waste_water_association	Abwasserverband	ASSOCIATION_EPURATION_EAU	\N	\N				\N	\N	t
3807	3807	administrative_office	Amt	OFFICE	\N	\N				\N	\N	t
3808	3808	connection_object	Anschlussobjekt	OBJET_RACCORDE	\N	\N				\N	\N	t
3809	3809	wwtp_structure	ARABauwerk	OUVRAGES_STEP	\N	\N				\N	\N	t
3810	3810	wwtp_energy_use	ARAEnergienutzung	CONSOMMATION_ENERGIE_STEP	\N	\N				\N	\N	t
3811	3811	bathing_area	Badestelle	LIEU_BAIGNADE	\N	\N				\N	\N	t
3812	3812	benching	Bankett	BANQUETTE	\N	\N				\N	\N	t
3813	3813	structure_part	BauwerksTeil	ELEMENT_OUVRAGE	\N	\N				\N	\N	t
3814	3814	well	Brunnen	FONTAINE	\N	\N				\N	\N	t
3815	3815	file	Datei	FICHIER	\N	\N				\N	\N	t
3816	3816	data_media	Datentraeger	SUPPORT_DONNEES	\N	\N				\N	\N	t
3817	3817	cover	Deckel	COUVERCLE	\N	\N				\N	\N	t
3818	3818	passage	Durchlass	PASSAGE_SOUS_TUYAU	\N	\N				\N	\N	t
5083	5083	discharge_point	Einleitstelle	EXUTOIRE	\N	\N				\N	\N	t
3819	3819	access_aid	Einstiegshilfe	DISPOSITIF_ACCES	\N	\N				\N	\N	t
3820	3820	individual_surface	Einzelflaeche	SURFACE_INDIVIDUELLE	\N	\N				\N	\N	t
3821	3821	catchment_area	Einzugsgebiet	BASSIN_VERSANT	\N	\N				\N	\N	t
3822	3822	electric_equipment	ElektrischeEinrichtung	EQUIPEMENT_ELECTRIQUE	\N	\N				\N	\N	t
3823	3823	electromechanical_equipment	ElektromechanischeAusruestung	EQUIPEMENT_ELECTROMECA	\N	\N				\N	\N	t
3824	3824	drainage_system	Entwaesserungssystem	systeme_evacuation_eaux	\N	\N				\N	\N	t
3825	3825	maintenance_event	Erhaltungsereignis	EVENEMENT_MAINTENANCE	\N	\N				\N	\N	t
3826	3826	fish_pass	Fischpass	ECHELLE_POISSONS	\N	\N				\N	\N	t
3827	3827	river	Fliessgewaesser	COURS_EAU	\N	\N				\N	\N	t
3828	3828	pump	FoerderAggregat	INSTALLATION_REFOULEMENT	\N	\N				\N	\N	t
3829	3829	ford	Furt	PASSAGE_A_GUE	\N	\N				\N	\N	t
3830	3830	building	Gebaeude	BATIMENT	\N	\N				\N	\N	t
3831	3831	hazard_source	Gefahrenquelle	SOURCE_DANGER	\N	\N				\N	\N	t
3832	3832	municipality	Gemeinde	COMMUNE	\N	\N				\N	\N	t
3833	3833	blocking_debris	Geschiebesperre	BARRAGE_ALLUVIONS	\N	\N				\N	\N	t
3834	3834	water_course_segment	Gewaesserabschnitt	TRONCON_COURS_EAU	\N	\N				\N	\N	t
3835	3835	chute	GewaesserAbsturz	SEUIL	\N	\N				\N	\N	t
3836	3836	water_body_protection_sector	Gewaesserschutzbereich	SECTEUR_PROTECTION_EAUX	\N	\N				\N	\N	t
3837	3837	sector_water_body	Gewaessersektor	SECTEUR_EAUX_SUP	\N	\N				\N	\N	t
3838	3838	river_bed	Gewaessersohle	FOND_COURS_EAU	\N	\N				\N	\N	t
3839	3839	water_control_structure	Gewaesserverbauung	AMENAGEMENT_COURS_EAU	\N	\N				\N	\N	t
3840	3840	dam	GewaesserWehr	OUVRAGE_RETENUE	\N	\N				\N	\N	t
3841	3841	aquifier	Grundwasserleiter	AQUIFERE	\N	\N				\N	\N	t
3842	3842	ground_water_protection_perimeter	Grundwasserschutzareal	PERIMETRE_PROT_EAUX_SOUT	\N	\N				\N	\N	t
3843	3843	groundwater_protection_zone	Grundwasserschutzzone	ZONE_PROT_EAUX_SOUT	\N	\N				\N	\N	t
3844	3844	reach	Haltung	TRONCON	\N	\N				\N	\N	t
3845	3845	reach_point	Haltungspunkt	POINT_TRONCON	\N	\N				\N	\N	t
3846	3846	hq_relation	HQ_Relation	RELATION_HQ	\N	\N				\N	\N	t
3847	3847	hydr_geometry	Hydr_Geometrie	GEOMETRIE_HYDR	\N	\N				\N	\N	t
3848	3848	hydr_geom_relation	Hydr_GeomRelation	RELATION_GEOM_HYDR	\N	\N				\N	\N	t
3849	3849	channel	Kanal	CANALISATION	\N	\N				\N	\N	t
3850	3850	damage_channel	Kanalschaden	DOMMAGE_AUX_CANALISATIONS	\N	\N				\N	\N	t
3851	3851	canton	Kanton	CANTON	\N	\N				\N	\N	t
3852	3852	leapingweir	Leapingwehr	LEAPING_WEIR	\N	\N				\N	\N	t
3853	3853	mechanical_pretreatment	MechanischeVorreinigung	PRETRAITEMENT_MECANIQUE	\N	\N				\N	\N	t
3854	3854	measurement_device	Messgeraet	APPAREIL_MESURE	\N	\N				\N	\N	t
3855	3855	measurement_series	Messreihe	SERIE_MESURES	\N	\N				\N	\N	t
3856	3856	measurement_result	Messresultat	RESULTAT_MESURE	\N	\N				\N	\N	t
3857	3857	measuring_point	Messstelle	STATION_MESURE	\N	\N				\N	\N	t
3858	3858	standard_manhole	Normschacht	CHAMBRE_STANDARD	\N	\N				\N	\N	t
3859	3859	damage_manhole	Normschachtschaden	DOMMAGE_CHAMBRE_STANDARD	\N	\N				\N	\N	t
3861	3861	surface_runoff_parameters	Oberflaechenabflussparameter	PARAM_ECOULEMENT_SUP	\N	\N				\N	\N	t
3862	3862	surface_water_bodies	Oberflaechengewaesser	EAUX_SUPERFICIELLES	\N	\N				\N	\N	t
3863	3863	organisation	Organisation	ORGANISATION	\N	\N				\N	\N	t
3864	3864	planning_zone	Planungszone	ZONE_RESERVEE	\N	\N				\N	\N	t
3865	3865	private	Privat	PRIVE	\N	\N				\N	\N	t
3866	3866	cleaning_device	Reinigungseinrichtung	DISPOSITIF_NETTOYAGE	\N	\N				\N	\N	t
3867	3867	reservoir	Reservoir	RESERVOIR	\N	\N				\N	\N	t
3868	3868	retention_body	Retentionskoerper	VOLUME_RETENTION	\N	\N				\N	\N	t
3869	3869	pipe_profile	Rohrprofil	PROFIL_TUYAU	\N	\N				\N	\N	t
3870	3870	profile_geometry	Rohrprofil_Geometrie	PROFIL_TUYAU_GEOM	\N	\N				\N	\N	t
3871	3871	damage	Schaden	DOMMAGE	\N	\N				\N	\N	t
3872	3872	sludge_treatment	Schlammbehandlung	TRAITEMENT_BOUES	\N	\N				\N	\N	t
3873	3873	lock	Schleuse	ECLUSE	\N	\N				\N	\N	t
3874	3874	lake	See	LAC	\N	\N				\N	\N	t
3875	3875	rock_ramp	Sohlrampe	RAMPE	\N	\N				\N	\N	t
3876	3876	special_structure	Spezialbauwerk	OUVRAGE_SPECIAL	\N	\N				\N	\N	t
3877	3877	control_center	Steuerungszentrale	CENTRALE_COMMANDE	\N	\N				\N	\N	t
3878	3878	substance	Stoff	SUBSTANCE	\N	\N				\N	\N	t
3879	3879	prank_weir	Streichwehr	DEVERSOIR_LATERAL	\N	\N				\N	\N	t
3880	3880	dryweather_downspout	Trockenwetterfallrohr	TUYAU_CHUTE	\N	\N				\N	\N	t
3881	3881	dryweather_flume	Trockenwetterrinne	CUNETTE_DEBIT_TEMPS_SEC	\N	\N				\N	\N	t
3882	3882	overflow	Ueberlauf	DEVERSOIR	\N	\N				\N	\N	t
3883	3883	overflow_characteristic	Ueberlaufcharakteristik	CARACTERISTIQUES_DEVERSOIR	\N	\N				\N	\N	t
3884	3884	shore	Ufer	RIVE	\N	\N				\N	\N	t
3885	3885	accident	Unfall	ACCIDENT	\N	\N				\N	\N	t
3886	3886	inspection	Untersuchung	EXAMEN	\N	\N				\N	\N	t
3887	3887	infiltration_installation	Versickerungsanlage	INSTALLATION_INFILTRATION	\N	\N				\N	\N	t
3888	3888	infiltration_zone	Versickerungsbereich	ZONE_INFILTRATION	\N	\N				\N	\N	t
3890	3890	water_catchment	Wasserfassung	CAPTAGE	\N	\N				\N	\N	t
3891	3891	zone	Zone	ZONE	\N	\N				\N	\N	t
\.


--
-- Data for Name: file_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.file_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3770	3770	other	andere	autre	\N	\N				\N	\N	t
3771	3771	digital_vidoe	digitalesVideo	video_numerique	\N	\N				\N	\N	t
3772	3772	photo	Foto	photo	\N	\N				\N	\N	t
3773	3773	panoramo_film	Panoramofilm	film_panoramique	\N	\N				\N	\N	t
3774	3774	textfile	Textdatei	fichier_texte	\N	\N				\N	\N	t
3775	3775	video	Video	video	\N	\N				\N	\N	t
\.


--
-- Data for Name: groundwater_protection_zone_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.groundwater_protection_zone_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
440	440	S1	S1	S1	S1							t
441	441	S2	S2	S2	S2							t
442	442	S3	S3	S3	S3							t
3040	3040	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: hydraulic_char_data_is_overflowing; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.hydraulic_char_data_is_overflowing (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5774	5774	yes	ja	oui	si							t
5775	5775	no	nein	non	no							t
5778	5778	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: hydraulic_char_data_main_weir_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.hydraulic_char_data_main_weir_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6422	6422	leapingweir	Leapingwehr	LEAPING_WEIR	zzz_Leapingwehr							t
6420	6420	spillway_raised	Streichwehr_hochgezogen	deversoir_lateral_a_seuil_sureleve	stramazzo_laterale_alto							t
6421	6421	spillway_low	Streichwehr_niedrig	deversoir_lateral_a_seuil_abaisse	stamazzo_laterale_basso							t
\.


--
-- Data for Name: hydraulic_char_data_pump_characteristics; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.hydraulic_char_data_pump_characteristics (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6374	6374	alternating	alternierend	alterne	alternato							t
6375	6375	other	andere	autres	altri							t
6376	6376	single	einzeln	individuel	singolo							t
6377	6377	parallel	parallel	parallele	parallelo							t
6378	6378	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: hydraulic_char_data_pump_usage_current; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.hydraulic_char_data_pump_usage_current (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6361	6361	other	andere	autres	altri							t
6362	6362	creek_water	Bachwasser	eaux_cours_d_eau	acqua_corso_acqua	ape_curs_de_apa						t
6363	6363	discharged_combined_wastewater	entlastetes_Mischabwasser	eaux_mixtes_deversees	acque_miste_scaricate	ape_mixte_deversate						t
6364	6364	industrial_wastewater	Industrieabwasser	eaux_industrielles	acque_industriali	ape_industriale		CW	EUC			t
6365	6365	combined_wastewater	Mischabwasser	eaux_mixtes	acque_miste	ape_mixte		MW	EUM			t
6366	6366	rain_wastewater	Regenabwasser	eaux_pluviales	acque_meteoriche	apa_meteorica		RW	EUP			t
6367	6367	clean_wastewater	Reinabwasser	eaux_claires	acque_chiare	ape_conventional_curate		KW	EUR			t
6368	6368	wastewater	Schmutzabwasser	eaux_usees	acque_luride			SW	EU			t
6369	6369	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: hydraulic_char_data_status; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.hydraulic_char_data_status (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6371	6371	planned	geplant	prevu	pianificato							t
6372	6372	current	Ist	actuel	attuale							t
6373	6373	current_optimized	Ist_optimiert	actuel_opt	attuale_ottimizzato							t
\.


--
-- Data for Name: individual_surface_function; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.individual_surface_function (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2979	2979	other	andere	autres	altri							t
3466	3466	railway_site	Bahnanlagen	installation_ferroviaire	zzz_Bahnanlagen							t
3461	3461	roof_industrial_or_commercial_building	DachflaecheIndustrieundGewerbebetriebe	surface_toits_bat_industriels_artisanaux	zzz_DachflaecheIndustrieundGewerbebetriebe							t
3460	3460	roof_residential_or_office_building	DachflaecheWohnundBuerogebaeude	surface_toits_imm_habitation_administratifs	zzz_DachflaecheWohnundBuerogebaeude							t
3464	3464	access_or_collecting_road	Erschliessungs_Sammelstrassen	routes_de_desserte_et_collectives	zzz_Erschliessungs_Sammelstrassen							t
3467	3467	parking_lot	Parkplaetze	parkings	zzz_Parkplaetze							t
3462	3462	transfer_site_or_stockyard	UmschlagundLagerplaetze	places_transbordement_entreposage	zzz_UmschlagundLagerplaetze							t
3029	3029	unknown	unbekannt	inconnu	sconosciuto							t
3465	3465	connecting_or_principal_or_major_road	Verbindungs_Hauptverkehrs_Hochleistungsstrassen	routes_de_raccordement_principales_grand_trafic								t
3463	3463	forecourt_and_access_road	VorplaetzeZufahrten	places_devant_entree_acces	zzz_VorplaetzeZufahrten							t
\.


--
-- Data for Name: individual_surface_pavement; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.individual_surface_pavement (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2978	2978	other	andere	autres	altri							t
2031	2031	paved	befestigt	impermeabilise	zzz_befestigt							t
2032	2032	forested	bestockt	boise	zzz_bestockt							t
2033	2033	soil_covered	humusiert	couverture_vegetale	zzz_humusiert							t
3030	3030	unknown	unbekannt	inconnu	sconosciuto							t
2034	2034	barren	vegetationslos	sans_vegetation	zzz_vegetationslos							t
\.


--
-- Data for Name: infiltration_installation_defects; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_installation_defects (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5361	5361	none	keine	aucunes	nessuno	inexistente		K	AN			t
3276	3276	marginal	unwesentliche	modestes	zzz_unwesentliche	modeste		UW	MI			t
3275	3275	substantial	wesentliche	importantes	zzz_wesentliche	importante		W	MA			t
\.


--
-- Data for Name: infiltration_installation_emergency_spillway; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_installation_emergency_spillway (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5365	5365	in_combined_waste_water_drain	inMischwasserkanalisation	dans_canalisation_eaux_mixtes	zzz_inMischwasserkanalisation	in_canalizare_ape_mixte		IMK	CEM			t
3307	3307	in_rain_waste_water_drain	inRegenwasserkanalisation	dans_canalisation_eaux_pluviales	zzz_inRegenwasserkanalisation	in_canalizare_apa_meteorica		IRK	CEP			t
3304	3304	in_water_body	inVorfluter	au_cours_d_eau_recepteur	zzz_inVorfluter	in_curs_apa		IV	CE			t
3303	3303	none	keiner	aucun	nessuno	inexistent		K	AN			t
3305	3305	surface_discharge	oberflaechlichausmuendend	deversement_en_surface	zzz_oberflaechlichausmuendend	deversare_la_suprafata		OA	DS			t
3308	3308	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: infiltration_installation_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_installation_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3282	3282	with_soil_passage	andere_mit_Bodenpassage	autre_avec_passage_a_travers_sol	zzz_altri_mit_Bodenpassage	altul_cu_traversare_sol	WSP	AMB	APC			t
3285	3285	without_soil_passage	andere_ohne_Bodenpassage	autre_sans_passage_a_travers_sol	zzz_altri_ohne_Bodenpassage	altul_fara_traversare_sol	WOP	AOB	ASC			t
3279	3279	surface_infiltration	Flaechenfoermige_Versickerung	infiltration_superficielle_sur_place	zzz_Flaechenfoermige_Versickerung	infilitratie_de_suprafata		FV	IS			t
277	277	gravel_formation	Kieskoerper	corps_de_gravier	zzz_Kieskoerper	formatiune_de_pietris		KK	VG			t
3284	3284	combination_manhole_pipe	Kombination_Schacht_Strang	combinaison_puits_bande	zzz_Kombination_Schacht_Strang	combinatie_put_conducta		KOM	CPT			t
3281	3281	swale_french_drain_infiltration	MuldenRigolenversickerung	cuvettes_rigoles_filtrantes	zzz_MuldenRigolenversickerung	cuve_rigole_filtrante		MRV	ICR			t
3087	3087	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
3280	3280	percolation_over_the_shoulder	Versickerung_ueber_die_Schulter	infiltration_par_les_bas_cotes	zzz_Versickerung_ueber_die_Schulter	infilitratie_pe_la_cote_joase		VUS	IDB			t
276	276	infiltration_basin	Versickerungsbecken	bassin_d_infiltration	zzz_Versickerungsbecken	bazin_infiltrare		VB	BI			t
278	278	adsorbing_well	Versickerungsschacht	puits_d_infiltration	zzz_Versickerungsschacht	put_de_inflitrare		VS	PI			t
3283	3283	infiltration_pipe_sections_gallery	Versickerungsstrang_Galerie	bande_infiltration_galerie	zzz_Versickerungsstrang_Galerie	conducta_infiltrare_galerie		VG	TIG			t
\.


--
-- Data for Name: infiltration_installation_labeling; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_installation_labeling (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5362	5362	labeled	beschriftet	signalee	zzz_beschriftet	marcat	L	BS	SI			t
5363	5363	not_labeled	nichtbeschriftet	non_signalee	zzz_nichtbeschriftet	nemarcat		NBS	NSI			t
5364	5364	unknown	unbekannt	inconnue	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: infiltration_installation_seepage_utilization; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_installation_seepage_utilization (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
274	274	rain_water	Regenabwasser	eaux_pluviales	acque_meteoriche	ape_pluviale		RW	EP			t
273	273	clean_water	Reinabwasser	eaux_claires	acque_chiare	ape_conventional_curate		KW	EC			t
5359	5359	unknown	unbekannt	inconnue	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: infiltration_installation_vehicle_access; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_installation_vehicle_access (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3289	3289	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
3288	3288	inaccessible	unzugaenglich	inaccessible	non_accessibile	neaccesibil		ZU	IAC			t
3287	3287	accessible	zugaenglich	accessible	accessibile	accessibil		Z	AC			t
\.


--
-- Data for Name: infiltration_installation_watertightness; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_installation_watertightness (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3295	3295	not_watertight	nichtwasserdicht	non_etanche	zzz_nichtwasserdicht	neetans		NWD	NE			t
5360	5360	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
3294	3294	watertight	wasserdicht	etanche	zzz_wasserdicht	etans		WD	E			t
\.


--
-- Data for Name: infiltration_zone_infiltration_capacity; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.infiltration_zone_infiltration_capacity (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
371	371	good	gut	bonnes	zzz_gut							t
374	374	none	keine	aucune	nessuno	inexistent						t
372	372	moderate	maessig	moyennes	zzz_maessig							t
373	373	bad	schlecht	mauvaises	zzz_schlecht							t
3073	3073	unknown	unbekannt	inconnu	sconosciuto							t
2996	2996	not_allowed	unzulaessig	non_admis	zzz_unzulaessig							t
\.


--
-- Data for Name: leapingweir_opening_shape; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.leapingweir_opening_shape (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3581	3581	other	andere	autres	altri							t
3582	3582	circle	Kreis	circulaire	zzz_Kreis							t
3585	3585	parable	Parabel	parabolique	zzz_Parabel							t
3583	3583	rectangular	Rechteck	rectangulaire	zzz_Rechteck							t
3584	3584	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: maintenance_event_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.maintenance_event_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2982	2982	other	andere	autres	altri							t
120	120	replacement	Erneuerung	renouvellement	zzz_Erneuerung							t
28	28	cleaning	Reinigung	nettoyage	zzz_Reinigung							t
4529	4529	renovation	Renovierung	renovation	zzz_Renovierung							t
4528	4528	repair	Reparatur	reparation	zzz_Reparatur							t
4530	4530	restoration	Sanierung	rehabilitation	zzz_Sanierung							t
3045	3045	unknown	unbekannt	inconnu	sconosciuto							t
4564	4564	examination	Untersuchung	examen	zzz_Untersuchung							t
\.


--
-- Data for Name: maintenance_event_status; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.maintenance_event_status (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2550	2550	accomplished	ausgefuehrt	execute	zzz_ausgefuehrt							t
2549	2549	planned	geplant	prevu	previsto							t
3678	3678	not_possible	nicht_moeglich	impossible	zzz_nicht_moeglich							t
3047	3047	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: manhole_function; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.manhole_function (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4532	4532	drop_structure	Absturzbauwerk	ouvrage_de_chute	manufatto_caduta	instalatie_picurare	DS	AK	OC			t
5344	5344	other	andere	autre	altro	alta	O	A	AU			t
4533	4533	venting	Be_Entlueftung	aeration	zzz_Be_Entlueftung	aerisire	VE	BE	AE			t
3267	3267	rain_water_manhole	Dachwasserschacht	chambre_recolte_eaux_toitures	zzz_Dachwasserschacht	camin_vizitare_apa_meteorica	RWM	DS	CRT			t
3266	3266	gully	Einlaufschacht	chambre_avec_grille_d_entree	zzz_Einlaufschacht	gura_scurgere	G	ES	CG			t
3472	3472	drainage_channel	Entwaesserungsrinne	rigole_de_drainage	canaletta_drenaggio	rigola		ER	RD			t
228	228	rail_track_gully	Geleiseschacht	evacuation_des_eaux_des_voies_ferrees	zzz_Geleiseschacht	evacuare_ape_cale_ferata		GL	EVF			t
204	204	manhole	Kontrollschacht	regard_de_visite	pozzetto_ispezione	camin_vizitare		KS	CC			t
1008	1008	oil_separator	Oelabscheider	separateur_d_hydrocarbures	separatore_olii	separator_hidrocarburi	OS	OA	SH			t
4536	4536	pump_station	Pumpwerk	station_de_pompage	stazione_pompaggio	statie_pompare		PW	SP			t
5346	5346	stormwater_overflow	Regenueberlauf	deversoir_d_orage	scaricatore_piena	preaplin		HE	DO			t
2742	2742	slurry_collector	Schlammsammler	depotoir	pozzetto_decantazione	colector_aluviuni		SA	D			t
5347	5347	floating_material_separator	Schwimmstoffabscheider	separateur_de_materiaux_flottants	separatore_materiali_galleggianti	separator_materie_flotanta		SW	SMF			t
4537	4537	jetting_manhole	Spuelschacht	chambre_de_chasse	pozzetto_lavaggio	camin_spalare		SS	CC			t
4798	4798	separating_structure	Trennbauwerk	ouvrage_de_repartition	camera_ripartizione	separator		TB	OR			t
5345	5345	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
\.


--
-- Data for Name: manhole_material; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.manhole_material (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4540	4540	other	andere	autre	altro	altul						t
4541	4541	concrete	Beton	beton	zzz_Beton	beton						t
4542	4542	plastic	Kunststoff	matiere_plastique	zzz_Kunststoff	materie_plastica						t
4543	4543	unknown	unbekannt	inconnu	sconosciuto	necunoscut						t
\.


--
-- Data for Name: manhole_surface_inflow; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.manhole_surface_inflow (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5342	5342	other	andere	autre	altro	altul	O	A	AU			t
2741	2741	none	keiner	aucune	nessuno	niciunul		K	AN			t
2739	2739	grid	Rost	grille_d_ecoulement	zzz_Rost	grilaj		R	G			t
5343	5343	unknown	unbekannt	inconnue	sconosciuto	necunoscut		U	I			t
2740	2740	intake_from_side	Zulauf_seitlich	arrivee_laterale	zzz_Zulauf_seitlich	admisie_laterala		ZS	AL			t
\.


--
-- Data for Name: measurement_result_measurement_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.measurement_result_measurement_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5732	5732	other	andere	autres	altri							t
5733	5733	flow	Durchfluss	debit	zzz_Durchfluss							t
5734	5734	level	Niveau	niveau	livello							t
5735	5735	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: measurement_series_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.measurement_series_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3217	3217	other	andere	autres	altri							t
2646	2646	continuous	kontinuierlich	continu	zzz_kontinuierlich							t
2647	2647	rain_weather	Regenwetter	temps_de_pluie	tempo_pioggia							t
3053	3053	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: measuring_device_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.measuring_device_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5702	5702	other	andere	autres	altri							t
5703	5703	static_sounding_stick	Drucksonde	sonde_de_pression	sensore_pressione							t
5704	5704	bubbler_system	Lufteinperlung	injection_bulles_d_air	insufflazione							t
5705	5705	EMF_partly_filled	MID_teilgefuellt	MID_partiellement_rempli	DEM_riempimento_parziale							t
5706	5706	EMF_filled	MID_vollgefuellt	MID_rempli	DEM_riempimento_pieno							t
5707	5707	radar	Radar	radar	radar							t
5708	5708	float	Schwimmer	flotteur	galleggiante							t
6322	6322	ultrasound	Ultraschall	ultrason	zzz_Ultraschall							t
5709	5709	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: measuring_point_damming_device; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.measuring_point_damming_device (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5720	5720	other	andere	autres	altri							t
5721	5721	none	keiner	aucun	nessuno							t
5722	5722	overflow_weir	Ueberfallwehr	lame_deversante	sfioratore							t
5724	5724	unknown	unbekannt	inconnu	sconosciuto							t
5723	5723	venturi_necking	Venturieinschnuerung	etranglement_venturi	zzz_Venturieinschnuerung							t
\.


--
-- Data for Name: measuring_point_purpose; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.measuring_point_purpose (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4595	4595	both	beides	les_deux	entrambi							t
4593	4593	cost_sharing	Kostenverteilung	repartition_des_couts	ripartizione_costi							t
4594	4594	technical_purpose	technischer_Zweck	but_technique	scopo_tecnico							t
4592	4592	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: mechanical_pretreatment_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.mechanical_pretreatment_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3317	3317	filter_bag	Filtersack	percolateur	zzz_Filtersack							t
3319	3319	artificial_adsorber	KuenstlicherAdsorber	adsorbeur_artificiel	zzz_KuenstlicherAdsorber							t
3318	3318	swale_french_drain_system	MuldenRigolenSystem	systeme_cuvettes_rigoles	zzz_MuldenRigolenSystem							t
3320	3320	slurry_collector	Schlammsammler	collecteur_de_boue	pozzetto_decantazione							t
3321	3321	floating_matter_separator	Schwimmstoffabscheider	separateur_materiaux_flottants	separatore_materiali_galleggianti	separator_materie_flotanta						t
3322	3322	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: mutation_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.mutation_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5523	5523	created	erstellt	cree	zzz_erstellt							t
5582	5582	changed	geaendert	changee	zzz_geaendert							t
5583	5583	deleted	geloescht	effacee	zzz_geloescht							t
\.


--
-- Data for Name: overflow_actuation; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.overflow_actuation (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3667	3667	other	andere	autres	altri							t
301	301	gaz_engine	Benzinmotor	moteur_a_essence	zzz_Benzinmotor	motor_benzina						t
302	302	diesel_engine	Dieselmotor	moteur_diesel	zzz_Dieselmotor	motor_diesel						t
303	303	electric_engine	Elektromotor	moteur_electrique	zzz_Elektromotor	motor_electric						t
433	433	hydraulic	hydraulisch	hydraulique	zzz_hydraulisch	hidraulic						t
300	300	none	keiner	aucun	nessuno							t
305	305	manual	manuell	manuel	zzz_manuell	manual						t
304	304	pneumatic	pneumatisch	pneumatique	zzz_pneumatisch	pneumatic						t
3005	3005	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: overflow_adjustability; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.overflow_adjustability (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
355	355	fixed	fest	fixe	zzz_fest							t
3021	3021	unknown	unbekannt	inconnu	sconosciuto							t
356	356	adjustable	verstellbar	reglable	zzz_verstellbar							t
\.


--
-- Data for Name: overflow_char_kind_overflow_characteristic; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.overflow_char_kind_overflow_characteristic (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6220	6220	hq	HQ	HQ	HQ							t
6221	6221	qq	QQ	QQ	QQ							t
6228	6228	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: overflow_char_overflow_characteristic_digital; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.overflow_char_overflow_characteristic_digital (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6223	6223	yes	ja	oui	si							t
6224	6224	no	nein	non	no							t
6225	6225	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: overflow_control; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.overflow_control (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
308	308	closed_loop_control	geregelt	avec_regulation	zzz_geregelt							t
307	307	open_loop_control	gesteuert	avec_commande	zzz_gesteuert							t
306	306	none	keine	aucun	nessuno	inexistent						t
3028	3028	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: overflow_function; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.overflow_function (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3228	3228	other	andere	autres	altri							t
3384	3384	internal	intern	interne	zzz_intern							t
217	217	emergency_overflow	Notentlastung	deversoir_de_secours	zzz_Notentlastung							t
5544	5544	stormwater_overflow	Regenueberlauf	deversoir_d_orage	scaricatore_piena							t
5546	5546	internal_overflow	Trennueberlauf	deversoir_interne	zzz_Trennueberlauf							t
3010	3010	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: overflow_signal_transmission; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.overflow_signal_transmission (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2694	2694	receiving	empfangen	recevoir	zzz_empfangen							t
2693	2693	sending	senden	emettre	zzz_senden							t
2695	2695	sending_receiving	senden_empfangen	emettre_recevoir	zzz_senden_empfangen							t
3056	3056	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: pipe_profile_profile_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.pipe_profile_profile_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3351	3351	egg	Eiprofil	ovoide	ovoidale	ovoid	E	E	OV			t
3350	3350	circle	Kreisprofil	circulaire	cicolare	rotund	CI	K	CI	CI	R	t
3352	3352	mouth	Maulprofil	profil_en_voute	composto	sectiune_cu_bolta	M	M	V	C		t
3354	3354	open	offenes_Profil	profil_ouvert	sezione_aperta	profil_deschis	OP	OP	PO	SA		t
3353	3353	rectangular	Rechteckprofil	rectangulaire	rettangolare	dreptunghiular	R	R	R	R	D	t
3355	3355	special	Spezialprofil	profil_special	sezione_speciale	sectiune_speciala	S	S	PS	S	S	t
3357	3357	unknown	unbekannt	inconnu	sconosciuto	necunoscut	U	U	I	S	N	t
\.


--
-- Data for Name: planning_zone_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.planning_zone_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2990	2990	other	andere	autres	altri							t
31	31	commercial_zone	Gewerbezone	zone_artisanale	zzz_Gewerbezone							t
32	32	industrial_zone	Industriezone	zone_industrielle	zzz_Industriezone							t
30	30	agricultural_zone	Landwirtschaftszone	zone_agricole	zzz_Landwirtschaftszone							t
3077	3077	unknown	unbekannt	inconnu	sconosciuto							t
29	29	residential_zone	Wohnzone	zone_d_habitations	zzz_Wohnzone							t
\.


--
-- Data for Name: prank_weir_weir_edge; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.prank_weir_weir_edge (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2995	2995	other	andere	autres	altri							t
351	351	rectangular	rechteckig	angulaire	zzz_rechteckig							t
350	350	round	rund	arrondie	zzz_rund	rotund						t
349	349	sharp_edged	scharfkantig	arete_vive	zzz_scharfkantig	margini_ascutite						t
3014	3014	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: prank_weir_weir_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.prank_weir_weir_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5772	5772	raised	hochgezogen	a_seuil_sureleve	laterale_alto							t
5771	5771	low	niedrig	a_seuil_abaisse	laterale_basso							t
\.


--
-- Data for Name: pump_contruction_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.pump_contruction_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2983	2983	other	andere	autres	altri							t
2662	2662	compressed_air_system	Druckluftanlage	systeme_a_air_comprime	impianto_aria_compressa							t
314	314	piston_pump	Kolbenpumpe	pompe_a_piston	pompa_pistoni							t
309	309	centrifugal_pump	Kreiselpumpe	pompe_centrifuge	pompa_centrifuga							t
310	310	screw_pump	Schneckenpumpe	pompe_a_vis	pompa_a_vite							t
3082	3082	unknown	unbekannt	inconnu	sconosciuto							t
2661	2661	vacuum_system	Vakuumanlage	systeme_a_vide_d_air	impinato_a_vuoto_aria							t
\.


--
-- Data for Name: pump_placement_of_actuation; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.pump_placement_of_actuation (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
318	318	wet	nass	immerge	zzz_nass							t
311	311	dry	trocken	non_submersible	zzz_trocken							t
3070	3070	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: pump_placement_of_pump; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.pump_placement_of_pump (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
362	362	horizontal	horizontal	horizontal	zzz_horizontal							t
3071	3071	unknown	unbekannt	inconnu	sconosciuto							t
363	363	vertical	vertikal	vertical	zzz_vertikal							t
\.


--
-- Data for Name: pump_usage_current; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.pump_usage_current (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6325	6325	other	andere	autres	altri							t
6202	6202	creek_water	Bachwasser	eaux_cours_d_eau	acqua_corso_acqua	ape_curs_de_apa						t
6203	6203	discharged_combined_wastewater	entlastetes_Mischabwasser	eaux_mixtes_deversees	acque_miste_scaricate	ape_mixte_deversate	DCW	EW	EUD			t
6204	6204	industrial_wastewater	Industrieabwasser	eaux_industrielles	acque_industriali	ape_industriale		CW	EUC			t
6201	6201	combined_wastewater	Mischabwasser	eaux_mixtes	acque_miste	ape_mixte		MW	EUM			t
6205	6205	rain_wastewater	Regenabwasser	eaux_pluviales	acque_meteoriche	apa_meteorica		RW	EUP			t
6200	6200	clean_wastewater	Reinabwasser	eaux_claires	acque_chiare	ape_conventional_curate		KW	EUR			t
6206	6206	wastewater	Schmutzabwasser	eaux_usees	acque_luride			SW	EU			t
6326	6326	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: reach_elevation_determination; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_elevation_determination (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4780	4780	accurate	genau	precise	precisa	precisa		LG	P			t
4778	4778	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
4779	4779	inaccurate	ungenau	imprecise	impreciso	imprecisa		LU	IP			t
\.


--
-- Data for Name: reach_horizontal_positioning; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_horizontal_positioning (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5378	5378	accurate	genau	precise	precisa	precisa		LG	P			t
5379	5379	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
5380	5380	inaccurate	ungenau	imprecise	impreciso	imprecisa		LU	IP			t
\.


--
-- Data for Name: reach_inside_coating; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_inside_coating (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5383	5383	other	andere	autre	altro	alta	O	A	AU			t
248	248	coating	Anstrich_Beschichtung	peinture_revetement	zzz_Anstrich_Beschichtung	strat_vopsea	C	B	PR			t
250	250	brick_lining	Kanalklinkerauskleidung	revetement_en_brique	zzz_Kanalklinkerauskleidung	strat_caramida		KL	RB			t
251	251	stoneware_lining	Steinzeugauskleidung	revetement_en_gres	zzz_Steinzeugauskleidung	strat_gresie		ST	RG			t
5384	5384	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
249	249	cement_mortar_lining	Zementmoertelauskleidung	revetement_en_mortier_de_ciment	zzz_Zementmoertelauskleidung	strat_mortar_ciment		ZM	RM			t
\.


--
-- Data for Name: reach_material; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_material (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5381	5381	other	andere	autre	altro	alta	O	A	AU	A		t
2754	2754	asbestos_cement	Asbestzement	amiante_ciment	cemento_amianto	azbociment	AC	AZ	AC	CA		t
3638	3638	concrete_normal	Beton_Normalbeton	beton_normal	calcestruzzo_normale	beton_normal	CN	NB	BN	CN		t
3639	3639	concrete_insitu	Beton_Ortsbeton	beton_coule_sur_place	calcestruzzo_gettato_opera	beton_turnat_insitu	CI	OB	BCP	CGO		t
3640	3640	concrete_presspipe	Beton_Pressrohrbeton	beton_pousse_tube	calcestruzzo_spingitubo	beton_presstube	CP	PRB	BPT	CST		t
3641	3641	concrete_special	Beton_Spezialbeton	beton_special	calcestruzzo_speciale	beton_special	CS	SB	BS	CS		t
3256	3256	concrete_unknown	Beton_unbekannt	beton_inconnu	calcestruzzo_sconosciuto	beton_necunoscut	CU	BU	BI	CSC		t
147	147	fiber_cement	Faserzement	fibrociment	fibrocemento	fibrociment	FC	FZ	FC	FC		t
2755	2755	bricks	Gebrannte_Steine	terre_cuite	ceramica	teracota	BR	SG	TC	CE		t
148	148	cast_ductile_iron	Guss_duktil	fonte_ductile	ghisa_duttile	fonta_ductila	ID	GD	FD	GD		t
3648	3648	cast_gray_iron	Guss_Grauguss	fonte_grise	ghisa_grigia	fonta_cenusie	CGI	GG	FG	GG		t
5076	5076	plastic_epoxy_resin	Kunststoff_Epoxydharz	matiere_synthetique_resine_d_epoxy	materiale_sintetico_resina_epossidica	plastic_rasina_epoxi	PER	EP	EP	MSR		t
5077	5077	plastic_highdensity_polyethylene	Kunststoff_Hartpolyethylen	matiere_synthetique_polyethylene_dur	materiale_sintetico_polietilene_duro	plastic_PEHD	HPE	HPE	PD	MSP		t
5078	5078	plastic_polyester_GUP	Kunststoff_Polyester_GUP	matiere_synthetique_polyester_GUP	materiale_sintetico_poliestere_GUP	plastic_poliester_GUP	GUP	GUP	GUP	GUP		t
5079	5079	plastic_polyethylene	Kunststoff_Polyethylen	matiere_synthetique_polyethylene	materiale_sintetico_polietilene	plastic_PE	PE	PE	PE	PE		t
5080	5080	plastic_polypropylene	Kunststoff_Polypropylen	matiere_synthetique_polypropylene	materiale_sintetico_polipropilene	plastic_polipropilena	PP	PP	PP	PP		t
5081	5081	plastic_PVC	Kunststoff_Polyvinilchlorid	matiere_synthetique_PVC	materiale_sintetico_PVC	plastic_PVC	PVC	PVC	PVC	PVC		t
5382	5382	plastic_unknown	Kunststoff_unbekannt	matiere_synthetique_inconnue	materiale_sintetico_sconosciuto	plastic_necunoscut	PU	KUU	MSI	MSC		t
153	153	steel	Stahl	acier	acciaio	otel	ST	ST	AC	AC		t
3654	3654	steel_stainless	Stahl_rostfrei	acier_inoxydable	acciaio_inossidabile	inox	SST	STI	ACI	ACI		t
154	154	stoneware	Steinzeug	gres	gres	gresie	SW	STZ	GR	GR		t
2761	2761	clay	Ton	argile	argilla	argila	CL	T	AR	AR		t
3016	3016	unknown	unbekannt	inconnu	sconosciuto	necunoscut	U	U	I	SC		t
2762	2762	cement	Zement	ciment	cemento	ciment	C	Z	C	C		t
\.


--
-- Data for Name: reach_point_elevation_accuracy; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_point_elevation_accuracy (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3248	3248	more_than_6cm	groesser_6cm	plusque_6cm	piu_6cm	mai_mare_6cm		G06	S06			t
3245	3245	plusminus_1cm	plusminus_1cm	plus_moins_1cm	piu_meno_1cm	plus_minus_1cm		P01	P01			t
3246	3246	plusminus_3cm	plusminus_3cm	plus_moins_3cm	piu_meno_3cm	plus_minus_3cm		P03	P03			t
3247	3247	plusminus_6cm	plusminus_6cm	plus_moins_6cm	piu_meno_6cm	plus_minus_6cm		P06	P06			t
5376	5376	unknown	unbekannt	inconnue	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: reach_point_outlet_shape; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_point_outlet_shape (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5374	5374	round_edged	abgerundet	arrondie	zzz_abgerundet	rotunjita	RE	AR	AR			t
298	298	orifice	blendenfoermig	en_forme_de_seuil_ou_diaphragme	zzz_blendenfoermig	orificiu	O	BF	FSD			t
3358	3358	no_cross_section_change	keine_Querschnittsaenderung	pas_de_changement_de_section	zzz_keine_Querschnittsaenderung	fara_schimbare_sectiune		KQ	PCS			t
286	286	sharp_edged	scharfkantig	aretes_vives	zzz_scharfkantig	margini_ascutite		SK	AV			t
5375	5375	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
\.


--
-- Data for Name: reach_reliner_material; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_reliner_material (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6459	6459	other	andere	autre	zzz_andere	altul						t
6461	6461	epoxy_resin_glass_fibre_laminate	Epoxidharz_Glasfaserlaminat	resine_epoxy_lamine_en_fibre_de_verre	zzz_Epoxidharz_Glasfaserlaminat	rasina_epoxi_laminata_in_fibra_de_sticla						t
6460	6460	epoxy_resin_plastic_felt	Epoxidharz_Kunststofffilz	resine_epoxy_feutre_synthetique	zzz_Epoxidharz_Kunststofffilz	rasina_epoxi_asemanatoare_plastic						t
6483	6483	GUP_pipe	GUP_Rohr	tuyau_PRV	zzz_GUP_Rohr	conducta_PAFS						t
6462	6462	HDPE	HDPE	HDPE	HDPE	PEHD						t
6484	6484	isocyanate_resin_glass_fibre_laminate	Isocyanatharze_Glasfaserlaminat	isocyanat_resine_lamine_en_fibre_de_verre	zzz_Isocynatharze_Glasfaserlaminat	izocianat_rasina_laminat_in_fibra_sticla						t
6485	6485	isocyanate_resin_plastic_felt	Isocyanatharze_Kunststofffilz	isocyanat_resine_lamine_feutre_synthetique	zzz_Isocynatharze_Kunststofffilz	izocianat_rasina_laminat_asemanatoare_plastic						t
6464	6464	polyester_resin_glass_fibre_laminate	Polyesterharz_Glasfaserlaminat	resine_de_polyester_lamine_en_fibre_de_verre	zzz_Polyesterharz_Glasfaserlaminat	rasina_de_poliester_laminata_in_fibra_de_sticla						t
6463	6463	polyester_resin_plastic_felt	Polyesterharz_Kunststofffilz	resine_de_polyester_feutre_synthetique	zzz_Polyesterharz_Kunststofffilz	rasina_poliester_asemanatare_plastic						t
6482	6482	polypropylene	Polypropylen	polypropylene	polipropilene	polipropilena						t
6465	6465	PVC	Polyvinilchlorid	PVC	zzz_Polyvinilchlorid	PVC						t
6466	6466	bottom_with_polyester_concret_shell	Sohle_mit_Schale_aus_Polyesterbeton	radier_avec_pellicule_en_beton_polyester	zzz_Sohle_mit_Schale_aus_Polyesterbeton	radier_cu_pelicula_din_beton_poliester						t
6467	6467	unknown	unbekannt	inconnu	zzz_unbekannt	necunoscut						t
6486	6486	UP_resin_LED_synthetic_fibre_liner	UP_Harz_LED_Synthesefaserliner	UP_resine_LED_fibre_synthetiques_liner	zzz_UP_Harz_LED_Synthesefaserliner	rasina_UP_LED_captuseala_fibra_sintetica						t
6468	6468	vinyl_ester_resin_glass_fibre_laminate	Vinylesterharz_Glasfaserlaminat	resine_d_ester_vinylique_lamine_en_fibre_de_verre	zzz_Vinylesterharz_Glasfaserlaminat	rasina_de_ester_vinil_laminata_in_fibra_de_sticla						t
6469	6469	vinyl_ester_resin_plastic_felt	Vinylesterharz_Kunststofffilz	resine_d_ester_vinylique_feutre_synthetique	zzz_Vinylesterharz_Kunststofffilz	rasina_de_ester_vinil						t
\.


--
-- Data for Name: reach_relining_construction; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_relining_construction (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6448	6448	other	andere	autre	zzz_andere	alta						t
6479	6479	close_fit_relining	Close_Fit_Relining	close_fit_relining	zzz_Close_Fit_Relining	reconditionare_close_fit						t
6449	6449	relining_short_tube	Kurzrohrrelining	relining_tube_court	zzz_Kurzrohrrelining	reconditionare_tub_scurt						t
6481	6481	grouted_in_place_lining	Noppenschlauchrelining	Noppenschlauchrelining	zzz_Noppenschlauchrelining	chituire						t
6452	6452	partial_liner	Partieller_Liner	liner_partiel	zzz_Partieller_Liner	captuseala_partiala						t
6450	6450	pipe_string_relining	Rohrstrangrelining	chemisage_par_ligne_de_tuyau	zzz_Rohrstrangrelining	pipe_string_relining						t
6451	6451	hose_relining	Schlauchrelining	chemisage_par_gainage	zzz_Schlauchrelining	reconditionare_prin_camasuire						t
6453	6453	unknown	unbekannt	inconnu	zzz_unbekannt	necunoscuta						t
6480	6480	spiral_lining	Wickelrohrrelining	chemisage_par_tube_spirale	zzz_Wickelrohrrelining	captusire_prin_tub_spirala						t
\.


--
-- Data for Name: reach_relining_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_relining_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6455	6455	full_reach	ganze_Haltung	troncon_entier	zzz_ganze_Haltung	tronson_intreg						t
6456	6456	partial	partiell	partiellement	zzz_partiell	partial						t
6457	6457	unknown	unbekannt	inconnu	sconosciuto	necunoscut						t
\.


--
-- Data for Name: reach_text_plantype; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_text_plantype (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7844	7844	pipeline_registry	Leitungskataster	cadastre_des_conduites_souterraines	catasto_delle_canalizzazioni							t
7846	7846	overviewmap.om10	Uebersichtsplan.UeP10	plan_d_ensemble.pe10	piano_di_insieme.pi10							t
7847	7847	overviewmap.om2	Uebersichtsplan.UeP2	plan_d_ensemble.pe2	piano_di_insieme.pi2							t
7848	7848	overviewmap.om5	Uebersichtsplan.UeP5	plan_d_ensemble.pe5	piano_di_insieme.pi5							t
7845	7845	network_plan	Werkplan	plan_de_reseau								t
\.


--
-- Data for Name: reach_text_texthali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_text_texthali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7850	7850	0	0	0	0	0						t
7851	7851	1	1	1	1	1						t
7852	7852	2	2	2	2	2						t
\.


--
-- Data for Name: reach_text_textvali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.reach_text_textvali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7853	7853	0	0	0	0	0						t
7854	7854	1	1	1	1	1						t
7855	7855	2	2	2	2	2						t
7856	7856	3	3	3	3	3						t
7857	7857	4	4	4	4	4						t
\.


--
-- Data for Name: retention_body_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.retention_body_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2992	2992	other	andere	autres	altri							t
346	346	retention_in_habitat	Biotop	retention_dans_bassins_et_depressions	zzz_Biotop							t
345	345	roof_retention	Dachretention	retention_sur_toits	zzz_Dachretention							t
348	348	parking_lot	Parkplatz	retention_sur_routes_et_places	zzz_Parkplatz							t
347	347	accumulation_channel	Staukanal	retention_dans_canalisations_stockage	zzz_Staukanal							t
3031	3031	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: river_bank_control_grade_of_river; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bank_control_grade_of_river (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
341	341	none	keine	nul	nessuno	inexistent						t
2612	2612	moderate	maessig	moyen	zzz_maessig							t
2613	2613	strong	stark	fort	zzz_stark							t
2614	2614	predominantly	ueberwiegend	preponderant	zzz_ueberwiegend							t
3026	3026	unknown	unbekannt	inconnu	sconosciuto							t
2611	2611	sporadic	vereinzelt	localise	zzz_vereinzelt							t
2615	2615	complete	vollstaendig	total	zzz_vollstaendig							t
\.


--
-- Data for Name: river_bank_river_control_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bank_river_control_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3489	3489	other_impermeable	andere_dicht	autres_impermeables	zzz_altri_dicht							t
3486	3486	concrete_chequer_brick_impermeable	Betongitterstein_dicht	brique_perforee_en_beton_impermeable	zzz_Betongitterstein_dicht							t
3485	3485	wood_permeable	Holz_durchlaessig	bois_permeable	zzz_Holz_durchlaessig							t
3482	3482	no_control_structure	keine_Verbauung	aucun_amenagement	zzz_keine_Verbauung							t
3483	3483	living_control_structure_permeable	Lebendverbau_durchlaessig	materiau_vegetal_permeable	zzz_Lebendverbau_durchlaessig							t
3488	3488	wall_impermeable	Mauer_dicht	mur_impermeable	zzz_Mauer_dicht							t
3487	3487	natural_stone_impermeable	Naturstein_dicht	pierre_naturelle_impermeable	zzz_Naturstein_dicht							t
3484	3484	loose_natural_stone_permeable	Naturstein_locker_durchlaessig	pierre_naturelle_lache	zzz_Naturstein_locker_durchlaessig							t
3080	3080	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: river_bank_shores; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bank_shores (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
404	404	inappropriate_to_river	gewaesserfremd	atypique_d_un_cours_d_eau	zzz_gewaesserfremd							t
403	403	appropriate_to_river	gewaessergerecht	typique_d_un_cours_d_eau	zzz_gewaessergerecht							t
405	405	artificial	kuenstlich	artificielle	zzz_kuenstlich							t
3081	3081	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: river_bank_side; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bank_side (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
420	420	left	links	gauche	zzz_links							t
421	421	right	rechts	droite	zzz_rechts							t
3065	3065	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: river_bank_utilisation_of_shore_surroundings; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bank_utilisation_of_shore_surroundings (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
424	424	developed_area	Bebauungen	constructions	zzz_Bebauungen							t
425	425	grassland	Gruenland	espaces_verts	zzz_Gruenland							t
3068	3068	unknown	unbekannt	inconnu	sconosciuto							t
426	426	forest	Wald	foret	zzz_Wald							t
\.


--
-- Data for Name: river_bank_vegetation; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bank_vegetation (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
325	325	missing	fehlend	absente	zzz_fehlend							t
323	323	typical_for_habitat	standorttypisch	typique_du_lieu	zzz_standorttypisch							t
324	324	atypical_for_habitat	standortuntypisch	non_typique_du_lieu	zzz_standortuntypisch							t
3025	3025	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: river_bed_control_grade_of_river; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bed_control_grade_of_river (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
142	142	none	keine	nul	nessuno	inexistent						t
2607	2607	moderate	maessig	moyen	zzz_maessig							t
2608	2608	heavily	stark	fort	zzz_stark							t
2609	2609	predominantly	ueberwiegend	preponderant	zzz_ueberwiegend							t
3085	3085	unknown	unbekannt	inconnu	sconosciuto							t
2606	2606	sporadic	vereinzelt	localise	zzz_vereinzelt							t
2610	2610	complete	vollstaendig	total	zzz_vollstaendig							t
\.


--
-- Data for Name: river_bed_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bed_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
290	290	hard	hart	dur	zzz_hart							t
3089	3089	unknown	unbekannt	inconnu	sconosciuto							t
289	289	soft	weich	tendre	zzz_weich							t
\.


--
-- Data for Name: river_bed_river_control_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_bed_river_control_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3481	3481	other_impermeable	andere_dicht	autres_impermeables	zzz_altri_dicht							t
338	338	concrete_chequer_brick	Betongittersteine	briques_perforees_en_beton	zzz_Betongittersteine							t
3479	3479	wood	Holz	bois	zzz_Holz							t
3477	3477	no_control_structure	keine_Verbauung	aucun_amenagement	zzz_keine_Verbauung							t
3478	3478	rock_fill_or_loose_boulders	Steinschuettung_Blockwurf	pierres_naturelles	zzz_Steinschuettung_Blockwurf							t
3079	3079	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: river_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.river_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3397	3397	englacial_river	Gletscherbach	ruisseau_de_glacier	zzz_Gletscherbach							t
3399	3399	moor_creek	Moorbach	ruisseau_de_tourbiere	zzz_Moorbach							t
3398	3398	lake_outflow	Seeausfluss	effluent_d_un_lac	zzz_Seeausfluss							t
3396	3396	travertine_river	Travertinbach	ruisseau_sur_fond_tufcalcaire	zzz_Travertinbach							t
3400	3400	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: rock_ramp_stabilisation; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.rock_ramp_stabilisation (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2635	2635	other_smooth	andere_glatt	autres_lisse	zzz_altri_glatt							t
2634	2634	other_rough	andere_rauh	autres_rugueux	zzz_altri_rauh							t
415	415	concrete_channel	Betonrinne	lit_en_beton	zzz_Betonrinne							t
412	412	rocks_or_boulders	Blockwurf	enrochement	zzz_Blockwurf							t
413	413	paved	gepflaestert	pavement	zzz_gepflaestert							t
414	414	wooden_beam	Holzbalken	poutres_en_bois	zzz_Holzbalken							t
3063	3063	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: sector_water_body_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.sector_water_body_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2657	2657	waterbody	Gewaesser	lac_ou_cours_d_eau	zzz_Gewaesser							t
2729	2729	parallel_section	ParallelerAbschnitt	troncon_parallele	zzz_ParallelerAbschnitt							t
2728	2728	lake_traversal	Seetraverse	element_traversant_un_lac	zzz_Seetraverse							t
2656	2656	shore	Ufer	rives	zzz_Ufer							t
3054	3054	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: sludge_treatment_stabilisation; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.sludge_treatment_stabilisation (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
141	141	aerob_cold	aerobkalt	aerobie_froid	zzz_aerobkalt							t
332	332	aerobthermophil	aerobthermophil	aerobie_thermophile	zzz_aerobthermophil							t
333	333	anaerob_cold	anaerobkalt	anaerobie_froid	zzz_anaerobkalt							t
334	334	anaerob_mesophil	anaerobmesophil	anaerobie_mesophile	zzz_anaerobmesophil							t
335	335	anaerob_thermophil	anaerobthermophil	anaerobie_thermophile	zzz_anaerobthermophil							t
2994	2994	other	andere	autres	altri							t
3004	3004	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: solids_retention_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.solids_retention_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5664	5664	other	andere	autres	altri							t
5665	5665	fine_screen	Feinrechen	grille_fine	griglia_fine							t
5666	5666	coarse_screen	Grobrechen	grille_grossiere	griglia_grossa							t
5667	5667	sieve	Sieb	tamis	filtro							t
5668	5668	scumboard	Tauchwand	paroi_plongeante	parete_sommersa							t
5669	5669	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: special_structure_bypass; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.special_structure_bypass (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2682	2682	inexistent	nicht_vorhanden	inexistant	zzz_nicht_vorhanden	inexistent		NV	IE			t
3055	3055	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
2681	2681	existent	vorhanden	existant	zzz_vorhanden	existent		V	E			t
\.


--
-- Data for Name: special_structure_emergency_spillway; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.special_structure_emergency_spillway (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5866	5866	other	andere	autres	altri	altele						t
5864	5864	in_combined_waste_water_drain	inMischabwasserkanalisation	dans_canalisation_eaux_mixtes	in_canalizzazione_acque_miste	in_canalizare_apa_mixta						t
5865	5865	in_rain_waste_water_drain	inRegenabwasserkanalisation	dans_canalisation_eaux_pluviales	in_canalizzazione_acque_meteoriche	in_canalizare_apa_meteorica						t
5863	5863	in_waste_water_drain	inSchmutzabwasserkanalisation	dans_canalisation_eaux_usees	in_canalizzazione_acque_luride	in_canalizare_apa_uzata						t
5878	5878	none	keiner	aucun	nessuno	niciunul						t
5867	5867	unknown	unbekannt	inconnu	sconosciuto	necunoscut						t
\.


--
-- Data for Name: special_structure_function; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.special_structure_function (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
6397	6397	pit_without_drain	abflussloseGrube	fosse_etanche	zzz_abflussloseGrube	bazin_vidanjabil						t
245	245	drop_structure	Absturzbauwerk	ouvrage_de_chute	manufatto_caduta	instalatie_picurare	DS	AK	OC			t
6398	6398	hydrolizing_tank	Abwasserfaulraum	fosse_digestive	zzz_Abwasserfaulraum	fosa_hidroliza						t
5371	5371	other	andere	autre	altro	alta	O	A	AU			t
386	386	venting	Be_Entlueftung	aeration	zzz_Be_Entlueftung	aerisire	VE	BE	AE			t
3234	3234	inverse_syphon_chamber	Duekerkammer	chambre_avec_siphon_inverse	zzz_Duekerkammer	instalatie_cu_sifon_inversat	ISC	DK	SI			t
5091	5091	syphon_head	Duekeroberhaupt	entree_de_siphon	zzz_Duekeroberhaupt	cap_sifon	SH	DO	ESI			t
6399	6399	septic_tank_two_chambers	Faulgrube	fosse_septique	zzz_Faulgrube	fosa_septica_2_compartimente						t
3348	3348	terrain_depression	Gelaendemulde	depression_de_terrain	zzz_Gelaendemulde	depresiune_teren		GM	DT			t
336	336	bolders_bedload_catchement_dam	Geschiebefang	depotoir_pour_alluvions	camera_ritenuta	colector_aluviuni		GF	DA			t
5494	5494	cesspit	Guellegrube	fosse_a_purin	zzz_Guellegrube	hazna						t
6478	6478	septic_tank	Klaergrube	fosse_de_decantation	fossa_settica	fosa_septica		KG	FD			t
2998	2998	manhole	Kontrollschacht	regard_de_visite	pozzetto_ispezione	camin_vizitare		KS	RV			t
2768	2768	oil_separator	Oelabscheider	separateur_d_hydrocarbures	separatore_olii	separator_hidrocarburi		OA	SH			t
246	246	pump_station	Pumpwerk	station_de_pompage	stazione_pompaggio	statie_pompare		PW	SP			t
3673	3673	stormwater_tank_with_overflow	Regenbecken_Durchlaufbecken	BEP_decantation	zzz_Regenbecken_Durchlaufbecken	bazin_retentie_apa_meteorica_cu_preaplin		DB	BDE			t
3674	3674	stormwater_tank_retaining_first_flush	Regenbecken_Fangbecken	BEP_retention	bacino_accumulo	bazin_retentie_apa_meteorica_prima_spalare		FB	BRE			t
5574	5574	stormwater_retaining_channel	Regenbecken_Fangkanal	BEP_canal_retention	canale_accumulo	bazin_retentie	TRE	FK	BCR			t
3675	3675	stormwater_sedimentation_tank	Regenbecken_Regenklaerbecken	BEP_clarification	bacino_decantazione_acque_meteoriche	bazin_decantare		RKB	BCL			t
3676	3676	stormwater_retention_tank	Regenbecken_Regenrueckhaltebecken	BEP_accumulation	bacino_ritenzione	bazin_retentie_apa_meteorica		RRB	BAC			t
5575	5575	stormwater_retention_channel	Regenbecken_Regenrueckhaltekanal	BEP_canal_accumulation	canale_ritenzione	canal_retentie_apa_meteorica	TRC	RRK	BCA			t
5576	5576	stormwater_storage_channel	Regenbecken_Stauraumkanal	BEP_canal_stockage	canale_stoccaggio	bazin_stocare	TSC	SRK	BCS			t
3677	3677	stormwater_composite_tank	Regenbecken_Verbundbecken	BEP_combine	bacino_combinato			VB	BCO			t
5372	5372	stormwater_overflow	Regenueberlauf	deversoir_d_orage	scaricatore_piena	preaplin		RU	DO			t
5373	5373	floating_material_separator	Schwimmstoffabscheider	separateur_de_materiaux_flottants	separatore_materiali_galleggianti	separator_materie_flotanta		SW	SMF			t
383	383	side_access	seitlicherZugang	acces_lateral	zzz_seitlicherZugang	acces_lateral		SZ	AL			t
227	227	jetting_manhole	Spuelschacht	chambre_de_chasse	pozzetto_lavaggio	camin_spalare		SS	CC			t
4799	4799	separating_structure	Trennbauwerk	ouvrage_de_repartition	camera_ripartizione	separator		TB	OR			t
3008	3008	unknown	unbekannt	inconnu	sconosciuto	necunoscuta		U	I			t
2745	2745	vortex_manhole	Wirbelfallschacht	chambre_de_chute_a_vortex	zzz_Wirbelfallschacht	instalatie_picurare_cu_vortex		WF	CT			t
\.


--
-- Data for Name: special_structure_stormwater_tank_arrangement; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.special_structure_stormwater_tank_arrangement (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4608	4608	main_connection	Hauptschluss	connexion_directe	in_serie	conectare_directa		HS	CD			t
4609	4609	side_connection	Nebenschluss	connexion_laterale	in_parallelo	conectare_laterala		NS	CL			t
4610	4610	unknown	unbekannt	inconnue	sconosciuto	necunoscuta						t
\.


--
-- Data for Name: structure_part_renovation_demand; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.structure_part_renovation_demand (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
138	138	not_necessary	nicht_notwendig	pas_necessaire	zzz_nicht_notwendig	nenecesare	NN	NN	PN			t
137	137	necessary	notwendig	necessaire	zzz_notwendig	necesare	N	N	N			t
5358	5358	unknown	unbekannt	inconnue	sconosciuto	necunoscut		U	I			t
\.


--
-- Data for Name: symbol_plantype; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.symbol_plantype (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7874	7874	pipeline_registry	Leitungskataster	cadastre_des_conduites_souterraines	catasto_delle_canalizzazioni							t
7876	7876	overviewmap.om10	Uebersichtsplan.UeP10	plan_d_ensemble.pe10	piano_di_insieme.pi10							t
7877	7877	overviewmap.om2	Uebersichtsplan.UeP2	plan_d_ensemble.pe2	piano_di_insieme.pi2							t
7878	7878	overviewmap.om5	Uebersichtsplan.UeP5	plan_d_ensemble.pe5	piano_di_insieme.pi5							t
7875	7875	network_plan	Werkplan	plan_de_reseau	zzz_Werkplan							t
\.


--
-- Data for Name: tank_cleaning_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.tank_cleaning_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5621	5621	airjet	Air_Jet	aeration_et_brassage	airjet							t
5620	5620	other	andere	autre	altro							t
5622	5622	none	keine	aucun	nessuno	inexistent						t
5623	5623	surge_flushing	Schwallspuelung	rincage_en_cascade	zzz_Schwallspülung							t
5624	5624	tipping_bucket	Spuelkippe	bac_de_rincage	zzz_Spuelkippe							t
\.


--
-- Data for Name: tank_emptying_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.tank_emptying_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5626	5626	other	andere	autre	altro							t
5627	5627	none	keine	aucun	nessuno	inexistent						t
5628	5628	pump	Pumpe	pompe	pompa							t
5629	5629	valve	Schieber	vanne	zzz_Schieber							t
\.


--
-- Data for Name: text_plantype; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.text_plantype (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7844	7844	pipeline_registry	Leitungskataster	cadastre_des_conduites_souterraines	catasto_delle_canalizzazioni							t
7846	7846	overviewmap.om10	Uebersichtsplan.UeP10	plan_d_ensemble.pe10	piano_di_insieme.pi10							t
7847	7847	overviewmap.om2	Uebersichtsplan.UeP2	plan_d_ensemble.pe2	piano_di_insieme.pi2							t
7848	7848	overviewmap.om5	Uebersichtsplan.UeP5	plan_d_ensemble.pe5	piano_di_insieme.pi5							t
7845	7845	network_plan	Werkplan	plan_de_reseau								t
\.


--
-- Data for Name: text_texthali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.text_texthali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7850	7850	0	0	0	0	0						t
7851	7851	1	1	1	1	1						t
7852	7852	2	2	2	2	2						t
\.


--
-- Data for Name: text_textvali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.text_textvali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7853	7853	0	0	0	0	0						t
7854	7854	1	1	1	1	1						t
7855	7855	2	2	2	2	2						t
7856	7856	3	3	3	3	3						t
7857	7857	4	4	4	4	4						t
\.


--
-- Data for Name: throttle_shut_off_unit_actuation; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.throttle_shut_off_unit_actuation (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3213	3213	other	andere	autres	altri	altul						t
3154	3154	gaz_engine	Benzinmotor	moteur_a_essence	zzz_Benzinmotor	motor_benzina						t
3155	3155	diesel_engine	Dieselmotor	moteur_diesel	zzz_Dieselmotor	motor_diesel						t
3156	3156	electric_engine	Elektromotor	moteur_electrique	zzz_Elektromotor	motor_electric						t
3152	3152	hydraulic	hydraulisch	hydraulique	zzz_hydraulisch	hidraulic						t
3153	3153	none	keiner	aucun	nessuno	niciunul						t
3157	3157	manual	manuell	manuel	zzz_manuell	manual						t
3158	3158	pneumatic	pneumatisch	pneumatique	zzz_pneumatisch	pneumatic						t
3151	3151	unknown	unbekannt	inconnu	sconosciuto	necunoscut						t
\.


--
-- Data for Name: throttle_shut_off_unit_adjustability; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.throttle_shut_off_unit_adjustability (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3159	3159	fixed	fest	fixe	zzz_fest							t
3161	3161	unknown	unbekannt	inconnu	sconosciuto							t
3160	3160	adjustable	verstellbar	reglable	zzz_verstellbar							t
\.


--
-- Data for Name: throttle_shut_off_unit_control; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.throttle_shut_off_unit_control (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3162	3162	closed_loop_control	geregelt	avec_regulation	zzz_geregelt							t
3163	3163	open_loop_control	gesteuert	avec_commande	zzz_gesteuert							t
3165	3165	none	keine	aucun	nessuno	inexistent						t
3164	3164	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: throttle_shut_off_unit_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.throttle_shut_off_unit_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2973	2973	other	andere	autres	altri							t
2746	2746	orifice	Blende	diaphragme_ou_seuil	zzz_Blende	diafragma_sau_prag						t
2691	2691	stop_log	Dammbalken	batardeau	zzz_Dammbalken							t
252	252	throttle_flap	Drosselklappe	clapet_de_limitation	zzz_Drosselklappe							t
135	135	throttle_valve	Drosselschieber	vanne_de_limitation	zzz_Drosselschieber							t
6490	6490	throttle_section	Drosselstrecke	conduite_d_etranglement	zzz_Drosselstrecke							t
6491	6491	leapingweir	Leapingwehr	leaping_weir	zzz_Leapingwehr							t
6492	6492	pomp	Pumpe	pompe	zzz_Pumpe							t
2690	2690	backflow_flap	Rueckstauklappe	clapet_de_non_retour_a_battant	zzz_Rueckstauklappe	clapeta _antirefulare						t
2688	2688	valve	Schieber	vanne	zzz_Schieber							t
134	134	tube_throttle	Schlauchdrossel	limiteur_a_membrane	zzz_Schlauchdrossel							t
2689	2689	sliding_valve	Schuetze	vanne_ecluse	zzz_Schuetze	vana_cu?it						t
5755	5755	gate_shield	Stauschild	plaque_de_retenue	paratoia_cilindrica							t
3046	3046	unknown	unbekannt	inconnu	sconosciuto							t
133	133	whirl_throttle	Wirbeldrossel	limiteur_a_vortex	zzz_Wirbeldrossel							t
\.


--
-- Data for Name: throttle_shut_off_unit_signal_transmission; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.throttle_shut_off_unit_signal_transmission (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3171	3171	receiving	empfangen	recevoir	zzz_empfangen							t
3172	3172	sending	senden	emettre	zzz_senden							t
3169	3169	sending_receiving	senden_empfangen	emettre_recevoir	zzz_senden_empfangen							t
3170	3170	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: waste_water_treatment_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.waste_water_treatment_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3210	3210	other	andere	autres	altri							t
387	387	biological	biologisch	biologique	zzz_biologisch							t
388	388	chemical	chemisch	chimique	zzz_chemisch							t
389	389	filtration	Filtration	filtration	zzz_Filtration							t
366	366	mechanical	mechanisch	mecanique	zzz_mechanisch							t
3076	3076	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: wastewater_structure_accessibility; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_accessibility (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3444	3444	covered	ueberdeckt	couvert	coperto	capac		UED	CO			t
3447	3447	unknown	unbekannt	inconnu	sconosciuto	necunoscut		U	I			t
3446	3446	inaccessible	unzugaenglich	inaccessible	non_accessibile	inaccesibil		UZG	NA			t
3445	3445	accessible	zugaenglich	accessible	accessibile	accessibil		ZG	A			t
\.


--
-- Data for Name: wastewater_structure_financing; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_financing (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5510	5510	public	oeffentlich	public	pubblico	publica	PU	OE	PU			t
5511	5511	private	privat	prive	privato	privata	PR	PR	PR			t
5512	5512	unknown	unbekannt	inconnu	sconosciuto	necunoscuta	U	U	I			t
\.


--
-- Data for Name: wastewater_structure_renovation_necessity; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_renovation_necessity (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
5370	5370	urgent	dringend	urgente	urgente	urgent	UR	DR	UR			t
5368	5368	none	keiner	aucune	nessuno	niciuna	N	K	AN			t
2	2	short_term	kurzfristig	a_court_terme	breve_termine	termen_scurt	ST	KF	CT			t
4	4	long_term	langfristig	a_long_terme	lungo_termine	termen_lung	LT	LF	LT			t
3	3	medium_term	mittelfristig	a_moyen_terme	medio_termine	termen_mediu		MF	MT			t
5369	5369	unknown	unbekannt	inconnue	sconosciuto	necunoscuta		U	I			t
\.


--
-- Data for Name: wastewater_structure_rv_construction_type; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_rv_construction_type (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4602	4602	other	andere	autre	altro	altul						t
4603	4603	field	Feld	dans_les_champs	campo_aperto	in_camp	FI	FE	FE			t
4606	4606	renovation_conduction_excavator	Sanierungsleitung_Bagger	conduite_d_assainissement_retro	canalizazzione_risanmento_scavatrice	conducte_excavate	RCE	SBA	CAR			t
4605	4605	renovation_conduction_ditch_cutter	Sanierungsleitung_Grabenfraese	conduite_d_assainissement_trancheuse	condotta_risanamento_scavafossi	conducta_taiere_sant	RCD	SGF	CAT			t
4604	4604	road	Strasse	sous_route	strada	sub_strada	ST	ST	ST			t
4601	4601	unknown	unbekannt	inconnu	sconosciuto	necunoscut						t
\.


--
-- Data for Name: wastewater_structure_status; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_status (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3633	3633	inoperative	ausser_Betrieb	hors_service	fuori_servizio	rrr_ausser_Betrieb	NO	AB	H	FS		t
8493	8493	operational	in_Betrieb	en_service	in_funzione	functionala						t
6530	6530	operational.tentative	in_Betrieb.provisorisch	en_service.provisoire	in_funzione.provvisorio	functionala.provizoriu	T	T	P			t
6533	6533	operational.will_be_suspended	in_Betrieb.wird_aufgehoben	en_service.sera_supprime	in_funzione.da_eliminare	functionala.va_fi_eliminata		WA	SS			t
6523	6523	abanndoned.suspended_not_filled	tot.aufgehoben_nicht_verfuellt	abandonne.supprime_non_demoli	abbandonato.eliminato_non_demolito	abandonata.eliminare_necompletata	SN	AN	S			t
6524	6524	abanndoned.suspended_unknown	tot.aufgehoben_unbekannt	abandonne.supprime_inconnu	abbandonato.eliminato_sconosciuto	abandonata.demolare_necunoscuta	SU	AU	AI			t
6532	6532	abanndoned.filled	tot.verfuellt	abandonne.demoli	abbandonato.demolito	abandonata.eliminata		V	D			t
3027	3027	unknown	unbekannt	inconnu	sconosciuto	rrr_unbekannt		U	I			t
6526	6526	other.calculation_alternative	weitere.Berechnungsvariante	autre.variante_de_calcul	altri.variante_calcolo	alta.varianta_calcul	CA	B	C			t
7959	7959	other.planned	weitere.geplant	autre.planifie	altri.previsto	rrr_weitere.geplant		G	PL			t
6529	6529	other.project	weitere.Projekt	autre.projet	altri.progetto	alta.proiect		N	PR			t
\.


--
-- Data for Name: wastewater_structure_structure_condition; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_structure_condition (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3037	3037	unknown	unbekannt	inconnu	sconosciuto	necunoscuta		U	I			t
3363	3363	Z0	Z0	Z0	Z0	Z0		Z0	Z0			t
3359	3359	Z1	Z1	Z1	Z1	Z1		Z1	Z1			t
3360	3360	Z2	Z2	Z2	Z2	Z2		Z2	Z2			t
3361	3361	Z3	Z3	Z3	Z3	Z3		Z3	Z3			t
3362	3362	Z4	Z4	Z4	Z4			Z4	Z4			t
\.


--
-- Data for Name: wastewater_structure_symbol_plantype; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_symbol_plantype (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7874	7874	pipeline_registry	Leitungskataster	cadastre_des_conduites_souterraines	catasto_delle_canalizzazioni							t
7876	7876	overviewmap.om10	Uebersichtsplan.UeP10	plan_d_ensemble.pe10	piano_di_insieme.pi10							t
7877	7877	overviewmap.om2	Uebersichtsplan.UeP2	plan_d_ensemble.pe2	piano_di_insieme.pi2							t
7878	7878	overviewmap.om5	Uebersichtsplan.UeP5	plan_d_ensemble.pe5	piano_di_insieme.pi5							t
7875	7875	network_plan	Werkplan	plan_de_reseau	zzz_Werkplan							t
\.


--
-- Data for Name: wastewater_structure_text_plantype; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_text_plantype (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7844	7844	pipeline_registry	Leitungskataster	cadastre_des_conduites_souterraines	catasto_delle_canalizzazioni							t
7846	7846	overviewmap.om10	Uebersichtsplan.UeP10	plan_d_ensemble.pe10	piano_di_insieme.pi10							t
7847	7847	overviewmap.om2	Uebersichtsplan.UeP2	plan_d_ensemble.pe2	piano_di_insieme.pi2							t
7848	7848	overviewmap.om5	Uebersichtsplan.UeP5	plan_d_ensemble.pe5	piano_di_insieme.pi5							t
7845	7845	network_plan	Werkplan	plan_de_reseau								t
\.


--
-- Data for Name: wastewater_structure_text_texthali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_text_texthali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7850	7850	0	0	0	0	0						t
7851	7851	1	1	1	1	1						t
7852	7852	2	2	2	2	2						t
\.


--
-- Data for Name: wastewater_structure_text_textvali; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wastewater_structure_text_textvali (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
7853	7853	0	0	0	0	0						t
7854	7854	1	1	1	1	1						t
7855	7855	2	2	2	2	2						t
7856	7856	3	3	3	3	3						t
7857	7857	4	4	4	4	4						t
\.


--
-- Data for Name: water_body_protection_sector_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_body_protection_sector_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
430	430	A	A	A	A	A						t
3652	3652	Ao	Ao	Ao	zzz_Ao							t
3649	3649	Au	Au	Au	zzz_Au							t
431	431	B	B	B	B	B						t
432	432	C	C	C	C	C						t
3069	3069	unknown	unbekannt	inconnu	sconosciuto							t
3651	3651	Zo	Zo	Zo	zzz_Zo							t
3650	3650	Zu	Zu	Zu	zzz_Zu							t
\.


--
-- Data for Name: water_catchment_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_catchment_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
24	24	process_water	Brauchwasser	eau_industrielle	zzz_Brauchwasser							t
25	25	drinking_water	Trinkwasser	eau_potable	zzz_Trinkwasser							t
3075	3075	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_algae_growth; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_algae_growth (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2623	2623	none_or_marginal	kein_gering	absent_faible	zzz_kein_gering							t
2624	2624	moderate_to_strong	maessig_stark	moyen_fort	zzz_maessig_stark							t
2625	2625	excessive_rampant	uebermaessig_wuchernd	tres_fort_proliferation	zzz_uebermaessig_wuchernd							t
3050	3050	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_altitudinal_zone; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_altitudinal_zone (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
320	320	alpine	alpin	alpin	zzz_alpin							t
294	294	foothill_zone	kollin	des_collines	zzz_kollin							t
295	295	montane	montan	montagnard	zzz_montan							t
319	319	subalpine	subalpin	subalpin	zzz_subalpin							t
3020	3020	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_dead_wood; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_dead_wood (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2629	2629	accumulations	Ansammlungen	amas	zzz_Ansammlungen							t
2631	2631	none_or_sporadic	kein_vereinzelt	absent_localise	zzz_kein_vereinzelt							t
3052	3052	unknown	unbekannt	inconnu	sconosciuto							t
2630	2630	scattered	zerstreut	dissemine	zzz_zerstreut							t
\.


--
-- Data for Name: water_course_segment_depth_variability; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_depth_variability (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2617	2617	pronounced	ausgepraegt	prononcee	zzz_ausgepraegt							t
2619	2619	none	keine	aucune	nessuno	inexistent						t
2618	2618	moderate	maessig	moyenne	zzz_maessig							t
3049	3049	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_discharge_regime; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_discharge_regime (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
297	297	compromised	beeintraechtigt	modifie	zzz_beeintraechtigt							t
428	428	artificial	kuenstlich	artificiel	zzz_kuenstlich							t
427	427	hardly_natural	naturfern	peu_naturel	zzz_naturfern							t
296	296	close_to_natural	naturnah	presque_naturel	zzz_naturnah							t
3091	3091	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_ecom_classification; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_ecom_classification (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
3496	3496	covered	eingedolt	mis_sous_terre	zzz_eingedolt							t
3495	3495	artificial	kuenstlich_naturfremd	artificiel_peu_naturel	zzz_kuenstlich_naturfremd							t
3492	3492	natural_or_seminatural	natuerlich_naturnah	naturel_presque_naturel	zzz_natuerlich_naturnah							t
3491	3491	not_classified	nicht_klassiert	pas_classifie	zzz_nicht_klassiert							t
3494	3494	heavily_compromised	stark_beeintraechtigt	fortement_modifie	zzz_stark_beeintraechtigt							t
3493	3493	partially_compromised	wenig_beeintraechtigt	peu_modifie	zzz_wenig_beeintraechtigt							t
\.


--
-- Data for Name: water_course_segment_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2710	2710	covered	eingedolt	mis_sous_terre	zzz_eingedolt							t
2709	2709	open	offen	ouvert	zzz_offen							t
3058	3058	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_length_profile; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_length_profile (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
97	97	downwelling	kaskadenartig	avec_des_cascades	zzz_kaskadenartig							t
3602	3602	rapids_or_potholes	Schnellen_Kolke	avec_rapides_marmites	zzz_Schnellen_Kolke							t
99	99	continuous	stetig	continu	zzz_stetig							t
3035	3035	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_macrophyte_coverage; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_macrophyte_coverage (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
2626	2626	none_or_marginal	kein_gering	absent_faible	zzz_kein_gering							t
2627	2627	moderate_to_strong	maessig_stark	moyen_fort	zzz_maessig_stark							t
2628	2628	excessive_rampant	uebermaessig_wuchernd	tres_fort_proliferation	zzz_uebermaessig_wuchernd							t
3051	3051	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_section_morphology; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_section_morphology (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
4575	4575	straight	gerade	rectiligne	zzz_gerade							t
4580	4580	moderately_bent	leichtbogig	legerement_incurve	zzz_leichtbogig							t
4579	4579	meandering	maeandrierend	en_meandres	zzz_maeandrierend							t
4578	4578	heavily_bent	starkbogig	fortement_incurve	zzz_starkbogig							t
4576	4576	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_slope; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_slope (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
291	291	shallow_dipping	flach	plat	piano							t
292	292	moderate_slope	mittel	moyen	medio							t
293	293	steep	steil	raide	ripido							t
3019	3019	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_utilisation; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_utilisation (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
384	384	recreation	Erholung	detente	zzz_Erholung							t
429	429	fishing	Fischerei	peche	zzz_Fischerei							t
385	385	dam	Stauanlage	installation_de_retenue	zzz_Stauanlage							t
3039	3039	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_water_hardness; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_water_hardness (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
321	321	limestone	Kalk	calcaire	zzz_Kalk							t
322	322	silicate	Silikat	silicieuse	zzz_Silikat							t
3024	3024	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: water_course_segment_width_variability; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.water_course_segment_width_variability (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
176	176	pronounced	ausgepraegt	prononcee	zzz_ausgepraegt							t
177	177	limited	eingeschraenkt	limitee	zzz_eingeschraenkt							t
178	178	none	keine	nulle	nessuno	inexistent						t
3078	3078	unknown	unbekannt	inconnu	sconosciuto							t
\.


--
-- Data for Name: wwtp_structure_kind; Type: TABLE DATA; Schema: qgep_vl; Owner: postgres
--

COPY qgep_vl.wwtp_structure_kind (code, vsacode, value_en, value_de, value_fr, value_it, value_ro, abbr_en, abbr_de, abbr_fr, abbr_it, abbr_ro, active) FROM stdin;
331	331	sedimentation_basin	Absetzbecken	bassin_de_decantation	zzz_Absetzbecken							t
2974	2974	other	andere	autres	altri							t
327	327	aeration_tank	Belebtschlammbecken	bassin_a_boues_activees	zzz_Belebtschlammbecken							t
329	329	fixed_bed_reactor	Festbettreaktor	reacteur_a_biomasse_fixee	zzz_Festbettreaktor							t
330	330	submerged_trickling_filter	Tauchtropfkoerper	disque_bacterien_immerge	zzz_Tauchtropfkoerper							t
328	328	trickling_filter	Tropfkoerper	lit_bacterien	zzz_Tropfkoerper							t
3032	3032	unknown	unbekannt	inconnu	sconosciuto							t
326	326	primary_clarifier	Vorklaerbecken	decanteurs_primaires	zzz_Vorklaerbecken							t
\.


--
-- PostgreSQL database dump complete
--

