-- =========================
-- 1. CREATE DATABASE TABLES
-- =========================
CREATE TABLE Partners (
    PartnerID INT PRIMARY KEY,
    PartnerName VARCHAR(100) NOT NULL,
    ContactNumber VARCHAR(15),
    ServiceZone VARCHAR(100)
);
CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    TrackingNumber VARCHAR(50) UNIQUE NOT NULL,
    PartnerID INT,
    OrderDate DATE NOT NULL,
    PromisedDate DATE NOT NULL,
    ActualDeliveryDate DATE,
    DestinationCity VARCHAR(100) NOT NULL,
    Status VARCHAR(20) CHECK (
        Status IN (
            'Successful',
            'Returned',
            'In Transit',
            'Delayed'
        )
    ),
    FOREIGN KEY (PartnerID) REFERENCES Partners(PartnerID)
);
CREATE TABLE DeliveryLogs (
    LogID INT PRIMARY KEY,
    ShipmentID INT,
    LogDate TIMESTAMP NOT NULL,
    Location VARCHAR(100),
    Remark VARCHAR(200),
    FOREIGN KEY (ShipmentID) REFERENCES Shipments(ShipmentID)
);
-- =========================
-- 2. SAMPLE DATA
-- =========================
INSERT INTO Partners (
        PartnerID,
        PartnerName,
        ContactNumber,
        ServiceZone
    )
VALUES (1, 'FastExpress', '9876543210', 'South'),
    (2, 'QuickMove', '9876543211', 'North'),
    (3, 'BlueDartPro', '9876543212', 'East'),
    (4, 'ShipNow', '9876543213', 'West');
INSERT INTO Shipments (
        ShipmentID,
        TrackingNumber,
        PartnerID,
        OrderDate,
        PromisedDate,
        ActualDeliveryDate,
        DestinationCity,
        Status
    )
VALUES (
        101,
        'TRK1001',
        1,
        CURRENT_DATE - INTERVAL '10 days',
        CURRENT_DATE - INTERVAL '5 days',
        CURRENT_DATE - INTERVAL '4 days',
        'Chennai',
        'Successful'
    ),
    (
        102,
        'TRK1002',
        1,
        CURRENT_DATE - INTERVAL '8 days',
        CURRENT_DATE - INTERVAL '3 days',
        CURRENT_DATE - INTERVAL '1 days',
        'Madurai',
        'Successful'
    ),
    (
        103,
        'TRK1003',
        2,
        CURRENT_DATE - INTERVAL '12 days',
        CURRENT_DATE - INTERVAL '7 days',
        CURRENT_DATE - INTERVAL '6 days',
        'Chennai',
        'Returned'
    ),
    (
        104,
        'TRK1004',
        2,
        CURRENT_DATE - INTERVAL '6 days',
        CURRENT_DATE - INTERVAL '2 days',
        CURRENT_DATE - INTERVAL '1 days',
        'Bangalore',
        'Successful'
    ),
    (
        105,
        'TRK1005',
        3,
        CURRENT_DATE - INTERVAL '15 days',
        CURRENT_DATE - INTERVAL '10 days',
        CURRENT_DATE - INTERVAL '8 days',
        'Chennai',
        'Successful'
    ),
    (
        106,
        'TRK1006',
        3,
        CURRENT_DATE - INTERVAL '5 days',
        CURRENT_DATE - INTERVAL '2 days',
        CURRENT_DATE,
        'Hyderabad',
        'Delayed'
    ),
    (
        107,
        'TRK1007',
        4,
        CURRENT_DATE - INTERVAL '9 days',
        CURRENT_DATE - INTERVAL '4 days',
        CURRENT_DATE - INTERVAL '2 days',
        'Chennai',
        'Successful'
    ),
    (
        108,
        'TRK1008',
        4,
        CURRENT_DATE - INTERVAL '7 days',
        CURRENT_DATE - INTERVAL '3 days',
        CURRENT_DATE - INTERVAL '3 days',
        'Madurai',
        'Successful'
    );
