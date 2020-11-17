---1.Инструкция SELECT, использующая предикат сравнения.
SELECT DISTINCT C1.id_student, C1.region, C2.date_registration
FROM studentInfo C1 JOIN studentRegistration AS C2 ON C2.id_student = C1.id_student
WHERE C1.region = 'Scotland'
ORDER BY C1.id_student

---2.Инструкция SELECT, использующая предикат BETWEEN.


SELECT DISTINCT C1.id_student, C1.region, C2.date_registration
FROM studentInfo C1 JOIN studentRegistration AS C2 ON C2.id_student = C1.id_student
WHERE C2.date_registration between '-52' AND '12'
ORDER BY C1.id_student

---3.Инструкция SELECT, использующая предикат LIKE.
SELECT DISTINCT studentInfo.id_student, studentInfo.region, studentRegistration.date_registration
FROM studentInfo JOIN studentRegistration ON studentInfo.id_student = studentRegistration.id_student
WHERE studentInfo.region LIKE '%South%'
---4.Инструкция SELECT, использующая предикат IN с вложенным подзапросом.

select id_student, gender, region, region
from studentinfo
where id_student in(
	select id_student
	from studentregistration
	where code_module = 'AAA'
)and gender = 'F'

select studentinfo.id_student, gender, region, region, studentregistration.code_module
from studentinfo join studentregistration on studentregistration.id_student = studentinfo.id_student
where studentinfo.id_student in(
	select studentinfo.id_student
	from studentregistration
	where code_module = 'AAA'
)and gender = 'F'

---5.Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.

select SV.id_student, sum(SV.sum_click)
from studentvle as SV
where exists(
	select S.id_student
	from studentInfo S left outer join studentvle on s.id_student = studentvle.id_student
	where S.gender = 'F'
)
group by SV.id_student

---6.Инструкция SELECT, использующая предикат сравнения с квантором.

select id_student, gender, region
from studentinfo
where id_student > ALL
(
	select id_student
	from studentinfo
	where gender = 'M'
)

---7.Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
select avg(sumClick) as "built-in AVG", sum(sumClick)/count(sumClick) as "Calc AVG"
from
(
	select id_student, (id_student/count(sum_click)) as sumClick from studentvle
	group by id_student
) as Count_avg_click



--- 8.Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
---
select id_student, gender,
(
	select avg(date_registration)
	from studentregistration
	where studentinfo.id_student = studentregistration.id_student
) as avgDate
from studentinfo
where gender = 'F'
---9.Инструкция SELECT, использующая простое выражение CASE.

select id_student, date_unregistration,
	case date_unregistration
		when (SELECT max(date_unregistration) from studentRegistration) then 'Lastest'
		when (SELECT min(date_unregistration) from studentRegistration) then 'Fastest'
		else 'unregistration'
	end as k
from studentRegistration
order by date_unregistration
---10.Инструкция SELECT, использующая поисковое выражение CASE.
select id_student,
	case
		when code_module = 'AAA' then 'lol'
		when code_module = 'BBB' then 'kek'
		else 'other module'
	end as k
from studentinfo
---11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.

select id_site, week_from, week_to
into studying
from vle
where week_from <> 0 and week_to <> 0;
select * from studying

-- 12.Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.

select studentInfo.id_student as "Student", ST.studytime as studytime
from studentInfo join(
	select studentvle.id_student, SUM(studentvle.sum_click) as studytime
	from studentvle
	group by studentvle.id_student
	order by studytime DESC
	limit 5
) as ST on studentInfo.id_student = ST.id_student
union
select studentInfo.id_student as "StudentActivity", AT.activitydate as activity
from studentInfo join(
	select studentassessment.id_student, MIN(studentassessment.date_submitted)
	as activitydate
	from studentassessment
	group by studentassessment.id_student
	order by activitydate DESC
	limit 5
) as AT on studentinfo.id_student = AT.id_student

--13.Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.

select 'By clicks' AS Criteria, studentinfo.id_student
from studentInfo
where id_student =
(
	select id_student from studentvle
	group by id_student
	having sum(sum_click) =
	(
		select max(sc)
		from
		(
				select sum(sum_click) as sc
				from studentvle
				group by id_student
		)as CL
	)
)
UNION
select 'By time(latest)' AS Criteria, studentinfo.id_student
from studentInfo
where id_student =
(
	select id_student from studentvle
	group by id_student
	having sum(dt) =
	(
		select max(dt)
		from
		(
			select sum(dt) as DT
			from studentvle
			group by id_student
		)as LDT
	)
)
--- ТЕСТ()
select * from studentInfo
where id_student = (
	select max(id_student)
	from studentinfo
)
--14.Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.

