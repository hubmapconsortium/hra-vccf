--#############################################################################
--#############################################################################
--## HRA-VCCF Generate Export Tables
--## Date: February 26, 2022
--## Database: Microsoft SQL Server
--## Author: Griffin M Weber, MD, PhD (weber@hms.harvard.edu)
--#############################################################################
--#############################################################################


--*****************************************************************************
--*****************************************************************************
--** Load data
--*****************************************************************************
--*****************************************************************************


select *
	into #Vessel
	from Vessel

alter table #Vessel add primary key (vessel)

select *
	into #CellTypeBiomarker
	from CellTypeBiomarker

alter table #CellTypeBiomarker add primary key (RuleID)



--*****************************************************************************
--*****************************************************************************
--** Get cell types and biomarkers for each vessel
--*****************************************************************************
--*****************************************************************************

--Get the list of cell types for each vessel
;with a as (
	select *
	from (
		select v.Vessel v, c.*, min(IncludeCTB) over (partition by v.Vessel, c.CTBType, c.CTBName) MinIncludeCTB
		from #Vessel v
			inner join #CellTypeBiomarker c
				on 1 = (
					case c.MatchType
						when 'VesselTypeList' then (case when ';'+c.MatchVal+';' like '%;'+v.VesselType+';%' then 1 else 0 end)
						when 'VesselSubTypeList' then (case when ';'+c.MatchVal+';' like '%;'+v.VesselSubType+';%' then 1 else 0 end)
						else 0 end)
		where CTBType like 'CT%'
	) t
	where MinIncludeCTB=1 --and v in ('left atrium','aorta','liver sinusoid')
), ct1 as (
	select v, CTBName CT1, CTBLabel CT1Label, CTBID CT1ID from a where CTBType='CT1'
), ct2 as (
	select c.*, '' CT2, '' CT2Label, '' CT2ID from ct1 c
	union all 
	select c.*, a.CTBName CT2, a.CTBLabel CT2Label, a.CTBID CT2ID
		from ct1 c inner join a on c.v=a.v and a.CTBType='CT2' and c.CT1<>''
), ct3 as (
	select c.*, '' CT3, '' CT3Label, '' CT3ID from ct2 c
	union all 
	select c.*, a.CTBName CT3, a.CTBLabel CT3Label, a.CTBID CT3ID
		from ct2 c inner join a on c.v=a.v and a.CTBType='CT3' and c.CT1<>'' and c.CT2<>''
), c as (
	select * from ct3
	union all 
	select v, CTBName CT1, CTBLabel CT1Label, CTBID CT1ID, '', '', '', '', '', '' from a where CTBType='CT'
)
select *
	into #VesselCellType
	from c

--Get the list of biomarkers for each vessel, based on the vessel itself or its cell types
;with a as (
	select *
	from (
		select *, row_number() over (partition by v, CTBType, CTBName order by RuleID) k
		from (
			select *, min(IncludeCTB) over (partition by v, CTBType, CTBName) MinIncludeCTB
			from (
				select v.Vessel v, c.*
					from #Vessel v
						inner join #CellTypeBiomarker c
							on 1 = (
								case c.MatchType
									when 'VesselTypeList' then (case when ';'+c.MatchVal+';' like '%;'+v.VesselType+';%' then 1 else 0 end)
									when 'VesselSubTypeList' then (case when ';'+c.MatchVal+';' like '%;'+v.VesselSubType+';%' then 1 else 0 end)
									else 0 end)
					where CTBType like 'B%'
				union all
				select v.v, c.*
					from #VesselCellType v
						inner join #CellTypeBiomarker c
							on c.MatchVal in (v.CT1,v.CT2,v.CT3) and c.MatchType='CellType'
			) t
			--where v in ('left atrium','aorta','liver sinusoid')
		) t
		where MinIncludeCTB=1
	) t
	where k=1
)
select v.*, isnull(a.CTBType,'') BType, isnull(a.CTBName,'') B1, isnull(a.CTBLabel,'') B1Label, isnull(a.CTBID,'') B1ID
	into #VesselCellTypeBiomarker
	from #VesselCellType v
		left outer join a
			on a.v=v.v
				and 1=(case
					when MatchType='CellType' then (case when a.MatchVal = coalesce(nullif(v.CT3,''),nullif(v.CT2,''),nullif(v.CT1,'')) then 1 else 0 end)
					when CT1 in ('cardiac endothelial cell','blood vessel endothelial cell') and CT2='' then 1
					else 0 end)

