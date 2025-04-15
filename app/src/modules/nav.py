# Idea borrowed from https://github.com/fsmosca/sample-streamlit-authenticator

# This file has function to add certain functionality to the left side bar of the app

import streamlit as st
import os
from pathlib import Path


#### ------------------------ General ------------------------
def HomeNav():
    st.sidebar.page_link("Home.py", label="Home", icon="🏠")


def AboutPageNav():
    st.sidebar.page_link("pages/40_About.py", label="About", icon="🧠")


#### ------------------------ Examples for Role of pol_strat_advisor ------------------------
def PolStratAdvHomeNav():
    st.sidebar.page_link(
        "pages/00_Customer_Home.py", label="Political Strategist Home", icon="👤"
    )


def WorldBankVizNav():
    st.sidebar.page_link(
        "pages/01_World_Bank_Viz.py", label="World Bank Visualization", icon="🏦"
    )


def MapDemoNav():
    st.sidebar.page_link("pages/02_Map_Demo.py", label="Map Demonstration", icon="🗺️")


## ------------------------ Examples for Role of usaid_worker ------------------------
def ApiTestNav():
    st.sidebar.page_link("pages/12_API_Test.py", label="Test the API", icon="🛜")


def PredictionNav():
    st.sidebar.page_link(
        "pages/11_Prediction.py", label="Regression Prediction", icon="📈"
    )


def ClassificationNav():
    st.sidebar.page_link(
        "pages/13_Classification.py", label="Classification Demo", icon="🌺"
    )



#### ------------------------ Customer Role ------------------------
def CustPageNav():
    st.sidebar.page_link("pages/00_Customer_Home.py", label="Customer Home", icon="🏠")

#### ------------------------ Store Owner Role ------------------------
def OwnerPageNav():
    st.sidebar.page_link("pages/14_Shop_Owner_Home.py", label="Shop Owner Home", icon="🏠")

#### ------------------------ Analyst Role ------------------------
def AnalystPageNav():
    st.sidebar.page_link("pages/30_Analyst_Home.py", label="Analyst Home", icon="🏠")

#### ------------------------ Admin Role ------------------------
def AdminPageNav():
    st.sidebar.page_link("pages/20_Admin_home.py", label="Admin Home", icon="🏠")



# --------------------------------Links Function -----------------------------------------------
def SideBarLinks(show_home=False):
    """
    This function handles adding links to the sidebar of the app based upon the logged-in user's role, which was put in the streamlit session_state object when logging in.
    """

    # add a logo to the sidebar always
   # st.sidebar.image("assets/logo.png", width=150)
    assets_dir = Path(__file__).parent.parent / "assets"
    logo_path = os.path.join(assets_dir, "logo.png")
    st.sidebar.image(logo_path, width=150)

    # If there is no logged in user, redirect to the Home (Landing) page
    if "authenticated" not in st.session_state:
        st.session_state.authenticated = False
        st.switch_page("Home.py")

    if show_home:
        # Show the Home page link (the landing page)
        HomeNav()

    # Show the other page navigators depending on the users' role.
    if st.session_state["authenticated"]:

        # Show Persona Home button
        if st.session_state["role"] == 'cafe_coin_customer':
            CustPageNav()

        if st.session_state["role"] == 'shop_owner':
            OwnerPageNav()

        if st.session_state["role"] == 'analyst':
            AnalystPageNav()

        if st.session_state["role"] == 'admin':
            AdminPageNav()

            

        

    # Always show the About page at the bottom of the list of links
    AboutPageNav()

    if st.session_state["authenticated"]:
        # Always show a logout button if there is a logged in user
        if st.sidebar.button("Logout"):
            del st.session_state["role"]
            del st.session_state["authenticated"]
            st.switch_page("Home.py")
