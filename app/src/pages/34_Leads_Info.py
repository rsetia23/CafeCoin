import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks
import pandas as pd
import matplotlib.pyplot as plt

SideBarLinks()

st.write("# Viewing Store Leads")

url = "http://web-api:4000/a/leadsinfo"

# obtain the data
try:
    response = requests.get(url)
    if response.status_code == 200:
        leads = response.json()
        if leads:
            st.dataframe(leads)
            df_leads = pd.DataFrame(leads)
        else:
            st.info("No leads found.")
    else:
        st.error(f"API Error: {response.status_code}")
except requests.exceptions.RequestException as e:
    st.error(f"Request failed: {e}")

# plot the graph
if "df_leads" in locals() and not df_leads.empty:
    state_counts = df_leads["State"].value_counts()

    fig, ax = plt.subplots(figsize=(8, 6))
    
    state_counts.plot(kind='bar', color='skyblue', ax=ax)
    ax.set_xlabel('State')
    ax.set_ylabel('Number of Leads')
    ax.set_title('Number of Leads per State')
    ax.set_xticklabels(ax.get_xticklabels(), rotation=90)
    
    
    st.pyplot(fig)
