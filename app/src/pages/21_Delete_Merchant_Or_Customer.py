import logging
logger = logging.getLogger(__name__)
import streamlit as st
from modules.nav import SideBarLinks
import requests

st.set_page_config(layout = 'wide')

SideBarLinks()

st.title('Delete a Merchant/Customer')

resource_type = st.selectbox(
    'Select type you want to delete',
    ('Customer', 'Merchant')
)
resource_slug = resource_type.lower() 

# fetch relevant list
try:
    fetch_url = f"http://web-api:4000/admin/{resource_slug}s"
    response = requests.get(fetch_url)
    response.raise_for_status()
    data = response.json()

    if not data:
        st.write(f"No {resource_type}s available to delete.")
        st.stop()

except Exception as e:
    st.write(f"Error fetching {resource_type}s: {e}")
    st.stop()

name_key = "Name"
id_key = f"{resource_type}ID"
name_to_id = {item[name_key]: item[id_key] for item in data}

selected_name = st.selectbox(f"Choose {resource_type} to Deprecate", list(name_to_id.keys()))

if st.button(f"Delete {resource_type} ❌"):
    item_id = name_to_id[selected_name]
    try:
        put_url = f"http://web-api:4000/admin/deprecate/{resource_slug}/{item_id}"
        put_res = requests.put(put_url)
        if put_res.status_code == 200:
            st.success(f"{resource_type} '{selected_name}' was successfully marked inactive ✅")
        elif put_res.status_code == 404:
            st.warning(f"{resource_type} not found.")
        else:
            st.error(f"Failed to deprecate. Status: {put_res.status_code}")
    except Exception as err:
        st.error(f"⚠️ Error: {err}")