--Place into ASCT+B table format, with different columns for each type of biomarker
select v Vessel, BType, CT1, CT1Label, CT1ID, CT2, CT2Label, CT2ID, CT3, CT3Label, CT3ID,
		(case when BType='BGene' then B1 else '' end) BGene1,
		(case when BType='BGene' then B1Label else '' end) BGene1Label,
		(case when BType='BGene' then B1ID else '' end) BGene1ID
	into #VesselCTB
	from #VesselCellTypeBiomarker

create clustered index idx_vct123 on #VesselCTB (Vessel, CT1, CT2, CT3)


--*****************************************************************************
--*****************************************************************************
--** Generate ASCT+B table
--*****************************************************************************
--*****************************************************************************


/*
--Generate SQL for pivot
;with a as (select 0 n union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9
), n as (select a.n+10*b.n n from a cross join a b
), s as (select n, cast(n.n as varchar(10)) s from n)
select n, s, 
		'isnull(x.ASXML.value(''x['+cast(n*3-2 as varchar(10))+']'',''varchar(200)''),'''') AS'+s+', '
		+'isnull(x.ASXML.value(''x['+cast(n*3-1 as varchar(10))+']'',''varchar(200)''),'''') AS'+s+'Label, '
		+'isnull(x.ASXML.value(''x['+cast(n*3 as varchar(10))+']'',''varchar(200)''),'''') AS'+s+'ID,' t
	from s
	where n between 1 and 20
	order by n
*/


select
		isnull(x.ASXML.value('x[1]','varchar(200)'),'') AS1, isnull(x.ASXML.value('x[2]','varchar(200)'),'') AS1Label, isnull(x.ASXML.value('x[3]','varchar(200)'),'') AS1ID,
		isnull(x.ASXML.value('x[4]','varchar(200)'),'') AS2, isnull(x.ASXML.value('x[5]','varchar(200)'),'') AS2Label, isnull(x.ASXML.value('x[6]','varchar(200)'),'') AS2ID,
		isnull(x.ASXML.value('x[7]','varchar(200)'),'') AS3, isnull(x.ASXML.value('x[8]','varchar(200)'),'') AS3Label, isnull(x.ASXML.value('x[9]','varchar(200)'),'') AS3ID,
		isnull(x.ASXML.value('x[10]','varchar(200)'),'') AS4, isnull(x.ASXML.value('x[11]','varchar(200)'),'') AS4Label, isnull(x.ASXML.value('x[12]','varchar(200)'),'') AS4ID,
		isnull(x.ASXML.value('x[13]','varchar(200)'),'') AS5, isnull(x.ASXML.value('x[14]','varchar(200)'),'') AS5Label, isnull(x.ASXML.value('x[15]','varchar(200)'),'') AS5ID,
		isnull(x.ASXML.value('x[16]','varchar(200)'),'') AS6, isnull(x.ASXML.value('x[17]','varchar(200)'),'') AS6Label, isnull(x.ASXML.value('x[18]','varchar(200)'),'') AS6ID,
		isnull(x.ASXML.value('x[19]','varchar(200)'),'') AS7, isnull(x.ASXML.value('x[20]','varchar(200)'),'') AS7Label, isnull(x.ASXML.value('x[21]','varchar(200)'),'') AS7ID,
		isnull(x.ASXML.value('x[22]','varchar(200)'),'') AS8, isnull(x.ASXML.value('x[23]','varchar(200)'),'') AS8Label, isnull(x.ASXML.value('x[24]','varchar(200)'),'') AS8ID,
		isnull(x.ASXML.value('x[25]','varchar(200)'),'') AS9, isnull(x.ASXML.value('x[26]','varchar(200)'),'') AS9Label, isnull(x.ASXML.value('x[27]','varchar(200)'),'') AS9ID,
		isnull(x.ASXML.value('x[28]','varchar(200)'),'') AS10, isnull(x.ASXML.value('x[29]','varchar(200)'),'') AS10Label, isnull(x.ASXML.value('x[30]','varchar(200)'),'') AS10ID,
		isnull(x.ASXML.value('x[31]','varchar(200)'),'') AS11, isnull(x.ASXML.value('x[32]','varchar(200)'),'') AS11Label, isnull(x.ASXML.value('x[33]','varchar(200)'),'') AS11ID,
		isnull(x.ASXML.value('x[34]','varchar(200)'),'') AS12, isnull(x.ASXML.value('x[35]','varchar(200)'),'') AS12Label, isnull(x.ASXML.value('x[36]','varchar(200)'),'') AS12ID,
		isnull(x.ASXML.value('x[37]','varchar(200)'),'') AS13, isnull(x.ASXML.value('x[38]','varchar(200)'),'') AS13Label, isnull(x.ASXML.value('x[39]','varchar(200)'),'') AS13ID,
		isnull(x.ASXML.value('x[40]','varchar(200)'),'') AS14, isnull(x.ASXML.value('x[41]','varchar(200)'),'') AS14Label, isnull(x.ASXML.value('x[42]','varchar(200)'),'') AS14ID,
		isnull(x.ASXML.value('x[43]','varchar(200)'),'') AS15, isnull(x.ASXML.value('x[44]','varchar(200)'),'') AS15Label, isnull(x.ASXML.value('x[45]','varchar(200)'),'') AS15ID,
		isnull(x.ASXML.value('x[46]','varchar(200)'),'') AS16, isnull(x.ASXML.value('x[47]','varchar(200)'),'') AS16Label, isnull(x.ASXML.value('x[48]','varchar(200)'),'') AS16ID,
		isnull(x.ASXML.value('x[49]','varchar(200)'),'') AS17, isnull(x.ASXML.value('x[50]','varchar(200)'),'') AS17Label, isnull(x.ASXML.value('x[51]','varchar(200)'),'') AS17ID,
		isnull(x.ASXML.value('x[52]','varchar(200)'),'') AS18, isnull(x.ASXML.value('x[53]','varchar(200)'),'') AS18Label, isnull(x.ASXML.value('x[54]','varchar(200)'),'') AS18ID,
		isnull(x.ASXML.value('x[55]','varchar(200)'),'') AS19, isnull(x.ASXML.value('x[56]','varchar(200)'),'') AS19Label, isnull(x.ASXML.value('x[57]','varchar(200)'),'') AS19ID,
		--isnull(x.ASXML.value('x[58]','varchar(200)'),'') AS20, isnull(x.ASXML.value('x[59]','varchar(200)'),'') AS20Label, isnull(x.ASXML.value('x[60]','varchar(200)'),'') AS20ID,
		isnull(c.CT1,'') CT1, isnull(c.CT1Label,'') CT1Label, isnull(c.CT1ID,'') CT1ID,
		isnull(c.CT2,'') CT2, isnull(c.CT2Label,'') CT2Label, isnull(c.CT2ID,'') CT2ID,
		isnull(c.CT3,'') CT3, isnull(c.CT3Label,'') CT3Label, isnull(c.CT3ID,'') CT3ID,
		isnull(c.BGene1,'') BGene1, isnull(c.BGene1Label,'') BGene1Label, isnull(c.BGene1ID,'') BGene1ID,
		v.FTU, v.FTULabel, v.FTUID, '' FTUComments, Reference REF1, ReferenceDOI REF1DOI, 'For AS' REF1Notes,
		isnull(row_number() over (order by PathFromHeart, CT1, CT2, CT3, BGene1),-1) SortOrder
	into #VesselASCTB
	from #Vessel v
		cross apply (select 'blood vasculature;blood vasculature;UBERON:0004537;'+replace(PathFromHeartWithIDs,';fma',';FMA:') ASList) a
		cross apply (select cast('<x>'+replace(a.ASList,';','</x><x>')+'</x>' as xml) ASXML) x
		left outer join #VesselCTB c on v.vessel=c.vessel

