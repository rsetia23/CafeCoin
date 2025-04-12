import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

SideBarLinks()

store1_id = st.session_state.get("store1_id")
store2_id = st.session_state.get("store2_id")

st.write("# Viewing All Transaction and Order Details")

# Create two columns side by side
col1, col2 = st.columns(2)

with col1:
    st.markdown(f"## Merchant #{store1_id} Transaction Data")
    # API endpoint for Store 1 Transactions
    url = f"http://web-api:4000/a/transactions/{store1_id}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            transactions = response.json()
            if transactions:
                st.dataframe(transactions)
            else:
                st.info("No Transactions found.")
        else:
            st.error(f"API Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        st.error(f"Request failed: {e}")

    st.markdown("### Order Details")
    # API endpoint for Store 1 Order Details
    url = f"http://web-api:4000/a/orderdetails/{store1_id}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            orders = response.json()
            if orders:
                st.dataframe(orders)
            else:
                st.info("No Order Details found.")
        else:
            st.error(f"API Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        st.error(f"Request failed: {e}")

with col2:
    st.markdown(f"## Merchant #{store2_id} Transaction Data")
    # API endpoint for Store 2 Transactions
    url = f"http://web-api:4000/a/transactions/{store2_id}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            transactions = response.json()
            if transactions:
                st.dataframe(transactions)
            else:
                st.info("No Transactions found.")
        else:
            st.error(f"API Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        st.error(f"Request failed: {e}")

    st.markdown("### Order Details")
    # API endpoint for Store 2 Order Details
    url = f"http://web-api:4000/a/orderdetails/{store2_id}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            orders = response.json()
            if orders:
                st.dataframe(orders)
            else:
                st.info("No Order Details found.")
        else:
            st.error(f"API Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        st.error(f"Request failed: {e}")
