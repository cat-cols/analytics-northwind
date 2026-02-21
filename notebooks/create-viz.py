import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Set style
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (10, 6)

# Load data
df = pd.read_csv('results/customer_analysis/top_10_customers.csv')

# Create bar chart
plt.figure(figsize=(12, 6))
plt.barh(df['company_name'], df['total_revenue'], color='steelblue')
plt.xlabel('Total Revenue ($)', fontsize=12)
plt.ylabel('Customer', fontsize=12)
plt.title('Top 10 Customers by Revenue', fontsize=14, fontweight='bold')
plt.gca().invert_yaxis()  # Highest at top
plt.tight_layout()
plt.savefig('results/visualizations/top_customers.png', dpi=300, bbox_inches='tight')
print("✅ Chart saved: top_customers.png")

# Monthly sales trend
df_monthly = pd.read_csv('results/sales_trends/monthly_sales_trend.csv')
df_monthly['month'] = pd.to_datetime(df_monthly['month'])

plt.figure(figsize=(14, 6))
plt.plot(df_monthly['month'], df_monthly['monthly_revenue'], marker='o', linewidth=2, color='darkgreen')
plt.xlabel('Month', fontsize=12)
plt.ylabel('Revenue ($)', fontsize=12)
plt.title('Monthly Revenue Trend', fontsize=14, fontweight='bold')
plt.xticks(rotation=45)
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('results/visualizations/monthly_revenue_trend.png', dpi=300, bbox_inches='tight')
print("✅ Chart saved: monthly_revenue_trend.png")