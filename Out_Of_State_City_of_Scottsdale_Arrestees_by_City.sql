--create temp table that:
-- 1) extracts two digit State of arrestee from the "City of Arrestee" field which includes City, State, Zip and
-- 2) excludes all arrestees who are residens of Arizona and
-- 3) excludes all records not in the standard City, State, Zip format


select count([Arrest Date]) as _Count_
	,[City of Arrestee]
into #City_of_Arrestee
from
		(select     -- my first opportunity to use "case when"
			case when [City of Arrestee] like '%[0-9][0-9][0-9][0-9][0-9]%' --since not all "City of Arrestees" had 5 digit zip I wanted to select these, then strip out the 5 zip so I could group on just the city
				then left([City of Arrestee], len([City of Arrestee]) -6)
			end as [City of Arrestee]
		,[Arrest Date]
		from [dbo].[spd_PDArrests$]
		where [City of Arrestee] not like '%, AZ %' and --AZ arrestees excluded
			  [City of Arrestee] not like '%Glendale%' and --strips out "City of Arrestee" values that only include "Glendale" without AZ at end
			  [City of Arrestee] not like '%Phoenix%' and  --strips out "City of Arrestee" values that only include "Phoenix" without AZ at end
			  [City of Arrestee] not like ',%' --strips out "City of Arrestee" values that only include "," without AZ at end
		) as A
where [City of Arrestee] is not null  --originally I had this included within the "from" statement above, but that wasn't excluding nulls since it was checking against a calculated field
group by [City of Arrestee]
	

--temp table above is used to find the percent of total arrestees in Scottsdale from non-AZ cities
select  
	A.[City of Arrestee]
	,A._Count_
	,B._Total_
	,convert(varchar,
		round(
			convert(float,A._Count_)/convert(float,B._Total_)*100
			,2
		)
	)  + '%' as _Percent_
from #City_of_Arrestee as A
cross join (
			select sum(_Count_) as _Total_
			from #City_of_Arrestee
			) as B
order by A._Count_ desc
