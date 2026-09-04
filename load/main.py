#from dotenv import load_dotenv
import os 
from extract.NZTrafficCrash_extract import ExtractData
from load.snowflake_load import load_to_snowflake

#load_dotenv('.env')
#dburl = os.getenv('databaseURL')
#print(f"Database URL: {dburl}")

if __name__ == "__main__":
    # Example usage
    df = ExtractData()
    print(f"Extracted DataFrame: {df.head() if df is not None else 'No data extracted.'}")
    load_to_snowflake(df, "NZ_Traffic_Crash","raw")