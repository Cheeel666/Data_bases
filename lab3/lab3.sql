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
-- проверено, все ок

CREATE OR REPLACE FUNCTION get_students (amount INTEGER)
RETURNS SETOF studentinfo
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
    	execute format('select *
					   from studentinfo
					   limit $1
					   ')
					   using amount;
END;
$$;
select * from get_students(1);


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
		select studentassessment.id_student as id,
		 (studentassessment.date_submitted - aveg) as aveg_pass, minn, maxx
			from studentassessment
			order by studentassessment.id_student;
end;
$$;

select get_avg();


-- 4. рекурсивная функция
-- ПЕРЕДЕЛАНО, В СООТВЕТСТВИИ С ЗАЩИТОЙ: работает
-- главное, опять же, подобрать границы, чтобы не было переполнения стека
--
drop function recursive_f;
create or replace function recursive_f(ct int,pr int)
returns table (min_id int, max_id int, id_s int)
language plpgsql
as
$$
begin
	return query select ct, pr, temp4rec.id_student from temp4rec where temp4rec.id_student = ct ;
	if ct < pr then
		return query select * from recursive_f(ct + 1,pr);
	end if;
end;
$$;

select * from recursive_f(11300,11400);
select * from recursive_f(28000, 28500);
select * from temp4rec;

-- 1. Хранимая процедура с параметрами или бе
-- там в названии show, но на самом деле это delete, мне лень менять!
-- проверил, все работает.
select * into test from studentassessment limit 5;
CREATE OR REPLACE PROCEDURE show_student(id_s INTEGER)
    LANGUAGE plpgsql
AS
$$
BEGIN
	delete from test
	where id_student = id_s;
END;
$$;
call show_student(31604);
call show_student(28400);
call show_student(32885);
call show_student(38053);
select * from test;
-- 2.
-- ПЕРЕПРОВЕРЕНО, РАБОТАЕТ
-- важно поставить не слишком большие границы, иначе переполняется стек
select * into temp_t from studentassessment limit 5;

select * from temp_t;

create or replace procedure rec_proc(new_date int, id_l int, id_h int) as
$$
begin
	if (id_l <= id_h)
then
	update temp_t
	set date_submitted = new_date
	where id_student = id_l;
	call rec_proc(new_date, id_l + 1, id_h);
end if;
end;
$$ language plpgsql;

call rec_proc(0,31600,31650);
select * from temp_t;
-- 3.
-- ПРОВЕРЕНО ДЛЯ ЗАЩИТЫ - работает

select * into temp_t from studentassessment limit 5;

select * from temp_t;
create or replace procedure update_date(ib int, target int) as
$$
declare cur cursor
	for select *
	from temp_t
	where date_submitted = target;
	row record;
begin
	open cur;
	loop
		fetch cur into row;
		exit when not found;
		update temp_t
		set date_submitted = date_submitted + ib
		where temp_t.id_student = row.id_student;
	end loop;
	close cur;
end
$$language plpgsql;

call update_date(1, 18);
select * from temp_t;

-- 4.

create or replace procedure table_info() as
$$
declare
	cur cursor
	for select table_name, size from
	(
		select table_name, pg_relation_size(cast(table_name as varchar)) as size
		from information_schema.tables
		where table_schema not in ('information_schema', 'pg_catalog')
		order by size desc
	) as tmp;
	row record;
begin
	open cur;
	loop
		fetch cur into row;
		exit when not found;
		raise notice '{table : %} {size : %}', row.table_name, row.size;
	end loop;
	close cur;
end
$$ language plpgsql;

call table_info();

----- ниже представлена правильная переделка(в соответствии с защитой)
------------   ПРАВИЛЬНАЯ ПЕРЕДЕЛКА (82мс)
create or replace procedure drop_table_like() as
$$
declare
	tmp_table_name text;
	cur cursor for
	select tablename from pg_tables where schemaname = 'public';
begin
	open cur;
	loop
		fetch cur into tmp_table_name;
		exit when not found;

		if tmp_table_name like 'temp%' then
			execute 'DROP TABLE IF EXISTS ' || tmp_table_name || ';';
			raise notice 'Deleted!';
		end if;
	end loop;
	close cur;
end;
$$ language plpgsql;
--- БЕЗ КУРСОРА (62мс):

CREATE OR REPLACE PROCEDURE drop_by_name(del_name VARCHAR)
LANGUAGE plpgsql
AS
$$
declare
table_rec rec;
BEGIN
for table_rec in (
select relname from pg_class
where relnamespace = (
select oid
from pg_namespace
where nspname = 'public'
)
and relname LIKE del_name
)
loop
execute 'drop table '||table_rec.relname||' cascade';
end loop;
END;
$$;


select * into temp_studentinfo from studentinfo;

create type rec as (
relname VARCHAR
);


create table temp_t(
lol integer);

call drop_by_name('temp%')
call drop_table_like()
--
-- ЗАЩИТА : процедура выше без курсора и замерить время
--триггер after
--триггер срабатывает при смене is_banked в table temp_t, логи в таблицу  test_log_table
create or replace function log_func()
returns trigger as
$$
begin
	insert into test_log_table(id_for_change,new_is_banked,old_is_banked, dt)
	values (new.id_student,new.is_banked,old.is_banked,current_timestamp);
	return new;
end;
$$ language plpgsql;


create trigger upd_trigger
	after update of is_banked on temp_t
	for each row
	execute procedure log_func();


select * from temp_t;
update temp_t
set is_banked = 104 where id_student = 1;

select * from test_log_table;
--
-- ТРИГГЕР insteard of
-- вместо значений в temp_t1 записывает их в studying_audits
create table temp_t1(
	id_student INTEGER,
	date_submitted integer
);

create table studying_audits(
	id_student INTEGER,
	date_submitted_old INTEGER,
	date_submitted_new INTEGER,
	changed_on TIMESTAMP(6) NOT NULL
);

--
create or replace function log_dt_insert()
	returns trigger
	language plpgsql
as
$$
begin
	insert into studying_audits(id_student, date_submitted_old, date_submitted_new, changed_on)
	values (new.id_student, null, new.date_submitted, now());
	return old;
end;
$$;

create trigger dt_change_insert
	before insert
	on temp_t1
	for each row
	execute procedure log_dt_insert();
--
select * from studying_audits;
insert into temp_t1 values(2,3);
select * from temp_t1;




	-- 2, 4,2B
