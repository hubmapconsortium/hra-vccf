--#############################################################################
--#############################################################################
--## HRA-VCCF Update Derived Fields
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


-- Load Vessel data into a temp table
select *
	into #vessel
	from Vessel

-- Set default values for derived fields
update #vessel
	set VesselBaseName='',
		HasBranches=0,
		VirtualVesselOfList='',
		VirtualVesselOfCount=0,
		VirtualInstances=1,
		VirtualPath='',
		PathFromHeart='',
		PathFromHeartWithIDs=''


--*****************************************************************************
--*****************************************************************************
--** VesselBaseName, HasBranches
--*****************************************************************************
--*****************************************************************************


update #vessel
	set VesselBaseName = (
			case when charindex('#',Vessel)=0 then Vessel 
			else left(Vessel, charindex('#',Vessel)-2) 
			end
		)

update #vessel
	set HasBranches = (
			case when ForBranchesSee<>'' then 1
			when VesselBaseName in (select BranchesFrom from #vessel) then 1
			else 0
			end
		)


--*****************************************************************************
--*****************************************************************************
--** PathFromHeart, PathFromHeartWithIDs
--*****************************************************************************
--*****************************************************************************

--Get a list of parent-child vessels with IDs
select v.vessel, v.vessel v, v.branchesfrom b, v.vessel+';'+v.ASLabel+';'+v.ASID c, w.vessel+';'+w.ASLabel+';'+w.ASID d
	into #PathTemp
	from #vessel v inner join #vessel w on v.BranchesFrom=w.Vessel
create unique clustered index pk on #PathTemp(v)

--Pivot the list to create the paths
select p0.*, 
	isnull(p29.b+';','')+
	isnull(p28.b+';','')+
	isnull(p27.b+';','')+
	isnull(p26.b+';','')+
	isnull(p25.b+';','')+
	isnull(p24.b+';','')+
	isnull(p23.b+';','')+
	isnull(p22.b+';','')+
	isnull(p21.b+';','')+
	isnull(p20.b+';','')+
	isnull(p19.b+';','')+
	isnull(p18.b+';','')+
	isnull(p17.b+';','')+
	isnull(p16.b+';','')+
	isnull(p15.b+';','')+
	isnull(p14.b+';','')+
	isnull(p13.b+';','')+
	isnull(p12.b+';','')+
	isnull(p11.b+';','')+
	isnull(p10.b+';','')+
	isnull(p9.b+';','')+
	isnull(p8.b+';','')+
	isnull(p7.b+';','')+
	isnull(p6.b+';','')+
	isnull(p5.b+';','')+
	isnull(p4.b+';','')+
	isnull(p3.b+';','')+
	isnull(p2.b+';','')+
	isnull(p1.b+';','')+
	(case when p0.v=p0.b then p0.v else p0.b+';'+p0.v end) PathFromHeart,
	isnull(p29.d+';','')+
	isnull(p28.d+';','')+
	isnull(p27.d+';','')+
	isnull(p26.d+';','')+
	isnull(p25.d+';','')+
	isnull(p24.d+';','')+
	isnull(p23.d+';','')+
	isnull(p22.d+';','')+
	isnull(p21.d+';','')+
	isnull(p20.d+';','')+
	isnull(p19.d+';','')+
	isnull(p18.d+';','')+
	isnull(p17.d+';','')+
	isnull(p16.d+';','')+
	isnull(p15.d+';','')+
	isnull(p14.d+';','')+
	isnull(p13.d+';','')+
	isnull(p12.d+';','')+
	isnull(p11.d+';','')+
	isnull(p10.d+';','')+
	isnull(p9.d+';','')+
	isnull(p8.d+';','')+
	isnull(p7.d+';','')+
	isnull(p6.d+';','')+
	isnull(p5.d+';','')+
	isnull(p4.d+';','')+
	isnull(p3.d+';','')+
	isnull(p2.d+';','')+
	isnull(p1.d+';','')+
	(case when p0.v=p0.b then p0.c else p0.d+';'+p0.c end) PathFromHeart2
into #PathFromHeart
from #PathTemp p0
	left outer join #PathTemp p1 on p1.v=p0.b and p1.b<>p1.v
	left outer join #PathTemp p2 on p2.v=p1.b and p2.b<>p2.v
	left outer join #PathTemp p3 on p3.v=p2.b and p3.b<>p3.v
	left outer join #PathTemp p4 on p4.v=p3.b and p4.b<>p4.v
	left outer join #PathTemp p5 on p5.v=p4.b and p5.b<>p5.v
	left outer join #PathTemp p6 on p6.v=p5.b and p6.b<>p6.v
	left outer join #PathTemp p7 on p7.v=p6.b and p7.b<>p7.v
	left outer join #PathTemp p8 on p8.v=p7.b and p8.b<>p8.v
	left outer join #PathTemp p9 on p9.v=p8.b and p9.b<>p9.v
	left outer join #PathTemp p10 on p10.v=p9.b and p10.b<>p10.v
	left outer join #PathTemp p11 on p11.v=p10.b and p11.b<>p11.v
	left outer join #PathTemp p12 on p12.v=p11.b and p12.b<>p12.v
	left outer join #PathTemp p13 on p13.v=p12.b and p13.b<>p13.v
	left outer join #PathTemp p14 on p14.v=p13.b and p14.b<>p14.v
	left outer join #PathTemp p15 on p15.v=p14.b and p15.b<>p15.v
	left outer join #PathTemp p16 on p16.v=p15.b and p16.b<>p16.v
	left outer join #PathTemp p17 on p17.v=p16.b and p17.b<>p17.v
	left outer join #PathTemp p18 on p18.v=p17.b and p18.b<>p18.v
	left outer join #PathTemp p19 on p19.v=p18.b and p19.b<>p19.v
	left outer join #PathTemp p20 on p20.v=p19.b and p20.b<>p20.v
	left outer join #PathTemp p21 on p21.v=p20.b and p21.b<>p21.v
	left outer join #PathTemp p22 on p22.v=p21.b and p22.b<>p22.v
	left outer join #PathTemp p23 on p23.v=p22.b and p23.b<>p23.v
	left outer join #PathTemp p24 on p24.v=p23.b and p24.b<>p24.v
	left outer join #PathTemp p25 on p25.v=p24.b and p25.b<>p25.v
	left outer join #PathTemp p26 on p26.v=p25.b and p26.b<>p26.v
	left outer join #PathTemp p27 on p27.v=p26.b and p27.b<>p27.v
	left outer join #PathTemp p28 on p28.v=p27.b and p28.b<>p28.v
	left outer join #PathTemp p29 on p29.v=p28.b and p29.b<>p29.v

--Update the vessel table with the results
update v
	set v.PathFromHeart=p.PathFromHeart, v.PathFromHeartWithIDs=p.PathFromHeart2
	from #vessel v
		inner join #PathFromHeart p
			on v.vessel=p.vessel

--Cleanup
drop table #PathTemp
drop table #PathFromHeart


--*****************************************************************************
--*****************************************************************************
--** Virtual vessel instances and paths
--*****************************************************************************
--*****************************************************************************


--Set the default values
update #vessel
	set VirtualVesselOfList='',
		VirtualVesselOfCount=0,
		VirtualInstances=1,
		VirtualPath=''


--Get the list of vessels that the virtual vessel is merging
update v
	set v.VirtualVessel=1, 
		v.VirtualVesselOfCount=t.VirtualVesselOfCount, 
		v.VirtualVesselOfList=t.VirtualVesselOfList
	from #vessel v
		inner join (
			select ForBranchesSee, count(*) VirtualVesselOfCount, substring((
					select ';'+b.vessel
					from #vessel b
					where b.ForBranchesSee=a.ForBranchesSee
					order by b.vessel
					for xml path ('')
				),2,999999) VirtualVesselOfList
			from #vessel a
			where ForBranchesSee<>''
			group by ForBranchesSee
		) t on v.Vessel=t.ForBranchesSee


--Handle the special case of virtual vessels that are not explicitly defined
update #vessel
	set VirtualVesselOfCount=abs(VirtualVessel),
		VirtualVesselOfList='(x'+cast(abs(VirtualVessel) as varchar(10))+') '+Vessel
	where VirtualVessel<-1


--Split the PathFromHeart into a list of ancestor nodes leading back to the tree root
select t.*, VirtualVessel, VirtualVesselOfList, VirtualVesselOfCount, VirtualInstances, VirtualPath
	into #VesselVirtualPaths
	from (
		select a.Vessel, r.x.value('.','varchar(200)') Ancestor, isnull(row_number() over (partition by a.Vessel order by r.x),-1) PathIndex
		from #vessel a
			cross apply (select cast('<x>'+replace(a.PathFromHeart,';','</x><x>')+'</x>' as xml) x) t
			cross apply t.x.nodes('x') as r(x)
	) t inner join #vessel v on t.Ancestor=v.Vessel

alter table #VesselVirtualPaths add primary key (Vessel, PathIndex)


--Handle the base case for virtual vessels
update #VesselVirtualPaths 
	set VirtualInstances=VirtualVesselOfCount, VirtualPath=VirtualVesselOfList
	where VirtualVesselOfCount>0


--Start with the roots and iteratively expand the paths going down the trees
declare @i int
select @i=2
while (@i<30)
begin
	update a
		set a.VirtualInstances=(
				case when a.VirtualVessel=-1 then isnull(nullif(a.VirtualVesselOfCount,0),1)
					else a.VirtualInstances*b.VirtualInstances
					end),
			a.VirtualPath=(
				case when a.VirtualVessel=-1 then a.VirtualVesselOfList
					else b.VirtualPath+(case when b.VirtualPath='' or a.VirtualPath='' then '' else '|' end)+a.VirtualPath
					end)
		from #VesselVirtualPaths a
			inner join #VesselVirtualPaths b
				on a.Vessel=b.Vessel and b.PathIndex=a.PathIndex-1
		where a.PathIndex=@i
	select @i=@i+1
end


--Update the vessel table with the results
update a
	set a.VirtualInstances=b.VirtualInstances, a.VirtualPath=b.VirtualPath
	from #vessel a
		inner join #VesselVirtualPaths b
			on a.Vessel=b.Vessel and b.Vessel=b.Ancestor

--Cleanup
drop table #VesselVirtualPaths


--*****************************************************************************
--*****************************************************************************
--** Update the actual Vessel table's derived fields
--*****************************************************************************
--*****************************************************************************


update a
	set a.VesselBaseName=b.VesselBaseName,
		a.HasBranches=b.HasBranches,
		a.VirtualVesselOfList=b.VirtualVesselOfList,
		a.VirtualVesselOfCount=b.VirtualVesselOfCount,
		a.VirtualInstances=b.VirtualInstances,
		a.VirtualPath=b.VirtualPath,
		a.PathFromHeart=b.PathFromHeart,
		a.PathFromHeartWithIDs=b.PathFromHeartWithIDs
	from Vessel a
		inner join #vessel b
		on a.vessel=b.vessel


