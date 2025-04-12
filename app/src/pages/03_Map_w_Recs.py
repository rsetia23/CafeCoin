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
                "For you: stores matching all your saved amenity preferences ": pdk.Layer(
                "ScatterplotLayer", 
                data = rec_stores,
                get_position = ["lon", "lat"],
                get_color = [200, 30, 0, 160],
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

st.write("Or, search for stores by city, state, zip code and view their features in an easy-to-read table!")

search_by = st.radio("Choose a way to search:", 
         ["City", "State", "Zip"], index = None)

search_term = st.text_input(label = "Enter your search term")

search = st.button(label = "Go")

if search_term:
    if search:
        if search_by:
            if search_by == "City":
                relevant_stores = all_stores[all_stores['City'] == search_term]
            elif search_by == "State":
                relevant_stores = all_stores[all_stores['State'] == search_term]
            elif search_by == "Zip":
                relevant_stores = all_stores[all_stores['ZipCode'] == search_term]

            st.table(relevant_stores)
        else:
            st.error("Please select a way to search")