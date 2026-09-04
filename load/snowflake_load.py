import snowflake.connector
import logging 
import pandas as pd
from dotenv import load_dotenv
from snowflake.connector.pandas_tools import write_pandas
import os
load_dotenv('.env')
logging.basicConfig(level=logging.INFO)


def load_to_snowflake(df : pd.DataFrame, table_name: str,schema: str):
    conn = None
    cursor = None
    try:
        
        conn = snowflake.connector.connect(
            user=os.getenv("SNOWFLAKE_USER"),
            password=os.getenv("SNOWFLAKE_PASSWORD"),
            account=os.getenv("SNOWFLAKE_ACCOUNT"),
            warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
            database=os.getenv("SNOWFLAKE_DATABASE"),
            schema=schema,
        )
        cursor = conn.cursor()
        cursor.execute(f"CREATE SCHEMA IF NOT EXISTS {schema}")
        success, nchunks, nrows, _ = write_pandas(
            conn,
            df,
            table_name,
            database=os.getenv("SNOWFLAKE_DATABASE"),
            schema=schema,
            auto_create_table=True,
            overwrite=True,
            quote_identifiers=False,
        )
        if not success:
            raise Exception("Failed to load data into Snowflake.")
        logging.info(f"Loaded {len(df)} rows into {table_name} table")
    except Exception as e:
        logging.error(f"Failed to load data into Snowflake: {e}")
        raise e
    finally:
        if cursor is not None:
            cursor.close()
        if conn is not None:
            conn.close()
