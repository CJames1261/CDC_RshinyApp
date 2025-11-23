#%%
#### TEST CODE FOR DATASET AVAILABILITY DISCOVERY
# The following code can be used to scrape the CDC WONDER landing page
# #%%
# import requests
# from bs4 import BeautifulSoup
# from urllib.parse import urljoin, urlparse
# #%%
# BASE = "https://wonder.cdc.gov"
# landing = "https://wonder.cdc.gov/nca-heatwavedays-historic.html"

# resp = requests.get(landing)
# print("Status:", resp.status_code)

# soup = BeautifulSoup(resp.text, "lxml")

# codes = set()

# # Look at all forms and grab their action URLs
# for form in soup.find_all("form", action=True):
#     action = form["action"]
#     full_url = urljoin(BASE, action)
#     path = urlparse(full_url).path  # e.g. "/controller/datarequest/D104"
#     tail = path.rstrip("/").split("/")[-1]  # e.g. "D104"
#     if tail.startswith("D") and tail[1:].isdigit():
#         codes.add(tail)

# print("Found dataset codes:", codes)


#%% imports
import requests
from bs4 import BeautifulSoup
import pandas as pd


#%% helper: build <parameter> XML blocks
def createParameterList(parameterList):
    """
    Helper to convert a dict like {"B_1": "D104.V2-level2", ...}
    into a chunk of:
      <parameter><name>...</name><value>...</value></parameter>
    """
    parameterString = ""
    for key in parameterList:
        parameterString += "<parameter>\n"
        parameterString += f"<name>{key}</name>\n"
        if isinstance(parameterList[key], list):
            for value in parameterList[key]:
                parameterString += f"<value>{value}</value>\n"
        else:
            parameterString += f"<value>{parameterList[key]}</value>\n"
        parameterString += "</parameter>\n"
    return parameterString


#%% helper: parse WONDER XML <data-table> → raw DataFrame
def wonder_xml_to_df(xml_text: str) -> pd.DataFrame:
    """
    Convert a CDC WONDER <data-table> XML into a pandas DataFrame.

    For D104 with:
      B_1 = D104.V2-level2 (County)
      B_2 = D104.V3        (Year)
      M_* = measures

    The first two columns will be [County, Year], the rest are measures.
    """
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

    df = pd.DataFrame(rows)
    return df


# #%% mapping: D104 measure codes → column definitions
# measure_code_to_name = {
#     "D104.M1":  "Heat Wave Days Based on Daily Maximum Temperature",
#     "D104.M11": "Average Heat Wave Days Based on Daily Maximum Temperature",
#     "D104.M12": "Average Heat Wave Days Based on Daily Maximum Temperature Standard Deviation",

#     "D104.M2": "Heat Wave Days Based on Daily Maximum Heat Index",
#     "D104.M21": "Average Heat Wave Days Based on Daily Maximum Heat Index",
#     "D104.M22": "Average Heat Wave Days Based on Daily Maximum Heat Index Standard Deviation",

#     "D104.M3":  "Heat Wave Days Based on Net Daily Heat Stress",
#     "D104.M31": "Average Heat Wave Days Based on Net Daily Heat Stress",
#     "D104.M32": "Average Heat Wave Days Based on Net Daily Heat Stress Standard Deviation",

#     "D104.M4":  "population",
#     "D104.M41": "Average Population",
#     "D104.M42": "Average Population Standard Deviation",
# }

measure_code_to_abbrev = {
    "D104.M1":  "hw_tmax_days",
    #"D104.M11": "hw_tmax_avg",
    # "D104.M12": "hw_tmax_sd",   # <-- SD removed

    "D104.M2":  "hw_hi_days",
    #"D104.M21": "hw_hi_avg",
    # "D104.M22": "hw_hi_sd",     # <-- SD removed

    "D104.M3":  "hw_nhs_days",
    #"D104.M31": "hw_nhs_avg",
    # "D104.M32": "hw_nhs_sd",    # <-- SD removed

    "D104.M4":  "Population",
    #"D104.M41": "Population_Avg",
    # "D104.M42": "Pop_SD",       # <-- SD removed
}


