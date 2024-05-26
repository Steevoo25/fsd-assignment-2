/*
* File: Assignment2_SubmissionTemplate.sql
* 
* 1) Rename this file according to the instructions in the assignment statement.
* 2) Use this file to insert your solution.
*
* Author: <Stevenson>, <Harry>
* Student ID Number: <2314315>
* Institutional mail prefix: <hjs115>
*/

/*
*  Assume a user account 'fsad' with password 'fsad2022' with permission
* to create  databases already exists. You do NO need to include the commands
* to create the user nor to give it permission in you solution.
* For your testing, the following command may be used:
*
* CREATE USER fsad PASSWORD 'fsad2022' CREATEDB;
* GRANT pg_read_server_files TO fsad;
*/

/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.
-- In PostgreSQL, folders are identified with '/'


-- 1) Create a database called SmokedTrout.

CREATE DATABASE SmokedTrout
	WITH
	ENCODING = 'UTF8'
	CONNECTION LIMIT = -1
	OWNER = fsad;
	
-- 2) Connect to the database

\c smokedtrout fsad

/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state

CREATE TYPE materialState as ENUM
	('Gas', 'Liquid','Solid','Plasma');

-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.

CREATE TYPE materialComposition as ENUM
	('Composite','Fundamental');

-- 3) Create the table TradingRoute with the corresponding attributes.
CREATE TABLE "TradingRoute" (
 	MonitoringKey integer  ,
 	FleetSize int,
 	OperatingCompany varchar(60),
 	LastYearRevenue numeric(10,2),
	PRIMARY KEY(MonitoringKey));

-- 4) Create the table Planet with the corresponding attributes.

CREATE TABLE "Planet" (
 	PlanetID integer ,
 	StationID varchar(30),
	PlanetName varchar(30),
	Population integer,
	PRIMARY KEY(PlanetID));

-- 5) Create the table SpaceStation with the corresponding attributes.

CREATE TABLE "SpaceStation" (
 	StationID integer,
	hasStation integer,
	Name varchar(30),
 	Longitude varchar(30),
	Latitude varchar(30),

	PRIMARY KEY(StationID),
	FOREIGN KEY (hasStation )
	REFERENCES "Planet"(PlanetID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	);

-- 6) Create the parent table Product with the corresponding attributes.

CREATE TABLE "Product"(
	ProductID integer  ,
	ValuePerTon float,
	ProductName varchar(30),
	PRIMARY KEY(ProductID));


-- 7) Create the child table RawMaterial with the corresponding attributes.

CREATE TABLE "RawMaterial"(
	ProductID integer UNIQUE,
	VolumePerTon float,
	State materialState,
	FundamentalOrComposite materialComposition DEFAULT 'Composite',
	
	FOREIGN KEY(ProductID)
	REFERENCES "Product"(ProductID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	
	PRIMARY KEY(ProductID));

-- 8) Create the child table ManufacturedGood. 

CREATE TABLE "ManufacturedGood"(
	ProductID integer UNIQUE,
	ProductName varchar(30),
	VolumePerTon real,
	ValuePerTon numeric(10,2),
	
	FOREIGN KEY(ProductID)
	REFERENCES "Product"(ProductID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,

	PRIMARY KEY(ProductID));

-- 9) Create the table MadeOf with the corresponding attributes.

CREATE TABLE "MadeOf"(
	ManufacturedGoodID integer,
	ProductID integer,

	FOREIGN KEY (ManufacturedGoodID)
	REFERENCES "ManufacturedGood"(ProductID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,

	FOREIGN KEY (ProductID)
	REFERENCES "Product"(ProductID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,

	PRIMARY KEY(ManufacturedGoodID,ProductID));

-- 10) Create the table Batch with the corresponding attributes.

CREATE TABLE "Batch"(
	BatchID integer UNIQUE ,
	ProductID integer,
	ExtractionOrManufacturingDate date,
	OriginalFrom integer,
	
	PRIMARY KEY (BatchID),
	
	FOREIGN KEY(ProductID)
	REFERENCES "Product"(ProductID)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	
	FOREIGN KEY(OriginalFrom)
	REFERENCES "Planet"(PlanetID)
	ON UPDATE CASCADE
	ON DELETE CASCADE);

-- 11) Create the table Sells with the corresponding attributes.

