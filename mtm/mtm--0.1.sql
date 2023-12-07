\echo Use "CREATE EXTENSION mtm" to load this file. \quit 


CREATE TYPE state_mtm AS (
    min numeric,
    max numeric,
    cntr int
);

CREATE OR REPLACE FUNCTION transition_mtm(
    state state_mtm,
    val numeric
)
RETURNS state_mtm AS $$
BEGIN
   -- RAISE NOTICE 'min: % max: % cntr: % val: %', state.min, state.max, state.cntr, val;
    IF state.cntr <> 0 THEN
      IF  state.min > val THEN
        state.min := val ;
      END IF;

      IF  state.max < val THEN
        state.max := val ;
      END IF;
    ELSE
     state.min := val ;
     state.max := val ;
    END IF;

    RETURN ROW(state.min, state.max, state.cntr+1)::state_mtm;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION final_mtm(
    state state_mtm
)
RETURNS text AS $$
<< main >>
DECLARE 
   formate text ;
   outp text; 
BEGIN
    -- RAISE NOTICE '= %(%)', state.min, state.max;
    SELECT coalesce(current_setting('mtm.output_format', true), '%s -> %s') into formate ;

    BEGIN 
        SELECT format(main.formate, state.max, state.min) into main.outp ;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Cehck mtm.output_format: %', main.formate;
    END;

    RETURN CASE
        WHEN state.cntr > 0 THEN outp::text
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE AGGREGATE max_to_min(numeric) (
    stype     = state_mtm,
    initcond  = '(0,0,0)',
    sfunc     = transition_mtm,
    finalfunc = final_mtm
);

CREATE TYPE state_mtm_dp AS (
    min double precision,
    max double precision,
    cntr int
);

CREATE OR REPLACE FUNCTION transition_mtm(
    state state_mtm_dp,
    val double precision
)
RETURNS state_mtm_dp AS $$
BEGIN
    -- RAISE NOTICE 'min: % max: % cntr: % val: %', state.min, state.max, state.cntr, val;

    IF val IS NULL THEN
        RETURN ROW(state.min, state.max, state.cntr)::state_mtm_dp ;
    END IF;

    IF state.cntr <> 0 THEN
      IF  state.min > val THEN
        state.min := val ;
      END IF;
      IF  state.max < val THEN
        state.max := val ;
      END IF;
    ELSE
     state.min := val ;
     state.max := val ;
    END IF;

    RETURN ROW(state.min, state.max, state.cntr+1)::state_mtm_dp;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION final_mtm(
    state state_mtm_dp
)
RETURNS text AS $$
<< main >>
DECLARE 
   formate text ;
   outp text; 
BEGIN
    SELECT coalesce(current_setting('mtm.output_format', true), '%s -> %s') into formate ;

    BEGIN 
        SELECT format(main.formate, state.max, state.min) into main.outp ;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Cehck mtm.output_format: %', main.formate;
    END;

    RETURN CASE
        WHEN state.cntr > 0 THEN outp::text
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE AGGREGATE max_to_min(double precision) (
    stype     = state_mtm_dp,
    initcond  = '(0,0,0)',
    sfunc     = transition_mtm,
    finalfunc = final_mtm
);