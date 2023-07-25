#set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');
#set @@global.sql_mode := concat('ONLY_FULL_GROUP_BY,', @@global.sql_mode);

use dma_project_new;
select * from branch;
select * from individual_info_2;
select * from review;
select * from branch_services;
select* from complaint;
select * from parent_comapny_2;
select * from open_account;

#1) to find the review score of customers, branch, company from massachusetts having individual id between 5000-7000?
with cte as 
(select i.individual_id, i.region, r.review_score, r.Branch_ID
from individual_info_2 as i 
inner join 
review as r on i.Individual_ID = r.Individual_ID
),

cte2 as 
( select b.branch_id, b.company_id
from branch as b 
inner join 
review as r1 on b.Branch_ID = r1.Branch_ID)

select c1.individual_id, c1.region, c1.review_score, c2.branch_id, c2.company_id from
cte as c1 inner join cte2 as c2 on c1.branch_id = c2.branch_id
where c1.region = "Massachusetts" AND c1.Individual_ID between "5000" AND "7000";











#2) finding the number of customers who have opened the account in a specific time frame in a company?
with cte2 as 
( select o.individual_id, o.company_id, o.Account_Opening_date from
open_account as o),

cte3 as
(select p.Comapny_name, p.company_id from parent_comapny_2 as p)

select count(c2.individual_id) as no_of_customers, (c2.account_opening_date), c3.comapny_name from
cte2 as c2 
inner join 
cte3 as c3 on c2.company_id = c3.company_id
group by c2.Account_Opening_date; 








#3) to find the number of branches in each region alongwith there branch_id?
with cte4 as
( select r.individual_id, r.branch_id 
from review as r 
left join
branch as b on r.branch_id = b.branch_id)

select i.region, count(c4.branch_id) as total_branches, c4.branch_id
from individual_info_2 as i 
inner join 
cte4 as c4 on i.Individual_ID = c4.Individual_ID
group by i.region, c4.branch_id;







#4)if the rating is less than 1 then give title bad reviews, if it is between 1 and 3 give title moderate review and greater than 3 then good?
with cte6 as (
select review_score,
( case when r.review_score < 1 then "Bad Reviews" 
	   when r.review_score between 1 and 3 then "Moderate Reviews"
	   when r.review_score > 3 then "Good Reviews"
       else "No review is mentioned"
       end ) as review_bifurcation, r.branch_id
	from review as r),
    
    cte7 as
    (
    select b.branch_id, b.company_id, c6.review_bifurcation,c6.review_score
    from branch as b
    inner join cte6 as c6 
    on b.branch_id = c6.branch_id)
    
    select * from cte7
    order by cte7.review_score desc;
    
    
    
    
    
    
    
#5) finding customers whose complaint status is still in progress?
   with cte8 as 
   (select (r.branch_id) as total_branch, c.complaint_status, c.individual_id
   from review as r
   left join 
   complaint as c on r.individual_id = c.individual_id
   where c.complaint_status = "In progress")
   #group by c.complaint_status)
   
   select * from cte8;
   
  
  
  
  
  
  
  
  
  
  #6) to find the complaint_status which are in progress and Conversion rate for complaints still in progress via different modes of communication.
   with cte10 as (
   select (c.complaint_status), (c.Complaint_ID)
   from complaint as c where c.complaint_status = "In progress")
   
   select * from cte10;

   # to find how much complaints were submitted via web mode.
   with cte11 as (
   select (c1.submitted_via) as mode_of_submission, c1.Complaint_ID
   from complaint as c1 where c1.submitted_via = "web")
   
   select * from cte11;

#)Conversion rate for complaints still in progress via different modes of communication.
 select 
 count(case when c.submitted_via = "web" AND c.complaint_status = "in progress" then c.submitted_via else null end) / 
 count(case when c.complaint_status ='in progress' then c.complaint_status else null end) as web_to_in_progress_rate,
 count(case when c.submitted_via = "phone" AND c.complaint_status = "in progress" then c.submitted_via else null end) / 
 count(case when c.complaint_status ='in progress' then c.complaint_status else null end) as phone_to_in_progress_rate,
 count(case when c.submitted_via = "referral" AND c.complaint_status = "in progress" then c.submitted_via else null end) / 
 count(case when c.complaint_status ='in progress' then c.complaint_status else null end) as referral_to_in_progress_rate
 from complaint as c;
 
   
  #7) Specifying a limit for no of atm,deposit and withdrawal and the catgeorizing them in small scale.
  with cte12 as(
  select
 count(case when b1.branch_atm < 15 then b1.Branch_ID else null end) as Small_scale_atm_branch,
 count(case when b1.branch_deposit <10 then b1.branch_id else null end) as Small_scale_deposit_branch,
 count(case when b1.branch_withdrawal <10 then b1.branch_id else null end) as small_scale_withdrawal_branch
 from branch_services as b1)
 
 select * from cte12 as c12;











#8 Correlated Query: To find the top rated reviews by the cutomers.
select r.review_score as top_rating, r.individual_id, r.review_id 
from review as r where r.Review_Score in
( select max(r2.review_score) from review as r2 );












#9 Correlated Query: Finding number of customers from California region.
select (i.individual_id), i.region from individual_info_2 as i
where i.region = "California" AND
(select sum(i1.individual_id) from individual_info_2 as i1);









#10 Correlated subquery using exists: Customers opening account in the year 2005 aling with company id.
select o.Individual_ID, o.company_id from open_account as o
where exists 
(select o1.account_opening_date from open_account as o1 where o.individual_id= o1.Individual_ID AND  o1.account_opening_date = "2005");
