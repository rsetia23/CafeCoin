import logging
logger = logging.getLogger(__name__)
import streamlit as st
from streamlit_extras.app_logo import add_logo
import pandas as pd
import pydeck as pdk
from urllib.error import URLError
from modules.nav import SideBarLinks
import requests

SideBarLinks()

# add the logo
add_logo("assets/logo.png", height=400)

# set up the page
st.header("Map of All CafeCoin Collective Member Stores")
st.write(" ")
st.write(f"### Hi, {st.session_state['first_name']}. Use the checkbox at left to view all CafeCoin locations, or our tailored recs just for you!")

# grab store data and store recs for customer (based on which stores match all amenity preferences)
all_stores_data = requests.get(f"http://api:4000/c/stores").json()
customer_recs_data = requests.get(f"http://api:4000/c/storerecs/{st.session_state['userID']}").json()

# build helper function to clean data
def clean_lat_lon(json_data):
    """renames lat and lon columns for use with pydeck and changes them to float types
    Args:
        json_data = some json data with Lat and Lon keys
    Returns:
        clean_df = pd dataframe with columns renamed and types updated
    """
    # store response as dataframe
    lat_lon_df = pd.DataFrame(json_data)
    
    # rename columns for compatability with pydeck_chart
    lat_lon_df = lat_lon_df.rename(columns = {'Lat': 'lat', 'Lon': 'lon'})

    # cast lat and lon to floats (returned as string types for some reason)
    lat_lon_df['lat'] = lat_lon_df['lat'].astype(float)
    lat_lon_df['lon'] = lat_lon_df['lon'].astype(float)

    return lat_lon_df

# generate cleaned dataframes from response
all_stores = clean_lat_lon(all_stores_data)
rec_stores = clean_lat_lon(customer_recs_data)

# build webpage
# construct pydeck layers
all_layers = { 
                # layer that includes dots for all stores
                "All stores": pdk.Layer(
                "ScatterplotLayer",
                data = all_stores,
                get_position = ["lon", "lat"],
                get_color = [200, 30, 0, 160],
                get_radius = 200,
                pickable = True), 
                
                # layer that only includes dots for stores matching all customer amenity preferences
                "For you: stores matching all your saved amenity preferences (blue)": pdk.Layer(
                "ScatterplotLayer", 
                data = rec_stores,
                get_position = ["lon", "lat"],
                get_color = [0, 0, 255, 160],
                get_radius = 200,
                pickable = True)}

# construct check boxes in sidebar so user can decide what to see
st.sidebar.markdown("### Map Layers")
selected_layers = [
    layer
    for layer_name, layer in all_layers.items()
    if st.sidebar.checkbox(layer_name, True)
]

# render pydeck_chart with selected layers, centered on Boston
if selected_layers:
    st.pydeck_chart(
        pdk.Deck(
            map_style=None,
            initial_view_state={
                "latitude": 42.37,
                "longitude": -71.1,
                "zoom": 11,
                "pitch": 50,
            },
            layers=selected_layers,

            # adds hover data on the store pulled from API
            tooltip={"text": "{MerchantName} \n {StreetAddress}, \n {City}, {State} {ZipCode} \n Visit online at {Website} \n Slogan: '{OwnerComment}'"},))
else:
    st.error("Please choose at least one layer above.")

# label search bar
st.write("Or, search for stores by city, state, zip code and view their features in an easy-to-read table!")

# create a set of radio buttons to define the search method
search_by = st.radio("Choose a way to search:", 
         ["City, State (two letter abbr)", "State (two letter abbr)", "Zip", "Store Name"], index = None)

# produce a text box to take user input
search_term = st.text_input(label = "Enter your search term")

# initiate "search" (data filtering) on button press
search = st.button(label = "Go")

# build search logic; first check if a search term has been entered
if search_term:
    # next check if the user has confirmed their search
    if search:
        # next check if the user defined a way to search 
        if search_by:
            # filter the data based on their response, handling case mismatches with .lower() and trailing whitespace with .strip()
            if search_by == "City, State (two letter abbr)":
                search_term = search_term.split(", ")
                relevant_stores = all_stores[(all_stores['City'].str.lower() == search_term[0].lower().strip()) & (all_stores['State'].str.lower() == search_term[1].lower().strip())]

            elif search_by == "State (two letter abbr)":
                relevant_stores = all_stores[all_stores['State'].str.lower() == search_term.lower().strip()]

            elif search_by == "Zip":
                relevant_stores = all_stores[all_stores['ZipCode'].str.lower() == search_term.lower().strip()]

            elif search_by == "Store Name": 
                relevant_stores = all_stores[all_stores['MerchantName'].str.lower() == search_term.lower().strip()]

            # check if the dataframe is empty, returning an error if so
            if relevant_stores.empty:
                st.error('No stores found. Please double check your search term and try again. Otherwise, we may not have a store in your area yet.')
            else:
                customer_info = relevant_stores.copy()

                # concatenate address features to make it more readable for the user
                customer_info['Suite'] = customer_info['Suite'].fillna('')
                customer_info['Address'] = customer_info['StreetAddress'] + " " + customer_info['Suite'] +", " + customer_info['City'] + ", " + customer_info['State'] + " " + customer_info['ZipCode']

                # change column names and reorder to improve readability
                customer_table = customer_info[['MerchantName', 'Address', 'Amenities', 'OwnerComment', 'Website']].rename(
                    columns = {'MerchantName': 'Store Name', 'OwnerComment': 'Slogan'})
                
                # print results as a dataframe for easy sorting/filtering for the user
                st.dataframe(customer_table, hide_index = True)
                
        # raise exception if the user forgot to select a search type
        else:
            st.error("Please select a way to search")