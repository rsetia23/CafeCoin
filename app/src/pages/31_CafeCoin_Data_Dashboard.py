import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks
import pandas as pd
import matplotlib.pyplot as plt

SideBarLinks()

st.write("# Viewing All Transaction and Order Details")

"""
Transaction Data
"""
# API endpoint
url = f"http://web-api:4000/a/transactions"

try:
    response = requests.get(url)
    if response.status_code == 200:
        transactions = response.json()
        if transactions:
            st.dataframe(transactions)
            df_transactions = pd.DataFrame(transactions)
        else:
            st.info("No subscribers found.")
    else:
        st.error(f"API Error: {response.status_code}")
except requests.exceptions.RequestException as e:
    st.error(f"Request failed: {e}")

"""
Order Details
"""
# API endpoint
url = f"http://web-api:4000/a/orderdetails"

try:
    response = requests.get(url)
    if response.status_code == 200:
        orderdetails = response.json()
        if orderdetails:
            st.dataframe(orderdetails)
            df_order_details = pd.DataFrame(orderdetails)
        else:
            st.info("No subscribers found.")
    else:
        st.error(f"API Error: {response.status_code}")
except requests.exceptions.RequestException as e:
    st.error(f"Request failed: {e}")

if "df_transactions" in locals() and not df_transactions.empty:
    # Prepare data for the bar chart.
    # Convert TransactionDate to datetime and AmountPaid to numeric.
    df_transactions['TransactionDate'] = pd.to_datetime(df_transactions['TransactionDate'])
    df_transactions['AmountPaid'] = pd.to_numeric(df_transactions['AmountPaid'], errors='coerce')
    # Create a new column with only the date part.
    df_transactions['Date'] = df_transactions['TransactionDate'].dt.date
    # Group by Date and sum the total AmountPaid for each day.
    grouped_amount = df_transactions.groupby('Date')['AmountPaid'].sum()

    # Prepare data for the pie chart.
    # Assuming 'CustomerID' identifies each unique customer.
    customer_by_payment_method = df_transactions.groupby('PaymentMethod')['CustomerID'].nunique()

    # Create the bar chart figure.
    fig_bar, ax_bar = plt.subplots(figsize=(8, 6))
    grouped_amount.plot(kind='bar', ax=ax_bar, color='skyblue')
    ax_bar.set_xlabel('Date')
    ax_bar.set_ylabel('Total Amount Paid')
    ax_bar.set_title('Total Amount Paid by Date')
    ax_bar.set_xticklabels(ax_bar.get_xticklabels(), rotation=45, ha='right')
    plt.tight_layout()

    # Create the pie chart figure.
    fig_pie, ax_pie = plt.subplots(figsize=(6, 6))
    ax_pie.pie(
        customer_by_payment_method, 
        labels=customer_by_payment_method.index, 
        autopct='%1.1f%%', 
        startangle=90
    )
    ax_pie.axis('equal')  # Ensure pie is drawn as a circle.
    ax_pie.set_title('Customer Distribution by Payment Method')

    # Display the graphs side by side using st.columns
    col1, col2 = st.columns(2)
    with col1:
        st.pyplot(fig_bar)
    with col2:
        st.pyplot(fig_pie)
else:
    st.info("No transaction data available for plotting.")