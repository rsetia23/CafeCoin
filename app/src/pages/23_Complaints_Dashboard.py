import streamlit as st
import pandas as pd
import requests

st.set_page_config(page_title="Complaint Dashboard", page_icon="🛠️")
st.title("🛠️ Complaint Ticket Dashboard")

try:
    res = requests.get("http://web-api:4000/admin/complaints")
    res.raise_for_status()
    complaints = res.json()
except Exception as e:
    st.error(f"Error loading complaints: {e}")
    st.stop()

if not complaints:
    st.info("No complaints found.")
else:
    df = pd.DataFrame(complaints)
    df["CreatedAt"] = pd.to_datetime(df["CreatedAt"]).dt.strftime("%Y-%m-%d %H:%M")
    open_df = df[df["Status"] != "Resolved"]

    st.subheader("🚨 Open Complaints")
    for i, row in open_df.iterrows():
        with st.expander(f"#{row.TicketID} | {row.Category} | {row.Priority}"):
            st.markdown(f"**Customer ID:** {row.CustomerID}")
            st.markdown(f"**Assigned To (Employee ID):** {row.AssignedToEmployeeID}")
            st.markdown(f"**Created:** {row.CreatedAt}")
            st.markdown(f"**Status:** {row.Status}")
            st.markdown(f"**Description:** {row.Description}")

            if st.button(f"✅ Mark Ticket #{row.TicketID} as Resolved", key=row.TicketID):
                try:
                    resp = requests.put(f"http://web-api:4000/admin/complaints/{row.TicketID}/resolve")
                    if resp.status_code == 200:
                        st.success(f"Ticket #{row.TicketID} resolved!")
                        st.rerun()
                    else:
                        st.error("Failed to resolve ticket.")
                except Exception as e:
                    st.error(f"Error: {e}")
