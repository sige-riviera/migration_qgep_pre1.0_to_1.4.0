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
-- Name: qgep_od; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA qgep_od;


ALTER SCHEMA qgep_od OWNER TO postgres;

--
-- Name: qgep_sys; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA qgep_sys;


ALTER SCHEMA qgep_sys OWNER TO postgres;

--
-- Name: qgep_vl; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA qgep_vl;


ALTER SCHEMA qgep_vl OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: damage_type; Type: TYPE; Schema: qgep_od; Owner: postgres
--

CREATE TYPE qgep_od.damage_type AS ENUM (
    'damage',
    'channel',
    'manhole'
);


ALTER TYPE qgep_od.damage_type OWNER TO postgres;

--
-- Name: maintenance_type; Type: TYPE; Schema: qgep_od; Owner: postgres
--

CREATE TYPE qgep_od.maintenance_type AS ENUM (
    'maintenance',
    'examination'
);


ALTER TYPE qgep_od.maintenance_type OWNER TO postgres;

--
-- Name: organisation_type; Type: TYPE; Schema: qgep_od; Owner: postgres
--

CREATE TYPE qgep_od.organisation_type AS ENUM (
    'organisation',
    'cooperative',
    'canton',
    'waste_water_association',
    'municipality',
    'administrative_office',
    'waste_water_treatment_plant',
    'private'
);


ALTER TYPE qgep_od.organisation_type OWNER TO postgres;

--
-- Name: overflow_type; Type: TYPE; Schema: qgep_od; Owner: postgres
--

CREATE TYPE qgep_od.overflow_type AS ENUM (
    'overflow',
    'leapingweir',
    'prank_weir',
    'pump'
);


ALTER TYPE qgep_od.overflow_type OWNER TO postgres;

--
-- Name: plantype; Type: TYPE; Schema: qgep_od; Owner: postgres
--

CREATE TYPE qgep_od.plantype AS ENUM (
    'Leitungskataster',
    'Werkinformation',
    'GEP_Verband',
    'GEP_Traegerschaft',
    'PAA',
    'SAA',
    'kein_Plantyp_definiert'
);


ALTER TYPE qgep_od.plantype OWNER TO postgres;

--
-- Name: calculate_reach_length(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.calculate_reach_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE
	_rp_from_level numeric(7,3);
	_rp_to_level numeric(7,3);

BEGIN

  SELECT rp_from.level INTO _rp_from_level
  FROM qgep_od.reach_point rp_from
  WHERE NEW.fk_reach_point_from = rp_from.obj_id;

  SELECT rp_to.level INTO _rp_to_level
  FROM qgep_od.reach_point rp_to
  WHERE NEW.fk_reach_point_to = rp_to.obj_id;

  NEW.length_effective = COALESCE(sqrt((_rp_from_level - _rp_to_level)^2 + ST_Length(NEW.progression_geometry)^2), ST_Length(NEW.progression_geometry) );

  RETURN NEW;

END;
$$;


ALTER FUNCTION qgep_od.calculate_reach_length() OWNER TO postgres;

--
-- Name: drop_symbology_triggers(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.drop_symbology_triggers() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DROP TRIGGER IF EXISTS on_reach_point_update ON qgep_od.reach_point;
  DROP TRIGGER IF EXISTS on_reach_change ON qgep_od.reach;
  DROP TRIGGER IF EXISTS on_wastewater_structure_update ON qgep_od.wastewater_structure;
  DROP TRIGGER IF EXISTS ws_label_update_by_wastewater_networkelement ON qgep_od.wastewater_networkelement;
  DROP TRIGGER IF EXISTS on_structure_part_change ON qgep_od.structure_part;
  DROP TRIGGER IF EXISTS on_cover_change ON qgep_od.cover;
  DROP TRIGGER IF EXISTS ws_symbology_update_by_reach ON qgep_od.reach;
  DROP TRIGGER IF EXISTS ws_symbology_update_by_channel ON qgep_od.channel;
  DROP TRIGGER IF EXISTS ws_symbology_update_by_reach_point ON qgep_od.reach_point;
  RETURN;
END;
$$;


ALTER FUNCTION qgep_od.drop_symbology_triggers() OWNER TO postgres;

--
-- Name: ft_damage_channel_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_damage_channel_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.damage_channel WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.damage WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_damage_channel_delete() OWNER TO postgres;

--
-- Name: ft_damage_channel_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_damage_channel_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.damage (
			obj_id
			, comments
			, connection
			, damage_begin
			, damage_end
			, damage_reach
			, distance
			, quantification1
			, quantification2
			, single_damage_class
			, video_counter
			, view_parameters
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_examination
		) VALUES (
			qgep_sys.generate_oid('qgep_od','damage') 
			, NEW.comments
			, NEW.connection
			, NEW.damage_begin
			, NEW.damage_end
			, NEW.damage_reach
			, NEW.distance
			, NEW.quantification1
			, NEW.quantification2
			, NEW.single_damage_class
			, NEW.video_counter
			, NEW.view_parameters
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_examination
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.damage_channel (
			obj_id
			, channel_damage_code
		) VALUES (
			NEW.obj_id 
			, NEW.channel_damage_code
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_damage_channel_insert() OWNER TO postgres;

--
-- Name: ft_damage_channel_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_damage_channel_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.damage SET
			comments = NEW.comments,
			connection = NEW.connection,
			damage_begin = NEW.damage_begin,
			damage_end = NEW.damage_end,
			damage_reach = NEW.damage_reach,
			distance = NEW.distance,
			quantification1 = NEW.quantification1,
			quantification2 = NEW.quantification2,
			single_damage_class = NEW.single_damage_class,
			video_counter = NEW.video_counter,
			view_parameters = NEW.view_parameters,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_examination = NEW.fk_examination
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.damage_channel SET
			channel_damage_code = NEW.channel_damage_code
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_damage_channel_update() OWNER TO postgres;

--
-- Name: ft_damage_manhole_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_damage_manhole_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.damage_manhole WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.damage WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_damage_manhole_delete() OWNER TO postgres;

--
-- Name: ft_damage_manhole_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_damage_manhole_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.damage (
			obj_id
			, comments
			, connection
			, damage_begin
			, damage_end
			, damage_reach
			, distance
			, quantification1
			, quantification2
			, single_damage_class
			, video_counter
			, view_parameters
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_examination
		) VALUES (
			qgep_sys.generate_oid('qgep_od','damage') 
			, NEW.comments
			, NEW.connection
			, NEW.damage_begin
			, NEW.damage_end
			, NEW.damage_reach
			, NEW.distance
			, NEW.quantification1
			, NEW.quantification2
			, NEW.single_damage_class
			, NEW.video_counter
			, NEW.view_parameters
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_examination
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.damage_manhole (
			obj_id
			, manhole_damage_code
			, manhole_shaft_area
		) VALUES (
			NEW.obj_id 
			, NEW.manhole_damage_code
			, NEW.manhole_shaft_area
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_damage_manhole_insert() OWNER TO postgres;

--
-- Name: ft_damage_manhole_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_damage_manhole_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.damage SET
			comments = NEW.comments,
			connection = NEW.connection,
			damage_begin = NEW.damage_begin,
			damage_end = NEW.damage_end,
			damage_reach = NEW.damage_reach,
			distance = NEW.distance,
			quantification1 = NEW.quantification1,
			quantification2 = NEW.quantification2,
			single_damage_class = NEW.single_damage_class,
			video_counter = NEW.video_counter,
			view_parameters = NEW.view_parameters,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_examination = NEW.fk_examination
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.damage_manhole SET
			manhole_damage_code = NEW.manhole_damage_code,
			manhole_shaft_area = NEW.manhole_shaft_area
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_damage_manhole_update() OWNER TO postgres;

--
-- Name: ft_maintenance_examination_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_maintenance_examination_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.examination WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.maintenance_event WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_maintenance_examination_delete() OWNER TO postgres;

--
-- Name: ft_maintenance_examination_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_maintenance_examination_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.maintenance_event (
			obj_id
			, base_data
			, cost
			, data_details
			, duration
			, identifier
			, kind
			, operator
			, reason
			, remark
			, result
			, status
			, time_point
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_operating_company
			, active_zone
		) VALUES (
			qgep_sys.generate_oid('qgep_od','maintenance_event') 
			, NEW.base_data
			, NEW.cost
			, NEW.data_details
			, NEW.duration
			, NEW.identifier
			, NEW.kind
			, NEW.operator
			, NEW.reason
			, NEW.remark
			, NEW.result
			, NEW.status
			, NEW.time_point
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_operating_company
			, NEW.active_zone
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.examination (
			obj_id
			, equipment
			, from_point_identifier
			, inspected_length
			, recording_type
			, to_point_identifier
			, vehicle
			, videonumber
			, weather
			, fk_reach_point
		) VALUES (
			NEW.obj_id 
			, NEW.equipment
			, NEW.from_point_identifier
			, NEW.inspected_length
			, NEW.recording_type
			, NEW.to_point_identifier
			, NEW.vehicle
			, NEW.videonumber
			, NEW.weather
			, NEW.fk_reach_point
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_maintenance_examination_insert() OWNER TO postgres;

--
-- Name: ft_maintenance_examination_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_maintenance_examination_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.maintenance_event SET
			base_data = NEW.base_data,
			cost = NEW.cost,
			data_details = NEW.data_details,
			duration = NEW.duration,
			identifier = NEW.identifier,
			kind = NEW.kind,
			operator = NEW.operator,
			reason = NEW.reason,
			remark = NEW.remark,
			result = NEW.result,
			status = NEW.status,
			time_point = NEW.time_point,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_operating_company = NEW.fk_operating_company,
			active_zone = NEW.active_zone
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.examination SET
			equipment = NEW.equipment,
			from_point_identifier = NEW.from_point_identifier,
			inspected_length = NEW.inspected_length,
			recording_type = NEW.recording_type,
			to_point_identifier = NEW.to_point_identifier,
			vehicle = NEW.vehicle,
			videonumber = NEW.videonumber,
			weather = NEW.weather,
			fk_reach_point = NEW.fk_reach_point
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_maintenance_examination_update() OWNER TO postgres;

--
-- Name: ft_organisation_administrative_office_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_administrative_office_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.administrative_office WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_administrative_office_delete() OWNER TO postgres;

--
-- Name: ft_organisation_administrative_office_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_administrative_office_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.administrative_office (
			obj_id
			
		) VALUES (
			NEW.obj_id 
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_administrative_office_insert() OWNER TO postgres;

--
-- Name: ft_organisation_administrative_office_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_administrative_office_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_administrative_office_update() OWNER TO postgres;

--
-- Name: ft_organisation_canton_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_canton_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.canton WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_canton_delete() OWNER TO postgres;

--
-- Name: ft_organisation_canton_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_canton_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.canton (
			obj_id
			, perimeter_geometry
		) VALUES (
			NEW.obj_id 
			, NEW.perimeter_geometry
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_canton_insert() OWNER TO postgres;

--
-- Name: ft_organisation_canton_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_canton_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.canton SET
			perimeter_geometry = NEW.perimeter_geometry
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_canton_update() OWNER TO postgres;

--
-- Name: ft_organisation_cooperative_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_cooperative_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.cooperative WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_cooperative_delete() OWNER TO postgres;

--
-- Name: ft_organisation_cooperative_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_cooperative_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.cooperative (
			obj_id
			
		) VALUES (
			NEW.obj_id 
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_cooperative_insert() OWNER TO postgres;

--
-- Name: ft_organisation_cooperative_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_cooperative_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_cooperative_update() OWNER TO postgres;

--
-- Name: ft_organisation_municipality_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_municipality_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.municipality WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_municipality_delete() OWNER TO postgres;

--
-- Name: ft_organisation_municipality_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_municipality_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.municipality (
			obj_id
			, altitude
			, gwdp_year
			, municipality_number
			, perimeter_geometry
			, population
			, total_surface
		) VALUES (
			NEW.obj_id 
			, NEW.altitude
			, NEW.gwdp_year
			, NEW.municipality_number
			, NEW.perimeter_geometry
			, NEW.population
			, NEW.total_surface
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_municipality_insert() OWNER TO postgres;

--
-- Name: ft_organisation_municipality_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_municipality_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.municipality SET
			altitude = NEW.altitude,
			gwdp_year = NEW.gwdp_year,
			municipality_number = NEW.municipality_number,
			perimeter_geometry = NEW.perimeter_geometry,
			population = NEW.population,
			total_surface = NEW.total_surface
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_municipality_update() OWNER TO postgres;

--
-- Name: ft_organisation_private_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_private_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.private WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_private_delete() OWNER TO postgres;

--
-- Name: ft_organisation_private_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_private_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.private (
			obj_id
			, kind
		) VALUES (
			NEW.obj_id 
			, NEW.private_kind
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_private_insert() OWNER TO postgres;

--
-- Name: ft_organisation_private_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_private_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.private SET
			kind = NEW.private_kind
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_private_update() OWNER TO postgres;

--
-- Name: ft_organisation_waste_water_association_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_waste_water_association_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.waste_water_association WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_waste_water_association_delete() OWNER TO postgres;

--
-- Name: ft_organisation_waste_water_association_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_waste_water_association_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.waste_water_association (
			obj_id
			
		) VALUES (
			NEW.obj_id 
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_waste_water_association_insert() OWNER TO postgres;

--
-- Name: ft_organisation_waste_water_association_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_waste_water_association_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_waste_water_association_update() OWNER TO postgres;

--
-- Name: ft_organisation_waste_water_treatment_plant_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_waste_water_treatment_plant_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.waste_water_treatment_plant WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_waste_water_treatment_plant_delete() OWNER TO postgres;

--
-- Name: ft_organisation_waste_water_treatment_plant_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_waste_water_treatment_plant_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.waste_water_treatment_plant (
			obj_id
			, bod5
			, cod
			, elimination_cod
			, elimination_n
			, elimination_nh4
			, elimination_p
			, installation_number
			, kind
			, nh4
			, start_year
		) VALUES (
			NEW.obj_id 
			, NEW.bod5
			, NEW.cod
			, NEW.elimination_cod
			, NEW.elimination_n
			, NEW.elimination_nh4
			, NEW.elimination_p
			, NEW.installation_number
			, NEW.waste_water_treatment_plant_kind
			, NEW.nh4
			, NEW.start_year
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_waste_water_treatment_plant_insert() OWNER TO postgres;

--
-- Name: ft_organisation_waste_water_treatment_plant_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_organisation_waste_water_treatment_plant_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.waste_water_treatment_plant SET
			bod5 = NEW.bod5,
			cod = NEW.cod,
			elimination_cod = NEW.elimination_cod,
			elimination_n = NEW.elimination_n,
			elimination_nh4 = NEW.elimination_nh4,
			elimination_p = NEW.elimination_p,
			installation_number = NEW.installation_number,
			kind = NEW.waste_water_treatment_plant_kind,
			nh4 = NEW.nh4,
			start_year = NEW.start_year
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_organisation_waste_water_treatment_plant_update() OWNER TO postgres;

--
-- Name: ft_overflow_leapingweir_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_leapingweir_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.leapingweir WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.overflow WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_leapingweir_delete() OWNER TO postgres;

--
-- Name: ft_overflow_leapingweir_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_leapingweir_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.overflow (
			obj_id
			, actuation
			, adjustability
			, brand
			, control
			, discharge_point
			, function
			, gross_costs
			, identifier
			, qon_dim
			, remark
			, signal_transmission
			, subsidies
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_wastewater_node
			, fk_overflow_to
			, fk_overflow_characteristic
			, fk_control_center
		) VALUES (
			qgep_sys.generate_oid('qgep_od','overflow') 
			, NEW.actuation
			, NEW.adjustability
			, NEW.brand
			, NEW.control
			, NEW.discharge_point
			, NEW.function
			, NEW.gross_costs
			, NEW.identifier
			, NEW.qon_dim
			, NEW.remark
			, NEW.signal_transmission
			, NEW.subsidies
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_wastewater_node
			, NEW.fk_overflow_to
			, NEW.fk_overflow_characteristic
			, NEW.fk_control_center
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.leapingweir (
			obj_id
			, length
			, opening_shape
			, width
		) VALUES (
			NEW.obj_id 
			, NEW.length
			, NEW.opening_shape
			, NEW.width
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_leapingweir_insert() OWNER TO postgres;

--
-- Name: ft_overflow_leapingweir_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_leapingweir_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.overflow SET
			actuation = NEW.actuation,
			adjustability = NEW.adjustability,
			brand = NEW.brand,
			control = NEW.control,
			discharge_point = NEW.discharge_point,
			function = NEW.function,
			gross_costs = NEW.gross_costs,
			identifier = NEW.identifier,
			qon_dim = NEW.qon_dim,
			remark = NEW.remark,
			signal_transmission = NEW.signal_transmission,
			subsidies = NEW.subsidies,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_wastewater_node = NEW.fk_wastewater_node,
			fk_overflow_to = NEW.fk_overflow_to,
			fk_overflow_characteristic = NEW.fk_overflow_characteristic,
			fk_control_center = NEW.fk_control_center
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.leapingweir SET
			length = NEW.length,
			opening_shape = NEW.opening_shape,
			width = NEW.width
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_leapingweir_update() OWNER TO postgres;

--
-- Name: ft_overflow_prank_weir_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_prank_weir_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.prank_weir WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.overflow WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_prank_weir_delete() OWNER TO postgres;

--
-- Name: ft_overflow_prank_weir_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_prank_weir_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.overflow (
			obj_id
			, actuation
			, adjustability
			, brand
			, control
			, discharge_point
			, function
			, gross_costs
			, identifier
			, qon_dim
			, remark
			, signal_transmission
			, subsidies
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_wastewater_node
			, fk_overflow_to
			, fk_overflow_characteristic
			, fk_control_center
		) VALUES (
			qgep_sys.generate_oid('qgep_od','overflow') 
			, NEW.actuation
			, NEW.adjustability
			, NEW.brand
			, NEW.control
			, NEW.discharge_point
			, NEW.function
			, NEW.gross_costs
			, NEW.identifier
			, NEW.qon_dim
			, NEW.remark
			, NEW.signal_transmission
			, NEW.subsidies
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_wastewater_node
			, NEW.fk_overflow_to
			, NEW.fk_overflow_characteristic
			, NEW.fk_control_center
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.prank_weir (
			obj_id
			, hydraulic_overflow_length
			, level_max
			, level_min
			, weir_edge
			, weir_kind
		) VALUES (
			NEW.obj_id 
			, NEW.hydraulic_overflow_length
			, NEW.level_max
			, NEW.level_min
			, NEW.weir_edge
			, NEW.weir_kind
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_prank_weir_insert() OWNER TO postgres;

--
-- Name: ft_overflow_prank_weir_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_prank_weir_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.overflow SET
			actuation = NEW.actuation,
			adjustability = NEW.adjustability,
			brand = NEW.brand,
			control = NEW.control,
			discharge_point = NEW.discharge_point,
			function = NEW.function,
			gross_costs = NEW.gross_costs,
			identifier = NEW.identifier,
			qon_dim = NEW.qon_dim,
			remark = NEW.remark,
			signal_transmission = NEW.signal_transmission,
			subsidies = NEW.subsidies,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_wastewater_node = NEW.fk_wastewater_node,
			fk_overflow_to = NEW.fk_overflow_to,
			fk_overflow_characteristic = NEW.fk_overflow_characteristic,
			fk_control_center = NEW.fk_control_center
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.prank_weir SET
			hydraulic_overflow_length = NEW.hydraulic_overflow_length,
			level_max = NEW.level_max,
			level_min = NEW.level_min,
			weir_edge = NEW.weir_edge,
			weir_kind = NEW.weir_kind
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_prank_weir_update() OWNER TO postgres;

--
-- Name: ft_overflow_pump_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_pump_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		DELETE FROM qgep_od.pump WHERE obj_id = OLD.obj_id;
		DELETE FROM qgep_od.overflow WHERE obj_id = OLD.obj_id;
		RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_pump_delete() OWNER TO postgres;

--
-- Name: ft_overflow_pump_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_pump_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.overflow (
			obj_id
			, actuation
			, adjustability
			, brand
			, control
			, discharge_point
			, function
			, gross_costs
			, identifier
			, qon_dim
			, remark
			, signal_transmission
			, subsidies
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_wastewater_node
			, fk_overflow_to
			, fk_overflow_characteristic
			, fk_control_center
		) VALUES (
			qgep_sys.generate_oid('qgep_od','overflow') 
			, NEW.actuation
			, NEW.adjustability
			, NEW.brand
			, NEW.control
			, NEW.discharge_point
			, NEW.function
			, NEW.gross_costs
			, NEW.identifier
			, NEW.qon_dim
			, NEW.remark
			, NEW.signal_transmission
			, NEW.subsidies
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_wastewater_node
			, NEW.fk_overflow_to
			, NEW.fk_overflow_characteristic
			, NEW.fk_control_center
		) RETURNING obj_id INTO NEW.obj_id;

		INSERT INTO qgep_od.pump (
			obj_id
			, contruction_type
			, operating_point
			, placement_of_actuation
			, placement_of_pump
			, pump_flow_max_single
			, pump_flow_min_single
			, start_level
			, stop_level
			, usage_current
		) VALUES (
			NEW.obj_id 
			, NEW.contruction_type
			, NEW.operating_point
			, NEW.placement_of_actuation
			, NEW.placement_of_pump
			, NEW.pump_flow_max_single
			, NEW.pump_flow_min_single
			, NEW.start_level
			, NEW.stop_level
			, NEW.usage_current
		);
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_pump_insert() OWNER TO postgres;

--
-- Name: ft_overflow_pump_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_overflow_pump_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.overflow SET
			actuation = NEW.actuation,
			adjustability = NEW.adjustability,
			brand = NEW.brand,
			control = NEW.control,
			discharge_point = NEW.discharge_point,
			function = NEW.function,
			gross_costs = NEW.gross_costs,
			identifier = NEW.identifier,
			qon_dim = NEW.qon_dim,
			remark = NEW.remark,
			signal_transmission = NEW.signal_transmission,
			subsidies = NEW.subsidies,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_wastewater_node = NEW.fk_wastewater_node,
			fk_overflow_to = NEW.fk_overflow_to,
			fk_overflow_characteristic = NEW.fk_overflow_characteristic,
			fk_control_center = NEW.fk_control_center
		WHERE obj_id = OLD.obj_id;

	UPDATE qgep_od.pump SET
			contruction_type = NEW.contruction_type,
			operating_point = NEW.operating_point,
			placement_of_actuation = NEW.placement_of_actuation,
			placement_of_pump = NEW.placement_of_pump,
			pump_flow_max_single = NEW.pump_flow_max_single,
			pump_flow_min_single = NEW.pump_flow_min_single,
			start_level = NEW.start_level,
			stop_level = NEW.stop_level,
			usage_current = NEW.usage_current
		WHERE obj_id = OLD.obj_id;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_overflow_pump_update() OWNER TO postgres;

--
-- Name: ft_vw_organisation_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_organisation_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	CASE
		WHEN OLD.organisation_type::qgep_od.organisation_type = 'cooperative'::qgep_od.organisation_type THEN
			DELETE FROM qgep_od.cooperative WHERE obj_id = OLD.obj_id;
		WHEN OLD.organisation_type::qgep_od.organisation_type = 'canton'::qgep_od.organisation_type THEN
			DELETE FROM qgep_od.canton WHERE obj_id = OLD.obj_id;
		WHEN OLD.organisation_type::qgep_od.organisation_type = 'waste_water_association'::qgep_od.organisation_type THEN
			DELETE FROM qgep_od.waste_water_association WHERE obj_id = OLD.obj_id;
		WHEN OLD.organisation_type::qgep_od.organisation_type = 'municipality'::qgep_od.organisation_type THEN
			DELETE FROM qgep_od.municipality WHERE obj_id = OLD.obj_id;
		WHEN OLD.organisation_type::qgep_od.organisation_type = 'administrative_office'::qgep_od.organisation_type THEN
			DELETE FROM qgep_od.administrative_office WHERE obj_id = OLD.obj_id;
		WHEN OLD.organisation_type::qgep_od.organisation_type = 'waste_water_treatment_plant'::qgep_od.organisation_type THEN
			DELETE FROM qgep_od.waste_water_treatment_plant WHERE obj_id = OLD.obj_id;
		WHEN OLD.organisation_type::qgep_od.organisation_type = 'private'::qgep_od.organisation_type THEN
			DELETE FROM qgep_od.private WHERE obj_id = OLD.obj_id;
	END CASE;
	DELETE FROM qgep_od.organisation WHERE obj_id = OLD.obj_id;
	RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_organisation_delete() OWNER TO postgres;

--
-- Name: ft_vw_organisation_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_organisation_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.organisation (
			obj_id
			, identifier
			, remark
			, uid
			, last_modification
			, fk_dataowner
			, fk_provider
		) VALUES (
			qgep_sys.generate_oid('qgep_od','organisation') 
			, NEW.identifier
			, NEW.remark
			, NEW.uid
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
		) RETURNING obj_id INTO NEW.obj_id;

	CASE
		WHEN NEW.organisation_type::qgep_od.organisation_type = 'cooperative'::qgep_od.organisation_type
			THEN INSERT INTO qgep_od.cooperative (
				obj_id 
			) VALUES (
				NEW.obj_id
		);

		WHEN NEW.organisation_type::qgep_od.organisation_type = 'canton'::qgep_od.organisation_type
			THEN INSERT INTO qgep_od.canton (
				obj_id 
				, perimeter_geometry
			) VALUES (
				NEW.obj_id
				, NEW.perimeter_geometry
		);

		WHEN NEW.organisation_type::qgep_od.organisation_type = 'waste_water_association'::qgep_od.organisation_type
			THEN INSERT INTO qgep_od.waste_water_association (
				obj_id 
			) VALUES (
				NEW.obj_id
		);

		WHEN NEW.organisation_type::qgep_od.organisation_type = 'municipality'::qgep_od.organisation_type
			THEN INSERT INTO qgep_od.municipality (
				obj_id 
				, altitude
				, gwdp_year
				, municipality_number
				, perimeter_geometry
				, population
				, total_surface
			) VALUES (
				NEW.obj_id
				, NEW.altitude
				, NEW.gwdp_year
				, NEW.municipality_number
				, NEW.perimeter_geometry
				, NEW.population
				, NEW.total_surface
		);

		WHEN NEW.organisation_type::qgep_od.organisation_type = 'administrative_office'::qgep_od.organisation_type
			THEN INSERT INTO qgep_od.administrative_office (
				obj_id 
			) VALUES (
				NEW.obj_id
		);

		WHEN NEW.organisation_type::qgep_od.organisation_type = 'waste_water_treatment_plant'::qgep_od.organisation_type
			THEN INSERT INTO qgep_od.waste_water_treatment_plant (
				obj_id 
				, bod5
				, cod
				, elimination_cod
				, elimination_n
				, elimination_nh4
				, elimination_p
				, installation_number
				, kind
				, nh4
				, start_year
			) VALUES (
				NEW.obj_id
				, NEW.bod5
				, NEW.cod
				, NEW.elimination_cod
				, NEW.elimination_n
				, NEW.elimination_nh4
				, NEW.elimination_p
				, NEW.installation_number
				, NEW.waste_water_treatment_plant_kind
				, NEW.nh4
				, NEW.start_year
		);

		WHEN NEW.organisation_type::qgep_od.organisation_type = 'private'::qgep_od.organisation_type
			THEN INSERT INTO qgep_od.private (
				obj_id 
				, kind
			) VALUES (
				NEW.obj_id
				, NEW.private_kind
		);

		 ELSE NULL;
	 END CASE;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_organisation_insert() OWNER TO postgres;

--
-- Name: ft_vw_organisation_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_organisation_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.organisation SET
			identifier = NEW.identifier,
			remark = NEW.remark,
			uid = NEW.uid,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider
		WHERE obj_id = OLD.obj_id;
	-- detect if type has changed
	IF OLD.organisation_type <> NEW.organisation_type::qgep_od.organisation_type THEN
		-- delete old sub type
		CASE
			WHEN OLD.organisation_type::qgep_od.organisation_type = 'cooperative'::qgep_od.organisation_type
				THEN DELETE FROM qgep_od.cooperative WHERE obj_id = OLD.obj_id;
			WHEN OLD.organisation_type::qgep_od.organisation_type = 'canton'::qgep_od.organisation_type
				THEN DELETE FROM qgep_od.canton WHERE obj_id = OLD.obj_id;
			WHEN OLD.organisation_type::qgep_od.organisation_type = 'waste_water_association'::qgep_od.organisation_type
				THEN DELETE FROM qgep_od.waste_water_association WHERE obj_id = OLD.obj_id;
			WHEN OLD.organisation_type::qgep_od.organisation_type = 'municipality'::qgep_od.organisation_type
				THEN DELETE FROM qgep_od.municipality WHERE obj_id = OLD.obj_id;
			WHEN OLD.organisation_type::qgep_od.organisation_type = 'administrative_office'::qgep_od.organisation_type
				THEN DELETE FROM qgep_od.administrative_office WHERE obj_id = OLD.obj_id;
			WHEN OLD.organisation_type::qgep_od.organisation_type = 'waste_water_treatment_plant'::qgep_od.organisation_type
				THEN DELETE FROM qgep_od.waste_water_treatment_plant WHERE obj_id = OLD.obj_id;
			WHEN OLD.organisation_type::qgep_od.organisation_type = 'private'::qgep_od.organisation_type
				THEN DELETE FROM qgep_od.private WHERE obj_id = OLD.obj_id;
		END CASE;
		-- insert new sub type
		CASE
			WHEN NEW.organisation_type::qgep_od.organisation_type = 'cooperative'::qgep_od.organisation_type
				THEN INSERT INTO qgep_od.cooperative (
						obj_id  
					) VALUES (
						OLD.obj_id
					);
			WHEN NEW.organisation_type::qgep_od.organisation_type = 'canton'::qgep_od.organisation_type
				THEN INSERT INTO qgep_od.canton (
						obj_id 
						, perimeter_geometry 
					) VALUES (
						OLD.obj_id
						, NEW.perimeter_geometry
					);
			WHEN NEW.organisation_type::qgep_od.organisation_type = 'waste_water_association'::qgep_od.organisation_type
				THEN INSERT INTO qgep_od.waste_water_association (
						obj_id  
					) VALUES (
						OLD.obj_id
					);
			WHEN NEW.organisation_type::qgep_od.organisation_type = 'municipality'::qgep_od.organisation_type
				THEN INSERT INTO qgep_od.municipality (
						obj_id 
						, altitude
						, gwdp_year
						, municipality_number
						, perimeter_geometry
						, population
						, total_surface 
					) VALUES (
						OLD.obj_id
						, NEW.altitude
						, NEW.gwdp_year
						, NEW.municipality_number
						, NEW.perimeter_geometry
						, NEW.population
						, NEW.total_surface
					);
			WHEN NEW.organisation_type::qgep_od.organisation_type = 'administrative_office'::qgep_od.organisation_type
				THEN INSERT INTO qgep_od.administrative_office (
						obj_id  
					) VALUES (
						OLD.obj_id
					);
			WHEN NEW.organisation_type::qgep_od.organisation_type = 'waste_water_treatment_plant'::qgep_od.organisation_type
				THEN INSERT INTO qgep_od.waste_water_treatment_plant (
						obj_id 
						, bod5
						, cod
						, elimination_cod
						, elimination_n
						, elimination_nh4
						, elimination_p
						, installation_number
						, kind
						, nh4
						, start_year 
					) VALUES (
						OLD.obj_id
						, NEW.bod5
						, NEW.cod
						, NEW.elimination_cod
						, NEW.elimination_n
						, NEW.elimination_nh4
						, NEW.elimination_p
						, NEW.installation_number
						, NEW.waste_water_treatment_plant_kind
						, NEW.nh4
						, NEW.start_year
					);
			WHEN NEW.organisation_type::qgep_od.organisation_type = 'private'::qgep_od.organisation_type
				THEN INSERT INTO qgep_od.private (
						obj_id 
						, kind 
					) VALUES (
						OLD.obj_id
						, NEW.private_kind
					);
		END CASE;
		-- return now as child has been updated
		RETURN NEW;
	END IF;
	CASE
	WHEN NEW.organisation_type::qgep_od.organisation_type = 'cooperative'::qgep_od.organisation_type
		THEN 
		NULL;
	WHEN NEW.organisation_type::qgep_od.organisation_type = 'canton'::qgep_od.organisation_type
		THEN UPDATE qgep_od.canton SET
			perimeter_geometry = NEW.perimeter_geometry
		WHERE obj_id = OLD.obj_id;
	WHEN NEW.organisation_type::qgep_od.organisation_type = 'waste_water_association'::qgep_od.organisation_type
		THEN 
		NULL;
	WHEN NEW.organisation_type::qgep_od.organisation_type = 'municipality'::qgep_od.organisation_type
		THEN UPDATE qgep_od.municipality SET
			altitude = NEW.altitude
			, gwdp_year = NEW.gwdp_year
			, municipality_number = NEW.municipality_number
			, perimeter_geometry = NEW.perimeter_geometry
			, population = NEW.population
			, total_surface = NEW.total_surface
		WHERE obj_id = OLD.obj_id;
	WHEN NEW.organisation_type::qgep_od.organisation_type = 'administrative_office'::qgep_od.organisation_type
		THEN 
		NULL;
	WHEN NEW.organisation_type::qgep_od.organisation_type = 'waste_water_treatment_plant'::qgep_od.organisation_type
		THEN UPDATE qgep_od.waste_water_treatment_plant SET
			bod5 = NEW.bod5
			, cod = NEW.cod
			, elimination_cod = NEW.elimination_cod
			, elimination_n = NEW.elimination_n
			, elimination_nh4 = NEW.elimination_nh4
			, elimination_p = NEW.elimination_p
			, installation_number = NEW.installation_number
			, kind = NEW.waste_water_treatment_plant_kind
			, nh4 = NEW.nh4
			, start_year = NEW.start_year
		WHERE obj_id = OLD.obj_id;
	WHEN NEW.organisation_type::qgep_od.organisation_type = 'private'::qgep_od.organisation_type
		THEN UPDATE qgep_od.private SET
			kind = NEW.private_kind
		WHERE obj_id = OLD.obj_id;
	END CASE;

	RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_organisation_update() OWNER TO postgres;

--
-- Name: ft_vw_qgep_damage_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_damage_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	CASE
		WHEN OLD.damage_type::qgep_od.damage_type = 'channel'::qgep_od.damage_type THEN
			DELETE FROM qgep_od.damage_channel WHERE obj_id = OLD.obj_id;
		WHEN OLD.damage_type::qgep_od.damage_type = 'manhole'::qgep_od.damage_type THEN
			DELETE FROM qgep_od.damage_manhole WHERE obj_id = OLD.obj_id;
	END CASE;
	DELETE FROM qgep_od.damage WHERE obj_id = OLD.obj_id;
	RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_damage_delete() OWNER TO postgres;

--
-- Name: ft_vw_qgep_damage_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_damage_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.damage (
			obj_id
			, comments
			, connection
			, damage_begin
			, damage_end
			, damage_reach
			, distance
			, quantification1
			, quantification2
			, single_damage_class
			, video_counter
			, view_parameters
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_examination
		) VALUES (
			qgep_sys.generate_oid('qgep_od','damage') 
			, NEW.comments
			, NEW.connection
			, NEW.damage_begin
			, NEW.damage_end
			, NEW.damage_reach
			, NEW.distance
			, NEW.quantification1
			, NEW.quantification2
			, NEW.single_damage_class
			, NEW.video_counter
			, NEW.view_parameters
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_examination
		) RETURNING obj_id INTO NEW.obj_id;

	CASE
		WHEN NEW.damage_type::qgep_od.damage_type = 'channel'::qgep_od.damage_type
			THEN INSERT INTO qgep_od.damage_channel (
				obj_id 
				, channel_damage_code
			) VALUES (
				NEW.obj_id
				, NEW.channel_damage_code
		);

		WHEN NEW.damage_type::qgep_od.damage_type = 'manhole'::qgep_od.damage_type
			THEN INSERT INTO qgep_od.damage_manhole (
				obj_id 
				, manhole_damage_code
				, manhole_shaft_area
			) VALUES (
				NEW.obj_id
				, NEW.manhole_damage_code
				, NEW.manhole_shaft_area
		);

		 ELSE NULL;
	 END CASE;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_damage_insert() OWNER TO postgres;

--
-- Name: ft_vw_qgep_damage_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_damage_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.damage SET
			comments = NEW.comments,
			connection = NEW.connection,
			damage_begin = NEW.damage_begin,
			damage_end = NEW.damage_end,
			damage_reach = NEW.damage_reach,
			distance = NEW.distance,
			quantification1 = NEW.quantification1,
			quantification2 = NEW.quantification2,
			single_damage_class = NEW.single_damage_class,
			video_counter = NEW.video_counter,
			view_parameters = NEW.view_parameters,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_examination = NEW.fk_examination
		WHERE obj_id = OLD.obj_id;
	-- detect if type has changed
	IF OLD.damage_type <> NEW.damage_type::qgep_od.damage_type THEN
		RAISE EXCEPTION 'Type change not allowed for damage'
			USING HINT = 'You cannot switch from ' || OLD.damage_type || ' to ' || NEW.damage_type; 
	END IF;
	CASE
	WHEN NEW.damage_type::qgep_od.damage_type = 'channel'::qgep_od.damage_type
		THEN UPDATE qgep_od.damage_channel SET
			channel_damage_code = NEW.channel_damage_code
		WHERE obj_id = OLD.obj_id;
	WHEN NEW.damage_type::qgep_od.damage_type = 'manhole'::qgep_od.damage_type
		THEN UPDATE qgep_od.damage_manhole SET
			manhole_damage_code = NEW.manhole_damage_code
			, manhole_shaft_area = NEW.manhole_shaft_area
		WHERE obj_id = OLD.obj_id;
	END CASE;

	RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_damage_update() OWNER TO postgres;

--
-- Name: ft_vw_qgep_maintenance_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_maintenance_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	CASE
		WHEN OLD.maintenance_type::qgep_od.maintenance_type = 'examination'::qgep_od.maintenance_type THEN
			DELETE FROM qgep_od.examination WHERE obj_id = OLD.obj_id;
	END CASE;
	DELETE FROM qgep_od.maintenance_event WHERE obj_id = OLD.obj_id;
	RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_maintenance_delete() OWNER TO postgres;

--
-- Name: ft_vw_qgep_maintenance_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_maintenance_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.maintenance_event (
			obj_id
			, base_data
			, cost
			, data_details
			, duration
			, identifier
			, kind
			, operator
			, reason
			, remark
			, result
			, status
			, time_point
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_operating_company
			, active_zone
		) VALUES (
			qgep_sys.generate_oid('qgep_od','maintenance_event') 
			, NEW.base_data
			, NEW.cost
			, NEW.data_details
			, NEW.duration
			, NEW.identifier
			, NEW.kind
			, NEW.operator
			, NEW.reason
			, NEW.remark
			, NEW.result
			, NEW.status
			, NEW.time_point
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_operating_company
			, NEW.active_zone
		) RETURNING obj_id INTO NEW.obj_id;

	CASE
		WHEN NEW.maintenance_type::qgep_od.maintenance_type = 'examination'::qgep_od.maintenance_type
			THEN INSERT INTO qgep_od.examination (
				obj_id 
				, equipment
				, from_point_identifier
				, inspected_length
				, recording_type
				, to_point_identifier
				, vehicle
				, videonumber
				, weather
				, fk_reach_point
			) VALUES (
				NEW.obj_id
				, NEW.equipment
				, NEW.from_point_identifier
				, NEW.inspected_length
				, NEW.recording_type
				, NEW.to_point_identifier
				, NEW.vehicle
				, NEW.videonumber
				, NEW.weather
				, NEW.fk_reach_point
		);

		 ELSE NULL;
	 END CASE;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_maintenance_insert() OWNER TO postgres;

--
-- Name: ft_vw_qgep_maintenance_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_maintenance_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.maintenance_event SET
			base_data = NEW.base_data,
			cost = NEW.cost,
			data_details = NEW.data_details,
			duration = NEW.duration,
			identifier = NEW.identifier,
			kind = NEW.kind,
			operator = NEW.operator,
			reason = NEW.reason,
			remark = NEW.remark,
			result = NEW.result,
			status = NEW.status,
			time_point = NEW.time_point,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_operating_company = NEW.fk_operating_company,
			active_zone = NEW.active_zone
		WHERE obj_id = OLD.obj_id;
	-- detect if type has changed
	IF OLD.maintenance_type <> NEW.maintenance_type::qgep_od.maintenance_type THEN
		RAISE EXCEPTION 'Type change not allowed for maintenance'
			USING HINT = 'You cannot switch from ' || OLD.maintenance_type || ' to ' || NEW.maintenance_type; 
	END IF;
	CASE
	WHEN NEW.maintenance_type::qgep_od.maintenance_type = 'examination'::qgep_od.maintenance_type
		THEN UPDATE qgep_od.examination SET
			equipment = NEW.equipment
			, from_point_identifier = NEW.from_point_identifier
			, inspected_length = NEW.inspected_length
			, recording_type = NEW.recording_type
			, to_point_identifier = NEW.to_point_identifier
			, vehicle = NEW.vehicle
			, videonumber = NEW.videonumber
			, weather = NEW.weather
			, fk_reach_point = NEW.fk_reach_point
		WHERE obj_id = OLD.obj_id;
	END CASE;

	RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_maintenance_update() OWNER TO postgres;

--
-- Name: ft_vw_qgep_overflow_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_overflow_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	CASE
		WHEN OLD.overflow_type::qgep_od.overflow_type = 'leapingweir'::qgep_od.overflow_type THEN
			DELETE FROM qgep_od.leapingweir WHERE obj_id = OLD.obj_id;
		WHEN OLD.overflow_type::qgep_od.overflow_type = 'prank_weir'::qgep_od.overflow_type THEN
			DELETE FROM qgep_od.prank_weir WHERE obj_id = OLD.obj_id;
		WHEN OLD.overflow_type::qgep_od.overflow_type = 'pump'::qgep_od.overflow_type THEN
			DELETE FROM qgep_od.pump WHERE obj_id = OLD.obj_id;
	END CASE;
	DELETE FROM qgep_od.overflow WHERE obj_id = OLD.obj_id;
	RETURN NULL;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_overflow_delete() OWNER TO postgres;

--
-- Name: ft_vw_qgep_overflow_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_overflow_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		INSERT INTO qgep_od.overflow (
			obj_id
			, actuation
			, adjustability
			, brand
			, control
			, discharge_point
			, function
			, gross_costs
			, identifier
			, qon_dim
			, remark
			, signal_transmission
			, subsidies
			, last_modification
			, fk_dataowner
			, fk_provider
			, fk_wastewater_node
			, fk_overflow_to
			, fk_overflow_characteristic
			, fk_control_center
		) VALUES (
			qgep_sys.generate_oid('qgep_od','overflow') 
			, NEW.actuation
			, NEW.adjustability
			, NEW.brand
			, NEW.control
			, NEW.discharge_point
			, NEW.function
			, NEW.gross_costs
			, NEW.identifier
			, NEW.qon_dim
			, NEW.remark
			, NEW.signal_transmission
			, NEW.subsidies
			, NEW.last_modification
			, NEW.fk_dataowner
			, NEW.fk_provider
			, NEW.fk_wastewater_node
			, NEW.fk_overflow_to
			, NEW.fk_overflow_characteristic
			, NEW.fk_control_center
		) RETURNING obj_id INTO NEW.obj_id;

	CASE
		WHEN NEW.overflow_type::qgep_od.overflow_type = 'leapingweir'::qgep_od.overflow_type
			THEN INSERT INTO qgep_od.leapingweir (
				obj_id 
				, length
				, opening_shape
				, width
			) VALUES (
				NEW.obj_id
				, NEW.length
				, NEW.opening_shape
				, NEW.width
		);

		WHEN NEW.overflow_type::qgep_od.overflow_type = 'prank_weir'::qgep_od.overflow_type
			THEN INSERT INTO qgep_od.prank_weir (
				obj_id 
				, hydraulic_overflow_length
				, level_max
				, level_min
				, weir_edge
				, weir_kind
			) VALUES (
				NEW.obj_id
				, NEW.hydraulic_overflow_length
				, NEW.level_max
				, NEW.level_min
				, NEW.weir_edge
				, NEW.weir_kind
		);

		WHEN NEW.overflow_type::qgep_od.overflow_type = 'pump'::qgep_od.overflow_type
			THEN INSERT INTO qgep_od.pump (
				obj_id 
				, contruction_type
				, operating_point
				, placement_of_actuation
				, placement_of_pump
				, pump_flow_max_single
				, pump_flow_min_single
				, start_level
				, stop_level
				, usage_current
			) VALUES (
				NEW.obj_id
				, NEW.contruction_type
				, NEW.operating_point
				, NEW.placement_of_actuation
				, NEW.placement_of_pump
				, NEW.pump_flow_max_single
				, NEW.pump_flow_min_single
				, NEW.start_level
				, NEW.stop_level
				, NEW.usage_current
		);

		 ELSE NULL;
	 END CASE;
		RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_overflow_insert() OWNER TO postgres;

--
-- Name: ft_vw_qgep_overflow_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ft_vw_qgep_overflow_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
	UPDATE qgep_od.overflow SET
			actuation = NEW.actuation,
			adjustability = NEW.adjustability,
			brand = NEW.brand,
			control = NEW.control,
			discharge_point = NEW.discharge_point,
			function = NEW.function,
			gross_costs = NEW.gross_costs,
			identifier = NEW.identifier,
			qon_dim = NEW.qon_dim,
			remark = NEW.remark,
			signal_transmission = NEW.signal_transmission,
			subsidies = NEW.subsidies,
			last_modification = NEW.last_modification,
			fk_dataowner = NEW.fk_dataowner,
			fk_provider = NEW.fk_provider,
			fk_wastewater_node = NEW.fk_wastewater_node,
			fk_overflow_to = NEW.fk_overflow_to,
			fk_overflow_characteristic = NEW.fk_overflow_characteristic,
			fk_control_center = NEW.fk_control_center
		WHERE obj_id = OLD.obj_id;
	-- detect if type has changed
	IF OLD.overflow_type <> NEW.overflow_type::qgep_od.overflow_type THEN
		RAISE EXCEPTION 'Type change not allowed for overflow'
			USING HINT = 'You cannot switch from ' || OLD.overflow_type || ' to ' || NEW.overflow_type; 
	END IF;
	CASE
	WHEN NEW.overflow_type::qgep_od.overflow_type = 'leapingweir'::qgep_od.overflow_type
		THEN UPDATE qgep_od.leapingweir SET
			length = NEW.length
			, opening_shape = NEW.opening_shape
			, width = NEW.width
		WHERE obj_id = OLD.obj_id;
	WHEN NEW.overflow_type::qgep_od.overflow_type = 'prank_weir'::qgep_od.overflow_type
		THEN UPDATE qgep_od.prank_weir SET
			hydraulic_overflow_length = NEW.hydraulic_overflow_length
			, level_max = NEW.level_max
			, level_min = NEW.level_min
			, weir_edge = NEW.weir_edge
			, weir_kind = NEW.weir_kind
		WHERE obj_id = OLD.obj_id;
	WHEN NEW.overflow_type::qgep_od.overflow_type = 'pump'::qgep_od.overflow_type
		THEN UPDATE qgep_od.pump SET
			contruction_type = NEW.contruction_type
			, operating_point = NEW.operating_point
			, placement_of_actuation = NEW.placement_of_actuation
			, placement_of_pump = NEW.placement_of_pump
			, pump_flow_max_single = NEW.pump_flow_max_single
			, pump_flow_min_single = NEW.pump_flow_min_single
			, start_level = NEW.start_level
			, stop_level = NEW.stop_level
			, usage_current = NEW.usage_current
		WHERE obj_id = OLD.obj_id;
	END CASE;

	RETURN NEW;
	END;
	$$;


ALTER FUNCTION qgep_od.ft_vw_qgep_overflow_update() OWNER TO postgres;

--
-- Name: on_cover_change(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.on_cover_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  co_obj_id TEXT;
  affected_sp RECORD;
BEGIN
  CASE
    WHEN TG_OP = 'UPDATE' THEN
      co_obj_id = OLD.obj_id;
    WHEN TG_OP = 'INSERT' THEN
      co_obj_id = NEW.obj_id;
    WHEN TG_OP = 'DELETE' THEN
      co_obj_id = OLD.obj_id;
  END CASE;

  SELECT SP.fk_wastewater_structure INTO affected_sp
  FROM qgep_od.structure_part SP
  WHERE obj_id = co_obj_id;

  EXECUTE qgep_od.update_wastewater_structure_label(affected_sp.fk_wastewater_structure);
  EXECUTE qgep_od.update_depth(affected_sp.fk_wastewater_structure);

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.on_cover_change() OWNER TO postgres;

--
-- Name: on_reach_change(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.on_reach_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rp_obj_ids TEXT[];
  _ws_obj_id TEXT;
  rps RECORD;
BEGIN
  CASE
    WHEN TG_OP = 'UPDATE' THEN
      rp_obj_ids = ARRAY[OLD.fk_reach_point_from, OLD.fk_reach_point_to];
    WHEN TG_OP = 'INSERT' THEN
      rp_obj_ids = ARRAY[NEW.fk_reach_point_from, NEW.fk_reach_point_to];
    WHEN TG_OP = 'DELETE' THEN
      rp_obj_ids = ARRAY[OLD.fk_reach_point_from, OLD.fk_reach_point_to];
  END CASE;

  FOR _ws_obj_id IN
    SELECT ws.obj_id
      FROM qgep_od.wastewater_structure ws
      LEFT JOIN qgep_od.wastewater_networkelement ne ON ws.obj_id = ne.fk_wastewater_structure
      LEFT JOIN qgep_od.reach_point rp ON ne.obj_id = rp.fk_wastewater_networkelement
      WHERE rp.obj_id = ANY ( rp_obj_ids )
  LOOP
    EXECUTE qgep_od.update_wastewater_structure_label(_ws_obj_id);
    EXECUTE qgep_od.update_depth(_ws_obj_id);
  END LOOP;

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.on_reach_change() OWNER TO postgres;

--
-- Name: on_reach_point_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.on_reach_point_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  rp_obj_id TEXT;
  _ws_obj_id TEXT;
BEGIN
  CASE
    WHEN TG_OP = 'UPDATE' THEN
      IF (NEW.fk_wastewater_networkelement = OLD.fk_wastewater_networkelement) THEN
        RETURN NEW;
      END IF;
      rp_obj_id = OLD.obj_id;
    WHEN TG_OP = 'INSERT' THEN
      rp_obj_id = NEW.obj_id;
    WHEN TG_OP = 'DELETE' THEN
      rp_obj_id = OLD.obj_id;
  END CASE;


  UPDATE qgep_od.reach
  SET progression_geometry = progression_geometry; --To retrigger the calculate_length trigger on reach update

  SELECT ws.obj_id INTO _ws_obj_id
  FROM qgep_od.wastewater_structure ws
  LEFT JOIN qgep_od.wastewater_networkelement ne ON ws.obj_id = ne.fk_wastewater_structure
  LEFT JOIN qgep_od.reach_point rp ON ne.obj_id = NEW.fk_wastewater_networkelement;

  EXECUTE qgep_od.update_wastewater_structure_label(_ws_obj_id);
  EXECUTE qgep_od.update_depth(_ws_obj_id);

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.on_reach_point_update() OWNER TO postgres;

--
-- Name: on_structure_part_change_networkelement(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.on_structure_part_change_networkelement() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _ws_obj_ids TEXT[];
  _ws_obj_id TEXT;
BEGIN
  CASE
    WHEN TG_OP = 'UPDATE' THEN
      _ws_obj_ids = ARRAY[OLD.fk_wastewater_structure, NEW.fk_wastewater_structure];
    WHEN TG_OP = 'INSERT' THEN
      _ws_obj_ids = ARRAY[NEW.fk_wastewater_structure];
    WHEN TG_OP = 'DELETE' THEN
      _ws_obj_ids = ARRAY[OLD.fk_wastewater_structure];
  END CASE;

  FOREACH _ws_obj_id IN ARRAY _ws_obj_ids
  LOOP
    EXECUTE qgep_od.update_wastewater_structure_label(_ws_obj_id);
  END LOOP;

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.on_structure_part_change_networkelement() OWNER TO postgres;

--
-- Name: on_wastewater_structure_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.on_wastewater_structure_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _ws_obj_id TEXT;
BEGIN
  -- Prevent recursion
  IF COALESCE(OLD.identifier, '') = COALESCE(NEW.identifier, '') THEN
    RETURN NEW;
  END IF;
  _ws_obj_id = OLD.obj_id;
  SELECT qgep_od.update_wastewater_structure_label(_ws_obj_id) INTO NEW._label;

  IF OLD.fk_main_cover != NEW.fk_main_cover THEN
    EXECUTE qgep_od.update_depth(_ws_obj_id);
  END IF;


  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.on_wastewater_structure_update() OWNER TO postgres;

--
-- Name: update_depth(text, boolean); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.update_depth(_obj_id text, _all boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
  myrec record;

BEGIN
  UPDATE qgep_od.wastewater_structure ws
  SET _depth = depth
  FROM (
    SELECT WS.obj_id, CO.level - COALESCE(MIN(NO.bottom_level), MIN(RP.level)) as depth
      FROM qgep_od.wastewater_structure WS
      LEFT JOIN qgep_od.cover CO on WS.fk_main_cover = CO.obj_id
      LEFT JOIN qgep_od.wastewater_networkelement NE ON NE.fk_wastewater_structure = WS.obj_id
      RIGHT JOIN qgep_od.wastewater_node NO on NO.obj_id = NE.obj_id
      LEFT JOIN qgep_od.reach_point RP ON RP.fk_wastewater_networkelement = NE.obj_id
      WHERE _all OR WS.obj_id = _obj_id
      GROUP BY WS.obj_id, CO.level
  ) ws_depths
  where ws.obj_id = ws_depths.obj_id;
END

$$;


ALTER FUNCTION qgep_od.update_depth(_obj_id text, _all boolean) OWNER TO postgres;

--
-- Name: update_wastewater_structure_label(text, boolean); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.update_wastewater_structure_label(_obj_id text, _all boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
  myrec record;

BEGIN
UPDATE qgep_od.wastewater_structure ws
SET _label = label
FROM (
  SELECT ws_obj_id,
       array_to_string(
         array_agg( 'C' || '=' || co_level::text ORDER BY co_level DESC),
         E'\n'
       ) ||
       E'\n' ||
       COALESCE(ws_identifier, '') ||
       E'\n' ||
       array_to_string(
         array_agg(lbl_type || idx || '=' || rp_level ORDER BY lbl_type, idx)
           , E'\n'
         ) AS label
  FROM (
    SELECT ws.obj_id AS ws_obj_id, ws.identifier AS ws_identifier, parts.lbl_type, parts.co_level, parts.rp_level, parts.obj_id, idx
    FROM qgep_od.wastewater_structure WS

    LEFT JOIN (
      SELECT 'C' as lbl_type, CO.level AS co_level, NULL AS rp_level, SP.fk_wastewater_structure ws, SP.obj_id, row_number() OVER(PARTITION BY SP.fk_wastewater_structure) AS idx
      FROM qgep_od.structure_part SP
      RIGHT JOIN qgep_od.cover CO ON CO.obj_id = SP.obj_id
      WHERE _all OR SP.fk_wastewater_structure = _obj_id
      UNION
      SELECT 'I' as lbl_type, NULL, RP.level AS rp_level, NE.fk_wastewater_structure ws, RP.obj_id, row_number() OVER(PARTITION BY RP.fk_wastewater_networkelement ORDER BY ST_Azimuth(RP.situation_geometry,ST_LineInterpolatePoint(ST_CurveToLine(RE_to.progression_geometry),0.99))/pi()*180 ASC)
      FROM qgep_od.reach_point RP
      LEFT JOIN qgep_od.wastewater_networkelement NE ON RP.fk_wastewater_networkelement = NE.obj_id
      INNER JOIN qgep_od.reach RE_to ON RP.obj_id = RE_to.fk_reach_point_to
      WHERE _all OR NE.fk_wastewater_structure = _obj_id
      UNION
      SELECT 'O' as lbl_type, NULL, RP.level AS rp_level, NE.fk_wastewater_structure ws, RP.obj_id, row_number() OVER(PARTITION BY RP.fk_wastewater_networkelement ORDER BY ST_Azimuth(RP.situation_geometry,ST_LineInterpolatePoint(ST_CurveToLine(RE_from.progression_geometry),0.99))/pi()*180 ASC)
      FROM qgep_od.reach_point RP
      LEFT JOIN qgep_od.wastewater_networkelement NE ON RP.fk_wastewater_networkelement = NE.obj_id
      INNER JOIN qgep_od.reach RE_from ON RP.obj_id = RE_from.fk_reach_point_from
      WHERE CASE WHEN _obj_id IS NULL THEN TRUE ELSE NE.fk_wastewater_structure = _obj_id END
    ) AS parts ON ws = ws.obj_id
    WHERE _all OR ws.obj_id = _obj_id
  ) parts
  GROUP BY ws_obj_id, COALESCE(ws_identifier, '')
) labeled_ws
WHERE ws.obj_id = labeled_ws.ws_obj_id;

END

$$;


ALTER FUNCTION qgep_od.update_wastewater_structure_label(_obj_id text, _all boolean) OWNER TO postgres;

--
-- Name: update_wastewater_structure_symbology(text, boolean); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.update_wastewater_structure_symbology(_obj_id text, _all boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
UPDATE qgep_od.wastewater_structure ws
SET
  _function_hierarchic = COALESCE(function_hierarchic_from, function_hierarchic_to),
  _usage_current = COALESCE(usage_current_from, usage_current_to)
FROM(
  SELECT ws.obj_id AS ws_obj_id,
    CH_from.function_hierarchic AS function_hierarchic_from,
    CH_to.function_hierarchic AS function_hierarchic_to,
    CH_from.usage_current AS usage_current_from,
    CH_to.usage_current AS usage_current_to,
    rank() OVER( PARTITION BY ws.obj_id ORDER BY vl_fct_hier_from.order_fct_hierarchic ASC NULLS LAST, vl_fct_hier_to.order_fct_hierarchic ASC NULLS LAST,
                              vl_usg_curr_from.order_usage_current ASC NULLS LAST, vl_usg_curr_to.order_usage_current ASC NULLS LAST)
                              AS hierarchy_rank
  FROM
    qgep_od.wastewater_structure ws
    LEFT JOIN qgep_od.wastewater_networkelement ne ON ne.fk_wastewater_structure = ws.obj_id

    LEFT JOIN qgep_od.reach_point rp ON ne.obj_id = rp.fk_wastewater_networkelement

    LEFT JOIN qgep_od.reach                       re_from           ON re_from.fk_reach_point_from = rp.obj_id
    LEFT JOIN qgep_od.wastewater_networkelement   ne_from           ON ne_from.obj_id = re_from.obj_id
    LEFT JOIN qgep_od.channel                     CH_from           ON CH_from.obj_id = ne_from.fk_wastewater_structure
    LEFT JOIN qgep_vl.channel_function_hierarchic vl_fct_hier_from  ON CH_from.function_hierarchic = vl_fct_hier_from.code
    LEFT JOIN qgep_vl.channel_usage_current       vl_usg_curr_from  ON CH_from.usage_current = vl_usg_curr_from.code

    LEFT JOIN qgep_od.reach                       re_to          ON re_to.fk_reach_point_to = rp.obj_id
    LEFT JOIN qgep_od.wastewater_networkelement   ne_to          ON ne_to.obj_id = re_to.obj_id
    LEFT JOIN qgep_od.channel                     CH_to          ON CH_to.obj_id = ne_to.fk_wastewater_structure
    LEFT JOIN qgep_vl.channel_function_hierarchic vl_fct_hier_to ON CH_to.function_hierarchic = vl_fct_hier_to.code
    LEFT JOIN qgep_vl.channel_usage_current       vl_usg_curr_to ON CH_to.usage_current = vl_usg_curr_to.code

    WHERE _all OR ws.obj_id = _obj_id
) symbology_ws
WHERE symbology_ws.ws_obj_id = ws.obj_id;
END
$$;


ALTER FUNCTION qgep_od.update_wastewater_structure_symbology(_obj_id text, _all boolean) OWNER TO postgres;

--
-- Name: vw_access_aid_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_access_aid_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.structure_part (
             obj_id
           , identifier
           , remark
           , renovation_demand
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','access_aid')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.renovation_demand
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.access_aid (
             obj_id
           , kind
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.kind
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_access_aid_insert() OWNER TO postgres;

--
-- Name: vw_backflow_prevention_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_backflow_prevention_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.structure_part (
             obj_id
           , identifier
           , remark
           , renovation_demand
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','backflow_prevention')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.renovation_demand
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.backflow_prevention (
             obj_id
           , gross_costs
           , kind
           , year_of_replacement
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.gross_costs
           , NEW.kind
           , NEW.year_of_replacement
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_backflow_prevention_insert() OWNER TO postgres;

--
-- Name: vw_benching_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_benching_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.structure_part (
             obj_id
           , identifier
           , remark
           , renovation_demand
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','benching')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.renovation_demand
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.benching (
             obj_id
           , kind
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.kind
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_benching_insert() OWNER TO postgres;

--
-- Name: vw_channel_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_channel_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.wastewater_structure (
             obj_id
           , accessibility
           , contract_section
           , detail_geometry_geometry
           , financing
           , gross_costs
           , identifier
           , inspection_interval
           , location_name
           , records
           , remark
           , renovation_necessity
           , replacement_value
           , rv_base_year
           , rv_construction_type
           , status
           , structure_condition
           , subsidies
           , year_of_construction
           , year_of_replacement
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_owner
           , fk_operator
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','channel')) -- obj_id
           , NEW.accessibility
           , NEW.contract_section
            , NEW.detail_geometry_geometry
           , NEW.financing
           , NEW.gross_costs
           , NEW.identifier
           , NEW.inspection_interval
           , NEW.location_name
           , NEW.records
           , NEW.remark
           , NEW.renovation_necessity
           , NEW.replacement_value
           , NEW.rv_base_year
           , NEW.rv_construction_type
           , NEW.status
           , NEW.structure_condition
           , NEW.subsidies
           , NEW.year_of_construction
           , NEW.year_of_replacement
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_owner
           , NEW.fk_operator
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.channel (
             obj_id
           , bedding_encasement
           , connection_type
           , function_hierarchic
           , function_hydraulic
           , jetting_interval
           , pipe_length
           , usage_current
           , usage_planned
           )
          VALUES (
             NEW.obj_id -- obj_id
           , NEW.bedding_encasement
           , NEW.connection_type
           , NEW.function_hierarchic
           , NEW.function_hydraulic
           , NEW.jetting_interval
           , NEW.pipe_length
           , NEW.usage_current
           , NEW.usage_planned
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_channel_insert() OWNER TO postgres;

--
-- Name: vw_cover_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_cover_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.structure_part (
             obj_id
           , identifier
           , remark
           , renovation_demand
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','cover')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.renovation_demand
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.cover (
             obj_id
           , brand
           , cover_shape
           , diameter
           , fastening
           , level
           , material
           , positional_accuracy
           , situation_geometry
           , sludge_bucket
           , venting
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.brand
           , NEW.cover_shape
           , NEW.diameter
           , NEW.fastening
           , NEW.level
           , NEW.material
           , NEW.positional_accuracy
           , NEW.situation_geometry
           , NEW.sludge_bucket
           , NEW.venting
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_cover_insert() OWNER TO postgres;

--
-- Name: vw_discharge_point_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_discharge_point_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.wastewater_structure (
             obj_id
           , accessibility
           , contract_section
            , detail_geometry_geometry
           , financing
           , gross_costs
           , identifier
           , inspection_interval
           , location_name
           , records
           , remark
           , renovation_necessity
           , replacement_value
           , rv_base_year
           , rv_construction_type
           , status
           , structure_condition
           , subsidies
           , year_of_construction
           , year_of_replacement
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_owner
           , fk_operator
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','discharge_point')) -- obj_id
           , NEW.accessibility
           , NEW.contract_section
            , NEW.detail_geometry_geometry
           , NEW.financing
           , NEW.gross_costs
           , NEW.identifier
           , NEW.inspection_interval
           , NEW.location_name
           , NEW.records
           , NEW.remark
           , NEW.renovation_necessity
           , NEW.replacement_value
           , NEW.rv_base_year
           , NEW.rv_construction_type
           , NEW.status
           , NEW.structure_condition
           , NEW.subsidies
           , NEW.year_of_construction
           , NEW.year_of_replacement
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_owner
           , NEW.fk_operator
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.discharge_point (
             obj_id
           , highwater_level
           , relevance
           , terrain_level
           , upper_elevation
           , waterlevel_hydraulic
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.highwater_level
           , NEW.relevance
           , NEW.terrain_level
           , NEW.upper_elevation
           , NEW.waterlevel_hydraulic
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_discharge_point_insert() OWNER TO postgres;

--
-- Name: vw_dryweather_downspout_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_dryweather_downspout_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.structure_part (
             obj_id
           , identifier
           , remark
           , renovation_demand
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','dryweather_downspout')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.renovation_demand
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.dryweather_downspout (
             obj_id
           , diameter
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.diameter
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_dryweather_downspout_insert() OWNER TO postgres;

--
-- Name: vw_dryweather_flume_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_dryweather_flume_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.structure_part (
             obj_id
           , identifier
           , remark
           , renovation_demand
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','dryweather_flume')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.renovation_demand
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.dryweather_flume (
             obj_id
           , material
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.material
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_dryweather_flume_insert() OWNER TO postgres;

--
-- Name: vw_manhole_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_manhole_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.wastewater_structure (
             obj_id
           , accessibility
           , contract_section
            , detail_geometry_geometry
           , financing
           , gross_costs
           , identifier
           , inspection_interval
           , location_name
           , records
           , remark
           , renovation_necessity
           , replacement_value
           , rv_base_year
           , rv_construction_type
           , status
           , structure_condition
           , subsidies
           , year_of_construction
           , year_of_replacement
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_owner
           , fk_operator
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','manhole')) -- obj_id
           , NEW.accessibility
           , NEW.contract_section
            , NEW.detail_geometry_geometry
           , NEW.financing
           , NEW.gross_costs
           , NEW.identifier
           , NEW.inspection_interval
           , NEW.location_name
           , NEW.records
           , NEW.remark
           , NEW.renovation_necessity
           , NEW.replacement_value
           , NEW.rv_base_year
           , NEW.rv_construction_type
           , NEW.status
           , NEW.structure_condition
           , NEW.subsidies
           , NEW.year_of_construction
           , NEW.year_of_replacement
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_owner
           , NEW.fk_operator
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.manhole (
             obj_id
           , dimension1
           , dimension2
           , function
           , material
           , surface_inflow
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.dimension1
           , NEW.dimension2
           , NEW.function
           , NEW.material
           , NEW.surface_inflow
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_manhole_insert() OWNER TO postgres;

--
-- Name: vw_qgep_reach_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_qgep_reach_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.reach_point(
            obj_id
            , elevation_accuracy
            , identifier
            , level
            , outlet_shape
            , position_of_connection
            , remark
            , situation_geometry
            , last_modification
            , fk_dataowner
            , fk_provider
            , fk_wastewater_networkelement
          )
    VALUES (
            COALESCE(NEW.rp_from_obj_id,qgep_sys.generate_oid('qgep_od','reach_point')) -- obj_id
            , NEW.rp_from_elevation_accuracy -- elevation_accuracy
            , NEW.rp_from_identifier -- identifier
            , NEW.rp_from_level -- level
            , NEW.rp_from_outlet_shape -- outlet_shape
            , NEW.rp_from_position_of_connection -- position_of_connection
            , NEW.rp_from_remark -- remark
            , ST_Force2D(ST_StartPoint(NEW.progression_geometry)) -- situation_geometry
            , NEW.rp_from_last_modification -- last_modification
            , NEW.rp_from_fk_dataowner -- fk_dataowner
            , NEW.rp_from_fk_provider -- fk_provider
            , NEW.rp_from_fk_wastewater_networkelement -- fk_wastewater_networkelement
          )
    RETURNING obj_id INTO NEW.rp_from_obj_id;


    INSERT INTO qgep_od.reach_point(
            obj_id
            , elevation_accuracy
            , identifier
            , level
            , outlet_shape
            , position_of_connection
            , remark
            , situation_geometry
            , last_modification
            , fk_dataowner
            , fk_provider
            , fk_wastewater_networkelement
          )
    VALUES (
            COALESCE(NEW.rp_to_obj_id,qgep_sys.generate_oid('qgep_od','reach_point')) -- obj_id
            , NEW.rp_to_elevation_accuracy -- elevation_accuracy
            , NEW.rp_to_identifier -- identifier
            , NEW.rp_to_level -- level
            , NEW.rp_to_outlet_shape -- outlet_shape
            , NEW.rp_to_position_of_connection -- position_of_connection
            , NEW.rp_to_remark -- remark
            , ST_Force2D(ST_EndPoint(NEW.progression_geometry)) -- situation_geometry
            , NEW.rp_to_last_modification -- last_modification
            , NEW.rp_to_fk_dataowner -- fk_dataowner
            , NEW.rp_to_fk_provider -- fk_provider
            , NEW.rp_to_fk_wastewater_networkelement -- fk_wastewater_networkelement
          )
    RETURNING obj_id INTO NEW.rp_to_obj_id;
    
  INSERT INTO qgep_od.wastewater_structure (
            obj_id
            , accessibility
            , contract_section
            -- , detail_geometry_geometry
            , financing
            , gross_costs
            , identifier
            , inspection_interval
            , location_name
            , records
            , remark
            , renovation_necessity
            , replacement_value
            , rv_base_year
            , rv_construction_type
            , status
            , structure_condition
            , subsidies
            , year_of_construction
            , year_of_replacement
            , last_modification
            , fk_dataowner
            , fk_provider
            , fk_owner
            , fk_operator )

    VALUES ( COALESCE(NEW.fk_wastewater_structure,qgep_sys.generate_oid('qgep_od','channel')) -- obj_id
            , NEW.accessibility
            , NEW.contract_section
            -- , NEW.detail_geometry_geometry
            , NEW.financing
            , NEW.gross_costs
            , NEW.identifier
            , NEW.inspection_interval
            , NEW.location_name
            , NEW.records
            , NEW.remark
            , NEW.renovation_necessity
            , NEW.replacement_value
            , NEW.rv_base_year
            , NEW.rv_construction_type
            , NEW.status
            , NEW.structure_condition
            , NEW.subsidies
            , NEW.year_of_construction
            , NEW.year_of_replacement
            , NEW.last_modification
            , NEW.fk_dataowner
            , NEW.fk_provider
            , NEW.fk_owner
            , NEW.fk_operator
           )
           RETURNING obj_id INTO NEW.fk_wastewater_structure;

  INSERT INTO qgep_od.channel(
              obj_id
            , bedding_encasement
            , connection_type
            , function_hierarchic
            , function_hydraulic
            , jetting_interval
            , pipe_length
            , usage_current
            , usage_planned
            )
            VALUES(
              NEW.fk_wastewater_structure
            , NEW.bedding_encasement
            , NEW.connection_type
            , NEW.function_hierarchic
            , NEW.function_hydraulic
            , NEW.jetting_interval
            , NEW.pipe_length
            , NEW.usage_current
            , NEW.usage_planned
            );

  INSERT INTO qgep_od.wastewater_networkelement (
            obj_id
            , identifier
            , remark
            , last_modification
            , fk_dataowner
            , fk_provider
            , fk_wastewater_structure )
    VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','reach')) -- obj_id
            , NEW.identifier -- identifier
            , NEW.remark -- remark
            , NEW.last_modification -- last_modification
            , NEW.fk_dataowner -- fk_dataowner
            , NEW.fk_provider -- fk_provider
            , NEW.fk_wastewater_structure -- fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

  INSERT INTO qgep_od.reach (
            obj_id
            , clear_height
            , coefficient_of_friction
            , elevation_determination
            , horizontal_positioning
            , inside_coating
            , length_effective
            , material
            , progression_geometry
            , reliner_material
            , reliner_nominal_size
            , relining_construction
            , relining_kind
            , ring_stiffness
            , slope_building_plan
            , wall_roughness
            , fk_reach_point_from
            , fk_reach_point_to
            , fk_pipe_profile )
    VALUES(
              NEW.obj_id -- obj_id
            , NEW.clear_height
            , NEW.coefficient_of_friction
            , NEW.elevation_determination
            , NEW.horizontal_positioning
            , NEW.inside_coating
            , NEW.length_effective
            , NEW.material
            , NEW.progression_geometry
            , NEW.reliner_material
            , NEW.reliner_nominal_size
            , NEW.relining_construction
            , NEW.relining_kind
            , NEW.ring_stiffness
            , NEW.slope_building_plan
            , NEW.wall_roughness
            , NEW.rp_from_obj_id
            , NEW.rp_to_obj_id
            , NEW.fk_pipe_profile);

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_qgep_reach_insert() OWNER TO postgres;

--
-- Name: vw_qgep_wastewater_structure_delete(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_qgep_wastewater_structure_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  DELETE FROM qgep_od.wastewater_structure WHERE obj_id = OLD.obj_id;
RETURN OLD;
END; $$;


ALTER FUNCTION qgep_od.vw_qgep_wastewater_structure_delete() OWNER TO postgres;

--
-- Name: vw_qgep_wastewater_structure_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_qgep_wastewater_structure_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

  NEW.identifier = COALESCE(NEW.identifier, NEW.obj_id);

  INSERT INTO qgep_od.wastewater_structure(
      obj_id
    , accessibility
    , contract_section
    , financing
    , gross_costs
    , identifier
    , inspection_interval
    , location_name
    , records
    , remark
    , renovation_necessity
    , replacement_value
    , rv_base_year
    , rv_construction_type
    , status
    , structure_condition
    , subsidies
    , year_of_construction
    , year_of_replacement
    , last_modification
    , fk_dataowner
    , fk_provider
    , fk_owner
    , fk_operator
  )
  VALUES
  (
      NEW.obj_id
    , NEW.accessibility
    , NEW.contract_section
    , NEW.financing
    , NEW.gross_costs
    , NEW.identifier
    , NEW.inspection_interval
    , NEW.location_name
    , NEW.records
    , NEW.remark
    , NEW.renovation_necessity
    , NEW.replacement_value
    , NEW.rv_base_year
    , NEW.rv_construction_type
    , NEW.status
    , NEW.structure_condition
    , NEW.subsidies
    , NEW.year_of_construction
    , NEW.year_of_replacement
    , NEW.last_modification
    , NEW.fk_dataowner
    , NEW.fk_provider
    , NEW.fk_owner
    , NEW.fk_operator
  );

  -- Manhole
  CASE
    WHEN NEW.ws_type = 'manhole' THEN
      INSERT INTO qgep_od.manhole(
             obj_id
           , dimension1
           , dimension2
           , function
           , material
           , surface_inflow
           )
           VALUES
           (
             NEW.obj_id
           , NEW.dimension1
           , NEW.dimension2
           , NEW.manhole_function
           , NEW.material
           , NEW.surface_inflow
           );

    -- Special Structure
    WHEN NEW.ws_type = 'special_structure' THEN
      INSERT INTO qgep_od.special_structure(
             obj_id
           , bypass
           , emergency_spillway
           , function
           , stormwater_tank_arrangement
           , upper_elevation
           )
           VALUES
           (
             NEW.obj_id
           , NEW.bypass
           , NEW.emergency_spillway
           , NEW.special_structure_function
           , NEW.stormwater_tank_arrangement
           , NEW.upper_elevation
           );

    -- Discharge Point
    WHEN NEW.ws_type = 'discharge_point' THEN
      INSERT INTO qgep_od.discharge_point(
             obj_id
           , highwater_level
           , relevance
           , terrain_level
           , upper_elevation
           , waterlevel_hydraulic
           )
           VALUES
           (
             NEW.obj_id
           , NEW.highwater_level
           , NEW.relevance
           , NEW.terrain_level
           , NEW.upper_elevation
           , NEW.waterlevel_hydraulic
           );

    -- Infiltration Installation
    WHEN NEW.ws_type = 'infiltration_installation' THEN
      INSERT INTO qgep_od.infiltration_installation(
             obj_id
           , absorption_capacity
           , defects
           , dimension1
           , dimension2
           , distance_to_aquifer
           , effective_area
           , emergency_spillway
           , kind
           , labeling
           , seepage_utilization
           , upper_elevation
           , vehicle_access
           , watertightness
           )
           VALUES
           (
             NEW.obj_id
           , NEW.absorption_capacity
           , NEW.defects
           , NEW.dimension1
           , NEW.dimension2
           , NEW.distance_to_aquifer
           , NEW.effective_area
           , NEW.emergency_spillway
           , NEW.kind
           , NEW.labeling
           , NEW.seepage_utilization
           , NEW.upper_elevation
           , NEW.vehicle_access
           , NEW.watertightness
           );
    ELSE
     RAISE NOTICE 'Wastewater structure type not known (%)', NEW.ws_type; -- ERROR
  END CASE;

  INSERT INTO qgep_od.vw_wastewater_node(
      obj_id
    , backflow_level
    , bottom_level
    , situation_geometry
    , identifier
    , remark
    , last_modification
    , fk_dataowner
    , fk_provider
    , fk_wastewater_structure
  )
  VALUES
  (
      NEW.wn_obj_id
    , NEW.backflow_level
    , NEW.bottom_level
    , ST_GeometryN( NEW.situation_geometry, 1 )
    , COALESCE(NULLIF(NEW.wn_identifier,''), NEW.identifier)
    , NEW.wn_remark
    , NOW()
    , COALESCE(NULLIF(NEW.wn_fk_provider,''), NEW.fk_provider)
    , COALESCE(NULLIF(NEW.wn_fk_dataowner,''), NEW.fk_dataowner)
    , NEW.obj_id
  );

  INSERT INTO qgep_od.vw_cover(
      obj_id
    , brand
    , cover_shape
    , diameter
    , fastening
    , level
    , material
    , positional_accuracy
    , situation_geometry
    , sludge_bucket
    , venting
    , identifier
    , remark
    , renovation_demand
    , last_modification
    , fk_dataowner
    , fk_provider
    , fk_wastewater_structure
  )
  VALUES
  (
      NEW.co_obj_id
    , NEW.brand
    , NEW.cover_shape
    , NEW.diameter
    , NEW.fastening
    , NEW.level
    , NEW.cover_material
    , NEW.positional_accuracy
    , ST_GeometryN( NEW.situation_geometry, 1 )
    , NEW.sludge_bucket
    , NEW.venting
    , COALESCE(NULLIF(NEW.co_identifier,''), NEW.identifier)
    , NEW.remark
    , NEW.renovation_demand
    , NOW()
    , NEW.fk_dataowner
    , NEW.fk_provider
    , NEW.obj_id
  );

  UPDATE qgep_od.wastewater_structure
  SET fk_main_cover = NEW.co_obj_id
  WHERE obj_id = NEW.obj_id;
  
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_qgep_wastewater_structure_insert() OWNER TO postgres;

--
-- Name: vw_qgep_wastewater_structure_update(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_qgep_wastewater_structure_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  dx float;
  dy float;
BEGIN
    UPDATE qgep_od.cover
      SET
        brand = NEW.brand,
        cover_shape = new.cover_shape,
        diameter = new.diameter,
        fastening = new.fastening,
        level = new.level,
        material = new.cover_material,
        positional_accuracy = new.positional_accuracy,
        sludge_bucket = new.sludge_bucket,
        venting = new.venting
    WHERE cover.obj_id::text = OLD.co_obj_id::text;

    UPDATE qgep_od.structure_part
      SET
        identifier = new.co_identifier,
        remark = new.remark,
        renovation_demand = new.renovation_demand,
        last_modification = new.last_modification,
        fk_dataowner = new.fk_dataowner,
        fk_provider = new.fk_provider
    WHERE structure_part.obj_id::text = OLD.co_obj_id::text;

    UPDATE qgep_od.wastewater_structure
      SET
        obj_id = NEW.obj_id,
        identifier = NEW.identifier,
        accessibility = NEW.accessibility,
        contract_section = NEW.contract_section,
        financing = NEW.financing,
        gross_costs = NEW.gross_costs,
        inspection_interval = NEW.inspection_interval,
        location_name = NEW.location_name,
        records = NEW.records,
        remark = NEW.ws_remark,
        renovation_necessity = NEW.renovation_necessity,
        replacement_value = NEW.replacement_value,
        rv_base_year = NEW.rv_base_year,
        rv_construction_type = NEW.rv_construction_type,
        status = NEW.status,
        structure_condition = NEW.structure_condition,
        subsidies = NEW.subsidies,
        year_of_construction = NEW.year_of_construction,
        year_of_replacement = NEW.year_of_replacement,
        fk_owner = NEW.fk_owner,
        fk_operator = NEW.fk_operator
     WHERE wastewater_structure.obj_id::text = OLD.obj_id::text;

  IF OLD.ws_type <> NEW.ws_type THEN
    CASE
      WHEN OLD.ws_type = 'manhole' THEN DELETE FROM qgep_od.manhole WHERE obj_id = OLD.obj_id;
      WHEN OLD.ws_type = 'special_structure' THEN DELETE FROM qgep_od.special_structure WHERE obj_id = OLD.obj_id;
      WHEN OLD.ws_type = 'discharge_point' THEN DELETE FROM qgep_od.discharge_point WHERE obj_id = OLD.obj_id;
      WHEN OLD.ws_type = 'infiltration_installation' THEN DELETE FROM qgep_od.infiltration_installation WHERE obj_id = OLD.obj_id;
    END CASE;

    CASE
      WHEN NEW.ws_type = 'manhole' THEN INSERT INTO qgep_od.manhole (obj_id) VALUES(OLD.obj_id);
      WHEN NEW.ws_type = 'special_structure' THEN INSERT INTO qgep_od.special_structure (obj_id) VALUES(OLD.obj_id);
      WHEN NEW.ws_type = 'discharge_point' THEN INSERT INTO qgep_od.discharge_point (obj_id) VALUES(OLD.obj_id);
      WHEN NEW.ws_type = 'infiltration_installation' THEN INSERT INTO qgep_od.infiltration_installation (obj_id) VALUES(OLD.obj_id);
    END CASE;
  END IF;

  CASE
    WHEN NEW.ws_type = 'manhole' THEN
      UPDATE qgep_od.manhole
      SET
        dimension1 = NEW.dimension1,
        dimension2 = NEW.dimension2,
        function = NEW.manhole_function,
        material = NEW.material,
        surface_inflow = NEW.surface_inflow
      WHERE obj_id = OLD.obj_id;

    WHEN NEW.ws_type = 'special_structure' THEN
      UPDATE qgep_od.special_structure
      SET
        bypass = NEW.bypass,
        emergency_spillway = NEW.emergency_spillway,
        function = NEW.special_structure_function,
        stormwater_tank_arrangement = NEW.stormwater_tank_arrangement,
        upper_elevation = NEW.upper_elevation
      WHERE obj_id = OLD.obj_id;

    WHEN NEW.ws_type = 'discharge_point' THEN
      UPDATE qgep_od.discharge_point
      SET
        highwater_level = NEW.highwater_level,
        relevance = NEW.relevance,
        terrain_level = NEW.terrain_level,
        upper_elevation = NEW.upper_elevation,
        waterlevel_hydraulic = NEW.waterlevel_hydraulic
      WHERE obj_id = OLD.obj_id;

    WHEN NEW.ws_type = 'infiltration_installation' THEN
      UPDATE qgep_od.infiltration_installation
      SET
        absorption_capacity = NEW.absorption_capacity,
        defects = NEW.defects,
        dimension1 = NEW.dimension1,
        dimension2 = NEW.dimension2,
        distance_to_aquifer = NEW.distance_to_aquifer,
        effective_area = NEW.effective_area,
        emergency_spillway = NEW.emergency_spillway,
        kind = NEW.kind,
        labeling = NEW.labeling,
        seepage_utilization = NEW.seepage_utilization,
        upper_elevation = NEW.upper_elevation,
        vehicle_access = NEW.vehicle_access,
        watertightness = NEW.watertightness
      WHERE obj_id = OLD.obj_id;
  END CASE;

  UPDATE qgep_od.vw_wastewater_node NO1
    SET
    backflow_level = NEW.backflow_level
    , bottom_level = NEW.bottom_level
    -- , situation_geometry = NEW.situation_geometry -- Geometry is handled separately below
    , identifier = NEW.identifier
    , remark = NEW.wn_remark
    -- , last_modification -- Handled by triggers
    , fk_dataowner = NEW.fk_dataowner
    , fk_provider = NEW.fk_provider
    -- Only update if there is a single wastewater node on this structure
    WHERE fk_wastewater_structure = NEW.obj_id AND
    (
      SELECT COUNT(*)
      FROM qgep_od.vw_wastewater_node NO2
      WHERE NO2.fk_wastewater_structure = NO1.fk_wastewater_structure
    ) = 1;

  -- Cover geometry has been moved
  IF NOT ST_Equals( OLD.situation_geometry, NEW.situation_geometry) THEN
    dx = ST_XMin(NEW.situation_geometry) - ST_XMin(OLD.situation_geometry);
    dy = ST_YMin(NEW.situation_geometry) - ST_YMin(OLD.situation_geometry);
  
    -- Move wastewater node as well
    UPDATE qgep_od.wastewater_node WN
    SET situation_geometry = ST_TRANSLATE(WN.situation_geometry, dx, dy )
    WHERE obj_id IN 
    (
      SELECT obj_id FROM qgep_od.wastewater_networkelement
      WHERE fk_wastewater_structure = NEW.obj_id
    );

    -- Move covers
    UPDATE qgep_od.cover CO
    SET situation_geometry = ST_TRANSLATE(CO.situation_geometry, dx, dy )
    WHERE obj_id IN
    (
      SELECT obj_id FROM qgep_od.structure_part
      WHERE fk_wastewater_structure = NEW.obj_id
    );

    -- Move reach(es) as well
    UPDATE qgep_od.reach RE
    SET progression_geometry = 
      ST_ForceCurve (ST_SetPoint(
        ST_CurveToLine (RE.progression_geometry ),
        0, -- SetPoint index is 0 based, PointN index is 1 based.
        ST_TRANSLATE(ST_PointN(RE.progression_geometry, 1), dx, dy )
      ) )
    WHERE fk_reach_point_from IN 
    (
      SELECT RP.obj_id FROM qgep_od.reach_point RP
      LEFT JOIN qgep_od.wastewater_networkelement NE ON RP.fk_wastewater_networkelement = NE.obj_id
      WHERE NE.fk_wastewater_structure = NEW.obj_id
    );

    UPDATE qgep_od.reach RE
    SET progression_geometry = 
      ST_ForceCurve( ST_SetPoint(
        ST_CurveToLine( RE.progression_geometry ),
        ST_NumPoints(RE.progression_geometry) - 1,
        ST_TRANSLATE(ST_EndPoint(RE.progression_geometry), dx, dy )
      ) )
    WHERE fk_reach_point_to IN 
    (
      SELECT RP.obj_id FROM qgep_od.reach_point RP
      LEFT JOIN qgep_od.wastewater_networkelement NE ON RP.fk_wastewater_networkelement = NE.obj_id
      WHERE NE.fk_wastewater_structure = NEW.obj_id
    );
  END IF;

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_qgep_wastewater_structure_update() OWNER TO postgres;

--
-- Name: vw_reach_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_reach_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.wastewater_networkelement (
             obj_id
           , identifier
           , remark
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','reach')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.reach (
             obj_id
           , clear_height
           , coefficient_of_friction
           , elevation_determination
           , horizontal_positioning
           , inside_coating
           , length_effective
           , material
           , progression_geometry
           , reliner_material
           , reliner_nominal_size
           , relining_construction
           , relining_kind
           , ring_stiffness
           , slope_building_plan
           , wall_roughness
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.clear_height
           , NEW.coefficient_of_friction
           , NEW.elevation_determination
           , NEW.horizontal_positioning
           , NEW.inside_coating
           , NEW.length_effective
           , NEW.material
           , NEW.progression_geometry
           , NEW.reliner_material
           , NEW.reliner_nominal_size
           , NEW.relining_construction
           , NEW.relining_kind
           , NEW.ring_stiffness
           , NEW.slope_building_plan
           , NEW.wall_roughness
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_reach_insert() OWNER TO postgres;

--
-- Name: vw_special_structure_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_special_structure_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.wastewater_structure (
             obj_id
           , accessibility
           , contract_section
            , detail_geometry_geometry
           , financing
           , gross_costs
           , identifier
           , inspection_interval
           , location_name
           , records
           , remark
           , renovation_necessity
           , replacement_value
           , rv_base_year
           , rv_construction_type
           , status
           , structure_condition
           , subsidies
           , year_of_construction
           , year_of_replacement
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_owner
           , fk_operator
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','special_structure')) -- obj_id
           , NEW.accessibility
           , NEW.contract_section
            , NEW.detail_geometry_geometry
           , NEW.financing
           , NEW.gross_costs
           , NEW.identifier
           , NEW.inspection_interval
           , NEW.location_name
           , NEW.records
           , NEW.remark
           , NEW.renovation_necessity
           , NEW.replacement_value
           , NEW.rv_base_year
           , NEW.rv_construction_type
           , NEW.status
           , NEW.structure_condition
           , NEW.subsidies
           , NEW.year_of_construction
           , NEW.year_of_replacement
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_owner
           , NEW.fk_operator
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.special_structure (
             obj_id
           , bypass
           , emergency_spillway
           , function
           , stormwater_tank_arrangement
           , upper_elevation
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.bypass
           , NEW.emergency_spillway
           , NEW.function
           , NEW.stormwater_tank_arrangement
           , NEW.upper_elevation
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_special_structure_insert() OWNER TO postgres;

--
-- Name: vw_wastewater_node_insert(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.vw_wastewater_node_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO qgep_od.wastewater_networkelement (
             obj_id
           , identifier
           , remark
           , fk_dataowner
           , fk_provider
           , last_modification
           , fk_wastewater_structure
           )
     VALUES ( COALESCE(NEW.obj_id,qgep_sys.generate_oid('qgep_od','wastewater_node')) -- obj_id
           , NEW.identifier
           , NEW.remark
           , NEW.fk_dataowner
           , NEW.fk_provider
           , NEW.last_modification
           , NEW.fk_wastewater_structure
           )
           RETURNING obj_id INTO NEW.obj_id;

INSERT INTO qgep_od.wastewater_node (
             obj_id
           , backflow_level
           , bottom_level
           , situation_geometry
           )
          VALUES (
            NEW.obj_id -- obj_id
           , NEW.backflow_level
           , NEW.bottom_level
           , NEW.situation_geometry
           );
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.vw_wastewater_node_insert() OWNER TO postgres;

--
-- Name: ws_symbology_update_by_channel(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ws_symbology_update_by_channel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _ws RECORD;
  ch_obj_id TEXT;
BEGIN
  CASE
    WHEN TG_OP = 'UPDATE' THEN
      ch_obj_id = OLD.obj_id;
    WHEN TG_OP = 'INSERT' THEN
      ch_obj_id = NEW.obj_id;
    WHEN TG_OP = 'DELETE' THEN
      ch_obj_id = OLD.obj_id;
  END CASE;

  SELECT ws.obj_id INTO _ws
    FROM qgep_od.wastewater_networkelement ch_ne
    LEFT JOIN qgep_od.reach re ON ch_ne.obj_id = re.obj_id
    LEFT JOIN qgep_od.reach_point rp ON (re.fk_reach_point_from = rp.obj_id OR re.fk_reach_point_to = rp.obj_id )
    LEFT JOIN qgep_od.wastewater_networkelement ne ON rp.fk_wastewater_networkelement = ne.obj_id
    LEFT JOIN qgep_od.wastewater_structure ws ON ne.fk_wastewater_structure = ws.obj_id
    WHERE ch_ne.fk_wastewater_structure = ch_obj_id;

  EXECUTE qgep_od.update_wastewater_structure_symbology(_ws.obj_id);
  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.ws_symbology_update_by_channel() OWNER TO postgres;

--
-- Name: ws_symbology_update_by_reach(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ws_symbology_update_by_reach() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _ws RECORD;
  symb_attribs RECORD;
  re_obj_id TEXT;
BEGIN
  CASE
    WHEN TG_OP = 'UPDATE' THEN
      re_obj_id = OLD.obj_id;
    WHEN TG_OP = 'INSERT' THEN
      re_obj_id = NEW.obj_id;
    WHEN TG_OP = 'DELETE' THEN
      re_obj_id = OLD.obj_id;
  END CASE;

  SELECT ws.obj_id INTO _ws
    FROM qgep_od.reach re
    LEFT JOIN qgep_od.reach_point rp ON ( rp.obj_id = re.fk_reach_point_from OR rp.obj_id = re.fk_reach_point_to )
    LEFT JOIN qgep_od.wastewater_networkelement ne ON ne.obj_id = rp.fk_wastewater_networkelement
    LEFT JOIN qgep_od.wastewater_structure ws ON ws.obj_id = ne.fk_wastewater_structure
    WHERE re.obj_id = re_obj_id;

  EXECUTE qgep_od.update_wastewater_structure_symbology(_ws.obj_id);

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.ws_symbology_update_by_reach() OWNER TO postgres;

--
-- Name: ws_symbology_update_by_reach_point(); Type: FUNCTION; Schema: qgep_od; Owner: postgres
--

CREATE FUNCTION qgep_od.ws_symbology_update_by_reach_point() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _ws RECORD;
  rp_obj_id TEXT;
BEGIN
  CASE
    WHEN TG_OP = 'UPDATE' THEN
      rp_obj_id = OLD.obj_id;
    WHEN TG_OP = 'INSERT' THEN
      rp_obj_id = NEW.obj_id;
    WHEN TG_OP = 'DELETE' THEN
      rp_obj_id = OLD.obj_id;
  END CASE;

  SELECT ws.obj_id INTO _ws
    FROM qgep_od.wastewater_structure ws
    LEFT JOIN qgep_od.wastewater_networkelement ne ON ws.obj_id = ne.fk_wastewater_structure
    LEFT JOIN qgep_od.reach_point rp ON ne.obj_id = rp.fk_wastewater_networkelement
    WHERE rp.obj_id = rp_obj_id;

  EXECUTE qgep_od.update_wastewater_structure_symbology(_ws.obj_id);

  RETURN NEW;
END; $$;


ALTER FUNCTION qgep_od.ws_symbology_update_by_reach_point() OWNER TO postgres;

--
-- Name: audit_table(regclass); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.audit_table(target_table regclass) RETURNS void
    LANGUAGE sql
    AS $_$
SELECT qgep_sys.audit_table($1, BOOLEAN 't', BOOLEAN 't');
$_$;


ALTER FUNCTION qgep_sys.audit_table(target_table regclass) OWNER TO postgres;

--
-- Name: audit_table(regclass, boolean, boolean); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean) RETURNS void
    LANGUAGE sql
    AS $_$
SELECT qgep_sys.audit_table($1, $2, $3, ARRAY[]::text[]);
$_$;


ALTER FUNCTION qgep_sys.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean) OWNER TO postgres;

--
-- Name: audit_table(regclass, boolean, boolean, text[]); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  stm_targets text = 'INSERT OR UPDATE OR DELETE OR TRUNCATE';
  _q_txt text;
  _ignored_cols_snip text = '';
BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_row ON ' || target_table::text;
    EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_stm ON ' || target_table::text;
 
    IF audit_rows THEN
        IF array_length(ignored_cols,1) > 0 THEN
            _ignored_cols_snip = ', ' || quote_literal(ignored_cols);
        END IF;
        _q_txt = 'CREATE TRIGGER audit_trigger_row AFTER INSERT OR UPDATE OR DELETE ON ' || 
                 target_table::text || 
                 ' FOR EACH ROW EXECUTE PROCEDURE qgep_sys.if_modified_func(' ||
                 quote_literal(audit_query_text) || _ignored_cols_snip || ');';
        RAISE NOTICE '%',_q_txt;
        EXECUTE _q_txt;
        stm_targets = 'TRUNCATE';
    ELSE
    END IF;
 
    _q_txt = 'CREATE TRIGGER audit_trigger_stm AFTER ' || stm_targets || ' ON ' ||
             target_table::text ||
             ' FOR EACH STATEMENT EXECUTE PROCEDURE qgep_sys.if_modified_func('||
             quote_literal(audit_query_text) || ');';
    RAISE NOTICE '%',_q_txt;
    EXECUTE _q_txt;
 
END;
$$;


ALTER FUNCTION qgep_sys.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text[]) OWNER TO postgres;

--
-- Name: FUNCTION audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text[]); Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON FUNCTION qgep_sys.audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text[]) IS '
ADD auditing support TO a TABLE.
 
Arguments:
   target_table:     TABLE name, schema qualified IF NOT ON search_path
   audit_rows:       Record each row CHANGE, OR only audit at a statement level
   audit_query_text: Record the text of the client query that triggered the audit event?
   ignored_cols:     COLUMNS TO exclude FROM UPDATE diffs, IGNORE updates that CHANGE only ignored cols.
';


--
-- Name: create_symbology_triggers(); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.create_symbology_triggers() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- only update -> insert and delete are handled by reach trigger
  CREATE TRIGGER on_reach_point_update
  AFTER UPDATE
    ON qgep_od.reach_point
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.on_reach_point_update();

  CREATE TRIGGER on_reach_change
  AFTER INSERT OR UPDATE OR DELETE
    ON qgep_od.reach
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.on_reach_change();

  CREATE TRIGGER calculate_reach_length
  BEFORE INSERT OR UPDATE
    ON qgep_od.reach
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.calculate_reach_length();


  CREATE TRIGGER ws_symbology_update_by_reach
  AFTER INSERT OR UPDATE OR DELETE
    ON qgep_od.reach
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.ws_symbology_update_by_reach();


  CREATE TRIGGER on_wastewater_structure_update
  AFTER UPDATE
    ON qgep_od.wastewater_structure
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.on_wastewater_structure_update();

  CREATE TRIGGER ws_label_update_by_wastewater_networkelement
  AFTER INSERT OR UPDATE OR DELETE
    ON qgep_od.wastewater_networkelement
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.on_structure_part_change_networkelement();

  CREATE TRIGGER on_structure_part_change
  AFTER INSERT OR UPDATE OR DELETE
    ON qgep_od.structure_part
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.on_structure_part_change_networkelement();

  CREATE TRIGGER on_cover_change
  AFTER INSERT OR UPDATE OR DELETE
    ON qgep_od.cover
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.on_cover_change();

  CREATE TRIGGER ws_symbology_update_by_channel
  AFTER INSERT OR UPDATE OR DELETE
  ON qgep_od.channel
  FOR EACH ROW
  EXECUTE PROCEDURE qgep_od.ws_symbology_update_by_channel();

  -- only update -> insert and delete are handled by reach trigger
  CREATE TRIGGER ws_symbology_update_by_reach_point
  AFTER UPDATE
    ON qgep_od.reach_point
  FOR EACH ROW
    EXECUTE PROCEDURE qgep_od.ws_symbology_update_by_reach_point();


  RETURN;
END;
$$;


ALTER FUNCTION qgep_sys.create_symbology_triggers() OWNER TO postgres;

--
-- Name: generate_oid(text, text); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.generate_oid(schema_name text, table_name text) RETURNS text
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
  myrec_prefix record;
  myrec_shortcut record;
  myrec_seq record;
BEGIN
  -- first we have to get the OID prefix
  BEGIN
    SELECT prefix::text INTO myrec_prefix FROM qgep_sys.oid_prefixes WHERE active = TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE EXCEPTION 'no active record found in table qgep_sys.oid_prefixes';
        WHEN TOO_MANY_ROWS THEN
	   RAISE EXCEPTION 'more than one active records found in table qgep_sys.oid_prefixes';
  END;
  -- test if prefix is of correct length
  IF char_length(myrec_prefix.prefix) != 8 THEN
    RAISE EXCEPTION 'character length of prefix must be 8';
  END IF;
  --get table 2char shortcut
  BEGIN
    SELECT shortcut_en INTO STRICT myrec_shortcut FROM qgep_sys.dictionary_od_table WHERE tablename = table_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'dictionary entry for table % not found', table_name;
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'dictonary entry for table % not unique', table_name;
  END;
  --get sequence for table
  EXECUTE format('SELECT nextval(''%1$I.seq_%2$I_oid'') AS seqval', schema_name, table_name) INTO myrec_seq;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'sequence for table % not found', table_name;
  END IF;
  RETURN myrec_prefix.prefix || myrec_shortcut.shortcut_en || to_char(myrec_seq.seqval,'FM000000');
END;
$_$;


ALTER FUNCTION qgep_sys.generate_oid(schema_name text, table_name text) OWNER TO postgres;

--
-- Name: if_modified_func(); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.if_modified_func() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO pg_catalog, public
    AS $$
DECLARE
    audit_row qgep_sys.logged_actions;
    include_values BOOLEAN;
    log_diffs BOOLEAN;
    h_old hstore;
    h_new hstore;
    excluded_cols text[] = ARRAY[]::text[];
BEGIN
    IF TG_WHEN <> 'AFTER' THEN
        RAISE EXCEPTION 'qgep_sys.if_modified_func() may only run as an AFTER trigger';
    END IF;
 
    audit_row = ROW(
        NEXTVAL('qgep_sys.logged_actions_event_id_seq'), -- event_id
        TG_TABLE_SCHEMA::text,                        -- schema_name
        TG_TABLE_NAME::text,                          -- table_name
        TG_RELID,                                     -- relation OID for much quicker searches
        session_user::text,                           -- session_user_name
        current_timestamp,                            -- action_tstamp_tx
        statement_timestamp(),                        -- action_tstamp_stm
        clock_timestamp(),                            -- action_tstamp_clk
        txid_current(),                               -- transaction ID
        (SELECT setting FROM pg_settings WHERE name = 'application_name'),
        inet_client_addr(),                           -- client_addr
        inet_client_port(),                           -- client_port
        current_query(),                              -- top-level query or queries (if multistatement) from client
        substring(TG_OP,1,1),                         -- action
        NULL, NULL,                                   -- row_data, changed_fields
        'f'                                           -- statement_only
        );
 
    IF NOT TG_ARGV[0]::BOOLEAN IS DISTINCT FROM 'f'::BOOLEAN THEN
        audit_row.client_query = NULL;
    END IF;
 
    IF TG_ARGV[1] IS NOT NULL THEN
        excluded_cols = TG_ARGV[1]::text[];
    END IF;
 
    IF (TG_OP = 'UPDATE' AND TG_LEVEL = 'ROW') THEN
        audit_row.row_data = hstore(OLD.*);
        audit_row.changed_fields =  (hstore(NEW.*) - audit_row.row_data) - excluded_cols;
        IF audit_row.changed_fields = hstore('') THEN
            -- All changed fields are ignored. Skip this update.
            RETURN NULL;
        END IF;
    ELSIF (TG_OP = 'DELETE' AND TG_LEVEL = 'ROW') THEN
        audit_row.row_data = hstore(OLD.*) - excluded_cols;
    ELSIF (TG_OP = 'INSERT' AND TG_LEVEL = 'ROW') THEN
        audit_row.row_data = hstore(NEW.*) - excluded_cols;
    ELSIF (TG_LEVEL = 'STATEMENT' AND TG_OP IN ('INSERT','UPDATE','DELETE','TRUNCATE')) THEN
        audit_row.statement_only = 't';
    ELSE
        RAISE EXCEPTION '[qgep_sys.if_modified_func] - Trigger func added as trigger for unhandled case: %, %',TG_OP, TG_LEVEL;
        RETURN NULL;
    END IF;
    INSERT INTO qgep_sys.logged_actions VALUES (audit_row.*);
    RETURN NULL;
END;
$$;


ALTER FUNCTION qgep_sys.if_modified_func() OWNER TO postgres;

--
-- Name: FUNCTION if_modified_func(); Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON FUNCTION qgep_sys.if_modified_func() IS '
Track changes TO a TABLE at the statement AND/OR row level.
 
Optional parameters TO TRIGGER IN CREATE TRIGGER call:
 
param 0: BOOLEAN, whether TO log the query text. DEFAULT ''t''.
 
param 1: text[], COLUMNS TO IGNORE IN updates. DEFAULT [].
 
         Updates TO ignored cols are omitted FROM changed_fields.
 
         Updates WITH only ignored cols changed are NOT inserted
         INTO the audit log.
 
         Almost ALL the processing work IS still done FOR updates
         that ignored. IF you need TO save the LOAD, you need TO USE
         WHEN clause ON the TRIGGER instead.
 
         No warning OR error IS issued IF ignored_cols contains COLUMNS
         that do NOT exist IN the target TABLE. This lets you specify
         a standard SET of ignored COLUMNS.
 
There IS no parameter TO disable logging of VALUES. ADD this TRIGGER AS
a ''FOR EACH STATEMENT'' rather than ''FOR EACH ROW'' TRIGGER IF you do NOT
want TO log row VALUES.
 
Note that the user name logged IS the login role FOR the session. The audit TRIGGER
cannot obtain the active role because it IS reset BY the SECURITY DEFINER invocation
of the audit TRIGGER its self.
';


--
-- Name: update_last_modified(); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.update_last_modified() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 NEW.last_modification := TIMEOFDAY();

 RETURN NEW;
END;
$$;


ALTER FUNCTION qgep_sys.update_last_modified() OWNER TO postgres;

--
-- Name: update_last_modified_parent(); Type: FUNCTION; Schema: qgep_sys; Owner: postgres
--

CREATE FUNCTION qgep_sys.update_last_modified_parent() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
 table_name TEXT;
BEGIN
 table_name = TG_ARGV[0];

 EXECUTE '
 UPDATE ' || table_name || '
 SET last_modification = TIMEOFDAY()::timestamp
 WHERE obj_id = ''' || NEW.obj_id || '''
';
 RETURN NEW;
END;
$$;


ALTER FUNCTION qgep_sys.update_last_modified_parent() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access_aid; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.access_aid (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'access_aid'::text) NOT NULL,
    kind integer
);


ALTER TABLE qgep_od.access_aid OWNER TO postgres;

--
-- Name: COLUMN access_aid.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.access_aid.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN access_aid.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.access_aid.kind IS 'yyy_Art des Einstiegs in das Bauwerk / Art des Einstiegs in das Bauwerk / Genre d''accès à l''ouvrage';


--
-- Name: accident; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.accident (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'accident'::text) NOT NULL,
    date timestamp without time zone,
    identifier character varying(20),
    place character varying(50),
    remark character varying(80),
    responsible character varying(50),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_hazard_source character varying(16)
);


ALTER TABLE qgep_od.accident OWNER TO postgres;

--
-- Name: COLUMN accident.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN accident.date; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.date IS 'Date of accident / Datum des Ereignisses / Date de l''événement';


--
-- Name: COLUMN accident.place; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.place IS 'Adress of the location of accident / Adresse der Unfallstelle / Adresse du lieu de l''accident';


--
-- Name: COLUMN accident.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN accident.responsible; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.responsible IS 'Name of the responsible of the accident / Name Adresse des Verursachers / Nom et adresse de l''auteur';


--
-- Name: COLUMN accident.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.situation_geometry IS 'National position coordinates (North, East) of accident / Landeskoordinate Ost/Nord des Unfallortes / Coordonnées nationales Est/Nord du lieu d''accident';


--
-- Name: COLUMN accident.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN accident.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN accident.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.accident.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: administrative_office; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.administrative_office (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'administrative_office'::text) NOT NULL
);


ALTER TABLE qgep_od.administrative_office OWNER TO postgres;

--
-- Name: COLUMN administrative_office.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.administrative_office.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: aquifier; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.aquifier (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'aquifier'::text) NOT NULL,
    average_groundwater_level numeric(7,3),
    identifier character varying(20),
    maximal_groundwater_level numeric(7,3),
    minimal_groundwater_level numeric(7,3),
    perimeter_geometry public.geometry(CurvePolygon,2056),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.aquifier OWNER TO postgres;

--
-- Name: COLUMN aquifier.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN aquifier.average_groundwater_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.average_groundwater_level IS 'Average level of groundwater table / Höhe des mittleren Grundwasserspiegels / Niveau moyen de la nappe';


--
-- Name: COLUMN aquifier.maximal_groundwater_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.maximal_groundwater_level IS 'Maximal level of ground water table / Maximale Lage des Grundwasserspiegels / Niveau maximal de la nappe';


--
-- Name: COLUMN aquifier.minimal_groundwater_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.minimal_groundwater_level IS 'Minimal level of groundwater table / Minimale Lage des Grundwasserspiegels / Niveau minimal de la nappe';


--
-- Name: COLUMN aquifier.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: COLUMN aquifier.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN aquifier.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN aquifier.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN aquifier.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.aquifier.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: backflow_prevention; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.backflow_prevention (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'backflow_prevention'::text) NOT NULL,
    gross_costs numeric(10,2),
    kind integer,
    year_of_replacement smallint,
    fk_throttle_shut_off_unit character varying(16),
    fk_pump character varying(16)
);


ALTER TABLE qgep_od.backflow_prevention OWNER TO postgres;

--
-- Name: COLUMN backflow_prevention.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.backflow_prevention.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN backflow_prevention.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.backflow_prevention.gross_costs IS 'Gross costs / Brutto Erstellungskosten / Coûts bruts de réalisation';


--
-- Name: COLUMN backflow_prevention.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.backflow_prevention.kind IS 'Ist keine Rückstausicherung vorhanden, wird keine Rueckstausicherung erfasst. /  Ist keine Rückstausicherung vorhanden, wird keine Rueckstausicherung erfasst / En absence de protection, laisser la composante vide';


--
-- Name: COLUMN backflow_prevention.year_of_replacement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.backflow_prevention.year_of_replacement IS 'yyy_Jahr in dem die Lebensdauer der Rückstausicherung voraussichtlich abläuft / Jahr in dem die Lebensdauer der Rückstausicherung voraussichtlich abläuft / Année pour laquelle on prévoit que la durée de vie de l''équipement soit écoulée';


--
-- Name: bathing_area; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.bathing_area (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'bathing_area'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_chute character varying(16)
);


ALTER TABLE qgep_od.bathing_area OWNER TO postgres;

--
-- Name: COLUMN bathing_area.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.bathing_area.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN bathing_area.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.bathing_area.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN bathing_area.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.bathing_area.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: COLUMN bathing_area.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.bathing_area.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN bathing_area.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.bathing_area.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN bathing_area.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.bathing_area.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: benching; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.benching (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'benching'::text) NOT NULL,
    kind integer
);


ALTER TABLE qgep_od.benching OWNER TO postgres;

--
-- Name: COLUMN benching.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.benching.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: blocking_debris; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.blocking_debris (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'blocking_debris'::text) NOT NULL,
    vertical_drop numeric(7,2)
);


ALTER TABLE qgep_od.blocking_debris OWNER TO postgres;

--
-- Name: COLUMN blocking_debris.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.blocking_debris.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN blocking_debris.vertical_drop; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.blocking_debris.vertical_drop IS 'yyy_Vertical difference of water level before and after Sperre / Differenz des Wasserspiegels vor und nach der Sperre / Différence de la hauteur du plan d''eau avant et après le barrage';


--
-- Name: building; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.building (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'building'::text) NOT NULL,
    house_number character varying(50),
    location_name character varying(50),
    perimeter_geometry public.geometry(CurvePolygon,2056),
    reference_point_geometry public.geometry(Point,2056)
);


ALTER TABLE qgep_od.building OWNER TO postgres;

--
-- Name: COLUMN building.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.building.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN building.house_number; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.building.house_number IS 'House number based on cadastral register / Hausnummer gemäss Grundbuch / Numéro de bâtiment selon le registre foncier';


--
-- Name: COLUMN building.location_name; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.building.location_name IS 'Street name or name of the location / Strassenname oder Ortsbezeichnung / Nom de la route ou du lieu';


--
-- Name: COLUMN building.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.building.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: COLUMN building.reference_point_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.building.reference_point_geometry IS 'National position coordinates (East, North) (relevant point for e.g. address) / Landeskoordinate Ost/Nord (massgebender Bezugspunkt für z.B. Adressdaten ) / Coordonnées nationales Est/Nord (Point de référence pour la détermination de l''adresse par exemple)';


--
-- Name: canton; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.canton (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'canton'::text) NOT NULL,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.canton OWNER TO postgres;

--
-- Name: COLUMN canton.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.canton.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN canton.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.canton.perimeter_geometry IS 'Border of canton / Kantonsgrenze / Limites cantonales';


--
-- Name: catchment_area; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.catchment_area (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'catchment_area'::text) NOT NULL,
    direct_discharge_current integer,
    direct_discharge_planned integer,
    discharge_coefficient_rw_current numeric(5,2),
    discharge_coefficient_rw_planned numeric(5,2),
    discharge_coefficient_ww_current numeric(5,2),
    discharge_coefficient_ww_planned numeric(5,2),
    drainage_system_current integer,
    drainage_system_planned integer,
    identifier character varying(20),
    infiltration_current integer,
    infiltration_planned integer,
    perimeter_geometry public.geometry(CurvePolygon,2056),
    population_density_current smallint,
    population_density_planned smallint,
    remark character varying(80),
    retention_current integer,
    retention_planned integer,
    runoff_limit_current numeric(4,1),
    runoff_limit_planned numeric(4,1),
    seal_factor_rw_current numeric(5,2),
    seal_factor_rw_planned numeric(5,2),
    seal_factor_ww_current numeric(5,2),
    seal_factor_ww_planned numeric(5,2),
    sewer_infiltration_water_production_current numeric(9,3),
    sewer_infiltration_water_production_planned numeric(9,3),
    surface_area numeric(8,2),
    waste_water_production_current numeric(9,3),
    waste_water_production_planned numeric(9,3),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_networkelement_rw_current character varying(16),
    fk_wastewater_networkelement_rw_planned character varying(16),
    fk_wastewater_networkelement_ww_planned character varying(16),
    fk_wastewater_networkelement_ww_current character varying(16)
);


ALTER TABLE qgep_od.catchment_area OWNER TO postgres;

--
-- Name: COLUMN catchment_area.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN catchment_area.direct_discharge_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.direct_discharge_current IS 'The rain water is currently fully or partially discharged into a water body / Das Regenabwasser wird ganz oder teilweise über eine SAA-Leitung in ein Gewässer eingeleitet / Les eaux pluviales sont rejetées complètement ou partiellement via une conduite OAS dans un cours d’eau';


--
-- Name: COLUMN catchment_area.direct_discharge_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.direct_discharge_planned IS 'The rain water will be discharged fully or partially over a SAA pipe into a water body / Das Regenabwasser wird in Zukunft ganz oder teilweise über eine SAA-Leitung in ein Gewässer eingeleitet / Les eaux pluviales seront rejetées complètement ou partiellement via une conduite OAS dans un cours d’eau';


--
-- Name: COLUMN catchment_area.discharge_coefficient_rw_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.discharge_coefficient_rw_current IS 'yyy_Abflussbeiwert für den Regenabwasseranschluss im Ist-Zustand / Abflussbeiwert für den Regenabwasseranschluss im Ist-Zustand / Coefficient de ruissellement pour le raccordement actuel des eaux pluviales';


--
-- Name: COLUMN catchment_area.discharge_coefficient_rw_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.discharge_coefficient_rw_planned IS 'yyy_Abflussbeiwert für den Regenabwasseranschluss im Planungszustand / Abflussbeiwert für den Regenabwasseranschluss im Planungszustand / Coefficient de ruissellement prévu pour le raccordement des eaux pluviales';


--
-- Name: COLUMN catchment_area.discharge_coefficient_ww_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.discharge_coefficient_ww_current IS 'yy_Abflussbeiwert für den Schmutz- oder Mischabwasseranschluss im Ist-Zustand / Abflussbeiwert für den Schmutz- oder Mischabwasseranschluss im Ist-Zustand / Coefficient de ruissellement pour les raccordements eaux usées et eaux mixtes actuels';


--
-- Name: COLUMN catchment_area.discharge_coefficient_ww_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.discharge_coefficient_ww_planned IS 'yyy_Abflussbeiwert für den Schmutz- oder Mischabwasseranschluss im Planungszustand / Abflussbeiwert für den Schmutz- oder Mischabwasseranschluss im Planungszustand / Coefficient de ruissellement pour le raccordement prévu des eaux usées ou mixtes';


--
-- Name: COLUMN catchment_area.drainage_system_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.drainage_system_current IS 'yyy_Effektive Entwässerungsart im Ist-Zustand / Effektive Entwässerungsart im Ist-Zustand / Genre d’évacuation des eaux réel à l’état actuel';


--
-- Name: COLUMN catchment_area.drainage_system_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.drainage_system_planned IS 'yyy_Entwässerungsart im Planungszustand (nach Umsetzung des Entwässerungskonzepts). Dieses Attribut hat Auflagecharakter. Es ist verbindlich für die Beurteilung von Baugesuchen / Entwässerungsart im Planungszustand (nach Umsetzung des Entwässerungskonzepts). Dieses Attribut hat Auflagecharakter. Es ist verbindlich für die Beurteilung von Baugesuchen / Genre d’évacuation des eaux à l’état de planification (mise en œuvre du concept d’évacuation). Cet attribut est exigé. Il est obligatoire pour l’examen des demandes de permit de construire';


--
-- Name: COLUMN catchment_area.infiltration_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.infiltration_current IS 'yyy_Das Regenabwasser wird ganz oder teilweise einer Versickerungsanlage zugeführt / Das Regenabwasser wird ganz oder teilweise einer Versickerungsanlage zugeführt / Les eaux pluviales sont amenées complètement ou partiellement à une installation d’infiltration';


--
-- Name: COLUMN catchment_area.infiltration_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.infiltration_planned IS 'In the future the rain water will  be completly or partially infiltrated in a infiltration unit. / Das Regenabwasser wird in Zukunft ganz oder teilweise einer Versickerungsanlage zugeführt / Les eaux pluviales seront amenées complètement ou partiellement à une installation d’infiltration';


--
-- Name: COLUMN catchment_area.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.perimeter_geometry IS 'Boundary points of the perimeter sub catchement area / Begrenzungspunkte des Teileinzugsgebiets / Points de délimitation du bassin versant partiel';


--
-- Name: COLUMN catchment_area.population_density_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.population_density_current IS 'yyy_Dichte der (physischen) Einwohner im Ist-Zustand / Dichte der (physischen) Einwohner im Ist-Zustand / Densité (physique) de la population actuelle';


--
-- Name: COLUMN catchment_area.population_density_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.population_density_planned IS 'yyy_Dichte der (physischen) Einwohner im Planungszustand / Dichte der (physischen) Einwohner im Planungszustand / Densité (physique) de la population prévue';


--
-- Name: COLUMN catchment_area.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN catchment_area.retention_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.retention_current IS 'yyy_Das Regen- oder Mischabwasser wird über Rückhalteeinrichtungen verzögert ins Kanalnetz eingeleitet. / Das Regen- oder Mischabwasser wird über Rückhalteeinrichtungen verzögert ins Kanalnetz eingeleitet. / Les eaux pluviales et mixtes sont rejetées de manière régulée dans le réseau des canalisations par un ouvrage de rétention.';


--
-- Name: COLUMN catchment_area.retention_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.retention_planned IS 'yyy_Das Regen- oder Mischabwasser wird in Zukunft über Rückhalteeinrichtungen verzögert ins Kanalnetz eingeleitet. / Das Regen- oder Mischabwasser wird in Zukunft über Rückhalteeinrichtungen verzögert ins Kanalnetz eingeleitet. / Les eaux pluviales et mixtes seront rejetées de manière régulée dans le réseau des canalisations par un ouvrage de rétention.';


--
-- Name: COLUMN catchment_area.runoff_limit_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.runoff_limit_current IS 'yyy_Abflussbegrenzung, falls eine entsprechende Auflage bereits umgesetzt ist. / Abflussbegrenzung, falls eine entsprechende Auflage bereits umgesetzt ist. / Restriction de débit, si une exigence est déjà mise en œuvre';


--
-- Name: COLUMN catchment_area.runoff_limit_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.runoff_limit_planned IS 'yyy_Abflussbegrenzung, falls eine entsprechende Auflage aus dem Entwässerungskonzept vorliegt. Dieses Attribut hat Auflagecharakter. Es ist verbindlich für die Beurteilung von Baugesuchen / Abflussbegrenzung, falls eine entsprechende Auflage aus dem Entwässerungskonzept vorliegt. Dieses Attribut hat Auflagecharakter. Es ist verbindlich für die Beurteilung von Baugesuchen / Restriction de débit, si une exigence correspondante existe dans le concept d’évacuation des eaux. Cet attribut est une exigence et obligatoire pour l’examen de demandes de permit de construire';


--
-- Name: COLUMN catchment_area.seal_factor_rw_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.seal_factor_rw_current IS 'yyy_Befestigungsgrad für den Regenabwasseranschluss im Ist-Zustand / Befestigungsgrad für den Regenabwasseranschluss im Ist-Zustand / Taux d''imperméabilisation pour le raccordement eaux pluviales actuel';


--
-- Name: COLUMN catchment_area.seal_factor_rw_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.seal_factor_rw_planned IS 'yyy_Befestigungsgrad für den Regenabwasseranschluss im Planungszustand / Befestigungsgrad für den Regenabwasseranschluss im Planungszustand / Taux d''imperméabilisation pour le raccordement eaux pluviales prévu';


--
-- Name: COLUMN catchment_area.seal_factor_ww_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.seal_factor_ww_current IS 'yyy_Befestigungsgrad für den Schmutz- oder Mischabwasseranschluss im Ist-Zustand / Befestigungsgrad für den Schmutz- oder Mischabwasseranschluss im Ist-Zustand / Taux d''imperméabilisation pour les raccordements eaux usées et eaux mixtes actuels';


--
-- Name: COLUMN catchment_area.seal_factor_ww_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.seal_factor_ww_planned IS 'yyy_Befestigungsgrad für den Schmutz- oder Mischabwasseranschluss im Planungszustand / Befestigungsgrad für den Schmutz- oder Mischabwasseranschluss im Planungszustand / Taux d''imperméabilisation pour les raccordements eaux usées et eaux mixtes prévus';


--
-- Name: COLUMN catchment_area.sewer_infiltration_water_production_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.sewer_infiltration_water_production_current IS 'yyy_Mittlerer Fremdwasseranfall, der im Ist-Zustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird / Mittlerer Fremdwasseranfall, der im Ist-Zustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird / Débit  d''eaux claires parasites (ECP) moyen actuel, rejeté dans les canalisation d’eaux usées ou mixtes';


--
-- Name: COLUMN catchment_area.sewer_infiltration_water_production_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.sewer_infiltration_water_production_planned IS 'yyy_Mittlerer Fremdwasseranfall, der im Planungszustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird. / Mittlerer Fremdwasseranfall, der im Planungszustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird. / Débit  d''eaux claires parasites (ECP) moyen prévu, rejeté dans les canalisation d’eaux usées ou mixtes';


--
-- Name: COLUMN catchment_area.surface_area; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.surface_area IS 'yyy_redundantes Attribut Flaeche, welches die aus dem Perimeter errechnete Flaeche [ha] enthält / Redundantes Attribut Flaeche, welches die aus dem Perimeter errechnete Flaeche [ha] enthält / Attribut redondant indiquant la surface calculée à partir du périmètre en ha';


--
-- Name: COLUMN catchment_area.waste_water_production_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.waste_water_production_current IS 'yyy_Mittlerer Schmutzabwasseranfall, der im Ist-Zustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird / Mittlerer Schmutzabwasseranfall, der im Ist-Zustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird / Débit moyen actuel des eaux usées rejetées dans les canalisations d’eaux usées ou d''eaux mixtes';


--
-- Name: COLUMN catchment_area.waste_water_production_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.waste_water_production_planned IS 'yyy_Mittlerer Schmutzabwasseranfall, der im Planungszustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird. / Mittlerer Schmutzabwasseranfall, der im Planungszustand in die Schmutz- oder Mischabwasserkanalisation eingeleitet wird. / Débit moyen prévu des eaux usées rejetées dans les canalisations d’eaux usées ou d''eaux mixtes.';


--
-- Name: COLUMN catchment_area.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN catchment_area.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN catchment_area.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: catchment_area_text; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.catchment_area_text (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'catchment_area_text'::text) NOT NULL,
    plantype integer,
    remark character varying(80),
    text text,
    texthali smallint,
    textori numeric(4,1),
    textpos_geometry public.geometry(Point,2056),
    textvali smallint,
    last_modification timestamp without time zone DEFAULT now(),
    fk_catchment_area character varying(16)
);


ALTER TABLE qgep_od.catchment_area_text OWNER TO postgres;

--
-- Name: COLUMN catchment_area_text.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area_text.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN catchment_area_text.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area_text.remark IS 'General remarks';


--
-- Name: COLUMN catchment_area_text.text; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area_text.text IS 'yyy_Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / valeur calculée à partir d’attributs, plusieurs lignes possible';


--
-- Name: COLUMN catchment_area_text.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.catchment_area_text.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: channel; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.channel (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'channel'::text) NOT NULL,
    bedding_encasement integer,
    connection_type integer,
    function_hierarchic integer,
    function_hydraulic integer,
    jetting_interval numeric(4,2),
    pipe_length numeric(7,2),
    usage_current integer,
    usage_planned integer
);


ALTER TABLE qgep_od.channel OWNER TO postgres;

--
-- Name: COLUMN channel.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN channel.bedding_encasement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.bedding_encasement IS 'yyy_Art und Weise der unmittelbaren Rohrumgebung im Boden: Bettungsschicht (Unterlage der Leitung),  Verdämmung (seitliche Auffüllung), Schutzschicht / Art und Weise der unmittelbaren Rohrumgebung im Boden: Bettungsschicht (Unterlage der Leitung),  Verdämmung (seitliche Auffüllung), Schutzschicht / Lit de pose (assise de la conduite), bourrage latéral (remblai latéral), couche de protection';


--
-- Name: COLUMN channel.connection_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.connection_type IS 'Types of connection / Verbindungstypen / Types de raccordement';


--
-- Name: COLUMN channel.function_hierarchic; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.function_hierarchic IS 'yyy_Art des Kanals hinsichtlich Bedeutung im Entwässerungssystem / Art des Kanals hinsichtlich Bedeutung im Entwässerungssystem / Genre de canalisation par rapport à sa fonction dans le système d''évacuation';


--
-- Name: COLUMN channel.function_hydraulic; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.function_hydraulic IS 'yyy_Art des Kanals hinsichtlich hydraulischer Ausführung / Art des Kanals hinsichtlich hydraulischer Ausführung / Genre de canalisation par rapport à sa fonction hydraulique';


--
-- Name: COLUMN channel.jetting_interval; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.jetting_interval IS 'yyy_Abstände in welchen der Kanal gespült werden sollte / Abstände in welchen der Kanal gespült werden sollte / Fréquence à laquelle une canalisation devrait subir un curage (années)';


--
-- Name: COLUMN channel.pipe_length; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.pipe_length IS 'yyy_Baulänge der Einzelrohre oder Fugenabstände bei Ortsbetonkanälen / Baulänge der Einzelrohre oder Fugenabstände bei Ortsbetonkanälen / Longueur de chaque tuyau ou distance des joints pour les canalisations en béton coulé sur place';


--
-- Name: COLUMN channel.usage_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.usage_current IS 'yyy_Für Primäre Abwasseranlagen gilt: heute zulässige Nutzung. Für Sekundäre Abwasseranlagen gilt: heute tatsächliche Nutzung / Für primäre Abwasseranlagen gilt: Heute zulässige Nutzung. Für sekundäre Abwasseranlagen gilt: Heute tatsächliche Nutzung / Pour les ouvrages du réseau primaire: utilisation actuelle autorisée pour les ouvrages du réseau secondaire: utilisation actuelle réelle';


--
-- Name: COLUMN channel.usage_planned; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.channel.usage_planned IS 'yyy_Durch das Konzept vorgesehene Nutzung (vergleiche auch Nutzungsart_Ist) / Durch das Konzept vorgesehene Nutzung (vergleiche auch Nutzungsart_Ist) / Utilisation prévue par le concept d''assainissement (voir aussi GENRE_UTILISATION_ACTUELLE)';


--
-- Name: chute; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.chute (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'chute'::text) NOT NULL,
    kind integer,
    material integer,
    vertical_drop numeric(7,2)
);


ALTER TABLE qgep_od.chute OWNER TO postgres;

--
-- Name: COLUMN chute.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.chute.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN chute.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.chute.kind IS 'Type of chute / Art des Absturzes / Type de seuil';


--
-- Name: COLUMN chute.material; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.chute.material IS 'Construction material of chute / Material aus welchem der Absturz besteht / Matériau de construction du seuil';


--
-- Name: COLUMN chute.vertical_drop; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.chute.vertical_drop IS 'Vertical difference of water level before and after chute / Differenz des Wasserspiegels vor und nach dem Absturz / Différence de la hauteur du plan d''eau avant et après la chute';


--
-- Name: connection_object; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.connection_object (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'connection_object'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    sewer_infiltration_water_production numeric(9,3),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_networkelement character varying(16),
    fk_owner character varying(16),
    fk_operator character varying(16)
);


ALTER TABLE qgep_od.connection_object OWNER TO postgres;

--
-- Name: COLUMN connection_object.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.connection_object.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN connection_object.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.connection_object.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN connection_object.sewer_infiltration_water_production; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.connection_object.sewer_infiltration_water_production IS 'yyy_Durchschnittlicher Fremdwasseranfall für Fremdwasserquellen wie Laufbrunnen oder Reservoirüberlauf / Durchschnittlicher Fremdwasseranfall für Fremdwasserquellen wie Laufbrunnen oder Reservoirüberlauf / Apport moyen d''eaux claires parasites (ECP) par des sources d''ECP, telles que fontaines ou trops-plein de réservoirs';


--
-- Name: COLUMN connection_object.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.connection_object.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN connection_object.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.connection_object.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN connection_object.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.connection_object.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: control_center; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.control_center (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'control_center'::text) NOT NULL,
    identifier character varying(20),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.control_center OWNER TO postgres;

--
-- Name: COLUMN control_center.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.control_center.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN control_center.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.control_center.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: COLUMN control_center.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.control_center.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN control_center.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.control_center.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN control_center.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.control_center.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: cooperative; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.cooperative (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'cooperative'::text) NOT NULL
);


ALTER TABLE qgep_od.cooperative OWNER TO postgres;

--
-- Name: COLUMN cooperative.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cooperative.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: cover; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.cover (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'cover'::text) NOT NULL,
    brand character varying(50),
    cover_shape integer,
    diameter smallint,
    fastening integer,
    level numeric(7,3),
    material integer,
    positional_accuracy integer,
    situation_geometry public.geometry(Point,2056),
    sludge_bucket integer,
    venting integer
);


ALTER TABLE qgep_od.cover OWNER TO postgres;

--
-- Name: COLUMN cover.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN cover.brand; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.brand IS 'Name of manufacturer / Name der Herstellerfirma / Nom de l''entreprise de fabrication';


--
-- Name: COLUMN cover.cover_shape; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.cover_shape IS 'shape of cover / Form des Deckels / Forme du couvercle';


--
-- Name: COLUMN cover.diameter; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.diameter IS 'yyy_Abmessung des Deckels (bei eckigen Deckeln minimale Abmessung) / Abmessung des Deckels (bei eckigen Deckeln minimale Abmessung) / Dimension du couvercle (dimension minimale pour couvercle anguleux)';


--
-- Name: COLUMN cover.fastening; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.fastening IS 'yyy_Befestigungsart des Deckels / Befestigungsart des Deckels / Genre de fixation du couvercle';


--
-- Name: COLUMN cover.level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.level IS 'Height of cover / Deckelhöhe / Cote du couvercle';


--
-- Name: COLUMN cover.material; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.material IS 'Material of cover / Deckelmaterial / Matériau du couvercle';


--
-- Name: COLUMN cover.positional_accuracy; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.positional_accuracy IS 'Quantfication of accuarcy of position of cover (center hole) / Quantifizierung der Genauigkeit der Lage des Deckels (Pickelloch) / Plage de précision des coordonnées planimétriques du couvercle.';


--
-- Name: COLUMN cover.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.situation_geometry IS 'Situation of cover (cover hole), National position coordinates (East, North) / Lage des Deckels (Pickelloch) / Positionnement du couvercle (milieu du couvercle)';


--
-- Name: COLUMN cover.sludge_bucket; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.sludge_bucket IS 'yyy_Angabe, ob der Deckel mit einem Schlammeimer versehen ist oder nicht / Angabe, ob der Deckel mit einem Schlammeimer versehen ist oder nicht / Indication si le couvercle est pourvu ou non d''un ramasse-boues';


--
-- Name: COLUMN cover.venting; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.cover.venting IS 'venting with wholes for aeration / Deckel mit Lüftungslöchern versehen / Couvercle pourvu de trous d''aération';


--
-- Name: dam; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.dam (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'dam'::text) NOT NULL,
    kind integer,
    vertical_drop numeric(7,2)
);


ALTER TABLE qgep_od.dam OWNER TO postgres;

--
-- Name: COLUMN dam.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.dam.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN dam.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.dam.kind IS 'Type of dam or weir / Art des Wehres / Genre d''ouvrage de retenue';


--
-- Name: COLUMN dam.vertical_drop; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.dam.vertical_drop IS 'Vertical difference of water level before and after chute / Differenz des Wasserspiegels vor und nach dem Absturz / Différence de la hauteur du plan d''eau avant et après la chute';


--
-- Name: damage; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.damage (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'damage'::text) NOT NULL,
    comments character varying(100),
    connection integer,
    damage_begin smallint,
    damage_end smallint,
    damage_reach character varying(3),
    distance numeric(7,2),
    quantification1 integer,
    quantification2 integer,
    single_damage_class integer,
    video_counter character varying(11),
    view_parameters character varying(200),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_examination character varying(16)
);


ALTER TABLE qgep_od.damage OWNER TO postgres;

--
-- Name: COLUMN damage.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.obj_id IS 'INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN damage.comments; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.comments IS 'yyy_Freie Bemerkungen zu einer Feststellung / Freie Bemerkungen zu einer Feststellung / Remarques libres concernant une observation';


--
-- Name: COLUMN damage.connection; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.connection IS 'yyy_Kennzeichen für eine Feststellung an einer Rohrverbindung (2.1.7). bzw. bei zwei aneinandergrenzenden Schachtelementen gemäss (3.1.7). Entspricht in SN EN 13508 ja = "A", nein = leer / Kennzeichen für eine Feststellung an einer Rohrverbindung (2.1.7). bzw. bei zwei aneinandergrenzenden Schachtelementen gemäss (3.1.7). Entspricht in SN EN 13508 ja = "A", nein = leer / Indication d’une observation au niveau d’un assemblage (2.1.7) ou Observation entre deux éléments de regard de visite adjacents (3.1.7). Correspond dans la SN EN 13508 à oui = « A », non = vide';


--
-- Name: COLUMN damage.damage_begin; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.damage_begin IS 'yyy_Lage am Umfang: Beginn des Schadens. Werte und Vorgehen sind unter Absatz 2.1.6 bzw. 3.1.6 genau beschrieben. / Lage am Umfang: Beginn des Schadens. Werte und Vorgehen sind unter Absatz 2.1.6 bzw. 3.1.6 genau beschrieben. / Emplacement circonférentiel: Début du dommage. Valeurs et procédure sont décrites en détail dans le paragraphe 2.1.6 resp. 3.1.6.';


--
-- Name: COLUMN damage.damage_end; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.damage_end IS 'yyy_Lage am Umfang: Ende des Schadens. Werte und Vorgehen sind unter Absatz 2.1.6 bzw. 3.1.6 genau beschrieben. / Lage am Umfang: Ende des Schadens. Werte und Vorgehen sind unter Absatz 2.1.6 bzw. 3.1.6 genau beschrieben. / Emplacement circonférentiel: Fin du dommage. Valeurs et procédure sont décrites en détail dans le paragraphe 2.1.6. resp. 3.1.6.';


--
-- Name: COLUMN damage.damage_reach; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.damage_reach IS 'yyy_Codes für den Anfang und das Ende eines Streckenschadens. Genaue Angaben unter 2.1.2 resp. 3.1.2 / Codes für den Anfang und das Ende eines Streckenschadens. Genaue Angaben unter 2.1.2 resp. 3.1.2';


--
-- Name: COLUMN damage.distance; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.distance IS 'yyy_Länge von Rohranfang bis zur Feststellung bzw. Länge ab Oberkante Deckel (siehe Richtlinie Absatz 2.1.1 bzw. 3.1.1.) in m mit zwei Nachkommastellen / Länge von Rohranfang bis zur Feststellung bzw. Länge ab Oberkante Deckel (siehe Richtlinie Absatz 2.1.1 bzw. 3.1.1.) in m mit zwei Nachkommastellen / Longueur entre le début de la canalisation resp. longueur entre le bord supérieur du couvercle et l’observation (cf. paragraphe 2.1.1 resp. 3.1.1.) en m avec deux chiffres après la virgule.';


--
-- Name: COLUMN damage.quantification1; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.quantification1 IS 'yyy_Quantifizierung 1 gemäss SN EN 13508-2. Zulässige Eingaben sind in Kapitel 2.3 - 2.6 beschrieben / Quantifizierung 1 gemäss SN EN 13508-2. Zulässige Eingaben sind in Kapitel 2.3 - 2.6 bzw.  3.1.5 beschrieben / Quantification 1 selon la SN EN 13508-2. Les entrées autorisées sont décrites dans les chapitres 2.3 - 2.6 reps. 3.1.5';


--
-- Name: COLUMN damage.quantification2; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.quantification2 IS 'yyy_Quantifizierung 2 gemäss SN EN 13508-2. Zulässige Eingaben sind in Kapitel 2.3 - 2.6 bzw. 3.1.5 beschrieben / Quantifizierung 2 gemäss SN EN 13508-2. Zulässige Eingaben sind in Kapitel 2.3 - 2.6 bzw. 3.1.5 beschrieben / Quantification 2 selon la SN EN 13508. Les entrées autorisées sont décrites dans le chapitre 2.3 - 2.6. resp. 3.1.5.';


--
-- Name: COLUMN damage.single_damage_class; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.single_damage_class IS 'yyy_Definiert die Schadensklasse eines Einzelschadens. Die Einteilung in die Zustandsklassen erfolgt aufgrund des Schadenbilds und des Schadensausmasses. Dabei kann ein Abwasserbauwerk direkt einer Klasse zugeteilt werden oder zuerst jeder Schaden einzeln klassifiziert werden. (Am Schluss bestimmt dann z.B. der schwerste Einzelschaden die Klassifizierung des gesamten Kanals (Abwasserbauwerk.BaulicherZustand)). / Definiert die Schadensklasse eines Einzelschadens. Die Einteilung in die Zustandsklassen erfolgt aufgrund des Schadenbilds und des Schadensausmasses. Dabei kann ein Abwasserbauwerk direkt einer Klasse zugeteilt werden oder zuerst jeder Schaden einzeln klassifiziert werden. (Am Schluss bestimmt dann z.B. der schwerste Einzelschaden die Klassifizierung des gesamten Kanals (Abwasserbauwerk.BaulicherZustand)). / Définit la classe de dommages d’un dommage unique. La répartition en classes d’état s’effectue sur la base de la nature et de l’étendue des dommages. Un ouvrage d''assainissement peut être classé directement ou chaque dommage peut d’abord être classé séparément. (A la fin, le dommage le plus important détermine le classement de l’ensemble de la canalisation (OUVRAGE_RESEAU_AS.ETAT_CONSTRUCTIF).';


--
-- Name: COLUMN damage.video_counter; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.video_counter IS 'yyy_Zählerstand auf einem analogen Videoband oder in einer digitalen Videodatei, in Echtzeit / Zählerstand auf einem analogen Videoband oder in einer digitalen Videodatei, in Echtzeit';


--
-- Name: COLUMN damage.view_parameters; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.view_parameters IS 'yyy_Spezielle Ansichtsparameter für die Positionierung innerhalb einer Filmdatei für Scanner- oder digitale Videotechnik / Spezielle Ansichtsparameter für die Positionierung innerhalb einer Filmdatei für Scanner- oder digitale Videotechnik / Paramètres de projection spéciaux pour le positionnement à l’intérieur d’un fichier de film pour la technique vidéo scanner ou numérique.';


--
-- Name: COLUMN damage.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: damage_channel; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.damage_channel (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'damage_channel'::text) NOT NULL,
    channel_damage_code integer
);


ALTER TABLE qgep_od.damage_channel OWNER TO postgres;

--
-- Name: COLUMN damage_channel.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage_channel.obj_id IS 'INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN damage_channel.channel_damage_code; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage_channel.channel_damage_code IS 'yyy_Vorgegebener Wertebereich: Gültiger Code auf der Grundlage von SN EN 13508-2. Alle gültigen Codes sind in Kapitel 2 der Richtlinie "Schadencodierung" abschliessend aufgeführt. / Vorgegebener Wertebereich: Gültiger Code auf der Grundlage von SN EN 13508-2. Alle gültigen Codes sind in Kapitel 2 der Richtlinie "Schadencodierung" abschliessend aufgeführt. / Domaine de valeur prédéfini: Code valide sur la base de la SN EN 13508-2. Tous les codes valides sont mentionnés dans le chapitre 2 de la directive.';


--
-- Name: damage_manhole; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.damage_manhole (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'damage_manhole'::text) NOT NULL,
    manhole_damage_code integer,
    manhole_shaft_area integer
);


ALTER TABLE qgep_od.damage_manhole OWNER TO postgres;

--
-- Name: COLUMN damage_manhole.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage_manhole.obj_id IS 'INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN damage_manhole.manhole_damage_code; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage_manhole.manhole_damage_code IS 'yyy_Vorgegebener Wertebereich: Gültiger Code auf der Grundlage von SN EN 13508-2. Alle gültigen Codes sind in Kapitel 3 der Richtlinie "Schadencodierung" abschliessend aufgeführt. / Vorgegebener Wertebereich: Gültiger Code auf der Grundlage von SN EN 13508-2. Alle gültigen Codes sind in Kapitel 3 der Richtlinie "Schadencodierung" abschliessend aufgeführt. / Domaine de valeur prédéfini: Code valide sur la base de la SN EN 13508-2. Tous les codes valides sont mentionnés dans le chapitre 3 de la directive.';


--
-- Name: COLUMN damage_manhole.manhole_shaft_area; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.damage_manhole.manhole_shaft_area IS 'yyy_Bereich in dem eine Feststellung auftritt. Die Werte sind unter 3.1.9 abschliessend beschrieben. / Bereich in dem eine Feststellung auftritt. Die Werte sind unter 3.1.9 abschliessend beschrieben. / Domaine où une observation est faite. Les valeurs sont décrites dans 3.1.9.';


--
-- Name: data_media; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.data_media (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'data_media'::text) NOT NULL,
    identifier character varying(40),
    kind integer,
    location character varying(50),
    path character varying(100),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.data_media OWNER TO postgres;

--
-- Name: COLUMN data_media.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.data_media.obj_id IS 'INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN data_media.identifier; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.data_media.identifier IS 'yyy_Name des Datenträgers. Bei elektronischen Datenträgern normalerweise das Volume-Label. Bei einem Server der Servername. Bei analogen Videobändern die Bandnummer. / Name des Datenträgers. Bei elektronischen Datenträgern normalerweise das Volume-Label. Bei einem Server der Servername. Bei analogen Videobändern die Bandnummer. / Nom du support de données. Pour les supports de données électroniques, normalement le label volume. Pour un serveur, le nom du serveur. Pour des bandes vidéo analogiques, les numéros de bandes.';


--
-- Name: COLUMN data_media.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.data_media.kind IS 'yyy_Beschreibt die Art des Datenträgers / Beschreibt die Art des Datenträgers / Décrit le genre de support de données';


--
-- Name: COLUMN data_media.location; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.data_media.location IS 'Where is the / Wo befindet sich der Datenträger / Où se trouve le support de données';


--
-- Name: COLUMN data_media.path; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.data_media.path IS 'yyy_Zugriffspfad zum Datenträger. z.B. DVD-Laufwerk -> D: , Server -> \\server\videos, Harddisk -> c:\videos . Kann auch eine URL sein. Bei einem analogen Videoband leer / Zugriffspfad zum Datenträger. z.B. DVD-Laufwerk -> D: , Server -> \\server\videos, Harddisk -> c:\videos . Kann auch eine URL sein. Bei einem analogen Videoband leer / Chemin d’accès au support de données, p. ex. lecteur DVD -> D: , - serveur -> \\ server\videos , disque dur -> c:\videos , Peut aussi être une URL. Pour une bande vidéo analogique: vide';


--
-- Name: COLUMN data_media.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.data_media.remark IS 'General remarks / Bemerkungen zum Datenträger / Remarques concernant le support de données';


--
-- Name: COLUMN data_media.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.data_media.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: discharge_point; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.discharge_point (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'discharge_point'::text) NOT NULL,
    highwater_level numeric(7,3),
    relevance integer,
    terrain_level numeric(7,3),
    upper_elevation numeric(7,3),
    waterlevel_hydraulic numeric(7,3),
    fk_sector_water_body character varying(16)
);


ALTER TABLE qgep_od.discharge_point OWNER TO postgres;

--
-- Name: COLUMN discharge_point.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.discharge_point.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN discharge_point.highwater_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.discharge_point.highwater_level IS 'yyy_Massgebliche Hochwasserkote der Einleitstelle. Diese ist in der Regel grösser als der Wasserspiegel_Hydraulik. / Massgebliche Hochwasserkote der Einleitstelle. Diese ist in der Regel grösser als der Wasserspiegel_Hydraulik. / Cote de crue déterminante au point de rejet. Diese ist in der Regel grösser als der Wasserspiegel_Hydraulik.';


--
-- Name: COLUMN discharge_point.relevance; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.discharge_point.relevance IS 'Relevance of discharge point for water course / Gewässerrelevanz der Einleitstelle / Il est conseillé d’utiliser des noms réels, tels qSignifiance pour milieu récepteur';


--
-- Name: COLUMN discharge_point.terrain_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.discharge_point.terrain_level IS 'Terrain level if there is no cover at the discharge point (structure), e.g. just pipe ending / Terrainkote, falls kein Deckel vorhanden bei Einleitstelle (Kanalende ohne Bauwerk oder Bauwerk ohne Deckel) / Cote terrain s''il n''y a pas de couvercle à l''exutoire par example seulement fin du conduite';


--
-- Name: COLUMN discharge_point.upper_elevation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.discharge_point.upper_elevation IS 'Highest point of structure (ceiling), outside / Höchster Punkt des Bauwerks (Decke), aussen / Point le plus élevé de l''ouvrage';


--
-- Name: COLUMN discharge_point.waterlevel_hydraulic; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.discharge_point.waterlevel_hydraulic IS 'yyy_Wasserspiegelkote für die hydraulische Berechnung (IST-Zustand). Berechneter Wasserspiegel bei der Einleitstelle. Wo nichts anders gefordert, ist der Wasserspiegel bei einem HQ30 einzusetzen. / Wasserspiegelkote für die hydraulische Berechnung (IST-Zustand). Berechneter Wasserspiegel bei der Einleitstelle. Wo nichts anders gefordert, ist der Wasserspiegel bei einem HQ30 einzusetzen. / Niveau d’eau calculé à l’exutoire. Si aucun exigence est demandée, indiquer le niveau d’eau pour un HQ30.';


--
-- Name: drainage_system; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.drainage_system (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'drainage_system'::text) NOT NULL,
    kind integer,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.drainage_system OWNER TO postgres;

--
-- Name: COLUMN drainage_system.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.drainage_system.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN drainage_system.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.drainage_system.kind IS 'yyy_Art des Entwässerungssystems in dem ein bestimmtes Gebiet entwässert werden soll (SOLL Zustand) / Art des Entwässerungssystems in dem ein bestimmtes Gebiet entwässert werden soll (SOLL Zustand) / Genre de système d''évacuation choisi pour une région déterminée (Etat prévu)';


--
-- Name: COLUMN drainage_system.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.drainage_system.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: dryweather_downspout; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.dryweather_downspout (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'dryweather_downspout'::text) NOT NULL,
    diameter smallint
);


ALTER TABLE qgep_od.dryweather_downspout OWNER TO postgres;

--
-- Name: COLUMN dryweather_downspout.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.dryweather_downspout.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN dryweather_downspout.diameter; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.dryweather_downspout.diameter IS 'yyy_Abmessung des Deckels (bei eckigen Deckeln minimale Abmessung) / Abmessung des Deckels (bei eckigen Deckeln minimale Abmessung) / Dimension du couvercle (dimension minimale pour couvercle anguleux)';


--
-- Name: dryweather_flume; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.dryweather_flume (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'dryweather_flume'::text) NOT NULL,
    material integer
);


ALTER TABLE qgep_od.dryweather_flume OWNER TO postgres;

--
-- Name: COLUMN dryweather_flume.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.dryweather_flume.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN dryweather_flume.material; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.dryweather_flume.material IS 'yyy_Material der Ausbildung oder Auskleidung der Trockenwetterrinne / Material der Ausbildung oder Auskleidung der Trockenwetterrinne / Matériau de fabrication ou de revêtement de la cunette de débit temps sec';


--
-- Name: electric_equipment; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.electric_equipment (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'electric_equipment'::text) NOT NULL,
    gross_costs numeric(10,2),
    kind integer,
    year_of_replacement smallint
);


ALTER TABLE qgep_od.electric_equipment OWNER TO postgres;

--
-- Name: COLUMN electric_equipment.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electric_equipment.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN electric_equipment.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electric_equipment.gross_costs IS 'Gross costs of electromechanical equipment / Brutto Erstellungskosten der elektromechanischen Ausrüstung / Coûts bruts des équipements électromécaniques';


--
-- Name: COLUMN electric_equipment.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electric_equipment.kind IS 'yyy_Elektrische Installationen und Geräte / Elektrische Installationen und Geräte / Installations et appareils électriques';


--
-- Name: COLUMN electric_equipment.year_of_replacement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electric_equipment.year_of_replacement IS 'yyy_Jahr, in dem die Lebensdauer der elektrischen Einrichtung voraussichtlich ausläuft / Jahr, in dem die Lebensdauer der elektrischen Einrichtung voraussichtlich ausläuft / Année pour laquelle on prévoit que la durée de vie de l''équipement soit écoulée';


--
-- Name: electromechanical_equipment; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.electromechanical_equipment (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'electromechanical_equipment'::text) NOT NULL,
    gross_costs numeric(10,2),
    kind integer,
    year_of_replacement smallint
);


ALTER TABLE qgep_od.electromechanical_equipment OWNER TO postgres;

--
-- Name: COLUMN electromechanical_equipment.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electromechanical_equipment.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN electromechanical_equipment.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electromechanical_equipment.gross_costs IS 'Gross costs of electromechanical equipment / Brutto Erstellungskosten der elektromechanischen Ausrüstung / Coûts bruts des équipements électromécaniques';


--
-- Name: COLUMN electromechanical_equipment.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electromechanical_equipment.kind IS 'yyy_Elektromechanische Teile eines Bauwerks / Elektromechanische Teile eines Bauwerks / Eléments électromécaniques d''un ouvrage';


--
-- Name: COLUMN electromechanical_equipment.year_of_replacement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.electromechanical_equipment.year_of_replacement IS 'yyy_Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Année pour laquelle on prévoit que la durée de vie de l''équipement soit écoulée';


--
-- Name: examination; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.examination (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'examination'::text) NOT NULL,
    equipment character varying(50),
    from_point_identifier character varying(41),
    inspected_length numeric(7,2),
    recording_type integer,
    to_point_identifier character varying(41),
    vehicle character varying(50),
    videonumber character varying(41),
    weather integer,
    fk_reach_point character varying(16)
);


ALTER TABLE qgep_od.examination OWNER TO postgres;

--
-- Name: COLUMN examination.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.obj_id IS 'INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN examination.equipment; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.equipment IS 'Name of used camera / Eingesetztes Aufnahmegeräte (Kamera) / Appareil de prise de vues (caméra) employé';


--
-- Name: COLUMN examination.from_point_identifier; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.from_point_identifier IS 'yyy_Bezeichnung des "von Punktes" einer Untersuchung, so wie sie auf dem Plan erscheint. Alternative zum Foreign key Haltungspunkt, wenn Topologie noch nicht definiert ist (Ersterfassung). Die vonPunktBezeichnung wird später vom Hydrauliker für den Aufbau der Kanalnetztopologie verwendet. Bei Schachtuntersuchungen bleibt dieser Wert leer. / Bezeichnung des "von Punktes" einer Untersuchung, so wie sie auf dem Plan erscheint. Alternative zum Fremdschlüssel Haltungspunkt, wenn Topologie noch nicht definiert ist (Ersterfassung). Die vonPunktBezeichnung wird später vom Hydrauliker für den Aufbau der Kanalnetztopologie verwendet. Bei Schachtuntersuchungen bleibt dieser Wert leer. / point (chambre ou nœud) auquel l’inspection termine. Désignation du « point départ » d’une inspection comme elle figure sur le plan. Elle sert d’alternative à la clé externe POINT_TRONCON, lorsque la topologie n’est pas encore définie (saisie initiale). La DESIGNATION_POINT_DE sera utilisée ultérieurement par l’hydraulicien pour la construction de la topologie du réseau. Cette valeur reste vide lors d’inspections de chambres.';


--
-- Name: COLUMN examination.inspected_length; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.inspected_length IS 'yyy_Total untersuchte Länge in Metern mit zwei Nachkommastellen / Total untersuchte Länge in Metern mit zwei Nachkommastellen / Longueur totale examinée en mètres avec deux chiffres après la virgule';


--
-- Name: COLUMN examination.recording_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.recording_type IS 'yyy_Aufnahmetechnik, beschreibt die Art der Aufnahme / Aufnahmetechnik, beschreibt die Art der Aufnahme / Technique de prise de vues, décrit le type de prise de vues';


--
-- Name: COLUMN examination.to_point_identifier; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.to_point_identifier IS 'yyy_Bezeichnung des "bis Punktes" einer Untersuchung, so wie sie auf dem Plan erscheint. Alternative zum Foreign key Abwasserbauwerk, wenn Topologie noch nicht definiert ist (Ersterfassung). Die vonPunktBezeichnung wird später vom Hydrauliker für den Aufbau der Kanalnetztopologie verwendet. / Bezeichnung des "bis Punktes" einer Untersuchung, so wie sie auf dem Plan erscheint. Alternative zum Fremdschlüssel Abwasserbauwerk, wenn Topologie noch nicht definiert ist (Ersterfassung). Die vonPunktBezeichnung wird später vom Hydrauliker für den Aufbau der Kanalnetztopologie verwendet. / point (chambre ou noeud) d’où l’inspection commence. Désignation du « point d’arrivée » d’une inspection comme elle figure sur le plan. Elle sert d’alternative à la clé externe OUVRAGE_RESEAU_AS lorsque la topologie n’est pas encore définie (saisie initiale). La DESIGNATION_POINT_DE sera utilisée ultérieurement par l’hydraulicien pour la construction de la topologie du réseau.';


--
-- Name: COLUMN examination.vehicle; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.vehicle IS 'yyy_Eingesetztes Inspektionsfahrzeug / Eingesetztes Inspektionsfahrzeug / Véhicule d’inspection employé';


--
-- Name: COLUMN examination.videonumber; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.videonumber IS 'yyy_Bei Videobändern steht hier die Bandnummer (z.B. 1/99). Bei elektronischen Datenträgern ist dies die Datenträgerbezeichnung (z.B. SG001). Falls pro Untersuchung eine einzelne Datei zur Verfügung steht, dann wird diese aus der Klasse Datei referenziert und dieses Attribut kann leer gelassen werden. / Bei Videobändern steht hier die Bandnummer (z.B. 1/99). Bei elektronischen Datenträgern ist dies die Datenträgerbezeichnung (z.B. SG001). Falls pro Untersuchung eine einzelne Datei zur Verfügung steht, dann wird diese aus der Klasse Datei referenziert und dieses Attribut kann leer gelassen werden. / Pour les bandes vidéo figure ici le numéro de la bande (p. ex. 1/99) et, pour les supports de don-nées électroniques, sa désignation (p. ex. SG001). S’il n’existe qu’un fichier par examen, ce fichier est référencé par la classe Fichier et cet attribut peut être laissé vide';


--
-- Name: COLUMN examination.weather; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.examination.weather IS 'Wheather conditions during inspection / Wetterverhältnisse während der Inspektion / Conditions météorologiques pendant l’inspection';


--
-- Name: file; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.file (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'file'::text) NOT NULL,
    class integer,
    identifier character varying(60),
    kind integer,
    object character varying(41),
    path_relative character varying(200),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.file OWNER TO postgres;

--
-- Name: COLUMN file.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.obj_id IS 'INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN file.class; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.class IS 'yyy_Gibt an, zu welcher Klasse des VSA-DSS-Datenmodells die Datei gehört. Grundsätzlich alle Klassen möglich. Im Rahmen der Kanalfernsehaufnahmen hauptsächlich Kanal, Normschachtschaden, Kanalschaden und Untersuchung. / Gibt an, zu welcher Klasse des VSA-DSS-Datenmodells die Datei gehört. Grundsätzlich alle Klassen möglich. Im Rahmen der Kanalfernsehaufnahmen hauptsächlich Kanal, Normschachtschaden, Kanalschaden und Untersuchung. / Indique à quelle classe du modèle de données de VSA-SDEE appartient le fichier. Toutes les classes sont possible. Surtout CANALISATION, DOMMAGE_CHAMBRE_STANDARD, DOMMAGE_CANALISATION, INSPECTION.';


--
-- Name: COLUMN file.identifier; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.identifier IS 'yyy_Name der Datei mit Dateiendung. Z.B video_01.mpg oder haltung_01.ipf / Name der Datei mit Dateiendung. Z.B video_01.mpg oder haltung_01.ipf / Nom du fichier avec terminaison du fichier. P. ex. video_01.mpg ou canalisation_01.ipf';


--
-- Name: COLUMN file.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.kind IS 'yyy_Beschreibt die Art der Datei. Für analoge Videos auf Bändern ist der Typ "Video" einzusetzen. Die Bezeichnung wird dann gleich gesetzt wie die Bezeichnung des Videobandes. / Beschreibt die Art der Datei. Für analoge Videos auf Bändern ist der Typ "Video" einzusetzen. Die Bezeichnung wird dann gleich gesetzt wie die Bezeichnung des Videobandes. / Décrit le type de fichier. Pour les vidéos analo-giques sur bandes, le type « vidéo » doit être entré. La désignation sera ensuite la même que celle de la bande vidéo.';


--
-- Name: COLUMN file.object; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.object IS 'yyy_Objekt-ID (OBJ_ID) des Datensatzes zu dem die Datei gehört / Objekt-ID (OBJ_ID) des Datensatzes zu dem die Datei gehört / Identification de l’ensemble de données auquel le fichier appartient (OBJ_ID)';


--
-- Name: COLUMN file.path_relative; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.path_relative IS 'yyy_Zusätzlicher Relativer Pfad, wo die Datei auf dem Datenträger zu finden ist. Z.B. DVD_01. / Zusätzlicher Relativer Pfad, wo die Datei auf dem Datenträger zu finden ist. Z.B. DVD_01. / Accès relatif supplémentaire à l’emplacement du fichier sur le support de données. P. ex. DVD_01';


--
-- Name: COLUMN file.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN file.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.file.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: fish_pass; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.fish_pass (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'fish_pass'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    vertical_drop numeric(7,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_water_control_structure character varying(16)
);


ALTER TABLE qgep_od.fish_pass OWNER TO postgres;

--
-- Name: COLUMN fish_pass.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fish_pass.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN fish_pass.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fish_pass.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN fish_pass.vertical_drop; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fish_pass.vertical_drop IS 'Vertical difference of water level before and after fishpass / Differenz des Wasserspiegels vor und nach dem Fischpass / Différence de la hauteur du plan d''eau avant et après l''échelle à poisson';


--
-- Name: COLUMN fish_pass.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fish_pass.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN fish_pass.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fish_pass.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN fish_pass.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fish_pass.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: ford; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.ford (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'ford'::text) NOT NULL
);


ALTER TABLE qgep_od.ford OWNER TO postgres;

--
-- Name: COLUMN ford.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.ford.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: fountain; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.fountain (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'fountain'::text) NOT NULL,
    location_name character varying(50),
    situation_geometry public.geometry(Point,2056)
);


ALTER TABLE qgep_od.fountain OWNER TO postgres;

--
-- Name: COLUMN fountain.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fountain.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN fountain.location_name; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fountain.location_name IS 'Street name or name of the location / Strassenname oder Ortsbezeichnung / Nom de la route ou du lieu';


--
-- Name: COLUMN fountain.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.fountain.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: ground_water_protection_perimeter; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.ground_water_protection_perimeter (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'ground_water_protection_perimeter'::text) NOT NULL,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.ground_water_protection_perimeter OWNER TO postgres;

--
-- Name: COLUMN ground_water_protection_perimeter.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.ground_water_protection_perimeter.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN ground_water_protection_perimeter.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.ground_water_protection_perimeter.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: groundwater_protection_zone; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.groundwater_protection_zone (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'groundwater_protection_zone'::text) NOT NULL,
    kind integer,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.groundwater_protection_zone OWNER TO postgres;

--
-- Name: COLUMN groundwater_protection_zone.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.groundwater_protection_zone.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN groundwater_protection_zone.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.groundwater_protection_zone.kind IS 'yyy_Zonenarten. Grundwasserschutzzonen bestehen aus dem Fassungsbereich (Zone S1), der Engeren Schutzzone (Zone S2) und der Weiteren Schutzzone (Zone S3). / Zonenarten. Grundwasserschutzzonen bestehen aus dem Fassungsbereich (Zone S1), der Engeren Schutzzone (Zone S2) und der Weiteren Schutzzone (Zone S3). / Genre de zones';


--
-- Name: COLUMN groundwater_protection_zone.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.groundwater_protection_zone.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: hazard_source; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.hazard_source (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'hazard_source'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_connection_object character varying(16),
    fk_owner character varying(16)
);


ALTER TABLE qgep_od.hazard_source OWNER TO postgres;

--
-- Name: COLUMN hazard_source.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hazard_source.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN hazard_source.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hazard_source.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN hazard_source.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hazard_source.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: COLUMN hazard_source.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hazard_source.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN hazard_source.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hazard_source.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN hazard_source.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hazard_source.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: hq_relation; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.hq_relation (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'hq_relation'::text) NOT NULL,
    altitude numeric(7,3),
    flow numeric(9,3),
    flow_from numeric(9,3),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_overflow_characteristic character varying(16)
);


ALTER TABLE qgep_od.hq_relation OWNER TO postgres;

--
-- Name: COLUMN hq_relation.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hq_relation.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN hq_relation.altitude; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hq_relation.altitude IS 'yyy_Zum Abfluss (Q2) korrelierender Wasserspiegel (h) / Zum Abfluss (Q2) korrelierender Wasserspiegel (h) / Niveau d''eau correspondant (h) au débit (Q2)';


--
-- Name: COLUMN hq_relation.flow; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hq_relation.flow IS 'Flow (Q2) in direction of WWTP / Abflussmenge (Q2) Richtung ARA / Débit d''eau (Q2) en direction de la STEP';


--
-- Name: COLUMN hq_relation.flow_from; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hq_relation.flow_from IS 'yyy_Zufluss (Q1) / Zufluss (Q1) / Débit d’entrée  (Q1)';


--
-- Name: COLUMN hq_relation.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hq_relation.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN hq_relation.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hq_relation.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN hq_relation.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hq_relation.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: hydr_geom_relation; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.hydr_geom_relation (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'hydr_geom_relation'::text) NOT NULL,
    water_depth numeric(7,2),
    water_surface numeric(8,2),
    wet_cross_section_area numeric(8,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_hydr_geometry character varying(16)
);


ALTER TABLE qgep_od.hydr_geom_relation OWNER TO postgres;

--
-- Name: COLUMN hydr_geom_relation.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geom_relation.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN hydr_geom_relation.water_depth; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geom_relation.water_depth IS 'yyy_Massgebende Wassertiefe / Massgebende Wassertiefe / Profondeur d''eau déterminante';


--
-- Name: COLUMN hydr_geom_relation.water_surface; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geom_relation.water_surface IS 'yyy_Freie Wasserspiegelfläche; für Speicherfunktionen massgebend / Freie Wasserspiegelfläche; für Speicherfunktionen massgebend / Surface du plan d''eau; déterminant pour les fonctions d''accumulation';


--
-- Name: COLUMN hydr_geom_relation.wet_cross_section_area; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geom_relation.wet_cross_section_area IS 'yyy_Hydraulisch wirksamer Querschnitt für Verlustberechnungen / Hydraulisch wirksamer Querschnitt für Verlustberechnungen / Section hydrauliquement active pour les calculs des pertes de charge';


--
-- Name: COLUMN hydr_geom_relation.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geom_relation.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN hydr_geom_relation.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geom_relation.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN hydr_geom_relation.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geom_relation.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: hydr_geometry; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.hydr_geometry (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'hydr_geometry'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    storage_volume numeric(9,2),
    usable_capacity_storage numeric(9,2),
    usable_capacity_treatment numeric(9,2),
    utilisable_capacity numeric(9,2),
    volume_pump_sump numeric(9,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.hydr_geometry OWNER TO postgres;

--
-- Name: COLUMN hydr_geometry.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN hydr_geometry.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN hydr_geometry.storage_volume; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.storage_volume IS 'yyy_Speicherinhalt im Becken und im Zulauf zwischen Wehrkrone und dem Wasserspiegel bei Qan. Bei Regenbeckenüberlaufbecken im Nebenschluss ist der Stauraum beim vorgelagerten Trennbauwerk bzw. Regenüberlauf zu erfassen (vgl. Erläuterungen Inhalt_Fangteil reps. _Klaerteil). Bei Pumpen: Speicherinhalt im Zulaufkanal unter dem Wasserspiegel beim Einschalten der Pumpe (höchstes Einschaltniveau bei mehreren Pumpen) / Speicherinhalt im Becken und im Zulauf zwischen Wehrkrone und dem Wasserspiegel bei Qan. Bei Regenbeckenüberlaufbecken im Nebenschluss ist der Stauraum beim vorgelagerten Trennbauwerk bzw. Regenüberlauf zu erfassen (vgl. Erläuterungen Inhalt_Fangteil reps. _Klaerteil). Bei Pumpen: Speicherinhalt im Zulaufkanal unter dem Wasserspiegel beim Einschalten der Pumpe (höchstes Einschaltniveau bei mehreren Pumpen) / Volume de stockage dans un bassin et dans la canalisation d’amenée entre la crête et le niveau d’eau de Qdim (débit conservé). Lors de bassins d’eaux pluviales en connexion latérale, le volume de stockage est à saisir à l’ouvrage de répartition, resp. déversoir d’orage précédant (cf. explications volume utile clarification, resp. volume utile stockage). Pour les pompes, il s’agit du volume de stockage dans la canalisation d’amenée sous le niveau d’eau lorsque la pompe s’enclenche (niveau max d’enclenchement lorsqu’il y a plusieurs pompes). Pour les bassins d’eaux pluviales, à saisir uniquement en connexion directe.';


--
-- Name: COLUMN hydr_geometry.usable_capacity_storage; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.usable_capacity_storage IS 'yyy_Inhalt der Kammer unterhalb der Wehrkrone ohne Stauraum im Zulaufkanal. Letzterer wird unter dem Attribut Stauraum erfasst (bei Anordnung im Hauptschluss auf der Stammkarte des Hauptbauwerkes, bei Anordnung im Nebenschluss auf der Stammkarte des vorgelagerten Trennbauwerkes oder Regenüberlaufs). / Inhalt der Kammer unterhalb der Wehrkrone ohne Stauraum im Zulaufkanal. Letzterer wird unter dem Attribut Stauraum erfasst (bei Anordnung im Hauptschluss auf der Stammkarte des Hauptbauwerkes, bei Anordnung im Nebenschluss auf der Stammkarte des vorgelagerten Trennbauwerkes oder Regenüberlaufs) / Volume de la chambre sous la crête, sans volume de stockage de la canalisation d’amenée. Ce dernier est saisi par l’attribut volume de stockage (lors de disposition en connexion directe ceci se fait dans la fiche technique de l’ouvrage principal, lors de connexion latérale, l’attribution se fait dans la fiche technique de l’ouvrage de répartition ou déversoir d’orage précédant).';


--
-- Name: COLUMN hydr_geometry.usable_capacity_treatment; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.usable_capacity_treatment IS 'yyy_Inhalt der Kammer unterhalb der Wehrkrone inkl. Einlaufbereich, Auslaufbereich und Sedimentationsbereich, ohne Stauraum im Zulaufkanal.  Letzterer wird unter dem Attribut Stauraum erfasst (bei Anordnung im Hauptschluss auf der Stammkarte des Hauptbauwerkes, bei Anordnung im Nebenschluss auf der Stammkarte des vorgelagerten Trennbauwerkes oder Regenüberlaufs) / Inhalt der Kammer unterhalb der Wehrkrone inkl. Einlaufbereich, Auslaufbereich und Sedimentationsbereich, ohne Stauraum im Zulaufkanal. Letzterer wird unter dem Attribut Stauraum erfasst (bei Anordnung im Hauptschluss auf der Stammkarte des Hauptbauwerkes, bei Anordnung im Nebenschluss auf der Stammkarte des vorgelagerten Trennbauwerkes oder Regenüberlaufs) / Volume de la chambre sous la crête, incl. l’entrée, la sortie et la partie de sédimentation, sans volume de stockage de la canalisation d’amenée. Ce dernier est saisi par l’attribut volume de stockage (lors de disposition en connexion directe ceci se fait dans la fiche technique de l’ouvrage principal, lors de connexion latérale, l’attribution se fait dans la fiche technique de l’ouvrage de répartition ou déversoir d’orage précédant).';


--
-- Name: COLUMN hydr_geometry.utilisable_capacity; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.utilisable_capacity IS 'yyy_Inhalt der Kammer unterhalb Notüberlauf oder Bypass (maximal mobilisierbares Volumen, inkl. Stauraum im Zulaufkanal). Für RRB und RRK. Für RÜB Nutzinhalt_Fangteil und Nutzinhalt_Klaerteil benutzen. Zusätzlich auch Stauraum erfassen. / Inhalt der Kammer unterhalb Notüberlauf oder Bypass (maximal mobilisierbares Volumen, inkl. Stauraum im Zulaufkanal). Für RRB und RRK. Für RÜB Nutzinhalt_Fangteil und Nutzinhalt_Klaerteil benutzen. Zusätzlich auch Stauraum erfassen. / Pour les bassins et canalisations d’accumulation : Volume de la chambre sous la surverse de secours ou bypass (volume mobilisable maximum, incl. le volume de stockage de la canalisation d’amenée). Pour les BEP il s’agit du VOLUME_UTILE_STOCKAGE et du VOLUME_UTILE_CLARIFICATION. Il faut également saisir le VOLUME_DE_STOCKAGE.';


--
-- Name: COLUMN hydr_geometry.volume_pump_sump; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.volume_pump_sump IS 'yyy_Volumen des Pumpensumpfs von der Sohle bis zur maximal möglichen Wasserspiegellage (inkl. Kanalspeichervolumen im Zulaufkanal). / Volumen des Pumpensumpfs von der Sohle bis zur maximal möglichen Wasserspiegellage (inkl. Kanalspeichervolumen im Zulaufkanal). / Volume du puisard calculée à partir du radier jusqu’au niveau d’eau maximum possible (incl. le volume de stockage de la canalisation d’amenée).';


--
-- Name: COLUMN hydr_geometry.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN hydr_geometry.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN hydr_geometry.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydr_geometry.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: hydraulic_char_data; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.hydraulic_char_data (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'hydraulic_char_data'::text) NOT NULL,
    aggregate_number smallint,
    delivery_height_geodaetic numeric(6,2),
    identifier character varying(20),
    is_overflowing integer,
    main_weir_kind integer,
    overcharge numeric(5,2),
    overflow_duration numeric(6,1),
    overflow_freight integer,
    overflow_frequency numeric(3,1),
    overflow_volume numeric(9,2),
    pump_characteristics integer,
    pump_flow_max numeric(9,3),
    pump_flow_min numeric(9,3),
    pump_usage_current integer,
    q_discharge numeric(9,3),
    qon numeric(9,3),
    remark character varying(80),
    status integer,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_node character varying(16),
    fk_overflow_characteristic character varying(16)
);


ALTER TABLE qgep_od.hydraulic_char_data OWNER TO postgres;

--
-- Name: COLUMN hydraulic_char_data.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN hydraulic_char_data.is_overflowing; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.is_overflowing IS 'yyy_Angabe, ob die Entlastung beim Dimensionierungsereignis anspringt / Angabe, ob die Entlastung beim Dimensionierungsereignis anspringt / Indication, si le déversoir déverse lors des événements pour lesquels il a été dimensionné.';


--
-- Name: COLUMN hydraulic_char_data.main_weir_kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.main_weir_kind IS 'yyy_Art des Hauptwehrs am Knoten, falls mehrere Überläufe / Art des Hauptwehrs am Knoten, falls mehrere Überläufe / Genre du déversoir principal du noeud concerné s''il y a plusieurs déversoirs.';


--
-- Name: COLUMN hydraulic_char_data.overcharge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.overcharge IS 'yyy_Optimale Mehrbelastung nach der Umsetzung der Massnahmen. / Ist: Mehrbelastung der untenliegenden Kanäle beim Dimensionierungsereignis = 100 * (Qab – Qan) / Qan 	[%]. Verhältnis zwischen der abgeleiteten Abwassermengen Richtung ARA beim Anspringen des Entlastungsbauwerkes (Qan) und Qab (Abwassermenge, welche beim Dimensionierungsereignis (z=5) weiter im Kanalnetz Richtung Abwasserreinigungsanlage abgeleitet wird). Beispiel: Qan = 100 l/s, Qab = 150 l/s -> Mehrbelastung = 50%; Ist_optimiert: Optimale Mehrbelastung im Ist-Zustand vor der Umsetzung von allfälligen weiteren Massnahmen; geplant: Optimale Mehrbelastung nach der Umsetzung der Massnahmen. / Etat actuel: Surcharge optimale à l’état actuel avant la réalisation d’éventuelles mesures;  actuel optimisé: Surcharge optimale à l’état actuel avant la réalisation d’éventuelles mesures; prévu: Optimale Mehrbelastung nach der Umsetzung der Massnahmen.';


--
-- Name: COLUMN hydraulic_char_data.overflow_duration; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.overflow_duration IS 'yyy_Mittlere Überlaufdauer pro Jahr. Bei Ist_Zustand: Berechnung mit geplanten Massnahmen. Bei Ist_optimiert:  Berechnung mit optimierten Einstellungen im Ist-Zustand vor der Umsetzung von allfälligen weiteren Massnahmen. Planungszustand: Berechnung mit geplanten Massnahmen / Mittlere Überlaufdauer pro Jahr. Bei Ist_Zustand: Berechnung mit geplanten Massnahmen. Bei Ist_optimiert:  Berechnung mit optimierten Einstellungen im Ist-Zustand vor der Umsetzung von allfälligen weiteren Massnahmen. Planungszustand: Berechnung mit geplanten Massnahmen / Durée moyenne de déversement par an.  Actuel: Durée moyenne de déversement par an selon des simulations pour de longs temps de retour (z > 10). Actuel optimizé: Calcul en mode optimal à l’état actuel avant la réalisation d’éventuelles mesures. Prévu: Calcul selon les mesures planifiées';


--
-- Name: COLUMN hydraulic_char_data.overflow_freight; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.overflow_freight IS 'yyy_Mittlere Ueberlaufschmutzfracht pro Jahr / Mittlere Ueberlaufschmutzfracht pro Jahr / Charge polluante moyenne déversée par année';


--
-- Name: COLUMN hydraulic_char_data.overflow_frequency; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.overflow_frequency IS 'yyy_Mittlere Überlaufhäufigkeit pro Jahr. Ist Zustand: Durchschnittliche Überlaufhäufigkeit pro Jahr von Entlastungsanlagen gemäss Langzeitsimulation (Dauer mindestens 10 Jahre). Ist optimiert: Berechnung mit optimierten Einstellungen im Ist-Zustand vor der Umsetzung von allfälligen weiteren Massnahmen. Planungszustand: Berechnung mit Einstellungen nach der Umsetzung der Massnahmen / Mittlere Überlaufhäufigkeit pro Jahr. Ist Zustand: Durchschnittliche Überlaufhäufigkeit pro Jahr von Entlastungsanlagen gemäss Langzeitsimulation (Dauer mindestens 10 Jahre). Ist optimiert: Berechnung mit optimierten Einstellungen im Ist-Zustand vor der Umsetzung von allfälligen weiteren Massnahmen. Planungszustand: Berechnung mit Einstellungen nach der Umsetzung der Massnahmen / Fréquence moyenne de déversement par an. Fréquence moyenne de déversement par an selon des simulations pour de longs temps de retour (z > 10). Actuel optimizé: Calcul en mode optimal à l’état actuel avant la réalisation d’éventuelles mesures. Prévu: Calcul après la réalisation d’éventuelles mesures.';


--
-- Name: COLUMN hydraulic_char_data.overflow_volume; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.overflow_volume IS 'yyy_Mittlere Überlaufwassermenge pro Jahr. Durchschnittliche Überlaufmenge pro Jahr von Entlastungsanlagen gemäss Langzeitsimulation (Dauer mindestens 10 Jahre). Ist optimiert: Berechnung mit optimierten Einstellungen im Ist-Zustand vor der Umsetzung von allfälligen weiteren Massnahmen. Planungszustand: Berechnung mit Einstellungen nach der Umsetzung der Massnahmen / Mittlere Überlaufwassermenge pro Jahr. Durchschnittliche Überlaufmenge pro Jahr von Entlastungsanlagen gemäss Langzeitsimulation (Dauer mindestens 10 Jahre). Ist optimiert: Berechnung mit optimierten Einstellungen im Ist-Zustand vor der Umsetzung von allfälligen weiteren Massnahmen. Planungszustand: Berechnung mit Einstellungen nach der Umsetzung der Massnahmen / Volume moyen déversé par an. Volume moyen déversé par an selon des simulations pour de longs temps de retour (z > 10). Actuel optimizé: Calcul en mode optimal à l’état actuel avant la réalisation d’éventuelles mesures. Prévu: Calcul après la réalisation d’éventuelles mesures.';


--
-- Name: COLUMN hydraulic_char_data.pump_characteristics; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.pump_characteristics IS 'yyy_Bei speziellen Betriebsarten ist die Funktion separat zu dokumentieren und der Stammkarte beizulegen. / Bei speziellen Betriebsarten ist die Funktion separat zu dokumentieren und der Stammkarte beizulegen. / Pour de régime de fonctionnement spéciaux, cette fonction doit être documentée séparément et annexée à la fiche technique';


--
-- Name: COLUMN hydraulic_char_data.pump_flow_max; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.pump_flow_max IS 'yyy_Maximaler Förderstrom der Pumpen (gesamtes Bauwerk). Tritt in der Regel bei der minimalen Förderhöhe ein. / Maximaler Förderstrom der Pumpen (gesamtes Bauwerk). Tritt in der Regel bei der minimalen Förderhöhe ein. / Débit de refoulement maximal de toutes les pompes de l’ouvrage. Survient normalement à la hauteur min de refoulement.';


--
-- Name: COLUMN hydraulic_char_data.pump_flow_min; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.pump_flow_min IS 'yyy_Minimaler Förderstrom der Pumpen zusammen (gesamtes Bauwerk). Tritt in der Regel bei der maximalen Förderhöhe ein. / Minimaler Förderstrom der Pumpen zusammen (gesamtes Bauwerk). Tritt in der Regel bei der maximalen Förderhöhe ein. / Débit de refoulement minimal de toutes les pompes de l’ouvrage. Survient normalement à la hauteur max de refoulement.';


--
-- Name: COLUMN hydraulic_char_data.pump_usage_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.pump_usage_current IS 'yyy_Nutzungsart_Ist des gepumpten Abwassers. / Nutzungsart_Ist des gepumpten Abwassers. / Genre d''utilisation actuel de l''eau usée pompée';


--
-- Name: COLUMN hydraulic_char_data.q_discharge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.q_discharge IS 'yyy_Qab gemäss GEP / Qab gemäss GEP / Qeff selon PGEE';


--
-- Name: COLUMN hydraulic_char_data.qon; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.qon IS 'yyy_Wassermenge, bei welcher der Überlauf anspringt / Wassermenge, bei welcher der Überlauf anspringt / Débit à partir duquel le déversoir devrait être fonctionnel';


--
-- Name: COLUMN hydraulic_char_data.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN hydraulic_char_data.status; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.status IS 'yyy_Planungszustand der Hydraulischen Kennwerte (zwingend). Ueberlaufcharakteristik und Gesamteinzugsgebiet kann für verschiedene Stati gebildet werden und leitet sich aus dem Status der Hydr_Kennwerte ab. / Planungszustand der Hydraulischen Kennwerte (zwingend). Ueberlaufcharakteristik und Gesamteinzugsgebiet kann für verschiedene Stati gebildet werden und leitet sich aus dem Status der Hydr_Kennwerte ab. / Etat prévu des caractéristiques hydrauliques (obligatoire). Les caractéristiques de déversement et le bassin versant global peuvent être représentés à différents états et se laissent déduire à partir de l’attribut PARAMETRES_HYDR';


--
-- Name: COLUMN hydraulic_char_data.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN hydraulic_char_data.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN hydraulic_char_data.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.hydraulic_char_data.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: individual_surface; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.individual_surface (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'individual_surface'::text) NOT NULL,
    function integer,
    inclination smallint,
    pavement integer,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.individual_surface OWNER TO postgres;

--
-- Name: COLUMN individual_surface.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.individual_surface.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN individual_surface.function; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.individual_surface.function IS 'Type of usage of surface / Art der Nutzung der Fläche / Genre d''utilisation de la surface';


--
-- Name: COLUMN individual_surface.inclination; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.individual_surface.inclination IS 'yyy_Mittlere Neigung der Oberfläche in Promill / Mittlere Neigung der Oberfläche in Promill / Pente moyenne de la surface en promille';


--
-- Name: COLUMN individual_surface.pavement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.individual_surface.pavement IS 'Type of pavement / Art der Befestigung / Genre de couverture du sol';


--
-- Name: COLUMN individual_surface.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.individual_surface.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: infiltration_installation; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.infiltration_installation (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'infiltration_installation'::text) NOT NULL,
    absorption_capacity numeric(9,3),
    defects integer,
    dimension1 smallint,
    dimension2 smallint,
    distance_to_aquifer numeric(7,2),
    effective_area numeric(8,2),
    emergency_spillway integer,
    kind integer,
    labeling integer,
    seepage_utilization integer,
    upper_elevation numeric(7,3),
    vehicle_access integer,
    watertightness integer,
    fk_aquifier character varying(16)
);


ALTER TABLE qgep_od.infiltration_installation OWNER TO postgres;

--
-- Name: COLUMN infiltration_installation.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN infiltration_installation.absorption_capacity; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.absorption_capacity IS 'yyy_Schluckvermögen des Bodens. / Schluckvermögen des Bodens. / Capacité d''absorption du sol';


--
-- Name: COLUMN infiltration_installation.defects; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.defects IS 'yyy_Gibt die aktuellen Mängel der Versickerungsanlage an (IST-Zustand). / Gibt die aktuellen Mängel der Versickerungsanlage an (IST-Zustand). / Indique les défauts actuels de l''installation d''infiltration (etat_actuel).';


--
-- Name: COLUMN infiltration_installation.dimension1; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.dimension1 IS 'Dimension1 of infiltration installations (largest inside dimension) if used with norm elements. Else leave empty.. / Dimension1 der Versickerungsanlage (grösstes Innenmass) bei der Verwendung von Normbauteilen. Sonst leer lassen und mit Detailgeometrie beschreiben. / Dimension1 de l’installation d’infiltration (plus grande mesure intérieure) lorsqu’elle est utilisée pour des éléments d’ouvrage normés. Sinon, à laisser libre et prendre la description de la géométrie détaillée.';


--
-- Name: COLUMN infiltration_installation.dimension2; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.dimension2 IS 'Dimension2 of infiltration installations (smallest inside dimension). With circle shaped installations leave dimension2 empty, with ovoid shaped ones fill it in. With rectangular shaped manholes use detailled_geometry to describe further. / Dimension2 der Versickerungsanlage (kleinstes Innenmass) bei der Verwendung von Normbauteilen. Sonst leer lassen und mit Detailgeometrie beschreiben. / Dimension2 de la chambre (plus petite mesure intérieure). La dimension2 est à saisir pour des chambres ovales et à laisser libre pour des chambres circulaires. Pour les chambres rectangulaires il faut utiliser la géométrie détaillée.';


--
-- Name: COLUMN infiltration_installation.distance_to_aquifer; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.distance_to_aquifer IS 'yyy_Flurabstand (Vertikale Distanz Terrainoberfläche zum Grundwasserleiter). / Flurabstand (Vertikale Distanz Terrainoberfläche zum Grundwasserleiter). / Distance à l''aquifère (distance verticale de la surface du terrain à l''aquifère)';


--
-- Name: COLUMN infiltration_installation.effective_area; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.effective_area IS 'yyy_Für den Abfluss wirksame Fläche / Für den Abfluss wirksame Fläche / Surface qui participe à l''écoulement';


--
-- Name: COLUMN infiltration_installation.emergency_spillway; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.emergency_spillway IS 'yyy_Endpunkt allfälliger Verrohrung des Notüberlaufes der Versickerungsanlage / Endpunkt allfälliger Verrohrung des Notüberlaufes der Versickerungsanlage / Point cumulant des conduites du trop plein d''une installation d''infiltration';


--
-- Name: COLUMN infiltration_installation.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.kind IS 'yyy_Arten von Versickerungsmethoden. / Arten von Versickerungsmethoden. / Genre de méthode d''infiltration.';


--
-- Name: COLUMN infiltration_installation.labeling; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.labeling IS 'yyy_Kennzeichnung der Schachtdeckel der Anlage als Versickerungsanlage.  Nur bei Anlagen mit Schächten. / Kennzeichnung der Schachtdeckel der Anlage als Versickerungsanlage.  Nur bei Anlagen mit Schächten. / Désignation inscrite du couvercle de l''installation d''infiltration. Uniquement pour des installations avec couvercle';


--
-- Name: COLUMN infiltration_installation.seepage_utilization; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.seepage_utilization IS 'yyy_Arten des zu versickernden Wassers. / Arten des zu versickernden Wassers. / Genre d''eau à infiltrer';


--
-- Name: COLUMN infiltration_installation.upper_elevation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.upper_elevation IS 'Highest point of structure (ceiling), outside / Höchster Punkt des Bauwerks (Decke), aussen / Point le plus élevé de la construction';


--
-- Name: COLUMN infiltration_installation.vehicle_access; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.vehicle_access IS 'yyy_Zugänglichkeit für Saugwagen. Sie bezieht sich auf die gesamte Versickerungsanlage / Vorbehandlungsanlagen und kann in den Bemerkungen weiter spezifiziert werden / Zugänglichkeit für Saugwagen. Sie bezieht sich auf die gesamte Versickerungsanlage / Vorbehandlungsanlagen und kann in den Bemerkungen weiter spezifiziert werden / Accessibilité pour des camions de vidange. Se réfère à toute l''installation d''infiltration / de prétraitement et peut être spécifiée sous REMARQUE';


--
-- Name: COLUMN infiltration_installation.watertightness; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_installation.watertightness IS 'yyy_Wasserdichtheit gegen Oberflächenwasser.  Nur bei Anlagen mit Schächten. / Wasserdichtheit gegen Oberflächenwasser.  Nur bei Anlagen mit Schächten. / Etanchéité contre des eaux superficielles. Uniquement pour des installations avec chambres';


--
-- Name: infiltration_zone; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.infiltration_zone (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'infiltration_zone'::text) NOT NULL,
    infiltration_capacity integer,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.infiltration_zone OWNER TO postgres;

--
-- Name: COLUMN infiltration_zone.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_zone.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN infiltration_zone.infiltration_capacity; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_zone.infiltration_capacity IS 'yyy_Versickerungsmöglichkeit im Bereich / Versickerungsmöglichkeit im Bereich / Potentiel d''infiltration de la zone';


--
-- Name: COLUMN infiltration_zone.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.infiltration_zone.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: lake; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.lake (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'lake'::text) NOT NULL,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.lake OWNER TO postgres;

--
-- Name: COLUMN lake.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.lake.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN lake.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.lake.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: leapingweir; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.leapingweir (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'leapingweir'::text) NOT NULL,
    length numeric(7,2),
    opening_shape integer,
    width numeric(7,2)
);


ALTER TABLE qgep_od.leapingweir OWNER TO postgres;

--
-- Name: COLUMN leapingweir.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.leapingweir.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN leapingweir.length; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.leapingweir.length IS 'yyy_Maximale Abmessung der Bodenöffnung in Fliessrichtung / Maximale Abmessung der Bodenöffnung in Fliessrichtung / Dimension maximale de l''ouverture de fond parallèlement au courant';


--
-- Name: COLUMN leapingweir.opening_shape; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.leapingweir.opening_shape IS 'Shape of opening in the floor / Form der  Bodenöffnung / Forme de l''ouverture de fond';


--
-- Name: COLUMN leapingweir.width; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.leapingweir.width IS 'yyy_Maximale Abmessung der Bodenöffnung quer zur Fliessrichtung / Maximale Abmessung der Bodenöffnung quer zur Fliessrichtung / Dimension maximale de l''ouverture de fond perpendiculairement à la direction d''écoulement';


--
-- Name: lock; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.lock (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'lock'::text) NOT NULL,
    vertical_drop numeric(7,2)
);


ALTER TABLE qgep_od.lock OWNER TO postgres;

--
-- Name: COLUMN lock.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.lock.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN lock.vertical_drop; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.lock.vertical_drop IS 'yyy_Vertical difference of water level before and after Schleuse / Differenz im Wasserspiegel oberhalb und unterhalb der Schleuse / Différence des plans d''eau entre l''amont et l''aval de l''écluse';


--
-- Name: maintenance_event; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.maintenance_event (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'maintenance_event'::text) NOT NULL,
    base_data character varying(50),
    cost numeric(10,2),
    data_details character varying(50),
    duration smallint,
    identifier character varying(20),
    kind integer,
    operator character varying(50),
    reason character varying(50),
    remark character varying(80),
    result character varying(50),
    status integer,
    time_point timestamp without time zone,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_operating_company character varying(16),
    active_zone character varying(1)
);


ALTER TABLE qgep_od.maintenance_event OWNER TO postgres;

--
-- Name: COLUMN maintenance_event.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN maintenance_event.base_data; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.base_data IS 'e.g. damage protocol / Z.B. Schadensprotokoll / par ex. protocole de dommages';


--
-- Name: COLUMN maintenance_event.data_details; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.data_details IS 'yyy_Ort, wo sich weitere Detailinformationen zum Ereignis finden (z.B. Nr. eines Videobandes) / Ort, wo sich weitere Detailinformationen zum Ereignis finden (z.B. Nr. eines Videobandes) / Lieu où se trouvent les données détaillées (par ex. n° d''une bande vidéo)';


--
-- Name: COLUMN maintenance_event.duration; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.duration IS 'Duration of event in days / Dauer des Ereignisses in Tagen / Durée de l''événement en jours';


--
-- Name: COLUMN maintenance_event.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.kind IS 'Type of event / Art des Ereignisses / Genre d''événement';


--
-- Name: COLUMN maintenance_event.operator; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.operator IS 'Operator of operating company or administration / Sachbearbeiter Firma oder Verwaltung (kann auch Operateur sein bei Untersuchung) / Responsable de saisie du bureau';


--
-- Name: COLUMN maintenance_event.reason; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.reason IS 'Reason for this event / Ursache für das Ereignis / Cause de l''événement';


--
-- Name: COLUMN maintenance_event.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN maintenance_event.result; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.result IS 'Result or important comments for this event / Resultat oder wichtige Bemerkungen aus Sicht des Bearbeiters / Résultat ou commentaire importante de l''événement';


--
-- Name: COLUMN maintenance_event.status; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.status IS 'Disposition state of the maintenance event / Phase in der sich das Erhaltungsereignis befindet / Phase dans laquelle se trouve l''événement de maintenance';


--
-- Name: COLUMN maintenance_event.time_point; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.time_point IS 'Date and time of the event / Zeitpunkt des Ereignisses / Date et heure de l''événement';


--
-- Name: COLUMN maintenance_event.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN maintenance_event.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN maintenance_event.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.maintenance_event.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: manhole; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.manhole (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'manhole'::text) NOT NULL,
    dimension1 smallint,
    dimension2 smallint,
    function integer,
    material integer,
    surface_inflow integer,
    _orientation numeric
);


ALTER TABLE qgep_od.manhole OWNER TO postgres;

--
-- Name: COLUMN manhole.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.manhole.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN manhole.dimension1; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.manhole.dimension1 IS 'Dimension2 of infiltration installations (largest inside dimension). / Dimension1 des Schachtes (grösstes Innenmass). / Dimension1 de la chambre (plus grande mesure intérieure).';


--
-- Name: COLUMN manhole.dimension2; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.manhole.dimension2 IS 'Dimension2 of manhole (smallest inside dimension). With circle shaped manholes leave dimension2 empty, with ovoid manholes fill it in. With rectangular shaped manholes use detailled_geometry to describe further. / Dimension2 des Schachtes (kleinstes Innenmass). Bei runden Schächten wird Dimension2 leer gelassen, bei ovalen abgefüllt. Für eckige Schächte Detailgeometrie verwenden. / Dimension2 de la chambre (plus petite mesure intérieure)';


--
-- Name: COLUMN manhole.function; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.manhole.function IS 'Kind of function / Art der Nutzung / Genre d''utilisation';


--
-- Name: COLUMN manhole.material; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.manhole.material IS 'yyy_Hauptmaterial aus dem das Bauwerk besteht zur groben Klassifizierung. / Hauptmaterial aus dem das Bauwerk besteht zur groben Klassifizierung. / Matériau dont est construit l''ouvrage, pour une classification sommaire';


--
-- Name: COLUMN manhole.surface_inflow; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.manhole.surface_inflow IS 'yyy_Zuflussmöglichkeit  von Oberflächenwasser direkt in den Schacht / Zuflussmöglichkeit  von Oberflächenwasser direkt in den Schacht / Arrivée directe d''eaux superficielles dans la chambre';


--
-- Name: COLUMN manhole._orientation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.manhole._orientation IS 'not part of the VSA-DSS data model
added solely for QGEP';


--
-- Name: measurement_result; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.measurement_result (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'measurement_result'::text) NOT NULL,
    identifier character varying(20),
    measurement_type integer,
    measuring_duration numeric(7,0),
    remark character varying(80),
    "time" timestamp without time zone,
    value real,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_measuring_device character varying(16),
    fk_measurement_series character varying(16)
);


ALTER TABLE qgep_od.measurement_result OWNER TO postgres;

--
-- Name: COLUMN measurement_result.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN measurement_result.measurement_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.measurement_type IS 'Type of measurment, e.g. proportional to time or volume / Art der Messung, z.B zeit- oder mengenproportional / Type de mesure, par ex. proportionnel au temps ou au débit';


--
-- Name: COLUMN measurement_result.measuring_duration; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.measuring_duration IS 'Duration of measurment in seconds / Dauer der Messung in Sekunden / Durée de la mesure';


--
-- Name: COLUMN measurement_result.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN measurement_result."time"; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result."time" IS 'Date and time at beginning of measurment / Zeitpunkt des Messbeginns / Date et heure du début de la mesure';


--
-- Name: COLUMN measurement_result.value; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.value IS 'yyy_Gemessene Grösse / Gemessene Grösse / Valeur mesurée';


--
-- Name: COLUMN measurement_result.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN measurement_result.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN measurement_result.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_result.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: measurement_series; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.measurement_series (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'measurement_series'::text) NOT NULL,
    dimension character varying(50),
    identifier character varying(20),
    kind integer,
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_measuring_point character varying(16)
);


ALTER TABLE qgep_od.measurement_series OWNER TO postgres;

--
-- Name: COLUMN measurement_series.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_series.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN measurement_series.dimension; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_series.dimension IS 'yyy_Messtypen (Einheit) / Messtypen (Einheit) / Types de mesures';


--
-- Name: COLUMN measurement_series.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_series.kind IS 'Type of measurment series / Art der Messreihe / Genre de série de mesures';


--
-- Name: COLUMN measurement_series.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_series.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN measurement_series.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_series.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN measurement_series.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_series.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN measurement_series.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measurement_series.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: measuring_device; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.measuring_device (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'measuring_device'::text) NOT NULL,
    brand character varying(50),
    identifier character varying(20),
    kind integer,
    remark character varying(80),
    serial_number character varying(50),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_measuring_point character varying(16)
);


ALTER TABLE qgep_od.measuring_device OWNER TO postgres;

--
-- Name: COLUMN measuring_device.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_device.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN measuring_device.brand; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_device.brand IS 'Brand / Name of producer / Name des Herstellers / Nom du fabricant';


--
-- Name: COLUMN measuring_device.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_device.kind IS 'Type of measuring device / Typ des Messgerätes / Type de l''appareil de mesure';


--
-- Name: COLUMN measuring_device.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_device.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN measuring_device.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_device.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN measuring_device.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_device.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN measuring_device.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_device.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: measuring_point; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.measuring_point (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'measuring_point'::text) NOT NULL,
    damming_device integer,
    identifier character varying(20),
    kind character varying(50),
    purpose integer,
    remark character varying(80),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_operator character varying(16),
    fk_waste_water_treatment_plant character varying(16),
    fk_wastewater_structure character varying(16),
    fk_water_course_segment character varying(16)
);


ALTER TABLE qgep_od.measuring_point OWNER TO postgres;

--
-- Name: COLUMN measuring_point.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN measuring_point.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.kind IS 'yyy_Art der Untersuchungsstelle ( Regenmessungen, Abflussmessungen, etc.) / Art der Untersuchungsstelle ( Regenmessungen, Abflussmessungen, etc.) / Genre de mesure (mesures de pluviométrie, mesures de débit, etc.)';


--
-- Name: COLUMN measuring_point.purpose; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.purpose IS 'Purpose of measurement / Zweck der Messung / Objet de la mesure';


--
-- Name: COLUMN measuring_point.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN measuring_point.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: COLUMN measuring_point.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN measuring_point.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN measuring_point.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.measuring_point.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: mechanical_pretreatment; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.mechanical_pretreatment (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'mechanical_pretreatment'::text) NOT NULL,
    identifier character varying(20),
    kind integer,
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_infiltration_installation character varying(16),
    fk_wastewater_structure character varying(16)
);


ALTER TABLE qgep_od.mechanical_pretreatment OWNER TO postgres;

--
-- Name: COLUMN mechanical_pretreatment.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mechanical_pretreatment.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN mechanical_pretreatment.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mechanical_pretreatment.kind IS 'yyy_Arten der mechanischen Vorreinigung / Behandlung (gemäss VSA Richtlinie Regenwasserentsorgung (2002)) / Arten der mechanischen Vorreinigung / Behandlung (gemäss VSA Richtlinie Regenwasserentsorgung (2002)) / Genre de pré-épuration mécanique (selon directive VSA "Evacuation des eaux pluviales, édition 2002)';


--
-- Name: COLUMN mechanical_pretreatment.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mechanical_pretreatment.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN mechanical_pretreatment.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mechanical_pretreatment.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN mechanical_pretreatment.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mechanical_pretreatment.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN mechanical_pretreatment.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mechanical_pretreatment.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: municipality; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.municipality (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'municipality'::text) NOT NULL,
    altitude numeric(7,3),
    gwdp_year smallint,
    municipality_number smallint,
    perimeter_geometry public.geometry(CurvePolygon,2056),
    population integer,
    total_surface numeric(8,2)
);


ALTER TABLE qgep_od.municipality OWNER TO postgres;

--
-- Name: COLUMN municipality.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.municipality.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN municipality.altitude; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.municipality.altitude IS 'Average altitude of settlement area / Mittlere Höhe des Siedlungsgebietes / Altitude moyenne de l''agglomération';


--
-- Name: COLUMN municipality.gwdp_year; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.municipality.gwdp_year IS 'Year of legal validity of General Water Drainage Planning (GWDP) / Rechtsgültiges GEP aus dem Jahr / PGEE en vigueur depuis';


--
-- Name: COLUMN municipality.municipality_number; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.municipality.municipality_number IS 'Official number of federal office for statistics / Offizielle Nummer gemäss Bundesamt für Statistik / Numéro officiel de la commune selon l''Office fédéral de la statistique';


--
-- Name: COLUMN municipality.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.municipality.perimeter_geometry IS 'Border of the municipality / Gemeindegrenze / Limites communales';


--
-- Name: COLUMN municipality.population; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.municipality.population IS 'Permanent opulation (based on statistics of the municipality) / Ständige Einwohner (laut Einwohnerkontrolle der Gemeinde) / Habitants permanents (selon le contrôle des habitants de la commune)';


--
-- Name: COLUMN municipality.total_surface; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.municipality.total_surface IS 'Total surface without lakes / Fläche ohne Seeanteil / Surface sans partie de lac';


--
-- Name: mutation; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.mutation (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'mutation'::text) NOT NULL,
    attribute character varying(50),
    class character varying(50),
    date_mutation timestamp without time zone,
    date_time timestamp without time zone,
    kind integer,
    last_value character varying(100),
    object character varying(20),
    recorded_by character varying(80),
    remark character varying(80),
    system_user character varying(20),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.mutation OWNER TO postgres;

--
-- Name: COLUMN mutation.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN mutation.attribute; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.attribute IS 'Attribute name of chosen object / Attributname des gewählten Objektes / Nom de l''attribut de l''objet à sélectionner';


--
-- Name: COLUMN mutation.class; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.class IS 'Class name of chosen object / Klassenname des gewählten Objektes / Nom de classe de l''objet à sélectionner';


--
-- Name: COLUMN mutation.date_mutation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.date_mutation IS 'if changed: Date/Time of changement. If deleted date/time of deleting / Bei geaendert Datum/Zeit der Änderung. Bei gelöscht Datum/Zeit der Löschung / changée: Date/Temps du changement. effacée: Date/Temps de la suppression';


--
-- Name: COLUMN mutation.date_time; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.date_time IS 'Date/Time of collecting data in the field. Else Date/Time of creating data set on the system / Datum/Zeit der Aufnahme im Feld falls vorhanden bei erstellt. Sonst Datum/Uhrzeit der Erstellung auf dem System / Date/temps de la relève, sinon date/temps de création dans le système';


--
-- Name: COLUMN mutation.last_value; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.last_value IS 'last_value changed to text. Only with type=changed and deleted / Letzter Wert umgewandelt in Text. Nur bei ART=geaendert oder geloescht / Dernière valeur modifiée du texte. Seulement avec GENRE = changee ou effacee';


--
-- Name: COLUMN mutation.object; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.object IS 'OBJ_ID of Object / OBJ_ID des Objektes / OBJ_ID de l''objet';


--
-- Name: COLUMN mutation.recorded_by; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.recorded_by IS 'Name of person who recorded the dataset / Name des Aufnehmers im Feld / Nom de la personne, qui a relevé les données';


--
-- Name: COLUMN mutation.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN mutation.system_user; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.system_user IS 'Name of system user / Name des Systembenutzers / Usager du système informatique';


--
-- Name: COLUMN mutation.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN mutation.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN mutation.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.mutation.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: organisation; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.organisation (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'organisation'::text) NOT NULL,
    identifier character varying(80),
    remark character varying(80),
    uid character varying(12),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.organisation OWNER TO postgres;

--
-- Name: COLUMN organisation.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.organisation.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN organisation.identifier; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.organisation.identifier IS 'It is suggested to use real names, e.g. Sample_Community and not only Community. Or "Waste Water Association WWTP Example" and not only Waste Water Association because there will be multiple objects / Es wird empfohlen reale Namen zu nehmen, z.B. Mustergemeinde und nicht Gemeinde. Oder Abwasserverband ARA Muster und nicht nur Abwasserverband, da es sonst Probleme gibt bei der Zusammenführung der Daten. / Utilisez les noms réels, par ex. commune "exemple" et pas seulement commune. Ou "Association pour l''épuration des eaux usées STEP XXX" et pas seulement  Association pour l''épuration des eaux usées. Sinon vous risquer des problèmes en réunissant les données de différentes communes.';


--
-- Name: COLUMN organisation.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.organisation.remark IS 'yyy Fehler bei Zuordnung / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN organisation.uid; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.organisation.uid IS 'yyyReferenz zur Unternehmensidentifikation des Bundesamts fuer Statistik (www.uid.admin.ch), e.g. z.B. CHE123456789 / Referenz zur Unternehmensidentifikation des Bundesamts fuer Statistik (www.uid.admin.ch), z.B. CHE123456789 / Référence pour l’identification des entreprises selon l’Office fédéral de la statistique OFS (www.uid.admin.ch), par exemple: CHE123456789';


--
-- Name: COLUMN organisation.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.organisation.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN organisation.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.organisation.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN organisation.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.organisation.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: overflow; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.overflow (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'overflow'::text) NOT NULL,
    actuation integer,
    adjustability integer,
    brand character varying(50),
    control integer,
    discharge_point character varying(20),
    function integer,
    gross_costs numeric(10,2),
    identifier character varying(20),
    qon_dim numeric(9,3),
    remark character varying(80),
    signal_transmission integer,
    subsidies numeric(10,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_node character varying(16),
    fk_overflow_to character varying(16),
    fk_overflow_characteristic character varying(16),
    fk_control_center character varying(16)
);


ALTER TABLE qgep_od.overflow OWNER TO postgres;

--
-- Name: COLUMN overflow.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN overflow.actuation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.actuation IS 'Actuation of installation / Antrieb der Einbaute / Entraînement des installations';


--
-- Name: COLUMN overflow.adjustability; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.adjustability IS 'yyy_Möglichkeit zur Verstellung / Möglichkeit zur Verstellung / Possibilité de modifier la position';


--
-- Name: COLUMN overflow.brand; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.brand IS 'Manufacturer of the electro-mechaninc equipment or installation / Hersteller der elektro-mechanischen Ausrüstung oder Einrichtung / Fabricant d''équipement électromécanique ou d''installations';


--
-- Name: COLUMN overflow.control; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.control IS 'yyy_Steuer- und Regelorgan für die Einbaute / Steuer- und Regelorgan für die Einbaute / Dispositifs de commande et de régulation des installations';


--
-- Name: COLUMN overflow.discharge_point; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.discharge_point IS 'Identifier of discharge_point in which the overflow is discharging (redundant attribute with network follow up or result of that). Is only needed if overflow is discharging into a river (directly or via a rainwater drainage). Foreignkey to discharge_point in class catchement_area_totals in extension Stammkarte. / Bezeichnung der Einleitstelle in die der Ueberlauf entlastet (redundantes Attribut zur Netzverfolgung oder Resultat davon). Muss nur erfasst werden, wenn das Abwasser vom Notüberlauf in ein Gewässer eingeleitet wird (direkt oder über eine Regenabwasserleitung). Verknüpfung mit Fremdschlüssel zu Einleitstelle in Klasse Gesamteinzugsgebiet in Erweiterung Stammkarte. / Désignation de l''exutoire: A indiquer uniquement lorsque l’eau déversée est rejetée dans un cours d’eau (directement ou indirectement via une conduite d’eaux pluviales). Association à l''exutoire dans la classe BASSIN_VERSANT_COMPLET de l''extension fichier technique.';


--
-- Name: COLUMN overflow.function; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.function IS 'yyy_Teil des Mischwasserabflusses, der aus einem Überlauf in einen Vorfluter oder in ein Abwasserbauwerk abgeleitet wird / Teil des Mischwasserabflusses, der aus einem Überlauf in einen Vorfluter oder in ein Abwasserbauwerk abgeleitet wird / Type de déversoir';


--
-- Name: COLUMN overflow.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.gross_costs IS 'Gross costs / Brutto Erstellungskosten / Coûts bruts de réalisation';


--
-- Name: COLUMN overflow.qon_dim; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.qon_dim IS 'yyy_Wassermenge, bei welcher der Überlauf gemäss Dimensionierung anspringt / Wassermenge, bei welcher der Überlauf gemäss Dimensionierung anspringt / Débit à partir duquel le déversoir devrait être fonctionnel (selon dimensionnement)';


--
-- Name: COLUMN overflow.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN overflow.signal_transmission; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.signal_transmission IS 'Signal or data transfer from or to a telecommunication station / Signalübermittlung von und zu einer Fernwirkanlage / Transmission des signaux de et vers une station de télécommande';


--
-- Name: COLUMN overflow.subsidies; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.subsidies IS 'yyy_Staats- und Bundesbeiträge / Staats- und Bundesbeiträge / Contributions des cantons et de la confédération';


--
-- Name: COLUMN overflow.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN overflow.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN overflow.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: overflow_char; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.overflow_char (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'overflow_char'::text) NOT NULL,
    identifier character varying(20),
    kind_overflow_characteristic integer,
    overflow_characteristic_digital integer,
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.overflow_char OWNER TO postgres;

--
-- Name: COLUMN overflow_char.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow_char.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN overflow_char.kind_overflow_characteristic; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow_char.kind_overflow_characteristic IS 'yyy_Die Kennlinie ist als Q /Q- (bei Bodenöffnungen) oder als H/Q-Tabelle (bei Streichwehren) zu dokumentieren. Bei einer freien Aufteilung muss die Kennlinie nicht dokumentiert werden. Bei Abflussverhältnissen in Einstaubereichen ist die Funktion separat in einer Beilage zu beschreiben. / Die Kennlinie ist als Q /Q- (bei Bodenöffnungen) oder als H/Q-Tabelle (bei Streichwehren) zu dokumentieren. Bei einer freien Aufteilung muss die Kennlinie nicht dokumentiert werden. Bei Abflussverhältnissen in Einstaubereichen ist die Funktion separat in einer Beilage zu beschreiben. / La courbe est à documenter sous forme de rapport Q/Q (Leaping weir) ou H/Q (déversoir latéral). Les conditions d’écoulement dans la chambre d’accumulation sont à fournir en annexe.';


--
-- Name: COLUMN overflow_char.overflow_characteristic_digital; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow_char.overflow_characteristic_digital IS 'yyy_Falls Kennlinie_digital = ja müssen die Attribute für die Q-Q oder H-Q Beziehung  in Ueberlaufcharakteristik ausgefüllt sein in HQ_Relation. / Falls Kennlinie_digital = ja müssen die Attribute für die Q-Q oder H-Q Beziehung in HQ_Relation ausgefüllt sein. / Si courbe de fonctionnement numérique = oui, les attributs pour les relations Q-Q et H-Q doivent être saisis dans la classe RELATION_HQ.';


--
-- Name: COLUMN overflow_char.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow_char.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN overflow_char.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow_char.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN overflow_char.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow_char.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN overflow_char.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.overflow_char.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: param_ca_general; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.param_ca_general (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'param_ca_general'::text) NOT NULL,
    dry_wheather_flow numeric(9,3),
    flow_path_length numeric(7,2),
    flow_path_slope smallint,
    population_equivalent integer,
    surface_ca numeric(8,2)
);


ALTER TABLE qgep_od.param_ca_general OWNER TO postgres;

--
-- Name: COLUMN param_ca_general.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_general.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN param_ca_general.dry_wheather_flow; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_general.dry_wheather_flow IS 'Dry wheather flow / Débit temps sec';


--
-- Name: COLUMN param_ca_general.flow_path_length; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_general.flow_path_length IS 'Length of flow path / Fliessweglänge / longueur de la ligne d''écoulement';


--
-- Name: COLUMN param_ca_general.flow_path_slope; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_general.flow_path_slope IS 'Slope of flow path [%o] / Fliessweggefälle [%o] / Pente de la ligne d''écoulement [%o]';


--
-- Name: COLUMN param_ca_general.surface_ca; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_general.surface_ca IS 'yyy_Surface bassin versant MOUSE1 / Fläche des Einzugsgebietes für MOUSE1 / Surface bassin versant MOUSE1';


--
-- Name: param_ca_mouse1; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.param_ca_mouse1 (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'param_ca_mouse1'::text) NOT NULL,
    dry_wheather_flow numeric(9,3),
    flow_path_length numeric(7,2),
    flow_path_slope smallint,
    population_equivalent integer,
    surface_ca_mouse numeric(8,2),
    usage character varying(50)
);


ALTER TABLE qgep_od.param_ca_mouse1 OWNER TO postgres;

--
-- Name: COLUMN param_ca_mouse1.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_mouse1.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN param_ca_mouse1.dry_wheather_flow; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_mouse1.dry_wheather_flow IS 'Parameter for calculation of surface runoff for surface runoff modell A1 / Parameter zur Bestimmung des Oberflächenabflusses für das Oberflächenabflussmodell A1 von MOUSE / Paramètre pour calculer l''écoulement superficiel selon le modèle A1 de MOUSE';


--
-- Name: COLUMN param_ca_mouse1.flow_path_length; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_mouse1.flow_path_length IS 'yyy_Parameter zur Bestimmung des Oberflächenabflusses für das Oberflächenabflussmodell A1 von MOUSE / Parameter zur Bestimmung des Oberflächenabflusses für das Oberflächenabflussmodell A1 von MOUSE / Paramètre pour calculer l''écoulement superficiel selon le modèle A1 de MOUSE';


--
-- Name: COLUMN param_ca_mouse1.flow_path_slope; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_mouse1.flow_path_slope IS 'yyy_Parameter zur Bestimmung des Oberflächenabflusses für das Oberflächenabflussmodell A1 von MOUSE [%o] / Parameter zur Bestimmung des Oberflächenabflusses für das Oberflächenabflussmodell A1 von MOUSE [%o] / Paramètre pour calculer l''écoulement superficiel selon le modèle A1 de MOUSE [%o]';


--
-- Name: COLUMN param_ca_mouse1.surface_ca_mouse; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_mouse1.surface_ca_mouse IS 'yyy_Parameter zur Bestimmung des Oberflächenabflusses für das Oberflächenabflussmodell A1 von MOUSE / Parameter zur Bestimmung des Oberflächenabflusses für das Oberflächenabflussmodell A1 von MOUSE / Paramètre pour calculer l''écoulement superficiel selon le modèle A1 de MOUSE';


--
-- Name: COLUMN param_ca_mouse1.usage; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.param_ca_mouse1.usage IS 'Classification based on surface runoff modell MOUSE 2000/2001 / Klassifikation gemäss Oberflächenabflussmodell von MOUSE 2000/2001 / Classification selon le modèle surface de MOUSE 2000/2001';


--
-- Name: passage; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.passage (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'passage'::text) NOT NULL
);


ALTER TABLE qgep_od.passage OWNER TO postgres;

--
-- Name: COLUMN passage.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.passage.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: pipe_profile; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.pipe_profile (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'pipe_profile'::text) NOT NULL,
    height_width_ratio numeric(5,2),
    identifier character varying(20),
    profile_type integer,
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.pipe_profile OWNER TO postgres;

--
-- Name: COLUMN pipe_profile.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pipe_profile.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN pipe_profile.height_width_ratio; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pipe_profile.height_width_ratio IS 'height-width ratio / Verhältnis der Höhe zur Breite / Rapport entre la hauteur et la largeur';


--
-- Name: COLUMN pipe_profile.profile_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pipe_profile.profile_type IS 'Type of profile / Typ des Profils / Type du profil';


--
-- Name: COLUMN pipe_profile.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pipe_profile.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN pipe_profile.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pipe_profile.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN pipe_profile.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pipe_profile.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN pipe_profile.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pipe_profile.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: planning_zone; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.planning_zone (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'planning_zone'::text) NOT NULL,
    kind integer,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.planning_zone OWNER TO postgres;

--
-- Name: COLUMN planning_zone.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.planning_zone.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN planning_zone.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.planning_zone.kind IS 'Type of planning zone / Art der Bauzone / Genre de zones à bâtir';


--
-- Name: COLUMN planning_zone.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.planning_zone.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: prank_weir; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.prank_weir (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'prank_weir'::text) NOT NULL,
    hydraulic_overflow_length numeric(7,2),
    level_max numeric(7,3),
    level_min numeric(7,3),
    weir_edge integer,
    weir_kind integer
);


ALTER TABLE qgep_od.prank_weir OWNER TO postgres;

--
-- Name: COLUMN prank_weir.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.prank_weir.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN prank_weir.hydraulic_overflow_length; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.prank_weir.hydraulic_overflow_length IS 'yyy_Hydraulisch wirksame Wehrlänge / Hydraulisch wirksame Wehrlänge / Longueur du déversoir hydrauliquement active';


--
-- Name: COLUMN prank_weir.level_max; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.prank_weir.level_max IS 'yyy_Höhe des höchsten Punktes der Überfallkante / Höhe des höchsten Punktes der Überfallkante / Niveau max. de la crête déversante';


--
-- Name: COLUMN prank_weir.level_min; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.prank_weir.level_min IS 'yyy_Höhe des tiefsten Punktes der Überfallkante / Höhe des tiefsten Punktes der Überfallkante / Niveau min. de la crête déversante';


--
-- Name: COLUMN prank_weir.weir_edge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.prank_weir.weir_edge IS 'yyy_Ausbildung der Überfallkante / Ausbildung der Überfallkante / Forme de la crête';


--
-- Name: COLUMN prank_weir.weir_kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.prank_weir.weir_kind IS 'yyy_Art der Wehrschweille des Streichwehrs / Art der Wehrschwelle des Streichwehrs / Genre de surverse du déversoir latéral';


--
-- Name: private; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.private (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'private'::text) NOT NULL,
    kind character varying(50)
);


ALTER TABLE qgep_od.private OWNER TO postgres;

--
-- Name: COLUMN private.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.private.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: profile_geometry; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.profile_geometry (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'profile_geometry'::text) NOT NULL,
    "position" smallint,
    x real,
    y real,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_pipe_profile character varying(16)
);


ALTER TABLE qgep_od.profile_geometry OWNER TO postgres;

--
-- Name: COLUMN profile_geometry.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.profile_geometry.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN profile_geometry."position"; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.profile_geometry."position" IS 'yyy_Position der Detailpunkte der Geometrie / Position der Detailpunkte der Geometrie / Position des points d''appui de la géométrie';


--
-- Name: COLUMN profile_geometry.x; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.profile_geometry.x IS 'x';


--
-- Name: COLUMN profile_geometry.y; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.profile_geometry.y IS 'y';


--
-- Name: COLUMN profile_geometry.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.profile_geometry.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN profile_geometry.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.profile_geometry.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN profile_geometry.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.profile_geometry.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: pump; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.pump (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'pump'::text) NOT NULL,
    contruction_type integer,
    operating_point numeric(9,2),
    placement_of_actuation integer,
    placement_of_pump integer,
    pump_flow_max_single numeric(9,3),
    pump_flow_min_single numeric(9,3),
    start_level numeric(7,3),
    stop_level numeric(7,3),
    usage_current integer
);


ALTER TABLE qgep_od.pump OWNER TO postgres;

--
-- Name: COLUMN pump.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN pump.contruction_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.contruction_type IS 'Types of pumps / Pumpenarten / Types de pompe';


--
-- Name: COLUMN pump.operating_point; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.operating_point IS 'Flow for pumps with fixed operating point / Fördermenge für Pumpen mit fixem Arbeitspunkt / Débit refoulé par la pompe avec point de travail fixe';


--
-- Name: COLUMN pump.placement_of_actuation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.placement_of_actuation IS 'Type of placement of the actuation / Art der Aufstellung des Motors / Genre de montage';


--
-- Name: COLUMN pump.placement_of_pump; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.placement_of_pump IS 'Type of placement of the pomp / Art der Aufstellung der Pumpe / Genre de montage de la pompe';


--
-- Name: COLUMN pump.pump_flow_max_single; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.pump_flow_max_single IS 'yyy_Maximaler Förderstrom der Pumpen (einzeln als Bauwerkskomponente). Tritt in der Regel bei der minimalen Förderhöhe ein. / Maximaler Förderstrom der Pumpe (einzeln als Bauwerkskomponente). Tritt in der Regel bei der minimalen Förderhöhe ein. / Débit de refoulement maximal des pompes individuelles en tant que composante d’ouvrage. Survient normalement à la hauteur min de refoulement.';


--
-- Name: COLUMN pump.pump_flow_min_single; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.pump_flow_min_single IS 'yyy_Minimaler Förderstrom der Pumpe (einzeln als Bauwerkskomponente). Tritt in der Regel bei der maximalen Förderhöhe ein. / Minimaler Förderstrom der Pumpe (einzeln als Bauwerkskomponente). Tritt in der Regel bei der maximalen Förderhöhe ein. / Débit de refoulement maximal de toutes les pompes de l’ouvrage (STAP) ou des pompes individuelles en tant que composante d’ouvrage. Survient normalement à la hauteur min de refoulement.';


--
-- Name: COLUMN pump.start_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.start_level IS 'yyy_Kote des Wasserspiegels im Pumpensumpf, bei der die Pumpe eingeschaltet wird (Einschaltkote) / Kote des Wasserspiegels im Pumpensumpf, bei der die Pumpe eingeschaltet wird (Einschaltkote) / Cote du niveau d''eau dans le puisard à laquelle s''enclenche la pompe';


--
-- Name: COLUMN pump.stop_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.stop_level IS 'yyy_Kote des Wasserspiegels im Pumpensumpf, bei der die Pumpe ausgeschaltet wird (Ausschaltkote) / Kote des Wasserspiegels im Pumpensumpf, bei der die Pumpe ausgeschaltet wird (Ausschaltkote) / Cote du niveau d''eau dans le puisard à laquelle s''arrête la pompe';


--
-- Name: COLUMN pump.usage_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.pump.usage_current IS 'yyy_Nutzungsart_Ist des gepumpten Abwassers. / Nutzungsart_Ist des gepumpten Abwassers. / Genre d''utilisation actuel de l''eau usée pompée';


--
-- Name: re_maintenance_event_wastewater_structure; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.re_maintenance_event_wastewater_structure (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 're_maintenance_event_wastewater_structure'::text) NOT NULL,
    fk_wastewater_structure character varying(16),
    fk_maintenance_event character varying(16)
);


ALTER TABLE qgep_od.re_maintenance_event_wastewater_structure OWNER TO postgres;

--
-- Name: COLUMN re_maintenance_event_wastewater_structure.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.re_maintenance_event_wastewater_structure.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: reach; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.reach (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'reach'::text) NOT NULL,
    clear_height integer,
    coefficient_of_friction smallint,
    elevation_determination integer,
    horizontal_positioning integer,
    inside_coating integer,
    length_effective numeric(7,2),
    material integer,
    progression_geometry public.geometry(CompoundCurveZ,2056),
    reliner_material integer,
    reliner_nominal_size integer,
    relining_construction integer,
    relining_kind integer,
    ring_stiffness smallint,
    slope_building_plan smallint,
    wall_roughness numeric(5,2),
    fk_reach_point_from character varying(16),
    fk_reach_point_to character varying(16),
    fk_pipe_profile character varying(16)
);


ALTER TABLE qgep_od.reach OWNER TO postgres;

--
-- Name: COLUMN reach.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN reach.clear_height; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.clear_height IS 'Maximal height (inside) of profile / Maximale Innenhöhe des Kanalprofiles / Hauteur intérieure maximale du profil';


--
-- Name: COLUMN reach.coefficient_of_friction; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.coefficient_of_friction IS 'yyy http://www.linguee.com/english-german/search?source=auto&query=reibungsbeiwert / Hydraulische Kenngrösse zur Beschreibung der Beschaffenheit der Kanalwandung. Beiwert für die Formeln nach Manning-Strickler (K oder kstr) / Constante de rugosité selon Manning-Strickler (K ou kstr)';


--
-- Name: COLUMN reach.elevation_determination; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.elevation_determination IS 'yyy_Definiert die Hoehenbestimmung einer Haltung. / Definiert die Hoehenbestimmung einer Haltung. / Définition de la détermination altimétrique d''un tronçon.';


--
-- Name: COLUMN reach.horizontal_positioning; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.horizontal_positioning IS 'yyy_Definiert die Lagegenauigkeit der Verlaufspunkte. / Definiert die Lagegenauigkeit der Verlaufspunkte. / Définit la précision de la détermination du tracé.';


--
-- Name: COLUMN reach.inside_coating; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.inside_coating IS 'yyy_Schutz der Innenwände des Kanals / Schutz der Innenwände des Kanals / Protection de la paroi intérieur de la canalisation';


--
-- Name: COLUMN reach.length_effective; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.length_effective IS 'yyy_Tatsächliche schräge Länge (d.h. nicht in horizontale Ebene projiziert)  inklusive Kanalkrümmungen / Tatsächliche schräge Länge (d.h. nicht in horizontale Ebene projiziert)  inklusive Kanalkrümmungen / Longueur effective (non projetée) incluant les parties incurvées';


--
-- Name: COLUMN reach.material; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.material IS 'Material of reach / pipe / Rohrmaterial / Matériau du tuyau';


--
-- Name: COLUMN reach.progression_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.progression_geometry IS 'Start, inflextion and endpoints of a pipe / Anfangs-, Knick- und Endpunkte der Leitung / Points de départ, intermédiaires et d’arrivée de la conduite.';


--
-- Name: COLUMN reach.reliner_material; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.reliner_material IS 'Material of reliner / Material des Reliners / Materiaux du relining';


--
-- Name: COLUMN reach.reliner_nominal_size; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.reliner_nominal_size IS 'yyy_Profilhöhe des Inliners (innen). Beim Export in Hydrauliksoftware müsste dieser Wert statt Haltung.Lichte_Hoehe übernommen werden um korrekt zu simulieren. / Profilhöhe des Inliners (innen). Beim Export in Hydrauliksoftware müsste dieser Wert statt Haltung.Lichte_Hoehe übernommen werden um korrekt zu simulieren. / Hauteur intérieure maximale du profil de l''inliner. A l''export dans le software hydraulique il faut utiliser cette attribut au lieu de HAUTEUR_MAX_PROFIL';


--
-- Name: COLUMN reach.relining_construction; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.relining_construction IS 'yyy_Bautechnik für das Relining. Zusätzlich wird der Einbau des Reliners als  Erhaltungsereignis abgebildet: Erhaltungsereignis.Art = Reparatur für Partieller_Liner, sonst Renovierung. / Bautechnik für das Relining. Zusätzlich wird der Einbau des Reliners als  Erhaltungsereignis abgebildet: Erhaltungsereignis.Art = Reparatur für Partieller_Liner, sonst Renovierung. / Relining technique de construction. En addition la construction du reliner doit être modeler comme événement maintenance: Genre = reparation pour liner_partiel, autrement genre = renovation.';


--
-- Name: COLUMN reach.relining_kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.relining_kind IS 'Kind of relining / Art des Relinings / Genre du relining';


--
-- Name: COLUMN reach.ring_stiffness; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.ring_stiffness IS 'yyy Ringsteifigkeitsklasse - Druckfestigkeit gegen Belastungen von aussen (gemäss ISO 13966 ) / Ringsteifigkeitsklasse - Druckfestigkeit gegen Belastungen von aussen (gemäss ISO 13966 ) / Rigidité annulaire pour des pressions extérieures (selon ISO 13966)';


--
-- Name: COLUMN reach.slope_building_plan; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.slope_building_plan IS 'yyy_Auf dem alten Plan eingezeichnetes Plangefälle [%o]. Nicht kontrolliert im Feld. Kann nicht für die hydraulische Berechnungen übernommen werden. Für Liegenschaftsentwässerung und Meliorationsleitungen. Darstellung als z.B. 3.5%oP auf Plänen. / Auf dem alten Plan eingezeichnetes Plangefälle [%o]. Nicht kontrolliert im Feld. Kann nicht für die hydraulische Berechnungen übernommen werden. Für Liegenschaftsentwässerung und Meliorationsleitungen. Darstellung als z.B. 3.5%oP auf Plänen. / Pente indiquée sur d''anciens plans non contrôlée [%o]. Ne peut pas être reprise pour des calculs hydrauliques. Indication pour des canalisations de biens-fonds ou d''amélioration foncière. Représentation sur de plan: 3.5‰ p';


--
-- Name: COLUMN reach.wall_roughness; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach.wall_roughness IS 'yyy Hydraulische Kenngrösse zur Beschreibung der Beschaffenheit der Kanalwandung. Beiwert für die Formeln nach Prandtl-Colebrook (ks oder kb) / Hydraulische Kenngrösse zur Beschreibung der Beschaffenheit der Kanalwandung. Beiwert für die Formeln nach Prandtl-Colebrook (ks oder kb) / Coefficient de rugosité d''après Prandtl Colebrook (ks ou kb)';


--
-- Name: reach_point; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.reach_point (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'reach_point'::text) NOT NULL,
    elevation_accuracy integer,
    identifier character varying(20),
    level numeric(7,3),
    outlet_shape integer,
    position_of_connection smallint,
    remark character varying(80),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_networkelement character varying(16)
);


ALTER TABLE qgep_od.reach_point OWNER TO postgres;

--
-- Name: COLUMN reach_point.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN reach_point.elevation_accuracy; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.elevation_accuracy IS 'yyy_Quantifizierung der Genauigkeit der Höhenlage der Kote in Relation zum Höhenfixpunktnetz (z.B. Grundbuchvermessung oder Landesnivellement). / Quantifizierung der Genauigkeit der Höhenlage der Kote in Relation zum Höhenfixpunktnetz (z.B. Grundbuchvermessung oder Landesnivellement). / Plage de précision des coordonnées altimétriques du point de tronçon';


--
-- Name: COLUMN reach_point.level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.level IS 'yyy_Sohlenhöhe des Haltungsendes / Sohlenhöhe des Haltungsendes / Cote du radier de la fin du tronçon';


--
-- Name: COLUMN reach_point.outlet_shape; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.outlet_shape IS 'Kind of outlet shape / Art des Auslaufs / Types de sortie';


--
-- Name: COLUMN reach_point.position_of_connection; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.position_of_connection IS 'yyy_Anschlussstelle bezogen auf Querschnitt im Kanal; in Fliessrichtung  (für Haus- und Strassenanschlüsse) / Anschlussstelle bezogen auf Querschnitt im Kanal; in Fliessrichtung  (für Haus- und Strassenanschlüsse) / Emplacement de raccordement Référence à la section transversale dans le canal dans le sens d’écoulement (pour les raccordements domestiques et de rue).';


--
-- Name: COLUMN reach_point.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN reach_point.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: COLUMN reach_point.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN reach_point.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN reach_point.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_point.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: reach_text; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.reach_text (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'reach_text'::text) NOT NULL,
    plantype integer,
    remark character varying(80),
    text text,
    texthali smallint,
    textori numeric(4,1),
    textpos_geometry public.geometry(Point,2056),
    textvali smallint,
    last_modification timestamp without time zone DEFAULT now(),
    fk_reach character varying(16)
);


ALTER TABLE qgep_od.reach_text OWNER TO postgres;

--
-- Name: COLUMN reach_text.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_text.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN reach_text.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_text.remark IS 'General remarks';


--
-- Name: COLUMN reach_text.text; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_text.text IS 'yyy_Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / valeur calculée à partir d’attributs, plusieurs lignes possible';


--
-- Name: COLUMN reach_text.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reach_text.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: reservoir; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.reservoir (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'reservoir'::text) NOT NULL,
    location_name character varying(50),
    situation_geometry public.geometry(Point,2056)
);


ALTER TABLE qgep_od.reservoir OWNER TO postgres;

--
-- Name: COLUMN reservoir.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reservoir.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN reservoir.location_name; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reservoir.location_name IS 'Street name or name of the location / Strassenname oder Ortsbezeichnung / Nom de la route ou du lieu';


--
-- Name: COLUMN reservoir.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.reservoir.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: retention_body; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.retention_body (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'retention_body'::text) NOT NULL,
    identifier character varying(20),
    kind integer,
    remark character varying(80),
    volume numeric(9,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_infiltration_installation character varying(16)
);


ALTER TABLE qgep_od.retention_body OWNER TO postgres;

--
-- Name: COLUMN retention_body.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.retention_body.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN retention_body.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.retention_body.kind IS 'Type of retention / Arten der Retention / Genre de rétention';


--
-- Name: COLUMN retention_body.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.retention_body.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN retention_body.volume; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.retention_body.volume IS 'yyy_Nutzbares Volumen des Retentionskörpers / Nutzbares Volumen des Retentionskörpers / Volume effectif du volume de rétention';


--
-- Name: COLUMN retention_body.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.retention_body.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN retention_body.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.retention_body.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN retention_body.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.retention_body.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: river; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.river (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'river'::text) NOT NULL,
    kind integer
);


ALTER TABLE qgep_od.river OWNER TO postgres;

--
-- Name: COLUMN river.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN river.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river.kind IS 'yyy_Art des Fliessgewässers. Klassifizierung nach GEWISS / Art des Fliessgewässers. Klassifizierung nach GEWISS / Type de cours d''eau. Classification selon GEWISS';


--
-- Name: river_bank; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.river_bank (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'river_bank'::text) NOT NULL,
    control_grade_of_river integer,
    identifier character varying(20),
    remark character varying(80),
    river_control_type integer,
    shores integer,
    side integer,
    utilisation_of_shore_surroundings integer,
    vegetation integer,
    width numeric(7,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_water_course_segment character varying(16)
);


ALTER TABLE qgep_od.river_bank OWNER TO postgres;

--
-- Name: COLUMN river_bank.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN river_bank.control_grade_of_river; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.control_grade_of_river IS 'yyy_Flächenhafter Verbauungsgrad des Böschungsfusses in %. Aufteilung in Klassen. / Flächenhafter Verbauungsgrad des Böschungsfusses in %. Aufteilung in Klassen. / Degré d''aménagement du pied du talus du cours d''eau';


--
-- Name: COLUMN river_bank.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN river_bank.river_control_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.river_control_type IS 'yyy_Verbauungsart des Böschungsfusses / Verbauungsart des Böschungsfusses / Genre d''aménagement du pied de la berge du cours d''eau';


--
-- Name: COLUMN river_bank.shores; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.shores IS 'yyy_Beschaffenheit des Bereiches oberhalb des Böschungsfusses / Beschaffenheit des Bereiches oberhalb des Böschungsfusses / Nature de la zone en dessus du pied de la berge du cours d''eau';


--
-- Name: COLUMN river_bank.side; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.side IS 'yyy_Linke oder rechte Uferseite in Fliessrichtung / Linke oder rechte Uferseite in Fliessrichtung / Berges sur le côté gauche ou droite du cours d''eau par rapport au sens d''écoulement';


--
-- Name: COLUMN river_bank.utilisation_of_shore_surroundings; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.utilisation_of_shore_surroundings IS 'yyy_Nutzung des Gewässerumlandes / Nutzung des Gewässerumlandes / Utilisation du sol des environs';


--
-- Name: COLUMN river_bank.width; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.width IS 'yyy_Breite des Bereiches oberhalb des Böschungsfusses bis zum Gebiet mit "intensiver Landnutzung" / Breite des Bereiches oberhalb des Böschungsfusses bis zum Gebiet mit "intensiver Landnutzung" / Distance horizontale de la zone comprise entre le pied de la berge et la zone d''utilisation intensive du sol';


--
-- Name: COLUMN river_bank.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN river_bank.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN river_bank.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bank.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: river_bed; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.river_bed (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'river_bed'::text) NOT NULL,
    control_grade_of_river integer,
    identifier character varying(20),
    kind integer,
    remark character varying(80),
    river_control_type integer,
    width numeric(7,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_water_course_segment character varying(16)
);


ALTER TABLE qgep_od.river_bed OWNER TO postgres;

--
-- Name: COLUMN river_bed.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN river_bed.control_grade_of_river; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.control_grade_of_river IS 'yyy_Flächenhafter Verbauungsgrad der Gewässersohle in %. Aufteilung in Klassen. / Flächenhafter Verbauungsgrad der Gewässersohle in %. Aufteilung in Klassen. / Pourcentage de la surface avec aménagement du fond du lit. Classification';


--
-- Name: COLUMN river_bed.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.kind IS 'type of bed / Sohlentyp / Type de fond';


--
-- Name: COLUMN river_bed.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN river_bed.river_control_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.river_control_type IS 'Type of river control / Art des Sohlenverbaus / Genre d''aménagement du fond';


--
-- Name: COLUMN river_bed.width; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.width IS 'yyy_Bei Hochwasser umgelagerter Bereich (frei von höheren Wasserpflanzen) / Bei Hochwasser umgelagerter Bereich (frei von höheren Wasserpflanzen) / Zone de charriage par hautes eaux (absence de plantes aquatiques supérieures)';


--
-- Name: COLUMN river_bed.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN river_bed.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN river_bed.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.river_bed.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: rock_ramp; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.rock_ramp (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'rock_ramp'::text) NOT NULL,
    stabilisation integer,
    vertical_drop numeric(7,2)
);


ALTER TABLE qgep_od.rock_ramp OWNER TO postgres;

--
-- Name: COLUMN rock_ramp.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.rock_ramp.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN rock_ramp.stabilisation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.rock_ramp.stabilisation IS 'Type of stabilisation of rock ramp / Befestigungsart der Sohlrampe / Genre de consolidation de la rampe';


--
-- Name: COLUMN rock_ramp.vertical_drop; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.rock_ramp.vertical_drop IS 'Vertical difference of water level before and after chute / Differenz des Wasserspiegels vor und nach dem Absturz / Différence de la hauteur du plan d''eau avant et après la chute';


--
-- Name: sector_water_body; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.sector_water_body (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'sector_water_body'::text) NOT NULL,
    code_bwg character varying(50),
    identifier character varying(20),
    kind integer,
    km_down numeric(9,3),
    km_up numeric(9,3),
    progression_geometry public.geometry(CompoundCurve,2056),
    ref_length numeric(7,2),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_chute character varying(16)
);


ALTER TABLE qgep_od.sector_water_body OWNER TO postgres;

--
-- Name: COLUMN sector_water_body.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN sector_water_body.code_bwg; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.code_bwg IS 'Code as published by the Federal Office for Water and Geology (FOWG) / Code gemäss Format des Bundesamtes für Wasser und Geologie (BWG) / Code selon le format de l''Office fédéral des eaux et de la géologie (OFEG)';


--
-- Name: COLUMN sector_water_body.identifier; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.identifier IS 'yyy_Eindeutiger Name des Sektors, ID des Bundesamtes für Wasserwirtschaft  und Geologie (BWG, früher BWW) falls Sektor von diesem bezogen wurde. / Eindeutiger Name des Sektors, ID des Bundesamtes für Wasserwirtschaft  und Geologie (BWG, früher BWW) falls Sektor von diesem bezogen wurde. / Nom univoque du secteur, identificateur de l''office fédéral des eaux et de la géologie (OFEG, anciennement OFEE) si existant';


--
-- Name: COLUMN sector_water_body.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.kind IS 'Shore or water course line. Important to distinguish lake traversals and waterbodies / Ufer oder Gewässerlinie. Zur Unterscheidung der Seesektoren wichtig. / Rives ou limites d''eau. Permet la différenciation des différents secteurs d''un lac ou cours d''eau';


--
-- Name: COLUMN sector_water_body.km_down; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.km_down IS 'yyy_Adresskilometer beim Sektorende (nur definieren, falls es sich um den letzten Sektor handelt oder ein Sprung in der Adresskilometrierung von einem Sektor zum nächsten  existiert) / Adresskilometer beim Sektorende (nur definieren, falls es sich um den letzten Sektor handelt oder ein Sprung in der Adresskilometrierung von einem Sektor zum nächsten  existiert) / Kilomètre de la fin du secteur (à définir uniquement s''il s''agit du dernier secteur ou lors d''un saut dans le kilométrage d''un secteur à un autre)';


--
-- Name: COLUMN sector_water_body.km_up; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.km_up IS 'yyy_Adresskilometer beim Sektorbeginn / Adresskilometer beim Sektorbeginn / Kilomètre du début du secteur';


--
-- Name: COLUMN sector_water_body.progression_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.progression_geometry IS 'yyy_Reihenfolge von Punkten die den Verlauf eines Gewässersektors beschreiben / Reihenfolge von Punkten die den Verlauf eines Gewässersektors beschreiben / Suite de points qui décrivent le tracé d''un secteur d''un cours d''eau';


--
-- Name: COLUMN sector_water_body.ref_length; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.ref_length IS 'yyy_Basislänge in Zusammenhang mit der Gewässerkilometrierung (siehe GEWISS - SYSEAU) / Basislänge in Zusammenhang mit der Gewässerkilometrierung (siehe GEWISS - SYSEAU) / Longueur de référence pour ce kilométrage des cours d''eau (voir GEWISS - SYSEAU)';


--
-- Name: COLUMN sector_water_body.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN sector_water_body.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN sector_water_body.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN sector_water_body.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sector_water_body.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: seq_access_aid_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_access_aid_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_access_aid_oid OWNER TO postgres;

--
-- Name: seq_accident_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_accident_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_accident_oid OWNER TO postgres;

--
-- Name: seq_administrative_office_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_administrative_office_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_administrative_office_oid OWNER TO postgres;

--
-- Name: seq_aquifier_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_aquifier_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_aquifier_oid OWNER TO postgres;

--
-- Name: seq_backflow_prevention_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_backflow_prevention_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_backflow_prevention_oid OWNER TO postgres;

--
-- Name: seq_bathing_area_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_bathing_area_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_bathing_area_oid OWNER TO postgres;

--
-- Name: seq_benching_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_benching_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_benching_oid OWNER TO postgres;

--
-- Name: seq_blocking_debris_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_blocking_debris_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_blocking_debris_oid OWNER TO postgres;

--
-- Name: seq_building_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_building_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_building_oid OWNER TO postgres;

--
-- Name: seq_canton_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_canton_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_canton_oid OWNER TO postgres;

--
-- Name: seq_catchment_area_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_catchment_area_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_catchment_area_oid OWNER TO postgres;

--
-- Name: seq_catchment_area_text_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_catchment_area_text_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_catchment_area_text_oid OWNER TO postgres;

--
-- Name: seq_channel_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_channel_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_channel_oid OWNER TO postgres;

--
-- Name: seq_chute_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_chute_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_chute_oid OWNER TO postgres;

--
-- Name: seq_connection_object_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_connection_object_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_connection_object_oid OWNER TO postgres;

--
-- Name: seq_control_center_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_control_center_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_control_center_oid OWNER TO postgres;

--
-- Name: seq_cooperative_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_cooperative_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_cooperative_oid OWNER TO postgres;

--
-- Name: seq_cover_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_cover_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_cover_oid OWNER TO postgres;

--
-- Name: seq_dam_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_dam_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_dam_oid OWNER TO postgres;

--
-- Name: seq_damage_channel_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_damage_channel_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_damage_channel_oid OWNER TO postgres;

--
-- Name: seq_damage_manhole_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_damage_manhole_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_damage_manhole_oid OWNER TO postgres;

--
-- Name: seq_damage_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_damage_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_damage_oid OWNER TO postgres;

--
-- Name: seq_data_media_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_data_media_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_data_media_oid OWNER TO postgres;

--
-- Name: seq_discharge_point_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_discharge_point_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_discharge_point_oid OWNER TO postgres;

--
-- Name: seq_drainage_system_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_drainage_system_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_drainage_system_oid OWNER TO postgres;

--
-- Name: seq_dryweather_downspout_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_dryweather_downspout_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_dryweather_downspout_oid OWNER TO postgres;

--
-- Name: seq_dryweather_flume_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_dryweather_flume_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_dryweather_flume_oid OWNER TO postgres;

--
-- Name: seq_electric_equipment_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_electric_equipment_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_electric_equipment_oid OWNER TO postgres;

--
-- Name: seq_electromechanical_equipment_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_electromechanical_equipment_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_electromechanical_equipment_oid OWNER TO postgres;

--
-- Name: seq_examination_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_examination_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_examination_oid OWNER TO postgres;

--
-- Name: seq_file_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_file_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_file_oid OWNER TO postgres;

--
-- Name: seq_fish_pass_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_fish_pass_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_fish_pass_oid OWNER TO postgres;

--
-- Name: seq_ford_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_ford_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_ford_oid OWNER TO postgres;

--
-- Name: seq_fountain_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_fountain_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_fountain_oid OWNER TO postgres;

--
-- Name: seq_ground_water_protection_perimeter_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_ground_water_protection_perimeter_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_ground_water_protection_perimeter_oid OWNER TO postgres;

--
-- Name: seq_groundwater_protection_zone_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_groundwater_protection_zone_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_groundwater_protection_zone_oid OWNER TO postgres;

--
-- Name: seq_hazard_source_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_hazard_source_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_hazard_source_oid OWNER TO postgres;

--
-- Name: seq_hq_relation_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_hq_relation_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_hq_relation_oid OWNER TO postgres;

--
-- Name: seq_hydr_geom_relation_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_hydr_geom_relation_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_hydr_geom_relation_oid OWNER TO postgres;

--
-- Name: seq_hydr_geometry_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_hydr_geometry_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_hydr_geometry_oid OWNER TO postgres;

--
-- Name: seq_hydraulic_char_data_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_hydraulic_char_data_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_hydraulic_char_data_oid OWNER TO postgres;

--
-- Name: seq_individual_surface_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_individual_surface_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_individual_surface_oid OWNER TO postgres;

--
-- Name: seq_infiltration_installation_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_infiltration_installation_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_infiltration_installation_oid OWNER TO postgres;

--
-- Name: seq_infiltration_zone_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_infiltration_zone_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_infiltration_zone_oid OWNER TO postgres;

--
-- Name: seq_lake_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_lake_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_lake_oid OWNER TO postgres;

--
-- Name: seq_leapingweir_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_leapingweir_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_leapingweir_oid OWNER TO postgres;

--
-- Name: seq_lock_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_lock_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_lock_oid OWNER TO postgres;

--
-- Name: seq_maintenance_event_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_maintenance_event_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_maintenance_event_oid OWNER TO postgres;

--
-- Name: seq_manhole_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_manhole_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_manhole_oid OWNER TO postgres;

--
-- Name: seq_measurement_result_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_measurement_result_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_measurement_result_oid OWNER TO postgres;

--
-- Name: seq_measurement_series_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_measurement_series_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_measurement_series_oid OWNER TO postgres;

--
-- Name: seq_measuring_device_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_measuring_device_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_measuring_device_oid OWNER TO postgres;

--
-- Name: seq_measuring_point_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_measuring_point_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_measuring_point_oid OWNER TO postgres;

--
-- Name: seq_mechanical_pretreatment_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_mechanical_pretreatment_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_mechanical_pretreatment_oid OWNER TO postgres;

--
-- Name: seq_municipality_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_municipality_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_municipality_oid OWNER TO postgres;

--
-- Name: seq_mutation_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_mutation_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_mutation_oid OWNER TO postgres;

--
-- Name: seq_organisation_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_organisation_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_organisation_oid OWNER TO postgres;

--
-- Name: seq_overflow_char_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_overflow_char_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_overflow_char_oid OWNER TO postgres;

--
-- Name: seq_overflow_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_overflow_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_overflow_oid OWNER TO postgres;

--
-- Name: seq_param_ca_general_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_param_ca_general_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_param_ca_general_oid OWNER TO postgres;

--
-- Name: seq_param_ca_mouse1_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_param_ca_mouse1_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_param_ca_mouse1_oid OWNER TO postgres;

--
-- Name: seq_passage_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_passage_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_passage_oid OWNER TO postgres;

--
-- Name: seq_pipe_profile_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_pipe_profile_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_pipe_profile_oid OWNER TO postgres;

--
-- Name: seq_planning_zone_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_planning_zone_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_planning_zone_oid OWNER TO postgres;

--
-- Name: seq_prank_weir_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_prank_weir_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_prank_weir_oid OWNER TO postgres;

--
-- Name: seq_private_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_private_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_private_oid OWNER TO postgres;

--
-- Name: seq_profile_geometry_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_profile_geometry_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_profile_geometry_oid OWNER TO postgres;

--
-- Name: seq_pump_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_pump_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_pump_oid OWNER TO postgres;

--
-- Name: seq_re_maintenance_event_wastewater_structure_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_re_maintenance_event_wastewater_structure_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_re_maintenance_event_wastewater_structure_oid OWNER TO postgres;

--
-- Name: seq_reach_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_reach_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_reach_oid OWNER TO postgres;

--
-- Name: seq_reach_point_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_reach_point_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_reach_point_oid OWNER TO postgres;

--
-- Name: seq_reach_text_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_reach_text_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_reach_text_oid OWNER TO postgres;

--
-- Name: seq_reservoir_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_reservoir_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_reservoir_oid OWNER TO postgres;

--
-- Name: seq_retention_body_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_retention_body_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_retention_body_oid OWNER TO postgres;

--
-- Name: seq_river_bank_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_river_bank_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_river_bank_oid OWNER TO postgres;

--
-- Name: seq_river_bed_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_river_bed_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_river_bed_oid OWNER TO postgres;

--
-- Name: seq_river_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_river_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_river_oid OWNER TO postgres;

--
-- Name: seq_rock_ramp_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_rock_ramp_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_rock_ramp_oid OWNER TO postgres;

--
-- Name: seq_sector_water_body_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_sector_water_body_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_sector_water_body_oid OWNER TO postgres;

--
-- Name: seq_sludge_treatment_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_sludge_treatment_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_sludge_treatment_oid OWNER TO postgres;

--
-- Name: seq_solids_retention_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_solids_retention_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_solids_retention_oid OWNER TO postgres;

--
-- Name: seq_special_structure_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_special_structure_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_special_structure_oid OWNER TO postgres;

--
-- Name: seq_structure_part_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_structure_part_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_structure_part_oid OWNER TO postgres;

--
-- Name: seq_substance_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_substance_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_substance_oid OWNER TO postgres;

--
-- Name: seq_surface_runoff_parameters_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_surface_runoff_parameters_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_surface_runoff_parameters_oid OWNER TO postgres;

--
-- Name: seq_surface_water_bodies_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_surface_water_bodies_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_surface_water_bodies_oid OWNER TO postgres;

--
-- Name: seq_tank_cleaning_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_tank_cleaning_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_tank_cleaning_oid OWNER TO postgres;

--
-- Name: seq_tank_emptying_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_tank_emptying_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_tank_emptying_oid OWNER TO postgres;

--
-- Name: seq_throttle_shut_off_unit_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_throttle_shut_off_unit_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_throttle_shut_off_unit_oid OWNER TO postgres;

--
-- Name: seq_txt_symbol_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_txt_symbol_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_txt_symbol_oid OWNER TO postgres;

--
-- Name: seq_txt_text_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_txt_text_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_txt_text_oid OWNER TO postgres;

--
-- Name: seq_waste_water_association_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_waste_water_association_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_waste_water_association_oid OWNER TO postgres;

--
-- Name: seq_waste_water_treatment_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_waste_water_treatment_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_waste_water_treatment_oid OWNER TO postgres;

--
-- Name: seq_waste_water_treatment_plant_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_waste_water_treatment_plant_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_waste_water_treatment_plant_oid OWNER TO postgres;

--
-- Name: seq_wastewater_networkelement_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_wastewater_networkelement_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_wastewater_networkelement_oid OWNER TO postgres;

--
-- Name: seq_wastewater_node_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_wastewater_node_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_wastewater_node_oid OWNER TO postgres;

--
-- Name: seq_wastewater_structure_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_wastewater_structure_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_wastewater_structure_oid OWNER TO postgres;

--
-- Name: seq_wastewater_structure_symbol_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_wastewater_structure_symbol_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_wastewater_structure_symbol_oid OWNER TO postgres;

--
-- Name: seq_wastewater_structure_text_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_wastewater_structure_text_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_wastewater_structure_text_oid OWNER TO postgres;

--
-- Name: seq_water_body_protection_sector_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_water_body_protection_sector_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_water_body_protection_sector_oid OWNER TO postgres;

--
-- Name: seq_water_catchment_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_water_catchment_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_water_catchment_oid OWNER TO postgres;

--
-- Name: seq_water_control_structure_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_water_control_structure_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_water_control_structure_oid OWNER TO postgres;

--
-- Name: seq_water_course_segment_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_water_course_segment_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_water_course_segment_oid OWNER TO postgres;

--
-- Name: seq_wwtp_energy_use_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_wwtp_energy_use_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_wwtp_energy_use_oid OWNER TO postgres;

--
-- Name: seq_wwtp_structure_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_wwtp_structure_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_wwtp_structure_oid OWNER TO postgres;

--
-- Name: seq_zone_oid; Type: SEQUENCE; Schema: qgep_od; Owner: postgres
--

CREATE SEQUENCE qgep_od.seq_zone_oid
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE qgep_od.seq_zone_oid OWNER TO postgres;

--
-- Name: sludge_treatment; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.sludge_treatment (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'sludge_treatment'::text) NOT NULL,
    composting numeric(7,2),
    dehydration numeric(7,2),
    digested_sludge_combustion numeric(7,2),
    drying numeric(7,2),
    fresh_sludge_combustion numeric(7,2),
    hygenisation numeric(7,2),
    identifier character varying(20),
    predensification_of_excess_sludge numeric(9,2),
    predensification_of_mixed_sludge numeric(9,2),
    predensification_of_primary_sludge numeric(9,2),
    remark character varying(80),
    stabilisation integer,
    stacking_of_dehydrated_sludge numeric(9,2),
    stacking_of_liquid_sludge numeric(9,2),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_waste_water_treatment_plant character varying(16)
);


ALTER TABLE qgep_od.sludge_treatment OWNER TO postgres;

--
-- Name: COLUMN sludge_treatment.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN sludge_treatment.composting; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.composting IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.dehydration; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.dehydration IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.digested_sludge_combustion; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.digested_sludge_combustion IS 'yyy_Dimensioning value der Verbrennungsanlage / Dimensionierungswert der Verbrennungsanlage / Valeur de dimensionnement de l''installation d''incinération';


--
-- Name: COLUMN sludge_treatment.drying; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.drying IS 'yyy_Leistung thermische Trocknung / Leistung thermische Trocknung / Puissance du séchage thermique';


--
-- Name: COLUMN sludge_treatment.fresh_sludge_combustion; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.fresh_sludge_combustion IS 'yyy_Dimensioning value der Verbrennungsanlage / Dimensionierungswert der Verbrennungsanlage / Valeur de dimensionnement de l''installation d''incinération';


--
-- Name: COLUMN sludge_treatment.hygenisation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.hygenisation IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.predensification_of_excess_sludge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.predensification_of_excess_sludge IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.predensification_of_mixed_sludge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.predensification_of_mixed_sludge IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.predensification_of_primary_sludge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.predensification_of_primary_sludge IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN sludge_treatment.stabilisation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.stabilisation IS 'yyy_Art der Schlammstabilisierung / Art der Schlammstabilisierung / Type de stabilisation des boues';


--
-- Name: COLUMN sludge_treatment.stacking_of_dehydrated_sludge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.stacking_of_dehydrated_sludge IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.stacking_of_liquid_sludge; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.stacking_of_liquid_sludge IS 'Dimensioning value / Dimensionierungswert / Valeur de dimensionnement';


--
-- Name: COLUMN sludge_treatment.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN sludge_treatment.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN sludge_treatment.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.sludge_treatment.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: solids_retention; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.solids_retention (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'solids_retention'::text) NOT NULL,
    dimensioning_value numeric(9,3),
    gross_costs numeric(10,2),
    overflow_level numeric(7,3),
    type integer,
    year_of_replacement smallint
);


ALTER TABLE qgep_od.solids_retention OWNER TO postgres;

--
-- Name: COLUMN solids_retention.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.solids_retention.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN solids_retention.dimensioning_value; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.solids_retention.dimensioning_value IS 'yyy_Wassermenge, Dimensionierungswert des Feststoffrückhaltes / Wassermenge, Dimensionierungswert des Feststoffrückhaltes / Volume, débit de dimensionnement';


--
-- Name: COLUMN solids_retention.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.solids_retention.gross_costs IS 'Gross costs of electromechanical equipment / Brutto Erstellungskosten der elektromechnischen Ausrüstung für die Beckenentleerung / Coûts bruts des équipements électromécaniques';


--
-- Name: COLUMN solids_retention.overflow_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.solids_retention.overflow_level IS 'Overflow level of solids retention in in m.a.sl. / Anspringkote Feststoffrückhalt in m.ü.M. / Cote du début du déversement de la retenue de matières solides en m.s.m.';


--
-- Name: COLUMN solids_retention.type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.solids_retention.type IS 'yyy_(Elektromechanische) Teile zum Feststoffrückhalt eines Bauwerks / (Elektromechanische) Teile zum Feststoffrückhalt eines Bauwerks / Eléments (électromécaniques) pour la retenue de matières solides d’un ouvrage';


--
-- Name: COLUMN solids_retention.year_of_replacement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.solids_retention.year_of_replacement IS 'yyy_Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Année pour laquelle on prévoit que la durée de vie de l''équipement soit écoulée';


--
-- Name: special_structure; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.special_structure (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'special_structure'::text) NOT NULL,
    bypass integer,
    emergency_spillway integer,
    function integer,
    stormwater_tank_arrangement integer,
    upper_elevation numeric(7,3)
);


ALTER TABLE qgep_od.special_structure OWNER TO postgres;

--
-- Name: COLUMN special_structure.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.special_structure.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN special_structure.bypass; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.special_structure.bypass IS 'yyy_Bypass zur Umleitung des Wassers (z.B. während Unterhalt oder  im Havariefall) / Bypass zur Umleitung des Wassers (z.B. während Unterhalt oder  im Havariefall) / Bypass pour détourner les eaux (par exemple durant des opérations de maintenance ou en cas d’avaries)';


--
-- Name: COLUMN special_structure.emergency_spillway; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.special_structure.emergency_spillway IS 'zzz_Das Attribut beschreibt, wohin die das Volumen übersteigende Menge abgeleitet wird (bei Regenrückhaltebecken / Regenrückhaltekanal). / Das Attribut beschreibt, wohin die das Volumen übersteigende Menge abgeleitet wird (bei Regenrückhaltebecken / Regenrückhaltekanal). / L’attribut décrit vers où le débit déversé s’écoule. (bassin d’accumulation / canal d’accumulation)';


--
-- Name: COLUMN special_structure.function; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.special_structure.function IS 'Kind of function / Art der Nutzung / Genre d''utilisation';


--
-- Name: COLUMN special_structure.stormwater_tank_arrangement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.special_structure.stormwater_tank_arrangement IS 'yyy_Anordnung des Regenbeckens im System. Zusätzlich zu erfassen falls Spezialbauwerk.Funktion = Regenbecken_* / Anordnung des Regenbeckens im System. Zusätzlich zu erfassen falls Spezialbauwerk.Funktion = Regenbecken_* / Disposition d''un bassin d''eaux pluviales dans le réseau d''assainissement. Attribut additionnel pour les valeurs BEP_* de OUVRAGE_SPECIAL.FONCTION.';


--
-- Name: COLUMN special_structure.upper_elevation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.special_structure.upper_elevation IS 'Highest point of structure (ceiling), outside / Höchster Punkt des Bauwerks (Decke), aussen / Point le plus élevé de la construction';


--
-- Name: structure_part; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.structure_part (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'structure_part'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    renovation_demand integer,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_structure character varying(16)
);


ALTER TABLE qgep_od.structure_part OWNER TO postgres;

--
-- Name: COLUMN structure_part.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.structure_part.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN structure_part.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.structure_part.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN structure_part.renovation_demand; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.structure_part.renovation_demand IS 'yyy_Zustandsinformation zum structure_part / Zustandsinformation zum Bauwerksteil / Information sur l''état de l''élément de l''ouvrage';


--
-- Name: COLUMN structure_part.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.structure_part.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN structure_part.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.structure_part.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN structure_part.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.structure_part.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: substance; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.substance (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'substance'::text) NOT NULL,
    identifier character varying(20),
    kind character varying(50),
    remark character varying(80),
    stockage character varying(50),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_hazard_source character varying(16)
);


ALTER TABLE qgep_od.substance OWNER TO postgres;

--
-- Name: COLUMN substance.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.substance.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN substance.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.substance.kind IS 'yyy_Liste der wassergefährdenden Stoffe / Liste der wassergefährdenden Stoffe / Liste des substances de nature à polluer les eaux';


--
-- Name: COLUMN substance.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.substance.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN substance.stockage; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.substance.stockage IS 'yyy_Art der Lagerung der abwassergefährdenden Stoffe / Art der Lagerung der abwassergefährdenden Stoffe / Genre de stockage des substances dangereuses';


--
-- Name: COLUMN substance.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.substance.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN substance.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.substance.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN substance.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.substance.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: surface_runoff_parameters; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.surface_runoff_parameters (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'surface_runoff_parameters'::text) NOT NULL,
    evaporation_loss numeric(4,1),
    identifier character varying(20),
    infiltration_loss numeric(4,1),
    remark character varying(80),
    surface_storage numeric(4,1),
    wetting_loss numeric(4,1),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_catchment_area character varying(16)
);


ALTER TABLE qgep_od.surface_runoff_parameters OWNER TO postgres;

--
-- Name: COLUMN surface_runoff_parameters.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN surface_runoff_parameters.evaporation_loss; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.evaporation_loss IS 'Loss by evaporation / Verlust durch Verdunstung / Pertes par évaporation au sol';


--
-- Name: COLUMN surface_runoff_parameters.infiltration_loss; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.infiltration_loss IS 'Loss by infiltration / Verlust durch Infiltration / Pertes par infiltration';


--
-- Name: COLUMN surface_runoff_parameters.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN surface_runoff_parameters.surface_storage; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.surface_storage IS 'Loss by filing depressions in the surface / Verlust durch Muldenfüllung / Pertes par remplissage de dépressions';


--
-- Name: COLUMN surface_runoff_parameters.wetting_loss; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.wetting_loss IS 'Loss of wetting plantes and surface during rainfall / Verlust durch Haftung des Niederschlages an Pflanzen- und andere Oberfläche / Pertes par rétention des précipitations sur la végétation et autres surfaces';


--
-- Name: COLUMN surface_runoff_parameters.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN surface_runoff_parameters.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN surface_runoff_parameters.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_runoff_parameters.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: surface_water_bodies; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.surface_water_bodies (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'surface_water_bodies'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.surface_water_bodies OWNER TO postgres;

--
-- Name: COLUMN surface_water_bodies.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_water_bodies.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN surface_water_bodies.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_water_bodies.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN surface_water_bodies.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_water_bodies.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN surface_water_bodies.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_water_bodies.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN surface_water_bodies.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.surface_water_bodies.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: tank_cleaning; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.tank_cleaning (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'tank_cleaning'::text) NOT NULL,
    gross_costs numeric(10,2),
    type integer,
    year_of_replacement smallint
);


ALTER TABLE qgep_od.tank_cleaning OWNER TO postgres;

--
-- Name: COLUMN tank_cleaning.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.tank_cleaning.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN tank_cleaning.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.tank_cleaning.gross_costs IS 'Gross costs of electromechanical equipment of tank cleaning / Brutto Erstellungskosten der elektromechnischen Ausrüstung für die Beckenreinigung / Coûts bruts des équipements électromécaniques nettoyage de bassins';


--
-- Name: COLUMN tank_cleaning.year_of_replacement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.tank_cleaning.year_of_replacement IS 'yyy_Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Année pour laquelle on prévoit que la durée de vie de l''équipement soit écoulée';


--
-- Name: tank_emptying; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.tank_emptying (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'tank_emptying'::text) NOT NULL,
    flow numeric(9,3),
    gross_costs numeric(10,2),
    type integer,
    year_of_replacement smallint,
    fk_throttle_shut_off_unit character varying(16),
    fk_overflow character varying(16)
);


ALTER TABLE qgep_od.tank_emptying OWNER TO postgres;

--
-- Name: COLUMN tank_emptying.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.tank_emptying.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN tank_emptying.flow; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.tank_emptying.flow IS 'yyy_Bei mehreren Pumpen / Schiebern muss die maximale Gesamtmenge erfasst werden. / Bei mehreren Pumpen / Schiebern muss die maximale Gesamtmenge erfasst werden. / Lors de présence de plusieurs pompes/vannes, indiquer le débit total.';


--
-- Name: COLUMN tank_emptying.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.tank_emptying.gross_costs IS 'Gross costs of electromechanical equipment of tank emptying / Brutto Erstellungskosten der elektromechnischen Ausrüstung für die Beckenentleerung / Coûts bruts des équipements électromécaniques vidange de bassins';


--
-- Name: COLUMN tank_emptying.year_of_replacement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.tank_emptying.year_of_replacement IS 'yyy_Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Jahr in dem die Lebensdauer der elektromechanischen Ausrüstung voraussichtlich abläuft / Année pour laquelle on prévoit que la durée de vie de l''équipement soit écoulée';


--
-- Name: throttle_shut_off_unit; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.throttle_shut_off_unit (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'throttle_shut_off_unit'::text) NOT NULL,
    actuation integer,
    adjustability integer,
    control integer,
    cross_section numeric(8,2),
    effective_cross_section numeric(8,2),
    gross_costs numeric(10,2),
    identifier character varying(20),
    kind integer,
    manufacturer character varying(50),
    remark character varying(80),
    signal_transmission integer,
    subsidies numeric(10,2),
    throttle_unit_opening_current integer,
    throttle_unit_opening_current_optimized integer,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_node character varying(16),
    fk_control_center character varying(16),
    fk_overflow character varying(16)
);


ALTER TABLE qgep_od.throttle_shut_off_unit OWNER TO postgres;

--
-- Name: COLUMN throttle_shut_off_unit.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN throttle_shut_off_unit.actuation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.actuation IS 'Actuation of the throttle or shut-off unit / Antrieb der Einbaute / Entraînement des installations';


--
-- Name: COLUMN throttle_shut_off_unit.adjustability; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.adjustability IS 'Possibility to adjust the position / Möglichkeit zur Verstellung / Possibilité de modifier la position';


--
-- Name: COLUMN throttle_shut_off_unit.control; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.control IS 'Open or closed loop control unit for the installation / Steuer- und Regelorgan für die Einbaute / Dispositifs de commande et de régulation des installations';


--
-- Name: COLUMN throttle_shut_off_unit.cross_section; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.cross_section IS 'Cross section (geometric area) of throttle or shut-off unit / Geometrischer Drosselquerschnitt: Fgeom / Section géométrique de l''élément régulateur';


--
-- Name: COLUMN throttle_shut_off_unit.effective_cross_section; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.effective_cross_section IS 'Effective cross section (area) / Wirksamer Drosselquerschnitt : Fid / Section du limiteur hydrauliquement active';


--
-- Name: COLUMN throttle_shut_off_unit.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.gross_costs IS 'Gross costs / Brutto Erstellungskosten / Coûts bruts de réalisation';


--
-- Name: COLUMN throttle_shut_off_unit.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.kind IS 'Type of flow control / Art der Durchflussregulierung / Genre de régulation du débit';


--
-- Name: COLUMN throttle_shut_off_unit.manufacturer; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.manufacturer IS 'Manufacturer of the electro-mechaninc equipment or installation / Hersteller der elektro-mech. Ausrüstung oder Einrichtung / Fabricant d''équipement électromécanique ou d''installations';


--
-- Name: COLUMN throttle_shut_off_unit.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN throttle_shut_off_unit.signal_transmission; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.signal_transmission IS 'Signal or data transfer from or to a telecommunication station sending_receiving / Signalübermittlung von und zu einer Fernwirkanlage / Transmission des signaux de et vers une station de télécommande';


--
-- Name: COLUMN throttle_shut_off_unit.subsidies; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.subsidies IS 'yyy_Staats- und Bundesbeiträge / Staats- und Bundesbeiträge / Contributions des cantons et de la confédération';


--
-- Name: COLUMN throttle_shut_off_unit.throttle_unit_opening_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.throttle_unit_opening_current IS 'yyy_Folgende Werte sind anzugeben: Leapingwehr: Schrägdistanz der Blech- resp. Bodenöffnung. Drosselstrecke: keine zusätzlichen Angaben. Schieber / Schütz: lichte Höhe der Öffnung (ab Sohle bis UK Schieberplatte, tiefster Punkt). Abflussregulator: keine zusätzlichen Angaben. Pumpe: zusätzlich in Stammkarte Pumpwerk erfassen / Folgende Werte sind anzugeben: Leapingwehr: Schrägdistanz der Blech- resp. Bodenöffnung. Drosselstrecke: keine zusätzlichen Angaben. Schieber / Schütz: lichte Höhe der Öffnung (ab Sohle bis UK Schieberplatte, tiefster Punkt). Abflussregulator: keine zusätzlichen Angaben. Pumpe: zusätzlich in Stammkarte Pumpwerk erfassen / Les valeurs suivantes doivent être indiquées: Leaping weir: Longueur ouverture de fond, Cond. d’étranglement : aucune indication suppl., Vanne : hauteur max de l’ouverture (du radier jusqu’au bord inférieur plaque, point le plus bas), Régulateur de débit : aucune indication suppl., Pompe : saisir fiche technique STAP';


--
-- Name: COLUMN throttle_shut_off_unit.throttle_unit_opening_current_optimized; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.throttle_unit_opening_current_optimized IS 'yyy_Folgende Werte sind anzugeben: Leapingwehr: Schrägdistanz der Blech- resp. Bodenöffnung. Drosselstrecke: keine zusätzlichen Angaben. Schieber / Schütz: lichte Höhe der Öffnung (ab Sohle bis UK Schieberplatte, tiefster Punkt). Abflussregulator: keine zusätzlichen Angaben. Pumpe: zusätzlich in Stammkarte Pumpwerk erfassen / Folgende Werte sind anzugeben: Leapingwehr: Schrägdistanz der Blech- resp. Bodenöffnung. Drosselstrecke: keine zusätzlichen Angaben. Schieber / Schütz: lichte Höhe der Öffnung (ab Sohle bis UK Schieberplatte, tiefster Punkt). Abflussregulator: keine zusätzlichen Angaben. Pumpe: zusätzlich in Stammkarte Pumpwerk erfassen / Les valeurs suivantes doivent être indiquées: Leaping weir: Longueur ouverture de fond, Cond. d’étranglement : aucune indication suppl., Vanne : hauteur max de l’ouverture (du radier jusqu’au bord inférieur plaque, point le plus bas), Régulateur de débit : aucune indication suppl., Pompe : saisir fiche technique STAP';


--
-- Name: COLUMN throttle_shut_off_unit.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN throttle_shut_off_unit.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN throttle_shut_off_unit.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.throttle_shut_off_unit.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: txt_symbol; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.txt_symbol (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'txt_symbol'::text) NOT NULL,
    class character varying(50),
    plantype integer,
    symbol_scaling_heigth numeric(2,1),
    symbol_scaling_width numeric(2,1),
    symbolori numeric(4,1),
    symbolpos_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_structure character varying(16)
);


ALTER TABLE qgep_od.txt_symbol OWNER TO postgres;

--
-- Name: COLUMN txt_symbol.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_symbol.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN txt_symbol.class; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_symbol.class IS 'ID of the active zone, for visualization purpose (use A, B, C, D, E, F, G and H)';


--
-- Name: COLUMN txt_symbol.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_symbol.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN txt_symbol.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_symbol.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN txt_symbol.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_symbol.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: txt_text; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.txt_text (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'txt_text'::text) NOT NULL,
    class character varying(50),
    plantype integer,
    remark character varying(80),
    text text,
    texthali smallint,
    textori numeric(4,1),
    textpos_geometry public.geometry(Point,2056),
    textvali smallint,
    last_modification timestamp without time zone DEFAULT now(),
    fk_wastewater_structure character varying(16),
    fk_catchment_area character varying(16),
    fk_reach character varying(16)
);


ALTER TABLE qgep_od.txt_text OWNER TO postgres;

--
-- Name: COLUMN txt_text.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_text.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN txt_text.class; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_text.class IS 'Name of class that textclass is related to / Name der Klasse zu der die Textklasse gehört / xxx_Name der Klasse zu der die Textklasse gehört';


--
-- Name: COLUMN txt_text.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_text.remark IS 'General remarks';


--
-- Name: COLUMN txt_text.text; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_text.text IS 'yyy_Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / valeur calculée à partir d’attributs, plusieurs lignes possible';


--
-- Name: COLUMN txt_text.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.txt_text.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: vw_access_aid; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_access_aid AS
 SELECT aa.obj_id,
    aa.kind,
    sp.identifier,
    sp.remark,
    sp.renovation_demand,
    sp.fk_dataowner,
    sp.fk_provider,
    sp.last_modification,
    sp.fk_wastewater_structure
   FROM (qgep_od.access_aid aa
     LEFT JOIN qgep_od.structure_part sp ON (((sp.obj_id)::text = (aa.obj_id)::text)));


ALTER TABLE qgep_od.vw_access_aid OWNER TO postgres;

--
-- Name: vw_backflow_prevention; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_backflow_prevention AS
 SELECT bp.obj_id,
    bp.gross_costs,
    bp.kind,
    bp.year_of_replacement,
    sp.identifier,
    sp.remark,
    sp.renovation_demand,
    sp.fk_dataowner,
    sp.fk_provider,
    sp.last_modification,
    sp.fk_wastewater_structure
   FROM (qgep_od.backflow_prevention bp
     LEFT JOIN qgep_od.structure_part sp ON (((sp.obj_id)::text = (bp.obj_id)::text)));


ALTER TABLE qgep_od.vw_backflow_prevention OWNER TO postgres;

--
-- Name: vw_benching; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_benching AS
 SELECT be.obj_id,
    be.kind,
    sp.identifier,
    sp.remark,
    sp.renovation_demand,
    sp.fk_dataowner,
    sp.fk_provider,
    sp.last_modification,
    sp.fk_wastewater_structure
   FROM (qgep_od.benching be
     LEFT JOIN qgep_od.structure_part sp ON (((sp.obj_id)::text = (be.obj_id)::text)));


ALTER TABLE qgep_od.vw_benching OWNER TO postgres;

--
-- Name: wastewater_node; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.wastewater_node (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wastewater_node'::text) NOT NULL,
    backflow_level numeric(7,3),
    bottom_level numeric(7,3),
    situation_geometry public.geometry(Point,2056),
    fk_hydr_geometry character varying(16)
);


ALTER TABLE qgep_od.wastewater_node OWNER TO postgres;

--
-- Name: COLUMN wastewater_node.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_node.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN wastewater_node.backflow_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_node.backflow_level IS 'yyy_1. Massgebende Rückstaukote bezogen auf den Berechnungsregen (dss)  2. Höhe, unter der innerhalb der Grundstücksentwässerung besondere Massnahmen gegen Rückstau zu treffen sind. (DIN 4045) / 1. Massgebende Rückstaukote bezogen auf den Berechnungsregen (dss)  2. Höhe, unter der innerhalb der Grundstücksentwässerung besondere Massnahmen gegen Rückstau zu treffen sind. (DIN 4045) / Cote de refoulement déterminante calculée à partir des pluies de projet';


--
-- Name: COLUMN wastewater_node.bottom_level; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_node.bottom_level IS 'yyy_Tiefster Punkt des Abwasserbauwerks / Tiefster Punkt des Abwasserbauwerks / Point le plus bas du noeud';


--
-- Name: COLUMN wastewater_node.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_node.situation_geometry IS 'yyy Situation of node. Decisive reference point for sewer network simulation  (In der Regel Lage des Pickellochs oder Lage des Trockenwetterauslauf) / Lage des Knotens, massgebender Bezugspunkt für die Kanalnetzberechnung. (In der Regel Lage des Pickellochs oder Lage des Trockenwetterauslaufs) / Positionnement du nœud. Point de référence déterminant pour le calcul de réseau de canalisations (en règle générale positionnement du milieu du couvercle ou de la sortie temps sec)';


--
-- Name: vw_catchment_area_connections; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_catchment_area_connections AS
 SELECT ca.obj_id,
    (public.st_makeline(public.st_centroid(public.st_curvetoline(ca.perimeter_geometry)), wn_rw_current.situation_geometry))::public.geometry(LineString,2056) AS connection_rw_current_geometry,
    (public.st_makeline(public.st_centroid(public.st_curvetoline(ca.perimeter_geometry)), wn_ww_current.situation_geometry))::public.geometry(LineString,2056) AS connection_ww_current_geometry
   FROM ((qgep_od.catchment_area ca
     LEFT JOIN qgep_od.wastewater_node wn_rw_current ON (((ca.fk_wastewater_networkelement_rw_current)::text = (wn_rw_current.obj_id)::text)))
     LEFT JOIN qgep_od.wastewater_node wn_ww_current ON (((ca.fk_wastewater_networkelement_ww_current)::text = (wn_ww_current.obj_id)::text)));


ALTER TABLE qgep_od.vw_catchment_area_connections OWNER TO postgres;

--
-- Name: wastewater_networkelement; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.wastewater_networkelement (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wastewater_networkelement'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_structure character varying(16)
);


ALTER TABLE qgep_od.wastewater_networkelement OWNER TO postgres;

--
-- Name: COLUMN wastewater_networkelement.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_networkelement.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN wastewater_networkelement.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_networkelement.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN wastewater_networkelement.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_networkelement.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN wastewater_networkelement.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_networkelement.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN wastewater_networkelement.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_networkelement.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: vw_change_points; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_change_points AS
 SELECT rp_to.obj_id,
    rp_to.situation_geometry AS geom,
    (re.material <> re_next.material) AS change_in_material,
    (re.clear_height <> re_next.clear_height) AS change_in_clear_height,
    (((rp_from.level - rp_to.level) / re.length_effective) - ((rp_next_from.level - rp_next_to.level) / re_next.length_effective)) AS change_in_slope
   FROM (((((((qgep_od.reach re
     LEFT JOIN qgep_od.reach_point rp_to ON (((rp_to.obj_id)::text = (re.fk_reach_point_to)::text)))
     LEFT JOIN qgep_od.reach_point rp_from ON (((rp_from.obj_id)::text = (re.fk_reach_point_from)::text)))
     LEFT JOIN qgep_od.reach re_next ON (((rp_to.fk_wastewater_networkelement)::text = (re_next.obj_id)::text)))
     LEFT JOIN qgep_od.reach_point rp_next_to ON (((rp_next_to.obj_id)::text = (re_next.fk_reach_point_to)::text)))
     LEFT JOIN qgep_od.reach_point rp_next_from ON (((rp_next_from.obj_id)::text = (re_next.fk_reach_point_from)::text)))
     LEFT JOIN qgep_od.wastewater_networkelement ne ON (((re.obj_id)::text = (ne.obj_id)::text)))
     LEFT JOIN qgep_od.wastewater_networkelement ne_next ON (((re_next.obj_id)::text = (ne_next.obj_id)::text)))
  WHERE ((ne_next.fk_wastewater_structure)::text = (ne.fk_wastewater_structure)::text);


ALTER TABLE qgep_od.vw_change_points OWNER TO postgres;

--
-- Name: wastewater_structure; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.wastewater_structure (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wastewater_structure'::text) NOT NULL,
    accessibility integer,
    contract_section character varying(50),
    detail_geometry_geometry public.geometry(CurvePolygonZ,2056),
    financing integer,
    gross_costs numeric(10,2),
    identifier character varying(20),
    inspection_interval numeric(4,2),
    location_name character varying(50),
    records character varying(255),
    remark character varying(80),
    renovation_necessity integer,
    replacement_value numeric(10,2),
    rv_base_year smallint,
    rv_construction_type integer,
    status integer,
    structure_condition integer,
    subsidies numeric(10,2),
    year_of_construction smallint,
    year_of_replacement smallint,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_owner character varying(16),
    fk_operator character varying(16),
    _usage_current integer,
    _function_hierarchic integer,
    _label text,
    fk_main_cover character varying(16),
    _depth numeric(6,3)
);


ALTER TABLE qgep_od.wastewater_structure OWNER TO postgres;

--
-- Name: COLUMN wastewater_structure.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN wastewater_structure.accessibility; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.accessibility IS 'yyy_Möglichkeit der Zugänglichkeit ins Innere eines Abwasserbauwerks für eine Person (nicht für ein Fahrzeug) / Möglichkeit der Zugänglichkeit ins Innere eines Abwasserbauwerks für eine Person (nicht für ein Fahrzeug) / Possibilités d’accès à l’ouvrage d’assainissement pour une personne (non pour un véhicule)';


--
-- Name: COLUMN wastewater_structure.contract_section; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.contract_section IS 'Number of contract section / Nummer des Bauloses / Numéro du lot de construction';


--
-- Name: COLUMN wastewater_structure.detail_geometry_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.detail_geometry_geometry IS 'Detail geometry especially with special structures. For manhole usually use dimension1 and 2. Also with normed infiltratin structures.  Channels usually do not have a detail_geometry. / Detaillierte Geometrie insbesondere bei Spezialbauwerken. Für Normschächte i.d. R.  Dimension1 und 2 verwenden. Dito bei normierten Versickerungsanlagen.  Kanäle haben normalerweise keine Detailgeometrie. / Géométrie détaillée particulièrement pour un OUVRAGE_SPECIAL. Pour l’attribut CHAMBRE_STANDARD utilisez Dimension1 et 2, de même pour une INSTALLATION_INFILTRATION normée.  Les canalisations n’ont en général pas de géométrie détaillée.';


--
-- Name: COLUMN wastewater_structure.financing; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.financing IS ' Method of financing  (Financing based on GschG Art. 60a). / Finanzierungart (Finanzierung gemäss GschG Art. 60a). / Type de financement (financement selon LEaux Art. 60a)';


--
-- Name: COLUMN wastewater_structure.gross_costs; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.gross_costs IS 'Gross costs of construction / Brutto Erstellungskosten / Coûts bruts des travaux de construction';


--
-- Name: COLUMN wastewater_structure.identifier; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.identifier IS 'yyy_Pro Datenherr eindeutige Bezeichnung / Pro Datenherr eindeutige Bezeichnung / Désignation unique pour chaque maître des données';


--
-- Name: COLUMN wastewater_structure.inspection_interval; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.inspection_interval IS 'yyy_Abstände, in welchen das Abwasserbauwerk inspiziert werden sollte (Jahre) / Abstände, in welchen das Abwasserbauwerk inspiziert werden sollte (Jahre) / Fréquence à laquelle un ouvrage du réseau d‘assainissement devrait subir une inspection (années)';


--
-- Name: COLUMN wastewater_structure.location_name; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.location_name IS 'Street name or name of the location of the structure / Strassenname oder Ortsbezeichnung  zum Bauwerk / Nom de la route ou du lieu de l''ouvrage';


--
-- Name: COLUMN wastewater_structure.records; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.records IS 'yyy_Plan Nr. der Ausführungsdokumentation. Kurzbeschrieb weiterer Akten (Betriebsanleitung vom …, etc.) / Plan Nr. der Ausführungsdokumentation. Kurzbeschrieb weiterer Akten (Betriebsanleitung vom …, etc.) / N° de plan de la documentation d’exécution, description de dossiers, manuels, etc.';


--
-- Name: COLUMN wastewater_structure.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN wastewater_structure.renovation_necessity; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.renovation_necessity IS 'yyy_Dringlichkeitsstufen und Zeithorizont für bauliche Massnahmen gemäss VSA-Richtline "Erhaltung von Kanalisationen" / Dringlichkeitsstufen und Zeithorizont für bauliche Massnahmen gemäss VSA-Richtline "Erhaltung von Kanalisationen" / 	Degrés d’urgence et délai de réalisation des mesures constructives selon la directive VSA "Maintien des canalisations"';


--
-- Name: COLUMN wastewater_structure.replacement_value; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.replacement_value IS 'yyy_Wiederbeschaffungswert des Bauwerks. Zusätzlich muss auch das Attribut WBW_Basisjahr erfasst werden / Wiederbeschaffungswert des Bauwerks. Zusätzlich muss auch das Attribut WBW_Basisjahr erfasst werden / Valeur de remplacement de l''OUVRAGE_RESEAU_AS. On à besoin aussi de saisir l''attribut VR_ANNEE_REFERENCE';


--
-- Name: COLUMN wastewater_structure.rv_base_year; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.rv_base_year IS 'yyy_Basisjahr für die Kalkulation des Wiederbeschaffungswerts (siehe auch Wiederbeschaffungswert) / Basisjahr für die Kalkulation des Wiederbeschaffungswerts (siehe auch Attribut Wiederbeschaffungswert) / Année de référence pour le calcul de la valeur de remplacement (cf. valeur de remplacement)';


--
-- Name: COLUMN wastewater_structure.rv_construction_type; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.rv_construction_type IS 'yyy_Grobe Einteilung der Bauart des Abwasserbauwerks als Inputwert für die Berechnung des Wiederbeschaffungswerts. / Grobe Einteilung der Bauart des Abwasserbauwerks als Inputwert für die Berechnung des Wiederbeschaffungswerts. / Valeur de remplacement du type de construction';


--
-- Name: COLUMN wastewater_structure.status; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.status IS 'Operating and planning status of the structure / Betriebs- bzw. Planungszustand des Bauwerks / Etat de fonctionnement et de planification de l’ouvrage';


--
-- Name: COLUMN wastewater_structure.structure_condition; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.structure_condition IS 'yyy_Zustandsklassen. Beschreibung des baulichen Zustands des Kanals. Nicht zu verwechseln mit den Sanierungsstufen, welche die Prioritäten der Massnahmen bezeichnen (Attribut Sanierungsbedarf). / Zustandsklassen 0 bis 4 gemäss VSA-Richtline "Erhaltung von Kanalisationen". Beschreibung des baulichen Zustands des Abwasserbauwerks. Nicht zu verwechseln mit den Sanierungsstufen, welche die Prioritäten der Massnahmen bezeichnen (Attribut Sanierungsbedarf). / Classes d''état. Description de l''état constructif selon la directive VSA "Maintien des canalisations" (2007/2009). Ne pas confondre avec les degrés de remise en état (attribut NECESSITE_ASSAINIR)';


--
-- Name: COLUMN wastewater_structure.subsidies; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.subsidies IS 'yyy_Staats- und Bundesbeiträge / Staats- und Bundesbeiträge / Contributions des cantons et de la Confédération';


--
-- Name: COLUMN wastewater_structure.year_of_construction; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.year_of_construction IS 'yyy_Jahr der Inbetriebsetzung (Schlussabnahme). Falls unbekannt = 1800 setzen (tiefster Wert des Wertebereiches) / Jahr der Inbetriebsetzung (Schlussabnahme). Falls unbekannt = 1800 setzen (tiefster Wert des Wertebereichs) / Année de mise en service (réception finale)';


--
-- Name: COLUMN wastewater_structure.year_of_replacement; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.year_of_replacement IS 'yyy_Jahr, in dem die Lebensdauer des Bauwerks voraussichtlich abläuft / Jahr, in dem die Lebensdauer des Bauwerks voraussichtlich abläuft / Année pour laquelle on prévoit que la durée de vie de l''ouvrage soit écoulée';


--
-- Name: COLUMN wastewater_structure.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN wastewater_structure.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN wastewater_structure.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: COLUMN wastewater_structure._usage_current; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure._usage_current IS 'not part of the VSA-DSS data model
added solely for QGEP
has to be updated by triggers';


--
-- Name: COLUMN wastewater_structure._function_hierarchic; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure._function_hierarchic IS 'not part of the VSA-DSS data model
added solely for QGEP
has to be updated by triggers';


--
-- Name: COLUMN wastewater_structure._label; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure._label IS 'not part of the VSA-DSS data model
added solely for QGEP';


--
-- Name: COLUMN wastewater_structure._depth; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure._depth IS 'yyy_Funktion (berechneter Wert) = repräsentative Abwasserknoten.Sohlenkote minus zugehörige Deckenkote des Bauwerks falls Detailgeometrie vorhanden, sonst Funktion (berechneter Wert) = Abwasserknoten.Sohlenkote minus zugehörige Deckel.Kote des Bauwerks / Funktion (berechneter Wert) = repräsentative Abwasserknoten.Sohlenkote minus zugehörige Deckenkote des Bauwerks falls Detailgeometrie vorhanden, sonst Funktion (berechneter Wert) = Abwasserknoten.Sohlenkote minus zugehörige Deckel.Kote des Bauwerks / Fonction (valeur calculée) = NOEUD_RESEAU.COTE_RADIER représentatif moins COTE_PLAFOND de l’ouvrage correspondant si la géométrie détaillée est disponible, sinon fonction (valeur calculée) = NŒUD_RESEAU.COT_RADIER moins COUVERCLE.COTE de l’ouvrage correspondant';


--
-- Name: vw_channel; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_channel AS
 SELECT cl.obj_id,
    cl.bedding_encasement,
    cl.connection_type,
    cl.function_hierarchic,
    cl.function_hydraulic,
    cl.jetting_interval,
    cl.pipe_length,
    cl.usage_current,
    cl.usage_planned,
    ws.accessibility,
    ws.contract_section,
    ws.detail_geometry_geometry,
    ws.financing,
    ws.gross_costs,
    ws.identifier,
    ws.inspection_interval,
    ws.location_name,
    ws.records,
    ws.remark,
    ws.renovation_necessity,
    ws.replacement_value,
    ws.rv_base_year,
    ws.rv_construction_type,
    ws.status,
    ws.structure_condition,
    ws.subsidies,
    ws.year_of_construction,
    ws.year_of_replacement,
    ws.fk_dataowner,
    ws.fk_provider,
    ws.last_modification,
    ws.fk_owner,
    ws.fk_operator
   FROM (qgep_od.channel cl
     LEFT JOIN qgep_od.wastewater_structure ws ON (((ws.obj_id)::text = (cl.obj_id)::text)));


ALTER TABLE qgep_od.vw_channel OWNER TO postgres;

--
-- Name: vw_cover; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_cover AS
 SELECT co.obj_id,
    co.brand,
    co.cover_shape,
    co.diameter,
    co.fastening,
    co.level,
    co.material,
    co.positional_accuracy,
    co.situation_geometry,
    co.sludge_bucket,
    co.venting,
    sp.identifier,
    sp.remark,
    sp.renovation_demand,
    sp.fk_dataowner,
    sp.fk_provider,
    sp.last_modification,
    sp.fk_wastewater_structure
   FROM (qgep_od.cover co
     LEFT JOIN qgep_od.structure_part sp ON (((sp.obj_id)::text = (co.obj_id)::text)));


ALTER TABLE qgep_od.vw_cover OWNER TO postgres;

--
-- Name: vw_damage_channel; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_damage_channel AS
 SELECT damage.obj_id,
    damage.comments,
    damage.connection,
    damage.damage_begin,
    damage.damage_end,
    damage.damage_reach,
    damage.distance,
    damage.quantification1,
    damage.quantification2,
    damage.single_damage_class,
    damage.video_counter,
    damage.view_parameters,
    damage.last_modification,
    damage.fk_dataowner,
    damage.fk_provider,
    damage.fk_examination,
    channel.channel_damage_code
   FROM (qgep_od.damage_channel channel
     JOIN qgep_od.damage damage ON (((channel.obj_id)::text = (damage.obj_id)::text)));


ALTER TABLE qgep_od.vw_damage_channel OWNER TO postgres;

--
-- Name: vw_damage_manhole; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_damage_manhole AS
 SELECT damage.obj_id,
    damage.comments,
    damage.connection,
    damage.damage_begin,
    damage.damage_end,
    damage.damage_reach,
    damage.distance,
    damage.quantification1,
    damage.quantification2,
    damage.single_damage_class,
    damage.video_counter,
    damage.view_parameters,
    damage.last_modification,
    damage.fk_dataowner,
    damage.fk_provider,
    damage.fk_examination,
    manhole.manhole_damage_code,
    manhole.manhole_shaft_area
   FROM (qgep_od.damage_manhole manhole
     JOIN qgep_od.damage damage ON (((manhole.obj_id)::text = (damage.obj_id)::text)));


ALTER TABLE qgep_od.vw_damage_manhole OWNER TO postgres;

--
-- Name: vw_discharge_point; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_discharge_point AS
 SELECT dp.obj_id,
    ws._depth,
    dp.highwater_level,
    dp.relevance,
    dp.terrain_level,
    dp.upper_elevation,
    dp.waterlevel_hydraulic,
    ws.accessibility,
    ws.contract_section,
    ws.detail_geometry_geometry,
    ws.financing,
    ws.gross_costs,
    ws.identifier,
    ws.inspection_interval,
    ws.location_name,
    ws.records,
    ws.remark,
    ws.renovation_necessity,
    ws.replacement_value,
    ws.rv_base_year,
    ws.rv_construction_type,
    ws.status,
    ws.structure_condition,
    ws.subsidies,
    ws.year_of_construction,
    ws.year_of_replacement,
    ws.fk_dataowner,
    ws.fk_provider,
    ws.last_modification,
    ws.fk_owner,
    ws.fk_operator
   FROM (qgep_od.discharge_point dp
     LEFT JOIN qgep_od.wastewater_structure ws ON (((ws.obj_id)::text = (dp.obj_id)::text)));


ALTER TABLE qgep_od.vw_discharge_point OWNER TO postgres;

--
-- Name: vw_dryweather_downspout; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_dryweather_downspout AS
 SELECT dd.obj_id,
    dd.diameter,
    sp.identifier,
    sp.remark,
    sp.renovation_demand,
    sp.fk_dataowner,
    sp.fk_provider,
    sp.last_modification,
    sp.fk_wastewater_structure
   FROM (qgep_od.dryweather_downspout dd
     LEFT JOIN qgep_od.structure_part sp ON (((sp.obj_id)::text = (dd.obj_id)::text)));


ALTER TABLE qgep_od.vw_dryweather_downspout OWNER TO postgres;

--
-- Name: vw_dryweather_flume; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_dryweather_flume AS
 SELECT df.obj_id,
    df.material,
    sp.identifier,
    sp.remark,
    sp.renovation_demand,
    sp.fk_dataowner,
    sp.fk_provider,
    sp.last_modification,
    sp.fk_wastewater_structure
   FROM (qgep_od.dryweather_flume df
     LEFT JOIN qgep_od.structure_part sp ON (((sp.obj_id)::text = (df.obj_id)::text)));


ALTER TABLE qgep_od.vw_dryweather_flume OWNER TO postgres;

--
-- Name: vw_maintenance_examination; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_maintenance_examination AS
 SELECT maintenance.obj_id,
    maintenance.base_data,
    maintenance.cost,
    maintenance.data_details,
    maintenance.duration,
    maintenance.identifier,
    maintenance.kind,
    maintenance.operator,
    maintenance.reason,
    maintenance.remark,
    maintenance.result,
    maintenance.status,
    maintenance.time_point,
    maintenance.last_modification,
    maintenance.fk_dataowner,
    maintenance.fk_provider,
    maintenance.fk_operating_company,
    maintenance.active_zone,
    examination.equipment,
    examination.from_point_identifier,
    examination.inspected_length,
    examination.recording_type,
    examination.to_point_identifier,
    examination.vehicle,
    examination.videonumber,
    examination.weather,
    examination.fk_reach_point
   FROM (qgep_od.examination examination
     JOIN qgep_od.maintenance_event maintenance ON (((examination.obj_id)::text = (maintenance.obj_id)::text)));


ALTER TABLE qgep_od.vw_maintenance_examination OWNER TO postgres;

--
-- Name: vw_manhole; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_manhole AS
 SELECT ma.obj_id,
    ws._depth,
    ma.dimension1,
    ma.dimension2,
    ma.function,
    ma.material,
    ma.surface_inflow,
    ws.accessibility,
    ws.contract_section,
    ws.detail_geometry_geometry,
    ws.financing,
    ws.gross_costs,
    ws.identifier,
    ws.inspection_interval,
    ws.location_name,
    ws.records,
    ws.remark,
    ws.renovation_necessity,
    ws.replacement_value,
    ws.rv_base_year,
    ws.rv_construction_type,
    ws.status,
    ws.structure_condition,
    ws.subsidies,
    ws.year_of_construction,
    ws.year_of_replacement,
    ws.fk_dataowner,
    ws.fk_provider,
    ws.last_modification,
    ws.fk_owner,
    ws.fk_operator
   FROM (qgep_od.manhole ma
     LEFT JOIN qgep_od.wastewater_structure ws ON (((ws.obj_id)::text = (ma.obj_id)::text)));


ALTER TABLE qgep_od.vw_manhole OWNER TO postgres;

--
-- Name: vw_network_node; Type: MATERIALIZED VIEW; Schema: qgep_od; Owner: postgres
--

CREATE MATERIALIZED VIEW qgep_od.vw_network_node AS
 SELECT row_number() OVER () AS gid,
    nodes.obj_id,
    nodes.type,
    nodes.node_type,
    nodes.level,
    nodes.usage_current,
    nodes.cover_level,
    nodes.backflow_level,
    nodes.description,
    nodes.detail_geometry,
    nodes.situation_geometry
   FROM ( SELECT reach_point.obj_id,
            'reach_point'::text AS type,
            'reach_point'::text AS node_type,
            reach_point.level,
            NULL::integer AS usage_current,
            NULL::numeric AS cover_level,
            NULL::numeric AS backflow_level,
            NULL::character varying AS description,
            reach_point.situation_geometry AS detail_geometry,
            reach_point.situation_geometry
           FROM qgep_od.reach_point
        UNION
         SELECT ne.obj_id,
            'wastewater_node'::text AS type,
                CASE
                    WHEN (mh.obj_id IS NOT NULL) THEN 'manhole'::text
                    WHEN (ws.obj_id IS NOT NULL) THEN 'special_WSucture'::text
                    ELSE 'other'::text
                END AS node_type,
            wn.bottom_level AS level,
            COALESCE(max(ch_from.usage_current), max(ch_to.usage_current)) AS usage_current,
            max(co.level) AS cover_level,
            wn.backflow_level,
            ne.identifier AS description,
            COALESCE(ws.detail_geometry_geometry, wn.situation_geometry) AS detail_geometry,
            wn.situation_geometry
           FROM ((((((((((((qgep_od.wastewater_node wn
             LEFT JOIN qgep_od.wastewater_networkelement ne ON (((ne.obj_id)::text = (wn.obj_id)::text)))
             LEFT JOIN qgep_od.wastewater_structure ws ON (((ws.obj_id)::text = (ne.fk_wastewater_structure)::text)))
             LEFT JOIN qgep_od.manhole mh ON (((mh.obj_id)::text = (ws.obj_id)::text)))
             LEFT JOIN qgep_od.structure_part sp ON (((sp.fk_wastewater_structure)::text = (ws.obj_id)::text)))
             LEFT JOIN qgep_od.cover co ON (((co.obj_id)::text = (sp.obj_id)::text)))
             LEFT JOIN qgep_od.reach_point rp ON (((ne.obj_id)::text = (rp.fk_wastewater_networkelement)::text)))
             LEFT JOIN qgep_od.reach re_from ON (((re_from.fk_reach_point_from)::text = (rp.obj_id)::text)))
             LEFT JOIN qgep_od.wastewater_networkelement ne_from ON (((ne_from.obj_id)::text = (re_from.obj_id)::text)))
             LEFT JOIN qgep_od.channel ch_from ON (((ch_from.obj_id)::text = (ne_from.fk_wastewater_structure)::text)))
             LEFT JOIN qgep_od.reach re_to ON (((re_to.fk_reach_point_to)::text = (rp.obj_id)::text)))
             LEFT JOIN qgep_od.wastewater_networkelement ne_to ON (((ne_to.obj_id)::text = (re_to.obj_id)::text)))
             LEFT JOIN qgep_od.channel ch_to ON (((ch_to.obj_id)::text = (ne_to.fk_wastewater_structure)::text)))
          GROUP BY ne.obj_id, 'wastewater_node'::text, wn.bottom_level, wn.backflow_level, ne.identifier, wn.situation_geometry, ws.detail_geometry_geometry, ws.obj_id, mh.obj_id, sp.fk_wastewater_structure) nodes
  WITH NO DATA;


ALTER TABLE qgep_od.vw_network_node OWNER TO postgres;

--
-- Name: value_list_base; Type: TABLE; Schema: qgep_sys; Owner: postgres
--

CREATE TABLE qgep_sys.value_list_base (
    code integer NOT NULL,
    vsacode integer NOT NULL,
    value_en character varying(50),
    value_de character varying(50),
    value_fr character varying(50),
    value_it character varying(60),
    value_ro character varying(50),
    abbr_en character varying(3),
    abbr_de character varying(3),
    abbr_fr character varying(3),
    abbr_it character varying(3),
    abbr_ro character varying(3),
    active boolean
);


ALTER TABLE qgep_sys.value_list_base OWNER TO postgres;

--
-- Name: reach_material; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_material (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_material OWNER TO postgres;

--
-- Name: vw_network_segment; Type: MATERIALIZED VIEW; Schema: qgep_od; Owner: postgres
--

CREATE MATERIALIZED VIEW qgep_od.vw_network_segment AS
 WITH reach_parts AS (
         SELECT row_number() OVER (ORDER BY reach_point.fk_wastewater_networkelement, (public.st_linelocatepoint(public.st_linemerge(public.st_curvetoline(public.st_force2d(reach.progression_geometry))), reach_point.situation_geometry))) AS gid,
            reach_point.obj_id,
            reach_point.fk_wastewater_networkelement,
            reach_point.situation_geometry,
            reach.progression_geometry,
            reach.fk_reach_point_from,
            reach.fk_reach_point_to,
            public.st_linemerge(public.st_curvetoline(public.st_force2d(reach.progression_geometry))) AS reach_progression,
            public.st_linelocatepoint(public.st_linemerge(public.st_curvetoline(public.st_force2d(reach.progression_geometry))), reach_point.situation_geometry) AS pos
           FROM (qgep_od.reach_point
             LEFT JOIN qgep_od.reach ON (((reach_point.fk_wastewater_networkelement)::text = (reach.obj_id)::text)))
          WHERE ((reach_point.fk_wastewater_networkelement IS NOT NULL) AND (reach.progression_geometry IS NOT NULL))
          ORDER BY reach_point.obj_id, (public.st_linelocatepoint(public.st_linemerge(public.st_curvetoline(reach.progression_geometry)), reach_point.situation_geometry))
        )
 SELECT row_number() OVER () AS gid,
    parts.obj_id,
    parts.type,
    parts.clear_height,
    parts.length_calc,
    parts.length_full,
    parts.from_obj_id,
    parts.to_obj_id,
    parts.from_obj_id_interpolate,
    parts.to_obj_id_interpolate,
    parts.from_pos,
    parts.to_pos,
    parts.bottom_level,
    parts.usage_current,
    parts.material,
    parts.progression_geometry,
    parts.detail_geometry
   FROM ( SELECT re.obj_id,
            'reach'::text AS type,
            re.clear_height,
            public.st_length(COALESCE(rr.reach_progression, re.progression_geometry)) AS length_calc,
            public.st_length(re.progression_geometry) AS length_full,
            COALESCE(rr.from_obj_id, re.fk_reach_point_from) AS from_obj_id,
            COALESCE(rr.to_obj_id, re.fk_reach_point_to) AS to_obj_id,
            re.fk_reach_point_from AS from_obj_id_interpolate,
            re.fk_reach_point_to AS to_obj_id_interpolate,
            COALESCE(rr.from_pos, (0)::double precision) AS from_pos,
            COALESCE(rr.to_pos, (1)::double precision) AS to_pos,
            NULL::numeric AS bottom_level,
            ch.usage_current,
            mat.abbr_de AS material,
            COALESCE(rr.reach_progression, public.st_linemerge(public.st_curvetoline(public.st_force2d(re.progression_geometry)))) AS progression_geometry,
            public.st_linemerge(public.st_curvetoline(public.st_force2d(re.progression_geometry))) AS detail_geometry
           FROM ((((qgep_od.reach re
             FULL JOIN ( SELECT COALESCE(s1.fk_wastewater_networkelement, s2.fk_wastewater_networkelement) AS reach_obj_id,
                    COALESCE(s1.obj_id, s2.fk_reach_point_from) AS from_obj_id,
                    COALESCE(s2.obj_id, s1.fk_reach_point_to) AS to_obj_id,
                    COALESCE(s1.pos, (0)::double precision) AS from_pos,
                    COALESCE(s2.pos, (1)::double precision) AS to_pos,
                    public.st_linesubstring(COALESCE(s1.reach_progression, s2.reach_progression), COALESCE(s1.pos, (0)::double precision), COALESCE(s2.pos, (1)::double precision)) AS reach_progression
                   FROM (reach_parts s1
                     FULL JOIN reach_parts s2 ON (((s1.gid = (s2.gid - 1)) AND ((s1.fk_wastewater_networkelement)::text = (s2.fk_wastewater_networkelement)::text))))
                  ORDER BY COALESCE(s1.fk_wastewater_networkelement, s2.fk_wastewater_networkelement), COALESCE(s1.pos, (0)::double precision)) rr ON (((rr.reach_obj_id)::text = (re.obj_id)::text)))
             LEFT JOIN qgep_od.wastewater_networkelement ne ON (((ne.obj_id)::text = (re.obj_id)::text)))
             LEFT JOIN qgep_od.channel ch ON (((ch.obj_id)::text = (ne.fk_wastewater_structure)::text)))
             LEFT JOIN qgep_vl.reach_material mat ON ((re.material = mat.code)))
        UNION
         SELECT connectors.obj_id,
            'special_structure'::text AS type,
            NULL::integer AS depth,
            public.st_length(connectors.progression_geometry) AS length_calc,
            public.st_length(connectors.progression_geometry) AS length_full,
            connectors.from_obj_id,
            connectors.to_obj_id,
            connectors.from_obj_id AS from_obj_id_interpolate,
            connectors.to_obj_id AS to_obj_id_interpolate,
            0 AS from_pos,
            1 AS to_pos,
            connectors.bottom_level,
            NULL::integer AS usage_current,
            NULL::character varying AS material,
            connectors.progression_geometry,
            connectors.progression_geometry AS detail_geometry
           FROM (( SELECT wn_from.obj_id,
                    wn_from.obj_id AS from_obj_id,
                    rp_from.obj_id AS to_obj_id,
                    wn_from.bottom_level,
                    public.st_linefrommultipoint(public.st_collect(wn_from.situation_geometry, rp_from.situation_geometry)) AS progression_geometry
                   FROM ((qgep_od.reach
                     LEFT JOIN qgep_od.reach_point rp_from ON (((rp_from.obj_id)::text = (reach.fk_reach_point_from)::text)))
                     LEFT JOIN qgep_od.wastewater_node wn_from ON (((rp_from.fk_wastewater_networkelement)::text = (wn_from.obj_id)::text)))
                  WHERE ((reach.fk_reach_point_from IS NOT NULL) AND (wn_from.obj_id IS NOT NULL))
                UNION
                 SELECT wn_to.obj_id,
                    rp_to.obj_id AS from_obj_id,
                    wn_to.obj_id AS to_obj_id,
                    wn_to.bottom_level,
                    public.st_linefrommultipoint(public.st_collect(rp_to.situation_geometry, wn_to.situation_geometry)) AS progression_geometry
                   FROM ((qgep_od.reach
                     LEFT JOIN qgep_od.reach_point rp_to ON (((rp_to.obj_id)::text = (reach.fk_reach_point_to)::text)))
                     LEFT JOIN qgep_od.wastewater_node wn_to ON (((rp_to.fk_wastewater_networkelement)::text = (wn_to.obj_id)::text)))
                  WHERE ((reach.fk_reach_point_to IS NOT NULL) AND (wn_to.obj_id IS NOT NULL))) connectors
             LEFT JOIN qgep_od.wastewater_networkelement ne ON (((ne.obj_id)::text = (connectors.obj_id)::text)))) parts
  WHERE (public.geometrytype(parts.progression_geometry) <> 'GEOMETRYCOLLECTION'::text)
  WITH NO DATA;


ALTER TABLE qgep_od.vw_network_segment OWNER TO postgres;

--
-- Name: waste_water_association; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.waste_water_association (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'waste_water_association'::text) NOT NULL
);


ALTER TABLE qgep_od.waste_water_association OWNER TO postgres;

--
-- Name: COLUMN waste_water_association.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_association.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: waste_water_treatment_plant; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.waste_water_treatment_plant (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'waste_water_treatment_plant'::text) NOT NULL,
    bod5 smallint,
    cod smallint,
    elimination_cod numeric(5,2),
    elimination_n numeric(5,2),
    elimination_nh4 numeric(5,2),
    elimination_p numeric(5,2),
    installation_number integer,
    kind character varying(50),
    nh4 smallint,
    start_year smallint
);


ALTER TABLE qgep_od.waste_water_treatment_plant OWNER TO postgres;

--
-- Name: COLUMN waste_water_treatment_plant.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN waste_water_treatment_plant.bod5; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.bod5 IS '5 day biochemical oxygen demand measured at a temperatur of 20 degree celsius. YYY / Biochemischer Sauerstoffbedarf nach 5 Tagen Messzeit und bei einer Temperatur vom 20 Grad Celsius. Er stellt den Verbrauch an gelöstem Sauerstoff durch die Lebensvorgänge der im Wasser oder Abwasser enthaltenen Mikroorganismen (Bakterienprotozoen) beim  Abbau organischer Substanzen dar. Der Wert stellt eine wichtige Grösse zur Beurteilung der  aerob abbaufähigen Substanzen dar. Der BSB5 wird in den Einheiten mg/l oder g/m3 angegeben. Ausser dem BSB5 wird der biochemische Sauerstoffbedarf auch an 20 Tagen und mehr bestimmt. Dann spricht man z.B. vom BSB20 usw. Siehe Sapromat, Winklerprobe, Verdünnungsmethode. (arb) / Elle représente la quantité d’oxygène dépensée par les phénomènes d’oxydation chimique, d’une part, et, d’autre part, la dégradation des matières organiques par voie aérobie, nécessaire à la destruction des composés organiques. Elle s’exprime en milligrammes d’O2 consommé par litre d’effluent. Par convention, on retient le résultat de la consommation d’oxygène à 20° C au bout de 5 jours, ce qui donne l’appellation DBO5. (d’après M. Satin, B. Selmi, Guide technique de l’assainissement).';


--
-- Name: COLUMN waste_water_treatment_plant.cod; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.cod IS 'Abbreviation for chemical oxygen demand (COD). / Abkürzung für den chemischen Sauerstoffbedarf. Die englische Abkürzung lautet COD. Mit einem starken Oxydationsmittel wird mehr oder weniger erfolgreich versucht, die organischen Verbindungen der Abwasserprobe zu CO2 und H2O zu oxydieren. Als Oxydationsmittel eignen sich Chromverbindungen verschiedener Wertigkeit (z.B. Kalium-Dichromat K2Cr2O7) und Manganverbindungen (z.B. KmnO4), wobei man unter dem CSB im Allgemeinen den chemischen Sauerstoffbedarf nach der Kalium-Dichromat-Methode) versteht. Das Resultat kann als Chromatverbrauch oder Kaliumpermanaganatverbrauch ausgedrückt werden (z.B. mg CrO4 2-/l oder mg KMnO4/l). Im allgemeinen ergibt die Kalium-Dichromat-Methode höhere Werte als mit Kaliumpermanganat. Das Verhältnis des CSB zum BSB5 gilt als Hinweis auf die Abbaubarkeit der organischen Abwasserinhaltsstoffe. Leicht abbaubare häusliche Abwässer haben einen DSB/BSB5-Verhältnis von 1 bis 1,5. Schweres abbaubares, industrielles Abwasser ein Verhältnis von über 2. (arb) / Elle représente la teneur totale de l’eau en matières organiques, qu’elles soient ou non biodégradables. Le principe repose sur la recherche d’un besoin d’oxygène de l’échantillon pour dégrader la matière organique. Mais dans ce cas, l’oxygène est fourni par un oxydant puissant (le bichromate de potassium). La réaction (Afnor T90-101) est pratiquée à chaud (150°C) en présence d’acide sulfurique, et après 2 h on mesure la quantité d’oxydant restant. Là encore, le résultat s’exprime en milligrammes d’O2 par litre d’effluent.  Le rapport entre DCO/DBO5 est d’environ 2 à 2.7 pour une eau usée domestique ; au-delà, il y a vraisemblablement présence d’eaux industrielles résiduaires.';


--
-- Name: COLUMN waste_water_treatment_plant.elimination_cod; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.elimination_cod IS 'Dimensioning value elimination rate in percent / Dimensionierungswert Eliminationsrate in % / Valeur de dimensionnement, taux d''élimination en %';


--
-- Name: COLUMN waste_water_treatment_plant.elimination_n; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.elimination_n IS 'Denitrification at at waster water temperature of below 10 degree celsius / Denitrifikation bei einer Abwassertemperatur von > 10 Grad / Dénitrification à une température des eaux supérieure à 10°C';


--
-- Name: COLUMN waste_water_treatment_plant.elimination_nh4; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.elimination_nh4 IS 'Dimensioning value elimination rate in percent / Dimensionierungswert: Eliminationsrate in % / Valeur de dimensionnement, taux d''élimination en %';


--
-- Name: COLUMN waste_water_treatment_plant.elimination_p; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.elimination_p IS 'Dimensioning value elimination rate in percent / Dimensionierungswert Eliminationsrate in % / Valeur de dimensionnement, taux d''élimination en %';


--
-- Name: COLUMN waste_water_treatment_plant.installation_number; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.installation_number IS 'WWTP Number from Federal Office for the Environment (FOEN) / ARA-Nummer gemäss Bundesamt für Umwelt (BAFU) / Numéro de la STEP selon l''Office fédéral de l''environnement (OFEV)';


--
-- Name: COLUMN waste_water_treatment_plant.nh4; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.nh4 IS 'yyy_Dimensioning value Ablauf Vorklärung. NH4 [gNH4/m3] / Dimensionierungswert Ablauf Vorklärung. NH4 [gNH4/m3] / Valeur de dimensionnement, NH4 à la sortie du décanteur primaire. NH4 [gNH4/m3]';


--
-- Name: COLUMN waste_water_treatment_plant.start_year; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment_plant.start_year IS 'Start of operation (year) / Jahr der Inbetriebnahme / Année de la mise en exploitation';


--
-- Name: vw_organisation; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation AS
 SELECT
        CASE
            WHEN (cooperative.obj_id IS NOT NULL) THEN 'cooperative'::qgep_od.organisation_type
            WHEN (canton.obj_id IS NOT NULL) THEN 'canton'::qgep_od.organisation_type
            WHEN (waste_water_association.obj_id IS NOT NULL) THEN 'waste_water_association'::qgep_od.organisation_type
            WHEN (municipality.obj_id IS NOT NULL) THEN 'municipality'::qgep_od.organisation_type
            WHEN (administrative_office.obj_id IS NOT NULL) THEN 'administrative_office'::qgep_od.organisation_type
            WHEN (waste_water_treatment_plant.obj_id IS NOT NULL) THEN 'waste_water_treatment_plant'::qgep_od.organisation_type
            WHEN (private.obj_id IS NOT NULL) THEN 'private'::qgep_od.organisation_type
            ELSE 'organisation'::qgep_od.organisation_type
        END AS organisation_type,
    organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider,
        CASE
            WHEN (canton.obj_id IS NOT NULL) THEN canton.perimeter_geometry
            WHEN (municipality.obj_id IS NOT NULL) THEN municipality.perimeter_geometry
            ELSE NULL::public.geometry
        END AS perimeter_geometry,
    municipality.altitude,
    municipality.gwdp_year,
    municipality.municipality_number,
    municipality.population,
    municipality.total_surface,
    waste_water_treatment_plant.bod5,
    waste_water_treatment_plant.cod,
    waste_water_treatment_plant.elimination_cod,
    waste_water_treatment_plant.elimination_n,
    waste_water_treatment_plant.elimination_nh4,
    waste_water_treatment_plant.elimination_p,
    waste_water_treatment_plant.installation_number,
    waste_water_treatment_plant.kind AS waste_water_treatment_plant_kind,
    waste_water_treatment_plant.nh4,
    waste_water_treatment_plant.start_year,
    private.kind AS private_kind
   FROM (((((((qgep_od.organisation organisation
     LEFT JOIN qgep_od.cooperative cooperative ON (((organisation.obj_id)::text = (cooperative.obj_id)::text)))
     LEFT JOIN qgep_od.canton canton ON (((organisation.obj_id)::text = (canton.obj_id)::text)))
     LEFT JOIN qgep_od.waste_water_association waste_water_association ON (((organisation.obj_id)::text = (waste_water_association.obj_id)::text)))
     LEFT JOIN qgep_od.municipality municipality ON (((organisation.obj_id)::text = (municipality.obj_id)::text)))
     LEFT JOIN qgep_od.administrative_office administrative_office ON (((organisation.obj_id)::text = (administrative_office.obj_id)::text)))
     LEFT JOIN qgep_od.waste_water_treatment_plant waste_water_treatment_plant ON (((organisation.obj_id)::text = (waste_water_treatment_plant.obj_id)::text)))
     LEFT JOIN qgep_od.private private ON (((organisation.obj_id)::text = (private.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation OWNER TO postgres;

--
-- Name: vw_organisation_administrative_office; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation_administrative_office AS
 SELECT organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider
   FROM (qgep_od.administrative_office administrative_office
     JOIN qgep_od.organisation organisation ON (((administrative_office.obj_id)::text = (organisation.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation_administrative_office OWNER TO postgres;

--
-- Name: vw_organisation_canton; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation_canton AS
 SELECT organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider,
    canton.perimeter_geometry
   FROM (qgep_od.canton canton
     JOIN qgep_od.organisation organisation ON (((canton.obj_id)::text = (organisation.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation_canton OWNER TO postgres;

--
-- Name: vw_organisation_cooperative; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation_cooperative AS
 SELECT organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider
   FROM (qgep_od.cooperative cooperative
     JOIN qgep_od.organisation organisation ON (((cooperative.obj_id)::text = (organisation.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation_cooperative OWNER TO postgres;

--
-- Name: vw_organisation_municipality; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation_municipality AS
 SELECT organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider,
    municipality.altitude,
    municipality.gwdp_year,
    municipality.municipality_number,
    municipality.perimeter_geometry,
    municipality.population,
    municipality.total_surface
   FROM (qgep_od.municipality municipality
     JOIN qgep_od.organisation organisation ON (((municipality.obj_id)::text = (organisation.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation_municipality OWNER TO postgres;

--
-- Name: vw_organisation_private; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation_private AS
 SELECT organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider,
    private.kind AS private_kind
   FROM (qgep_od.private private
     JOIN qgep_od.organisation organisation ON (((private.obj_id)::text = (organisation.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation_private OWNER TO postgres;

--
-- Name: vw_organisation_waste_water_association; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation_waste_water_association AS
 SELECT organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider
   FROM (qgep_od.waste_water_association waste_water_association
     JOIN qgep_od.organisation organisation ON (((waste_water_association.obj_id)::text = (organisation.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation_waste_water_association OWNER TO postgres;

--
-- Name: vw_organisation_waste_water_treatment_plant; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_organisation_waste_water_treatment_plant AS
 SELECT organisation.obj_id,
    organisation.identifier,
    organisation.remark,
    organisation.uid,
    organisation.last_modification,
    organisation.fk_dataowner,
    organisation.fk_provider,
    waste_water_treatment_plant.bod5,
    waste_water_treatment_plant.cod,
    waste_water_treatment_plant.elimination_cod,
    waste_water_treatment_plant.elimination_n,
    waste_water_treatment_plant.elimination_nh4,
    waste_water_treatment_plant.elimination_p,
    waste_water_treatment_plant.installation_number,
    waste_water_treatment_plant.kind AS waste_water_treatment_plant_kind,
    waste_water_treatment_plant.nh4,
    waste_water_treatment_plant.start_year
   FROM (qgep_od.waste_water_treatment_plant waste_water_treatment_plant
     JOIN qgep_od.organisation organisation ON (((waste_water_treatment_plant.obj_id)::text = (organisation.obj_id)::text)));


ALTER TABLE qgep_od.vw_organisation_waste_water_treatment_plant OWNER TO postgres;

--
-- Name: vw_overflow_leapingweir; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_overflow_leapingweir AS
 SELECT overflow.obj_id,
    overflow.actuation,
    overflow.adjustability,
    overflow.brand,
    overflow.control,
    overflow.discharge_point,
    overflow.function,
    overflow.gross_costs,
    overflow.identifier,
    overflow.qon_dim,
    overflow.remark,
    overflow.signal_transmission,
    overflow.subsidies,
    overflow.last_modification,
    overflow.fk_dataowner,
    overflow.fk_provider,
    overflow.fk_wastewater_node,
    overflow.fk_overflow_to,
    overflow.fk_overflow_characteristic,
    overflow.fk_control_center,
    leapingweir.length,
    leapingweir.opening_shape,
    leapingweir.width
   FROM (qgep_od.leapingweir leapingweir
     JOIN qgep_od.overflow overflow ON (((leapingweir.obj_id)::text = (overflow.obj_id)::text)));


ALTER TABLE qgep_od.vw_overflow_leapingweir OWNER TO postgres;

--
-- Name: vw_overflow_prank_weir; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_overflow_prank_weir AS
 SELECT overflow.obj_id,
    overflow.actuation,
    overflow.adjustability,
    overflow.brand,
    overflow.control,
    overflow.discharge_point,
    overflow.function,
    overflow.gross_costs,
    overflow.identifier,
    overflow.qon_dim,
    overflow.remark,
    overflow.signal_transmission,
    overflow.subsidies,
    overflow.last_modification,
    overflow.fk_dataowner,
    overflow.fk_provider,
    overflow.fk_wastewater_node,
    overflow.fk_overflow_to,
    overflow.fk_overflow_characteristic,
    overflow.fk_control_center,
    prank_weir.hydraulic_overflow_length,
    prank_weir.level_max,
    prank_weir.level_min,
    prank_weir.weir_edge,
    prank_weir.weir_kind
   FROM (qgep_od.prank_weir prank_weir
     JOIN qgep_od.overflow overflow ON (((prank_weir.obj_id)::text = (overflow.obj_id)::text)));


ALTER TABLE qgep_od.vw_overflow_prank_weir OWNER TO postgres;

--
-- Name: vw_overflow_pump; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_overflow_pump AS
 SELECT overflow.obj_id,
    overflow.actuation,
    overflow.adjustability,
    overflow.brand,
    overflow.control,
    overflow.discharge_point,
    overflow.function,
    overflow.gross_costs,
    overflow.identifier,
    overflow.qon_dim,
    overflow.remark,
    overflow.signal_transmission,
    overflow.subsidies,
    overflow.last_modification,
    overflow.fk_dataowner,
    overflow.fk_provider,
    overflow.fk_wastewater_node,
    overflow.fk_overflow_to,
    overflow.fk_overflow_characteristic,
    overflow.fk_control_center,
    pump.contruction_type,
    pump.operating_point,
    pump.placement_of_actuation,
    pump.placement_of_pump,
    pump.pump_flow_max_single,
    pump.pump_flow_min_single,
    pump.start_level,
    pump.stop_level,
    pump.usage_current
   FROM (qgep_od.pump pump
     JOIN qgep_od.overflow overflow ON (((pump.obj_id)::text = (overflow.obj_id)::text)));


ALTER TABLE qgep_od.vw_overflow_pump OWNER TO postgres;

--
-- Name: vw_qgep_damage; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_qgep_damage AS
 SELECT
        CASE
            WHEN (channel.obj_id IS NOT NULL) THEN 'channel'::qgep_od.damage_type
            WHEN (manhole.obj_id IS NOT NULL) THEN 'manhole'::qgep_od.damage_type
            ELSE 'damage'::qgep_od.damage_type
        END AS damage_type,
    damage.obj_id,
    damage.comments,
    damage.connection,
    damage.damage_begin,
    damage.damage_end,
    damage.damage_reach,
    damage.distance,
    damage.quantification1,
    damage.quantification2,
    damage.single_damage_class,
    damage.video_counter,
    damage.view_parameters,
    damage.last_modification,
    damage.fk_dataowner,
    damage.fk_provider,
    damage.fk_examination,
    channel.channel_damage_code,
    manhole.manhole_damage_code,
    manhole.manhole_shaft_area
   FROM ((qgep_od.damage damage
     LEFT JOIN qgep_od.damage_channel channel ON (((damage.obj_id)::text = (channel.obj_id)::text)))
     LEFT JOIN qgep_od.damage_manhole manhole ON (((damage.obj_id)::text = (manhole.obj_id)::text)));


ALTER TABLE qgep_od.vw_qgep_damage OWNER TO postgres;

--
-- Name: vw_qgep_maintenance; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_qgep_maintenance AS
 SELECT
        CASE
            WHEN (examination.obj_id IS NOT NULL) THEN 'examination'::qgep_od.maintenance_type
            ELSE 'maintenance'::qgep_od.maintenance_type
        END AS maintenance_type,
    maintenance.obj_id,
    maintenance.base_data,
    maintenance.cost,
    maintenance.data_details,
    maintenance.duration,
    maintenance.identifier,
    maintenance.kind,
    maintenance.operator,
    maintenance.reason,
    maintenance.remark,
    maintenance.result,
    maintenance.status,
    maintenance.time_point,
    maintenance.last_modification,
    maintenance.fk_dataowner,
    maintenance.fk_provider,
    maintenance.fk_operating_company,
    maintenance.active_zone,
    examination.equipment,
    examination.from_point_identifier,
    examination.inspected_length,
    examination.recording_type,
    examination.to_point_identifier,
    examination.vehicle,
    examination.videonumber,
    examination.weather,
    examination.fk_reach_point
   FROM (qgep_od.maintenance_event maintenance
     LEFT JOIN qgep_od.examination examination ON (((maintenance.obj_id)::text = (examination.obj_id)::text)));


ALTER TABLE qgep_od.vw_qgep_maintenance OWNER TO postgres;

--
-- Name: vw_qgep_overflow; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_qgep_overflow AS
 SELECT
        CASE
            WHEN (leapingweir.obj_id IS NOT NULL) THEN 'leapingweir'::qgep_od.overflow_type
            WHEN (prank_weir.obj_id IS NOT NULL) THEN 'prank_weir'::qgep_od.overflow_type
            WHEN (pump.obj_id IS NOT NULL) THEN 'pump'::qgep_od.overflow_type
            ELSE 'overflow'::qgep_od.overflow_type
        END AS overflow_type,
    overflow.obj_id,
    overflow.actuation,
    overflow.adjustability,
    overflow.brand,
    overflow.control,
    overflow.discharge_point,
    overflow.function,
    overflow.gross_costs,
    overflow.identifier,
    overflow.qon_dim,
    overflow.remark,
    overflow.signal_transmission,
    overflow.subsidies,
    overflow.last_modification,
    overflow.fk_dataowner,
    overflow.fk_provider,
    overflow.fk_wastewater_node,
    overflow.fk_overflow_to,
    overflow.fk_overflow_characteristic,
    overflow.fk_control_center,
    (public.st_makeline(n1.situation_geometry, n2.situation_geometry))::public.geometry(LineString,2056) AS geometry,
    leapingweir.length,
    leapingweir.opening_shape,
    leapingweir.width,
    prank_weir.hydraulic_overflow_length,
    prank_weir.level_max,
    prank_weir.level_min,
    prank_weir.weir_edge,
    prank_weir.weir_kind,
    pump.contruction_type,
    pump.operating_point,
    pump.placement_of_actuation,
    pump.placement_of_pump,
    pump.pump_flow_max_single,
    pump.pump_flow_min_single,
    pump.start_level,
    pump.stop_level,
    pump.usage_current
   FROM (((((qgep_od.overflow overflow
     LEFT JOIN qgep_od.leapingweir leapingweir ON (((overflow.obj_id)::text = (leapingweir.obj_id)::text)))
     LEFT JOIN qgep_od.prank_weir prank_weir ON (((overflow.obj_id)::text = (prank_weir.obj_id)::text)))
     LEFT JOIN qgep_od.pump pump ON (((overflow.obj_id)::text = (pump.obj_id)::text)))
     LEFT JOIN qgep_od.wastewater_node n1 ON (((overflow.fk_wastewater_node)::text = (n1.obj_id)::text)))
     LEFT JOIN qgep_od.wastewater_node n2 ON (((overflow.fk_overflow_to)::text = (n2.obj_id)::text)));


ALTER TABLE qgep_od.vw_qgep_overflow OWNER TO postgres;

--
-- Name: vw_qgep_reach; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_qgep_reach AS
 WITH active_maintenance_event AS (
         SELECT me.obj_id,
            me.identifier,
            me.active_zone,
            mews.fk_wastewater_structure
           FROM (qgep_od.maintenance_event me
             LEFT JOIN qgep_od.re_maintenance_event_wastewater_structure mews ON (((mews.fk_maintenance_event)::text = (me.obj_id)::text)))
          WHERE (me.active_zone IS NOT NULL)
        )
 SELECT re.obj_id,
    re.clear_height,
        CASE
            WHEN (pp.height_width_ratio IS NOT NULL) THEN ((round(((re.clear_height)::numeric * pp.height_width_ratio)))::smallint)::integer
            ELSE re.clear_height
        END AS width,
    re.coefficient_of_friction,
    re.elevation_determination,
    re.horizontal_positioning,
    re.inside_coating,
    re.length_effective,
        CASE
            WHEN ((rp_from.level > (0)::numeric) AND (rp_to.level > (0)::numeric)) THEN round((((rp_from.level - rp_to.level) / NULLIF(re.length_effective, (0)::numeric)) * (1000)::numeric), 1)
            ELSE NULL::numeric
        END AS slope_per_mill,
    re.material,
    re.progression_geometry,
    re.reliner_material,
    re.reliner_nominal_size,
    re.relining_construction,
    re.relining_kind,
    re.ring_stiffness,
    re.slope_building_plan,
    re.wall_roughness,
    re.fk_pipe_profile,
    ch.bedding_encasement,
    ch.function_hierarchic,
    ch.connection_type,
    ch.function_hydraulic,
    ch.jetting_interval,
    ch.pipe_length,
    ch.usage_current,
    ch.usage_planned,
    ws.obj_id AS ws_obj_id,
    ws.accessibility,
    ws.contract_section,
    ws.financing,
    ws.gross_costs,
    ws.inspection_interval,
    ws.location_name,
    ws.records,
    ws.renovation_necessity,
    ws.replacement_value,
    ws.rv_base_year,
    ws.rv_construction_type,
    ws.status,
    ws.structure_condition,
    ws.subsidies,
    ws.year_of_construction,
    ws.year_of_replacement,
    ws.fk_owner,
    ws.fk_operator,
    ne.identifier,
    ne.remark,
    ne.last_modification,
    ne.fk_dataowner,
    ne.fk_provider,
    ne.fk_wastewater_structure,
    rp_from.obj_id AS rp_from_obj_id,
    rp_from.elevation_accuracy AS rp_from_elevation_accuracy,
    rp_from.identifier AS rp_from_identifier,
    rp_from.level AS rp_from_level,
    rp_from.outlet_shape AS rp_from_outlet_shape,
    rp_from.position_of_connection AS rp_from_position_of_connection,
    rp_from.remark AS rp_from_remark,
    rp_from.last_modification AS rp_from_last_modification,
    rp_from.fk_dataowner AS rp_from_fk_dataowner,
    rp_from.fk_provider AS rp_from_fk_provider,
    rp_from.fk_wastewater_networkelement AS rp_from_fk_wastewater_networkelement,
    rp_to.obj_id AS rp_to_obj_id,
    rp_to.elevation_accuracy AS rp_to_elevation_accuracy,
    rp_to.identifier AS rp_to_identifier,
    rp_to.level AS rp_to_level,
    rp_to.outlet_shape AS rp_to_outlet_shape,
    rp_to.position_of_connection AS rp_to_position_of_connection,
    rp_to.remark AS rp_to_remark,
    rp_to.last_modification AS rp_to_last_modification,
    rp_to.fk_dataowner AS rp_to_fk_dataowner,
    rp_to.fk_provider AS rp_to_fk_provider,
    rp_to.fk_wastewater_networkelement AS rp_to_fk_wastewater_networkelement,
    am.obj_id AS me_obj_id,
    am.active_zone AS me_active_zone,
    am.identifier AS me_identifier
   FROM (((((((qgep_od.reach re
     LEFT JOIN qgep_od.wastewater_networkelement ne ON (((ne.obj_id)::text = (re.obj_id)::text)))
     LEFT JOIN qgep_od.reach_point rp_from ON (((rp_from.obj_id)::text = (re.fk_reach_point_from)::text)))
     LEFT JOIN qgep_od.reach_point rp_to ON (((rp_to.obj_id)::text = (re.fk_reach_point_to)::text)))
     LEFT JOIN qgep_od.wastewater_structure ws ON (((ne.fk_wastewater_structure)::text = (ws.obj_id)::text)))
     LEFT JOIN qgep_od.channel ch ON (((ch.obj_id)::text = (ws.obj_id)::text)))
     LEFT JOIN qgep_od.pipe_profile pp ON (((re.fk_pipe_profile)::text = (pp.obj_id)::text)))
     LEFT JOIN active_maintenance_event am ON (((am.fk_wastewater_structure)::text = (ch.obj_id)::text)));


ALTER TABLE qgep_od.vw_qgep_reach OWNER TO postgres;

--
-- Name: vw_wastewater_node; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_wastewater_node AS
 SELECT wn.obj_id,
    wn.backflow_level,
    wn.bottom_level,
    wn.situation_geometry,
    we.identifier,
    we.remark,
    we.fk_dataowner,
    we.fk_provider,
    we.last_modification,
    we.fk_wastewater_structure
   FROM (qgep_od.wastewater_node wn
     LEFT JOIN qgep_od.wastewater_networkelement we ON (((we.obj_id)::text = (wn.obj_id)::text)));


ALTER TABLE qgep_od.vw_wastewater_node OWNER TO postgres;

--
-- Name: vw_qgep_wastewater_structure; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_qgep_wastewater_structure AS
 SELECT ws.obj_id,
    main_co.brand,
    main_co.cover_shape,
    main_co.diameter,
    main_co.fastening,
    main_co.level,
    main_co.material AS cover_material,
    main_co.positional_accuracy,
    aggregated_wastewater_structure.situation_geometry,
    main_co.sludge_bucket,
    main_co.venting,
    main_co_sp.identifier AS co_identifier,
    main_co_sp.remark,
    main_co_sp.renovation_demand,
    main_co_sp.last_modification,
    ws.fk_dataowner,
    ws.fk_provider,
        CASE
            WHEN (mh.obj_id IS NOT NULL) THEN 'manhole'::text
            WHEN (ss.obj_id IS NOT NULL) THEN 'special_structure'::text
            WHEN (dp.obj_id IS NOT NULL) THEN 'discharge_point'::text
            WHEN (ii.obj_id IS NOT NULL) THEN 'infiltration_installation'::text
            ELSE 'unknown'::text
        END AS ws_type,
    main_co.obj_id AS co_obj_id,
    ws.identifier,
    ws.accessibility,
    ws.contract_section,
    ws.financing,
    ws.gross_costs,
    ws.inspection_interval,
    ws.location_name,
    ws.records,
    ws.remark AS ws_remark,
    ws.renovation_necessity,
    ws.replacement_value,
    ws.rv_base_year,
    ws.rv_construction_type,
    ws.status,
    ws.structure_condition,
    ws.subsidies,
    ws.year_of_construction,
    ws.year_of_replacement,
    ws.fk_owner,
    ws.fk_operator,
    ws._label,
    ws._depth,
    COALESCE(mh.dimension1, ii.dimension1) AS dimension1,
    COALESCE(mh.dimension2, ii.dimension2) AS dimension2,
    COALESCE(ss.upper_elevation, dp.upper_elevation, ii.upper_elevation) AS upper_elevation,
    mh.function AS manhole_function,
    mh.material,
    mh.surface_inflow,
    ws._usage_current AS channel_usage_current,
    ws._function_hierarchic AS channel_function_hierarchic,
    mh._orientation AS manhole_orientation,
    ss.bypass,
    ss.function AS special_structure_function,
    ss.stormwater_tank_arrangement,
    dp.highwater_level,
    dp.relevance,
    dp.terrain_level,
    dp.waterlevel_hydraulic,
    ii.absorption_capacity,
    ii.defects,
    ii.distance_to_aquifer,
    ii.effective_area,
    ii.emergency_spillway,
    ii.kind,
    ii.labeling,
    ii.seepage_utilization,
    ii.vehicle_access,
    ii.watertightness,
    wn.obj_id AS wn_obj_id,
    wn.backflow_level,
    wn.bottom_level,
    wn.identifier AS wn_identifier,
    wn.remark AS wn_remark,
    wn.last_modification AS wn_last_modification,
    wn.fk_dataowner AS wn_fk_dataowner,
    wn.fk_provider AS wn_fk_provider
   FROM ((((((((( SELECT ws_1.obj_id,
            (public.st_collect(co.situation_geometry))::public.geometry(MultiPoint,2056) AS situation_geometry,
                CASE
                    WHEN (count(wn_1.obj_id) = 1) THEN min((wn_1.obj_id)::text)
                    ELSE NULL::text
                END AS wn_obj_id
           FROM ((((qgep_od.wastewater_structure ws_1
             FULL JOIN qgep_od.structure_part sp ON (((sp.fk_wastewater_structure)::text = (ws_1.obj_id)::text)))
             LEFT JOIN qgep_od.cover co ON (((co.obj_id)::text = (sp.obj_id)::text)))
             LEFT JOIN qgep_od.wastewater_networkelement ne ON (((ne.fk_wastewater_structure)::text = (ws_1.obj_id)::text)))
             LEFT JOIN qgep_od.wastewater_node wn_1 ON (((wn_1.obj_id)::text = (ne.obj_id)::text)))
          GROUP BY ws_1.obj_id) aggregated_wastewater_structure
     LEFT JOIN qgep_od.wastewater_structure ws ON (((ws.obj_id)::text = (aggregated_wastewater_structure.obj_id)::text)))
     LEFT JOIN qgep_od.cover main_co ON (((main_co.obj_id)::text = (ws.fk_main_cover)::text)))
     LEFT JOIN qgep_od.structure_part main_co_sp ON (((main_co_sp.obj_id)::text = (ws.fk_main_cover)::text)))
     LEFT JOIN qgep_od.manhole mh ON (((mh.obj_id)::text = (ws.obj_id)::text)))
     LEFT JOIN qgep_od.special_structure ss ON (((ss.obj_id)::text = (ws.obj_id)::text)))
     LEFT JOIN qgep_od.discharge_point dp ON (((dp.obj_id)::text = (ws.obj_id)::text)))
     LEFT JOIN qgep_od.infiltration_installation ii ON (((ii.obj_id)::text = (ws.obj_id)::text)))
     LEFT JOIN qgep_od.vw_wastewater_node wn ON (((wn.obj_id)::text = aggregated_wastewater_structure.wn_obj_id)));


ALTER TABLE qgep_od.vw_qgep_wastewater_structure OWNER TO postgres;

--
-- Name: vw_reach; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_reach AS
 SELECT re.obj_id,
    re.clear_height,
    re.coefficient_of_friction,
    re.elevation_determination,
    re.horizontal_positioning,
    re.inside_coating,
    re.length_effective,
    re.material,
    re.progression_geometry,
    re.reliner_material,
    re.reliner_nominal_size,
    re.relining_construction,
    re.relining_kind,
    re.ring_stiffness,
    re.slope_building_plan,
    re.wall_roughness,
    we.identifier,
    we.remark,
    we.fk_dataowner,
    we.fk_provider,
    we.last_modification,
    we.fk_wastewater_structure
   FROM (qgep_od.reach re
     LEFT JOIN qgep_od.wastewater_networkelement we ON (((we.obj_id)::text = (re.obj_id)::text)));


ALTER TABLE qgep_od.vw_reach OWNER TO postgres;

--
-- Name: vw_special_structure; Type: VIEW; Schema: qgep_od; Owner: postgres
--

CREATE VIEW qgep_od.vw_special_structure AS
 SELECT ss.obj_id,
    ss.bypass,
    ws._depth,
    ss.emergency_spillway,
    ss.function,
    ss.stormwater_tank_arrangement,
    ss.upper_elevation,
    ws.accessibility,
    ws.contract_section,
    ws.detail_geometry_geometry,
    ws.financing,
    ws.gross_costs,
    ws.identifier,
    ws.inspection_interval,
    ws.location_name,
    ws.records,
    ws.remark,
    ws.renovation_necessity,
    ws.replacement_value,
    ws.rv_base_year,
    ws.rv_construction_type,
    ws.status,
    ws.structure_condition,
    ws.subsidies,
    ws.year_of_construction,
    ws.year_of_replacement,
    ws.fk_dataowner,
    ws.fk_provider,
    ws.last_modification,
    ws.fk_owner,
    ws.fk_operator
   FROM (qgep_od.special_structure ss
     LEFT JOIN qgep_od.wastewater_structure ws ON (((ws.obj_id)::text = (ss.obj_id)::text)));


ALTER TABLE qgep_od.vw_special_structure OWNER TO postgres;

--
-- Name: waste_water_treatment; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.waste_water_treatment (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'waste_water_treatment'::text) NOT NULL,
    identifier character varying(20),
    kind integer,
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_waste_water_treatment_plant character varying(16)
);


ALTER TABLE qgep_od.waste_water_treatment OWNER TO postgres;

--
-- Name: COLUMN waste_water_treatment.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN waste_water_treatment.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment.kind IS 'Type of wastewater  treatment / Verfahren für die Abwasserbehandlung / Genre de traitement des eaux usées';


--
-- Name: COLUMN waste_water_treatment.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN waste_water_treatment.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN waste_water_treatment.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN waste_water_treatment.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.waste_water_treatment.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: wastewater_structure_symbol; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.wastewater_structure_symbol (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wastewater_structure_symbol'::text) NOT NULL,
    plantype integer,
    symbol_scaling_heigth numeric(2,1),
    symbol_scaling_width numeric(2,1),
    symbolori numeric(4,1),
    symbolpos_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_wastewater_structure character varying(16)
);


ALTER TABLE qgep_od.wastewater_structure_symbol OWNER TO postgres;

--
-- Name: COLUMN wastewater_structure_symbol.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_symbol.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN wastewater_structure_symbol.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_symbol.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN wastewater_structure_symbol.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_symbol.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN wastewater_structure_symbol.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_symbol.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: wastewater_structure_text; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.wastewater_structure_text (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wastewater_structure_text'::text) NOT NULL,
    plantype integer,
    remark character varying(80),
    text text,
    texthali smallint,
    textori numeric(4,1),
    textpos_geometry public.geometry(Point,2056),
    textvali smallint,
    last_modification timestamp without time zone DEFAULT now(),
    fk_wastewater_structure character varying(16)
);


ALTER TABLE qgep_od.wastewater_structure_text OWNER TO postgres;

--
-- Name: COLUMN wastewater_structure_text.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_text.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN wastewater_structure_text.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_text.remark IS 'General remarks';


--
-- Name: COLUMN wastewater_structure_text.text; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_text.text IS 'yyy_Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / Aus Attributwerten zusammengesetzter Wert, mehrzeilig möglich / valeur calculée à partir d’attributs, plusieurs lignes possible';


--
-- Name: COLUMN wastewater_structure_text.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wastewater_structure_text.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: water_body_protection_sector; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.water_body_protection_sector (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'water_body_protection_sector'::text) NOT NULL,
    kind integer,
    perimeter_geometry public.geometry(CurvePolygon,2056)
);


ALTER TABLE qgep_od.water_body_protection_sector OWNER TO postgres;

--
-- Name: COLUMN water_body_protection_sector.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_body_protection_sector.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN water_body_protection_sector.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_body_protection_sector.kind IS 'yyy_Art des Schutzbereiches für  oberflächliches Gewässer und Grundwasser bezüglich Gefährdung / Art des Schutzbereiches für  oberflächliches Gewässer und Grundwasser bezüglich Gefährdung / Type de zones de protection des eaux superficielles et souterraines';


--
-- Name: COLUMN water_body_protection_sector.perimeter_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_body_protection_sector.perimeter_geometry IS 'Boundary points of the perimeter / Begrenzungspunkte der Fläche / Points de délimitation de la surface';


--
-- Name: water_catchment; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.water_catchment (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'water_catchment'::text) NOT NULL,
    identifier character varying(20),
    kind integer,
    remark character varying(80),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_aquifier character varying(16),
    fk_chute character varying(16)
);


ALTER TABLE qgep_od.water_catchment OWNER TO postgres;

--
-- Name: COLUMN water_catchment.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_catchment.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN water_catchment.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_catchment.kind IS 'Type of water catchment / Art der Trinkwasserfassung / Genre de prise d''eau';


--
-- Name: COLUMN water_catchment.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_catchment.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN water_catchment.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_catchment.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: COLUMN water_catchment.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_catchment.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN water_catchment.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_catchment.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN water_catchment.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_catchment.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: water_control_structure; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.water_control_structure (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'water_control_structure'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    situation_geometry public.geometry(Point,2056),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_water_course_segment character varying(16)
);


ALTER TABLE qgep_od.water_control_structure OWNER TO postgres;

--
-- Name: COLUMN water_control_structure.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_control_structure.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN water_control_structure.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_control_structure.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN water_control_structure.situation_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_control_structure.situation_geometry IS 'National position coordinates (East, North) / Landeskoordinate Ost/Nord / Coordonnées nationales Est/Nord';


--
-- Name: COLUMN water_control_structure.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_control_structure.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN water_control_structure.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_control_structure.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN water_control_structure.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_control_structure.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: water_course_segment; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.water_course_segment (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'water_course_segment'::text) NOT NULL,
    algae_growth integer,
    altitudinal_zone integer,
    bed_with numeric(7,2),
    dead_wood integer,
    depth_variability integer,
    discharge_regime integer,
    ecom_classification integer,
    from_geometry public.geometry(Point,2056),
    identifier character varying(20),
    kind integer,
    length_profile integer,
    macrophyte_coverage integer,
    remark character varying(80),
    section_morphology integer,
    size smallint,
    slope integer,
    to_geometry public.geometry(Point,2056),
    utilisation integer,
    water_hardness integer,
    width_variability integer,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_watercourse character varying(16)
);


ALTER TABLE qgep_od.water_course_segment OWNER TO postgres;

--
-- Name: COLUMN water_course_segment.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN water_course_segment.algae_growth; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.algae_growth IS 'Coverage with algae / Bewuchs mit Algen / Couverture végétale par des algues';


--
-- Name: COLUMN water_course_segment.altitudinal_zone; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.altitudinal_zone IS 'Alltiduinal zone of a water course / Höhenstufentypen eines Gewässers / Type d''étage d''altitude des cours d''eau';


--
-- Name: COLUMN water_course_segment.bed_with; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.bed_with IS 'Average bed with / mittlere Sohlenbreite / Largeur moyenne du lit';


--
-- Name: COLUMN water_course_segment.dead_wood; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.dead_wood IS 'Accumulations of dead wood in water course section / Ansammlungen von Totholz im Gewässerabschnitt / Amas de bois mort dans le cours d''eau';


--
-- Name: COLUMN water_course_segment.depth_variability; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.depth_variability IS 'Variability of depth of water course / Variabilität der Gewässertiefe / Variabilité de la profondeur d''eau';


--
-- Name: COLUMN water_course_segment.discharge_regime; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.discharge_regime IS 'yyy_Grad der antropogenen Beeinflussung des charakteristischen Ganges des Abflusses. / Grad der antropogenen Beeinflussung des charakteristischen Ganges des Abflusses. / Degré d''intervention anthropogène sur le régime hydraulique';


--
-- Name: COLUMN water_course_segment.ecom_classification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.ecom_classification IS 'Summary attribut of ecomorphological classification of level F / Summenattribut aus der ökomorphologischen Klassifizierung nach Stufe F / Attribut issu de la classification écomorphologique du niveau R';


--
-- Name: COLUMN water_course_segment.from_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.from_geometry IS 'Position of segment start point in water course / Lage des Abschnittanfangs  im Gewässerverlauf / Situation du début du tronçon';


--
-- Name: COLUMN water_course_segment.length_profile; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.length_profile IS 'Character of length profile / Charakterisierung des Gewässerlängsprofil / Caractérisation du profil en long';


--
-- Name: COLUMN water_course_segment.macrophyte_coverage; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.macrophyte_coverage IS 'Coverage with macrophytes / Bewuchs mit Makrophyten / Couverture végétale par des macrophytes (végétation aquatique (macroscopique))';


--
-- Name: COLUMN water_course_segment.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN water_course_segment.section_morphology; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.section_morphology IS 'yyy_Linienführung eines Gewässerabschnittes / Linienführung eines Gewässerabschnittes / Tracé d''un cours d''eau';


--
-- Name: COLUMN water_course_segment.size; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.size IS 'Classification by Strahler / Ordnungszahl nach Strahler / Classification selon Strahler';


--
-- Name: COLUMN water_course_segment.slope; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.slope IS 'Average slope of water course segment / Mittleres Gefälle des Gewässerabschnittes / Pente moyenne du fond du tronçon cours d''eau';


--
-- Name: COLUMN water_course_segment.to_geometry; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.to_geometry IS 'Position of segment end point in water course / Lage Abschnitt-Ende im Gewässerverlauf / Situation de la fin du tronçon';


--
-- Name: COLUMN water_course_segment.utilisation; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.utilisation IS 'Primary utilisation of water course segment / Primäre Nutzung des Gewässerabschnittes / Utilisation primaire du tronçon de cours d''eau';


--
-- Name: COLUMN water_course_segment.water_hardness; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.water_hardness IS 'Chemical water hardness / Chemische Wasserhärte / Dureté chimique de l''eau';


--
-- Name: COLUMN water_course_segment.width_variability; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.width_variability IS 'yyy_Breitenvariabilität des Wasserspiegels bei niedrigem bis mittlerem Abfluss / Breitenvariabilität des Wasserspiegels bei niedrigem bis mittlerem Abfluss / Variabilité de la largeur du lit mouillé par basses et moyennes eaux';


--
-- Name: COLUMN water_course_segment.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN water_course_segment.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN water_course_segment.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.water_course_segment.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: wwtp_energy_use; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.wwtp_energy_use (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wwtp_energy_use'::text) NOT NULL,
    gas_motor integer,
    heat_pump integer,
    identifier character varying(20),
    remark character varying(80),
    turbining integer,
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16),
    fk_waste_water_treatment_plant character varying(16)
);


ALTER TABLE qgep_od.wwtp_energy_use OWNER TO postgres;

--
-- Name: COLUMN wwtp_energy_use.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN wwtp_energy_use.gas_motor; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.gas_motor IS 'electric power / elektrische Leistung / Puissance électrique';


--
-- Name: COLUMN wwtp_energy_use.heat_pump; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.heat_pump IS 'Energy production based on the heat production on the WWTP / Energienutzung aufgrund des Wärmeanfalls auf der ARA / Utilisation de l''énergie thermique de la STEP';


--
-- Name: COLUMN wwtp_energy_use.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN wwtp_energy_use.turbining; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.turbining IS 'Energy production based on the (bio)gaz production on the WWTP / Energienutzung aufgrund des Gasanfalls auf der ARA / Production d''énergie issue de la production de gaz de la STEP';


--
-- Name: COLUMN wwtp_energy_use.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN wwtp_energy_use.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN wwtp_energy_use.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_energy_use.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: wwtp_structure; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.wwtp_structure (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wwtp_structure'::text) NOT NULL,
    kind integer
);


ALTER TABLE qgep_od.wwtp_structure OWNER TO postgres;

--
-- Name: COLUMN wwtp_structure.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_structure.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN wwtp_structure.kind; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.wwtp_structure.kind IS 'yyy_Art des Beckens oder Verfahrens im ARA Bauwerk / Art des Beckens oder Verfahrens im ARA Bauwerk / Genre de l''l’ouvrage ou genre de traitement dans l''ouvrage STEP';


--
-- Name: zone; Type: TABLE; Schema: qgep_od; Owner: postgres
--

CREATE TABLE qgep_od.zone (
    obj_id character varying(16) DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'zone'::text) NOT NULL,
    identifier character varying(20),
    remark character varying(80),
    last_modification timestamp without time zone DEFAULT now(),
    fk_dataowner character varying(16),
    fk_provider character varying(16)
);


ALTER TABLE qgep_od.zone OWNER TO postgres;

--
-- Name: COLUMN zone.obj_id; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.zone.obj_id IS '[primary_key] INTERLIS STANDARD OID (with Postfix/Präfix) or UUOID, see www.interlis.ch';


--
-- Name: COLUMN zone.remark; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.zone.remark IS 'General remarks / Allgemeine Bemerkungen / Remarques générales';


--
-- Name: COLUMN zone.last_modification; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.zone.last_modification IS 'Last modification / Letzte_Aenderung / Derniere_modification: INTERLIS_1_DATE';


--
-- Name: COLUMN zone.fk_dataowner; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.zone.fk_dataowner IS 'Foreignkey to Metaattribute dataowner (as an organisation) - this is the person or body who is allowed to delete, change or maintain this object / Metaattribut Datenherr ist diejenige Person oder Stelle, die berechtigt ist, diesen Datensatz zu löschen, zu ändern bzw. zu verwalten / Maître des données gestionnaire de données, qui est la personne ou l''organisation autorisée pour gérer, modifier ou supprimer les données de cette table/classe';


--
-- Name: COLUMN zone.fk_provider; Type: COMMENT; Schema: qgep_od; Owner: postgres
--

COMMENT ON COLUMN qgep_od.zone.fk_provider IS 'Foreignkey to Metaattribute provider (as an organisation) - this is the person or body who delivered the data / Metaattribut Datenlieferant ist diejenige Person oder Stelle, die die Daten geliefert hat / FOURNISSEUR DES DONNEES Organisation qui crée l’enregistrement de ces données ';


--
-- Name: dictionary_od_field; Type: TABLE; Schema: qgep_sys; Owner: postgres
--

CREATE TABLE qgep_sys.dictionary_od_field (
    id integer NOT NULL,
    class_id integer,
    attribute_id integer,
    table_name character varying(80),
    field_name character varying(80),
    field_name_en character varying(80),
    field_name_de character varying(100),
    field_name_fr character varying(100),
    field_name_it character varying(100),
    field_name_ro character varying(100),
    field_description_en text,
    field_description_de text,
    field_description_fr text,
    field_description_it text,
    field_description_ro text,
    field_mandatory qgep_od.plantype[],
    field_visible boolean,
    field_datatype character varying(40),
    field_unit_de character varying(20),
    field_unit_description_de character varying(90),
    field_unit_en character varying(20),
    field_unit_description_en character varying(90),
    field_unit_fr character varying(20),
    field_unit_description_fr character varying(90),
    field_unit_it character varying(20),
    field_unit_description_it character varying(90),
    field_unit_ro character varying(20),
    field_unit_description_ro character varying(90),
    field_min numeric,
    field_max numeric
);


ALTER TABLE qgep_sys.dictionary_od_field OWNER TO postgres;

--
-- Name: dictionary_od_field_id_seq; Type: SEQUENCE; Schema: qgep_sys; Owner: postgres
--

CREATE SEQUENCE qgep_sys.dictionary_od_field_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE qgep_sys.dictionary_od_field_id_seq OWNER TO postgres;

--
-- Name: dictionary_od_field_id_seq; Type: SEQUENCE OWNED BY; Schema: qgep_sys; Owner: postgres
--

ALTER SEQUENCE qgep_sys.dictionary_od_field_id_seq OWNED BY qgep_sys.dictionary_od_field.id;


--
-- Name: dictionary_od_table; Type: TABLE; Schema: qgep_sys; Owner: postgres
--

CREATE TABLE qgep_sys.dictionary_od_table (
    id integer NOT NULL,
    tablename text,
    name_en text,
    shortcut_en character(2),
    name_de text,
    shortcut_de character(2),
    name_fr text,
    shortcut_fr character(2),
    name_it text,
    shortcut_it character(4),
    name_ro text,
    shortcut_ro character(4)
);


ALTER TABLE qgep_sys.dictionary_od_table OWNER TO postgres;

--
-- Name: dictionary_od_values; Type: TABLE; Schema: qgep_sys; Owner: postgres
--

CREATE TABLE qgep_sys.dictionary_od_values (
    id integer NOT NULL,
    class_id integer,
    attribute_id integer,
    value_id integer,
    table_name character varying(80),
    field_name character varying(80),
    value_name character varying(100),
    value_name_en character varying(80),
    shortcut_en character(3),
    value_name_de character varying(100),
    shortcut_de character(3),
    value_name_fr character varying(100),
    shortcut_fr character(3),
    value_name_it character varying(100),
    shortcut_it character(3),
    value_name_ro character varying(100),
    shortcut_ro character(3),
    value_description_en text,
    value_description_de text,
    value_description_fr text,
    value_description_it text,
    value_description_ro text
);


ALTER TABLE qgep_sys.dictionary_od_values OWNER TO postgres;

--
-- Name: dictionary_od_values_id_seq; Type: SEQUENCE; Schema: qgep_sys; Owner: postgres
--

CREATE SEQUENCE qgep_sys.dictionary_od_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE qgep_sys.dictionary_od_values_id_seq OWNER TO postgres;

--
-- Name: dictionary_od_values_id_seq; Type: SEQUENCE OWNED BY; Schema: qgep_sys; Owner: postgres
--

ALTER SEQUENCE qgep_sys.dictionary_od_values_id_seq OWNED BY qgep_sys.dictionary_od_values.id;


--
-- Name: dictionary_value_list; Type: VIEW; Schema: qgep_sys; Owner: postgres
--

CREATE VIEW qgep_sys.dictionary_value_list AS
 SELECT p.relname AS vl_name,
    vl.code,
    vl.vsacode,
    vl.value_en,
    vl.value_de,
    vl.value_fr,
    vl.value_it,
    vl.value_ro,
    vl.abbr_en,
    vl.abbr_de,
    vl.abbr_fr,
    vl.abbr_it,
    vl.abbr_ro,
    vl.active
   FROM qgep_sys.value_list_base vl,
    pg_class p
  WHERE (vl.tableoid = p.oid);


ALTER TABLE qgep_sys.dictionary_value_list OWNER TO postgres;

--
-- Name: logged_actions; Type: TABLE; Schema: qgep_sys; Owner: postgres
--

CREATE TABLE qgep_sys.logged_actions (
    event_id bigint NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    relid oid NOT NULL,
    session_user_name text,
    action_tstamp_tx timestamp with time zone NOT NULL,
    action_tstamp_stm timestamp with time zone NOT NULL,
    action_tstamp_clk timestamp with time zone NOT NULL,
    transaction_id bigint,
    application_name text,
    client_addr inet,
    client_port integer,
    client_query text NOT NULL,
    action text NOT NULL,
    row_data public.hstore,
    changed_fields public.hstore,
    statement_only boolean NOT NULL,
    CONSTRAINT logged_actions_action_check CHECK ((action = ANY (ARRAY['I'::text, 'D'::text, 'U'::text, 'T'::text])))
);


ALTER TABLE qgep_sys.logged_actions OWNER TO postgres;

--
-- Name: TABLE logged_actions; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON TABLE qgep_sys.logged_actions IS 'History of auditable actions on audited tables, from qgep_sys.if_modified_func()';


--
-- Name: COLUMN logged_actions.event_id; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.event_id IS 'Unique identifier for each auditable event';


--
-- Name: COLUMN logged_actions.schema_name; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.schema_name IS 'Database schema audited table for this event is in';


--
-- Name: COLUMN logged_actions.table_name; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.table_name IS 'Non-schema-qualified table name of table event occured in';


--
-- Name: COLUMN logged_actions.relid; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.relid IS 'Table OID. Changes with drop/create. Get with ''tablename''::regclass';


--
-- Name: COLUMN logged_actions.session_user_name; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.session_user_name IS 'Login / session user whose statement caused the audited event';


--
-- Name: COLUMN logged_actions.action_tstamp_tx; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.action_tstamp_tx IS 'Transaction start timestamp for tx in which audited event occurred';


--
-- Name: COLUMN logged_actions.action_tstamp_stm; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.action_tstamp_stm IS 'Statement start timestamp for tx in which audited event occurred';


--
-- Name: COLUMN logged_actions.action_tstamp_clk; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.action_tstamp_clk IS 'Wall clock time at which audited event''s trigger call occurred';


--
-- Name: COLUMN logged_actions.transaction_id; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.transaction_id IS 'Identifier of transaction that made the change. May wrap, but unique paired with action_tstamp_tx.';


--
-- Name: COLUMN logged_actions.application_name; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.application_name IS 'Application name set when this audit event occurred. Can be changed in-session by client.';


--
-- Name: COLUMN logged_actions.client_addr; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.client_addr IS 'IP address of client that issued query. Null for unix domain socket.';


--
-- Name: COLUMN logged_actions.client_port; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.client_port IS 'Remote peer IP port address of client that issued query. Undefined for unix socket.';


--
-- Name: COLUMN logged_actions.client_query; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.client_query IS 'Top-level query that caused this auditable event. May be more than one statement.';


--
-- Name: COLUMN logged_actions.action; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.action IS 'Action type; I = insert, D = delete, U = update, T = truncate';


--
-- Name: COLUMN logged_actions.row_data; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.row_data IS 'Record value. Null for statement-level trigger. For INSERT this is the new tuple. For DELETE and UPDATE it is the old tuple.';


--
-- Name: COLUMN logged_actions.changed_fields; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.changed_fields IS 'New values of fields changed by UPDATE. Null except for row-level UPDATE events.';


--
-- Name: COLUMN logged_actions.statement_only; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON COLUMN qgep_sys.logged_actions.statement_only IS '''t'' if audit event is from an FOR EACH STATEMENT trigger, ''f'' for FOR EACH ROW';


--
-- Name: logged_actions_event_id_seq; Type: SEQUENCE; Schema: qgep_sys; Owner: postgres
--

CREATE SEQUENCE qgep_sys.logged_actions_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE qgep_sys.logged_actions_event_id_seq OWNER TO postgres;

--
-- Name: logged_actions_event_id_seq; Type: SEQUENCE OWNED BY; Schema: qgep_sys; Owner: postgres
--

ALTER SEQUENCE qgep_sys.logged_actions_event_id_seq OWNED BY qgep_sys.logged_actions.event_id;


--
-- Name: oid_prefixes; Type: TABLE; Schema: qgep_sys; Owner: postgres
--

CREATE TABLE qgep_sys.oid_prefixes (
    id integer NOT NULL,
    prefix character(8),
    organization text,
    active boolean
);


ALTER TABLE qgep_sys.oid_prefixes OWNER TO postgres;

--
-- Name: TABLE oid_prefixes; Type: COMMENT; Schema: qgep_sys; Owner: postgres
--

COMMENT ON TABLE qgep_sys.oid_prefixes IS 'This table contains OID prefixes for different communities or organizations. The application or administrator changing this table has to make sure that only one record is set to active.';


--
-- Name: oid_prefixes_id_seq; Type: SEQUENCE; Schema: qgep_sys; Owner: postgres
--

CREATE SEQUENCE qgep_sys.oid_prefixes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE qgep_sys.oid_prefixes_id_seq OWNER TO postgres;

--
-- Name: oid_prefixes_id_seq; Type: SEQUENCE OWNED BY; Schema: qgep_sys; Owner: postgres
--

ALTER SEQUENCE qgep_sys.oid_prefixes_id_seq OWNED BY qgep_sys.oid_prefixes.id;


--
-- Name: pum_info; Type: TABLE; Schema: qgep_sys; Owner: postgres
--

CREATE TABLE qgep_sys.pum_info (
    id integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type integer NOT NULL,
    script character varying(1000) NOT NULL,
    checksum character varying(32) NOT NULL,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE qgep_sys.pum_info OWNER TO postgres;

--
-- Name: pum_info_id_seq; Type: SEQUENCE; Schema: qgep_sys; Owner: postgres
--

CREATE SEQUENCE qgep_sys.pum_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE qgep_sys.pum_info_id_seq OWNER TO postgres;

--
-- Name: pum_info_id_seq; Type: SEQUENCE OWNED BY; Schema: qgep_sys; Owner: postgres
--

ALTER SEQUENCE qgep_sys.pum_info_id_seq OWNED BY qgep_sys.pum_info.id;


--
-- Name: access_aid_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.access_aid_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.access_aid_kind OWNER TO postgres;

--
-- Name: backflow_prevention_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.backflow_prevention_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.backflow_prevention_kind OWNER TO postgres;

--
-- Name: benching_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.benching_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.benching_kind OWNER TO postgres;

--
-- Name: catchment_area_direct_discharge_current; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_direct_discharge_current (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_direct_discharge_current OWNER TO postgres;

--
-- Name: catchment_area_direct_discharge_planned; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_direct_discharge_planned (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_direct_discharge_planned OWNER TO postgres;

--
-- Name: catchment_area_drainage_system_current; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_drainage_system_current (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_drainage_system_current OWNER TO postgres;

--
-- Name: catchment_area_drainage_system_planned; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_drainage_system_planned (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_drainage_system_planned OWNER TO postgres;

--
-- Name: catchment_area_infiltration_current; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_infiltration_current (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_infiltration_current OWNER TO postgres;

--
-- Name: catchment_area_infiltration_planned; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_infiltration_planned (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_infiltration_planned OWNER TO postgres;

--
-- Name: catchment_area_retention_current; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_retention_current (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_retention_current OWNER TO postgres;

--
-- Name: catchment_area_retention_planned; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_retention_planned (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_retention_planned OWNER TO postgres;

--
-- Name: catchment_area_text_plantype; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_text_plantype (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_text_plantype OWNER TO postgres;

--
-- Name: catchment_area_text_texthali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_text_texthali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_text_texthali OWNER TO postgres;

--
-- Name: catchment_area_text_textvali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.catchment_area_text_textvali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.catchment_area_text_textvali OWNER TO postgres;

--
-- Name: channel_bedding_encasement; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.channel_bedding_encasement (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.channel_bedding_encasement OWNER TO postgres;

--
-- Name: channel_connection_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.channel_connection_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.channel_connection_type OWNER TO postgres;

--
-- Name: channel_function_hierarchic; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.channel_function_hierarchic (
    order_fct_hierarchic smallint
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.channel_function_hierarchic OWNER TO postgres;

--
-- Name: channel_function_hydraulic; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.channel_function_hydraulic (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.channel_function_hydraulic OWNER TO postgres;

--
-- Name: channel_usage_current; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.channel_usage_current (
    order_usage_current smallint
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.channel_usage_current OWNER TO postgres;

--
-- Name: channel_usage_planned; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.channel_usage_planned (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.channel_usage_planned OWNER TO postgres;

--
-- Name: chute_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.chute_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.chute_kind OWNER TO postgres;

--
-- Name: chute_material; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.chute_material (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.chute_material OWNER TO postgres;

--
-- Name: cover_cover_shape; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.cover_cover_shape (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.cover_cover_shape OWNER TO postgres;

--
-- Name: cover_fastening; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.cover_fastening (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.cover_fastening OWNER TO postgres;

--
-- Name: cover_material; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.cover_material (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.cover_material OWNER TO postgres;

--
-- Name: cover_positional_accuracy; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.cover_positional_accuracy (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.cover_positional_accuracy OWNER TO postgres;

--
-- Name: cover_sludge_bucket; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.cover_sludge_bucket (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.cover_sludge_bucket OWNER TO postgres;

--
-- Name: cover_venting; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.cover_venting (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.cover_venting OWNER TO postgres;

--
-- Name: dam_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.dam_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.dam_kind OWNER TO postgres;

--
-- Name: damage_channel_channel_damage_code; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.damage_channel_channel_damage_code (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.damage_channel_channel_damage_code OWNER TO postgres;

--
-- Name: damage_connection; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.damage_connection (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.damage_connection OWNER TO postgres;

--
-- Name: damage_manhole_manhole_damage_code; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.damage_manhole_manhole_damage_code (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.damage_manhole_manhole_damage_code OWNER TO postgres;

--
-- Name: damage_manhole_manhole_shaft_area; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.damage_manhole_manhole_shaft_area (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.damage_manhole_manhole_shaft_area OWNER TO postgres;

--
-- Name: damage_single_damage_class; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.damage_single_damage_class (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.damage_single_damage_class OWNER TO postgres;

--
-- Name: data_media_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.data_media_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.data_media_kind OWNER TO postgres;

--
-- Name: discharge_point_relevance; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.discharge_point_relevance (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.discharge_point_relevance OWNER TO postgres;

--
-- Name: drainage_system_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.drainage_system_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.drainage_system_kind OWNER TO postgres;

--
-- Name: dryweather_flume_material; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.dryweather_flume_material (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.dryweather_flume_material OWNER TO postgres;

--
-- Name: electric_equipment_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.electric_equipment_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.electric_equipment_kind OWNER TO postgres;

--
-- Name: electromechanical_equipment_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.electromechanical_equipment_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.electromechanical_equipment_kind OWNER TO postgres;

--
-- Name: examination_recording_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.examination_recording_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.examination_recording_type OWNER TO postgres;

--
-- Name: examination_weather; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.examination_weather (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.examination_weather OWNER TO postgres;

--
-- Name: file_class; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.file_class (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.file_class OWNER TO postgres;

--
-- Name: file_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.file_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.file_kind OWNER TO postgres;

--
-- Name: groundwater_protection_zone_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.groundwater_protection_zone_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.groundwater_protection_zone_kind OWNER TO postgres;

--
-- Name: hydraulic_char_data_is_overflowing; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.hydraulic_char_data_is_overflowing (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.hydraulic_char_data_is_overflowing OWNER TO postgres;

--
-- Name: hydraulic_char_data_main_weir_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.hydraulic_char_data_main_weir_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.hydraulic_char_data_main_weir_kind OWNER TO postgres;

--
-- Name: hydraulic_char_data_pump_characteristics; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.hydraulic_char_data_pump_characteristics (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.hydraulic_char_data_pump_characteristics OWNER TO postgres;

--
-- Name: hydraulic_char_data_pump_usage_current; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.hydraulic_char_data_pump_usage_current (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.hydraulic_char_data_pump_usage_current OWNER TO postgres;

--
-- Name: hydraulic_char_data_status; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.hydraulic_char_data_status (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.hydraulic_char_data_status OWNER TO postgres;

--
-- Name: individual_surface_function; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.individual_surface_function (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.individual_surface_function OWNER TO postgres;

--
-- Name: individual_surface_pavement; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.individual_surface_pavement (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.individual_surface_pavement OWNER TO postgres;

--
-- Name: infiltration_installation_defects; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_installation_defects (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_installation_defects OWNER TO postgres;

--
-- Name: infiltration_installation_emergency_spillway; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_installation_emergency_spillway (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_installation_emergency_spillway OWNER TO postgres;

--
-- Name: infiltration_installation_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_installation_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_installation_kind OWNER TO postgres;

--
-- Name: infiltration_installation_labeling; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_installation_labeling (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_installation_labeling OWNER TO postgres;

--
-- Name: infiltration_installation_seepage_utilization; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_installation_seepage_utilization (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_installation_seepage_utilization OWNER TO postgres;

--
-- Name: infiltration_installation_vehicle_access; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_installation_vehicle_access (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_installation_vehicle_access OWNER TO postgres;

--
-- Name: infiltration_installation_watertightness; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_installation_watertightness (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_installation_watertightness OWNER TO postgres;

--
-- Name: infiltration_zone_infiltration_capacity; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.infiltration_zone_infiltration_capacity (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.infiltration_zone_infiltration_capacity OWNER TO postgres;

--
-- Name: leapingweir_opening_shape; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.leapingweir_opening_shape (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.leapingweir_opening_shape OWNER TO postgres;

--
-- Name: maintenance_event_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.maintenance_event_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.maintenance_event_kind OWNER TO postgres;

--
-- Name: maintenance_event_status; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.maintenance_event_status (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.maintenance_event_status OWNER TO postgres;

--
-- Name: manhole_function; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.manhole_function (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.manhole_function OWNER TO postgres;

--
-- Name: manhole_material; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.manhole_material (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.manhole_material OWNER TO postgres;

--
-- Name: manhole_surface_inflow; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.manhole_surface_inflow (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.manhole_surface_inflow OWNER TO postgres;

--
-- Name: measurement_result_measurement_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.measurement_result_measurement_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.measurement_result_measurement_type OWNER TO postgres;

--
-- Name: measurement_series_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.measurement_series_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.measurement_series_kind OWNER TO postgres;

--
-- Name: measuring_device_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.measuring_device_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.measuring_device_kind OWNER TO postgres;

--
-- Name: measuring_point_damming_device; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.measuring_point_damming_device (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.measuring_point_damming_device OWNER TO postgres;

--
-- Name: measuring_point_purpose; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.measuring_point_purpose (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.measuring_point_purpose OWNER TO postgres;

--
-- Name: mechanical_pretreatment_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.mechanical_pretreatment_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.mechanical_pretreatment_kind OWNER TO postgres;

--
-- Name: mutation_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.mutation_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.mutation_kind OWNER TO postgres;

--
-- Name: overflow_actuation; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.overflow_actuation (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.overflow_actuation OWNER TO postgres;

--
-- Name: overflow_adjustability; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.overflow_adjustability (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.overflow_adjustability OWNER TO postgres;

--
-- Name: overflow_char_kind_overflow_characteristic; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.overflow_char_kind_overflow_characteristic (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.overflow_char_kind_overflow_characteristic OWNER TO postgres;

--
-- Name: overflow_char_overflow_characteristic_digital; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.overflow_char_overflow_characteristic_digital (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.overflow_char_overflow_characteristic_digital OWNER TO postgres;

--
-- Name: overflow_control; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.overflow_control (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.overflow_control OWNER TO postgres;

--
-- Name: overflow_function; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.overflow_function (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.overflow_function OWNER TO postgres;

--
-- Name: overflow_signal_transmission; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.overflow_signal_transmission (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.overflow_signal_transmission OWNER TO postgres;

--
-- Name: pipe_profile_profile_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.pipe_profile_profile_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.pipe_profile_profile_type OWNER TO postgres;

--
-- Name: planning_zone_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.planning_zone_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.planning_zone_kind OWNER TO postgres;

--
-- Name: prank_weir_weir_edge; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.prank_weir_weir_edge (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.prank_weir_weir_edge OWNER TO postgres;

--
-- Name: prank_weir_weir_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.prank_weir_weir_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.prank_weir_weir_kind OWNER TO postgres;

--
-- Name: pump_contruction_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.pump_contruction_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.pump_contruction_type OWNER TO postgres;

--
-- Name: pump_placement_of_actuation; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.pump_placement_of_actuation (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.pump_placement_of_actuation OWNER TO postgres;

--
-- Name: pump_placement_of_pump; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.pump_placement_of_pump (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.pump_placement_of_pump OWNER TO postgres;

--
-- Name: pump_usage_current; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.pump_usage_current (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.pump_usage_current OWNER TO postgres;

--
-- Name: reach_elevation_determination; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_elevation_determination (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_elevation_determination OWNER TO postgres;

--
-- Name: reach_horizontal_positioning; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_horizontal_positioning (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_horizontal_positioning OWNER TO postgres;

--
-- Name: reach_inside_coating; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_inside_coating (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_inside_coating OWNER TO postgres;

--
-- Name: reach_point_elevation_accuracy; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_point_elevation_accuracy (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_point_elevation_accuracy OWNER TO postgres;

--
-- Name: reach_point_outlet_shape; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_point_outlet_shape (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_point_outlet_shape OWNER TO postgres;

--
-- Name: reach_reliner_material; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_reliner_material (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_reliner_material OWNER TO postgres;

--
-- Name: reach_relining_construction; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_relining_construction (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_relining_construction OWNER TO postgres;

--
-- Name: reach_relining_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_relining_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_relining_kind OWNER TO postgres;

--
-- Name: reach_text_plantype; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_text_plantype (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_text_plantype OWNER TO postgres;

--
-- Name: reach_text_texthali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_text_texthali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_text_texthali OWNER TO postgres;

--
-- Name: reach_text_textvali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.reach_text_textvali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.reach_text_textvali OWNER TO postgres;

--
-- Name: retention_body_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.retention_body_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.retention_body_kind OWNER TO postgres;

--
-- Name: river_bank_control_grade_of_river; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bank_control_grade_of_river (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bank_control_grade_of_river OWNER TO postgres;

--
-- Name: river_bank_river_control_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bank_river_control_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bank_river_control_type OWNER TO postgres;

--
-- Name: river_bank_shores; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bank_shores (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bank_shores OWNER TO postgres;

--
-- Name: river_bank_side; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bank_side (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bank_side OWNER TO postgres;

--
-- Name: river_bank_utilisation_of_shore_surroundings; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bank_utilisation_of_shore_surroundings (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bank_utilisation_of_shore_surroundings OWNER TO postgres;

--
-- Name: river_bank_vegetation; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bank_vegetation (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bank_vegetation OWNER TO postgres;

--
-- Name: river_bed_control_grade_of_river; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bed_control_grade_of_river (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bed_control_grade_of_river OWNER TO postgres;

--
-- Name: river_bed_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bed_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bed_kind OWNER TO postgres;

--
-- Name: river_bed_river_control_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_bed_river_control_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_bed_river_control_type OWNER TO postgres;

--
-- Name: river_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.river_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.river_kind OWNER TO postgres;

--
-- Name: rock_ramp_stabilisation; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.rock_ramp_stabilisation (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.rock_ramp_stabilisation OWNER TO postgres;

--
-- Name: sector_water_body_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.sector_water_body_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.sector_water_body_kind OWNER TO postgres;

--
-- Name: sludge_treatment_stabilisation; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.sludge_treatment_stabilisation (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.sludge_treatment_stabilisation OWNER TO postgres;

--
-- Name: solids_retention_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.solids_retention_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.solids_retention_type OWNER TO postgres;

--
-- Name: special_structure_bypass; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.special_structure_bypass (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.special_structure_bypass OWNER TO postgres;

--
-- Name: special_structure_emergency_spillway; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.special_structure_emergency_spillway (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.special_structure_emergency_spillway OWNER TO postgres;

--
-- Name: special_structure_function; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.special_structure_function (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.special_structure_function OWNER TO postgres;

--
-- Name: special_structure_stormwater_tank_arrangement; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.special_structure_stormwater_tank_arrangement (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.special_structure_stormwater_tank_arrangement OWNER TO postgres;

--
-- Name: structure_part_renovation_demand; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.structure_part_renovation_demand (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.structure_part_renovation_demand OWNER TO postgres;

--
-- Name: symbol_plantype; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.symbol_plantype (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.symbol_plantype OWNER TO postgres;

--
-- Name: tank_cleaning_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.tank_cleaning_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.tank_cleaning_type OWNER TO postgres;

--
-- Name: tank_emptying_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.tank_emptying_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.tank_emptying_type OWNER TO postgres;

--
-- Name: text_plantype; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.text_plantype (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.text_plantype OWNER TO postgres;

--
-- Name: text_texthali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.text_texthali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.text_texthali OWNER TO postgres;

--
-- Name: text_textvali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.text_textvali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.text_textvali OWNER TO postgres;

--
-- Name: throttle_shut_off_unit_actuation; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.throttle_shut_off_unit_actuation (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.throttle_shut_off_unit_actuation OWNER TO postgres;

--
-- Name: throttle_shut_off_unit_adjustability; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.throttle_shut_off_unit_adjustability (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.throttle_shut_off_unit_adjustability OWNER TO postgres;

--
-- Name: throttle_shut_off_unit_control; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.throttle_shut_off_unit_control (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.throttle_shut_off_unit_control OWNER TO postgres;

--
-- Name: throttle_shut_off_unit_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.throttle_shut_off_unit_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.throttle_shut_off_unit_kind OWNER TO postgres;

--
-- Name: throttle_shut_off_unit_signal_transmission; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.throttle_shut_off_unit_signal_transmission (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.throttle_shut_off_unit_signal_transmission OWNER TO postgres;

--
-- Name: waste_water_treatment_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.waste_water_treatment_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.waste_water_treatment_kind OWNER TO postgres;

--
-- Name: wastewater_structure_accessibility; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_accessibility (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_accessibility OWNER TO postgres;

--
-- Name: wastewater_structure_financing; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_financing (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_financing OWNER TO postgres;

--
-- Name: wastewater_structure_renovation_necessity; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_renovation_necessity (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_renovation_necessity OWNER TO postgres;

--
-- Name: wastewater_structure_rv_construction_type; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_rv_construction_type (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_rv_construction_type OWNER TO postgres;

--
-- Name: wastewater_structure_status; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_status (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_status OWNER TO postgres;

--
-- Name: wastewater_structure_structure_condition; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_structure_condition (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_structure_condition OWNER TO postgres;

--
-- Name: wastewater_structure_symbol_plantype; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_symbol_plantype (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_symbol_plantype OWNER TO postgres;

--
-- Name: wastewater_structure_text_plantype; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_text_plantype (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_text_plantype OWNER TO postgres;

--
-- Name: wastewater_structure_text_texthali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_text_texthali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_text_texthali OWNER TO postgres;

--
-- Name: wastewater_structure_text_textvali; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wastewater_structure_text_textvali (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wastewater_structure_text_textvali OWNER TO postgres;

--
-- Name: water_body_protection_sector_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_body_protection_sector_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_body_protection_sector_kind OWNER TO postgres;

--
-- Name: water_catchment_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_catchment_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_catchment_kind OWNER TO postgres;

--
-- Name: water_course_segment_algae_growth; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_algae_growth (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_algae_growth OWNER TO postgres;

--
-- Name: water_course_segment_altitudinal_zone; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_altitudinal_zone (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_altitudinal_zone OWNER TO postgres;

--
-- Name: water_course_segment_dead_wood; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_dead_wood (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_dead_wood OWNER TO postgres;

--
-- Name: water_course_segment_depth_variability; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_depth_variability (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_depth_variability OWNER TO postgres;

--
-- Name: water_course_segment_discharge_regime; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_discharge_regime (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_discharge_regime OWNER TO postgres;

--
-- Name: water_course_segment_ecom_classification; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_ecom_classification (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_ecom_classification OWNER TO postgres;

--
-- Name: water_course_segment_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_kind OWNER TO postgres;

--
-- Name: water_course_segment_length_profile; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_length_profile (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_length_profile OWNER TO postgres;

--
-- Name: water_course_segment_macrophyte_coverage; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_macrophyte_coverage (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_macrophyte_coverage OWNER TO postgres;

--
-- Name: water_course_segment_section_morphology; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_section_morphology (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_section_morphology OWNER TO postgres;

--
-- Name: water_course_segment_slope; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_slope (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_slope OWNER TO postgres;

--
-- Name: water_course_segment_utilisation; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_utilisation (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_utilisation OWNER TO postgres;

--
-- Name: water_course_segment_water_hardness; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_water_hardness (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_water_hardness OWNER TO postgres;

--
-- Name: water_course_segment_width_variability; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.water_course_segment_width_variability (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.water_course_segment_width_variability OWNER TO postgres;

--
-- Name: wwtp_structure_kind; Type: TABLE; Schema: qgep_vl; Owner: postgres
--

CREATE TABLE qgep_vl.wwtp_structure_kind (
)
INHERITS (qgep_sys.value_list_base);


ALTER TABLE qgep_vl.wwtp_structure_kind OWNER TO postgres;

--
-- Name: vw_qgep_reach obj_id; Type: DEFAULT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.vw_qgep_reach ALTER COLUMN obj_id SET DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'reach'::text);


--
-- Name: vw_qgep_reach fk_wastewater_structure; Type: DEFAULT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.vw_qgep_reach ALTER COLUMN fk_wastewater_structure SET DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'channel'::text);


--
-- Name: vw_qgep_reach rp_from_obj_id; Type: DEFAULT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.vw_qgep_reach ALTER COLUMN rp_from_obj_id SET DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'reach_point'::text);


--
-- Name: vw_qgep_reach rp_to_obj_id; Type: DEFAULT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.vw_qgep_reach ALTER COLUMN rp_to_obj_id SET DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'reach_point'::text);


--
-- Name: vw_qgep_wastewater_structure obj_id; Type: DEFAULT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.vw_qgep_wastewater_structure ALTER COLUMN obj_id SET DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'wastewater_structure'::text);


--
-- Name: vw_qgep_wastewater_structure co_obj_id; Type: DEFAULT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.vw_qgep_wastewater_structure ALTER COLUMN co_obj_id SET DEFAULT qgep_sys.generate_oid('qgep_od'::text, 'structure_part'::text);


--
-- Name: dictionary_od_field id; Type: DEFAULT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_field ALTER COLUMN id SET DEFAULT nextval('qgep_sys.dictionary_od_field_id_seq'::regclass);


--
-- Name: dictionary_od_values id; Type: DEFAULT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_values ALTER COLUMN id SET DEFAULT nextval('qgep_sys.dictionary_od_values_id_seq'::regclass);


--
-- Name: logged_actions event_id; Type: DEFAULT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.logged_actions ALTER COLUMN event_id SET DEFAULT nextval('qgep_sys.logged_actions_event_id_seq'::regclass);


--
-- Name: oid_prefixes id; Type: DEFAULT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.oid_prefixes ALTER COLUMN id SET DEFAULT nextval('qgep_sys.oid_prefixes_id_seq'::regclass);


--
-- Name: pum_info id; Type: DEFAULT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.pum_info ALTER COLUMN id SET DEFAULT nextval('qgep_sys.pum_info_id_seq'::regclass);


--
-- Name: access_aid pkey_qgep_od_access_aid_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.access_aid
    ADD CONSTRAINT pkey_qgep_od_access_aid_obj_id PRIMARY KEY (obj_id);


--
-- Name: accident pkey_qgep_od_accident_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.accident
    ADD CONSTRAINT pkey_qgep_od_accident_obj_id PRIMARY KEY (obj_id);


--
-- Name: administrative_office pkey_qgep_od_administrative_office_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.administrative_office
    ADD CONSTRAINT pkey_qgep_od_administrative_office_obj_id PRIMARY KEY (obj_id);


--
-- Name: aquifier pkey_qgep_od_aquifier_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.aquifier
    ADD CONSTRAINT pkey_qgep_od_aquifier_obj_id PRIMARY KEY (obj_id);


--
-- Name: backflow_prevention pkey_qgep_od_backflow_prevention_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.backflow_prevention
    ADD CONSTRAINT pkey_qgep_od_backflow_prevention_obj_id PRIMARY KEY (obj_id);


--
-- Name: bathing_area pkey_qgep_od_bathing_area_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.bathing_area
    ADD CONSTRAINT pkey_qgep_od_bathing_area_obj_id PRIMARY KEY (obj_id);


--
-- Name: benching pkey_qgep_od_benching_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.benching
    ADD CONSTRAINT pkey_qgep_od_benching_obj_id PRIMARY KEY (obj_id);


--
-- Name: blocking_debris pkey_qgep_od_blocking_debris_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.blocking_debris
    ADD CONSTRAINT pkey_qgep_od_blocking_debris_obj_id PRIMARY KEY (obj_id);


--
-- Name: building pkey_qgep_od_building_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.building
    ADD CONSTRAINT pkey_qgep_od_building_obj_id PRIMARY KEY (obj_id);


--
-- Name: canton pkey_qgep_od_canton_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.canton
    ADD CONSTRAINT pkey_qgep_od_canton_obj_id PRIMARY KEY (obj_id);


--
-- Name: catchment_area pkey_qgep_od_catchment_area_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT pkey_qgep_od_catchment_area_obj_id PRIMARY KEY (obj_id);


--
-- Name: catchment_area_text pkey_qgep_od_catchment_area_text_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area_text
    ADD CONSTRAINT pkey_qgep_od_catchment_area_text_obj_id PRIMARY KEY (obj_id);


--
-- Name: channel pkey_qgep_od_channel_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT pkey_qgep_od_channel_obj_id PRIMARY KEY (obj_id);


--
-- Name: chute pkey_qgep_od_chute_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.chute
    ADD CONSTRAINT pkey_qgep_od_chute_obj_id PRIMARY KEY (obj_id);


--
-- Name: connection_object pkey_qgep_od_connection_object_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.connection_object
    ADD CONSTRAINT pkey_qgep_od_connection_object_obj_id PRIMARY KEY (obj_id);


--
-- Name: control_center pkey_qgep_od_control_center_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.control_center
    ADD CONSTRAINT pkey_qgep_od_control_center_obj_id PRIMARY KEY (obj_id);


--
-- Name: cooperative pkey_qgep_od_cooperative_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cooperative
    ADD CONSTRAINT pkey_qgep_od_cooperative_obj_id PRIMARY KEY (obj_id);


--
-- Name: cover pkey_qgep_od_cover_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT pkey_qgep_od_cover_obj_id PRIMARY KEY (obj_id);


--
-- Name: dam pkey_qgep_od_dam_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dam
    ADD CONSTRAINT pkey_qgep_od_dam_obj_id PRIMARY KEY (obj_id);


--
-- Name: damage_channel pkey_qgep_od_damage_channel_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage_channel
    ADD CONSTRAINT pkey_qgep_od_damage_channel_obj_id PRIMARY KEY (obj_id);


--
-- Name: damage_manhole pkey_qgep_od_damage_manhole_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage_manhole
    ADD CONSTRAINT pkey_qgep_od_damage_manhole_obj_id PRIMARY KEY (obj_id);


--
-- Name: damage pkey_qgep_od_damage_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage
    ADD CONSTRAINT pkey_qgep_od_damage_obj_id PRIMARY KEY (obj_id);


--
-- Name: data_media pkey_qgep_od_data_media_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.data_media
    ADD CONSTRAINT pkey_qgep_od_data_media_obj_id PRIMARY KEY (obj_id);


--
-- Name: discharge_point pkey_qgep_od_discharge_point_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.discharge_point
    ADD CONSTRAINT pkey_qgep_od_discharge_point_obj_id PRIMARY KEY (obj_id);


--
-- Name: drainage_system pkey_qgep_od_drainage_system_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.drainage_system
    ADD CONSTRAINT pkey_qgep_od_drainage_system_obj_id PRIMARY KEY (obj_id);


--
-- Name: dryweather_downspout pkey_qgep_od_dryweather_downspout_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dryweather_downspout
    ADD CONSTRAINT pkey_qgep_od_dryweather_downspout_obj_id PRIMARY KEY (obj_id);


--
-- Name: dryweather_flume pkey_qgep_od_dryweather_flume_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dryweather_flume
    ADD CONSTRAINT pkey_qgep_od_dryweather_flume_obj_id PRIMARY KEY (obj_id);


--
-- Name: electric_equipment pkey_qgep_od_electric_equipment_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.electric_equipment
    ADD CONSTRAINT pkey_qgep_od_electric_equipment_obj_id PRIMARY KEY (obj_id);


--
-- Name: electromechanical_equipment pkey_qgep_od_electromechanical_equipment_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.electromechanical_equipment
    ADD CONSTRAINT pkey_qgep_od_electromechanical_equipment_obj_id PRIMARY KEY (obj_id);


--
-- Name: examination pkey_qgep_od_examination_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.examination
    ADD CONSTRAINT pkey_qgep_od_examination_obj_id PRIMARY KEY (obj_id);


--
-- Name: file pkey_qgep_od_file_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.file
    ADD CONSTRAINT pkey_qgep_od_file_obj_id PRIMARY KEY (obj_id);


--
-- Name: fish_pass pkey_qgep_od_fish_pass_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.fish_pass
    ADD CONSTRAINT pkey_qgep_od_fish_pass_obj_id PRIMARY KEY (obj_id);


--
-- Name: ford pkey_qgep_od_ford_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.ford
    ADD CONSTRAINT pkey_qgep_od_ford_obj_id PRIMARY KEY (obj_id);


--
-- Name: fountain pkey_qgep_od_fountain_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.fountain
    ADD CONSTRAINT pkey_qgep_od_fountain_obj_id PRIMARY KEY (obj_id);


--
-- Name: ground_water_protection_perimeter pkey_qgep_od_ground_water_protection_perimeter_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.ground_water_protection_perimeter
    ADD CONSTRAINT pkey_qgep_od_ground_water_protection_perimeter_obj_id PRIMARY KEY (obj_id);


--
-- Name: groundwater_protection_zone pkey_qgep_od_groundwater_protection_zone_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.groundwater_protection_zone
    ADD CONSTRAINT pkey_qgep_od_groundwater_protection_zone_obj_id PRIMARY KEY (obj_id);


--
-- Name: hazard_source pkey_qgep_od_hazard_source_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hazard_source
    ADD CONSTRAINT pkey_qgep_od_hazard_source_obj_id PRIMARY KEY (obj_id);


--
-- Name: hq_relation pkey_qgep_od_hq_relation_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hq_relation
    ADD CONSTRAINT pkey_qgep_od_hq_relation_obj_id PRIMARY KEY (obj_id);


--
-- Name: hydr_geom_relation pkey_qgep_od_hydr_geom_relation_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydr_geom_relation
    ADD CONSTRAINT pkey_qgep_od_hydr_geom_relation_obj_id PRIMARY KEY (obj_id);


--
-- Name: hydr_geometry pkey_qgep_od_hydr_geometry_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydr_geometry
    ADD CONSTRAINT pkey_qgep_od_hydr_geometry_obj_id PRIMARY KEY (obj_id);


--
-- Name: hydraulic_char_data pkey_qgep_od_hydraulic_char_data_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT pkey_qgep_od_hydraulic_char_data_obj_id PRIMARY KEY (obj_id);


--
-- Name: individual_surface pkey_qgep_od_individual_surface_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.individual_surface
    ADD CONSTRAINT pkey_qgep_od_individual_surface_obj_id PRIMARY KEY (obj_id);


--
-- Name: infiltration_installation pkey_qgep_od_infiltration_installation_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT pkey_qgep_od_infiltration_installation_obj_id PRIMARY KEY (obj_id);


--
-- Name: infiltration_zone pkey_qgep_od_infiltration_zone_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_zone
    ADD CONSTRAINT pkey_qgep_od_infiltration_zone_obj_id PRIMARY KEY (obj_id);


--
-- Name: lake pkey_qgep_od_lake_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.lake
    ADD CONSTRAINT pkey_qgep_od_lake_obj_id PRIMARY KEY (obj_id);


--
-- Name: leapingweir pkey_qgep_od_leapingweir_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.leapingweir
    ADD CONSTRAINT pkey_qgep_od_leapingweir_obj_id PRIMARY KEY (obj_id);


--
-- Name: lock pkey_qgep_od_lock_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.lock
    ADD CONSTRAINT pkey_qgep_od_lock_obj_id PRIMARY KEY (obj_id);


--
-- Name: maintenance_event pkey_qgep_od_maintenance_event_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.maintenance_event
    ADD CONSTRAINT pkey_qgep_od_maintenance_event_obj_id PRIMARY KEY (obj_id);


--
-- Name: manhole pkey_qgep_od_manhole_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.manhole
    ADD CONSTRAINT pkey_qgep_od_manhole_obj_id PRIMARY KEY (obj_id);


--
-- Name: measurement_result pkey_qgep_od_measurement_result_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_result
    ADD CONSTRAINT pkey_qgep_od_measurement_result_obj_id PRIMARY KEY (obj_id);


--
-- Name: measurement_series pkey_qgep_od_measurement_series_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_series
    ADD CONSTRAINT pkey_qgep_od_measurement_series_obj_id PRIMARY KEY (obj_id);


--
-- Name: measuring_device pkey_qgep_od_measuring_device_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_device
    ADD CONSTRAINT pkey_qgep_od_measuring_device_obj_id PRIMARY KEY (obj_id);


--
-- Name: measuring_point pkey_qgep_od_measuring_point_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT pkey_qgep_od_measuring_point_obj_id PRIMARY KEY (obj_id);


--
-- Name: mechanical_pretreatment pkey_qgep_od_mechanical_pretreatment_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mechanical_pretreatment
    ADD CONSTRAINT pkey_qgep_od_mechanical_pretreatment_obj_id PRIMARY KEY (obj_id);


--
-- Name: municipality pkey_qgep_od_municipality_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.municipality
    ADD CONSTRAINT pkey_qgep_od_municipality_obj_id PRIMARY KEY (obj_id);


--
-- Name: mutation pkey_qgep_od_mutation_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mutation
    ADD CONSTRAINT pkey_qgep_od_mutation_obj_id PRIMARY KEY (obj_id);


--
-- Name: organisation pkey_qgep_od_organisation_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.organisation
    ADD CONSTRAINT pkey_qgep_od_organisation_obj_id PRIMARY KEY (obj_id);


--
-- Name: overflow_char pkey_qgep_od_overflow_char_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow_char
    ADD CONSTRAINT pkey_qgep_od_overflow_char_obj_id PRIMARY KEY (obj_id);


--
-- Name: overflow pkey_qgep_od_overflow_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT pkey_qgep_od_overflow_obj_id PRIMARY KEY (obj_id);


--
-- Name: param_ca_general pkey_qgep_od_param_ca_general_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.param_ca_general
    ADD CONSTRAINT pkey_qgep_od_param_ca_general_obj_id PRIMARY KEY (obj_id);


--
-- Name: param_ca_mouse1 pkey_qgep_od_param_ca_mouse1_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.param_ca_mouse1
    ADD CONSTRAINT pkey_qgep_od_param_ca_mouse1_obj_id PRIMARY KEY (obj_id);


--
-- Name: passage pkey_qgep_od_passage_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.passage
    ADD CONSTRAINT pkey_qgep_od_passage_obj_id PRIMARY KEY (obj_id);


--
-- Name: pipe_profile pkey_qgep_od_pipe_profile_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pipe_profile
    ADD CONSTRAINT pkey_qgep_od_pipe_profile_obj_id PRIMARY KEY (obj_id);


--
-- Name: planning_zone pkey_qgep_od_planning_zone_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.planning_zone
    ADD CONSTRAINT pkey_qgep_od_planning_zone_obj_id PRIMARY KEY (obj_id);


--
-- Name: prank_weir pkey_qgep_od_prank_weir_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.prank_weir
    ADD CONSTRAINT pkey_qgep_od_prank_weir_obj_id PRIMARY KEY (obj_id);


--
-- Name: private pkey_qgep_od_private_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.private
    ADD CONSTRAINT pkey_qgep_od_private_obj_id PRIMARY KEY (obj_id);


--
-- Name: profile_geometry pkey_qgep_od_profile_geometry_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.profile_geometry
    ADD CONSTRAINT pkey_qgep_od_profile_geometry_obj_id PRIMARY KEY (obj_id);


--
-- Name: pump pkey_qgep_od_pump_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pump
    ADD CONSTRAINT pkey_qgep_od_pump_obj_id PRIMARY KEY (obj_id);


--
-- Name: reach pkey_qgep_od_reach_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT pkey_qgep_od_reach_obj_id PRIMARY KEY (obj_id);


--
-- Name: reach_point pkey_qgep_od_reach_point_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_point
    ADD CONSTRAINT pkey_qgep_od_reach_point_obj_id PRIMARY KEY (obj_id);


--
-- Name: reach_text pkey_qgep_od_reach_text_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_text
    ADD CONSTRAINT pkey_qgep_od_reach_text_obj_id PRIMARY KEY (obj_id);


--
-- Name: reservoir pkey_qgep_od_reservoir_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reservoir
    ADD CONSTRAINT pkey_qgep_od_reservoir_obj_id PRIMARY KEY (obj_id);


--
-- Name: retention_body pkey_qgep_od_retention_body_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.retention_body
    ADD CONSTRAINT pkey_qgep_od_retention_body_obj_id PRIMARY KEY (obj_id);


--
-- Name: river_bank pkey_qgep_od_river_bank_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT pkey_qgep_od_river_bank_obj_id PRIMARY KEY (obj_id);


--
-- Name: river_bed pkey_qgep_od_river_bed_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bed
    ADD CONSTRAINT pkey_qgep_od_river_bed_obj_id PRIMARY KEY (obj_id);


--
-- Name: river pkey_qgep_od_river_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river
    ADD CONSTRAINT pkey_qgep_od_river_obj_id PRIMARY KEY (obj_id);


--
-- Name: rock_ramp pkey_qgep_od_rock_ramp_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.rock_ramp
    ADD CONSTRAINT pkey_qgep_od_rock_ramp_obj_id PRIMARY KEY (obj_id);


--
-- Name: sector_water_body pkey_qgep_od_sector_water_body_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sector_water_body
    ADD CONSTRAINT pkey_qgep_od_sector_water_body_obj_id PRIMARY KEY (obj_id);


--
-- Name: sludge_treatment pkey_qgep_od_sludge_treatment_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sludge_treatment
    ADD CONSTRAINT pkey_qgep_od_sludge_treatment_obj_id PRIMARY KEY (obj_id);


--
-- Name: solids_retention pkey_qgep_od_solids_retention_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.solids_retention
    ADD CONSTRAINT pkey_qgep_od_solids_retention_obj_id PRIMARY KEY (obj_id);


--
-- Name: special_structure pkey_qgep_od_special_structure_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.special_structure
    ADD CONSTRAINT pkey_qgep_od_special_structure_obj_id PRIMARY KEY (obj_id);


--
-- Name: structure_part pkey_qgep_od_structure_part_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.structure_part
    ADD CONSTRAINT pkey_qgep_od_structure_part_obj_id PRIMARY KEY (obj_id);


--
-- Name: substance pkey_qgep_od_substance_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.substance
    ADD CONSTRAINT pkey_qgep_od_substance_obj_id PRIMARY KEY (obj_id);


--
-- Name: surface_runoff_parameters pkey_qgep_od_surface_runoff_parameters_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.surface_runoff_parameters
    ADD CONSTRAINT pkey_qgep_od_surface_runoff_parameters_obj_id PRIMARY KEY (obj_id);


--
-- Name: surface_water_bodies pkey_qgep_od_surface_water_bodies_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.surface_water_bodies
    ADD CONSTRAINT pkey_qgep_od_surface_water_bodies_obj_id PRIMARY KEY (obj_id);


--
-- Name: tank_cleaning pkey_qgep_od_tank_cleaning_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_cleaning
    ADD CONSTRAINT pkey_qgep_od_tank_cleaning_obj_id PRIMARY KEY (obj_id);


--
-- Name: tank_emptying pkey_qgep_od_tank_emptying_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_emptying
    ADD CONSTRAINT pkey_qgep_od_tank_emptying_obj_id PRIMARY KEY (obj_id);


--
-- Name: throttle_shut_off_unit pkey_qgep_od_throttle_shut_off_unit_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT pkey_qgep_od_throttle_shut_off_unit_obj_id PRIMARY KEY (obj_id);


--
-- Name: waste_water_association pkey_qgep_od_waste_water_association_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_association
    ADD CONSTRAINT pkey_qgep_od_waste_water_association_obj_id PRIMARY KEY (obj_id);


--
-- Name: waste_water_treatment pkey_qgep_od_waste_water_treatment_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_treatment
    ADD CONSTRAINT pkey_qgep_od_waste_water_treatment_obj_id PRIMARY KEY (obj_id);


--
-- Name: waste_water_treatment_plant pkey_qgep_od_waste_water_treatment_plant_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_treatment_plant
    ADD CONSTRAINT pkey_qgep_od_waste_water_treatment_plant_obj_id PRIMARY KEY (obj_id);


--
-- Name: wastewater_networkelement pkey_qgep_od_wastewater_networkelement_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_networkelement
    ADD CONSTRAINT pkey_qgep_od_wastewater_networkelement_obj_id PRIMARY KEY (obj_id);


--
-- Name: wastewater_node pkey_qgep_od_wastewater_node_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_node
    ADD CONSTRAINT pkey_qgep_od_wastewater_node_obj_id PRIMARY KEY (obj_id);


--
-- Name: wastewater_structure pkey_qgep_od_wastewater_structure_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT pkey_qgep_od_wastewater_structure_obj_id PRIMARY KEY (obj_id);


--
-- Name: wastewater_structure_symbol pkey_qgep_od_wastewater_structure_symbol_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_symbol
    ADD CONSTRAINT pkey_qgep_od_wastewater_structure_symbol_obj_id PRIMARY KEY (obj_id);


--
-- Name: wastewater_structure_text pkey_qgep_od_wastewater_structure_text_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_text
    ADD CONSTRAINT pkey_qgep_od_wastewater_structure_text_obj_id PRIMARY KEY (obj_id);


--
-- Name: water_body_protection_sector pkey_qgep_od_water_body_protection_sector_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_body_protection_sector
    ADD CONSTRAINT pkey_qgep_od_water_body_protection_sector_obj_id PRIMARY KEY (obj_id);


--
-- Name: water_catchment pkey_qgep_od_water_catchment_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_catchment
    ADD CONSTRAINT pkey_qgep_od_water_catchment_obj_id PRIMARY KEY (obj_id);


--
-- Name: water_control_structure pkey_qgep_od_water_control_structure_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_control_structure
    ADD CONSTRAINT pkey_qgep_od_water_control_structure_obj_id PRIMARY KEY (obj_id);


--
-- Name: water_course_segment pkey_qgep_od_water_course_segment_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT pkey_qgep_od_water_course_segment_obj_id PRIMARY KEY (obj_id);


--
-- Name: wwtp_energy_use pkey_qgep_od_wwtp_energy_use_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wwtp_energy_use
    ADD CONSTRAINT pkey_qgep_od_wwtp_energy_use_obj_id PRIMARY KEY (obj_id);


--
-- Name: wwtp_structure pkey_qgep_od_wwtp_structure_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wwtp_structure
    ADD CONSTRAINT pkey_qgep_od_wwtp_structure_obj_id PRIMARY KEY (obj_id);


--
-- Name: zone pkey_qgep_od_zone_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.zone
    ADD CONSTRAINT pkey_qgep_od_zone_obj_id PRIMARY KEY (obj_id);


--
-- Name: re_maintenance_event_wastewater_structure pkey_qgep_re_maintenance_event_wastewater_structure_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.re_maintenance_event_wastewater_structure
    ADD CONSTRAINT pkey_qgep_re_maintenance_event_wastewater_structure_obj_id PRIMARY KEY (obj_id);


--
-- Name: txt_symbol pkey_qgep_txt_symbol_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_symbol
    ADD CONSTRAINT pkey_qgep_txt_symbol_obj_id PRIMARY KEY (obj_id);


--
-- Name: txt_text pkey_qgep_txt_text_obj_id; Type: CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_text
    ADD CONSTRAINT pkey_qgep_txt_text_obj_id PRIMARY KEY (obj_id);


--
-- Name: dictionary_od_field is_dictionary_od_field_pkey; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_field
    ADD CONSTRAINT is_dictionary_od_field_pkey PRIMARY KEY (id);


--
-- Name: dictionary_od_values is_dictionary_od_values_pkey; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_values
    ADD CONSTRAINT is_dictionary_od_values_pkey PRIMARY KEY (id);


--
-- Name: logged_actions logged_actions_pkey; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.logged_actions
    ADD CONSTRAINT logged_actions_pkey PRIMARY KEY (event_id);


--
-- Name: dictionary_od_table pkey_qgep_is_dictonary_id; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT pkey_qgep_is_dictonary_id PRIMARY KEY (id);


--
-- Name: oid_prefixes pkey_qgep_is_oid_prefixes_id; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.oid_prefixes
    ADD CONSTRAINT pkey_qgep_is_oid_prefixes_id PRIMARY KEY (id);


--
-- Name: value_list_base pkey_qgep_value_list_code; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.value_list_base
    ADD CONSTRAINT pkey_qgep_value_list_code PRIMARY KEY (code);


--
-- Name: pum_info pum_info_pkey; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.pum_info
    ADD CONSTRAINT pum_info_pkey PRIMARY KEY (id);


--
-- Name: dictionary_od_table unq_qgep_is_dictonary_name_de; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT unq_qgep_is_dictonary_name_de UNIQUE (name_de);


--
-- Name: dictionary_od_table unq_qgep_is_dictonary_name_en; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT unq_qgep_is_dictonary_name_en UNIQUE (name_en);


--
-- Name: dictionary_od_table unq_qgep_is_dictonary_name_fr; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT unq_qgep_is_dictonary_name_fr UNIQUE (name_fr);


--
-- Name: dictionary_od_table unq_qgep_is_dictonary_shortcut_de; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT unq_qgep_is_dictonary_shortcut_de UNIQUE (shortcut_de);


--
-- Name: dictionary_od_table unq_qgep_is_dictonary_shortcut_en; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT unq_qgep_is_dictonary_shortcut_en UNIQUE (shortcut_en);


--
-- Name: dictionary_od_table unq_qgep_is_dictonary_shortcut_fr; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT unq_qgep_is_dictonary_shortcut_fr UNIQUE (shortcut_fr);


--
-- Name: dictionary_od_table unq_qgep_is_dictonary_tablename; Type: CONSTRAINT; Schema: qgep_sys; Owner: postgres
--

ALTER TABLE ONLY qgep_sys.dictionary_od_table
    ADD CONSTRAINT unq_qgep_is_dictonary_tablename UNIQUE (tablename);


--
-- Name: access_aid_kind pkey_qgep_vl_access_aid_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.access_aid_kind
    ADD CONSTRAINT pkey_qgep_vl_access_aid_kind_code PRIMARY KEY (code);


--
-- Name: backflow_prevention_kind pkey_qgep_vl_backflow_prevention_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.backflow_prevention_kind
    ADD CONSTRAINT pkey_qgep_vl_backflow_prevention_kind_code PRIMARY KEY (code);


--
-- Name: benching_kind pkey_qgep_vl_benching_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.benching_kind
    ADD CONSTRAINT pkey_qgep_vl_benching_kind_code PRIMARY KEY (code);


--
-- Name: catchment_area_direct_discharge_current pkey_qgep_vl_catchment_area_direct_discharge_current_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_direct_discharge_current
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_direct_discharge_current_code PRIMARY KEY (code);


--
-- Name: catchment_area_direct_discharge_planned pkey_qgep_vl_catchment_area_direct_discharge_planned_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_direct_discharge_planned
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_direct_discharge_planned_code PRIMARY KEY (code);


--
-- Name: catchment_area_drainage_system_current pkey_qgep_vl_catchment_area_drainage_system_current_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_drainage_system_current
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_drainage_system_current_code PRIMARY KEY (code);


--
-- Name: catchment_area_drainage_system_planned pkey_qgep_vl_catchment_area_drainage_system_planned_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_drainage_system_planned
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_drainage_system_planned_code PRIMARY KEY (code);


--
-- Name: catchment_area_infiltration_current pkey_qgep_vl_catchment_area_infiltration_current_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_infiltration_current
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_infiltration_current_code PRIMARY KEY (code);


--
-- Name: catchment_area_infiltration_planned pkey_qgep_vl_catchment_area_infiltration_planned_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_infiltration_planned
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_infiltration_planned_code PRIMARY KEY (code);


--
-- Name: catchment_area_retention_current pkey_qgep_vl_catchment_area_retention_current_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_retention_current
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_retention_current_code PRIMARY KEY (code);


--
-- Name: catchment_area_retention_planned pkey_qgep_vl_catchment_area_retention_planned_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_retention_planned
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_retention_planned_code PRIMARY KEY (code);


--
-- Name: catchment_area_text_plantype pkey_qgep_vl_catchment_area_text_plantype_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_text_plantype
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_text_plantype_code PRIMARY KEY (code);


--
-- Name: catchment_area_text_texthali pkey_qgep_vl_catchment_area_text_texthali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_text_texthali
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_text_texthali_code PRIMARY KEY (code);


--
-- Name: catchment_area_text_textvali pkey_qgep_vl_catchment_area_text_textvali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.catchment_area_text_textvali
    ADD CONSTRAINT pkey_qgep_vl_catchment_area_text_textvali_code PRIMARY KEY (code);


--
-- Name: channel_bedding_encasement pkey_qgep_vl_channel_bedding_encasement_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.channel_bedding_encasement
    ADD CONSTRAINT pkey_qgep_vl_channel_bedding_encasement_code PRIMARY KEY (code);


--
-- Name: channel_connection_type pkey_qgep_vl_channel_connection_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.channel_connection_type
    ADD CONSTRAINT pkey_qgep_vl_channel_connection_type_code PRIMARY KEY (code);


--
-- Name: channel_function_hierarchic pkey_qgep_vl_channel_function_hierarchic_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.channel_function_hierarchic
    ADD CONSTRAINT pkey_qgep_vl_channel_function_hierarchic_code PRIMARY KEY (code);


--
-- Name: channel_function_hydraulic pkey_qgep_vl_channel_function_hydraulic_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.channel_function_hydraulic
    ADD CONSTRAINT pkey_qgep_vl_channel_function_hydraulic_code PRIMARY KEY (code);


--
-- Name: channel_usage_current pkey_qgep_vl_channel_usage_current_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.channel_usage_current
    ADD CONSTRAINT pkey_qgep_vl_channel_usage_current_code PRIMARY KEY (code);


--
-- Name: channel_usage_planned pkey_qgep_vl_channel_usage_planned_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.channel_usage_planned
    ADD CONSTRAINT pkey_qgep_vl_channel_usage_planned_code PRIMARY KEY (code);


--
-- Name: chute_kind pkey_qgep_vl_chute_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.chute_kind
    ADD CONSTRAINT pkey_qgep_vl_chute_kind_code PRIMARY KEY (code);


--
-- Name: chute_material pkey_qgep_vl_chute_material_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.chute_material
    ADD CONSTRAINT pkey_qgep_vl_chute_material_code PRIMARY KEY (code);


--
-- Name: cover_cover_shape pkey_qgep_vl_cover_cover_shape_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.cover_cover_shape
    ADD CONSTRAINT pkey_qgep_vl_cover_cover_shape_code PRIMARY KEY (code);


--
-- Name: cover_fastening pkey_qgep_vl_cover_fastening_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.cover_fastening
    ADD CONSTRAINT pkey_qgep_vl_cover_fastening_code PRIMARY KEY (code);


--
-- Name: cover_material pkey_qgep_vl_cover_material_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.cover_material
    ADD CONSTRAINT pkey_qgep_vl_cover_material_code PRIMARY KEY (code);


--
-- Name: cover_positional_accuracy pkey_qgep_vl_cover_positional_accuracy_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.cover_positional_accuracy
    ADD CONSTRAINT pkey_qgep_vl_cover_positional_accuracy_code PRIMARY KEY (code);


--
-- Name: cover_sludge_bucket pkey_qgep_vl_cover_sludge_bucket_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.cover_sludge_bucket
    ADD CONSTRAINT pkey_qgep_vl_cover_sludge_bucket_code PRIMARY KEY (code);


--
-- Name: cover_venting pkey_qgep_vl_cover_venting_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.cover_venting
    ADD CONSTRAINT pkey_qgep_vl_cover_venting_code PRIMARY KEY (code);


--
-- Name: dam_kind pkey_qgep_vl_dam_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.dam_kind
    ADD CONSTRAINT pkey_qgep_vl_dam_kind_code PRIMARY KEY (code);


--
-- Name: damage_channel_channel_damage_code pkey_qgep_vl_damage_channel_channel_damage_code_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.damage_channel_channel_damage_code
    ADD CONSTRAINT pkey_qgep_vl_damage_channel_channel_damage_code_code PRIMARY KEY (code);


--
-- Name: damage_connection pkey_qgep_vl_damage_connection_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.damage_connection
    ADD CONSTRAINT pkey_qgep_vl_damage_connection_code PRIMARY KEY (code);


--
-- Name: damage_manhole_manhole_damage_code pkey_qgep_vl_damage_manhole_manhole_damage_code_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.damage_manhole_manhole_damage_code
    ADD CONSTRAINT pkey_qgep_vl_damage_manhole_manhole_damage_code_code PRIMARY KEY (code);


--
-- Name: damage_manhole_manhole_shaft_area pkey_qgep_vl_damage_manhole_manhole_shaft_area_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.damage_manhole_manhole_shaft_area
    ADD CONSTRAINT pkey_qgep_vl_damage_manhole_manhole_shaft_area_code PRIMARY KEY (code);


--
-- Name: damage_single_damage_class pkey_qgep_vl_damage_single_damage_class_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.damage_single_damage_class
    ADD CONSTRAINT pkey_qgep_vl_damage_single_damage_class_code PRIMARY KEY (code);


--
-- Name: data_media_kind pkey_qgep_vl_data_media_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.data_media_kind
    ADD CONSTRAINT pkey_qgep_vl_data_media_kind_code PRIMARY KEY (code);


--
-- Name: discharge_point_relevance pkey_qgep_vl_discharge_point_relevance_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.discharge_point_relevance
    ADD CONSTRAINT pkey_qgep_vl_discharge_point_relevance_code PRIMARY KEY (code);


--
-- Name: drainage_system_kind pkey_qgep_vl_drainage_system_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.drainage_system_kind
    ADD CONSTRAINT pkey_qgep_vl_drainage_system_kind_code PRIMARY KEY (code);


--
-- Name: dryweather_flume_material pkey_qgep_vl_dryweather_flume_material_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.dryweather_flume_material
    ADD CONSTRAINT pkey_qgep_vl_dryweather_flume_material_code PRIMARY KEY (code);


--
-- Name: electric_equipment_kind pkey_qgep_vl_electric_equipment_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.electric_equipment_kind
    ADD CONSTRAINT pkey_qgep_vl_electric_equipment_kind_code PRIMARY KEY (code);


--
-- Name: electromechanical_equipment_kind pkey_qgep_vl_electromechanical_equipment_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.electromechanical_equipment_kind
    ADD CONSTRAINT pkey_qgep_vl_electromechanical_equipment_kind_code PRIMARY KEY (code);


--
-- Name: examination_recording_type pkey_qgep_vl_examination_recording_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.examination_recording_type
    ADD CONSTRAINT pkey_qgep_vl_examination_recording_type_code PRIMARY KEY (code);


--
-- Name: examination_weather pkey_qgep_vl_examination_weather_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.examination_weather
    ADD CONSTRAINT pkey_qgep_vl_examination_weather_code PRIMARY KEY (code);


--
-- Name: file_class pkey_qgep_vl_file_class_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.file_class
    ADD CONSTRAINT pkey_qgep_vl_file_class_code PRIMARY KEY (code);


--
-- Name: file_kind pkey_qgep_vl_file_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.file_kind
    ADD CONSTRAINT pkey_qgep_vl_file_kind_code PRIMARY KEY (code);


--
-- Name: groundwater_protection_zone_kind pkey_qgep_vl_groundwater_protection_zone_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.groundwater_protection_zone_kind
    ADD CONSTRAINT pkey_qgep_vl_groundwater_protection_zone_kind_code PRIMARY KEY (code);


--
-- Name: hydraulic_char_data_is_overflowing pkey_qgep_vl_hydraulic_char_data_is_overflowing_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.hydraulic_char_data_is_overflowing
    ADD CONSTRAINT pkey_qgep_vl_hydraulic_char_data_is_overflowing_code PRIMARY KEY (code);


--
-- Name: hydraulic_char_data_main_weir_kind pkey_qgep_vl_hydraulic_char_data_main_weir_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.hydraulic_char_data_main_weir_kind
    ADD CONSTRAINT pkey_qgep_vl_hydraulic_char_data_main_weir_kind_code PRIMARY KEY (code);


--
-- Name: hydraulic_char_data_pump_characteristics pkey_qgep_vl_hydraulic_char_data_pump_characteristics_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.hydraulic_char_data_pump_characteristics
    ADD CONSTRAINT pkey_qgep_vl_hydraulic_char_data_pump_characteristics_code PRIMARY KEY (code);


--
-- Name: hydraulic_char_data_pump_usage_current pkey_qgep_vl_hydraulic_char_data_pump_usage_current_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.hydraulic_char_data_pump_usage_current
    ADD CONSTRAINT pkey_qgep_vl_hydraulic_char_data_pump_usage_current_code PRIMARY KEY (code);


--
-- Name: hydraulic_char_data_status pkey_qgep_vl_hydraulic_char_data_status_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.hydraulic_char_data_status
    ADD CONSTRAINT pkey_qgep_vl_hydraulic_char_data_status_code PRIMARY KEY (code);


--
-- Name: individual_surface_function pkey_qgep_vl_individual_surface_function_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.individual_surface_function
    ADD CONSTRAINT pkey_qgep_vl_individual_surface_function_code PRIMARY KEY (code);


--
-- Name: individual_surface_pavement pkey_qgep_vl_individual_surface_pavement_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.individual_surface_pavement
    ADD CONSTRAINT pkey_qgep_vl_individual_surface_pavement_code PRIMARY KEY (code);


--
-- Name: infiltration_installation_defects pkey_qgep_vl_infiltration_installation_defects_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_installation_defects
    ADD CONSTRAINT pkey_qgep_vl_infiltration_installation_defects_code PRIMARY KEY (code);


--
-- Name: infiltration_installation_emergency_spillway pkey_qgep_vl_infiltration_installation_emergency_spillway_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_installation_emergency_spillway
    ADD CONSTRAINT pkey_qgep_vl_infiltration_installation_emergency_spillway_code PRIMARY KEY (code);


--
-- Name: infiltration_installation_kind pkey_qgep_vl_infiltration_installation_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_installation_kind
    ADD CONSTRAINT pkey_qgep_vl_infiltration_installation_kind_code PRIMARY KEY (code);


--
-- Name: infiltration_installation_labeling pkey_qgep_vl_infiltration_installation_labeling_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_installation_labeling
    ADD CONSTRAINT pkey_qgep_vl_infiltration_installation_labeling_code PRIMARY KEY (code);


--
-- Name: infiltration_installation_seepage_utilization pkey_qgep_vl_infiltration_installation_seepage_utilization_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_installation_seepage_utilization
    ADD CONSTRAINT pkey_qgep_vl_infiltration_installation_seepage_utilization_code PRIMARY KEY (code);


--
-- Name: infiltration_installation_vehicle_access pkey_qgep_vl_infiltration_installation_vehicle_access_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_installation_vehicle_access
    ADD CONSTRAINT pkey_qgep_vl_infiltration_installation_vehicle_access_code PRIMARY KEY (code);


--
-- Name: infiltration_installation_watertightness pkey_qgep_vl_infiltration_installation_watertightness_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_installation_watertightness
    ADD CONSTRAINT pkey_qgep_vl_infiltration_installation_watertightness_code PRIMARY KEY (code);


--
-- Name: infiltration_zone_infiltration_capacity pkey_qgep_vl_infiltration_zone_infiltration_capacity_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.infiltration_zone_infiltration_capacity
    ADD CONSTRAINT pkey_qgep_vl_infiltration_zone_infiltration_capacity_code PRIMARY KEY (code);


--
-- Name: leapingweir_opening_shape pkey_qgep_vl_leapingweir_opening_shape_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.leapingweir_opening_shape
    ADD CONSTRAINT pkey_qgep_vl_leapingweir_opening_shape_code PRIMARY KEY (code);


--
-- Name: maintenance_event_kind pkey_qgep_vl_maintenance_event_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.maintenance_event_kind
    ADD CONSTRAINT pkey_qgep_vl_maintenance_event_kind_code PRIMARY KEY (code);


--
-- Name: maintenance_event_status pkey_qgep_vl_maintenance_event_status_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.maintenance_event_status
    ADD CONSTRAINT pkey_qgep_vl_maintenance_event_status_code PRIMARY KEY (code);


--
-- Name: manhole_function pkey_qgep_vl_manhole_function_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.manhole_function
    ADD CONSTRAINT pkey_qgep_vl_manhole_function_code PRIMARY KEY (code);


--
-- Name: manhole_material pkey_qgep_vl_manhole_material_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.manhole_material
    ADD CONSTRAINT pkey_qgep_vl_manhole_material_code PRIMARY KEY (code);


--
-- Name: manhole_surface_inflow pkey_qgep_vl_manhole_surface_inflow_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.manhole_surface_inflow
    ADD CONSTRAINT pkey_qgep_vl_manhole_surface_inflow_code PRIMARY KEY (code);


--
-- Name: measurement_result_measurement_type pkey_qgep_vl_measurement_result_measurement_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.measurement_result_measurement_type
    ADD CONSTRAINT pkey_qgep_vl_measurement_result_measurement_type_code PRIMARY KEY (code);


--
-- Name: measurement_series_kind pkey_qgep_vl_measurement_series_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.measurement_series_kind
    ADD CONSTRAINT pkey_qgep_vl_measurement_series_kind_code PRIMARY KEY (code);


--
-- Name: measuring_device_kind pkey_qgep_vl_measuring_device_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.measuring_device_kind
    ADD CONSTRAINT pkey_qgep_vl_measuring_device_kind_code PRIMARY KEY (code);


--
-- Name: measuring_point_damming_device pkey_qgep_vl_measuring_point_damming_device_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.measuring_point_damming_device
    ADD CONSTRAINT pkey_qgep_vl_measuring_point_damming_device_code PRIMARY KEY (code);


--
-- Name: measuring_point_purpose pkey_qgep_vl_measuring_point_purpose_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.measuring_point_purpose
    ADD CONSTRAINT pkey_qgep_vl_measuring_point_purpose_code PRIMARY KEY (code);


--
-- Name: mechanical_pretreatment_kind pkey_qgep_vl_mechanical_pretreatment_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.mechanical_pretreatment_kind
    ADD CONSTRAINT pkey_qgep_vl_mechanical_pretreatment_kind_code PRIMARY KEY (code);


--
-- Name: mutation_kind pkey_qgep_vl_mutation_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.mutation_kind
    ADD CONSTRAINT pkey_qgep_vl_mutation_kind_code PRIMARY KEY (code);


--
-- Name: overflow_actuation pkey_qgep_vl_overflow_actuation_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.overflow_actuation
    ADD CONSTRAINT pkey_qgep_vl_overflow_actuation_code PRIMARY KEY (code);


--
-- Name: overflow_adjustability pkey_qgep_vl_overflow_adjustability_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.overflow_adjustability
    ADD CONSTRAINT pkey_qgep_vl_overflow_adjustability_code PRIMARY KEY (code);


--
-- Name: overflow_char_kind_overflow_characteristic pkey_qgep_vl_overflow_char_kind_overflow_characteristic_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.overflow_char_kind_overflow_characteristic
    ADD CONSTRAINT pkey_qgep_vl_overflow_char_kind_overflow_characteristic_code PRIMARY KEY (code);


--
-- Name: overflow_char_overflow_characteristic_digital pkey_qgep_vl_overflow_char_overflow_characteristic_digital_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.overflow_char_overflow_characteristic_digital
    ADD CONSTRAINT pkey_qgep_vl_overflow_char_overflow_characteristic_digital_code PRIMARY KEY (code);


--
-- Name: overflow_control pkey_qgep_vl_overflow_control_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.overflow_control
    ADD CONSTRAINT pkey_qgep_vl_overflow_control_code PRIMARY KEY (code);


--
-- Name: overflow_function pkey_qgep_vl_overflow_function_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.overflow_function
    ADD CONSTRAINT pkey_qgep_vl_overflow_function_code PRIMARY KEY (code);


--
-- Name: overflow_signal_transmission pkey_qgep_vl_overflow_signal_transmission_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.overflow_signal_transmission
    ADD CONSTRAINT pkey_qgep_vl_overflow_signal_transmission_code PRIMARY KEY (code);


--
-- Name: pipe_profile_profile_type pkey_qgep_vl_pipe_profile_profile_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.pipe_profile_profile_type
    ADD CONSTRAINT pkey_qgep_vl_pipe_profile_profile_type_code PRIMARY KEY (code);


--
-- Name: planning_zone_kind pkey_qgep_vl_planning_zone_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.planning_zone_kind
    ADD CONSTRAINT pkey_qgep_vl_planning_zone_kind_code PRIMARY KEY (code);


--
-- Name: prank_weir_weir_edge pkey_qgep_vl_prank_weir_weir_edge_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.prank_weir_weir_edge
    ADD CONSTRAINT pkey_qgep_vl_prank_weir_weir_edge_code PRIMARY KEY (code);


--
-- Name: prank_weir_weir_kind pkey_qgep_vl_prank_weir_weir_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.prank_weir_weir_kind
    ADD CONSTRAINT pkey_qgep_vl_prank_weir_weir_kind_code PRIMARY KEY (code);


--
-- Name: pump_contruction_type pkey_qgep_vl_pump_contruction_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.pump_contruction_type
    ADD CONSTRAINT pkey_qgep_vl_pump_contruction_type_code PRIMARY KEY (code);


--
-- Name: pump_placement_of_actuation pkey_qgep_vl_pump_placement_of_actuation_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.pump_placement_of_actuation
    ADD CONSTRAINT pkey_qgep_vl_pump_placement_of_actuation_code PRIMARY KEY (code);


--
-- Name: pump_placement_of_pump pkey_qgep_vl_pump_placement_of_pump_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.pump_placement_of_pump
    ADD CONSTRAINT pkey_qgep_vl_pump_placement_of_pump_code PRIMARY KEY (code);


--
-- Name: pump_usage_current pkey_qgep_vl_pump_usage_current_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.pump_usage_current
    ADD CONSTRAINT pkey_qgep_vl_pump_usage_current_code PRIMARY KEY (code);


--
-- Name: reach_elevation_determination pkey_qgep_vl_reach_elevation_determination_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_elevation_determination
    ADD CONSTRAINT pkey_qgep_vl_reach_elevation_determination_code PRIMARY KEY (code);


--
-- Name: reach_horizontal_positioning pkey_qgep_vl_reach_horizontal_positioning_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_horizontal_positioning
    ADD CONSTRAINT pkey_qgep_vl_reach_horizontal_positioning_code PRIMARY KEY (code);


--
-- Name: reach_inside_coating pkey_qgep_vl_reach_inside_coating_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_inside_coating
    ADD CONSTRAINT pkey_qgep_vl_reach_inside_coating_code PRIMARY KEY (code);


--
-- Name: reach_material pkey_qgep_vl_reach_material_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_material
    ADD CONSTRAINT pkey_qgep_vl_reach_material_code PRIMARY KEY (code);


--
-- Name: reach_point_elevation_accuracy pkey_qgep_vl_reach_point_elevation_accuracy_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_point_elevation_accuracy
    ADD CONSTRAINT pkey_qgep_vl_reach_point_elevation_accuracy_code PRIMARY KEY (code);


--
-- Name: reach_point_outlet_shape pkey_qgep_vl_reach_point_outlet_shape_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_point_outlet_shape
    ADD CONSTRAINT pkey_qgep_vl_reach_point_outlet_shape_code PRIMARY KEY (code);


--
-- Name: reach_reliner_material pkey_qgep_vl_reach_reliner_material_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_reliner_material
    ADD CONSTRAINT pkey_qgep_vl_reach_reliner_material_code PRIMARY KEY (code);


--
-- Name: reach_relining_construction pkey_qgep_vl_reach_relining_construction_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_relining_construction
    ADD CONSTRAINT pkey_qgep_vl_reach_relining_construction_code PRIMARY KEY (code);


--
-- Name: reach_relining_kind pkey_qgep_vl_reach_relining_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_relining_kind
    ADD CONSTRAINT pkey_qgep_vl_reach_relining_kind_code PRIMARY KEY (code);


--
-- Name: reach_text_plantype pkey_qgep_vl_reach_text_plantype_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_text_plantype
    ADD CONSTRAINT pkey_qgep_vl_reach_text_plantype_code PRIMARY KEY (code);


--
-- Name: reach_text_texthali pkey_qgep_vl_reach_text_texthali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_text_texthali
    ADD CONSTRAINT pkey_qgep_vl_reach_text_texthali_code PRIMARY KEY (code);


--
-- Name: reach_text_textvali pkey_qgep_vl_reach_text_textvali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.reach_text_textvali
    ADD CONSTRAINT pkey_qgep_vl_reach_text_textvali_code PRIMARY KEY (code);


--
-- Name: retention_body_kind pkey_qgep_vl_retention_body_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.retention_body_kind
    ADD CONSTRAINT pkey_qgep_vl_retention_body_kind_code PRIMARY KEY (code);


--
-- Name: river_bank_control_grade_of_river pkey_qgep_vl_river_bank_control_grade_of_river_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bank_control_grade_of_river
    ADD CONSTRAINT pkey_qgep_vl_river_bank_control_grade_of_river_code PRIMARY KEY (code);


--
-- Name: river_bank_river_control_type pkey_qgep_vl_river_bank_river_control_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bank_river_control_type
    ADD CONSTRAINT pkey_qgep_vl_river_bank_river_control_type_code PRIMARY KEY (code);


--
-- Name: river_bank_shores pkey_qgep_vl_river_bank_shores_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bank_shores
    ADD CONSTRAINT pkey_qgep_vl_river_bank_shores_code PRIMARY KEY (code);


--
-- Name: river_bank_side pkey_qgep_vl_river_bank_side_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bank_side
    ADD CONSTRAINT pkey_qgep_vl_river_bank_side_code PRIMARY KEY (code);


--
-- Name: river_bank_utilisation_of_shore_surroundings pkey_qgep_vl_river_bank_utilisation_of_shore_surroundings_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bank_utilisation_of_shore_surroundings
    ADD CONSTRAINT pkey_qgep_vl_river_bank_utilisation_of_shore_surroundings_code PRIMARY KEY (code);


--
-- Name: river_bank_vegetation pkey_qgep_vl_river_bank_vegetation_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bank_vegetation
    ADD CONSTRAINT pkey_qgep_vl_river_bank_vegetation_code PRIMARY KEY (code);


--
-- Name: river_bed_control_grade_of_river pkey_qgep_vl_river_bed_control_grade_of_river_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bed_control_grade_of_river
    ADD CONSTRAINT pkey_qgep_vl_river_bed_control_grade_of_river_code PRIMARY KEY (code);


--
-- Name: river_bed_kind pkey_qgep_vl_river_bed_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bed_kind
    ADD CONSTRAINT pkey_qgep_vl_river_bed_kind_code PRIMARY KEY (code);


--
-- Name: river_bed_river_control_type pkey_qgep_vl_river_bed_river_control_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_bed_river_control_type
    ADD CONSTRAINT pkey_qgep_vl_river_bed_river_control_type_code PRIMARY KEY (code);


--
-- Name: river_kind pkey_qgep_vl_river_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.river_kind
    ADD CONSTRAINT pkey_qgep_vl_river_kind_code PRIMARY KEY (code);


--
-- Name: rock_ramp_stabilisation pkey_qgep_vl_rock_ramp_stabilisation_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.rock_ramp_stabilisation
    ADD CONSTRAINT pkey_qgep_vl_rock_ramp_stabilisation_code PRIMARY KEY (code);


--
-- Name: sector_water_body_kind pkey_qgep_vl_sector_water_body_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.sector_water_body_kind
    ADD CONSTRAINT pkey_qgep_vl_sector_water_body_kind_code PRIMARY KEY (code);


--
-- Name: sludge_treatment_stabilisation pkey_qgep_vl_sludge_treatment_stabilisation_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.sludge_treatment_stabilisation
    ADD CONSTRAINT pkey_qgep_vl_sludge_treatment_stabilisation_code PRIMARY KEY (code);


--
-- Name: solids_retention_type pkey_qgep_vl_solids_retention_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.solids_retention_type
    ADD CONSTRAINT pkey_qgep_vl_solids_retention_type_code PRIMARY KEY (code);


--
-- Name: special_structure_bypass pkey_qgep_vl_special_structure_bypass_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.special_structure_bypass
    ADD CONSTRAINT pkey_qgep_vl_special_structure_bypass_code PRIMARY KEY (code);


--
-- Name: special_structure_emergency_spillway pkey_qgep_vl_special_structure_emergency_spillway_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.special_structure_emergency_spillway
    ADD CONSTRAINT pkey_qgep_vl_special_structure_emergency_spillway_code PRIMARY KEY (code);


--
-- Name: special_structure_function pkey_qgep_vl_special_structure_function_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.special_structure_function
    ADD CONSTRAINT pkey_qgep_vl_special_structure_function_code PRIMARY KEY (code);


--
-- Name: special_structure_stormwater_tank_arrangement pkey_qgep_vl_special_structure_stormwater_tank_arrangement_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.special_structure_stormwater_tank_arrangement
    ADD CONSTRAINT pkey_qgep_vl_special_structure_stormwater_tank_arrangement_code PRIMARY KEY (code);


--
-- Name: structure_part_renovation_demand pkey_qgep_vl_structure_part_renovation_demand_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.structure_part_renovation_demand
    ADD CONSTRAINT pkey_qgep_vl_structure_part_renovation_demand_code PRIMARY KEY (code);


--
-- Name: symbol_plantype pkey_qgep_vl_symbol_plantype_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.symbol_plantype
    ADD CONSTRAINT pkey_qgep_vl_symbol_plantype_code PRIMARY KEY (code);


--
-- Name: tank_cleaning_type pkey_qgep_vl_tank_cleaning_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.tank_cleaning_type
    ADD CONSTRAINT pkey_qgep_vl_tank_cleaning_type_code PRIMARY KEY (code);


--
-- Name: tank_emptying_type pkey_qgep_vl_tank_emptying_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.tank_emptying_type
    ADD CONSTRAINT pkey_qgep_vl_tank_emptying_type_code PRIMARY KEY (code);


--
-- Name: text_plantype pkey_qgep_vl_text_plantype_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.text_plantype
    ADD CONSTRAINT pkey_qgep_vl_text_plantype_code PRIMARY KEY (code);


--
-- Name: text_texthali pkey_qgep_vl_text_texthali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.text_texthali
    ADD CONSTRAINT pkey_qgep_vl_text_texthali_code PRIMARY KEY (code);


--
-- Name: text_textvali pkey_qgep_vl_text_textvali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.text_textvali
    ADD CONSTRAINT pkey_qgep_vl_text_textvali_code PRIMARY KEY (code);


--
-- Name: throttle_shut_off_unit_actuation pkey_qgep_vl_throttle_shut_off_unit_actuation_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.throttle_shut_off_unit_actuation
    ADD CONSTRAINT pkey_qgep_vl_throttle_shut_off_unit_actuation_code PRIMARY KEY (code);


--
-- Name: throttle_shut_off_unit_adjustability pkey_qgep_vl_throttle_shut_off_unit_adjustability_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.throttle_shut_off_unit_adjustability
    ADD CONSTRAINT pkey_qgep_vl_throttle_shut_off_unit_adjustability_code PRIMARY KEY (code);


--
-- Name: throttle_shut_off_unit_control pkey_qgep_vl_throttle_shut_off_unit_control_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.throttle_shut_off_unit_control
    ADD CONSTRAINT pkey_qgep_vl_throttle_shut_off_unit_control_code PRIMARY KEY (code);


--
-- Name: throttle_shut_off_unit_kind pkey_qgep_vl_throttle_shut_off_unit_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.throttle_shut_off_unit_kind
    ADD CONSTRAINT pkey_qgep_vl_throttle_shut_off_unit_kind_code PRIMARY KEY (code);


--
-- Name: throttle_shut_off_unit_signal_transmission pkey_qgep_vl_throttle_shut_off_unit_signal_transmission_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.throttle_shut_off_unit_signal_transmission
    ADD CONSTRAINT pkey_qgep_vl_throttle_shut_off_unit_signal_transmission_code PRIMARY KEY (code);


--
-- Name: waste_water_treatment_kind pkey_qgep_vl_waste_water_treatment_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.waste_water_treatment_kind
    ADD CONSTRAINT pkey_qgep_vl_waste_water_treatment_kind_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_accessibility pkey_qgep_vl_wastewater_structure_accessibility_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_accessibility
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_accessibility_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_financing pkey_qgep_vl_wastewater_structure_financing_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_financing
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_financing_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_renovation_necessity pkey_qgep_vl_wastewater_structure_renovation_necessity_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_renovation_necessity
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_renovation_necessity_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_rv_construction_type pkey_qgep_vl_wastewater_structure_rv_construction_type_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_rv_construction_type
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_rv_construction_type_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_status pkey_qgep_vl_wastewater_structure_status_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_status
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_status_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_structure_condition pkey_qgep_vl_wastewater_structure_structure_condition_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_structure_condition
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_structure_condition_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_symbol_plantype pkey_qgep_vl_wastewater_structure_symbol_plantype_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_symbol_plantype
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_symbol_plantype_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_text_plantype pkey_qgep_vl_wastewater_structure_text_plantype_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_text_plantype
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_text_plantype_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_text_texthali pkey_qgep_vl_wastewater_structure_text_texthali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_text_texthali
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_text_texthali_code PRIMARY KEY (code);


--
-- Name: wastewater_structure_text_textvali pkey_qgep_vl_wastewater_structure_text_textvali_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wastewater_structure_text_textvali
    ADD CONSTRAINT pkey_qgep_vl_wastewater_structure_text_textvali_code PRIMARY KEY (code);


--
-- Name: water_body_protection_sector_kind pkey_qgep_vl_water_body_protection_sector_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_body_protection_sector_kind
    ADD CONSTRAINT pkey_qgep_vl_water_body_protection_sector_kind_code PRIMARY KEY (code);


--
-- Name: water_catchment_kind pkey_qgep_vl_water_catchment_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_catchment_kind
    ADD CONSTRAINT pkey_qgep_vl_water_catchment_kind_code PRIMARY KEY (code);


--
-- Name: water_course_segment_algae_growth pkey_qgep_vl_water_course_segment_algae_growth_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_algae_growth
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_algae_growth_code PRIMARY KEY (code);


--
-- Name: water_course_segment_altitudinal_zone pkey_qgep_vl_water_course_segment_altitudinal_zone_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_altitudinal_zone
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_altitudinal_zone_code PRIMARY KEY (code);


--
-- Name: water_course_segment_dead_wood pkey_qgep_vl_water_course_segment_dead_wood_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_dead_wood
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_dead_wood_code PRIMARY KEY (code);


--
-- Name: water_course_segment_depth_variability pkey_qgep_vl_water_course_segment_depth_variability_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_depth_variability
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_depth_variability_code PRIMARY KEY (code);


--
-- Name: water_course_segment_discharge_regime pkey_qgep_vl_water_course_segment_discharge_regime_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_discharge_regime
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_discharge_regime_code PRIMARY KEY (code);


--
-- Name: water_course_segment_ecom_classification pkey_qgep_vl_water_course_segment_ecom_classification_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_ecom_classification
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_ecom_classification_code PRIMARY KEY (code);


--
-- Name: water_course_segment_kind pkey_qgep_vl_water_course_segment_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_kind
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_kind_code PRIMARY KEY (code);


--
-- Name: water_course_segment_length_profile pkey_qgep_vl_water_course_segment_length_profile_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_length_profile
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_length_profile_code PRIMARY KEY (code);


--
-- Name: water_course_segment_macrophyte_coverage pkey_qgep_vl_water_course_segment_macrophyte_coverage_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_macrophyte_coverage
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_macrophyte_coverage_code PRIMARY KEY (code);


--
-- Name: water_course_segment_section_morphology pkey_qgep_vl_water_course_segment_section_morphology_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_section_morphology
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_section_morphology_code PRIMARY KEY (code);


--
-- Name: water_course_segment_slope pkey_qgep_vl_water_course_segment_slope_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_slope
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_slope_code PRIMARY KEY (code);


--
-- Name: water_course_segment_utilisation pkey_qgep_vl_water_course_segment_utilisation_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_utilisation
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_utilisation_code PRIMARY KEY (code);


--
-- Name: water_course_segment_water_hardness pkey_qgep_vl_water_course_segment_water_hardness_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_water_hardness
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_water_hardness_code PRIMARY KEY (code);


--
-- Name: water_course_segment_width_variability pkey_qgep_vl_water_course_segment_width_variability_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.water_course_segment_width_variability
    ADD CONSTRAINT pkey_qgep_vl_water_course_segment_width_variability_code PRIMARY KEY (code);


--
-- Name: wwtp_structure_kind pkey_qgep_vl_wwtp_structure_kind_code; Type: CONSTRAINT; Schema: qgep_vl; Owner: postgres
--

ALTER TABLE ONLY qgep_vl.wwtp_structure_kind
    ADD CONSTRAINT pkey_qgep_vl_wwtp_structure_kind_code PRIMARY KEY (code);


--
-- Name: in_od_accident_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_accident_identifier ON qgep_od.accident USING btree (identifier, fk_dataowner);


--
-- Name: in_od_aquifier_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_aquifier_identifier ON qgep_od.aquifier USING btree (identifier, fk_dataowner);


--
-- Name: in_od_bathing_area_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_bathing_area_identifier ON qgep_od.bathing_area USING btree (identifier, fk_dataowner);


--
-- Name: in_od_catchment_area_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_catchment_area_identifier ON qgep_od.catchment_area USING btree (identifier, fk_dataowner);


--
-- Name: in_od_channel_function_hierarchic_usage_current; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_od_channel_function_hierarchic_usage_current ON qgep_od.channel USING btree (function_hierarchic, usage_current);


--
-- Name: in_od_connection_object_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_connection_object_identifier ON qgep_od.connection_object USING btree (identifier, fk_dataowner);


--
-- Name: in_od_control_center_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_control_center_identifier ON qgep_od.control_center USING btree (identifier, fk_dataowner);


--
-- Name: in_od_data_media_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_data_media_identifier ON qgep_od.data_media USING btree (identifier, fk_dataowner);


--
-- Name: in_od_file_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_file_identifier ON qgep_od.file USING btree (identifier, fk_dataowner);


--
-- Name: in_od_fish_pass_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_fish_pass_identifier ON qgep_od.fish_pass USING btree (identifier, fk_dataowner);


--
-- Name: in_od_hazard_source_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_hazard_source_identifier ON qgep_od.hazard_source USING btree (identifier, fk_dataowner);


--
-- Name: in_od_hydr_geometry_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_hydr_geometry_identifier ON qgep_od.hydr_geometry USING btree (identifier, fk_dataowner);


--
-- Name: in_od_hydraulic_char_data_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_hydraulic_char_data_identifier ON qgep_od.hydraulic_char_data USING btree (identifier, fk_dataowner);


--
-- Name: in_od_maintenance_event_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_maintenance_event_identifier ON qgep_od.maintenance_event USING btree (identifier, fk_dataowner);


--
-- Name: in_od_manhole_function; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_od_manhole_function ON qgep_od.manhole USING btree (function);


--
-- Name: in_od_measurement_result_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_measurement_result_identifier ON qgep_od.measurement_result USING btree (identifier, fk_dataowner);


--
-- Name: in_od_measurement_series_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_measurement_series_identifier ON qgep_od.measurement_series USING btree (identifier, fk_dataowner);


--
-- Name: in_od_measuring_device_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_measuring_device_identifier ON qgep_od.measuring_device USING btree (identifier, fk_dataowner);


--
-- Name: in_od_measuring_point_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_measuring_point_identifier ON qgep_od.measuring_point USING btree (identifier, fk_dataowner);


--
-- Name: in_od_mechanical_pretreatment_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_mechanical_pretreatment_identifier ON qgep_od.mechanical_pretreatment USING btree (identifier, fk_dataowner);


--
-- Name: in_od_organisation_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_organisation_identifier ON qgep_od.organisation USING btree (identifier, fk_dataowner);


--
-- Name: in_od_overflow_char_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_overflow_char_identifier ON qgep_od.overflow_char USING btree (identifier, fk_dataowner);


--
-- Name: in_od_overflow_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_overflow_identifier ON qgep_od.overflow USING btree (identifier, fk_dataowner);


--
-- Name: in_od_pipe_profile_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_pipe_profile_identifier ON qgep_od.pipe_profile USING btree (identifier, fk_dataowner);


--
-- Name: in_od_reach_point_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_reach_point_identifier ON qgep_od.reach_point USING btree (identifier, fk_dataowner);


--
-- Name: in_od_retention_body_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_retention_body_identifier ON qgep_od.retention_body USING btree (identifier, fk_dataowner);


--
-- Name: in_od_river_bank_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_river_bank_identifier ON qgep_od.river_bank USING btree (identifier, fk_dataowner);


--
-- Name: in_od_river_bed_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_river_bed_identifier ON qgep_od.river_bed USING btree (identifier, fk_dataowner);


--
-- Name: in_od_sector_water_body_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_sector_water_body_identifier ON qgep_od.sector_water_body USING btree (identifier, fk_dataowner);


--
-- Name: in_od_sludge_treatment_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_sludge_treatment_identifier ON qgep_od.sludge_treatment USING btree (identifier, fk_dataowner);


--
-- Name: in_od_special_structure_function; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_od_special_structure_function ON qgep_od.special_structure USING btree (function);


--
-- Name: in_od_structure_part_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_structure_part_identifier ON qgep_od.structure_part USING btree (identifier, fk_dataowner);


--
-- Name: in_od_substance_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_substance_identifier ON qgep_od.substance USING btree (identifier, fk_dataowner);


--
-- Name: in_od_surface_runoff_parameters_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_surface_runoff_parameters_identifier ON qgep_od.surface_runoff_parameters USING btree (identifier, fk_dataowner);


--
-- Name: in_od_surface_water_bodies_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_surface_water_bodies_identifier ON qgep_od.surface_water_bodies USING btree (identifier, fk_dataowner);


--
-- Name: in_od_throttle_shut_off_unit_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_throttle_shut_off_unit_identifier ON qgep_od.throttle_shut_off_unit USING btree (identifier, fk_dataowner);


--
-- Name: in_od_waste_water_treatment_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_waste_water_treatment_identifier ON qgep_od.waste_water_treatment USING btree (identifier, fk_dataowner);


--
-- Name: in_od_wastewater_networkelement_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_wastewater_networkelement_identifier ON qgep_od.wastewater_networkelement USING btree (identifier, fk_dataowner);


--
-- Name: in_od_wastewater_structure_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_wastewater_structure_identifier ON qgep_od.wastewater_structure USING btree (identifier, fk_dataowner);


--
-- Name: in_od_water_catchment_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_water_catchment_identifier ON qgep_od.water_catchment USING btree (identifier, fk_dataowner);


--
-- Name: in_od_water_control_structure_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_water_control_structure_identifier ON qgep_od.water_control_structure USING btree (identifier, fk_dataowner);


--
-- Name: in_od_water_course_segment_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_water_course_segment_identifier ON qgep_od.water_course_segment USING btree (identifier, fk_dataowner);


--
-- Name: in_od_wwtp_energy_use_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_wwtp_energy_use_identifier ON qgep_od.wwtp_energy_use USING btree (identifier, fk_dataowner);


--
-- Name: in_od_zone_identifier; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE UNIQUE INDEX in_od_zone_identifier ON qgep_od.zone USING btree (identifier, fk_dataowner);


--
-- Name: in_qgep_od_accident_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_accident_situation_geometry ON qgep_od.accident USING gist (situation_geometry);


--
-- Name: in_qgep_od_aquifier_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_aquifier_perimeter_geometry ON qgep_od.aquifier USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_bathing_area_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_bathing_area_situation_geometry ON qgep_od.bathing_area USING gist (situation_geometry);


--
-- Name: in_qgep_od_building_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_building_perimeter_geometry ON qgep_od.building USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_building_reference_point_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_building_reference_point_geometry ON qgep_od.building USING gist (reference_point_geometry);


--
-- Name: in_qgep_od_canton_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_canton_perimeter_geometry ON qgep_od.canton USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_catchment_area_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_catchment_area_perimeter_geometry ON qgep_od.catchment_area USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_catchment_area_text_textpos_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_catchment_area_text_textpos_geometry ON qgep_od.catchment_area_text USING gist (textpos_geometry);


--
-- Name: in_qgep_od_control_center_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_control_center_situation_geometry ON qgep_od.control_center USING gist (situation_geometry);


--
-- Name: in_qgep_od_cover_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_cover_situation_geometry ON qgep_od.cover USING gist (situation_geometry);


--
-- Name: in_qgep_od_drainage_system_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_drainage_system_perimeter_geometry ON qgep_od.drainage_system USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_fountain_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_fountain_situation_geometry ON qgep_od.fountain USING gist (situation_geometry);


--
-- Name: in_qgep_od_ground_water_protection_perimeter_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_ground_water_protection_perimeter_perimeter_geometry ON qgep_od.ground_water_protection_perimeter USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_groundwater_protection_zone_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_groundwater_protection_zone_perimeter_geometry ON qgep_od.groundwater_protection_zone USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_hazard_source_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_hazard_source_situation_geometry ON qgep_od.hazard_source USING gist (situation_geometry);


--
-- Name: in_qgep_od_individual_surface_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_individual_surface_perimeter_geometry ON qgep_od.individual_surface USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_infiltration_zone_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_infiltration_zone_perimeter_geometry ON qgep_od.infiltration_zone USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_lake_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_lake_perimeter_geometry ON qgep_od.lake USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_measuring_point_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_measuring_point_situation_geometry ON qgep_od.measuring_point USING gist (situation_geometry);


--
-- Name: in_qgep_od_municipality_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_municipality_perimeter_geometry ON qgep_od.municipality USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_planning_zone_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_planning_zone_perimeter_geometry ON qgep_od.planning_zone USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_reach_point_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_reach_point_situation_geometry ON qgep_od.reach_point USING gist (situation_geometry);


--
-- Name: in_qgep_od_reach_progression_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_reach_progression_geometry ON qgep_od.reach USING gist (progression_geometry);


--
-- Name: in_qgep_od_reach_text_textpos_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_reach_text_textpos_geometry ON qgep_od.reach_text USING gist (textpos_geometry);


--
-- Name: in_qgep_od_reservoir_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_reservoir_situation_geometry ON qgep_od.reservoir USING gist (situation_geometry);


--
-- Name: in_qgep_od_sector_water_body_progression_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_sector_water_body_progression_geometry ON qgep_od.sector_water_body USING gist (progression_geometry);


--
-- Name: in_qgep_od_wastewater_node_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_wastewater_node_situation_geometry ON qgep_od.wastewater_node USING gist (situation_geometry);


--
-- Name: in_qgep_od_wastewater_structure_detail_geometry_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_wastewater_structure_detail_geometry_geometry ON qgep_od.wastewater_structure USING gist (detail_geometry_geometry);


--
-- Name: in_qgep_od_wastewater_structure_symbol_symbolpos_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_wastewater_structure_symbol_symbolpos_geometry ON qgep_od.wastewater_structure_symbol USING gist (symbolpos_geometry);


--
-- Name: in_qgep_od_wastewater_structure_text_textpos_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_wastewater_structure_text_textpos_geometry ON qgep_od.wastewater_structure_text USING gist (textpos_geometry);


--
-- Name: in_qgep_od_water_body_protection_sector_perimeter_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_water_body_protection_sector_perimeter_geometry ON qgep_od.water_body_protection_sector USING gist (perimeter_geometry);


--
-- Name: in_qgep_od_water_catchment_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_water_catchment_situation_geometry ON qgep_od.water_catchment USING gist (situation_geometry);


--
-- Name: in_qgep_od_water_control_structure_situation_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_water_control_structure_situation_geometry ON qgep_od.water_control_structure USING gist (situation_geometry);


--
-- Name: in_qgep_od_water_course_segment_from_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_water_course_segment_from_geometry ON qgep_od.water_course_segment USING gist (from_geometry);


--
-- Name: in_qgep_od_water_course_segment_to_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_od_water_course_segment_to_geometry ON qgep_od.water_course_segment USING gist (to_geometry);


--
-- Name: in_qgep_txt_symbol_symbolpos_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_txt_symbol_symbolpos_geometry ON qgep_od.txt_symbol USING gist (symbolpos_geometry);


--
-- Name: in_qgep_txt_text_textpos_geometry; Type: INDEX; Schema: qgep_od; Owner: postgres
--

CREATE INDEX in_qgep_txt_text_textpos_geometry ON qgep_od.txt_text USING gist (textpos_geometry);


--
-- Name: in_qgep_is_oid_prefixes_active; Type: INDEX; Schema: qgep_sys; Owner: postgres
--

CREATE INDEX in_qgep_is_oid_prefixes_active ON qgep_sys.oid_prefixes USING btree (active);


--
-- Name: in_qgep_is_oid_prefixes_id; Type: INDEX; Schema: qgep_sys; Owner: postgres
--

CREATE UNIQUE INDEX in_qgep_is_oid_prefixes_id ON qgep_sys.oid_prefixes USING btree (id);


--
-- Name: logged_actions_action_idx; Type: INDEX; Schema: qgep_sys; Owner: postgres
--

CREATE INDEX logged_actions_action_idx ON qgep_sys.logged_actions USING btree (action);


--
-- Name: logged_actions_action_tstamp_tx_stm_idx; Type: INDEX; Schema: qgep_sys; Owner: postgres
--

CREATE INDEX logged_actions_action_tstamp_tx_stm_idx ON qgep_sys.logged_actions USING btree (action_tstamp_stm);


--
-- Name: logged_actions_relid_idx; Type: INDEX; Schema: qgep_sys; Owner: postgres
--

CREATE INDEX logged_actions_relid_idx ON qgep_sys.logged_actions USING btree (relid);


--
-- Name: vw_access_aid vw_access_aid_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_access_aid_on_delete AS
    ON DELETE TO qgep_od.vw_access_aid DO INSTEAD ( DELETE FROM qgep_od.access_aid
  WHERE ((access_aid.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.structure_part
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_access_aid vw_access_aid_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_access_aid_on_update AS
    ON UPDATE TO qgep_od.vw_access_aid DO INSTEAD ( UPDATE qgep_od.access_aid SET kind = new.kind
  WHERE ((access_aid.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.structure_part SET identifier = new.identifier, remark = new.remark, renovation_demand = new.renovation_demand, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_backflow_prevention vw_backflow_prevention_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_backflow_prevention_on_delete AS
    ON DELETE TO qgep_od.vw_backflow_prevention DO INSTEAD ( DELETE FROM qgep_od.backflow_prevention
  WHERE ((backflow_prevention.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.structure_part
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_backflow_prevention vw_backflow_prevention_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_backflow_prevention_on_update AS
    ON UPDATE TO qgep_od.vw_backflow_prevention DO INSTEAD ( UPDATE qgep_od.backflow_prevention SET gross_costs = new.gross_costs, kind = new.kind, year_of_replacement = new.year_of_replacement
  WHERE ((backflow_prevention.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.structure_part SET identifier = new.identifier, remark = new.remark, renovation_demand = new.renovation_demand, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_benching vw_benching_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_benching_on_delete AS
    ON DELETE TO qgep_od.vw_benching DO INSTEAD ( DELETE FROM qgep_od.benching
  WHERE ((benching.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.structure_part
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_benching vw_benching_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_benching_on_update AS
    ON UPDATE TO qgep_od.vw_benching DO INSTEAD ( UPDATE qgep_od.benching SET kind = new.kind
  WHERE ((benching.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.structure_part SET identifier = new.identifier, remark = new.remark, renovation_demand = new.renovation_demand, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_channel vw_channel_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_channel_on_delete AS
    ON DELETE TO qgep_od.vw_channel DO INSTEAD ( DELETE FROM qgep_od.channel
  WHERE ((channel.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.wastewater_structure
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_channel vw_channel_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_channel_on_update AS
    ON UPDATE TO qgep_od.vw_channel DO INSTEAD ( UPDATE qgep_od.channel SET bedding_encasement = new.bedding_encasement, connection_type = new.connection_type, function_hierarchic = new.function_hierarchic, function_hydraulic = new.function_hydraulic, jetting_interval = new.jetting_interval, pipe_length = new.pipe_length, usage_current = new.usage_current, usage_planned = new.usage_planned
  WHERE ((channel.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.wastewater_structure SET accessibility = new.accessibility, contract_section = new.contract_section, detail_geometry_geometry = new.detail_geometry_geometry, financing = new.financing, gross_costs = new.gross_costs, identifier = new.identifier, inspection_interval = new.inspection_interval, location_name = new.location_name, records = new.records, remark = new.remark, renovation_necessity = new.renovation_necessity, replacement_value = new.replacement_value, rv_base_year = new.rv_base_year, rv_construction_type = new.rv_construction_type, status = new.status, structure_condition = new.structure_condition, subsidies = new.subsidies, year_of_construction = new.year_of_construction, year_of_replacement = new.year_of_replacement, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_owner = new.fk_owner, fk_operator = new.fk_operator
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_cover vw_cover_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_cover_on_delete AS
    ON DELETE TO qgep_od.vw_cover DO INSTEAD ( DELETE FROM qgep_od.cover
  WHERE ((cover.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.structure_part
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_cover vw_cover_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_cover_on_update AS
    ON UPDATE TO qgep_od.vw_cover DO INSTEAD ( UPDATE qgep_od.cover SET brand = new.brand, cover_shape = new.cover_shape, diameter = new.diameter, fastening = new.fastening, level = new.level, material = new.material, positional_accuracy = new.positional_accuracy, situation_geometry = new.situation_geometry, sludge_bucket = new.sludge_bucket, venting = new.venting
  WHERE ((cover.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.structure_part SET identifier = new.identifier, remark = new.remark, renovation_demand = new.renovation_demand, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_discharge_point vw_discharge_point_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_discharge_point_on_delete AS
    ON DELETE TO qgep_od.vw_discharge_point DO INSTEAD ( DELETE FROM qgep_od.discharge_point
  WHERE ((discharge_point.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.wastewater_structure
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_discharge_point vw_discharge_point_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_discharge_point_on_update AS
    ON UPDATE TO qgep_od.vw_discharge_point DO INSTEAD ( UPDATE qgep_od.discharge_point SET highwater_level = new.highwater_level, relevance = new.relevance, terrain_level = new.terrain_level, upper_elevation = new.upper_elevation, waterlevel_hydraulic = new.waterlevel_hydraulic
  WHERE ((discharge_point.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.wastewater_structure SET accessibility = new.accessibility, contract_section = new.contract_section, detail_geometry_geometry = new.detail_geometry_geometry, financing = new.financing, gross_costs = new.gross_costs, identifier = new.identifier, inspection_interval = new.inspection_interval, location_name = new.location_name, records = new.records, remark = new.remark, renovation_necessity = new.renovation_necessity, replacement_value = new.replacement_value, rv_base_year = new.rv_base_year, rv_construction_type = new.rv_construction_type, status = new.status, structure_condition = new.structure_condition, subsidies = new.subsidies, year_of_construction = new.year_of_construction, year_of_replacement = new.year_of_replacement, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_owner = new.fk_owner, fk_operator = new.fk_operator
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_dryweather_downspout vw_dryweather_downspout_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_dryweather_downspout_on_delete AS
    ON DELETE TO qgep_od.vw_dryweather_downspout DO INSTEAD ( DELETE FROM qgep_od.dryweather_downspout
  WHERE ((dryweather_downspout.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.structure_part
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_dryweather_downspout vw_dryweather_downspout_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_dryweather_downspout_on_update AS
    ON UPDATE TO qgep_od.vw_dryweather_downspout DO INSTEAD ( UPDATE qgep_od.dryweather_downspout SET diameter = new.diameter
  WHERE ((dryweather_downspout.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.structure_part SET identifier = new.identifier, remark = new.remark, renovation_demand = new.renovation_demand, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_dryweather_flume vw_dryweather_flume_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_dryweather_flume_on_delete AS
    ON DELETE TO qgep_od.vw_dryweather_flume DO INSTEAD ( DELETE FROM qgep_od.dryweather_flume
  WHERE ((dryweather_flume.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.structure_part
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_dryweather_flume vw_dryweather_flume_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_dryweather_flume_on_update AS
    ON UPDATE TO qgep_od.vw_dryweather_flume DO INSTEAD ( UPDATE qgep_od.dryweather_flume SET material = new.material
  WHERE ((dryweather_flume.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.structure_part SET identifier = new.identifier, remark = new.remark, renovation_demand = new.renovation_demand, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((structure_part.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_manhole vw_manhole_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_manhole_on_delete AS
    ON DELETE TO qgep_od.vw_manhole DO INSTEAD ( DELETE FROM qgep_od.manhole
  WHERE ((manhole.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.wastewater_structure
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_manhole vw_manhole_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_manhole_on_update AS
    ON UPDATE TO qgep_od.vw_manhole DO INSTEAD ( UPDATE qgep_od.manhole SET dimension1 = new.dimension1, dimension2 = new.dimension2, function = new.function, material = new.material, surface_inflow = new.surface_inflow
  WHERE ((manhole.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.wastewater_structure SET accessibility = new.accessibility, contract_section = new.contract_section, detail_geometry_geometry = new.detail_geometry_geometry, financing = new.financing, gross_costs = new.gross_costs, identifier = new.identifier, inspection_interval = new.inspection_interval, location_name = new.location_name, records = new.records, remark = new.remark, renovation_necessity = new.renovation_necessity, replacement_value = new.replacement_value, rv_base_year = new.rv_base_year, rv_construction_type = new.rv_construction_type, status = new.status, structure_condition = new.structure_condition, subsidies = new.subsidies, year_of_construction = new.year_of_construction, year_of_replacement = new.year_of_replacement, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_owner = new.fk_owner, fk_operator = new.fk_operator
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_qgep_reach vw_qgep_reach_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_qgep_reach_on_delete AS
    ON DELETE TO qgep_od.vw_qgep_reach DO INSTEAD ( DELETE FROM qgep_od.reach
  WHERE ((reach.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.wastewater_networkelement
  WHERE ((wastewater_networkelement.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.reach_point
  WHERE ((reach_point.obj_id)::text = (old.rp_from_obj_id)::text);
 DELETE FROM qgep_od.reach_point
  WHERE ((reach_point.obj_id)::text = (old.rp_to_obj_id)::text);
);


--
-- Name: vw_qgep_reach vw_qgep_reach_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_qgep_reach_on_update AS
    ON UPDATE TO qgep_od.vw_qgep_reach DO INSTEAD ( UPDATE qgep_od.reach_point SET elevation_accuracy = new.rp_from_elevation_accuracy, identifier = new.rp_from_identifier, level = new.rp_from_level, outlet_shape = new.rp_from_outlet_shape, position_of_connection = new.rp_from_position_of_connection, remark = new.rp_from_remark, situation_geometry = public.st_force2d(public.st_startpoint(new.progression_geometry)), last_modification = new.rp_from_last_modification, fk_dataowner = new.rp_from_fk_dataowner, fk_provider = new.rp_from_fk_provider, fk_wastewater_networkelement = new.rp_from_fk_wastewater_networkelement
  WHERE ((reach_point.obj_id)::text = (old.rp_from_obj_id)::text);
 UPDATE qgep_od.reach_point SET elevation_accuracy = new.rp_to_elevation_accuracy, identifier = new.rp_to_identifier, level = new.rp_to_level, outlet_shape = new.rp_to_outlet_shape, position_of_connection = new.rp_to_position_of_connection, remark = new.rp_to_remark, situation_geometry = public.st_force2d(public.st_endpoint(new.progression_geometry)), last_modification = new.rp_to_last_modification, fk_dataowner = new.rp_to_fk_dataowner, fk_provider = new.rp_to_fk_provider, fk_wastewater_networkelement = new.rp_to_fk_wastewater_networkelement
  WHERE ((reach_point.obj_id)::text = (old.rp_to_obj_id)::text);
 UPDATE qgep_od.channel SET bedding_encasement = new.bedding_encasement, connection_type = new.connection_type, function_hierarchic = new.function_hierarchic, function_hydraulic = new.function_hydraulic, jetting_interval = new.jetting_interval, pipe_length = new.pipe_length, usage_current = new.usage_current, usage_planned = new.usage_planned
  WHERE ((channel.obj_id)::text = (old.fk_wastewater_structure)::text);
 UPDATE qgep_od.wastewater_structure SET accessibility = new.accessibility, contract_section = new.contract_section, financing = new.financing, gross_costs = new.gross_costs, identifier = new.identifier, inspection_interval = new.inspection_interval, location_name = new.location_name, records = new.records, remark = new.remark, renovation_necessity = new.renovation_necessity, replacement_value = new.replacement_value, rv_base_year = new.rv_base_year, rv_construction_type = new.rv_construction_type, status = new.status, structure_condition = new.structure_condition, subsidies = new.subsidies, year_of_construction = new.year_of_construction, year_of_replacement = new.year_of_replacement, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_owner = new.fk_owner, fk_operator = new.fk_operator
  WHERE ((wastewater_structure.obj_id)::text = (old.fk_wastewater_structure)::text);
 UPDATE qgep_od.wastewater_networkelement SET identifier = new.identifier, remark = new.remark, last_modification = new.last_modification, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((wastewater_networkelement.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.reach SET clear_height = new.clear_height, coefficient_of_friction = new.coefficient_of_friction, elevation_determination = new.elevation_determination, horizontal_positioning = new.horizontal_positioning, inside_coating = new.inside_coating, length_effective = new.length_effective, material = new.material, progression_geometry = new.progression_geometry, reliner_material = new.reliner_material, reliner_nominal_size = new.reliner_nominal_size, relining_construction = new.relining_construction, relining_kind = new.relining_kind, ring_stiffness = new.ring_stiffness, slope_building_plan = new.slope_building_plan, wall_roughness = new.wall_roughness, fk_pipe_profile = new.fk_pipe_profile
  WHERE ((reach.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_reach vw_reach_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_reach_on_delete AS
    ON DELETE TO qgep_od.vw_reach DO INSTEAD ( DELETE FROM qgep_od.reach
  WHERE ((reach.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.wastewater_networkelement
  WHERE ((wastewater_networkelement.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_reach vw_reach_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_reach_on_update AS
    ON UPDATE TO qgep_od.vw_reach DO INSTEAD ( UPDATE qgep_od.reach SET clear_height = new.clear_height, coefficient_of_friction = new.coefficient_of_friction, elevation_determination = new.elevation_determination, horizontal_positioning = new.horizontal_positioning, inside_coating = new.inside_coating, length_effective = new.length_effective, material = new.material, progression_geometry = new.progression_geometry, reliner_material = new.reliner_material, reliner_nominal_size = new.reliner_nominal_size, relining_construction = new.relining_construction, relining_kind = new.relining_kind, ring_stiffness = new.ring_stiffness, slope_building_plan = new.slope_building_plan, wall_roughness = new.wall_roughness
  WHERE ((reach.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.wastewater_networkelement SET identifier = new.identifier, remark = new.remark, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((wastewater_networkelement.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_special_structure vw_special_structure_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_special_structure_on_delete AS
    ON DELETE TO qgep_od.vw_special_structure DO INSTEAD ( DELETE FROM qgep_od.special_structure
  WHERE ((special_structure.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.wastewater_structure
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_special_structure vw_special_structure_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_special_structure_on_update AS
    ON UPDATE TO qgep_od.vw_special_structure DO INSTEAD ( UPDATE qgep_od.special_structure SET bypass = new.bypass, emergency_spillway = new.emergency_spillway, function = new.function, stormwater_tank_arrangement = new.stormwater_tank_arrangement, upper_elevation = new.upper_elevation
  WHERE ((special_structure.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.wastewater_structure SET accessibility = new.accessibility, contract_section = new.contract_section, detail_geometry_geometry = new.detail_geometry_geometry, financing = new.financing, gross_costs = new.gross_costs, identifier = new.identifier, inspection_interval = new.inspection_interval, location_name = new.location_name, records = new.records, remark = new.remark, renovation_necessity = new.renovation_necessity, replacement_value = new.replacement_value, rv_base_year = new.rv_base_year, rv_construction_type = new.rv_construction_type, status = new.status, structure_condition = new.structure_condition, subsidies = new.subsidies, year_of_construction = new.year_of_construction, year_of_replacement = new.year_of_replacement, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_owner = new.fk_owner, fk_operator = new.fk_operator
  WHERE ((wastewater_structure.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_wastewater_node vw_wastewater_node_on_delete; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_wastewater_node_on_delete AS
    ON DELETE TO qgep_od.vw_wastewater_node DO INSTEAD ( DELETE FROM qgep_od.wastewater_node
  WHERE ((wastewater_node.obj_id)::text = (old.obj_id)::text);
 DELETE FROM qgep_od.wastewater_networkelement
  WHERE ((wastewater_networkelement.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: vw_wastewater_node vw_wastewater_node_on_update; Type: RULE; Schema: qgep_od; Owner: postgres
--

CREATE RULE vw_wastewater_node_on_update AS
    ON UPDATE TO qgep_od.vw_wastewater_node DO INSTEAD ( UPDATE qgep_od.wastewater_node SET backflow_level = new.backflow_level, bottom_level = new.bottom_level, situation_geometry = new.situation_geometry
  WHERE ((wastewater_node.obj_id)::text = (old.obj_id)::text);
 UPDATE qgep_od.wastewater_networkelement SET identifier = new.identifier, remark = new.remark, fk_dataowner = new.fk_dataowner, fk_provider = new.fk_provider, last_modification = new.last_modification, fk_wastewater_structure = new.fk_wastewater_structure
  WHERE ((wastewater_networkelement.obj_id)::text = (old.obj_id)::text);
);


--
-- Name: reach calculate_reach_length; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER calculate_reach_length BEFORE INSERT OR UPDATE ON qgep_od.reach FOR EACH ROW EXECUTE PROCEDURE qgep_od.calculate_reach_length();


--
-- Name: cover on_cover_change; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER on_cover_change AFTER INSERT OR DELETE OR UPDATE ON qgep_od.cover FOR EACH ROW EXECUTE PROCEDURE qgep_od.on_cover_change();


--
-- Name: reach on_reach_change; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER on_reach_change AFTER INSERT OR DELETE OR UPDATE ON qgep_od.reach FOR EACH ROW EXECUTE PROCEDURE qgep_od.on_reach_change();


--
-- Name: reach_point on_reach_point_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER on_reach_point_update AFTER UPDATE ON qgep_od.reach_point FOR EACH ROW EXECUTE PROCEDURE qgep_od.on_reach_point_update();


--
-- Name: structure_part on_structure_part_change; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER on_structure_part_change AFTER INSERT OR DELETE OR UPDATE ON qgep_od.structure_part FOR EACH ROW EXECUTE PROCEDURE qgep_od.on_structure_part_change_networkelement();


--
-- Name: wastewater_structure on_wastewater_structure_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER on_wastewater_structure_update AFTER UPDATE ON qgep_od.wastewater_structure FOR EACH ROW EXECUTE PROCEDURE qgep_od.on_wastewater_structure_update();


--
-- Name: vw_damage_channel tr_damage_channel_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_damage_channel_delete INSTEAD OF DELETE ON qgep_od.vw_damage_channel FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_damage_channel_delete();


--
-- Name: vw_damage_channel tr_damage_channel_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_damage_channel_insert INSTEAD OF INSERT ON qgep_od.vw_damage_channel FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_damage_channel_insert();


--
-- Name: vw_damage_channel tr_damage_channel_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_damage_channel_update INSTEAD OF UPDATE ON qgep_od.vw_damage_channel FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_damage_channel_update();


--
-- Name: vw_damage_manhole tr_damage_manhole_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_damage_manhole_delete INSTEAD OF DELETE ON qgep_od.vw_damage_manhole FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_damage_manhole_delete();


--
-- Name: vw_damage_manhole tr_damage_manhole_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_damage_manhole_insert INSTEAD OF INSERT ON qgep_od.vw_damage_manhole FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_damage_manhole_insert();


--
-- Name: vw_damage_manhole tr_damage_manhole_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_damage_manhole_update INSTEAD OF UPDATE ON qgep_od.vw_damage_manhole FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_damage_manhole_update();


--
-- Name: vw_maintenance_examination tr_maintenance_examination_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_maintenance_examination_delete INSTEAD OF DELETE ON qgep_od.vw_maintenance_examination FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_maintenance_examination_delete();


--
-- Name: vw_maintenance_examination tr_maintenance_examination_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_maintenance_examination_insert INSTEAD OF INSERT ON qgep_od.vw_maintenance_examination FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_maintenance_examination_insert();


--
-- Name: vw_maintenance_examination tr_maintenance_examination_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_maintenance_examination_update INSTEAD OF UPDATE ON qgep_od.vw_maintenance_examination FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_maintenance_examination_update();


--
-- Name: vw_organisation_administrative_office tr_organisation_administrative_office_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_administrative_office_delete INSTEAD OF DELETE ON qgep_od.vw_organisation_administrative_office FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_administrative_office_delete();


--
-- Name: vw_organisation_administrative_office tr_organisation_administrative_office_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_administrative_office_insert INSTEAD OF INSERT ON qgep_od.vw_organisation_administrative_office FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_administrative_office_insert();


--
-- Name: vw_organisation_administrative_office tr_organisation_administrative_office_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_administrative_office_update INSTEAD OF UPDATE ON qgep_od.vw_organisation_administrative_office FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_administrative_office_update();


--
-- Name: vw_organisation_canton tr_organisation_canton_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_canton_delete INSTEAD OF DELETE ON qgep_od.vw_organisation_canton FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_canton_delete();


--
-- Name: vw_organisation_canton tr_organisation_canton_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_canton_insert INSTEAD OF INSERT ON qgep_od.vw_organisation_canton FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_canton_insert();


--
-- Name: vw_organisation_canton tr_organisation_canton_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_canton_update INSTEAD OF UPDATE ON qgep_od.vw_organisation_canton FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_canton_update();


--
-- Name: vw_organisation_cooperative tr_organisation_cooperative_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_cooperative_delete INSTEAD OF DELETE ON qgep_od.vw_organisation_cooperative FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_cooperative_delete();


--
-- Name: vw_organisation_cooperative tr_organisation_cooperative_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_cooperative_insert INSTEAD OF INSERT ON qgep_od.vw_organisation_cooperative FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_cooperative_insert();


--
-- Name: vw_organisation_cooperative tr_organisation_cooperative_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_cooperative_update INSTEAD OF UPDATE ON qgep_od.vw_organisation_cooperative FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_cooperative_update();


--
-- Name: vw_organisation_municipality tr_organisation_municipality_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_municipality_delete INSTEAD OF DELETE ON qgep_od.vw_organisation_municipality FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_municipality_delete();


--
-- Name: vw_organisation_municipality tr_organisation_municipality_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_municipality_insert INSTEAD OF INSERT ON qgep_od.vw_organisation_municipality FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_municipality_insert();


--
-- Name: vw_organisation_municipality tr_organisation_municipality_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_municipality_update INSTEAD OF UPDATE ON qgep_od.vw_organisation_municipality FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_municipality_update();


--
-- Name: vw_organisation_private tr_organisation_private_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_private_delete INSTEAD OF DELETE ON qgep_od.vw_organisation_private FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_private_delete();


--
-- Name: vw_organisation_private tr_organisation_private_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_private_insert INSTEAD OF INSERT ON qgep_od.vw_organisation_private FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_private_insert();


--
-- Name: vw_organisation_private tr_organisation_private_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_private_update INSTEAD OF UPDATE ON qgep_od.vw_organisation_private FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_private_update();


--
-- Name: vw_organisation_waste_water_association tr_organisation_waste_water_association_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_waste_water_association_delete INSTEAD OF DELETE ON qgep_od.vw_organisation_waste_water_association FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_waste_water_association_delete();


--
-- Name: vw_organisation_waste_water_association tr_organisation_waste_water_association_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_waste_water_association_insert INSTEAD OF INSERT ON qgep_od.vw_organisation_waste_water_association FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_waste_water_association_insert();


--
-- Name: vw_organisation_waste_water_association tr_organisation_waste_water_association_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_waste_water_association_update INSTEAD OF UPDATE ON qgep_od.vw_organisation_waste_water_association FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_waste_water_association_update();


--
-- Name: vw_organisation_waste_water_treatment_plant tr_organisation_waste_water_treatment_plant_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_waste_water_treatment_plant_delete INSTEAD OF DELETE ON qgep_od.vw_organisation_waste_water_treatment_plant FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_waste_water_treatment_plant_delete();


--
-- Name: vw_organisation_waste_water_treatment_plant tr_organisation_waste_water_treatment_plant_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_waste_water_treatment_plant_insert INSTEAD OF INSERT ON qgep_od.vw_organisation_waste_water_treatment_plant FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_waste_water_treatment_plant_insert();


--
-- Name: vw_organisation_waste_water_treatment_plant tr_organisation_waste_water_treatment_plant_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_organisation_waste_water_treatment_plant_update INSTEAD OF UPDATE ON qgep_od.vw_organisation_waste_water_treatment_plant FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_organisation_waste_water_treatment_plant_update();


--
-- Name: vw_overflow_leapingweir tr_overflow_leapingweir_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_leapingweir_delete INSTEAD OF DELETE ON qgep_od.vw_overflow_leapingweir FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_leapingweir_delete();


--
-- Name: vw_overflow_leapingweir tr_overflow_leapingweir_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_leapingweir_insert INSTEAD OF INSERT ON qgep_od.vw_overflow_leapingweir FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_leapingweir_insert();


--
-- Name: vw_overflow_leapingweir tr_overflow_leapingweir_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_leapingweir_update INSTEAD OF UPDATE ON qgep_od.vw_overflow_leapingweir FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_leapingweir_update();


--
-- Name: vw_overflow_prank_weir tr_overflow_prank_weir_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_prank_weir_delete INSTEAD OF DELETE ON qgep_od.vw_overflow_prank_weir FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_prank_weir_delete();


--
-- Name: vw_overflow_prank_weir tr_overflow_prank_weir_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_prank_weir_insert INSTEAD OF INSERT ON qgep_od.vw_overflow_prank_weir FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_prank_weir_insert();


--
-- Name: vw_overflow_prank_weir tr_overflow_prank_weir_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_prank_weir_update INSTEAD OF UPDATE ON qgep_od.vw_overflow_prank_weir FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_prank_weir_update();


--
-- Name: vw_overflow_pump tr_overflow_pump_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_pump_delete INSTEAD OF DELETE ON qgep_od.vw_overflow_pump FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_pump_delete();


--
-- Name: vw_overflow_pump tr_overflow_pump_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_pump_insert INSTEAD OF INSERT ON qgep_od.vw_overflow_pump FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_pump_insert();


--
-- Name: vw_overflow_pump tr_overflow_pump_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_overflow_pump_update INSTEAD OF UPDATE ON qgep_od.vw_overflow_pump FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_overflow_pump_update();


--
-- Name: vw_organisation tr_vw_organisation_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_organisation_delete INSTEAD OF DELETE ON qgep_od.vw_organisation FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_organisation_delete();


--
-- Name: vw_organisation tr_vw_organisation_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_organisation_insert INSTEAD OF INSERT ON qgep_od.vw_organisation FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_organisation_insert();


--
-- Name: vw_organisation tr_vw_organisation_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_organisation_update INSTEAD OF UPDATE ON qgep_od.vw_organisation FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_organisation_update();


--
-- Name: vw_qgep_damage tr_vw_qgep_damage_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_damage_delete INSTEAD OF DELETE ON qgep_od.vw_qgep_damage FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_damage_delete();


--
-- Name: vw_qgep_damage tr_vw_qgep_damage_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_damage_insert INSTEAD OF INSERT ON qgep_od.vw_qgep_damage FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_damage_insert();


--
-- Name: vw_qgep_damage tr_vw_qgep_damage_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_damage_update INSTEAD OF UPDATE ON qgep_od.vw_qgep_damage FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_damage_update();


--
-- Name: vw_qgep_maintenance tr_vw_qgep_maintenance_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_maintenance_delete INSTEAD OF DELETE ON qgep_od.vw_qgep_maintenance FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_maintenance_delete();


--
-- Name: vw_qgep_maintenance tr_vw_qgep_maintenance_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_maintenance_insert INSTEAD OF INSERT ON qgep_od.vw_qgep_maintenance FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_maintenance_insert();


--
-- Name: vw_qgep_maintenance tr_vw_qgep_maintenance_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_maintenance_update INSTEAD OF UPDATE ON qgep_od.vw_qgep_maintenance FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_maintenance_update();


--
-- Name: vw_qgep_overflow tr_vw_qgep_overflow_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_overflow_delete INSTEAD OF DELETE ON qgep_od.vw_qgep_overflow FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_overflow_delete();


--
-- Name: vw_qgep_overflow tr_vw_qgep_overflow_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_overflow_insert INSTEAD OF INSERT ON qgep_od.vw_qgep_overflow FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_overflow_insert();


--
-- Name: vw_qgep_overflow tr_vw_qgep_overflow_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER tr_vw_qgep_overflow_update INSTEAD OF UPDATE ON qgep_od.vw_qgep_overflow FOR EACH ROW EXECUTE PROCEDURE qgep_od.ft_vw_qgep_overflow_update();


--
-- Name: access_aid update_last_modified_access_aid; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_access_aid BEFORE INSERT OR UPDATE ON qgep_od.access_aid FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: accident update_last_modified_accident; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_accident BEFORE INSERT OR UPDATE ON qgep_od.accident FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: administrative_office update_last_modified_administrative_office; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_administrative_office BEFORE INSERT OR UPDATE ON qgep_od.administrative_office FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.organisation');


--
-- Name: aquifier update_last_modified_aquifier; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_aquifier BEFORE INSERT OR UPDATE ON qgep_od.aquifier FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: backflow_prevention update_last_modified_backflow_prevention; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_backflow_prevention BEFORE INSERT OR UPDATE ON qgep_od.backflow_prevention FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: bathing_area update_last_modified_bathing_area; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_bathing_area BEFORE INSERT OR UPDATE ON qgep_od.bathing_area FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: benching update_last_modified_benching; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_benching BEFORE INSERT OR UPDATE ON qgep_od.benching FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: blocking_debris update_last_modified_blocking_debris; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_blocking_debris BEFORE INSERT OR UPDATE ON qgep_od.blocking_debris FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.water_control_structure');


--
-- Name: building update_last_modified_building; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_building BEFORE INSERT OR UPDATE ON qgep_od.building FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.connection_object');


--
-- Name: canton update_last_modified_canton; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_canton BEFORE INSERT OR UPDATE ON qgep_od.canton FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.organisation');


--
-- Name: catchment_area update_last_modified_catchment_area; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_catchment_area BEFORE INSERT OR UPDATE ON qgep_od.catchment_area FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: catchment_area_text update_last_modified_catchment_area_text; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_catchment_area_text BEFORE INSERT OR UPDATE ON qgep_od.catchment_area_text FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: channel update_last_modified_channel; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_channel BEFORE INSERT OR UPDATE ON qgep_od.channel FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_structure');


--
-- Name: chute update_last_modified_chute; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_chute BEFORE INSERT OR UPDATE ON qgep_od.chute FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.water_control_structure');


--
-- Name: connection_object update_last_modified_connection_object; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_connection_object BEFORE INSERT OR UPDATE ON qgep_od.connection_object FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: control_center update_last_modified_control_center; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_control_center BEFORE INSERT OR UPDATE ON qgep_od.control_center FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: cooperative update_last_modified_cooperative; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_cooperative BEFORE INSERT OR UPDATE ON qgep_od.cooperative FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.organisation');


--
-- Name: cover update_last_modified_cover; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_cover BEFORE INSERT OR UPDATE ON qgep_od.cover FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: dam update_last_modified_dam; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_dam BEFORE INSERT OR UPDATE ON qgep_od.dam FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.water_control_structure');


--
-- Name: damage update_last_modified_damage; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_damage BEFORE INSERT OR UPDATE ON qgep_od.damage FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: damage_channel update_last_modified_damage_channel; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_damage_channel BEFORE INSERT OR UPDATE ON qgep_od.damage_channel FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.damage');


--
-- Name: damage_manhole update_last_modified_damage_manhole; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_damage_manhole BEFORE INSERT OR UPDATE ON qgep_od.damage_manhole FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.damage');


--
-- Name: data_media update_last_modified_data_media; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_data_media BEFORE INSERT OR UPDATE ON qgep_od.data_media FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: discharge_point update_last_modified_discharge_point; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_discharge_point BEFORE INSERT OR UPDATE ON qgep_od.discharge_point FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_structure');


--
-- Name: drainage_system update_last_modified_drainage_system; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_drainage_system BEFORE INSERT OR UPDATE ON qgep_od.drainage_system FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.zone');


--
-- Name: dryweather_downspout update_last_modified_dryweather_downspout; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_dryweather_downspout BEFORE INSERT OR UPDATE ON qgep_od.dryweather_downspout FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: dryweather_flume update_last_modified_dryweather_flume; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_dryweather_flume BEFORE INSERT OR UPDATE ON qgep_od.dryweather_flume FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: electric_equipment update_last_modified_electric_equipment; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_electric_equipment BEFORE INSERT OR UPDATE ON qgep_od.electric_equipment FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: electromechanical_equipment update_last_modified_electromechanical_equipment; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_electromechanical_equipment BEFORE INSERT OR UPDATE ON qgep_od.electromechanical_equipment FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: examination update_last_modified_examination; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_examination BEFORE INSERT OR UPDATE ON qgep_od.examination FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.maintenance_event');


--
-- Name: file update_last_modified_file; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_file BEFORE INSERT OR UPDATE ON qgep_od.file FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: fish_pass update_last_modified_fish_pass; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_fish_pass BEFORE INSERT OR UPDATE ON qgep_od.fish_pass FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: ford update_last_modified_ford; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_ford BEFORE INSERT OR UPDATE ON qgep_od.ford FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.water_control_structure');


--
-- Name: fountain update_last_modified_fountain; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_fountain BEFORE INSERT OR UPDATE ON qgep_od.fountain FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.connection_object');


--
-- Name: ground_water_protection_perimeter update_last_modified_ground_water_protection_perimeter; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_ground_water_protection_perimeter BEFORE INSERT OR UPDATE ON qgep_od.ground_water_protection_perimeter FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.zone');


--
-- Name: groundwater_protection_zone update_last_modified_groundwater_protection_zone; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_groundwater_protection_zone BEFORE INSERT OR UPDATE ON qgep_od.groundwater_protection_zone FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.zone');


--
-- Name: hazard_source update_last_modified_hazard_source; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_hazard_source BEFORE INSERT OR UPDATE ON qgep_od.hazard_source FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: hq_relation update_last_modified_hq_relation; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_hq_relation BEFORE INSERT OR UPDATE ON qgep_od.hq_relation FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: hydr_geom_relation update_last_modified_hydr_geom_relation; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_hydr_geom_relation BEFORE INSERT OR UPDATE ON qgep_od.hydr_geom_relation FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: hydr_geometry update_last_modified_hydr_geometry; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_hydr_geometry BEFORE INSERT OR UPDATE ON qgep_od.hydr_geometry FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: hydraulic_char_data update_last_modified_hydraulic_char_data; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_hydraulic_char_data BEFORE INSERT OR UPDATE ON qgep_od.hydraulic_char_data FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: individual_surface update_last_modified_individual_surface; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_individual_surface BEFORE INSERT OR UPDATE ON qgep_od.individual_surface FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.connection_object');


--
-- Name: infiltration_installation update_last_modified_infiltration_installation; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_infiltration_installation BEFORE INSERT OR UPDATE ON qgep_od.infiltration_installation FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_structure');


--
-- Name: infiltration_zone update_last_modified_infiltration_zone; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_infiltration_zone BEFORE INSERT OR UPDATE ON qgep_od.infiltration_zone FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.zone');


--
-- Name: lake update_last_modified_lake; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_lake BEFORE INSERT OR UPDATE ON qgep_od.lake FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.surface_water_bodies');


--
-- Name: leapingweir update_last_modified_leapingweir; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_leapingweir BEFORE INSERT OR UPDATE ON qgep_od.leapingweir FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.overflow');


--
-- Name: lock update_last_modified_lock; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_lock BEFORE INSERT OR UPDATE ON qgep_od.lock FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.water_control_structure');


--
-- Name: maintenance_event update_last_modified_maintenance_event; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_maintenance_event BEFORE INSERT OR UPDATE ON qgep_od.maintenance_event FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: manhole update_last_modified_manhole; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_manhole BEFORE INSERT OR UPDATE ON qgep_od.manhole FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_structure');


--
-- Name: measurement_result update_last_modified_measurement_result; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_measurement_result BEFORE INSERT OR UPDATE ON qgep_od.measurement_result FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: measurement_series update_last_modified_measurement_series; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_measurement_series BEFORE INSERT OR UPDATE ON qgep_od.measurement_series FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: measuring_device update_last_modified_measuring_device; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_measuring_device BEFORE INSERT OR UPDATE ON qgep_od.measuring_device FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: measuring_point update_last_modified_measuring_point; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_measuring_point BEFORE INSERT OR UPDATE ON qgep_od.measuring_point FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: mechanical_pretreatment update_last_modified_mechanical_pretreatment; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_mechanical_pretreatment BEFORE INSERT OR UPDATE ON qgep_od.mechanical_pretreatment FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: municipality update_last_modified_municipality; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_municipality BEFORE INSERT OR UPDATE ON qgep_od.municipality FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.organisation');


--
-- Name: mutation update_last_modified_mutation; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_mutation BEFORE INSERT OR UPDATE ON qgep_od.mutation FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: organisation update_last_modified_organisation; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_organisation BEFORE INSERT OR UPDATE ON qgep_od.organisation FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: overflow update_last_modified_overflow; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_overflow BEFORE INSERT OR UPDATE ON qgep_od.overflow FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: overflow_char update_last_modified_overflow_char; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_overflow_char BEFORE INSERT OR UPDATE ON qgep_od.overflow_char FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: param_ca_general update_last_modified_param_ca_general; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_param_ca_general BEFORE INSERT OR UPDATE ON qgep_od.param_ca_general FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.surface_runoff_parameters');


--
-- Name: param_ca_mouse1 update_last_modified_param_ca_mouse1; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_param_ca_mouse1 BEFORE INSERT OR UPDATE ON qgep_od.param_ca_mouse1 FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.surface_runoff_parameters');


--
-- Name: passage update_last_modified_passage; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_passage BEFORE INSERT OR UPDATE ON qgep_od.passage FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.water_control_structure');


--
-- Name: pipe_profile update_last_modified_pipe_profile; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_pipe_profile BEFORE INSERT OR UPDATE ON qgep_od.pipe_profile FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: planning_zone update_last_modified_planning_zone; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_planning_zone BEFORE INSERT OR UPDATE ON qgep_od.planning_zone FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.zone');


--
-- Name: prank_weir update_last_modified_prank_weir; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_prank_weir BEFORE INSERT OR UPDATE ON qgep_od.prank_weir FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.overflow');


--
-- Name: private update_last_modified_private; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_private BEFORE INSERT OR UPDATE ON qgep_od.private FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.organisation');


--
-- Name: profile_geometry update_last_modified_profile_geometry; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_profile_geometry BEFORE INSERT OR UPDATE ON qgep_od.profile_geometry FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: pump update_last_modified_pump; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_pump BEFORE INSERT OR UPDATE ON qgep_od.pump FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.overflow');


--
-- Name: reach update_last_modified_reach; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_reach BEFORE INSERT OR UPDATE ON qgep_od.reach FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_networkelement');


--
-- Name: reach_point update_last_modified_reach_point; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_reach_point BEFORE INSERT OR UPDATE ON qgep_od.reach_point FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: reach_text update_last_modified_reach_text; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_reach_text BEFORE INSERT OR UPDATE ON qgep_od.reach_text FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: reservoir update_last_modified_reservoir; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_reservoir BEFORE INSERT OR UPDATE ON qgep_od.reservoir FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.connection_object');


--
-- Name: retention_body update_last_modified_retention_body; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_retention_body BEFORE INSERT OR UPDATE ON qgep_od.retention_body FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: river update_last_modified_river; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_river BEFORE INSERT OR UPDATE ON qgep_od.river FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.surface_water_bodies');


--
-- Name: river_bank update_last_modified_river_bank; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_river_bank BEFORE INSERT OR UPDATE ON qgep_od.river_bank FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: river_bed update_last_modified_river_bed; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_river_bed BEFORE INSERT OR UPDATE ON qgep_od.river_bed FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: rock_ramp update_last_modified_rock_ramp; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_rock_ramp BEFORE INSERT OR UPDATE ON qgep_od.rock_ramp FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.water_control_structure');


--
-- Name: sector_water_body update_last_modified_sector_water_body; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_sector_water_body BEFORE INSERT OR UPDATE ON qgep_od.sector_water_body FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: sludge_treatment update_last_modified_sludge_treatment; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_sludge_treatment BEFORE INSERT OR UPDATE ON qgep_od.sludge_treatment FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: solids_retention update_last_modified_solids_retention; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_solids_retention BEFORE INSERT OR UPDATE ON qgep_od.solids_retention FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: special_structure update_last_modified_special_structure; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_special_structure BEFORE INSERT OR UPDATE ON qgep_od.special_structure FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_structure');


--
-- Name: structure_part update_last_modified_structure_part; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_structure_part BEFORE INSERT OR UPDATE ON qgep_od.structure_part FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: substance update_last_modified_substance; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_substance BEFORE INSERT OR UPDATE ON qgep_od.substance FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: surface_runoff_parameters update_last_modified_surface_runoff_parameters; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_surface_runoff_parameters BEFORE INSERT OR UPDATE ON qgep_od.surface_runoff_parameters FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: surface_water_bodies update_last_modified_surface_water_bodies; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_surface_water_bodies BEFORE INSERT OR UPDATE ON qgep_od.surface_water_bodies FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: txt_symbol update_last_modified_symbol; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_symbol BEFORE INSERT OR UPDATE ON qgep_od.txt_symbol FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: tank_cleaning update_last_modified_tank_cleaning; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_tank_cleaning BEFORE INSERT OR UPDATE ON qgep_od.tank_cleaning FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: tank_emptying update_last_modified_tank_emptying; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_tank_emptying BEFORE INSERT OR UPDATE ON qgep_od.tank_emptying FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.structure_part');


--
-- Name: txt_text update_last_modified_text; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_text BEFORE INSERT OR UPDATE ON qgep_od.txt_text FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: throttle_shut_off_unit update_last_modified_throttle_shut_off_unit; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_throttle_shut_off_unit BEFORE INSERT OR UPDATE ON qgep_od.throttle_shut_off_unit FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: waste_water_association update_last_modified_waste_water_association; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_waste_water_association BEFORE INSERT OR UPDATE ON qgep_od.waste_water_association FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.organisation');


--
-- Name: waste_water_treatment update_last_modified_waste_water_treatment; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_waste_water_treatment BEFORE INSERT OR UPDATE ON qgep_od.waste_water_treatment FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: waste_water_treatment_plant update_last_modified_waste_water_treatment_plant; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_waste_water_treatment_plant BEFORE INSERT OR UPDATE ON qgep_od.waste_water_treatment_plant FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.organisation');


--
-- Name: wastewater_networkelement update_last_modified_wastewater_networkelement; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_wastewater_networkelement BEFORE INSERT OR UPDATE ON qgep_od.wastewater_networkelement FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: wastewater_node update_last_modified_wastewater_node; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_wastewater_node BEFORE INSERT OR UPDATE ON qgep_od.wastewater_node FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_networkelement');


--
-- Name: wastewater_structure update_last_modified_wastewater_structure; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_wastewater_structure BEFORE INSERT OR UPDATE ON qgep_od.wastewater_structure FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: wastewater_structure_symbol update_last_modified_wastewater_structure_symbol; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_wastewater_structure_symbol BEFORE INSERT OR UPDATE ON qgep_od.wastewater_structure_symbol FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: wastewater_structure_text update_last_modified_wastewater_structure_text; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_wastewater_structure_text BEFORE INSERT OR UPDATE ON qgep_od.wastewater_structure_text FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: water_body_protection_sector update_last_modified_water_body_protection_sector; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_water_body_protection_sector BEFORE INSERT OR UPDATE ON qgep_od.water_body_protection_sector FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.zone');


--
-- Name: water_catchment update_last_modified_water_catchment; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_water_catchment BEFORE INSERT OR UPDATE ON qgep_od.water_catchment FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: water_control_structure update_last_modified_water_control_structure; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_water_control_structure BEFORE INSERT OR UPDATE ON qgep_od.water_control_structure FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: water_course_segment update_last_modified_water_course_segment; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_water_course_segment BEFORE INSERT OR UPDATE ON qgep_od.water_course_segment FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: wwtp_energy_use update_last_modified_wwtp_energy_use; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_wwtp_energy_use BEFORE INSERT OR UPDATE ON qgep_od.wwtp_energy_use FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: wwtp_structure update_last_modified_wwtp_structure; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_wwtp_structure BEFORE INSERT OR UPDATE ON qgep_od.wwtp_structure FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified_parent('qgep_od.wastewater_structure');


--
-- Name: zone update_last_modified_zone; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER update_last_modified_zone BEFORE INSERT OR UPDATE ON qgep_od.zone FOR EACH ROW EXECUTE PROCEDURE qgep_sys.update_last_modified();


--
-- Name: vw_access_aid vw_access_aid_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_access_aid_on_insert INSTEAD OF INSERT ON qgep_od.vw_access_aid FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_access_aid_insert();


--
-- Name: vw_backflow_prevention vw_backflow_prevention_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_backflow_prevention_on_insert INSTEAD OF INSERT ON qgep_od.vw_backflow_prevention FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_backflow_prevention_insert();


--
-- Name: vw_benching vw_benching_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_benching_on_insert INSTEAD OF INSERT ON qgep_od.vw_benching FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_benching_insert();


--
-- Name: vw_channel vw_channel_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_channel_on_insert INSTEAD OF INSERT ON qgep_od.vw_channel FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_channel_insert();


--
-- Name: vw_cover vw_cover_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_cover_on_insert INSTEAD OF INSERT ON qgep_od.vw_cover FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_cover_insert();


--
-- Name: vw_discharge_point vw_discharge_point_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_discharge_point_on_insert INSTEAD OF INSERT ON qgep_od.vw_discharge_point FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_discharge_point_insert();


--
-- Name: vw_dryweather_downspout vw_dryweather_downspout_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_dryweather_downspout_on_insert INSTEAD OF INSERT ON qgep_od.vw_dryweather_downspout FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_dryweather_downspout_insert();


--
-- Name: vw_dryweather_flume vw_dryweather_flume_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_dryweather_flume_on_insert INSTEAD OF INSERT ON qgep_od.vw_dryweather_flume FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_dryweather_flume_insert();


--
-- Name: vw_manhole vw_manhole_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_manhole_on_insert INSTEAD OF INSERT ON qgep_od.vw_manhole FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_manhole_insert();


--
-- Name: vw_qgep_reach vw_qgep_reach_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_qgep_reach_on_insert INSTEAD OF INSERT ON qgep_od.vw_qgep_reach FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_qgep_reach_insert();


--
-- Name: vw_qgep_wastewater_structure vw_qgep_wastewater_structure_on_delete; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_qgep_wastewater_structure_on_delete INSTEAD OF DELETE ON qgep_od.vw_qgep_wastewater_structure FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_qgep_wastewater_structure_delete();


--
-- Name: vw_qgep_wastewater_structure vw_qgep_wastewater_structure_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_qgep_wastewater_structure_on_insert INSTEAD OF INSERT ON qgep_od.vw_qgep_wastewater_structure FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_qgep_wastewater_structure_insert();


--
-- Name: vw_qgep_wastewater_structure vw_qgep_wastewater_structure_on_update; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_qgep_wastewater_structure_on_update INSTEAD OF UPDATE ON qgep_od.vw_qgep_wastewater_structure FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_qgep_wastewater_structure_update();


--
-- Name: vw_reach vw_reach_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_reach_on_insert INSTEAD OF INSERT ON qgep_od.vw_reach FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_reach_insert();


--
-- Name: vw_special_structure vw_special_structure_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_special_structure_on_insert INSTEAD OF INSERT ON qgep_od.vw_special_structure FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_special_structure_insert();


--
-- Name: vw_wastewater_node vw_wastewater_node_on_insert; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER vw_wastewater_node_on_insert INSTEAD OF INSERT ON qgep_od.vw_wastewater_node FOR EACH ROW EXECUTE PROCEDURE qgep_od.vw_wastewater_node_insert();


--
-- Name: wastewater_networkelement ws_label_update_by_wastewater_networkelement; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER ws_label_update_by_wastewater_networkelement AFTER INSERT OR DELETE OR UPDATE ON qgep_od.wastewater_networkelement FOR EACH ROW EXECUTE PROCEDURE qgep_od.on_structure_part_change_networkelement();


--
-- Name: channel ws_symbology_update_by_channel; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER ws_symbology_update_by_channel AFTER INSERT OR DELETE OR UPDATE ON qgep_od.channel FOR EACH ROW EXECUTE PROCEDURE qgep_od.ws_symbology_update_by_channel();


--
-- Name: reach ws_symbology_update_by_reach; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER ws_symbology_update_by_reach AFTER INSERT OR DELETE OR UPDATE ON qgep_od.reach FOR EACH ROW EXECUTE PROCEDURE qgep_od.ws_symbology_update_by_reach();


--
-- Name: reach_point ws_symbology_update_by_reach_point; Type: TRIGGER; Schema: qgep_od; Owner: postgres
--

CREATE TRIGGER ws_symbology_update_by_reach_point AFTER UPDATE ON qgep_od.reach_point FOR EACH ROW EXECUTE PROCEDURE qgep_od.ws_symbology_update_by_reach_point();


--
-- Name: access_aid fkey_vl_access_aid_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.access_aid
    ADD CONSTRAINT fkey_vl_access_aid_kind FOREIGN KEY (kind) REFERENCES qgep_vl.access_aid_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: backflow_prevention fkey_vl_backflow_prevention_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.backflow_prevention
    ADD CONSTRAINT fkey_vl_backflow_prevention_kind FOREIGN KEY (kind) REFERENCES qgep_vl.backflow_prevention_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: benching fkey_vl_benching_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.benching
    ADD CONSTRAINT fkey_vl_benching_kind FOREIGN KEY (kind) REFERENCES qgep_vl.benching_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_direct_discharge_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_direct_discharge_current FOREIGN KEY (direct_discharge_current) REFERENCES qgep_vl.catchment_area_direct_discharge_current(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_direct_discharge_planned; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_direct_discharge_planned FOREIGN KEY (direct_discharge_planned) REFERENCES qgep_vl.catchment_area_direct_discharge_planned(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_drainage_system_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_drainage_system_current FOREIGN KEY (drainage_system_current) REFERENCES qgep_vl.catchment_area_drainage_system_current(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_drainage_system_planned; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_drainage_system_planned FOREIGN KEY (drainage_system_planned) REFERENCES qgep_vl.catchment_area_drainage_system_planned(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_infiltration_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_infiltration_current FOREIGN KEY (infiltration_current) REFERENCES qgep_vl.catchment_area_infiltration_current(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_infiltration_planned; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_infiltration_planned FOREIGN KEY (infiltration_planned) REFERENCES qgep_vl.catchment_area_infiltration_planned(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_retention_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_retention_current FOREIGN KEY (retention_current) REFERENCES qgep_vl.catchment_area_retention_current(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area fkey_vl_catchment_area_retention_planned; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT fkey_vl_catchment_area_retention_planned FOREIGN KEY (retention_planned) REFERENCES qgep_vl.catchment_area_retention_planned(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area_text fkey_vl_catchment_area_text_plantype; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area_text
    ADD CONSTRAINT fkey_vl_catchment_area_text_plantype FOREIGN KEY (plantype) REFERENCES qgep_vl.catchment_area_text_plantype(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area_text fkey_vl_catchment_area_text_texthali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area_text
    ADD CONSTRAINT fkey_vl_catchment_area_text_texthali FOREIGN KEY (texthali) REFERENCES qgep_vl.catchment_area_text_texthali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: catchment_area_text fkey_vl_catchment_area_text_textvali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area_text
    ADD CONSTRAINT fkey_vl_catchment_area_text_textvali FOREIGN KEY (textvali) REFERENCES qgep_vl.catchment_area_text_textvali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: channel fkey_vl_channel_bedding_encasement; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT fkey_vl_channel_bedding_encasement FOREIGN KEY (bedding_encasement) REFERENCES qgep_vl.channel_bedding_encasement(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: channel fkey_vl_channel_connection_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT fkey_vl_channel_connection_type FOREIGN KEY (connection_type) REFERENCES qgep_vl.channel_connection_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: channel fkey_vl_channel_function_hierarchic; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT fkey_vl_channel_function_hierarchic FOREIGN KEY (function_hierarchic) REFERENCES qgep_vl.channel_function_hierarchic(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: channel fkey_vl_channel_function_hydraulic; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT fkey_vl_channel_function_hydraulic FOREIGN KEY (function_hydraulic) REFERENCES qgep_vl.channel_function_hydraulic(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: channel fkey_vl_channel_usage_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT fkey_vl_channel_usage_current FOREIGN KEY (usage_current) REFERENCES qgep_vl.channel_usage_current(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: channel fkey_vl_channel_usage_planned; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT fkey_vl_channel_usage_planned FOREIGN KEY (usage_planned) REFERENCES qgep_vl.channel_usage_planned(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: chute fkey_vl_chute_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.chute
    ADD CONSTRAINT fkey_vl_chute_kind FOREIGN KEY (kind) REFERENCES qgep_vl.chute_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: chute fkey_vl_chute_material; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.chute
    ADD CONSTRAINT fkey_vl_chute_material FOREIGN KEY (material) REFERENCES qgep_vl.chute_material(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cover fkey_vl_cover_cover_shape; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT fkey_vl_cover_cover_shape FOREIGN KEY (cover_shape) REFERENCES qgep_vl.cover_cover_shape(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cover fkey_vl_cover_fastening; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT fkey_vl_cover_fastening FOREIGN KEY (fastening) REFERENCES qgep_vl.cover_fastening(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cover fkey_vl_cover_material; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT fkey_vl_cover_material FOREIGN KEY (material) REFERENCES qgep_vl.cover_material(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cover fkey_vl_cover_positional_accuracy; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT fkey_vl_cover_positional_accuracy FOREIGN KEY (positional_accuracy) REFERENCES qgep_vl.cover_positional_accuracy(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cover fkey_vl_cover_sludge_bucket; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT fkey_vl_cover_sludge_bucket FOREIGN KEY (sludge_bucket) REFERENCES qgep_vl.cover_sludge_bucket(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: cover fkey_vl_cover_venting; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT fkey_vl_cover_venting FOREIGN KEY (venting) REFERENCES qgep_vl.cover_venting(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: dam fkey_vl_dam_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dam
    ADD CONSTRAINT fkey_vl_dam_kind FOREIGN KEY (kind) REFERENCES qgep_vl.dam_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: damage_channel fkey_vl_damage_channel_channel_damage_code; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage_channel
    ADD CONSTRAINT fkey_vl_damage_channel_channel_damage_code FOREIGN KEY (channel_damage_code) REFERENCES qgep_vl.damage_channel_channel_damage_code(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: damage fkey_vl_damage_connection; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage
    ADD CONSTRAINT fkey_vl_damage_connection FOREIGN KEY (connection) REFERENCES qgep_vl.damage_connection(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: damage_manhole fkey_vl_damage_manhole_manhole_damage_code; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage_manhole
    ADD CONSTRAINT fkey_vl_damage_manhole_manhole_damage_code FOREIGN KEY (manhole_damage_code) REFERENCES qgep_vl.damage_manhole_manhole_damage_code(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: damage_manhole fkey_vl_damage_manhole_manhole_shaft_area; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage_manhole
    ADD CONSTRAINT fkey_vl_damage_manhole_manhole_shaft_area FOREIGN KEY (manhole_shaft_area) REFERENCES qgep_vl.damage_manhole_manhole_shaft_area(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: damage fkey_vl_damage_single_damage_class; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage
    ADD CONSTRAINT fkey_vl_damage_single_damage_class FOREIGN KEY (single_damage_class) REFERENCES qgep_vl.damage_single_damage_class(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: data_media fkey_vl_data_media_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.data_media
    ADD CONSTRAINT fkey_vl_data_media_kind FOREIGN KEY (kind) REFERENCES qgep_vl.data_media_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: discharge_point fkey_vl_discharge_point_relevance; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.discharge_point
    ADD CONSTRAINT fkey_vl_discharge_point_relevance FOREIGN KEY (relevance) REFERENCES qgep_vl.discharge_point_relevance(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: drainage_system fkey_vl_drainage_system_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.drainage_system
    ADD CONSTRAINT fkey_vl_drainage_system_kind FOREIGN KEY (kind) REFERENCES qgep_vl.drainage_system_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: dryweather_flume fkey_vl_dryweather_flume_material; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dryweather_flume
    ADD CONSTRAINT fkey_vl_dryweather_flume_material FOREIGN KEY (material) REFERENCES qgep_vl.dryweather_flume_material(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: electric_equipment fkey_vl_electric_equipment_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.electric_equipment
    ADD CONSTRAINT fkey_vl_electric_equipment_kind FOREIGN KEY (kind) REFERENCES qgep_vl.electric_equipment_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: electromechanical_equipment fkey_vl_electromechanical_equipment_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.electromechanical_equipment
    ADD CONSTRAINT fkey_vl_electromechanical_equipment_kind FOREIGN KEY (kind) REFERENCES qgep_vl.electromechanical_equipment_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: examination fkey_vl_examination_recording_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.examination
    ADD CONSTRAINT fkey_vl_examination_recording_type FOREIGN KEY (recording_type) REFERENCES qgep_vl.examination_recording_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: examination fkey_vl_examination_weather; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.examination
    ADD CONSTRAINT fkey_vl_examination_weather FOREIGN KEY (weather) REFERENCES qgep_vl.examination_weather(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: file fkey_vl_file_class; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.file
    ADD CONSTRAINT fkey_vl_file_class FOREIGN KEY (class) REFERENCES qgep_vl.file_class(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: file fkey_vl_file_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.file
    ADD CONSTRAINT fkey_vl_file_kind FOREIGN KEY (kind) REFERENCES qgep_vl.file_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: groundwater_protection_zone fkey_vl_groundwater_protection_zone_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.groundwater_protection_zone
    ADD CONSTRAINT fkey_vl_groundwater_protection_zone_kind FOREIGN KEY (kind) REFERENCES qgep_vl.groundwater_protection_zone_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: hydraulic_char_data fkey_vl_hydraulic_char_data_is_overflowing; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT fkey_vl_hydraulic_char_data_is_overflowing FOREIGN KEY (is_overflowing) REFERENCES qgep_vl.hydraulic_char_data_is_overflowing(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: hydraulic_char_data fkey_vl_hydraulic_char_data_main_weir_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT fkey_vl_hydraulic_char_data_main_weir_kind FOREIGN KEY (main_weir_kind) REFERENCES qgep_vl.hydraulic_char_data_main_weir_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: hydraulic_char_data fkey_vl_hydraulic_char_data_pump_characteristics; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT fkey_vl_hydraulic_char_data_pump_characteristics FOREIGN KEY (pump_characteristics) REFERENCES qgep_vl.hydraulic_char_data_pump_characteristics(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: hydraulic_char_data fkey_vl_hydraulic_char_data_pump_usage_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT fkey_vl_hydraulic_char_data_pump_usage_current FOREIGN KEY (pump_usage_current) REFERENCES qgep_vl.hydraulic_char_data_pump_usage_current(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: hydraulic_char_data fkey_vl_hydraulic_char_data_status; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT fkey_vl_hydraulic_char_data_status FOREIGN KEY (status) REFERENCES qgep_vl.hydraulic_char_data_status(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: individual_surface fkey_vl_individual_surface_function; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.individual_surface
    ADD CONSTRAINT fkey_vl_individual_surface_function FOREIGN KEY (function) REFERENCES qgep_vl.individual_surface_function(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: individual_surface fkey_vl_individual_surface_pavement; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.individual_surface
    ADD CONSTRAINT fkey_vl_individual_surface_pavement FOREIGN KEY (pavement) REFERENCES qgep_vl.individual_surface_pavement(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_installation fkey_vl_infiltration_installation_defects; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT fkey_vl_infiltration_installation_defects FOREIGN KEY (defects) REFERENCES qgep_vl.infiltration_installation_defects(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_installation fkey_vl_infiltration_installation_emergency_spillway; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT fkey_vl_infiltration_installation_emergency_spillway FOREIGN KEY (emergency_spillway) REFERENCES qgep_vl.infiltration_installation_emergency_spillway(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_installation fkey_vl_infiltration_installation_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT fkey_vl_infiltration_installation_kind FOREIGN KEY (kind) REFERENCES qgep_vl.infiltration_installation_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_installation fkey_vl_infiltration_installation_labeling; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT fkey_vl_infiltration_installation_labeling FOREIGN KEY (labeling) REFERENCES qgep_vl.infiltration_installation_labeling(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_installation fkey_vl_infiltration_installation_seepage_utilization; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT fkey_vl_infiltration_installation_seepage_utilization FOREIGN KEY (seepage_utilization) REFERENCES qgep_vl.infiltration_installation_seepage_utilization(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_installation fkey_vl_infiltration_installation_vehicle_access; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT fkey_vl_infiltration_installation_vehicle_access FOREIGN KEY (vehicle_access) REFERENCES qgep_vl.infiltration_installation_vehicle_access(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_installation fkey_vl_infiltration_installation_watertightness; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT fkey_vl_infiltration_installation_watertightness FOREIGN KEY (watertightness) REFERENCES qgep_vl.infiltration_installation_watertightness(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: infiltration_zone fkey_vl_infiltration_zone_infiltration_capacity; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_zone
    ADD CONSTRAINT fkey_vl_infiltration_zone_infiltration_capacity FOREIGN KEY (infiltration_capacity) REFERENCES qgep_vl.infiltration_zone_infiltration_capacity(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: leapingweir fkey_vl_leapingweir_opening_shape; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.leapingweir
    ADD CONSTRAINT fkey_vl_leapingweir_opening_shape FOREIGN KEY (opening_shape) REFERENCES qgep_vl.leapingweir_opening_shape(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: maintenance_event fkey_vl_maintenance_event_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.maintenance_event
    ADD CONSTRAINT fkey_vl_maintenance_event_kind FOREIGN KEY (kind) REFERENCES qgep_vl.maintenance_event_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: maintenance_event fkey_vl_maintenance_event_status; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.maintenance_event
    ADD CONSTRAINT fkey_vl_maintenance_event_status FOREIGN KEY (status) REFERENCES qgep_vl.maintenance_event_status(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: manhole fkey_vl_manhole_function; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.manhole
    ADD CONSTRAINT fkey_vl_manhole_function FOREIGN KEY (function) REFERENCES qgep_vl.manhole_function(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: manhole fkey_vl_manhole_material; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.manhole
    ADD CONSTRAINT fkey_vl_manhole_material FOREIGN KEY (material) REFERENCES qgep_vl.manhole_material(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: manhole fkey_vl_manhole_surface_inflow; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.manhole
    ADD CONSTRAINT fkey_vl_manhole_surface_inflow FOREIGN KEY (surface_inflow) REFERENCES qgep_vl.manhole_surface_inflow(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: measurement_result fkey_vl_measurement_result_measurement_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_result
    ADD CONSTRAINT fkey_vl_measurement_result_measurement_type FOREIGN KEY (measurement_type) REFERENCES qgep_vl.measurement_result_measurement_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: measurement_series fkey_vl_measurement_series_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_series
    ADD CONSTRAINT fkey_vl_measurement_series_kind FOREIGN KEY (kind) REFERENCES qgep_vl.measurement_series_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: measuring_device fkey_vl_measuring_device_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_device
    ADD CONSTRAINT fkey_vl_measuring_device_kind FOREIGN KEY (kind) REFERENCES qgep_vl.measuring_device_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: measuring_point fkey_vl_measuring_point_damming_device; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT fkey_vl_measuring_point_damming_device FOREIGN KEY (damming_device) REFERENCES qgep_vl.measuring_point_damming_device(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: measuring_point fkey_vl_measuring_point_purpose; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT fkey_vl_measuring_point_purpose FOREIGN KEY (purpose) REFERENCES qgep_vl.measuring_point_purpose(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: mechanical_pretreatment fkey_vl_mechanical_pretreatment_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mechanical_pretreatment
    ADD CONSTRAINT fkey_vl_mechanical_pretreatment_kind FOREIGN KEY (kind) REFERENCES qgep_vl.mechanical_pretreatment_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: mutation fkey_vl_mutation_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mutation
    ADD CONSTRAINT fkey_vl_mutation_kind FOREIGN KEY (kind) REFERENCES qgep_vl.mutation_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: overflow fkey_vl_overflow_actuation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT fkey_vl_overflow_actuation FOREIGN KEY (actuation) REFERENCES qgep_vl.overflow_actuation(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: overflow fkey_vl_overflow_adjustability; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT fkey_vl_overflow_adjustability FOREIGN KEY (adjustability) REFERENCES qgep_vl.overflow_adjustability(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: overflow_char fkey_vl_overflow_char_kind_overflow_characteristic; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow_char
    ADD CONSTRAINT fkey_vl_overflow_char_kind_overflow_characteristic FOREIGN KEY (kind_overflow_characteristic) REFERENCES qgep_vl.overflow_char_kind_overflow_characteristic(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: overflow_char fkey_vl_overflow_char_overflow_characteristic_digital; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow_char
    ADD CONSTRAINT fkey_vl_overflow_char_overflow_characteristic_digital FOREIGN KEY (overflow_characteristic_digital) REFERENCES qgep_vl.overflow_char_overflow_characteristic_digital(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: overflow fkey_vl_overflow_control; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT fkey_vl_overflow_control FOREIGN KEY (control) REFERENCES qgep_vl.overflow_control(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: overflow fkey_vl_overflow_function; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT fkey_vl_overflow_function FOREIGN KEY (function) REFERENCES qgep_vl.overflow_function(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: overflow fkey_vl_overflow_signal_transmission; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT fkey_vl_overflow_signal_transmission FOREIGN KEY (signal_transmission) REFERENCES qgep_vl.overflow_signal_transmission(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: pipe_profile fkey_vl_pipe_profile_profile_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pipe_profile
    ADD CONSTRAINT fkey_vl_pipe_profile_profile_type FOREIGN KEY (profile_type) REFERENCES qgep_vl.pipe_profile_profile_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: planning_zone fkey_vl_planning_zone_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.planning_zone
    ADD CONSTRAINT fkey_vl_planning_zone_kind FOREIGN KEY (kind) REFERENCES qgep_vl.planning_zone_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: prank_weir fkey_vl_prank_weir_weir_edge; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.prank_weir
    ADD CONSTRAINT fkey_vl_prank_weir_weir_edge FOREIGN KEY (weir_edge) REFERENCES qgep_vl.prank_weir_weir_edge(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: prank_weir fkey_vl_prank_weir_weir_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.prank_weir
    ADD CONSTRAINT fkey_vl_prank_weir_weir_kind FOREIGN KEY (weir_kind) REFERENCES qgep_vl.prank_weir_weir_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: pump fkey_vl_pump_contruction_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pump
    ADD CONSTRAINT fkey_vl_pump_contruction_type FOREIGN KEY (contruction_type) REFERENCES qgep_vl.pump_contruction_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: pump fkey_vl_pump_placement_of_actuation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pump
    ADD CONSTRAINT fkey_vl_pump_placement_of_actuation FOREIGN KEY (placement_of_actuation) REFERENCES qgep_vl.pump_placement_of_actuation(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: pump fkey_vl_pump_placement_of_pump; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pump
    ADD CONSTRAINT fkey_vl_pump_placement_of_pump FOREIGN KEY (placement_of_pump) REFERENCES qgep_vl.pump_placement_of_pump(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: pump fkey_vl_pump_usage_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pump
    ADD CONSTRAINT fkey_vl_pump_usage_current FOREIGN KEY (usage_current) REFERENCES qgep_vl.pump_usage_current(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach fkey_vl_reach_elevation_determination; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT fkey_vl_reach_elevation_determination FOREIGN KEY (elevation_determination) REFERENCES qgep_vl.reach_elevation_determination(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach fkey_vl_reach_horizontal_positioning; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT fkey_vl_reach_horizontal_positioning FOREIGN KEY (horizontal_positioning) REFERENCES qgep_vl.reach_horizontal_positioning(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach fkey_vl_reach_inside_coating; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT fkey_vl_reach_inside_coating FOREIGN KEY (inside_coating) REFERENCES qgep_vl.reach_inside_coating(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach fkey_vl_reach_material; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT fkey_vl_reach_material FOREIGN KEY (material) REFERENCES qgep_vl.reach_material(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach_point fkey_vl_reach_point_elevation_accuracy; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_point
    ADD CONSTRAINT fkey_vl_reach_point_elevation_accuracy FOREIGN KEY (elevation_accuracy) REFERENCES qgep_vl.reach_point_elevation_accuracy(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach_point fkey_vl_reach_point_outlet_shape; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_point
    ADD CONSTRAINT fkey_vl_reach_point_outlet_shape FOREIGN KEY (outlet_shape) REFERENCES qgep_vl.reach_point_outlet_shape(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach fkey_vl_reach_reliner_material; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT fkey_vl_reach_reliner_material FOREIGN KEY (reliner_material) REFERENCES qgep_vl.reach_reliner_material(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach fkey_vl_reach_relining_construction; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT fkey_vl_reach_relining_construction FOREIGN KEY (relining_construction) REFERENCES qgep_vl.reach_relining_construction(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach fkey_vl_reach_relining_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT fkey_vl_reach_relining_kind FOREIGN KEY (relining_kind) REFERENCES qgep_vl.reach_relining_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach_text fkey_vl_reach_text_plantype; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_text
    ADD CONSTRAINT fkey_vl_reach_text_plantype FOREIGN KEY (plantype) REFERENCES qgep_vl.reach_text_plantype(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach_text fkey_vl_reach_text_texthali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_text
    ADD CONSTRAINT fkey_vl_reach_text_texthali FOREIGN KEY (texthali) REFERENCES qgep_vl.reach_text_texthali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: reach_text fkey_vl_reach_text_textvali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_text
    ADD CONSTRAINT fkey_vl_reach_text_textvali FOREIGN KEY (textvali) REFERENCES qgep_vl.reach_text_textvali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: retention_body fkey_vl_retention_body_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.retention_body
    ADD CONSTRAINT fkey_vl_retention_body_kind FOREIGN KEY (kind) REFERENCES qgep_vl.retention_body_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bank fkey_vl_river_bank_control_grade_of_river; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT fkey_vl_river_bank_control_grade_of_river FOREIGN KEY (control_grade_of_river) REFERENCES qgep_vl.river_bank_control_grade_of_river(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bank fkey_vl_river_bank_river_control_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT fkey_vl_river_bank_river_control_type FOREIGN KEY (river_control_type) REFERENCES qgep_vl.river_bank_river_control_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bank fkey_vl_river_bank_shores; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT fkey_vl_river_bank_shores FOREIGN KEY (shores) REFERENCES qgep_vl.river_bank_shores(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bank fkey_vl_river_bank_side; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT fkey_vl_river_bank_side FOREIGN KEY (side) REFERENCES qgep_vl.river_bank_side(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bank fkey_vl_river_bank_utilisation_of_shore_surroundings; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT fkey_vl_river_bank_utilisation_of_shore_surroundings FOREIGN KEY (utilisation_of_shore_surroundings) REFERENCES qgep_vl.river_bank_utilisation_of_shore_surroundings(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bank fkey_vl_river_bank_vegetation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT fkey_vl_river_bank_vegetation FOREIGN KEY (vegetation) REFERENCES qgep_vl.river_bank_vegetation(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bed fkey_vl_river_bed_control_grade_of_river; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bed
    ADD CONSTRAINT fkey_vl_river_bed_control_grade_of_river FOREIGN KEY (control_grade_of_river) REFERENCES qgep_vl.river_bed_control_grade_of_river(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bed fkey_vl_river_bed_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bed
    ADD CONSTRAINT fkey_vl_river_bed_kind FOREIGN KEY (kind) REFERENCES qgep_vl.river_bed_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river_bed fkey_vl_river_bed_river_control_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bed
    ADD CONSTRAINT fkey_vl_river_bed_river_control_type FOREIGN KEY (river_control_type) REFERENCES qgep_vl.river_bed_river_control_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: river fkey_vl_river_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river
    ADD CONSTRAINT fkey_vl_river_kind FOREIGN KEY (kind) REFERENCES qgep_vl.river_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: rock_ramp fkey_vl_rock_ramp_stabilisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.rock_ramp
    ADD CONSTRAINT fkey_vl_rock_ramp_stabilisation FOREIGN KEY (stabilisation) REFERENCES qgep_vl.rock_ramp_stabilisation(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: sector_water_body fkey_vl_sector_water_body_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sector_water_body
    ADD CONSTRAINT fkey_vl_sector_water_body_kind FOREIGN KEY (kind) REFERENCES qgep_vl.sector_water_body_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: sludge_treatment fkey_vl_sludge_treatment_stabilisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sludge_treatment
    ADD CONSTRAINT fkey_vl_sludge_treatment_stabilisation FOREIGN KEY (stabilisation) REFERENCES qgep_vl.sludge_treatment_stabilisation(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: solids_retention fkey_vl_solids_retention_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.solids_retention
    ADD CONSTRAINT fkey_vl_solids_retention_type FOREIGN KEY (type) REFERENCES qgep_vl.solids_retention_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: special_structure fkey_vl_special_structure_bypass; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.special_structure
    ADD CONSTRAINT fkey_vl_special_structure_bypass FOREIGN KEY (bypass) REFERENCES qgep_vl.special_structure_bypass(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: special_structure fkey_vl_special_structure_emergency_spillway; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.special_structure
    ADD CONSTRAINT fkey_vl_special_structure_emergency_spillway FOREIGN KEY (emergency_spillway) REFERENCES qgep_vl.special_structure_emergency_spillway(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: special_structure fkey_vl_special_structure_function; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.special_structure
    ADD CONSTRAINT fkey_vl_special_structure_function FOREIGN KEY (function) REFERENCES qgep_vl.special_structure_function(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: special_structure fkey_vl_special_structure_stormwater_tank_arrangement; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.special_structure
    ADD CONSTRAINT fkey_vl_special_structure_stormwater_tank_arrangement FOREIGN KEY (stormwater_tank_arrangement) REFERENCES qgep_vl.special_structure_stormwater_tank_arrangement(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: structure_part fkey_vl_structure_part_renovation_demand; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.structure_part
    ADD CONSTRAINT fkey_vl_structure_part_renovation_demand FOREIGN KEY (renovation_demand) REFERENCES qgep_vl.structure_part_renovation_demand(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: txt_symbol fkey_vl_symbol_plantype; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_symbol
    ADD CONSTRAINT fkey_vl_symbol_plantype FOREIGN KEY (plantype) REFERENCES qgep_vl.symbol_plantype(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: tank_cleaning fkey_vl_tank_cleaning_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_cleaning
    ADD CONSTRAINT fkey_vl_tank_cleaning_type FOREIGN KEY (type) REFERENCES qgep_vl.tank_cleaning_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: tank_emptying fkey_vl_tank_emptying_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_emptying
    ADD CONSTRAINT fkey_vl_tank_emptying_type FOREIGN KEY (type) REFERENCES qgep_vl.tank_emptying_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: txt_text fkey_vl_text_plantype; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_text
    ADD CONSTRAINT fkey_vl_text_plantype FOREIGN KEY (plantype) REFERENCES qgep_vl.text_plantype(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: txt_text fkey_vl_text_texthali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_text
    ADD CONSTRAINT fkey_vl_text_texthali FOREIGN KEY (texthali) REFERENCES qgep_vl.text_texthali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: txt_text fkey_vl_text_textvali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_text
    ADD CONSTRAINT fkey_vl_text_textvali FOREIGN KEY (textvali) REFERENCES qgep_vl.text_textvali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: throttle_shut_off_unit fkey_vl_throttle_shut_off_unit_actuation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT fkey_vl_throttle_shut_off_unit_actuation FOREIGN KEY (actuation) REFERENCES qgep_vl.throttle_shut_off_unit_actuation(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: throttle_shut_off_unit fkey_vl_throttle_shut_off_unit_adjustability; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT fkey_vl_throttle_shut_off_unit_adjustability FOREIGN KEY (adjustability) REFERENCES qgep_vl.throttle_shut_off_unit_adjustability(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: throttle_shut_off_unit fkey_vl_throttle_shut_off_unit_control; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT fkey_vl_throttle_shut_off_unit_control FOREIGN KEY (control) REFERENCES qgep_vl.throttle_shut_off_unit_control(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: throttle_shut_off_unit fkey_vl_throttle_shut_off_unit_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT fkey_vl_throttle_shut_off_unit_kind FOREIGN KEY (kind) REFERENCES qgep_vl.throttle_shut_off_unit_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: throttle_shut_off_unit fkey_vl_throttle_shut_off_unit_signal_transmission; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT fkey_vl_throttle_shut_off_unit_signal_transmission FOREIGN KEY (signal_transmission) REFERENCES qgep_vl.throttle_shut_off_unit_signal_transmission(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: waste_water_treatment fkey_vl_waste_water_treatment_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_treatment
    ADD CONSTRAINT fkey_vl_waste_water_treatment_kind FOREIGN KEY (kind) REFERENCES qgep_vl.waste_water_treatment_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure fkey_vl_wastewater_structure_accessibility; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT fkey_vl_wastewater_structure_accessibility FOREIGN KEY (accessibility) REFERENCES qgep_vl.wastewater_structure_accessibility(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure fkey_vl_wastewater_structure_financing; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT fkey_vl_wastewater_structure_financing FOREIGN KEY (financing) REFERENCES qgep_vl.wastewater_structure_financing(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure fkey_vl_wastewater_structure_renovation_necessity; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT fkey_vl_wastewater_structure_renovation_necessity FOREIGN KEY (renovation_necessity) REFERENCES qgep_vl.wastewater_structure_renovation_necessity(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure fkey_vl_wastewater_structure_rv_construction_type; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT fkey_vl_wastewater_structure_rv_construction_type FOREIGN KEY (rv_construction_type) REFERENCES qgep_vl.wastewater_structure_rv_construction_type(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure fkey_vl_wastewater_structure_status; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT fkey_vl_wastewater_structure_status FOREIGN KEY (status) REFERENCES qgep_vl.wastewater_structure_status(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure fkey_vl_wastewater_structure_structure_condition; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT fkey_vl_wastewater_structure_structure_condition FOREIGN KEY (structure_condition) REFERENCES qgep_vl.wastewater_structure_structure_condition(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure_symbol fkey_vl_wastewater_structure_symbol_plantype; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_symbol
    ADD CONSTRAINT fkey_vl_wastewater_structure_symbol_plantype FOREIGN KEY (plantype) REFERENCES qgep_vl.wastewater_structure_symbol_plantype(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure_text fkey_vl_wastewater_structure_text_plantype; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_text
    ADD CONSTRAINT fkey_vl_wastewater_structure_text_plantype FOREIGN KEY (plantype) REFERENCES qgep_vl.wastewater_structure_text_plantype(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure_text fkey_vl_wastewater_structure_text_texthali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_text
    ADD CONSTRAINT fkey_vl_wastewater_structure_text_texthali FOREIGN KEY (texthali) REFERENCES qgep_vl.wastewater_structure_text_texthali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wastewater_structure_text fkey_vl_wastewater_structure_text_textvali; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_text
    ADD CONSTRAINT fkey_vl_wastewater_structure_text_textvali FOREIGN KEY (textvali) REFERENCES qgep_vl.wastewater_structure_text_textvali(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_body_protection_sector fkey_vl_water_body_protection_sector_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_body_protection_sector
    ADD CONSTRAINT fkey_vl_water_body_protection_sector_kind FOREIGN KEY (kind) REFERENCES qgep_vl.water_body_protection_sector_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_catchment fkey_vl_water_catchment_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_catchment
    ADD CONSTRAINT fkey_vl_water_catchment_kind FOREIGN KEY (kind) REFERENCES qgep_vl.water_catchment_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_algae_growth; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_algae_growth FOREIGN KEY (algae_growth) REFERENCES qgep_vl.water_course_segment_algae_growth(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_altitudinal_zone; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_altitudinal_zone FOREIGN KEY (altitudinal_zone) REFERENCES qgep_vl.water_course_segment_altitudinal_zone(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_dead_wood; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_dead_wood FOREIGN KEY (dead_wood) REFERENCES qgep_vl.water_course_segment_dead_wood(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_depth_variability; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_depth_variability FOREIGN KEY (depth_variability) REFERENCES qgep_vl.water_course_segment_depth_variability(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_discharge_regime; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_discharge_regime FOREIGN KEY (discharge_regime) REFERENCES qgep_vl.water_course_segment_discharge_regime(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_ecom_classification; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_ecom_classification FOREIGN KEY (ecom_classification) REFERENCES qgep_vl.water_course_segment_ecom_classification(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_kind FOREIGN KEY (kind) REFERENCES qgep_vl.water_course_segment_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_length_profile; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_length_profile FOREIGN KEY (length_profile) REFERENCES qgep_vl.water_course_segment_length_profile(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_macrophyte_coverage; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_macrophyte_coverage FOREIGN KEY (macrophyte_coverage) REFERENCES qgep_vl.water_course_segment_macrophyte_coverage(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_section_morphology; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_section_morphology FOREIGN KEY (section_morphology) REFERENCES qgep_vl.water_course_segment_section_morphology(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_slope; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_slope FOREIGN KEY (slope) REFERENCES qgep_vl.water_course_segment_slope(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_utilisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_utilisation FOREIGN KEY (utilisation) REFERENCES qgep_vl.water_course_segment_utilisation(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_water_hardness; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_water_hardness FOREIGN KEY (water_hardness) REFERENCES qgep_vl.water_course_segment_water_hardness(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: water_course_segment fkey_vl_water_course_segment_width_variability; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT fkey_vl_water_course_segment_width_variability FOREIGN KEY (width_variability) REFERENCES qgep_vl.water_course_segment_width_variability(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: wwtp_structure fkey_vl_wwtp_structure_kind; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wwtp_structure
    ADD CONSTRAINT fkey_vl_wwtp_structure_kind FOREIGN KEY (kind) REFERENCES qgep_vl.wwtp_structure_kind(code) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: access_aid oorel_od_access_aid_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.access_aid
    ADD CONSTRAINT oorel_od_access_aid_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: administrative_office oorel_od_administrative_office_organisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.administrative_office
    ADD CONSTRAINT oorel_od_administrative_office_organisation FOREIGN KEY (obj_id) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: backflow_prevention oorel_od_backflow_prevention_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.backflow_prevention
    ADD CONSTRAINT oorel_od_backflow_prevention_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: benching oorel_od_benching_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.benching
    ADD CONSTRAINT oorel_od_benching_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: blocking_debris oorel_od_blocking_debris_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.blocking_debris
    ADD CONSTRAINT oorel_od_blocking_debris_water_control_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: building oorel_od_building_connection_object; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.building
    ADD CONSTRAINT oorel_od_building_connection_object FOREIGN KEY (obj_id) REFERENCES qgep_od.connection_object(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: canton oorel_od_canton_organisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.canton
    ADD CONSTRAINT oorel_od_canton_organisation FOREIGN KEY (obj_id) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: channel oorel_od_channel_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.channel
    ADD CONSTRAINT oorel_od_channel_wastewater_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chute oorel_od_chute_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.chute
    ADD CONSTRAINT oorel_od_chute_water_control_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cooperative oorel_od_cooperative_organisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cooperative
    ADD CONSTRAINT oorel_od_cooperative_organisation FOREIGN KEY (obj_id) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cover oorel_od_cover_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.cover
    ADD CONSTRAINT oorel_od_cover_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dam oorel_od_dam_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dam
    ADD CONSTRAINT oorel_od_dam_water_control_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: damage_channel oorel_od_damage_channel_damage; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage_channel
    ADD CONSTRAINT oorel_od_damage_channel_damage FOREIGN KEY (obj_id) REFERENCES qgep_od.damage(obj_id) ON DELETE CASCADE;


--
-- Name: damage_manhole oorel_od_damage_manhole_damage; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage_manhole
    ADD CONSTRAINT oorel_od_damage_manhole_damage FOREIGN KEY (obj_id) REFERENCES qgep_od.damage(obj_id) ON DELETE CASCADE;


--
-- Name: discharge_point oorel_od_discharge_point_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.discharge_point
    ADD CONSTRAINT oorel_od_discharge_point_wastewater_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: drainage_system oorel_od_drainage_system_zone; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.drainage_system
    ADD CONSTRAINT oorel_od_drainage_system_zone FOREIGN KEY (obj_id) REFERENCES qgep_od.zone(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dryweather_downspout oorel_od_dryweather_downspout_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dryweather_downspout
    ADD CONSTRAINT oorel_od_dryweather_downspout_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dryweather_flume oorel_od_dryweather_flume_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.dryweather_flume
    ADD CONSTRAINT oorel_od_dryweather_flume_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: electric_equipment oorel_od_electric_equipment_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.electric_equipment
    ADD CONSTRAINT oorel_od_electric_equipment_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: electromechanical_equipment oorel_od_electromechanical_equipment_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.electromechanical_equipment
    ADD CONSTRAINT oorel_od_electromechanical_equipment_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: examination oorel_od_examination_maintenance_event; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.examination
    ADD CONSTRAINT oorel_od_examination_maintenance_event FOREIGN KEY (obj_id) REFERENCES qgep_od.maintenance_event(obj_id) ON DELETE CASCADE;


--
-- Name: ford oorel_od_ford_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.ford
    ADD CONSTRAINT oorel_od_ford_water_control_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fountain oorel_od_fountain_connection_object; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.fountain
    ADD CONSTRAINT oorel_od_fountain_connection_object FOREIGN KEY (obj_id) REFERENCES qgep_od.connection_object(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ground_water_protection_perimeter oorel_od_ground_water_protection_perimeter_zone; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.ground_water_protection_perimeter
    ADD CONSTRAINT oorel_od_ground_water_protection_perimeter_zone FOREIGN KEY (obj_id) REFERENCES qgep_od.zone(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: groundwater_protection_zone oorel_od_groundwater_protection_zone_zone; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.groundwater_protection_zone
    ADD CONSTRAINT oorel_od_groundwater_protection_zone_zone FOREIGN KEY (obj_id) REFERENCES qgep_od.zone(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: individual_surface oorel_od_individual_surface_connection_object; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.individual_surface
    ADD CONSTRAINT oorel_od_individual_surface_connection_object FOREIGN KEY (obj_id) REFERENCES qgep_od.connection_object(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: infiltration_installation oorel_od_infiltration_installation_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT oorel_od_infiltration_installation_wastewater_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: infiltration_zone oorel_od_infiltration_zone_zone; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_zone
    ADD CONSTRAINT oorel_od_infiltration_zone_zone FOREIGN KEY (obj_id) REFERENCES qgep_od.zone(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lake oorel_od_lake_surface_water_bodies; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.lake
    ADD CONSTRAINT oorel_od_lake_surface_water_bodies FOREIGN KEY (obj_id) REFERENCES qgep_od.surface_water_bodies(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: leapingweir oorel_od_leapingweir_overflow; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.leapingweir
    ADD CONSTRAINT oorel_od_leapingweir_overflow FOREIGN KEY (obj_id) REFERENCES qgep_od.overflow(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lock oorel_od_lock_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.lock
    ADD CONSTRAINT oorel_od_lock_water_control_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: manhole oorel_od_manhole_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.manhole
    ADD CONSTRAINT oorel_od_manhole_wastewater_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: municipality oorel_od_municipality_organisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.municipality
    ADD CONSTRAINT oorel_od_municipality_organisation FOREIGN KEY (obj_id) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: param_ca_general oorel_od_param_ca_general_surface_runoff_parameters; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.param_ca_general
    ADD CONSTRAINT oorel_od_param_ca_general_surface_runoff_parameters FOREIGN KEY (obj_id) REFERENCES qgep_od.surface_runoff_parameters(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: param_ca_mouse1 oorel_od_param_ca_mouse1_surface_runoff_parameters; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.param_ca_mouse1
    ADD CONSTRAINT oorel_od_param_ca_mouse1_surface_runoff_parameters FOREIGN KEY (obj_id) REFERENCES qgep_od.surface_runoff_parameters(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: passage oorel_od_passage_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.passage
    ADD CONSTRAINT oorel_od_passage_water_control_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: planning_zone oorel_od_planning_zone_zone; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.planning_zone
    ADD CONSTRAINT oorel_od_planning_zone_zone FOREIGN KEY (obj_id) REFERENCES qgep_od.zone(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prank_weir oorel_od_prank_weir_overflow; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.prank_weir
    ADD CONSTRAINT oorel_od_prank_weir_overflow FOREIGN KEY (obj_id) REFERENCES qgep_od.overflow(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: private oorel_od_private_organisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.private
    ADD CONSTRAINT oorel_od_private_organisation FOREIGN KEY (obj_id) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pump oorel_od_pump_overflow; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pump
    ADD CONSTRAINT oorel_od_pump_overflow FOREIGN KEY (obj_id) REFERENCES qgep_od.overflow(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reach oorel_od_reach_wastewater_networkelement; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT oorel_od_reach_wastewater_networkelement FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reservoir oorel_od_reservoir_connection_object; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reservoir
    ADD CONSTRAINT oorel_od_reservoir_connection_object FOREIGN KEY (obj_id) REFERENCES qgep_od.connection_object(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: river oorel_od_river_surface_water_bodies; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river
    ADD CONSTRAINT oorel_od_river_surface_water_bodies FOREIGN KEY (obj_id) REFERENCES qgep_od.surface_water_bodies(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rock_ramp oorel_od_rock_ramp_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.rock_ramp
    ADD CONSTRAINT oorel_od_rock_ramp_water_control_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: solids_retention oorel_od_solids_retention_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.solids_retention
    ADD CONSTRAINT oorel_od_solids_retention_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: special_structure oorel_od_special_structure_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.special_structure
    ADD CONSTRAINT oorel_od_special_structure_wastewater_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tank_cleaning oorel_od_tank_cleaning_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_cleaning
    ADD CONSTRAINT oorel_od_tank_cleaning_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tank_emptying oorel_od_tank_emptying_structure_part; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_emptying
    ADD CONSTRAINT oorel_od_tank_emptying_structure_part FOREIGN KEY (obj_id) REFERENCES qgep_od.structure_part(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: waste_water_association oorel_od_waste_water_association_organisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_association
    ADD CONSTRAINT oorel_od_waste_water_association_organisation FOREIGN KEY (obj_id) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: waste_water_treatment_plant oorel_od_waste_water_treatment_plant_organisation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_treatment_plant
    ADD CONSTRAINT oorel_od_waste_water_treatment_plant_organisation FOREIGN KEY (obj_id) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wastewater_node oorel_od_wastewater_node_wastewater_networkelement; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_node
    ADD CONSTRAINT oorel_od_wastewater_node_wastewater_networkelement FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_body_protection_sector oorel_od_water_body_protection_sector_zone; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_body_protection_sector
    ADD CONSTRAINT oorel_od_water_body_protection_sector_zone FOREIGN KEY (obj_id) REFERENCES qgep_od.zone(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wwtp_structure oorel_od_wwtp_structure_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wwtp_structure
    ADD CONSTRAINT oorel_od_wwtp_structure_wastewater_structure FOREIGN KEY (obj_id) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: accident rel_accident_hazard_source; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.accident
    ADD CONSTRAINT rel_accident_hazard_source FOREIGN KEY (fk_hazard_source) REFERENCES qgep_od.hazard_source(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: backflow_prevention rel_backflow_prevention_pump; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.backflow_prevention
    ADD CONSTRAINT rel_backflow_prevention_pump FOREIGN KEY (fk_pump) REFERENCES qgep_od.pump(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: backflow_prevention rel_backflow_prevention_throttle_shut_off_unit; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.backflow_prevention
    ADD CONSTRAINT rel_backflow_prevention_throttle_shut_off_unit FOREIGN KEY (fk_throttle_shut_off_unit) REFERENCES qgep_od.throttle_shut_off_unit(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: bathing_area rel_bathing_area_chute; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.bathing_area
    ADD CONSTRAINT rel_bathing_area_chute FOREIGN KEY (fk_chute) REFERENCES qgep_od.surface_water_bodies(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: catchment_area_text rel_catchment_area_text_catchment_area; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area_text
    ADD CONSTRAINT rel_catchment_area_text_catchment_area FOREIGN KEY (fk_catchment_area) REFERENCES qgep_od.catchment_area(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: catchment_area rel_catchment_area_wastewater_networkelement_rw_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT rel_catchment_area_wastewater_networkelement_rw_current FOREIGN KEY (fk_wastewater_networkelement_rw_current) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: catchment_area rel_catchment_area_wastewater_networkelement_rw_planned; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT rel_catchment_area_wastewater_networkelement_rw_planned FOREIGN KEY (fk_wastewater_networkelement_rw_planned) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: catchment_area rel_catchment_area_wastewater_networkelement_ww_current; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT rel_catchment_area_wastewater_networkelement_ww_current FOREIGN KEY (fk_wastewater_networkelement_ww_current) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: catchment_area rel_catchment_area_wastewater_networkelement_ww_planned; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT rel_catchment_area_wastewater_networkelement_ww_planned FOREIGN KEY (fk_wastewater_networkelement_ww_planned) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: connection_object rel_connection_object_operator; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.connection_object
    ADD CONSTRAINT rel_connection_object_operator FOREIGN KEY (fk_operator) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: connection_object rel_connection_object_owner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.connection_object
    ADD CONSTRAINT rel_connection_object_owner FOREIGN KEY (fk_owner) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: connection_object rel_connection_object_wastewater_networkelement; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.connection_object
    ADD CONSTRAINT rel_connection_object_wastewater_networkelement FOREIGN KEY (fk_wastewater_networkelement) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: damage rel_damage_examination; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage
    ADD CONSTRAINT rel_damage_examination FOREIGN KEY (fk_examination) REFERENCES qgep_od.examination(obj_id);


--
-- Name: discharge_point rel_discharge_point_sector_water_body; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.discharge_point
    ADD CONSTRAINT rel_discharge_point_sector_water_body FOREIGN KEY (fk_sector_water_body) REFERENCES qgep_od.sector_water_body(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: examination rel_examination_reach_point; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.examination
    ADD CONSTRAINT rel_examination_reach_point FOREIGN KEY (fk_reach_point) REFERENCES qgep_od.reach_point(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fish_pass rel_fish_pass_water_control_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.fish_pass
    ADD CONSTRAINT rel_fish_pass_water_control_structure FOREIGN KEY (fk_water_control_structure) REFERENCES qgep_od.water_control_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hazard_source rel_hazard_source_connection_object; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hazard_source
    ADD CONSTRAINT rel_hazard_source_connection_object FOREIGN KEY (fk_connection_object) REFERENCES qgep_od.connection_object(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: hazard_source rel_hazard_source_owner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hazard_source
    ADD CONSTRAINT rel_hazard_source_owner FOREIGN KEY (fk_owner) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: hq_relation rel_hq_relation_overflow_characteristic; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hq_relation
    ADD CONSTRAINT rel_hq_relation_overflow_characteristic FOREIGN KEY (fk_overflow_characteristic) REFERENCES qgep_od.overflow_char(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hydr_geom_relation rel_hydr_geom_relation_hydr_geometry; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydr_geom_relation
    ADD CONSTRAINT rel_hydr_geom_relation_hydr_geometry FOREIGN KEY (fk_hydr_geometry) REFERENCES qgep_od.hydr_geometry(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hydraulic_char_data rel_hydraulic_char_data_overflow_characteristic; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT rel_hydraulic_char_data_overflow_characteristic FOREIGN KEY (fk_overflow_characteristic) REFERENCES qgep_od.overflow_char(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: hydraulic_char_data rel_hydraulic_char_data_wastewater_node; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT rel_hydraulic_char_data_wastewater_node FOREIGN KEY (fk_wastewater_node) REFERENCES qgep_od.wastewater_node(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: infiltration_installation rel_infiltration_installation_aquifier; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.infiltration_installation
    ADD CONSTRAINT rel_infiltration_installation_aquifier FOREIGN KEY (fk_aquifier) REFERENCES qgep_od.aquifier(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: maintenance_event rel_maintenance_event_operating_company; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.maintenance_event
    ADD CONSTRAINT rel_maintenance_event_operating_company FOREIGN KEY (fk_operating_company) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: re_maintenance_event_wastewater_structure rel_maintenance_event_wastewater_structure_maintenance_event; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.re_maintenance_event_wastewater_structure
    ADD CONSTRAINT rel_maintenance_event_wastewater_structure_maintenance_event FOREIGN KEY (fk_maintenance_event) REFERENCES qgep_od.maintenance_event(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: re_maintenance_event_wastewater_structure rel_maintenance_event_wastewater_structure_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.re_maintenance_event_wastewater_structure
    ADD CONSTRAINT rel_maintenance_event_wastewater_structure_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: measurement_result rel_measurement_result_measurement_series; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_result
    ADD CONSTRAINT rel_measurement_result_measurement_series FOREIGN KEY (fk_measurement_series) REFERENCES qgep_od.measurement_series(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: measurement_result rel_measurement_result_measuring_device; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_result
    ADD CONSTRAINT rel_measurement_result_measuring_device FOREIGN KEY (fk_measuring_device) REFERENCES qgep_od.measuring_device(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: measurement_series rel_measurement_series_measuring_point; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_series
    ADD CONSTRAINT rel_measurement_series_measuring_point FOREIGN KEY (fk_measuring_point) REFERENCES qgep_od.measuring_point(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: measuring_device rel_measuring_device_measuring_point; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_device
    ADD CONSTRAINT rel_measuring_device_measuring_point FOREIGN KEY (fk_measuring_point) REFERENCES qgep_od.measuring_point(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: measuring_point rel_measuring_point_operator; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT rel_measuring_point_operator FOREIGN KEY (fk_operator) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: measuring_point rel_measuring_point_waste_water_treatment_plant; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT rel_measuring_point_waste_water_treatment_plant FOREIGN KEY (fk_waste_water_treatment_plant) REFERENCES qgep_od.waste_water_treatment_plant(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: measuring_point rel_measuring_point_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT rel_measuring_point_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: measuring_point rel_measuring_point_water_course_segment; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT rel_measuring_point_water_course_segment FOREIGN KEY (fk_water_course_segment) REFERENCES qgep_od.water_course_segment(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: mechanical_pretreatment rel_mechanical_pretreatment_infiltration_installation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mechanical_pretreatment
    ADD CONSTRAINT rel_mechanical_pretreatment_infiltration_installation FOREIGN KEY (fk_infiltration_installation) REFERENCES qgep_od.infiltration_installation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: mechanical_pretreatment rel_mechanical_pretreatment_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mechanical_pretreatment
    ADD CONSTRAINT rel_mechanical_pretreatment_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: accident rel_od_accident_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.accident
    ADD CONSTRAINT rel_od_accident_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: accident rel_od_accident_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.accident
    ADD CONSTRAINT rel_od_accident_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: aquifier rel_od_aquifier_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.aquifier
    ADD CONSTRAINT rel_od_aquifier_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: aquifier rel_od_aquifier_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.aquifier
    ADD CONSTRAINT rel_od_aquifier_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: bathing_area rel_od_bathing_area_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.bathing_area
    ADD CONSTRAINT rel_od_bathing_area_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: bathing_area rel_od_bathing_area_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.bathing_area
    ADD CONSTRAINT rel_od_bathing_area_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: catchment_area rel_od_catchment_area_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT rel_od_catchment_area_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: catchment_area rel_od_catchment_area_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.catchment_area
    ADD CONSTRAINT rel_od_catchment_area_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: connection_object rel_od_connection_object_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.connection_object
    ADD CONSTRAINT rel_od_connection_object_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: connection_object rel_od_connection_object_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.connection_object
    ADD CONSTRAINT rel_od_connection_object_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: control_center rel_od_control_center_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.control_center
    ADD CONSTRAINT rel_od_control_center_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: control_center rel_od_control_center_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.control_center
    ADD CONSTRAINT rel_od_control_center_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: damage rel_od_damage_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage
    ADD CONSTRAINT rel_od_damage_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: damage rel_od_damage_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.damage
    ADD CONSTRAINT rel_od_damage_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: data_media rel_od_data_media_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.data_media
    ADD CONSTRAINT rel_od_data_media_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: data_media rel_od_data_media_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.data_media
    ADD CONSTRAINT rel_od_data_media_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: file rel_od_file_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.file
    ADD CONSTRAINT rel_od_file_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: file rel_od_file_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.file
    ADD CONSTRAINT rel_od_file_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: fish_pass rel_od_fish_pass_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.fish_pass
    ADD CONSTRAINT rel_od_fish_pass_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: fish_pass rel_od_fish_pass_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.fish_pass
    ADD CONSTRAINT rel_od_fish_pass_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hazard_source rel_od_hazard_source_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hazard_source
    ADD CONSTRAINT rel_od_hazard_source_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hazard_source rel_od_hazard_source_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hazard_source
    ADD CONSTRAINT rel_od_hazard_source_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hq_relation rel_od_hq_relation_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hq_relation
    ADD CONSTRAINT rel_od_hq_relation_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hq_relation rel_od_hq_relation_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hq_relation
    ADD CONSTRAINT rel_od_hq_relation_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hydr_geom_relation rel_od_hydr_geom_relation_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydr_geom_relation
    ADD CONSTRAINT rel_od_hydr_geom_relation_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hydr_geom_relation rel_od_hydr_geom_relation_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydr_geom_relation
    ADD CONSTRAINT rel_od_hydr_geom_relation_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hydr_geometry rel_od_hydr_geometry_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydr_geometry
    ADD CONSTRAINT rel_od_hydr_geometry_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hydr_geometry rel_od_hydr_geometry_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydr_geometry
    ADD CONSTRAINT rel_od_hydr_geometry_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hydraulic_char_data rel_od_hydraulic_char_data_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT rel_od_hydraulic_char_data_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: hydraulic_char_data rel_od_hydraulic_char_data_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.hydraulic_char_data
    ADD CONSTRAINT rel_od_hydraulic_char_data_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: maintenance_event rel_od_maintenance_event_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.maintenance_event
    ADD CONSTRAINT rel_od_maintenance_event_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: maintenance_event rel_od_maintenance_event_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.maintenance_event
    ADD CONSTRAINT rel_od_maintenance_event_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measurement_result rel_od_measurement_result_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_result
    ADD CONSTRAINT rel_od_measurement_result_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measurement_result rel_od_measurement_result_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_result
    ADD CONSTRAINT rel_od_measurement_result_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measurement_series rel_od_measurement_series_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_series
    ADD CONSTRAINT rel_od_measurement_series_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measurement_series rel_od_measurement_series_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measurement_series
    ADD CONSTRAINT rel_od_measurement_series_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measuring_device rel_od_measuring_device_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_device
    ADD CONSTRAINT rel_od_measuring_device_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measuring_device rel_od_measuring_device_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_device
    ADD CONSTRAINT rel_od_measuring_device_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measuring_point rel_od_measuring_point_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT rel_od_measuring_point_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: measuring_point rel_od_measuring_point_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.measuring_point
    ADD CONSTRAINT rel_od_measuring_point_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: mechanical_pretreatment rel_od_mechanical_pretreatment_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mechanical_pretreatment
    ADD CONSTRAINT rel_od_mechanical_pretreatment_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: mechanical_pretreatment rel_od_mechanical_pretreatment_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mechanical_pretreatment
    ADD CONSTRAINT rel_od_mechanical_pretreatment_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: mutation rel_od_mutation_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mutation
    ADD CONSTRAINT rel_od_mutation_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: mutation rel_od_mutation_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.mutation
    ADD CONSTRAINT rel_od_mutation_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: organisation rel_od_organisation_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.organisation
    ADD CONSTRAINT rel_od_organisation_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: organisation rel_od_organisation_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.organisation
    ADD CONSTRAINT rel_od_organisation_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: overflow_char rel_od_overflow_char_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow_char
    ADD CONSTRAINT rel_od_overflow_char_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: overflow_char rel_od_overflow_char_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow_char
    ADD CONSTRAINT rel_od_overflow_char_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: overflow rel_od_overflow_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT rel_od_overflow_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: overflow rel_od_overflow_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT rel_od_overflow_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: pipe_profile rel_od_pipe_profile_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pipe_profile
    ADD CONSTRAINT rel_od_pipe_profile_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: pipe_profile rel_od_pipe_profile_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.pipe_profile
    ADD CONSTRAINT rel_od_pipe_profile_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: profile_geometry rel_od_profile_geometry_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.profile_geometry
    ADD CONSTRAINT rel_od_profile_geometry_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: profile_geometry rel_od_profile_geometry_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.profile_geometry
    ADD CONSTRAINT rel_od_profile_geometry_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: reach_point rel_od_reach_point_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_point
    ADD CONSTRAINT rel_od_reach_point_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: reach_point rel_od_reach_point_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_point
    ADD CONSTRAINT rel_od_reach_point_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: retention_body rel_od_retention_body_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.retention_body
    ADD CONSTRAINT rel_od_retention_body_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: retention_body rel_od_retention_body_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.retention_body
    ADD CONSTRAINT rel_od_retention_body_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: river_bank rel_od_river_bank_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT rel_od_river_bank_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: river_bank rel_od_river_bank_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT rel_od_river_bank_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: river_bed rel_od_river_bed_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bed
    ADD CONSTRAINT rel_od_river_bed_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: river_bed rel_od_river_bed_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bed
    ADD CONSTRAINT rel_od_river_bed_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: sector_water_body rel_od_sector_water_body_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sector_water_body
    ADD CONSTRAINT rel_od_sector_water_body_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: sector_water_body rel_od_sector_water_body_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sector_water_body
    ADD CONSTRAINT rel_od_sector_water_body_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: sludge_treatment rel_od_sludge_treatment_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sludge_treatment
    ADD CONSTRAINT rel_od_sludge_treatment_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: sludge_treatment rel_od_sludge_treatment_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sludge_treatment
    ADD CONSTRAINT rel_od_sludge_treatment_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: structure_part rel_od_structure_part_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.structure_part
    ADD CONSTRAINT rel_od_structure_part_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: structure_part rel_od_structure_part_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.structure_part
    ADD CONSTRAINT rel_od_structure_part_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: substance rel_od_substance_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.substance
    ADD CONSTRAINT rel_od_substance_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: substance rel_od_substance_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.substance
    ADD CONSTRAINT rel_od_substance_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: surface_runoff_parameters rel_od_surface_runoff_parameters_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.surface_runoff_parameters
    ADD CONSTRAINT rel_od_surface_runoff_parameters_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: surface_runoff_parameters rel_od_surface_runoff_parameters_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.surface_runoff_parameters
    ADD CONSTRAINT rel_od_surface_runoff_parameters_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: surface_water_bodies rel_od_surface_water_bodies_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.surface_water_bodies
    ADD CONSTRAINT rel_od_surface_water_bodies_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: surface_water_bodies rel_od_surface_water_bodies_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.surface_water_bodies
    ADD CONSTRAINT rel_od_surface_water_bodies_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: throttle_shut_off_unit rel_od_throttle_shut_off_unit_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT rel_od_throttle_shut_off_unit_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: throttle_shut_off_unit rel_od_throttle_shut_off_unit_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT rel_od_throttle_shut_off_unit_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: waste_water_treatment rel_od_waste_water_treatment_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_treatment
    ADD CONSTRAINT rel_od_waste_water_treatment_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: waste_water_treatment rel_od_waste_water_treatment_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_treatment
    ADD CONSTRAINT rel_od_waste_water_treatment_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wastewater_networkelement rel_od_wastewater_networkelement_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_networkelement
    ADD CONSTRAINT rel_od_wastewater_networkelement_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wastewater_networkelement rel_od_wastewater_networkelement_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_networkelement
    ADD CONSTRAINT rel_od_wastewater_networkelement_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wastewater_structure rel_od_wastewater_structure_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT rel_od_wastewater_structure_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wastewater_structure rel_od_wastewater_structure_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT rel_od_wastewater_structure_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wastewater_structure_symbol rel_od_wastewater_structure_symbol_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_symbol
    ADD CONSTRAINT rel_od_wastewater_structure_symbol_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wastewater_structure_symbol rel_od_wastewater_structure_symbol_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_symbol
    ADD CONSTRAINT rel_od_wastewater_structure_symbol_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: water_catchment rel_od_water_catchment_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_catchment
    ADD CONSTRAINT rel_od_water_catchment_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: water_catchment rel_od_water_catchment_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_catchment
    ADD CONSTRAINT rel_od_water_catchment_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: water_control_structure rel_od_water_control_structure_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_control_structure
    ADD CONSTRAINT rel_od_water_control_structure_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: water_control_structure rel_od_water_control_structure_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_control_structure
    ADD CONSTRAINT rel_od_water_control_structure_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: water_course_segment rel_od_water_course_segment_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT rel_od_water_course_segment_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: water_course_segment rel_od_water_course_segment_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT rel_od_water_course_segment_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wwtp_energy_use rel_od_wwtp_energy_use_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wwtp_energy_use
    ADD CONSTRAINT rel_od_wwtp_energy_use_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: wwtp_energy_use rel_od_wwtp_energy_use_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wwtp_energy_use
    ADD CONSTRAINT rel_od_wwtp_energy_use_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: zone rel_od_zone_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.zone
    ADD CONSTRAINT rel_od_zone_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: zone rel_od_zone_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.zone
    ADD CONSTRAINT rel_od_zone_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: overflow rel_overflow_control_center; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT rel_overflow_control_center FOREIGN KEY (fk_control_center) REFERENCES qgep_od.control_center(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: overflow rel_overflow_overflow_characteristic; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT rel_overflow_overflow_characteristic FOREIGN KEY (fk_overflow_characteristic) REFERENCES qgep_od.overflow_char(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: overflow rel_overflow_overflow_to; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT rel_overflow_overflow_to FOREIGN KEY (fk_overflow_to) REFERENCES qgep_od.wastewater_node(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: overflow rel_overflow_wastewater_node; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.overflow
    ADD CONSTRAINT rel_overflow_wastewater_node FOREIGN KEY (fk_wastewater_node) REFERENCES qgep_od.wastewater_node(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: profile_geometry rel_profile_geometry_pipe_profile; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.profile_geometry
    ADD CONSTRAINT rel_profile_geometry_pipe_profile FOREIGN KEY (fk_pipe_profile) REFERENCES qgep_od.pipe_profile(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reach rel_reach_pipe_profile; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT rel_reach_pipe_profile FOREIGN KEY (fk_pipe_profile) REFERENCES qgep_od.pipe_profile(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reach_point rel_reach_point_wastewater_networkelement; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_point
    ADD CONSTRAINT rel_reach_point_wastewater_networkelement FOREIGN KEY (fk_wastewater_networkelement) REFERENCES qgep_od.wastewater_networkelement(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reach rel_reach_reach_point_from; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT rel_reach_reach_point_from FOREIGN KEY (fk_reach_point_from) REFERENCES qgep_od.reach_point(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reach rel_reach_reach_point_to; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach
    ADD CONSTRAINT rel_reach_reach_point_to FOREIGN KEY (fk_reach_point_to) REFERENCES qgep_od.reach_point(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reach_text rel_reach_text_reach; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.reach_text
    ADD CONSTRAINT rel_reach_text_reach FOREIGN KEY (fk_reach) REFERENCES qgep_od.reach(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: retention_body rel_retention_body_infiltration_installation; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.retention_body
    ADD CONSTRAINT rel_retention_body_infiltration_installation FOREIGN KEY (fk_infiltration_installation) REFERENCES qgep_od.infiltration_installation(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: river_bank rel_river_bank_water_course_segment; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bank
    ADD CONSTRAINT rel_river_bank_water_course_segment FOREIGN KEY (fk_water_course_segment) REFERENCES qgep_od.water_course_segment(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: river_bed rel_river_bed_water_course_segment; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.river_bed
    ADD CONSTRAINT rel_river_bed_water_course_segment FOREIGN KEY (fk_water_course_segment) REFERENCES qgep_od.water_course_segment(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sector_water_body rel_sector_water_body_chute; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sector_water_body
    ADD CONSTRAINT rel_sector_water_body_chute FOREIGN KEY (fk_chute) REFERENCES qgep_od.surface_water_bodies(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sludge_treatment rel_sludge_treatment_waste_water_treatment_plant; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.sludge_treatment
    ADD CONSTRAINT rel_sludge_treatment_waste_water_treatment_plant FOREIGN KEY (fk_waste_water_treatment_plant) REFERENCES qgep_od.waste_water_treatment_plant(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: structure_part rel_structure_part_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.structure_part
    ADD CONSTRAINT rel_structure_part_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: substance rel_substance_hazard_source; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.substance
    ADD CONSTRAINT rel_substance_hazard_source FOREIGN KEY (fk_hazard_source) REFERENCES qgep_od.hazard_source(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: surface_runoff_parameters rel_surface_runoff_parameters_catchment_area; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.surface_runoff_parameters
    ADD CONSTRAINT rel_surface_runoff_parameters_catchment_area FOREIGN KEY (fk_catchment_area) REFERENCES qgep_od.catchment_area(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: txt_symbol rel_symbol_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_symbol
    ADD CONSTRAINT rel_symbol_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON DELETE CASCADE;


--
-- Name: tank_emptying rel_tank_emptying_overflow; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_emptying
    ADD CONSTRAINT rel_tank_emptying_overflow FOREIGN KEY (fk_overflow) REFERENCES qgep_od.pump(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tank_emptying rel_tank_emptying_throttle_shut_off_unit; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.tank_emptying
    ADD CONSTRAINT rel_tank_emptying_throttle_shut_off_unit FOREIGN KEY (fk_throttle_shut_off_unit) REFERENCES qgep_od.throttle_shut_off_unit(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: txt_text rel_text_catchment_area; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_text
    ADD CONSTRAINT rel_text_catchment_area FOREIGN KEY (fk_catchment_area) REFERENCES qgep_od.catchment_area(obj_id) ON DELETE CASCADE;


--
-- Name: txt_text rel_text_reach; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_text
    ADD CONSTRAINT rel_text_reach FOREIGN KEY (fk_reach) REFERENCES qgep_od.reach(obj_id) ON DELETE CASCADE;


--
-- Name: txt_text rel_text_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_text
    ADD CONSTRAINT rel_text_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON DELETE CASCADE;


--
-- Name: throttle_shut_off_unit rel_throttle_shut_off_unit_control_center; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT rel_throttle_shut_off_unit_control_center FOREIGN KEY (fk_control_center) REFERENCES qgep_od.control_center(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: throttle_shut_off_unit rel_throttle_shut_off_unit_overflow; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT rel_throttle_shut_off_unit_overflow FOREIGN KEY (fk_overflow) REFERENCES qgep_od.overflow(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: throttle_shut_off_unit rel_throttle_shut_off_unit_wastewater_node; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.throttle_shut_off_unit
    ADD CONSTRAINT rel_throttle_shut_off_unit_wastewater_node FOREIGN KEY (fk_wastewater_node) REFERENCES qgep_od.wastewater_node(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: txt_symbol rel_txt_symbol_fk_dataowner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_symbol
    ADD CONSTRAINT rel_txt_symbol_fk_dataowner FOREIGN KEY (fk_dataowner) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: txt_symbol rel_txt_symbol_fk_dataprovider; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.txt_symbol
    ADD CONSTRAINT rel_txt_symbol_fk_dataprovider FOREIGN KEY (fk_provider) REFERENCES qgep_od.organisation(obj_id);


--
-- Name: waste_water_treatment rel_waste_water_treatment_waste_water_treatment_plant; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.waste_water_treatment
    ADD CONSTRAINT rel_waste_water_treatment_waste_water_treatment_plant FOREIGN KEY (fk_waste_water_treatment_plant) REFERENCES qgep_od.waste_water_treatment_plant(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wastewater_networkelement rel_wastewater_networkelement_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_networkelement
    ADD CONSTRAINT rel_wastewater_networkelement_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wastewater_node rel_wastewater_node_hydr_geometry; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_node
    ADD CONSTRAINT rel_wastewater_node_hydr_geometry FOREIGN KEY (fk_hydr_geometry) REFERENCES qgep_od.hydr_geometry(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wastewater_structure rel_wastewater_structure_cover; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT rel_wastewater_structure_cover FOREIGN KEY (fk_main_cover) REFERENCES qgep_od.cover(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: wastewater_structure rel_wastewater_structure_operator; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT rel_wastewater_structure_operator FOREIGN KEY (fk_operator) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: wastewater_structure rel_wastewater_structure_owner; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure
    ADD CONSTRAINT rel_wastewater_structure_owner FOREIGN KEY (fk_owner) REFERENCES qgep_od.organisation(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: wastewater_structure_symbol rel_wastewater_structure_symbol_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_symbol
    ADD CONSTRAINT rel_wastewater_structure_symbol_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wastewater_structure_text rel_wastewater_structure_text_wastewater_structure; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wastewater_structure_text
    ADD CONSTRAINT rel_wastewater_structure_text_wastewater_structure FOREIGN KEY (fk_wastewater_structure) REFERENCES qgep_od.wastewater_structure(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: water_catchment rel_water_catchment_aquifier; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_catchment
    ADD CONSTRAINT rel_water_catchment_aquifier FOREIGN KEY (fk_aquifier) REFERENCES qgep_od.aquifier(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: water_catchment rel_water_catchment_chute; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_catchment
    ADD CONSTRAINT rel_water_catchment_chute FOREIGN KEY (fk_chute) REFERENCES qgep_od.surface_water_bodies(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: water_control_structure rel_water_control_structure_water_course_segment; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_control_structure
    ADD CONSTRAINT rel_water_control_structure_water_course_segment FOREIGN KEY (fk_water_course_segment) REFERENCES qgep_od.water_course_segment(obj_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: water_course_segment rel_water_course_segment_watercourse; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.water_course_segment
    ADD CONSTRAINT rel_water_course_segment_watercourse FOREIGN KEY (fk_watercourse) REFERENCES qgep_od.river(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wwtp_energy_use rel_wwtp_energy_use_waste_water_treatment_plant; Type: FK CONSTRAINT; Schema: qgep_od; Owner: postgres
--

ALTER TABLE ONLY qgep_od.wwtp_energy_use
    ADD CONSTRAINT rel_wwtp_energy_use_waste_water_treatment_plant FOREIGN KEY (fk_waste_water_treatment_plant) REFERENCES qgep_od.waste_water_treatment_plant(obj_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

