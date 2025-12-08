# %% 1 — Imports + Helper Functions

import requests
from bs4 import BeautifulSoup
import pandas as pd
import time


def createParameterList(parameterList):
    """
    Build <parameter>...</parameter> blocks for the WONDER XML request.
    """
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


def wonder_xml_to_df(xml_text: str) -> pd.DataFrame:
    """
    Convert WONDER <data-table> XML into pandas DataFrame.
    """
    soup = BeautifulSoup(xml_text, "lxml-xml")
    table = soup.find("data-table")
    if table is None:
        raise ValueError("No <data-table> found in response.")

    rows = []
    for r in table.find_all("r"):
        vals = []
        for c in r.find_all("c"):
            if c.has_attr("v"):
                vals.append(c["v"])
            elif c.has_attr("l"):
                vals.append(c["l"])
            else:
                vals.append(c.get_text(strip=True))
        rows.append(vals)

    return pd.DataFrame(rows)



# %% 2 — Parameter Definitions (D128 Selected STDs by Age, Race/Ethnicity, Sex)

b_parameters_d128 = {
    "B_1": "D128.V1",   # Year
    "B_2": "D128.V2",   # State
    "B_3": "D128.V4",   # Sex
    "B_4": "D128.V9",   # Age
    "B_5": "D128.V3",   # Disease
}

f_parameters_d128 = {
    "F_D128.V5": "*All*",
    "F_D128.V6": "*All*",
    "F_D128.V7": "*All*",
}

i_parameters_d128 = {
    "I_D128.V5": "*All* (The United States)\n",
    "I_D128.V6": "*All* (The United States)\n",
    "I_D128.V7": "*All* (The United States)\n",
}

m_parameters_d128 = {
    "M_1": "D128.M1",   # STD Cases
    "M_2": "D128.M2",   # Population
    "M_3": "D128.M3",   # Rate per 100k
}

o_parameters_d128 = {
    "O_V5_fmode": "freg",
    "O_V6_fmode": "freg",
    "O_V7_fmode": "freg",
    "O_export-format": "xls",
    "O_javascript": "on",
    "O_location": "D128.V2",
    "O_precision": "2",
    "O_rate_per": "100000",
    "O_timeout": "600",
    "O_title": "",
}

misc_parameters_d128 = {
    "action-Send": "Send",
    "dataset_code": "D128",
    "dataset_label": "Selected STDs by Age, Race/Ethnicity, and Sex, 1996-2014",
    "dataset_vintage_latest": "STD by age, race/ethnicity",
    "finder-stage-D128.V5": "codeset",
    "finder-stage-D128.V6": "codeset",
    "finder-stage-D128.V7": "codeset",
    "saved_id": "",
    "stage": "request",
}



# %% 3 — Loop settings (Years, States, URL) + State Name Lookup

url = "https://wonder.cdc.gov/controller/datarequest/D128"

years = range(1996, 2015)

state_codes = [
    "01","02","04","05","06","08","09","10","11","12",
    "13","15","16","17","18","19","20","21","22","23",
    "24","25","26","27","28","29","30","31","32","33",
    "34","35","36","37","38","39","40","41","42","44",
    "45","46","47","48","49","50","51","53","54","55",
    "56","72"
]

# FIPS → State name lookup
state_lookup = {
    "01": "Alabama", "02": "Alaska", "04": "Arizona", "05": "Arkansas",
    "06": "California", "08": "Colorado", "09": "Connecticut", "10": "Delaware",
    "11": "District of Columbia", "12": "Florida", "13": "Georgia", "15": "Hawaii",
    "16": "Idaho", "17": "Illinois", "18": "Indiana", "19": "Iowa",
    "20": "Kansas", "21": "Kentucky", "22": "Louisiana", "23": "Maine",
    "24": "Maryland", "25": "Massachusetts", "26": "Michigan", "27": "Minnesota",
    "28": "Mississippi", "29": "Missouri", "30": "Montana", "31": "Nebraska",
    "32": "Nevada", "33": "New Hampshire", "34": "New Jersey", "35": "New Mexico",
    "36": "New York", "37": "North Carolina", "38": "North Dakota", "39": "Ohio",
    "40": "Oklahoma", "41": "Oregon", "42": "Pennsylvania", "44": "Rhode Island",
    "45": "South Carolina", "46": "South Dakota", "47": "Tennessee", "48": "Texas",
    "49": "Utah", "50": "Vermont", "51": "Virginia", "53": "Washington",
    "54": "West Virginia", "55": "Wisconsin", "56": "Wyoming",
    "72": "Puerto Rico"
}

