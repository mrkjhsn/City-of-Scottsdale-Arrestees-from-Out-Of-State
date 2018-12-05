--create temp table that:
-- 1) extracts two digit State of arrestee from the "City of Arrestee" field which includes City, State, Zip and
-- 2) excludes all arrestees who are residens of Arizona and
-- 3) excludes all records not in the standard City, State, Zip format

select  
	case when [City of Arrestee] like '%[0-9][0-9][0-9][0-9][0-9]%' 
		then left([City of Arrestee], len([City of Arrestee]) -6)
	end as City_of_Arrestee
	,count(*) as _Count_
into #City_of_Arrestee
from [dbo].[spd_PDArrests$]
where [City of Arrestee] not like '%, AZ %' and --AZ arrestees excluded
	  [City of Arrestee] not like '%Glendale%' and
	  [City of Arrestee] not like '%Phoenix%' and
	  [City of Arrestee] not like ',%' and
	  [City of Arrestee] is not null  --not sure why 27 null values are still being returned
group by 
	case when [City of Arrestee] like '%[0-9][0-9][0-9][0-9][0-9]%' 
		then left([City of Arrestee], len([City of Arrestee]) -6)
	end
	
 select * from #City_of_Arrestee
 order by _Count_ desc

 drop table #City_of_Arrestee


--temp table above is used to find the percent of total arrestees in Scottsdale from non-AZ cities
select  
	A.City_of_Arrestee
	,A._Count_
	,B._Total_
	,convert(varchar,
		round(
			convert(float,A._Count_)/convert(float,B._Total_)*100
			,2
		)
	)  + '%' as _Percent_
from #City_of_Arrestee as A
cross join (select sum(_Count_) as _Total_
			from #City_of_Arrestee
			) as B
group by A.City_of_Arrestee
		,A._Count_
		,B._Total_
		,convert(varchar,
		round(
			convert(float,A._Count_)/convert(float,B._Total_)*100
			,2
		)
	)
order by A._Count_ desc