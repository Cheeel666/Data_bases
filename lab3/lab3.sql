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
select * from temp_t;
call rec_proc(12,11390,11395);

-- 3.

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

call update_date(1, 22);
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

--
create table if not exists changes
(
	change_id int not null,
	change_data text not null
);

create or replace function log_func()
returns trigger as
$$
begin
	insert into changes(change_id, change_data)
	values (new.id, current_timestamp);
	return new;
end;
$$ language plpgsql;

create trigger upd_trigger
	after update of date_submitted on temp_t
	for each row
	execute procedure log_func();


--


create table studiyng_audits(
	id_student INTEGER,
	date_submitted_old INTEGER,
	date_submitted_new INTEGER,
	changed_on TIMESTAMP(6) NOT NULL
);
create or replace function log_dt_insert()
	returns trigger
	language plpgsql
as
$$
begin
	insert into studying_audits(id_student, date_submitted_old, date_submitted_new, changed_on)
	values (new.id_student, null, new.date_submitted_new, now());
	return old;
end;
$$;

create trigger dt_change_insert
	before insert
	on temp_t1
	for each row
	execute procedure log_dt_insert();


	-- 2, 4,2B,
	--метаданные - данные в темп таблицу
