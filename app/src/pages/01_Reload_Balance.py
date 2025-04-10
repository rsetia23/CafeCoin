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

# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()

# set the header of the page
st.header('Reload CafeCoin Account Balance')

# Access the session state to greet the customer
st.write(f"### Hi, {st.session_state['first_name']}.")

st.write('How much money would you like to load into your CafeCoin account? Remember, in-store purchases made with account balances earn double Coins!')

standard_denoms = [1, 5, 10, 20]

selected_denom = 0

for denom in standard_denoms:
    if st.checkbox(f'${denom}'):
        selected_denom+=denom

entered_amount = st.number_input('Or, enter a custom amount:', step = 0.01)

if selected_denom > 0:
    total = selected_denom
elif entered_amount:
    total = entered_amount
else:
    total = 0

st.write('Please select which of your cards on file to use for this transaction from the dropdown below.')
try:
    card_data = requests.get(f"http://api:4000/c/balanceupdate/{st.session_state['userID']}").json()
except:
    st.write('Could not load cards.')

if card_data:
    card_options = {card['CardNumber'] : card['MethodID'] for card in card_data}

    selected_card = st.selectbox('Choose one of your cards on file:', options = list(card_options.keys()))
else:
    st.write('No cards on file')

st.write(f'You are adding ${total} to your CafeCoin account balance using your card with the number {selected_card}.')

if st.button('Confirm purchase'):
    st.write(f'Thank you for your order! ${total} added to account.')
elif st.button('Cancel purchase'):
    st.write('Transaction canceled.')
    
  #  if card_data:
   #    card_options = {}
    #   for card in card_data:
     #      card_options[card['CardNumber'] : card['MethodID']]
        
      #  selected_card = st.selectbox("Choose one of your cards on file:", options=list(card_options.keys()))
       

   
   
   #countries:pd.DataFrame = wb.get_countries()
   
    #st.dataframe(countries)

# the with statment shows the code for this block above it 
# with st.echo(code_location='above'):
#     arr = np.random.normal(1, 1, size=100)
#     test_plot, ax = plt.subplots()
#     ax.hist(arr, bins=20)

#     st.pyplot(test_plot)


# with st.echo(code_location='above'):
#     slim_countries = countries[countries['incomeLevel'] != 'Aggregates']
#     data_crosstab = pd.crosstab(slim_countries['region'], 
#                                 slim_countries['incomeLevel'],  
#                                 margins = False) 
#     st.table(data_crosstab)
