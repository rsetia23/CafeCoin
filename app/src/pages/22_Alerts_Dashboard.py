import streamlit as st
import requests
import pandas as pd
import time

st.set_page_config(page_title="Alerts Dashboard", page_icon="📢")
st.title("📢 Alerts Admin Panel")

audience_filter = st.selectbox(
    "Select Alert Audience",
    ["All Users", "Customers", "Merchants", "Staff"],
    index=0
)

try:
    url = f"http://web-api:4000/admin/alerts/{audience_filter}"
    res = requests.get(url)
    res.raise_for_status()
    data = res.json()
except Exception as e:
    st.error(f"❌ Could not load alerts: {e}")
    st.stop()

if not data:
    st.info("No alerts found for this audience.")
else:
    df = pd.DataFrame(data)
    df["SentAt"] = pd.to_datetime(df["SentAt"]).dt.strftime("%Y-%m-%d %H:%M")

    st.subheader("🔔 Alerts")
    st.dataframe(
        df[["Title", "Message", "SentAt", "Status", "Priority"]],
        use_container_width=True,
        hide_index=True
    )

st.markdown("---")
st.subheader("🆕 Create New Alert")

with st.form("create_alert_form"):
    title = st.text_input("Alert Title")
    message = st.text_area("Alert Message")
    new_audience = st.selectbox("Target Audience", ["All Users", "Customers", "Merchants", "Staff"])
    priority = st.selectbox("Priority", ["Low", "Medium", "High"])
    status = st.selectbox("Status", ["Draft", "Sent"])
    emp_id = st.number_input("Created By (Employee ID)", min_value=1, step=1)

    send_alert = st.form_submit_button("📤 Send Alert")

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
            post_res = requests.post("http://web-api:4000/admin/alerts", json=payload)
            if post_res.status_code == 200:
                st.success("✅ Alert sent successfully!")
                time.sleep(2)
                st.rerun()
            else:
                st.error(f"Failed to send alert: {post_res.status_code}")
        except Exception as e:
            st.error(f"Request failed: {e}")
