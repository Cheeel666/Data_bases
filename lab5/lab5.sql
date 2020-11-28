-- 1.Из таблиц базы данных, созданной в первой лабораторной работе,
-- извлечь данные в XML (MSSQL) или JSON(Oracle, Postgres).
-- Для выгрузки в XML проверить все режимы конструкции FOR XML
copy (select row_to_json(t)
from (select * from studentinfo) t)
to '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/info.json';

-- 2. Загрузка и выгрузка в базу
copy (select row_to_json(t)
from (select * from studentAssessment) t)
to '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/task2.json';

create temp table test_import(doc json);
copy test_import from '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/task2.json';

select t.*
from test_import, json_populate_record(null::studentAssessment, doc) as t;

-- 3. Создание таблицы с json данными
create table graduatestudents(
    id_student int NOT NULL,
    graduateInfo JSON,
    PRIMARY KEY(id_student)
);
insert into graduatestudents VALUES
(1, '{"firstname":"Ilya", "lastname":"chelyadinov","studytime":4}'),
(2, '{"firstname":"Efim", "lastname":"Sokolov","studytime":4}'),
(3, '{"firstname":"Artem", "lastname":"Sarkisov","studytime":4}'),
(4, '{"firstname":"Dmitri", "lastname":"Kovalev","studytime":4}'),
(5, '{"firstname":"Max", "lastname":"Zemskov","studytime":4}'),
(6, '{"firstname":"Pablo", "lastname":"Topor","studytime":4}'),
(7, '{"firstname":"Karim", "lastname":"Akhmetov","studytime":3}');

select * from graduatestudents;

-- 4.1 извлечь фрагмент из json документа
create temp table test_import4(doc json);
copy test_import4 from '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/4.1.json';
select * from test_import4;

-- ИЛИ
create or replace procedure import_from_json()
as
$$
begin
create table if not exists young_money(
    jstring JSON
);
delete from young_money;
copy young_money from '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/4.1.json';
end;
$$ language plpgsql;

call import_from_json();
select * from young_money;

--4.2 значение конкретных атрибутов json документа:
-- РАБОТАЕМ С plpython3u ТОЛЬКО ЧЕРЕЗ ВИРТУАЛКУ!!!!!!!!!!!!!!!!!!!!!!!

create or replace function get_atribute_4_2(nm varchar)
returns text
as
$$
import json
with open("/home/parallels/Desktop/example.json", "r") as read_file:
    l = json.load(read_file)
return l[nm]
$$ language plpython3u;
select * from get_atribute_4_2('money');

--- ИЛИ

create or replace function get_atribute4_2()
RETURNS text
as
$$
BEGIN
create temp table if not exists tt1(json_text json);
delete from tt1;
copy tt1 from '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/4.1.json';
return json_text->>'top_producer' as "TOP" from tt1;
end;
$$ language plpgsql;


-- 4.3 проверка существования атрибута
-- РАБОТАЕМ В ВИРТУАЛКЕ, НАПОМИНАЮ!!!!!!!!!!!!
create or replace function exist_test(nm varchar)
returns text
as
$$
import json
with open("/home/parallels/Desktop/example.json", "r") as read_file:
    l = json.load(read_file)
exist = nm in l
if exist:
    return "exist"
else:
    return "not exist"
$$ language plpython3u;

select * from exist_test('money');
--- ИЛИ

create or replace function is_exist1(nm varchar)
returns text
as
$$
declare obj text;
BEGIN

create temp table if not exists tt1(json_text json);
delete from tt1;
copy tt1 from '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/4.1.json';
obj = '';
select json_text->> format('{%s}', nm) into obj from tt1;
if obj is null THEN
  return 'not exist';
else
  return 'exist';
end if;

end;
$$ language plpgsql;

--4.4 изменить json документ
-- данный код на языке postgresq + plpgsql создает дубликаты записай в 4_4.json с помощью 2 процедур
create or replace procedure upload_from_json()

as
$$
begin
create temp table if not exists test_import4_4(doc json);
copy test_import4_4 from '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/4_4.json';
end;
$$ language plpgsql;

call upload_from_json();
call upload_from_json();
select * from test_import4_4;


create or replace procedure push_json_back()
as
$$
begin
copy(select * from test_import4_4) to '/Users/ilchel/Desktop/Data_bases/Data_bases/lab5/4_4.json';
end;
$$ language plpgsql;
call push_json_back();

-- 4.5

create or replace procedure split_json()
as
$$
import json
with open("/home/parallels/Desktop/example.json", "r") as read_file:
    l = json.load(read_file)

with open ("/var/lib/postgresql/ex.txt", "w") as write_file:
    for i in l:
        a = str(i) + ":" + str(l[i]) + "\n"
        write_file.write(a)
$$ language plpython3u;


call split_json();
