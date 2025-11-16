-- Data exploration:
SELECT * FROM telco_churn ORDER BY customerID ASC;

-- Overall churn rate:
SELECT 
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage
FROM telco_churn;

-- Results: 26.54 % of churn rate.

-- Churn rate by contract type with annual revenue loss:
SELECT 
    Contract,
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges * 12 ELSE 0 END), 2) as annual_revenue_lost
FROM telco_churn
GROUP BY Contract;

-- Results: Month-to-month customers have higher churn rate (42.71%).

-- Churn analysis for Month-to-month customers by internet service type:
SELECT 
    InternetService as internet_service_type,
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges * 12 ELSE 0 END), 2) as annual_revenue_lost
FROM telco_churn
WHERE Contract = 'Month-to-month'
GROUP BY InternetService
ORDER BY churn_rate_percentage DESC;

-- Results: Month-to-month customers with Fiber opitic churn more (54.61%).

-- Security services analysis for Month-to-month Fiber optic customers
SELECT 
    CASE 
        WHEN OnlineSecurity = 'No' AND OnlineBackup = 'No' AND DeviceProtection = 'No' THEN 'No security services'
        WHEN OnlineSecurity = 'No' OR OnlineBackup = 'No' OR DeviceProtection = 'No' THEN 'Partial security services'
        ELSE 'Full security services'
    END as security_category,
    COUNT(*) as total_customers,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage
FROM telco_churn
WHERE Contract = 'Month-to-month' AND InternetService = 'Fiber optic'
GROUP BY InternetService, security_category
ORDER BY churn_rate_percentage DESC;

-- TechSupport analysis for Month-to-month Fiber optic customers
SELECT 
    CASE 
        WHEN TechSupport = 'No' THEN 'No TechSupport'
        ELSE 'With TechSupport'
    END as tech_support_level,
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge
FROM telco_churn
WHERE Contract = 'Month-to-month' AND InternetService = 'Fiber optic'
GROUP BY tech_support_level
ORDER BY churn_rate_percentage DESC;

-- Streaming services analysis for Month-to-month Fiber optic customers
SELECT 
    CASE 
        WHEN StreamingTV = 'No' AND StreamingMovies = 'No' THEN 'No streaming services'
        WHEN StreamingTV = 'Yes' AND StreamingMovies = 'Yes' THEN 'Both streaming services'
        ELSE 'One streaming service'
    END as streaming_category,
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge
FROM telco_churn
WHERE Contract = 'Month-to-month' AND InternetService = 'Fiber optic'
GROUP BY streaming_category
ORDER BY churn_rate_percentage DESC;

-- Results: The churn rate is higher for customers with no TechSupport and no security service. The streaming is not a problem.

-- Comprehensive analysis: Security + TechSupport for Month-to-month and Fiber optic customers:
SELECT 
    -- Security
    CASE 
        WHEN OnlineSecurity = 'No' AND OnlineBackup = 'No' AND DeviceProtection = 'No' THEN 'No security services'
        WHEN OnlineSecurity = 'No' OR OnlineBackup = 'No' OR DeviceProtection = 'No' THEN 'Partial security services'
        ELSE 'Full security services'
    END as security_level,
    -- TechSupport
    CASE 
        WHEN TechSupport = 'No' THEN 'No TechSupport'
        ELSE 'With TechSupport'
    END as tech_support_level,
    COUNT(*) as total_customers,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as churned_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage
FROM telco_churn
WHERE Contract = 'Month-to-month'
AND InternetService = 'Fiber optic'
GROUP BY security_level, tech_support_level
ORDER BY churn_rate_percentage DESC;

