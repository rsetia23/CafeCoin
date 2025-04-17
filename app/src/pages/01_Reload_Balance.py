import logging
logger = logging.getLogger(__name__)
import streamlit as st
from modules.nav import SideBarLinks
import requests
from streamlit_extras.stylable_container import stylable_container

# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()

# build the webpage
# set the header of the page
st.header('Reload CafeCoin Account Balance')

# Access the session state to greet the customer, explain page functionality
st.write(f"### Hi, {st.session_state['first_name']}.")
st.write('How much money would you like to load into your CafeCoin account? Remember, in-store purchases made with account balances earn double Coins!')
st.text("")

# render radio buttons with preset denominations for the user to add to their account
selected_denom = st.radio(
    "Choose a preset amount (USD)",
    [1, 5, 10, 20],
    index=None,
)

# add an input field so the user can choose a custom amount
entered_amount = st.number_input('Or, enter a custom amount:', step = 0.01)

# check if the user chose a preset amount, then if not, what they entered in the custom amount box
if selected_denom:
    total = selected_denom
elif entered_amount:
    total = entered_amount
else:
    total = 0
st.text("")

# ask the user which card they'd like to use
st.write('Please select which of your cards on file to use for this transaction from the dropdown below.')

# fetch the user's card data, raising an error if they have no cards on file
try:
    card_data = requests.get(f"http://api:4000/c/customers/{st.session_state['userID']}/paymethods").json()
except:
    st.error('Could not load cards.')

# verify there is card data for the customer before rendering the rest of the page 
if card_data:
    # build a dict of the customer's card data (number and methodID) so we can display number (more intuitive for customer) and store ID (needed for DB)
    card_options = {card['CardNumber'] : card['MethodID'] for card in card_data}

    # allow the user to select from their card numbers on file, saving the method ID associated with whatever card they chose
    selected_card_number = st.selectbox('Choose one of your cards on file:', options = list(card_options.keys()))
    selected_card_id = card_options[selected_card_number]

    # build an input box for the customer's chosen card's CVV
    cvv = st.text_input(label = 'Input CVV/security code')
    st.text("")

    # notify the user of the specifics of their purchase
    if total > 0 and selected_card_number:
        st.write(f'You are adding ${total} to your CafeCoin account balance using your card with the number {selected_card_number}.')

    # Create green button with st.button for the user to confirm their purchase
    with stylable_container(
        "green",
        css_styles="""
        button {
            background-color: #00FF00;
        }""",
    ):
        confirm = st.button("Confirm purchase")

    # verify that the customer entered their CVV and confirmed their purchase
    if confirm and cvv:

        # build data body to post to transactions table (note: date defaults and some fields hard coded as transaction always with CafeCoin (MerchantID 3), using a card, done online)
        body = {
            'CustomerID': st.session_state['userID'],
            'MerchantID': 3,
            'Date': None,
            'PaymentMethod': 'card',
            'CardUsed': selected_card_id,
            'TransactionType': 'balancereload',
            'AmountPaid': total}
        
        # post transaction data
        transaction = requests.post("http://api:4000/c/transactions/balance", json=body)

        # if transaction posts successfully, update the user's account balance and alert them
        if transaction.status_code == 200:
            body2 = {
                'Amount': total}
            acct_balance = requests.put(f"http://api:4000/c/customers/{st.session_state['userID']}/balance", json = body2)
            st.success(f'Your next cup of java awaits! ${total} added to account.')

            reload_again = st.button("Add more to your balance now")
            if reload_again:
                st.switch_page('pages/01_Reload_Balance.py')

    # return an error if the customer forgot to input their CVV
    elif confirm and not cvv: 
        st.error("No CVV input detected.")

else:
    st.error('No cards on file')