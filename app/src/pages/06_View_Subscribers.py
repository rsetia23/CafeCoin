import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("View Subscribers")
merchant_id = 1

# API endpoint
url = f"http://web-api:4000/shop_owner/subscribers/{merchant_id}"

try:
    response = requests.get(url)
    if response.status_code == 200:
        subscribers = response.json()
        if subscribers:
            st.dataframe(subscribers)
        else:
            st.info("No subscribers found.")
    else:
        st.error(f"API Error: {response.status_code}")
except requests.exceptions.RequestException as e:
    st.error(f"Request failed: {e}")
