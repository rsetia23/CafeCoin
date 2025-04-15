import logging
logger = logging.getLogger(__name__)
import streamlit as st
from modules.nav import SideBarLinks
import requests

st.title('Manage Merchants & Customers')
SideBarLinks()

resource_type = st.selectbox(
    'Select type to manage:',
    ('Customer', 'Merchant')
)
resource_slug = resource_type.lower()

try:
    fetch_url = f"http://api:4000/admin/{resource_slug}s"
    response = requests.get(fetch_url)
    response.raise_for_status()
    data = response.json()

    if not data:
        st.warning(f"No {resource_type}s available.")
        st.stop()

except Exception as e:
    st.error(f"Error fetching {resource_type}s: {e}")
    st.stop()

name_key = "Name"
id_key = f"{resource_type}ID"
name_to_id = {item[name_key]: item[id_key] for item in data}

selected_name = st.selectbox(f"Choose {resource_type} to manage:", list(name_to_id.keys()))
item_id = name_to_id[selected_name]

col1, col2 = st.columns(2)

with col1:
    if st.button(f"Mark {resource_type} as Inactive"):
        try:
            put_url = f"http://api:4000/admin/deprecate/{resource_slug}/{item_id}"
            res = requests.put(put_url)
            if res.status_code == 200:
                st.success(f"{resource_type} '{selected_name}' marked as inactive")
            elif res.status_code == 404:
                st.warning(f"{resource_type} not found.")
            else:
                st.error(f"Failed to deprecate. Status: {res.status_code}")
        except Exception as err:
            st.error(f"Error: {err}")

with col2:
    if st.button(f"DELETE {resource_type} from System"):
        try:
            delete_url = f"http://api:4000/admin/delete/{resource_slug}/{item_id}"
            res = requests.delete(delete_url)
            if res.status_code == 200:
                st.success(f"{resource_type} '{selected_name}' deleted permanently")
            elif res.status_code == 404:
                st.warning(f"{resource_type} not found.")
            else:
                st.error(f"Failed to delete. Status: {res.status_code}")
        except Exception as err:
            st.error(f"Error: {err}")
