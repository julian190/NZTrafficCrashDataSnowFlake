# NZ Traffic Crash Data — Snowflake Edition

This is a follow-up to my [original NZ crash data pipeline](https://github.com/julian190/NZTrafficCrashData), which ran on Postgres. I wanted to see how much of that project would carry over to a proper cloud data warehouse, so I rebuilt the load and transform layers against Snowflake instead. Short answer: most of it ports over cleanly, but not all of it — and this repo documents where things had to change.

## Why I built this

I'd just finished my SnowPro Core certification and didn't want it to be a certificate with nothing behind it. A cert tells you I passed a multiple-choice exam. This tells you I can actually get data into Snowflake, shape it with dbt, and explain the decisions along the way — which is a very different thing.

I also wanted to test something specific: how portable is a "real" dbt project when you swap the underlying warehouse? Same source data, same business questions, different engine. That distinction matters more than it sounds like it should.

## What's the same as the Postgres version

- The data source: Waka Kotahi's Crash Analysis System (CAS), pulled via the ArcGIS CSV endpoint.
- The extract step: same Python + `requests` logic. I didn't touch it, and that was intentional — extract logic shouldn't care where the data ends up.
- The transformation logic in dbt: staging cleans and casts columns, the mart layer builds out the same derived fields (total casualties, road type by speed band, fatality flags, vulnerable road user flags).

## What had to change

- **Loading data in.** The Postgres version used SQLAlchemy and `df.to_sql()`. Snowflake needs its own connector, so I switched to `snowflake-connector-python` and used `write_pandas()`, which handles staging the file and running `COPY INTO` behind the scenes rather than me managing that manually.
- **Identifier casing.** Snowflake defaults to uppercase unquoted identifiers. Postgres doesn't care about case unless you quote things. This tripped me up early — a couple of "table not found" errors that turned out to just be casing mismatches between my `sources.yml` and what actually landed in the raw table. Once I picked a convention and stuck with it, it stopped being a problem.
- **No S3 bucket.** The course I originally learned this pattern from used an S3 bucket as the source. I don't have an AWS account, so I used Snowflake's internal stages instead — which turned out to be a completely reasonable substitute for a project this size. Worth noting: in a real production setup you'd more likely see an external stage, since data usually already lives in cloud storage somewhere. I used an internal one here because it didn't make sense to spin up AWS just for this.
- **Materialization choices.** Snowflake bills by compute time, which isn't how Postgres works. That changed how I thought about which models should be tables versus views — I didn't just copy the old materializations over without thinking about it.

## Stack

Python (extract) → Snowflake internal stage + `write_pandas` (load) → dbt Core (staging + marts) → Snowflake as the warehouse.

## A note on the data

This uses a free Snowflake trial account, which expires after 30 days. If you're looking at this after that window, the live warehouse won't be running — but everything that matters is here: the code, the dbt models, and the query results I captured while it was live (see `/logs` and the screenshots below). If you want to see it actually running, it takes about ten minutes to spin up a new trial and point this at it, since none of the logic is tied to a specific account.

## Repo structure

```
extract/     - pulls raw CSV data from the CAS ArcGIS endpoint
load/        - loads data into Snowflake using write_pandas
dbt/         - staging and mart models, tests, sources.yml
logs/        - run logs from extract/load scripts
```

## What I'd do differently next time

Probably nothing dramatic, but if I were starting a Snowflake project from scratch (rather than porting one), I'd think harder up front about identifier casing and file format conventions before writing any SQL, instead of discovering the mismatches as I went. It wasn't a big deal to fix, just a few wasted minutes.