#%% 1) BY variables: group by County + Year (Pattern B)
b_parameters_104 = {
    "B_1": "D104.V2-level2",   # County
    "B_2": "D104.V3",          # Year
    "B_3": "*None*",
    "B_4": "*None*",
    "B_5": "*None*",
}

#%% 2) Finder + "currently selected" for location
# From exported XML: "All (The United States)"
f_parameters_104 = {
    "F_D104.V2": "*All*",                     # highlight all locations
}

i_parameters_104 = {
    "I_D104.V2": "*All* (The United States) ",  # label shown in UI
}

#%% 3) Measures: request ALL D104 measures (order matters!)
#%% 3) Measures: request ALL D104 measures (order matters!)
m_parameters_104 = {
    "M_1":  "D104.M1",
    #"M_11": "D104.M11",
    # "M_12": "D104.M12",  # <-- SD removed

    "M_2":  "D104.M2",
    #"M_21": "D104.M21",
    # "M_22": "D104.M22",  # <-- SD removed

    "M_3":  "D104.M3",
    #"M_31": "D104.M31",
    # "M_32": "D104.M32",  # <-- SD removed

    "M_4":  "D104.M4",
    #"M_41": "D104.M41",
    # "M_42": "D104.M42",  # <-- SD removed
}


#%% 4) Other options (O_*), taken from your XML
o_parameters_104 = {
    "O_V2_fmode": "freg",      # regular finder
    "O_export-format": "xls",
    "O_javascript": "on",
    "O_precision": "2",
    "O_show_totals": "true",
    "O_timeout": "600",        # can bump if needed
    "O_title": "",             # no title
}

#%% 5) Misc + dataset metadata (from XML)
misc_parameters_104 = {
    "action-Send": "Send",
    "dataset_code": "D104",
    "dataset_id": "D104",
    "dataset_label": "Number of Heat Wave Days in May-September (1981-2010)",
    "dataset_vintage": "2010",
    "finder-stage-D104.V2": "codeset",
    "saved_id": "",
    "stage": "request",
}


#%% main loop: query 1981–2010 by year, group by County + Year
url = "https://wonder.cdc.gov/controller/datarequest/D104"
all_dfs = []

for year in range(1981, 2011):
    # V_* filters: all counties, specific year
    v_parameters_104 = {
        "V_D104.V2": "",         # all counties (default)
        "V_D104.V3": str(year),  # specific year (valid code)
    }

    # Build XML request for this year
    xml_request_104 = "<request-parameters>\n"
    xml_request_104 += createParameterList(b_parameters_104)
    xml_request_104 += createParameterList(f_parameters_104)
    xml_request_104 += createParameterList(i_parameters_104)
    xml_request_104 += createParameterList(m_parameters_104)
    xml_request_104 += createParameterList(o_parameters_104)
    xml_request_104 += createParameterList(v_parameters_104)
    xml_request_104 += createParameterList(misc_parameters_104)
    xml_request_104 += "</request-parameters>"

    resp = requests.post(
        url,
        data={
            "request_xml": xml_request_104,
            "accept_datause_restrictions": "true",
        },
        timeout=600,
    )

    print(f"Year {year} status:", resp.status_code)

    if resp.status_code != 200 or "<data-table" not in resp.text:
        print(f"Year {year} failed or returned no data-table.")
        print(resp.text[:500])
        break

    # Parse raw table
    raw_df = wonder_xml_to_df(resp.text)

    # raw_df columns: [County, Year, M?, M?, ...]
    num_cols = raw_df.shape[1]
    if num_cols < 2:
        raise ValueError(f"Unexpected table shape for year {year}: {raw_df.shape}")

    num_measures_returned = num_cols - 2

    # Measure codes requested, in order (Python 3.7+ dict preserves insertion order)
    requested_measure_codes = list(m_parameters_104.values())
    used_measure_codes = requested_measure_codes[:num_measures_returned]

    # Map measure codes → friendly names
    measure_names = []
    for code in used_measure_codes:
        if code not in measure_code_to_abbrev:
            raise KeyError(f"Missing column name mapping for measure code: {code}")
        measure_names.append(measure_code_to_abbrev[code])

    # Assign column names
    raw_df.columns = ["County", "Year"] + measure_names
    raw_df = raw_df[raw_df["County"].str.strip() != ""]
    

    df_year = raw_df
    
    all_dfs.append(df_year)

