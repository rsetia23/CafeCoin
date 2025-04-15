import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

st.title(f"Welcome Andrew Patten, CafeCoin Shop Owner.")
st.write("")
st.write("")
st.write("### What would you like to do today?")

if st.button("Edit Menu (Add / Update / Delete Items)",
             type='primary',
             use_container_width=True):
    st.switch_page("pages/15_Edit_Menu.py")

if st.button("View Subscribers",
             type='primary',
             use_container_width=True):
    st.switch_page("pages/16_View_Subscribers.py")

if st.button("Reward Item Performance",
             type='primary',
             use_container_width=True):
    st.switch_page("pages/17_Reward_Performance.py")


