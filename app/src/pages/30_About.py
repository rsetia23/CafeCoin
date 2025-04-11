import streamlit as st
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

SideBarLinks()

st.write("# About this App")

st.markdown (
    """
    Welcome to Cafe Coin!

    We are a community-driven rewards platform built to connect local coffee shops with loyal customers. Through a shared digital coin system, customers earn and redeem rewards across participating cafes, while shop owners gain powerful tools to manage menus, track reward performance, and engage with their community.

    CafeCoin empowers small businesses, simplifies loyalty, and helps everyone start their day with a great cup of coffee.
    """
        )
