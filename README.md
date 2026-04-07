# 🚚 SwiftShip Logistics Tracking System

## 📌 Overview
SwiftShip is a third-party logistics provider handling large volumes of daily shipments.  
This project simulates a **tracking database system** to analyze delivery performance, identify delays, and evaluate partner efficiency.

---

## 🎯 Objectives
- Track shipment details and delivery logs
- Identify delayed shipments
- Analyze partner performance
- Determine most active delivery zones
- Generate a partner scorecard

---

## 🧱 Database Schema

The project includes three main tables:

1. **Partners**
2. **Shipments**
3. **DeliveryLogs**

---

## ⚙️ Features

- 🔍 Find delayed shipments  
- 📊 Partner performance ranking  
- 📍 Most popular destination city  
- 🏆 Partner scorecard (based on success rate)

---

## 🛠️ How to Run

### MySQL
```sql
CREATE DATABASE swiftship;
USE swiftship;
source project.sql;
```

### SQLite
```sql
.read project.sql
```

---

## 📂 Files
- project.sql
- README.md
- docs/sample-output.txt

---


