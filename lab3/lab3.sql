-- 1. Скалярная функция(возвращает 1 число)

-- возвращает среднюю дату сдачи работ
CREATE OR REPLACE  FUNCTION get_avg_date()
	returns int
	language plpgsql
as
$$
DECLARE
	i integer;
BEGIN
	select avg(studentassessment.date_submitted)
	into i
	from studentassessment;
	return i;
end;
$$;

select get_avg_date();

-- 2. Подставляемая табличная функция


CREATE OR REPLACE FUNCTION get_students (gender varchar,amount INTEGER)
RETURNS SETOF studentinfo
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
    	execute format('select *
					   from studentinfo
					   where gender = ''F''
					   limit $1
					   ')
					   using amount;
END;
$$;
select * from get_students('F',1);


-- 3. многооператорная табличная функция(возвращает набор значений)

-- для каждого человека возвращает дату сдачи - среднюю дату сдачи, минимальную и максимальную.
CREATE OR REPLACE  FUNCTION get_avg()
	returns table (id_student integer, aveg integer, minn integer, maxx integer)
	language plpgsql
as
$$
DECLARE
	aveg integer;
	minn integer;
	maxx integer;
BEGIN
	select avg(studentassessment.date_submitted)
	into aveg
	from studentassessment;

	select min(studentassessment.date_submitted)
	into minn
	from studentassessment;

	select max(studentassessment.date_submitted)
	into maxx
	from studentassessment;
	return query
		select studentassessment.id_student as id, (studentassessment.date_submitted - aveg) as aveg_pass, minn, maxx
			from studentassessment
			order by studentassessment.id_student;
end;
$$;

select get_avg();


-- 4. рекурсивная функция


create or replace function recursive_f(ct int,pr int)
returns table (counter int, product int)
language plpgsql
as
$$
begin
	return query select ct, pr;
	if ct < 10 then
		return query select * from recursive_f(ct + 1, (ct + 1) * (ct + 1));
	end if;
end;
$$;

select * from recursive_f(1,1)

-- 1. Хранимая процедура с параметрами или без

CREATE OR REPLACE PROCEDURE show_student(id_s INTEGER)
    LANGUAGE plpgsql
AS
$$
BEGIN
	delete from test
	where employeeid = id_s;
END;
$$;

call show_student(3)

-- 2.
