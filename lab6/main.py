import psycopg2
from psycopg2 import OperationalError
text = '''1)Выполнить скалярный запрос
2)Выполнить запрос с несколькими join
3)Выполнить запрос с ОТВ и оконными функциями
4)Выполнить запрос к метаданным
5)Вызвать скалярную функцию(написанную в третьей л.р.)
6)Вызвать многооператорную или табличную функцию(написанную в 3 л.р.)
7)Вызвать хранимую процедуру(написанную 3 л.р.)
8)Вызвать системную функцию или процедуру
9)Создать таблицу в базе данных, соответствующую теме бд
10)Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY
'''

# получение студента с максимальным баллом
scalarRequest = '''
select id_student from studentassessment where score = 100 limit 1;
'''
# получение столбцов из разных таблиц с 2 join
multJoinRequest = '''
select st.id_student, st.region, s.id_site, v.activity_type
from studentinfo st join studentvle s on st.id_student = s.id_student
join vle v on v.id_site = s.id_site
'''
# получение среднего date_submitted для каждого студента
OTV = '''
WITH CTE(id_student, date_submitted) AS
(
	SELECT id_student, date_submitted
	from studentAssessment
	where date_submitted > 0
	group by id_student, date_submitted
)

SELECT DISTINCT id_student, AVG(date_submitted) OVER(PARTITION by id_student)
from CTE;
'''
# получение всех данных из public
metadataRequest = '''
select * from pg_tables where schemaname = 'public';
'''
# получение average date_submitted
scalarFunc = '''
select * from get_avg_date();
'''
# получение average date_submitted
MultoptFunc = '''
select * from get_avg();
'''
# увеличевает все date_submitted 18 на 1
storedProc = '''
call update_date(1, 18);
'''
systemFunc = '''
select current_catalog;
'''
tableCreation = '''
create table if not exists studentgraduate(
	id_student integer,
	fistname varchar,
	lastname varchar,
	studytime integer
);
'''

tableInsertion = '''
insert into studentgraduate values
(1, 'Ilya', 'Chelyadinov', 4),
(2, 'Efim', 'Sokolof', 4),
(3, 'Artem', 'Sarkisov', 4),
(4, 'Dmitri', 'Kovalev', 4),
(5, 'Karim', 'Achmetov', 4);
'''
def output(cur, func):
    if func == 1:
        answer = cur.fetchall()
        print("ID студента с максимальным баллом: ", answer[0][0])
    elif func == 2:
        answer = cur.fetchmany(10)
        for i in answer:
            print(i)
    elif func == 3:
        answer = cur.fetchmany(10)
        for i in answer:
            print(i)
    elif func == 4:
        answer = cur.fetchall()
        for i in answer:
            print(i)
    elif func == 5:
        answer = cur.fetchall()
        print("Average submitted date", answer[0][0])
    elif func == 6:
        answer = cur.fetchmany(10)
        for i in answer:
            print(i)
    elif func == 7:
        print("Все поля date_submitted сo значением 18 инкрементированы")
    elif func == 8:
        answer = cur.fetchall()
        print(answer[0][0])
    elif func == 9:
        print("Table created")
    elif func == 10:
        print("Values inserted")




def requestPgQuery(connection, query, func):
    cursor = connection.cursor()
    try:
        cursor.execute(query)
        connection.commit()
        output(cursor, func)
    except Error as e:
        print(f"Произошла ошибка '{e}'")
    cursor.close()


def create_connection(db_name, db_user, db_password, db_host, db_port):
    connection = None
    try:
        connection = psycopg2.connect(
            database=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port,
        )
        print("Connection to PostgreSQL DB successful")
    except OperationalError as e:
        print(f"The error '{e}' occurred")
    return connection

def menu(connection):
    print(text)
    print("Выберите действие:")
    choice = int(input())
    while(choice):
        if (choice == 1):
            requestPgQuery(connection, scalarRequest, 1)
        elif choice == 2:
            requestPgQuery(connection, multJoinRequest, 2)
        elif choice == 3:
            requestPgQuery(connection, OTV, 3)
        elif choice == 4:
            requestPgQuery(connection, metadataRequest, 4)
        elif choice == 5:
            requestPgQuery(connection, scalarFunc, 5)
        elif choice == 6:
            requestPgQuery(connection, MultoptFunc, 6)
        elif choice == 7:
            requestPgQuery(connection, storedProc, 7)
        elif choice == 8:
            requestPgQuery(connection, systemFunc, 8)
        elif choice == 9:
            requestPgQuery(connection, tableCreation, 9)
        elif choice == 10:
            requestPgQuery(connection, tableInsertion, 10)
        print("Выберите действие:")
        choice = int(input())


connection = create_connection(
    "lab1", "postgres", "1", "127.0.0.1", "5432"
)

menu(connection)
connection.close()
