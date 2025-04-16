import streamlit as st
import requests
import pandas as pd
import time
from modules.nav import SideBarLinks

st.set_page_config(page_title="Alerts Dashboard")
st.title("Alerts Admin Panel")

SideBarLinks()

audience_options = [
    "All Users",
    "Customers",
    "New Users",
    "Loyalty Members",
    "Inactive Users",
    "Merchants",
    "Employees",
    "Admins",
    "Support Team.",
    "Beta Testers"
]

audience_filter = st.selectbox("Select Alert Audience", audience_options, index=0)

# Fetch alerts for selected audience
try:
    url = f"http://api:4000/ad/alerts/{audience_filter}"
    res = requests.get(url)
    res.raise_for_status()
    data = res.json()
except Exception as e:
    st.error(f"Could not load alerts: {e}")
    st.stop()

# Display alerts
if not data:
    st.info("No alerts found for this audience.")
else:
    df = pd.DataFrame(data)

    # Parse SentAt from RFC format safely
    df["SentAt"] = pd.to_datetime(
        df["SentAt"].astype(str).str.strip(),
        format="%a, %d %b %Y %H:%M:%S GMT",
        errors="coerce"
    )
    df["SentAt"] = df["SentAt"].dt.strftime("%Y-%m-%d %H:%M")
    df["SentAt"] = df["SentAt"].fillna("Not sent yet")

    st.subheader("Alerts")
    st.dataframe(
        df[["Title", "Message", "SentAt", "Status", "Priority"]],
        use_container_width=True,
        hide_index=True
    )

# Divider
st.markdown("---")

# Alert creation form
st.subheader("Create New Alert")

with st.form("create_alert_form"):
    title = st.text_input("Alert Title")
    message = st.text_area("Alert Message")
    new_audience = st.selectbox("Target Audience", audience_options)
    priority = st.selectbox("Priority", ["Low", "Medium", "High"])
    status = st.selectbox("Status", ["Draft", "Sent"])
    emp_id = st.number_input("Created By (Employee ID)", min_value=1, step=1)

    send_alert = st.form_submit_button("Send Alert")

    if send_alert:
        payload = {
            "CreatedByEmp": emp_id,
            "Title": title,
            "Message": message,
            "Audience": new_audience,
            "Status": status,
            "Priority": priority
        }

        try:
            post_res = requests.post("http://api:4000/ad/alerts", json=payload)
            if post_res.status_code == 200:
                st.success("Alert sent successfully!")
                time.sleep(2)
                st.rerun()
            else:
                st.error(f"Failed to send alert: {post_res.status_code}")
        except Exception as e:
            st.error(f"Request failed: {e}")