all_dfs = []



# %% 4 — Main Extraction Loop

for year in years:
    for st in state_codes:

        print(f"D128: Year {year}, State {st}")

        v_parameters_d128 = {
            "V_D128.V1": str(year),
            "V_D128.V2": st,          # FIPS state code
            "V_D128.V3": "*All*",     # Disease
            "V_D128.V4": "*All*",     # Sex
            "V_D128.V5": "",
            "V_D128.V6": "",
            "V_D128.V7": "",
            "V_D128.V8": "*All*",     # Race/Ethnicity
            "V_D128.V9": "*All*",     # Age
        }

        xml_request = (
            "<request-parameters>\n"
            + createParameterList(b_parameters_d128)
            + createParameterList(f_parameters_d128)
            + createParameterList(i_parameters_d128)
            + createParameterList(m_parameters_d128)
            + createParameterList(o_parameters_d128)
            + createParameterList(v_parameters_d128)
            + createParameterList(misc_parameters_d128)
            + "</request-parameters>"
        )

        resp = requests.post(
            url,
            data={"request_xml": xml_request,
                  "accept_datause_restrictions": "true"},
            timeout=None,
        )

        if resp.status_code != 200 or "<data-table" not in resp.text:
            print("Bad response:", resp.text[:200])
            continue

        df = wonder_xml_to_df(resp.text)

        if df.shape[1] < 8:
            print("Unexpected shape:", df.shape)
            continue

        df.columns = [
            "Year",
            "State",
            "Sex",
            "Age",
            "Disease",
            "Cases",
            "Population",
            "RatePer100k"
        ]

        df["Year"] = year
        df["StateCode"] = st
        df["StateName"] = state_lookup.get(st, None)

        all_dfs.append(df)

        time.sleep(0.35)



# %% 5 — Clean numeric columns, finalize DF

if all_dfs:
    df_all = pd.concat(all_dfs, ignore_index=True)

    df_all["Population"] = df_all["Population"].replace("Not Applicable", pd.NA)
    df_all["RatePer100k"] = df_all["RatePer100k"].replace("Not Applicable", pd.NA)

    df_all["Cases"] = (
        pd.to_numeric(df_all["Cases"].str.replace(",", "", regex=False), errors="coerce")
            .astype("Int64")
    )

    df_all["Population"] = (
        pd.to_numeric(df_all["Population"].str.replace(",", "", regex=False), errors="coerce")
            .astype("Int64")
    )

    df_all["RatePer100k"] = pd.to_numeric(df_all["RatePer100k"], errors="coerce")

    print("FINAL ROW COUNT:", len(df_all))
    print(df_all.head())

else:
    print("No D128 data returned.")

#%%
#Instruction Saving to Postgres
from sqlalchemy import create_engine

# Replace with your actual Postgres password
password = "YourPostgresPassword"

engine = create_engine(
    f"postgresql+psycopg2://postgres:{password}@localhost:5432/your_schema_name"
)


df_all.to_sql(
    name="std_d128_1996_2014",
    con=engine,
    schema="cdc",         
    if_exists="replace",
    index=False
)
print("Table heatwave_d104 written to PostgreSQL.")

# %% 6 — Save to SQLite

import sqlite3

conn = sqlite3.connect("std_selected_age_race_1996_2014.db")

df_all.to_sql(
    name="std_selected_age_race_1996_2014",
    con=conn,
    if_exists="replace",
    index=False
)

conn.close()

print("Saved to std_selected_age_race_1996_2014.db")
