#%%
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time


#%% helper: build <parameter> XML blocks
def createParameterList(parameterList):
    param_str = ""
    for key, val in parameterList.items():
        param_str += "<parameter>\n"
        param_str += f"<name>{key}</name>\n"
        if isinstance(val, list):
            for v in val:
                param_str += f"<value>{v}</value>\n"
        else:
            param_str += f"<value>{val}</value>\n"
        param_str += "</parameter>\n"
    return param_str


#%% helper: parse WONDER XML <data-table> → raw DataFrame
def wonder_xml_to_df(xml_text: str) -> pd.DataFrame:
    soup = BeautifulSoup(xml_text, "lxml-xml")
    data_table = soup.find("data-table")
    if data_table is None:
        raise ValueError("No <data-table> found in response")

    rows = []
    for r in data_table.find_all("r"):
        cells = r.find_all("c")
        vals = []
        for c in cells:
            if c.has_attr("v"):
                vals.append(c["v"])
            elif c.has_attr("l"):
                vals.append(c["l"])
            else:
                vals.append(c.get_text(strip=True))
        rows.append(vals)

    return pd.DataFrame(rows)


#%% measure mapping (optional)
measure_code_to_abbrev = {
    "D205.M1": "Count",
    "D205.M2": "Population",
    "D205.M40": "CrudeRatePer100k",
}


#%% BY variables — MSA REMOVED
b_parameters_d205 = {
    "B_1": "D205.V1",   # Year
    "B_2": "D205.V2",   # State
    "B_3": "D205.V8",   # Cancer Sites
    "B_4": "D205.V5",   # Age Groups
    "B_5": "D205.V9",   # Sex
    "B_6": "D205.V4",   # Race   (correct)
}


#%% Finder + info
f_parameters_d205 = {
    "F_D205.V11": "*All*",
}

i_parameters_d205 = {
    "I_D205.V11": "*All* (The United States)\n",
}


#%% Measures
m_parameters_d205 = {
    "M_1": "D205.M1",
    "M_2": "D205.M2",
    "M_40": "D205.M40",
}


#%% Other Options — NO MSA, NO Puerto Rico
o_parameters_d205 = {
    "O_V11_fmode": "freg",
    "O_cancer": "D205.V8",
    "O_export-format": "xls",
    "O_javascript": "on",
    "O_location": "D205.V2",   # States only
    "O_precision": "1",
    "O_rate_per": "100000",
    "O_stdpop": "201",
    "O_timeout": "600",
    "O_title": "",
}


#%% Misc dataset metadata
misc_parameters_d205 = {
    "action-Send": "Send",
    "dataset_code": "D205",
    "dataset_id": "D205",
    "dataset_label": "United States and Puerto Rico Cancer Statistics, 1999-2022 Incidence",
    "dataset_vintage_latest": "Cancer Incidence",
    "finder-stage-D205.V11": "codeset",
    "saved_id": "",
    "stage": "request",
}



#%% main loop: state × year
url = "https://wonder.cdc.gov/controller/datarequest/D205"

state_codes = [
    "01","02","04","05","06","08","09","10","11","12",
    "13","15","16","17","18","19","20","21","22","23",
    "24","25","26","27","28","29","30","31","32","33",
    "34","35","36","37","38","39","40","41","42","44",
    "45","46","47","48","49","50","51","53","54","55",
    "56"
]


years = range(2013, 2023)

all_dfs = []

for year in years:
    for state_code in state_codes:
        print(f"Year {year}, state {state_code}...")

        v_parameters_d205 = {
            "V_D205.V1": str(year),   # Year
            "V_D205.V10": "0",
            "V_D205.V11": "",
            "V_D205.V12": "",
            "V_D205.V2": state_code,  # State
            "V_D205.V3": "*All*",     # MSA removed from BY but filter *All*
            "V_D205.V4": "*All*",     # Race
            "V_D205.V5": "*All*",     # Age
            "V_D205.V6": "*All*",     # Ethnicity
            "V_D205.V7": "*All*",     # Childhood cancers
            "V_D205.V8": "*All*",     # Cancer Sites
            "V_D205.V9": "*All*",     # Sex
        }

        xml_request_d205 = (
            "<request-parameters>\n"
            + createParameterList(b_parameters_d205)
            + createParameterList(f_parameters_d205)
            + createParameterList(i_parameters_d205)
            + createParameterList(m_parameters_d205)
            + createParameterList(o_parameters_d205)
            + createParameterList(v_parameters_d205)
            + createParameterList(misc_parameters_d205)
            + "</request-parameters>"
        )

        resp = requests.post(
            url,
            data={"request_xml": xml_request_d205,
                  "accept_datause_restrictions": "true"},
            timeout=None,
        )

        print("Status:", resp.status_code)

        if resp.status_code != 200 or "<data-table" not in resp.text:
            print("Failed or no table.")
            print(resp.text[:300])
            continue

        raw_df = wonder_xml_to_df(resp.text)

        # Expect: Year, State, CancerSite, AgeGroup, Sex, Race, Count, Population, CrudeRate
        if raw_df.shape[1] < 9:
            print("Unexpected table shape:", raw_df.shape)
            continue

        raw_df.columns = [
            "Year",
            "State",
            "CancerSite",
            "AgeGroup",
            "Sex",
            "Race",
            "Count",
            "Population",
            "CrudeRatePer100k",
        ]

        raw_df["Year"] = int(year)
        

        all_dfs.append(raw_df)
        time.sleep(0.5)


#%% final merge + numeric cleaning + region/division
if all_dfs:
    df_all = pd.concat(all_dfs, ignore_index=True)
    df_all["Population"] = (
    df_all["Population"]
    .str.replace(",", "", regex=False))


    print("Final rows:", len(df_all))
    print(df_all.head())
else:
    print("No data returned.")

#%%

# Count -> nullable integer
df_all["Count"] = (
    pd.to_numeric(df_all["Count"], errors="coerce")   # ensure numeric
    .round()                                          # just in case there are tiny float artifacts
    .astype("Int64")                                  # pandas nullable integer
)

# Population -> nullable integer
df_all["Population"] = (
    pd.to_numeric(df_all["Population"], errors="coerce")
    .round()
    .astype("Int64")
)

# CrudeRatePer100k -> float (decimal)
df_all["CrudeRatePer100k"] = pd.to_numeric(
    df_all["CrudeRatePer100k"], errors="coerce"
)


#%%
#Instruction Saving to Postgres
from sqlalchemy import create_engine

# Replace with your actual Postgres password
password = "your_postgres_password"

engine = create_engine(
    f"postgresql+psycopg2://postgres:{password}@localhost:5432/your_schema_name"
)


df_all.to_sql(
    name="cancer_statistics_1999_2022",
    con=engine,
    schema="cdc",         
    if_exists="replace",
    index=False
)
print("Table heatwave_d104 written to PostgreSQL.")
# %%
#### SAving to sql lite for shiny app
import sqlite3

# 1. Create / open a SQLite database file
# This will create "cdc_heatwave.db" in your current working directory
conn = sqlite3.connect("cancer_statistics_1999_2022.db")

# 2. Write your DataFrame to a table in that file
df_all.to_sql(
    name="cancer_statistics_1999_2022",   # table name inside the SQLite DB
    con=conn,
    if_exists="replace",    # replace table if it already exists
    index=False
)

# 3. Close the connection
conn.close()

print("Saved df_all to cdc_heatwave.db (table: heatwave_d104)")

# %%
