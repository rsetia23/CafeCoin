import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()


st.title(f"Welcome CafeCoin Analyst, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

if st.button('View Full System Dashboard', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/31_CafeCoin_Data_Dashboard.py')

if st.button('Compare 2 Stores', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/32_Store_Comparison.py')

if st.button('Show Store Leads', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/02_Map_Demo.py')