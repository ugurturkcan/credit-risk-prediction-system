#  AI-Powered Credit Risk Prediction System

![Status](https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge)
![Backend](https://img.shields.io/badge/Backend-FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![Frontend](https://img.shields.io/badge/Frontend-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![AI Model](https://img.shields.io/badge/AI-LightGBM-orange?style=for-the-badge)

> **A Fintech Solution:** End-to-end credit risk assessment system featuring a Hybrid Decision Engine (Rule-Based + AI), served via a high-performance FastAPI backend, and consumed by a modern Flutter mobile application.

---

##  Project Overview

Traditional credit scoring systems often rely solely on linear rules or black-box AI models. This project bridges the gap by implementing a **"Hybrid Intelligence"** approach. It combines strict regulatory compliance rules (Rule Engine) with advanced machine learning predictions to ensure both safety and accuracy.

### Key Features
* ** Hybrid Decision Engine:** First, it checks "Knock-out" rules (e.g., Age < 18, High Debt-to-Income Ratio). If passed, the AI model calculates the risk probability.
* ** Advanced ML Model:** Built with **LightGBM**, optimized for tabular data with handled imbalanced datasets using `class_weight='balanced'`.
* ** Smart "What-If" Analysis:** If a loan is rejected, the system analyzes *why* and suggests actionable advice (e.g., *"Reduce loan amount to 40,000 TL to get approved"*).
* ** Modern Mobile UI:** A clean Flutter interface with dynamic color-coded risk gauges, sliders, and real-time feedback.

---

##  The Machine Learning Model

The core of this system is a **LightGBM (Gradient Boosting Machine)** classifier, trained on the Home Credit Default Risk dataset.

### 1. Feature Engineering & Selection
Instead of using raw data blindly, we carefully selected and engineered **8 Key Features** that impact creditworthiness the most:
* **Financial Ratios (Backend Generated):**
    * `CREDIT_INCOME_RATIO`: How large is the loan relative to income?
    * `ANNUITY_INCOME_RATIO` (DTI): How much of the income goes to monthly installments?
* **Demographics:** Age (`DAYS_BIRTH`), Education Level, Marital Status.
* **Stability:** Years Employed (`DAYS_EMPLOYED`).
* **External Data:** Credit Bureau Score (Simulated as `EXT_SOURCE_2`).

### 2. Model Performance
* **Strategy:** The model focuses on **Recall** to minimize False Negatives (missing a risky customer is costlier than rejecting a safe one).
* **Optimization:** Hyperparameters were tuned to handle the imbalanced nature of default risk data.

---

##  System Architecture (Monorepo)

The project follows a clean **Service-Oriented Architecture (SOA)** within a Monorepo structure.

```text
credit-risk-prediction-system/
│
├── backend/                #  Python Backend 
│   ├── models/             # Trained .pkl models
│   ├── routers/            # API Endpoints
│   ├── services/           # Business Logic & Rule Engine
│   ├── main.py             # Entry Point
│   └── requirements.txt    # Python Dependencies
│
├── frontend/               # Flutter App 
│   ├── lib/
│       ├── models/         # Dart Data Models
│       ├── screens/        # UI Screens & Widgets
│       ├── services/       # HTTP API Integration
│       └── main.dart       # App Entry Point
## 🚀 How to Run (Installation Guide)

You can run this project locally on your machine. Follow these steps to set up the full-stack environment.

### Prerequisites
Ensure you have the following installed:
- **Python 3.9+**
- **Flutter SDK**
- **Git**
- **VS Code** (Recommended)

---

### Step 1: Clone the Repository
Open your terminal and run:

```bash
git clone https://github.com/ugurturkcan/credit-risk-prediction-system.git
cd credit-risk-prediction-system

### Step 2: Setup & Run Backend (Python)
The mobile app requires the backend to be running first to fetch predictions.

1.Navigate to the backend directory:
cd backend

2.Create and activate a virtual environment:
python -m venv .venv
.venv\Scripts\activate

3.Install dependencies:
pip install -r requirements.txt

4.Start the API server:
python main.py

### Step 3: Setup & Run Mobile App (Flutter)
Keep the backend terminal open and open a new terminal window.

1.Navigate to the frontend directory:
cd frontend

2.Install Flutter packages:
flutter pub get

3.Configure API URL (Crucial Step):
Open lib/utils/constants.dart.

Ensure the apiUrl matches your environment:

Android Emulator: Use http://10.0.2.2:8000 (Default)

iOS Simulator / Web: Use http://127.0.0.1:8000

4.Run the App:

flutter run
