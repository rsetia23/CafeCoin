import logging
logger = logging.getLogger(__name__)
import pandas as pd
import streamlit as st
from streamlit_extras.app_logo import add_logo
import world_bank_data as wb
import matplotlib.pyplot as plt
import numpy as np
import plotly.express as px
from modules.nav import SideBarLinks
import requests
from streamlit_extras.stylable_container import stylable_container

# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()

# set the header of the page
st.header('Reload CafeCoin Account Balance')

# Access the session state to greet the customer
st.write(f"### Hi, {st.session_state['first_name']}.")

st.write('How much money would you like to load into your CafeCoin account? Remember, in-store purchases made with account balances earn double Coins!')
st.text("")

# standard_denoms = [1, 5, 10, 20]

# selected_denom = 0

# # change this to radio button
# for denom in standard_denoms:
#     if st.checkbox(f'${denom}'):
#         selected_denom+=denom

selected_denom = st.radio(
    "Choose a preset amount (USD)",
    [1, 5, 10, 20],
    index=None,
)

entered_amount = st.number_input('Or, enter a custom amount:', step = 0.01)

if selected_denom:
    total = selected_denom
elif entered_amount:
    total = entered_amount
else:
    total = 0

st.text("")

st.write('Please select which of your cards on file to use for this transaction from the dropdown below.')
try:
    card_data = requests.get(f"http://api:4000/c/paymethods/{st.session_state['userID']}").json()
except:
    st.write('Could not load cards.')

if card_data:
    card_options = {card['CardNumber'] : card['MethodID'] for card in card_data}

    selected_card_number = st.selectbox('Choose one of your cards on file:', options = list(card_options.keys()))
    selected_card_id = card_options[selected_card_number]

    st.text_input(label = 'Input CVV/security code', value = None)

else:
    st.write('No cards on file')

st.text("")

st.write(f'You are adding ${total} to your CafeCoin account balance using your card with the number {selected_card_number}.')

# Create buttons with st.button
with stylable_container(
    "green",
    css_styles="""
    button {
        background-color: #00FF00;
    }""",
):
    confirm = st.button("Confirm purchase")

if confirm:
    body = {
        'CustomerID': st.session_state['userID'],
        'MerchantID': 1,
        'Date': None,
        'PaymentMethod': 'card',
        'CardUsed': selected_card_id,
        'TransactionType': 'online',
        'AmountPaid': total}
    
    transaction = requests.post("http://api:4000/c/balanceupdate", json=body)

    if transaction.status_code == 200:
        acct_balance = requests.put(f"http://api:4000/c/balanceupdate/{st.session_state['userID']}/{total}")

        st.success(f'Your next cup of java awaits! ${total} added to account.')