import streamlit as st
import pandas as pd
import requests
from modules.nav import SideBarLinks

st.set_page_config(page_title="Complaint Dashboard")
st.title("Complaint Ticket Dashboard")

SideBarLinks()

# Fetch complaints
try:
    res = requests.get("http://api:4000/admin/complaints")
    res.raise_for_status()
    complaints = res.json()
except Exception as e:
    st.error(f"Error loading complaints: {e}")
    st.stop()

if not complaints:
    st.info("No complaints found.")
else:
    df = pd.DataFrame(complaints)

    df["CreatedAt"] = pd.to_datetime(df["CreatedAt"], errors="coerce").dt.strftime("%Y-%m-%d %H:%M")

    priority_order = ["Critical", "Urgent", "High", "Medium", "Low"]
    df["PriorityRank"] = df["Priority"].apply(lambda p: priority_order.index(p) if p in priority_order else 999)

    open_df = df[df["Status"] != "Resolved"].sort_values("PriorityRank")

    st.subheader("Open Complaints")
    for _, row in open_df.iterrows():
        with st.expander(f"#{row.TicketID} | {row.Category} | {row.Priority}"):
            # Inline customer email fetch
            try:
                email_resp = requests.get(f"http://api:4000/admin/customers/{row.CustomerID}/email")
                if email_resp.status_code == 200:
                    email = email_resp.json().get("Email")
                else:
                    email = "N/A"
            except Exception:
                email = "N/A"

            st.markdown(f"**Customer ID:** {row.CustomerID}")
            st.markdown(f"**Customer Email:** {email}")
            st.markdown(f"**Assigned To (Employee ID):** {row.AssignedToEmployeeID}")
            st.markdown(f"**Created:** {row.CreatedAt}")
            st.markdown(f"**Status:** {row.Status}")
            st.markdown(f"**Description:** {row.Description}")

            if st.button(f"Mark Ticket #{row.TicketID} as Resolved", key=row.TicketID):
                try:
                    resp = requests.put(f"http://api:4000/admin/complaints/{row.TicketID}/resolve")
                    if resp.status_code == 200:
                        st.success(f"Ticket #{row.TicketID} resolved!")
                        st.rerun()
                    else:
                        st.error("Failed to resolve ticket.")
                except Exception as e:
                    st.error(f"Error: {e}")
