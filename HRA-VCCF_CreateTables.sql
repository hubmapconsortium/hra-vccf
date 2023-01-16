--#############################################################################
--#############################################################################
--## HRA-VCCF Create Tables
--## Date: January 15, 2023
--## Database: Microsoft SQL Server
--## Author: Griffin M Weber, MD, PhD (weber@hms.harvard.edu)
--#############################################################################
--#############################################################################


CREATE TABLE Vessel (
	BranchesFrom varchar(200) not null,
	Vessel varchar(200) not null primary key,
	VesselType varchar(50) not null,
	VesselSubType varchar(50) not null,
	BodyPart varchar(100) not null,
	BodySubPart varchar(100) not null,
	PortalSystem varchar(100) not null,
	FTU varchar(50) not null,
	Sex varchar(50) not null,
	Anastomoses varchar(max) not null,
	ArteryVeinConnects varchar(200) not null,
	ArteryVeinPair varchar(200) not null,
	ForBranchesSee varchar(200) not null,
	VirtualVessel int not null,
	BranchSequence int not null,
	SpatialReferenceObjectFemale varchar(200) not null,
	SpatialReferenceObjectMale varchar(200) not null,
	CoordX varchar(10) not null,
	CoordY varchar(10) not null,
	ReferenceURL varchar(500) not null,
	Reference varchar(max) not null,
	ReferenceDOI varchar(500) not null,
	VesselTypeID varchar(50) not null,
	VesselSubTypeID varchar(50) not null,
	BodyPartID varchar(100) not null,
	BodySubPartID varchar(100) not null,
	FTULabel varchar(200) not null,
	FTUID varchar(50) not null,
	UBERON varchar(50) not null,
	FMA varchar(50) not null,
	UBERONLabel varchar(200) not null,
	FMALabel varchar(200) not null,
	ASLabel varchar(200) not null,
	ASID varchar(50) not null,
	OtherUberonFmaNameList varchar(max) not null,
	TerminologiaAnatomica varchar(max) not null,
	OtherVesselNameList varchar(max) not null,
	VesselBaseName varchar(200) not null,
	FullVesselNameList varchar(max) not null,
	HasBranches int not null,
	VirtualVesselOfList varchar(max) not null,
	VirtualVesselOfCount int not null,
	VirtualInstances int not null,
	VirtualPath varchar(max) not null,
	PathFromHeart varchar(max) not null,
	PathFromHeartWithIDs varchar(max) not null
)

CREATE TABLE CellTypeBiomarker (
	RuleID int not null primary key,
	MatchType varchar(100) not null,
	MatchVal varchar(max) not null,
	IncludeCTB int not null,
	CTBType varchar(50) not null,
	CTBName varchar(500) not null,
	CTBLabel varchar(500) not null,
	CTBID varchar(50) not null,
	ReferenceURL varchar(500) not null,
	Reference varchar(max) not null,
	ReferenceDOI varchar(500) not null
)

CREATE TABLE VesselCTB (
	Vessel varchar(200) not null,
	BType varchar(50) not null,
	CT1 varchar(50) not null,
	CT1Label varchar(500) not null,
	CT1ID varchar(500) not null,
	CT2 varchar(50) not null,
	CT2Label varchar(500) not null,
	CT2ID varchar(500) not null,
	CT3 varchar(50) not null,
	CT3Label varchar(500) not null,
	CT3ID varchar(500) not null,
	BGene1 varchar(50) not null,
	BGene1Label varchar(500) not null,
	BGene1ID varchar(500) not null
)


CREATE TABLE Geometry (
	Vessel varchar(200) not null,
	Property varchar(100) not null,
	Sex varchar(50) not null,
	Value varchar(50) not null,
	StandardDeviation varchar(50) not null,
	RangeLow varchar(50) not null,
	RangeHigh varchar(50) not null,
	Units varchar(20) not null,
	Population varchar(100) not null,
	SampleSize varchar(50) not null,
	Method varchar(100) not null,
	ReferenceURL varchar(500) not null,
	Reference varchar(max) not null,
	ReferenceDOI varchar(500) not null,
	Notes varchar(max) not null
)