select S.id_student, MIN(SA.date_submitted) as min_date, max(SA.date_submitted) as max_date, SA.score
from studentInfo S left outer join studentassessment SA on S.id_student = SA.id_student where gender = 'M'
group by S.id_student, SA.score
--
--15.Инструкция SELECT, консолидирующая данные с помощью предложения GROUPBYи предложенияHAVING.

select id_student, avg(score) as "average score"
from studentAssessment SA
group by id_student having avg(score) >
(
	select avg(score) as Ascore from studentAssessment
)

--16.Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.


INSERT INTO studentInfo (code_module, code_presentation, id_student, gender, region, highest_education,
				   imd_band, age_band, num_of_prev_attempts, studied_credits, disability, final_request)
VALUES('AA', '2020N', 2716796, 'M', 'Russia', 'BMSTU-IU7(Bachelor)', '50-70%','0-35', 0,1, 'N','PASS')
select * from studentInfo
where id_student = (
	select max(id_student)
	from studentinfo
)
--
-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.

INSERT INTO vle(id_site, code_module, code_presentation, activity_type, week_from, week_to)
select(
	select max(id_site) + 1
	from vle
), 'AAA', '2020N', 'lab', 0, 15

--
-- 18.Простая инструкция UPDATE.

update studentinfo
set region = 'Znamensk'
where id_student = (select max(id_student) from studentInfo)

--19.Инструкция UPDATE со скалярным подзапросом в предложении SET.

UPDATE studentinfo SET studied_credits =
(
SELECT AVG(studied_credits) FROM studentInfo
)
WHERE id_student = (
select max(id_student) from studentInfo
)

--20.Простая инструкция DELETE.

delete from studentInfo
where id_student IS NULL

--21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.

DELETE FROM studentvle WHERE id_site IN
(
SELECT studentvle.id_site
FROM studentvle LEFT OUTER JOIN studentinfo ON studentvle.id_student = studentInfo.id_student
WHERE studentvle.id_site IS NULL
)

--- 22.Инструкция SELECT, использующая простое обобщенное табличное выражение

WITH CTE(id_student, dt) AS
(
	SELECT id_student, dt
	from studentvle
	where DT > 0
	group by id_student, dt
)

SELECT AVG(dt) AS "Average date"
from CTE

--- 23.Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
CREATE TEMP TABLE test (
EmployeeID smallint NOT NULL,
FirstName varchar NOT NULL,
LastName varchar NOT NULL,
Subject varchar NOT NULL,
Hours int,
ManagerID int NULL,
PRIMARY KEY (EmployeeID)
);

INSERT INTO test VALUES (1, N'Иван', N'Петров', N'Базы данных',5, NULL) ;
INSERT INTO test VALUES (2, N'Андрей', N'Глотов', N'Операционные системы', 10, NULL);


WITH RECURSIVE RecOvertaking (EmployeeID,FirstName, LastName,Subject, Hours, Level) AS
(
SELECT EmployeeID,FirstName, LastName,Subject, Hours, 0 as level
from test
WHERE ManagerID is NULL
UNION ALL

SELECT test.EmployeeID,test.FirstName, test.LastName,test.Subject, test.Hours, Level + 1
FROM test join RecOvertaking RT ON test.ManagerID = RT.EmployeeID
)
SELECT EmployeeID,FirstName, LastName,Subject, Hours, Level  FROM RecOvertaking ;

--- 24.Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
-- Для каждой заданной группы продукта вывести среднее значение цены

SELECT SV.id_student, SV.id_site,
SV.sum_click, S.id_student,
AVG(SV.sum_click) OVER(PARTITION BY SV.id_student, SV.id_site) AS AvgPrice,
MIN(SV.sum_click) OVER(PARTITION BY SV.id_student, SV.id_site) AS MinPrice,
MAX(SV.sum_click) OVER(PARTITION BY SV.id_student, SV.id_site) AS MaxPrice
FROM studentvle SV LEFT OUTER JOIN studentInfo S ON sv.id_student = s.id_student

--- 25.Оконные фнкции для устранения дублей
--- удаляет дупликаты, содержащие lastname (одинаковые) в темповой таблице



INSERT INTO test VALUES (3, N'Андрей', N'Глотовы', N'Операционные системы', 10, NULL);
INSERT INTO test VALUES (4, N'Андрей', N'Глотовы', N'Операционные системы', 10, NULL);

WITH tmp AS (
     DELETE
     FROM test
     RETURNING *
), rown AS (
     SELECT *, ROW_NUMBER() OVER(PARTITION BY lastname) n
     FROM tmp
 )
INSERT INTO test
SELECT employeeid, firstname, lastname, subject
FROM rown
WHERE n = 1;
select * from test
--обобщенное табличное выражение, оконные функции - что такое и чем отличаются от других функций.
--