alter table #VesselASCTB add primary key (SortOrder)


--*****************************************************************************
--*****************************************************************************
--** Return Tables
--*****************************************************************************
--*****************************************************************************


--ASCT+B table, one row per vessel (the one with PECAM1 biomarker)
select *
	from #VesselASCTB
	where BGene1='PECAM1 (CD31)'
	order by SortOrder

--ASCT+B table, full (all cell types and biomarkers)
select *
	from #VesselASCTB
	order by SortOrder


--Extended vascular table
select *
	from #Vessel
	order by PathFromHeart

--Cell types and biomarker rules
select *
	from #CellTypeBiomarker
	order by RuleID

--Vessel cell types and biomarkers
select c.*, v.PathFromHeart
	from #VesselCTB c
		inner join #Vessel v
			on c.Vessel=v.Vessel
	order by v.PathFromHeart, CT1, CT2, CT3, BGene1

--Body part mappings
select BodyPart, BodyPartID, Vessel, ASLabel VesselLabel, replace(ASID,'fma','FMA:') VesselID, VesselType, VesselSubType, PortalSystem, FTU
	from #Vessel
	order by 1, 3

--Body part mappings summary
select BodyPart, count(*) Vessels
	from #Vessel
	group by BodyPart
	order by 1


--*****************************************************************************
--*****************************************************************************
--** Cleanup
--*****************************************************************************
--*****************************************************************************

/*
drop table #Vessel
drop table #CellTypeBiomarker
drop table #VesselCellType
drop table #VesselCellTypeBiomarker
drop table #VesselCTB
drop table #VesselASCTB
*/

