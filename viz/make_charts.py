import os
import pandas as pd
import matplotlib.pyplot as plt

OUT = "outputs"
FIG = "reports/figures"
os.makedirs(FIG, exist_ok=True)

def save_fig(name):
    path = os.path.join(FIG, name)
    plt.tight_layout()
    plt.savefig(path, dpi=200)
    plt.close()
    print("saved:", path)

# 1) Monthly revenue trend
df = pd.read_csv(f"{OUT}/sales_trends/monthly_sales.csv")
df["month"] = pd.to_datetime(df["month"])
df = df.sort_values("month")
plt.figure()
plt.plot(df["month"], df["revenue"])
plt.title("Monthly Revenue")
plt.xlabel("Month")
plt.ylabel("Revenue")
save_fig("monthly_revenue.png")

# 2) Revenue by category
df = pd.read_csv(f"{OUT}/product_analysis/category_performance.csv")
df = df.sort_values("revenue", ascending=True)
plt.figure()
plt.barh(df["category_name"], df["revenue"])
plt.title("Revenue by Category")
plt.xlabel("Revenue")
save_fig("revenue_by_category.png")

# 3) Top customers
df = pd.read_csv(f"{OUT}/customer_analysis/top_10_customers.csv")
df = df.sort_values("total_revenue", ascending=True)
labels = df["company_name"] + " (" + df["country"] + ")"
plt.figure()
plt.barh(labels, df["total_revenue"])
plt.title("Top 10 Customers by Revenue")
plt.xlabel("Revenue")
save_fig("top_customers.png")

# 4) Customer segments
df = pd.read_csv(f"{OUT}/customer_analysis/customer_segments.csv")
df = df.sort_values("avg_spent", ascending=True)
plt.figure()
plt.barh(df["segment"], df["customers"])
plt.title("Customers by Segment")
plt.xlabel("Customer count")
save_fig("customer_segments.png")

# 5) Employee leaderboard
df = pd.read_csv(f"{OUT}/employee_performance/sales_by_employee.csv")
df = df.sort_values("revenue", ascending=True)
plt.figure()
plt.barh(df["employee"], df["revenue"])
plt.title("Revenue by Employee")
plt.xlabel("Revenue")
save_fig("revenue_by_employee.png")

# 6) Shipping performance
df = pd.read_csv(f"{OUT}/operational_metrics/shipping_performance.csv")
df = df.sort_values("avg_days_to_ship", ascending=True)
plt.figure()
plt.barh(df["ship_country"], df["avg_days_to_ship"])
plt.title("Average Days to Ship by Country")
plt.xlabel("Days")
save_fig("shipping_days_by_country.png")
