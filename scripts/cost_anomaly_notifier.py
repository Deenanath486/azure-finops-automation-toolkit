"""
Azure FinOps Cost Anomaly & Daily Budget Notifier
Monitors daily spending against threshold budgets and posts rich alert cards to Microsoft Teams / Slack.
"""

import os
import json
import urllib.request
from datetime import datetime

def send_teams_alert(webhook_url: str, current_spend: float, budget_threshold: float, currency: str = "USD"):
    percentage = (current_spend / budget_threshold) * 100
    color = "FF0000" if percentage > 100 else "FFA500"

    payload = {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": color,
        "summary": "Azure FinOps Cost Alert",
        "sections": [{
            "activityTitle": "⚠️ Azure FinOps Cost Alert",
            "activitySubtitle": f"Evaluated at {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}",
            "facts": [
                {"name": "Current Spend Today:", "value": f"{currency} {current_spend:.2f}"},
                {"name": "Budget Threshold:", "value": f"{currency} {budget_threshold:.2f}"},
                {"name": "Consumption Ratio:", "value": f"{percentage:.1f}%"},
                {"name": "Status:", "value": "BUDGET EXCEEDED" if percentage > 100 else "WARNING LEVEL"}
            ],
            "markdown": True
        }]
    }

    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(payload).encode('utf-8'),
        headers={'Content-Type': 'application/json'}
    )

    try:
        with urllib.request.urlopen(req) as response:
            print(f"[✓] Alert successfully posted to Teams/Slack (HTTP {response.getcode()})")
    except Exception as e:
        print(f"[!] Error posting alert: {e}")

if __name__ == '__main__':
    webhook = os.getenv("FINOPS_WEBHOOK_URL", "")
    spend = float(os.getenv("CURRENT_DAILY_SPEND", "145.50"))
    budget = float(os.getenv("DAILY_BUDGET_THRESHOLD", "100.00"))

    if webhook:
        send_teams_alert(webhook, spend, budget)
    else:
        print("FinOps Anomaly Notifier initialized. Set FINOPS_WEBHOOK_URL to send live alerts.")