CREATE TABLE "Sells"(
	BatchID integer,
	StationID integer,
	
	FOREIGN KEY(BatchID)
	REFERENCES "Batch"(BatchID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	FOREIGN KEY (StationID)
	REFERENCES "SpaceStation"(StationID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	PRIMARY KEY(BatchID, StationID)
	);

-- 12)  Create the table Buys with the corresponding attributes.

CREATE TABLE "Buys"(
	BatchID integer,
	StationID integer,
	
	FOREIGN KEY(BatchID)
	REFERENCES "Batch"(BatchID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	FOREIGN KEY (StationID)
	REFERENCES "SpaceStation"(StationID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	PRIMARY KEY(BatchID, StationID)
	);

-- 13)  Create the table CallsAt with the corresponding attributes.

CREATE TABLE "CallsAt"(
	MonitoringKey integer,
	StationID integer,
	VisitOrder integer,

	FOREIGN KEY(MonitoringKey)
	REFERENCES "TradingRoute"(MonitoringKey)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	FOREIGN KEY(StationID)
	REFERENCES "SpaceStation"(StationID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	PRIMARY KEY(MonitoringKey, VisitOrder)

);

-- 14)  Create the table Distance with the corresponding attributes.

CREATE TABLE "Distance"(
	PlanetOrigin integer,
	PlanetDestination integer,
	PlanetDistance float,
	
	FOREIGN KEY(PlanetOrigin)
	REFERENCES "Planet"(PlanetID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	FOREIGN KEY(PlanetDestination)
	REFERENCES "Planet"(PlanetID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	PRIMARY KEY(PlanetOrigin, PlanetDestination)
	
);

/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */

-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.

CREATE TABLE Dummy (
	MonitoringKey SERIAL,
	FleetSize int,
	OperatingCompany varchar(40),
	LasYearRevenue numeric(10,2) NOT NULL);
	
\copy Dummy FROM './data/TradeRoutes.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "TradingRoute"(MonitoringKey,FleetSize, OperatingCompany, LastYearRevenue)
SELECT * FROM Dummy;

DROP TABLE Dummy;

-- 3) Populate the table Planet with the data in the file Planets.csv.

CREATE TABLE Dummy(
	PlanetID SERIAL,
	StarSystem varchar(40),
	Planet varchar(40),
	Population_inMillions_ integer);
	
\copy Dummy FROM './data/Planets.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Planet"(PlanetID, StationID, PlanetName, Population)
SELECT * FROM Dummy;

DROP TABLE Dummy;

-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.

CREATE TABLE Dummy (
	StationID SERIAL,
	PlanetID integer,
	Name varchar(30),
	Longitude varchar(30),
	Latitude varchar(30));
	
\copy Dummy FROM './data/SpaceStations.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "SpaceStation"
SELECT * FROM Dummy;

DROP TABLE Dummy;

-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv. 

CREATE TABLE Dummy (
	ProductID SERIAL,
	Product varchar(30),
	Composite varchar(30),
	VolumePerTon float,
	ValuePerTon float,
	State materialState);
	
\copy Dummy FROM './data/Products_Raw.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Product"
SELECT ProductID, ValuePerTon, Product FROM Dummy;

INSERT INTO "RawMaterial"(ProductID, VolumePerTon)
SELECT ProductID, VolumePerTon FROM Dummy;

UPDATE "RawMaterial" 
SET FundamentalOrComposite = 'Fundamental'
FROM Dummy
WHERE "RawMaterial".ProductID = Dummy.ProductID AND Dummy.Composite = 'Yes';

UPDATE "RawMaterial" 
SET state= Dummy.state
FROM Dummy
WHERE "RawMaterial".ProductID = Dummy.ProductID;

DROP TABLE Dummy;

-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.

CREATE TABLE Dummy (
	ProductID SERIAL,
	Product varchar(30),
	VolumePerTon float,
	ValuePerTon float);
	
\copy Dummy FROM './data/Products_Manufactured.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Product"
SELECT ProductID, ValuePerTon, Product FROM Dummy;

INSERT INTO "ManufacturedGood"
SELECT * FROM Dummy;

DROP TABLE Dummy;

-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.

\copy "MadeOf" FROM './data/MadeOf.csv' WITH (FORMAT CSV, HEADER);

-- 8) Populate the table Batch with the data in the file Batches.csv.

\copy "Batch" FROM './data/Batches.csv' WITH (FORMAT CSV, HEADER);

-- 9) Populate the table Sells with the data in the file Sells.csv.

\copy "Sells" FROM './data/Sells.csv' WITH (FORMAT CSV, HEADER);

-- 10) Populate the table Buys with the data in the file Buys.csv.

\copy "Buys" FROM './data/Buys.csv' WITH (FORMAT CSV, HEADER);

-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.

\copy "CallsAt" FROM './data/CallsAt.csv' WITH (FORMAT CSV, HEADER);

