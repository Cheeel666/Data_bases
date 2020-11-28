create or replace function get_score_by_id(id_s integer)
returns text
as
$$
    score = plpy.execute(f"select score from studentassessment where id_student = '{id_s}' limit 1;")
    return score[0]["score"]
$$ language plpython3u;

select * from get_score_by_id(11391);

-- Защита: написать через агрегатную функцию.
create or replace function get_avg_score(double precision,id_s integer)
returns float
as
$$
global summ
l = plpy.execute(f"select avg(date_submitted) as average from studentassessment where id_student = '{id_s}' group by id_student")
return l[0]["average"]
$$ language plpython3u;

create or replace aggregate avg_score(integer)(
    SFUNC = get_avg_score,
    STYPE = float
);

select * from get_avg_score(11391);
select avg_score(11391);


create or replace function get_students_with_score(scor integer)
returns table (id_assessment int, id_student int, date_submitted int, is_banked int, score int)
as
$$
res = []
l = plpy.execute("select * from studentassessment")
for i in l:
    if i['score'] == scor:
        res.append(i)
return res
$$ language plpython3u;

select * from get_students_with_score(78);

--4) Хранимую процедуру CLR,
--5) Триггер CLR,
--6) Определяемый пользователем тип данных CLR

select * into test from studentassessment limit 5;

create or replace procedure delete_by_id(id_s integer)
as
$$
plpy.execute(f"delete from test where id_student = '{id_s}'")
$$ language plpython3u;

call delete_by_id(32885);
call delete_by_id(38053);
--
create table test_backup(
    id_assessment int,
    id_student int,
    date_submitted int,
    is_banked int,
    score int
);

create or replace function backup_test()
returns trigger
as
$$
bu = plpy.prepare("insert into test_backup(id_assessment, id_student, date_submitted, is_banked, score) values($1, $2, $3, $4, $5);",
["int", "int", "int", "int", "int"])
val = TD['old']
rv = plpy.execute(bu, [val["id_assessment"],val["id_student"], val["date_submitted"], val["is_banked"], val["score"]])
return TD['new']
$$ language plpython3u;

create trigger backup_test
before delete on test
for each row
execute procedure backup_test();

---

create type test_student as (
    id_student int,
    gender varchar,
    region varchar
);

create or replace function get_type_by_id(id_s int)
returns test_student
as
$$
l = plpy.execute(f"select id_student, gender, region from studentinfo where id_student = '{id_s}'")
return (l[0]['id_student'],l[0]['gender'], l[0]['region'])
$$ language plpython3u;

select * from get_type_by_id(11391);
