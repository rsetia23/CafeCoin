import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("Edit Menu")

API_BASE = "http://web-api:4000/m/merchants/menuitems"

#SHowing the menu items
st.subheader("Current Menu Items")

try:
    response = requests.get(API_BASE)
    if response.status_code == 200:
        menu_items = response.json()
        if menu_items:
            st.dataframe(menu_items)
        else:
            st.info("No menu items found.")
    else:
        st.error(f"Error fetching menu items: {response.status_code}")
except requests.exceptions.RequestException as e:
    st.error(f"Failed to fetch menu items: {e}")

#Add a new item
st.subheader("Add a New Menu Item")
with st.form("add_form"):
    add_name = st.text_input("Item Name")
    add_price = st.number_input("Price", min_value=0.0, format="%.2f")
    add_description = st.text_input("Description")
    add_type = st.text_input("Item Type")
    add_reward = st.checkbox("Is Reward Item?")
    add_submit = st.form_submit_button("Add Item")

    if add_submit:
        data = {
            "MerchantID": 1,
            "ItemName": add_name,
            "CurrentPrice": add_price,
            "Description": add_description,
            "ItemType": add_type,
            "IsRewardItem": add_reward,
            "IsActive": True
        }
        try:
            response = requests.post(API_BASE, json=data)
            if response.status_code == 201:
                st.success("Item added successfully!")
                st.rerun()
            else:
                st.error(f"Error: {response.json().get('error', 'Unknown error')}")
        except requests.exceptions.RequestException as e:
            st.error(f"Request failed: {e}")

#Update menu item
st.subheader("Update an Existing Item")
with st.form("update_form"):
    update_id = st.number_input("Item ID to Update", min_value=1, step=1)
    update_name = st.text_input("Updated Item Name")
    update_price = st.number_input("Updated Price", min_value=0.0, format="%.2f")
    update_description = st.text_input("Updated Description")
    update_type = st.text_input("Updated Item Type")
    update_reward = st.checkbox("Updated Reward Status")
    update_submit = st.form_submit_button("Update Item")

    if update_submit:
        update_url = f"{API_BASE}/{update_id}"
        data = {
            "ItemName": update_name,
            "CurrentPrice": update_price,
            "Description": update_description,
            "ItemType": update_type,
            "IsRewardItem": update_reward,
            "IsActive": True
        }
        try:
            response = requests.put(update_url, json=data)
            if response.status_code == 200:
                st.success("Item updated successfully!")
                st.rerun()
            else:
                st.error(f"Error: {response.json().get('error', 'Unknown error')}")
        except requests.exceptions.RequestException as e:
            st.error(f"Request failed: {e}")

#Delete menu item
st.subheader("Delete an Item")
with st.form("delete_form"):
    delete_id = st.number_input("Item ID to Delete", min_value=1, step=1)
    delete_submit = st.form_submit_button("Delete Item")

    if delete_submit:
        delete_url = f"{API_BASE}/{delete_id}"
        try:
            response = requests.delete(delete_url)
            if response.status_code == 200:
                st.success("Item deleted successfully!")
                st.rerun()
            else:
                st.error(f"Error: {response.json().get('error', 'Unknown error')}")
        except requests.exceptions.RequestException as e:
            st.error(f"Request failed: {e}")
