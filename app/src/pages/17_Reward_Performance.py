import streamlit as st
import requests
from modules.nav import SideBarLinks
import datetime

st.set_page_config(layout='wide')
SideBarLinks()

st.title("View Reward Item Performance")
#Set default merchant for this page to Merchant 1 (Andrew Patten)
MERCHANT_ID = 1

#Get reward history
try:
    response = requests.get(f"http://web-api:4000/m/merchants/{MERCHANT_ID}/reward-items/history")
    if response.status_code == 200:
        reward_history = response.json()

        if not reward_history:
            st.warning("No reward item history found.")
        else:
            #item dropdown
            item_map = {
                f"{item['ItemName']} (Reward #{item['RewardID']})": item["RewardID"]
                for item in reward_history
            }
            item_choice = st.selectbox("Select a reward item to view performance:", list(item_map.keys()))
            reward_id = item_map[item_choice]

            # Date range inputs
            col1, col2 = st.columns(2)
            with col1:
                start_date = st.date_input("Start Date", datetime.date(2024, 1, 1))
            with col2:
                end_date = st.date_input("End Date", datetime.date.today())

            # Get the stats
            if st.button("Get Reward Item Stats"):
                params = {
                    "item_id": reward_id,
                    "start_date": start_date.strftime("%Y-%m-%d"),
                    "end_date": end_date.strftime("%Y-%m-%d")
                }

                try:
                    stats_response = requests.get("http://web-api:4000/m/merchants/reward-items/orderdetails", params=params)
                    if stats_response.status_code == 200:
                        stats = stats_response.json()
                        st.success("Reward item stats loaded!")

                        #Display metrics
                        col1, col2, col3 = st.columns(3)
                        col1.metric("Total Orders", stats.get("TotalOrders", 0))
                        col2.metric("Total Revenue", f"${float(stats.get('TotalRevenue', 0)):.2f}")
                        col3.metric("Average Price", f"${float(stats.get('AveragePrice', 0)):.2f}")
                    else:
                        st.error(f"Error fetching stats: {stats_response.status_code}")
                except requests.exceptions.RequestException as e:
                    st.error(f"Failed to fetch reward stats: {e}")
    else:
        st.error(f"Error fetching reward history: {response.status_code}")

except requests.exceptions.RequestException as e:
    st.error(f"Failed to fetch reward history: {e}")
