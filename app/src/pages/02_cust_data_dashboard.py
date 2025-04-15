import logging
logger = logging.getLogger(__name__)
import pandas as pd
import streamlit as st
import plotly.express as px
from modules.nav import SideBarLinks
import requests
from streamlit_extras.stylable_container import stylable_container
from dateutil.relativedelta import relativedelta

# Call the SideBarLinks from the nav module in the modules directory
SideBarLinks()

# grab account and transaction data
json_raw = requests.get(f"http://api:4000/c/summary/{st.session_state['userID']}").json()

# build separate pd dataframes with account details and transaction data
try: 
    df_acct_deets = pd.DataFrame(json_raw[0])
except: 
    st.error("Could not load account balance and Coin balance")

try: 
    df_order_deets = pd.DataFrame(json_raw[1])
except: 
    st.error("Could not load transaction history")
    df_order_deets = pd.DataFrame()

# for a user who has made at least 1 in-store transaction (excluding balance reloads, which don't contribute to stats):
if not df_order_deets.empty:
    # clean datetime string for order dates
    df_order_deets['TransactionDate'] = pd.to_datetime(df_order_deets['TransactionDate'])
    df_order_deets['ItemPrice'] = df_order_deets['ItemPrice'].astype(float)
    df_order_deets['Discount'] = df_order_deets['Discount'].astype(float)

    # calculate lifetime stats
    # total spending
    total_spend = df_order_deets['ItemPrice'].sum() - df_order_deets['Discount'].sum().round(2)
    rewards_redeemed = df_order_deets['RewardRedeemed'].sum()

    # group by orders for order summary stats
    net_spending = df_order_deets.groupby('OrderNum')[['ItemPrice', 'Discount']].sum()
    net_spending['NetSpend'] = net_spending['ItemPrice'] - net_spending['Discount']
    net_spending = net_spending.reset_index()

    # calculate order summary stats
    avg_order_spend = net_spending['NetSpend'].mean().round(2)
    largest_order = net_spending['NetSpend'].max().round(2)
    num_orders = len(net_spending['OrderNum'])
    total_savings = net_spending['Discount'].sum().round(2)

    # group by merchant and item to get number of unique shops visited and number of unique items ordered
    merchants_grouped = df_order_deets.groupby('MerchantName')
    num_merchants = merchants_grouped.ngroups

    items_grouped = df_order_deets.groupby('ItemNum')
    num_items = items_grouped.ngroups

    # isolating the month and year for grouping
    df_order_deets['transaction_month'] = df_order_deets['TransactionDate'].dt.strftime('%b %Y')

    # build trailing 12m viz (spending/month, avg order by month)
    # group by month/year
    months_grouped = df_order_deets.groupby('transaction_month')

    # calculate net spending
    monthly_orders = months_grouped[['ItemPrice', 'Discount']].sum().sort_values('transaction_month', ascending=False)
    monthly_orders['NetSpend'] = monthly_orders['ItemPrice'] - monthly_orders['Discount']

    # calculate number of orders
    num_orders_month = months_grouped['OrderNum'].nunique()
    monthly_orders['NumOrders'] = num_orders_month

    # calculate avg order size by month
    monthly_orders['ThisMonthAvgOrder'] = monthly_orders['NetSpend']/monthly_orders['NumOrders']

    # cast to dataframe for manipulation and plotting
    monthly_orders_df = monthly_orders.reset_index()

    # build a dataframe of most recent 12 months
    today = pd.to_datetime('today')
    months = [today - relativedelta(months = i) for i in range(12)]
    year_df = pd.DataFrame({'transaction_month': months})
    year_df['transaction_month'] = year_df['transaction_month'].dt.strftime('%b %Y')

    # add all time average order spend next to each month (for line plot)
    year_df['AllTimeAvgOrder'] = avg_order_spend


    # merge dataframes and sort to ensure all of most recent 12 months are reflected in spending data and data are ordered for plotting
    merged_year_spend = pd.merge(monthly_orders_df, year_df, on = 'transaction_month', how = 'right').fillna(0)
    merged_year_spend['transaction_month'] = pd.to_datetime(merged_year_spend['transaction_month'], format='%b %Y')
    merged_year_spend = merged_year_spend.sort_values('transaction_month')

    # build spending plot
    fig = px.bar(data_frame=merged_year_spend.head(12), x = 'transaction_month', y = 'NetSpend', title = 'Trailing 12 Months Net Cafe Spending/Month',
                labels = {'NetSpend': 'Dollars Spent', 'transaction_month': 'Month'})

    # build avg order plot
    fig2 = px.line(data_frame=merged_year_spend.head(12), x = 'transaction_month', y = merged_year_spend.columns[5:], title = 'Trailing 12 Months Avg Order Total/Month vs All Time',
                labels = {'value': 'Avg order total ($)', 'transaction_month': 'Month'})

    # build this month's favorites viz
    # filter the data to only include transactions from this month
    now = (pd.to_datetime('today')).strftime('%b %Y')
    df_this_month = df_order_deets[df_order_deets['transaction_month'] == now]

    # group by merchants and count distinct orders
    orders_per_merchant = df_this_month.groupby('MerchantName')['OrderNum'].nunique().reset_index()

    # build visit count plot
    fig3 = px.bar(data_frame = orders_per_merchant, x = 'MerchantName', y = 'OrderNum', title = f'Visits Per Store This Month ({now})',
                labels = {'MerchantName': 'Store Name', 'OrderNum': 'Number of Visits'})

    orders_per_item = df_this_month.groupby(['ItemNum', 'ItemName', 'MerchantName'])['OrderNum'].nunique().reset_index()

    fig4 = px.bar(data_frame=orders_per_item, x = 'ItemName', y = 'OrderNum', hover_data = ['ItemName', 'MerchantName'], title = f'Most Frequently Ordered Items This Month ({now})',
                labels = {'ItemNum': 'Item number (hover for name)', 'OrderNum': '# of your orders including this item'})


    # build the web page
    # set the header of the page
    st.header(f"{st.session_state['first_name']} {st.session_state['last_name']} Customer Dashboard")
    st.write(" ")
    st.write(f"### Your account balances are:")

    if not df_acct_deets.empty:
        # format coin balance and account balance as side-by-side columns
        col1, col2 = st.columns(2)
        with col1:
            coins = df_acct_deets.iloc[0,1]
            st.metric(label="🪙 Coin Balance", value = coins)

            # calculate how far the customer is from 200 Coins (hypothetical reward value)
            distance_to_reward = 200 - coins.astype(float)

            # tell the customer how far they are from a reward
            if distance_to_reward > 0: 
                st.write(f"{distance_to_reward} Coins until your next reward! Visit a CafeCoin Collective Member to get more Coins!")
                            # Create button to change tabs to reload cash balance

            # provide a button so the customer can find a store to use their accumulated coins if a reward is available
            elif distance_to_reward <= 0:
                st.write("Reward available! Visit a CafeCoin Collective Member to redeem your Coins!")

            with stylable_container(
                "green",
                css_styles="""
                button {
                    background-color: #00FF00;
                }""",
                ):
                find_store = st.button("Click to find a store")
                if find_store:
                    st.switch_page('pages/03_Map_w_Recs.py')
            

        with col2:
            st.metric(label="💰 Account Cash Balance", value=df_acct_deets.iloc[0,0])
            
            # Create button to change tabs to reload cash balance
            with stylable_container(
                "green1",
                css_styles="""
                button {
                    background-color: #00FF00;
                }""",
                ):
                confirm = st.button("Click to reload balance")
                if confirm:
                    st.switch_page('pages/01_Reload_Balance.py')

    st.write(" ")
    st.write('### Your lifetime stats are:')

    col3, col4 = st.columns(2)
    with col3: 
        st.metric(label = '🤑 Total Spending', value = f'${total_spend}')
        st.metric(label = '🤯 Most Expensive Order', value = f'${largest_order}')
        st.metric(label = '🤗 Number of Rewards Redeemed', value = rewards_redeemed)
        st.metric(label = '🏪 Number of Stores Visited', value = num_merchants)
                


    with col4:
        st.metric(label = '☕️ Average Order Spend', value = f'${avg_order_spend}')
        st.metric(label = '☝️ Total Orders', value = num_orders)
        st.metric(label = '😎 Total CafeCoin Rewards Savings', value = f'${-1*total_savings}')
        st.metric(label = '🤩 Number of Unique Items Ordered', value = num_items)
                

    st.write('### Your recent spending trends:')

    st.plotly_chart(fig)
    st.plotly_chart(fig2)
    st.plotly_chart(fig3)
    st.plotly_chart(fig4)

# for a user who has not made at least one in-store transaction:
else:
    # build the web page
    # set the header of the page
    st.header(f"{st.session_state['first_name']} {st.session_state['last_name']} Customer Dashboard")
    st.write(" ")
    st.write(f"### Your account balances are:")

    # format coin balance and account balance as side-by-side columns
    col1, col2 = st.columns(2)
    with col1:
        st.metric(label="🪙 Coin Balance", value=df_acct_deets.iloc[0,1])

    with col2:
        st.metric(label="💰 Account Cash Balance", value=df_acct_deets.iloc[0,0])
        
        # Create button to change tabs to reload cash balance
        with stylable_container(
            "green",
            css_styles="""
            button {
                background-color: #00FF00;
            }""",
            ):
            confirm = st.button("Reload balance now")
            if confirm:
                st.switch_page('pages/01_Reload_Balance.py')

    st.write(" ")
    # notify the customer they have no data on file
    st.write('### You have not made any orders yet. Visit our store locater to get caffeinated!')

    # provide a link to the store locator
    if st.button(label = 'Store locator'):
        st.switch_page('pages/03_Map_w_Recs.py')
