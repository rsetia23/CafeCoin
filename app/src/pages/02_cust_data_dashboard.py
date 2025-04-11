import logging
logger = logging.getLogger(__name__)
import pandas as pd
import streamlit as st
from streamlit_extras.app_logo import add_logo
import world_bank_data as wb
import matplotlib.pyplot as plt
import numpy as np
import plotly.express as px
from modules.nav import SideBarLinks
import requests
from streamlit_extras.stylable_container import stylable_container

# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()

# set the header of the page
st.header('CafeCoin Customer Dashboard')

# Access the session state to greet the customer
st.write(f"### Hi, {st.session_state['first_name']}.")

# grab account and transaction data
json_raw = requests.get(f"http://api:4000/c/summary/{st.session_state['userID']}").json()

# build separate pd dataframes with account details and transaction data
df_acct_deets = pd.DataFrame(json_raw[0])
df_order_deets = pd.DataFrame(json_raw[1])

# clean datetime string for order dates
df_order_deets['TransactionDate'] = pd.to_datetime(df_order_deets['TransactionDate'])

st.table(df_acct_deets)
st.table(df_order_deets)