import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

SideBarLinks()

st.write("# Viewing Store Leads")

"""
Store Leads
"""
# API endpoint
url = f"http://web-api:4000/a/leadsinfo"

try:
    response = requests.get(url)
    if response.status_code == 200:
        transactions = response.json()
        if transactions:
            st.dataframe(transactions)
        else:
            st.info("No leads found.")
    else:
        st.error(f"API Error: {response.status_code}")
except requests.exceptions.RequestException as e:
    st.error(f"Request failed: {e}")
