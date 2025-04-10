import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks
import requests

st.set_page_config(layout = 'wide')

SideBarLinks()

st.title('Admin Home')

if st.button('Delete a Merchant/Customer', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/21_Delete_Merchant_Or_Customer.py')

if st.button('Alerts Dashboard',
             type='primary',
             use_container_width=True):
  st.switch_page('pages/22_Alerts_Dashboard.py')

if st.button('Complaints Dashboard',
             type='primary',
             use_container_width=True):
  st.switch_page('pages/23_Complaints_Dashboard.py')
