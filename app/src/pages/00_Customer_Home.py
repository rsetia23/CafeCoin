import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout = 'wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

st.title(f"Welcome CafeCoin Customer, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

if st.button('View Account Details and Order Data', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/02_cust_data_dashboard.py')

if st.button('Reload CafeCoin Account Balance', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/01_Reload_Balance.py')

if st.button('Find a CafeCoin Shop Near Me', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/02_Map_Demo.py')