#%%
df_all = pd.concat(all_dfs, ignore_index=True)




df_all.head()
#%% combine and save
if all_dfs:
    df_all = pd.concat(all_dfs, ignore_index=True)
    #df_all.to_csv("D104_heatwave_1981_2010_county_year_all_measures.csv", index=False)
    print("Saved all years to D104_heatwave_1981_2010_county_year_all_measures.csv")
    #print(df_all.head())
    print("Columns:", df_all.columns.tolist())
else:
    print("No dataframes were collected; check earlier error messages.")

# Extract state abbreviation
df_all["State_abrv"] = df_all["County"].str.split(",").str[-1].str.strip()

# Extract county name without the word "County"
df_all["County"] = (
    df_all["County"]
    .str.split(",").str[0]
    .str.replace(" County", "", regex=False)
    .str.strip()
)

# Remove commas from Population and convert to integer
df_all["Population"] = (
    df_all["Population"]
    .str.replace(",", "", regex=False)
)
# Columns to keep as strings
string_cols = ["State_abrv", "County"]  # optional to keep County

# Convert all other columns to nullable integer
for col in df_all.columns:
    if col not in string_cols:
        df_all[col] = pd.to_numeric(df_all[col], errors="coerce").astype("Int64")
        
state_map = {
    "AL": "Alabama",
    "AK": "Alaska",
    "AZ": "Arizona",
    "AR": "Arkansas",
    "CA": "California",
    "CO": "Colorado",
    "CT": "Connecticut",
    "DE": "Delaware",
    "DC": "District of Columbia",
    "FL": "Florida",
    "GA": "Georgia",
    "HI": "Hawaii",
    "ID": "Idaho",
    "IL": "Illinois",
    "IN": "Indiana",
    "IA": "Iowa",
    "KS": "Kansas",
    "KY": "Kentucky",
    "LA": "Louisiana",
    "ME": "Maine",
    "MD": "Maryland",
    "MA": "Massachusetts",
    "MI": "Michigan",
    "MN": "Minnesota",
    "MS": "Mississippi",
    "MO": "Missouri",
    "MT": "Montana",
    "NE": "Nebraska",
    "NV": "Nevada",
    "NH": "New Hampshire",
    "NJ": "New Jersey",
    "NM": "New Mexico",
    "NY": "New York",
    "NC": "North Carolina",
    "ND": "North Dakota",
    "OH": "Ohio",
    "OK": "Oklahoma",
    "OR": "Oregon",
    "PA": "Pennsylvania",
    "RI": "Rhode Island",
    "SC": "South Carolina",
    "SD": "South Dakota",
    "TN": "Tennessee",
    "TX": "Texas",
    "UT": "Utah",
    "VT": "Vermont",
    "VA": "Virginia",
    "WA": "Washington",
    "WV": "West Virginia",
    "WI": "Wisconsin",
    "WY": "Wyoming",
}

df_all["State"] = df_all["State_abrv"].map(state_map)
df_all.drop(columns=["State_abrv"], inplace=True)

df_all.head()
#%%

#Instruction Saving to Postgres
# from sqlalchemy import create_engine

# # Replace with your actual Postgres password
# password = "yourPostgresPassword"

# engine = create_engine(
#     f"postgresql+psycopg2://postgres:{password}@localhost:5432/yourdataschema"
# )


# df_all.to_sql(
#     name="heatwave_d104",
#     con=engine,
#     schema="cdc",         
#     if_exists="replace",
#     index=False
# )
#print("Table heatwave_d104 written to PostgreSQL.")
# %%
#### SAving to sql lite for shiny app
import sqlite3

# 1. Create / open a SQLite database file
# This will create "cdc_heatwave.db" in your current working directory
conn = sqlite3.connect("cdc_heatwave.db")

# 2. Write your DataFrame to a table in that file
df_all.to_sql(
    name="heatwave_d104",   # table name inside the SQLite DB
    con=conn,
    if_exists="replace",    # replace table if it already exists
    index=False
)

# 3. Close the connection
conn.close()

print("Saved df_all to cdc_heatwave.db (table: heatwave_d104)")

# %%