-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.

\copy "Distance" FROM './data/PlanetDistances.csv' WITH (FORMAT CSV, HEADER);

/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute

ALTER TABLE "TradingRoute" ADD COLUMN Taxes numeric(10,2) GENERATED ALWAYS AS (LastYearRevenue * 0.12) STORED;

-- 2) Set the derived attribute taxes as 12% of LastYearRevenue

--**Done in Previous Step**

-- 3) Report the operating company and the sum of its taxes group by company.

SELECT OperatingCompany, SUM(LastYearRevenue) AS TotalTax FROM "TradingRoute" GROUP BY OperatingCompany;


-- 4.2 What's the longest trading route in parsecs?

-- 1) Create a dummy table RouteLength to store the trading route and their lengths.

CREATE TABLE RouteLength(
	MonitoringKey integer,
	Length real);

-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.

CREATE VIEW EnrichedCallsAt AS SELECT 
"TradingRoute".MonitoringKey,
"TradingRoute".OperatingCompany,
"TradingRoute".LastYearRevenue,
"TradingRoute".Taxes,
"TradingRoute".FleetSize,
"CallsAt".StationID,
"CallsAt".VisitOrder,
"SpaceStation".Name,
"SpaceStation".Longitude,
"SpaceStation".Latitude,
"Planet".PlanetID,
"Planet".PlanetName,
"Planet".Population
 FROM "TradingRoute" 
JOIN "CallsAt" USING (MonitoringKey) 
JOIN "SpaceStation" USING (StationID) 
JOIN "Planet" ON "SpaceStation".HasStation = "Planet".PlanetID; 

-- 3) Add the support to execute an anonymous code block as follows;

DO 
$$

DECLARE

-- 4) Within the declare section, declare a variable of type real to store a route total distance.

	routeDistance real := 0;

-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.

	hopPartialDistance real :=0;

-- 6) Within the declare section, declare a variable of type record to iterate over routes.

	routeIter record;

-- 7) Within the declare section, declare a variable of type record to iterate over hops.

	hopIter record;

-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.

	query text;
	previousPort record;
	
BEGIN
-- 9) Within the main body section, loop over routes in TradingRoutes
FOR routeIter IN SELECT MonitoringKey FROM "TradingRoute"
	LOOP
	
-- 10) Within the loop over routes, get all visited planets (in order) by this trading route.

	query:= 'CREATE VIEW PortsOfCall AS 
	SELECT PlanetID, VisitOrder FROM EnrichedCallsAt
	WHERE MonitoringKey = ' || routeIter.MonitoringKey || ' ORDER BY VisitOrder ASC';
	
-- 11) Within the loop over routes, execute the dynamic view
	
	EXECUTE query;
	
	query := 'SELECT * FROM PortsOfCall WHERE VisitOrder = 1';
	
	EXECUTE query INTO previousPort; 
	
	-- 12) Within the loop over routes, create a view Hops for storing the hops of that route. 
	--** I completed the task in a slightly different way so step 12) is not needed
	-- 13) Within the loop over routes, initialize the route total distance to 0.0.
	
	routeDistance:=0;
	
	-- 14) Within the loop over routes, create an inner loop over the hops
	
	FOR hopIter IN SELECT * FROM PortsOfCall WHERE VisitOrder>1
		LOOP	
		-- 15) Within the loop over hops, get the partial distances of the hop. 
		
		query := 'SELECT PlanetDistance FROM "Distance" '
				|| 'WHERE PlanetOrigin = ' || previousPort.PlanetID || ' AND '
				|| 'PlanetDestination = ' || hopIter.PlanetID;
				
		-- 16)  Within the loop over hops, execute the dynamic view and store the outcome INTO the hop partial distance.
		
		EXECUTE query INTO hopPartialDistance;
		
		-- 17)  Within the loop over hops, accumulate the hop partial distance to the route total distance.
		
		routeDistance := routeDistance + hopPartialDistance;
		END LOOP;
		
		-- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).
		
		query:= 'INSERT INTO RouteLength VALUES ($1, $2)';
		EXECUTE query USING routeIter.MonitoringKey, routeDistance;
	-- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).
	-- Again, as I completed the task in a slightly different way, Hops was not created and therefore does not need to be dropped
	
	-- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).
	DROP VIEW PortsOfCall CASCADE;
	END LOOP;
	
END $$;

-- 21)  Finally, just report the longest route in the dummy table RouteLength.

SELECT DISTINCT * FROM RouteLength 
WHERE length = (SELECT MAX(length) from ROuteLength);