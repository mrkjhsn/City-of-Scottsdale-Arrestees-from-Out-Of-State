--create temp table that:
-- 1) extracts two digit State of arrestee from the "City of Arrestee" field which includes City, State, Zip and
-- 2) excludes all arrestees who are residens of Arizona and
-- 3) excludes all records not in standard format(City, State, Zip)

select  
	SUBSTRING(
		[City of Arrestee]
		,charindex(',',[City of Arrestee]) +2
		,2
	) as State_of_Arrestee
	,count(*) as _Count_
into #State_of_Arrestee
from [dbo].[spd_PDArrests$]
where [City of Arrestee] not like '%, AZ %' and --AZ arrestees excluded
	[City of Arrestee] like '%, __ _____' --messy, non-standard records excluded
group by SUBSTRING(
		[City of Arrestee]
		,charindex(',',[City of Arrestee]) +2
		,2
	)
	
--temp table above is used to find the percent of total arrestees in Scottsdale from non-AZ states
select  
	A.State_of_Arrestee
	,A._Count_
	,B._Total_
	,convert(varchar,
		round(
			convert(float,A._Count_)/convert(float,B._Total_)*100
			,2
		)
	)  + '%' as _Percent_
from #State_of_Arrestee as A
cross join (select sum(_Count_) as _Total_
			from #State_of_Arrestee
			) as B
group by A.[State_of_Arrestee]
		,A._Count_
		,B._Total_
		,convert(varchar,
		round(
			convert(float,A._Count_)/convert(float,B._Total_)*100
			,2
		)
	)
order by A._Count_ desc