INSERT INTO DeliveryLogs (LogID, ShipmentID, LogDate, Location, Remark)
VALUES (
        1,
        101,
        CURRENT_TIMESTAMP,
        'Chennai Hub',
        'Delivered successfully'
    ),
    (
        2,
        102,
        CURRENT_TIMESTAMP,
        'Madurai Hub',
        'Delivered late'
    ),
    (
        3,
        103,
        CURRENT_TIMESTAMP,
        'Chennai Hub',
        'Customer not available, returned'
    ),
    (
        4,
        104,
        CURRENT_TIMESTAMP,
        'Bangalore Hub',
        'Delivered successfully'
    ),
    (
        5,
        105,
        CURRENT_TIMESTAMP,
        'Chennai Hub',
        'Delivered successfully'
    ),
    (
        6,
        106,
        CURRENT_TIMESTAMP,
        'Hyderabad Hub',
        'Still delayed'
    ),
    (
        7,
        107,
        CURRENT_TIMESTAMP,
        'Chennai Hub',
        'Delivered successfully'
    ),
    (
        8,
        108,
        CURRENT_TIMESTAMP,
        'Madurai Hub',
        'Delivered on time'
    );
-- =========================================
-- 3. DELAYED SHIPMENT QUERY
-- Find all shipments where ActualDeliveryDate > PromisedDate
-- =========================================
SELECT ShipmentID,
    TrackingNumber,
    PartnerID,
    DestinationCity,
    PromisedDate,
    ActualDeliveryDate,
    Status
FROM Shipments
WHERE ActualDeliveryDate > PromisedDate;
-- =========================================
-- 4. PERFORMANCE RANKING
-- Show Successful vs Returned deliveries for each partner
-- =========================================
SELECT p.PartnerID,
    p.PartnerName,
    COUNT(
        CASE
            WHEN s.Status = 'Successful' THEN 1
        END
    ) AS SuccessfulDeliveries,
    COUNT(
        CASE
            WHEN s.Status = 'Returned' THEN 1
        END
    ) AS ReturnedDeliveries
FROM Partners p
    LEFT JOIN Shipments s ON p.PartnerID = s.PartnerID
GROUP BY p.PartnerID,
    p.PartnerName
ORDER BY SuccessfulDeliveries DESC,
    ReturnedDeliveries ASC;
-- =========================================
-- 5. MOST POPULAR DESTINATION CITY
-- Orders placed in the last 30 days
-- =========================================
SELECT DestinationCity,
    COUNT(*) AS TotalOrders
FROM Shipments
WHERE OrderDate >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DestinationCity
ORDER BY TotalOrders DESC
LIMIT 1;
-- =========================================
-- 6. PARTNER SCORECARD
-- Company with the fewest delays
-- =========================================
SELECT p.PartnerID,
    p.PartnerName,
    COUNT(s.ShipmentID) AS TotalShipments,
    COUNT(
        CASE
            WHEN s.ActualDeliveryDate > s.PromisedDate THEN 1
        END
    ) AS DelayedShipments,
    COUNT(
        CASE
            WHEN s.Status = 'Successful' THEN 1
        END
    ) AS SuccessfulDeliveries,
    ROUND(
        COUNT(
            CASE
                WHEN s.Status = 'Successful' THEN 1
            END
        ) * 100.0 / NULLIF(COUNT(s.ShipmentID), 0),
        2
    ) AS SuccessRate
FROM Partners p
    LEFT JOIN Shipments s ON p.PartnerID = s.PartnerID
GROUP BY p.PartnerID,
    p.PartnerName
ORDER BY DelayedShipments ASC,
    SuccessRate DESC;
-- =========================================
-- 7. BEST PARTNER (FEWEST DELAYS)
-- =========================================
SELECT p.PartnerID,
    p.PartnerName,
    COUNT(
        CASE
            WHEN s.ActualDeliveryDate > s.PromisedDate THEN 1
        END
    ) AS DelayedShipments
FROM Partners p
    LEFT JOIN Shipments s ON p.PartnerID = s.PartnerID
GROUP BY p.PartnerID,
    p.PartnerName
ORDER BY DelayedShipments ASC
LIMIT 1;