import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks
import pandas as pd
import matplotlib.pyplot as plt

SideBarLinks()

store1_id = st.session_state.get("store1_id")
store2_id = st.session_state.get("store2_id")
store1_name = st.session_state.get("store1_name")
store2_name = st.session_state.get("store2_name")

st.write("# Viewing All Transaction and Order Details")

col1, col2 = st.columns(2)
with col1:
    st.markdown(f"## {store1_name} Transaction Data")
    # API endpoint for Store 1 Transactions
    url = f"http://web-api:4000/a/transactions/{store1_id}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            transactions1 = response.json()
            if transactions1:
                # Display the transactions table with a fixed height
                st.dataframe(transactions1, height=400)
                # Convert transactions to a DataFrame for graphing
                df_store1 = pd.DataFrame(transactions1)
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
            orders1 = response.json()
            if orders1:
                st.dataframe(orders1, height = 400)
            else:
                st.info("No Order Details found.")
        else:
            st.error(f"API Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        st.error(f"Request failed: {e}")

    if 'df_store1' in locals() and not df_store1.empty:
        # Use the appropriate format string for abbreviated month names.
        df_store1['TransactionDate'] = pd.to_datetime(
            df_store1['TransactionDate'], format="%a, %d %b %Y %H:%M:%S GMT"
        )
        df_store1['AmountPaid'] = pd.to_numeric(df_store1['AmountPaid'], errors='coerce')
        df_store1['Date'] = df_store1['TransactionDate'].dt.date

        grouped_amount1 = df_store1.groupby('Date')['AmountPaid'].sum()
        fig1_bar, ax1_bar = plt.subplots(figsize=(6, 4))
        grouped_amount1.plot(kind='bar', ax=ax1_bar, color='skyblue')
        ax1_bar.set_xlabel('Date')
        ax1_bar.set_ylabel('Total Amount Paid')
        ax1_bar.set_title('Total Amount Paid by Date')
        ax1_bar.set_xticklabels(ax1_bar.get_xticklabels(), rotation=45, ha='right')
        plt.tight_layout()

        customers_by_payment1 = df_store1.groupby('PaymentMethod')['CustomerID'].nunique()
        fig1_pie, ax1_pie = plt.subplots(figsize=(4, 4))
        ax1_pie.pie(customers_by_payment1, labels=customers_by_payment1.index,
                    autopct='%1.1f%%', startangle=90)
        ax1_pie.axis('equal')
        ax1_pie.set_title('Cust. Dist. by Payment Method')

        st.write("#### Graphs for", store1_name)
        graph_cols1 = st.columns(2)
        with graph_cols1[0]:
            st.pyplot(fig1_bar)
        with graph_cols1[1]:
            st.pyplot(fig1_pie)
with col2:
    st.markdown(f"## {store2_name} Transaction Data")
    url = f"http://web-api:4000/a/transactions/{store2_id}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            transactions2 = response.json()
            if transactions2:
                st.dataframe(transactions2, height=400)
                df_store2 = pd.DataFrame(transactions2)
            else:
                st.info("No Transactions found.")
        else:
            st.error(f"API Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        st.error(f"Request failed: {e}")

    st.markdown("### Order Details")
    url = f"http://web-api:4000/a/orderdetails/{store2_id}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            orders2 = response.json()
            if orders2:
                st.dataframe(orders2, height = 400)
            else:
                st.info("No Order Details found.")
        else:
            st.error(f"API Error: {response.status_code}")
    except requests.exceptions.RequestException as e:
        st.error(f"Request failed: {e}")

    if 'df_store2' in locals() and not df_store2.empty:
        # Use the appropriate format string for abbreviated month names.
        df_store2['TransactionDate'] = pd.to_datetime(
            df_store2['TransactionDate'], format="%a, %d %b %Y %H:%M:%S GMT"
        )
        df_store2['AmountPaid'] = pd.to_numeric(df_store2['AmountPaid'], errors='coerce')
        df_store2['Date'] = df_store2['TransactionDate'].dt.date

        grouped_amount2 = df_store2.groupby('Date')['AmountPaid'].sum()
        fig2_bar, ax2_bar = plt.subplots(figsize=(6, 4))
        grouped_amount2.plot(kind='bar', ax=ax2_bar, color='skyblue')
        ax2_bar.set_xlabel('Date')
        ax2_bar.set_ylabel('Total Amount Paid')
        ax2_bar.set_title('Total Amount Paid by Date')
        ax2_bar.set_xticklabels(ax2_bar.get_xticklabels(), rotation=45, ha='right')
        plt.tight_layout()

        customers_by_payment2 = df_store2.groupby('PaymentMethod')['CustomerID'].nunique()
        fig2_pie, ax2_pie = plt.subplots(figsize=(4, 4))
        ax2_pie.pie(customers_by_payment2, labels=customers_by_payment2.index,
                    autopct='%1.1f%%', startangle=90)
        ax2_pie.axis('equal')
        ax2_pie.set_title('Cust. Dist. by Payment Method')

        st.write("#### Graphs for", store2_name)
        graph_cols2 = st.columns(2)
        with graph_cols2[0]:
            st.pyplot(fig2_bar)
        with graph_cols2[1]:
            st.pyplot(fig2_pie)