-- Tenure analysis for these churned customers:
SELECT 
    -- Service categorization
    CASE 
        WHEN TechSupport = 'No' THEN 'No TechSupport'
        ELSE 'With TechSupport'
    END as tech_support_level,
    CASE 
        WHEN OnlineSecurity = 'No' AND OnlineBackup = 'No' AND DeviceProtection = 'No' THEN 'No security services'
        WHEN OnlineSecurity = 'No' OR OnlineBackup = 'No' OR DeviceProtection = 'No' THEN 'Partial security services'
        ELSE 'Full security services'
    END as security_level,
   
    -- Time distribution
    SUM(CASE WHEN Churn = 'Yes' AND tenure <= 3 THEN 1 ELSE 0 END) as churned_first_3_months,
    SUM(CASE WHEN Churn = 'Yes' AND tenure BETWEEN 4 AND 6 THEN 1 ELSE 0 END) as churned_4_6_months,
    SUM(CASE WHEN Churn = 'Yes' AND tenure BETWEEN 7 AND 12 THEN 1 ELSE 0 END) as churned_7_12_months,
    SUM(CASE WHEN Churn = 'Yes' AND tenure > 12 THEN 1 ELSE 0 END) as churned_after_1_year,
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as total_churned
    
FROM telco_churn
WHERE Contract = 'Month-to-month'
AND InternetService = 'Fiber optic'
GROUP BY tech_support_level, security_level
ORDER BY total_churned DESC;

-- Results: customers churn more on the first 3 months.

-- Emergency intervention: Highest risk customers with churn cost.
SELECT 
    COUNT(*) as emergency_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as already_churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges * 12 ELSE 0 END), 2) as annual_revenue_lost,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges * 24 ELSE 0 END), 2) as biennial_revenue_lost
FROM telco_churn
WHERE Contract = 'Month-to-month'
AND InternetService = 'Fiber optic'
AND TechSupport = 'No'
AND DeviceProtection = 'No' 
AND OnlineBackup = 'No' 
AND OnlineSecurity = 'No'
AND tenure <= 3;

-- Detailed financial analysis for timely interventions
SELECT 
    -- Priority categorization
    CASE 
        WHEN tenure = 1 THEN 'First month'
        WHEN tenure = 2 THEN 'Second month' 
        WHEN tenure = 3 THEN 'Third month'
    END as current_month,
    
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) as already_churned,
    SUM(CASE WHEN Churn = 'No' THEN 1 ELSE 0 END) as still_active,
    
    -- Financial analysis
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges * 12 ELSE 0 END), 2) as annual_revenue_lost,
    
    -- Salvage potential (if we intervene NOW)
    ROUND(SUM(CASE WHEN Churn = 'No' THEN MonthlyCharges * 12 ELSE 0 END), 2) as salvageable_annual_revenue

FROM telco_churn
WHERE Contract = 'Month-to-month'
AND InternetService = 'Fiber optic'
AND TechSupport = 'No'
AND DeviceProtection = 'No' 
AND OnlineBackup = 'No' 
AND OnlineSecurity = 'No'
AND tenure <= 3
GROUP BY tenure
ORDER BY tenure;

-- Results: The first 30 days are critical, over €140K revenue lost in the first month alone.

-- SUMMARY: Highest risk customer profile identification
SELECT 
    'HIGH RISK CUSTOMER' as profile,
    'Month-to-month + Fiber + No TechSupport + No Security + First 3 months' as characteristics,
    COUNT(*) as total_customers,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as churn_rate_percentage,
    ROUND(AVG(MonthlyCharges), 2) as average_monthly_charge,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges * 12 ELSE 0 END), 2) as annual_revenue_lost
FROM telco_churn
WHERE Contract = 'Month-to-month'
AND InternetService = 'Fiber optic'
AND TechSupport = 'No'
AND OnlineSecurity = 'No' 
AND OnlineBackup = 'No'
AND DeviceProtection = 'No'
AND tenure <= 3;

-- URGENT ACTION REQUIRED: 295 customers with 81% churn rate costing €221K annually.
-- RECOMMENDATION: Immediate "Fiber Care Bundle" rollout for this segment.

