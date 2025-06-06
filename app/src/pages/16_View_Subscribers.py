import streamlit as st
import requests
from modules.nav import SideBarLinks
import pandas as pd

st.set_page_config(layout='wide')
SideBarLinks()

#Make default Merchant (Andrew Patten) number 1
st.title("View Subscribers")
merchant_id = 1

url = f"http://web-api:4000/m/merchants/{merchant_id}/subscribers"

#Text box to filter
query = st.text_input("Filter by name, email, etc.")

#Retrieve subscriber list
try:
    response = requests.get(url)
    if response.status_code == 200:
        subscribers = response.json()
        if subscribers:
            df = pd.DataFrame(subscribers)
            #Check if a query is entered in the text box
            if query:
                query = query.lower()
                df = df[df.apply(lambda row: row.astype(str).str.lower().str.contains(query).any(), axis=1)]
            #Display the results
            st.dataframe(df)
        else:
            st.info("No subscribers found.")
    else:
        st.error(f"API Error: {response.status_code}")
except requests.exceptions.RequestException as e:
    st.error(f"Request failed: {e}")
