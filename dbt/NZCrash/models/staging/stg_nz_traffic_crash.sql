WITH source AS (

    select *
from {{ source('raw', 'NZ_Traffic_Crash') }}


),

cleaned AS (

    SELECT 
        -- Identifiers 
        TRY_TO_NUMBER(TO_VARCHAR("OBJECTID")) AS crash_id,

        -- Area 
        TRY_TO_DECIMAL(TO_VARCHAR("X")) AS longitude,
        TRY_TO_DECIMAL(TO_VARCHAR("Y")) AS latitude,
        "crashLocation1"                                                            AS crash_location1,
        "crashLocation2"                                                            AS crash_location2,
        
        -- Conditions 
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("advisorySpeed")), 0) AS advisory_speed,
        "region"                                                                         AS region,

        -- Crash details 
        "crashFinancialYear"                                                             AS financial_year,
        "crashSeverity"                                                                  AS crash_severity,
        "crashSHDescription"                                                             AS crash_sh_description,
        TRY_TO_NUMBER(TO_VARCHAR("crashYear")) AS crash_year,
        
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("minorInjuryCount")), 0) AS minor_injury_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("fatalCount")), 0) AS fatal_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("seriousInjuryCount")), 0) AS serious_injury_count,

        -- Vehicle 
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("bicycle")), 0) AS bicycle_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("bus")), 0) AS bus_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("carStationWagon")), 0) AS car_station_wagon_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("moped")), 0) AS moped_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("motorcycle")), 0) AS motorcycle_count,

        -- Environment 
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("bridge")), 0) AS bridge_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("ditch")), 0) AS ditch_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("fence")), 0) AS fence_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("flatHill")), 0) AS flathill_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("houseOrBuilding")), 0) AS house_or_building_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("guardRail")), 0) AS guard_rail_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("kerb")), 0) AS kerb_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("NumberOfLanes")), 0) AS number_of_lanes,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("objectThrownOrDropped")), 0) AS object_thrown_or_dropped_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("parkedVehicle")), 0) AS parked_vehicle_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("pedestrian")), 0) AS pedestrian_count,
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("roadworks")), 0) AS roadworks_count,
        
        "roadSurface"                                                                 AS road_surface,
        
        -- Speed limit clean handling
        COALESCE(TRY_TO_NUMBER(TO_VARCHAR("speedLimit")), 0) AS speed_limit,
        
        "holiday"                                                                     AS holiday_name,
        "light"                                                                       AS light_description,
        "weatherA"                                                                    AS weather_a,
        "weatherB"                                                                    AS weather_b,
        {{ current_timestamp() }}                                                     AS ingested_at
    FROM source
)

SELECT * FROM cleaned