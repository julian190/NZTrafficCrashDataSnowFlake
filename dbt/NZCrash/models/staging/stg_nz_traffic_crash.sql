WITH source AS (

    SELECT * FROM {{ source('NZCRASHDATA', 'NZ_Traffic_Crash') }}

),

cleaned AS (

    SELECT 
        -- Identifiers 
        TRY_TO_NUMBER("OBJECTID") AS crash_id,

        -- Area 
        TRY_TO_DECIMAL("X") AS longitude,
        TRY_TO_DECIMAL("Y") AS latitude,
        "crashLocation1"                                                            AS crash_location1,
        "crashLocation2"                                                            AS crash_location2,
        
        -- Conditions 
        COALESCE(TRY_TO_NUMBER("advisorySpeed"), 0) AS advisory_speed,
        "region"                                                                         AS region,

        -- Crash details 
        "crashFinancialYear"                                                             AS financial_year,
        "crashSeverity"                                                                  AS crash_severity,
        "crashSHDescription"                                                             AS crash_sh_description,
        TRY_TO_NUMBER("crashYear") AS crash_year,
        
        COALESCE(TRY_TO_NUMBER("minorInjuryCount"), 0) AS minor_injury_count,
        COALESCE(TRY_TO_NUMBER("fatalCount"), 0) AS fatal_count,
        COALESCE(TRY_TO_NUMBER("seriousInjuryCount"), 0) AS serious_injury_count,

        -- Vehicle 
        COALESCE(TRY_TO_NUMBER("bicycle"), 0) AS bicycle_count,
        COALESCE(TRY_TO_NUMBER("bus"), 0) AS bus_count,
        COALESCE(TRY_TO_NUMBER("carStationWagon"), 0) AS car_station_wagon_count,
        COALESCE(TRY_TO_NUMBER("moped"), 0) AS moped_count,
        COALESCE(TRY_TO_NUMBER("motorcycle"), 0) AS motorcycle_count,

        -- Environment 
        COALESCE(TRY_TO_NUMBER("bridge"), 0) AS bridge_count,
        COALESCE(TRY_TO_NUMBER("ditch"), 0) AS ditch_count,
        COALESCE(TRY_TO_NUMBER("fence"), 0) AS fence_count,
        COALESCE(TRY_TO_NUMBER("flatHill"), 0) AS flathill_count,
        COALESCE(TRY_TO_NUMBER("houseOrBuilding"), 0) AS house_or_building_count,
        COALESCE(TRY_TO_NUMBER("guardRail"), 0) AS guard_rail_count,
        COALESCE(TRY_TO_NUMBER("kerb"), 0) AS kerb_count,
        COALESCE(TRY_TO_NUMBER("NumberOfLanes"), 0) AS number_of_lanes,
        COALESCE(TRY_TO_NUMBER("objectThrownOrDropped"), 0) AS object_thrown_or_dropped_count,
        COALESCE(TRY_TO_NUMBER("parkedVehicle"), 0) AS parked_vehicle_count,
        COALESCE(TRY_TO_NUMBER("pedestrian"), 0) AS pedestrian_count,
        COALESCE(TRY_TO_NUMBER("roadworks"), 0) AS roadworks_count,
        
        "roadSurface"                                                                 AS road_surface,
        
        -- Speed limit clean handling
        COALESCE(TRY_TO_NUMBER("speedLimit"), 0) AS speed_limit,
        
        "holiday"                                                                     AS holiday_name,
        "light"                                                                       AS light_description,
        "weatherA"                                                                    AS weather_a,
        "weatherB"                                                                    AS weather_b,
        {{ current_timestamp() }}                                                     AS ingested_at
    FROM source
)

SELECT * FROM cleaned