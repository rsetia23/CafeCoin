import streamlit as st
import requests
from modules.nav import SideBarLinks
import datetime

st.set_page_config(layout='wide')
SideBarLinks()

st.title("Store Comparison Selector")

API_HISTORY = "http://web-api:4000/an/transactions"

# grabbing the history of the stores so I can access the drop down when I choose comparison stores
try:
    response = requests.get(f"{API_HISTORY}")
    if response.status_code == 200:
        transaction_history = response.json()

        if not transaction_history:
            st.warning("No transaction history found.")
        else:
            store_map = {
                f"{merchant['MerchantName']} (Merchant #{merchant['MerchantID']})": merchant["MerchantID"]
                for merchant in transaction_history
}
            # adding the button to get the first merchant
            merchant1_choice = st.selectbox(
                "Select the first merchant to view performance:",
                list(store_map.keys()),
                key="merchant1_select"
            )
            store1_id = store_map[merchant1_choice]
            store1_name = merchant1_choice.split(" (")[0]

            # adding the button to get the second merchant
            merchant2_choice = st.selectbox(
                "Select the second merchant to view performance:",
                list(store_map.keys()),
                key="merchant2_select"
            )
            store2_id = store_map[merchant2_choice]
            store2_name = merchant2_choice.split(" (")[0]

            # moving pages to get the data for the two stores
            if st.button('Compare Stores', 
             type='primary',
             use_container_width=True):
                st.session_state["store1_id"] = store1_id
                st.session_state["store2_id"] = store2_id
                st.session_state["store1_name"] = store1_name
                st.session_state["store2_name"] = store2_name
                st.switch_page('pages/33_Store_Comparison_Data.py')
            
    else:
        st.error(f"Error fetching store history: {response.status_code}")

except requests.exceptions.RequestException as e:
    st.error(f"Failed to fetch store history: {e}")
