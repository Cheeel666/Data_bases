from peewee import *
from playhouse.postgres_ext import *
import psycopg2
from psycopg2 import OperationalError
menu = '''

Меню: 
LINQ to object:
1) 1.1 - select + where
2) 1.2 - select + order
3) 1.3 - select avg
4) 1.4 - select having
5) 1.5 - select between
LINQ to JSON
6) 2.1 - read from JSON
7) 2.2 - update JSON
8) 2.3 - insert into JSON
LINQ to SQL
9) 3.1 - single-table query
10)3.2 - multi-table query
11)3.3.1 - insert 
12)3.3.2 - update
13)3.3.3 - delete

Выберете действие
'''

# http://docs.peewee-orm.com/en/latest/peewee/playhouse.html#postgres-ext
# http://docs.peewee-orm.com/en/latest/peewee/query_operators.html
db = PostgresqlDatabase(
    "lab1", user="postgres", password="1", host="127.0.0.1", port=5432
)

curs = db.cursor()
ext_db = PostgresqlExtDatabase(
    "lab1", user="postgres", password="1", host="127.0.0.1", port=5432
)


class ExtDbModel(Model):
    class Meta:
        database = ext_db


class DbModel(Model):
    class Meta:
        database = db


class StudentInfo(DbModel):
    code_module = TextField(column_name="code_module")
    code_presentation = TextField(column_name="code_presentation")
    id_student = IntegerField(column_name="id_student", primary_key=True)
    gender = TextField(column_name="gender")
    region = TextField(column_name="region")
    highest_education = TextField(column_name="highest_education")
    imd_band = TextField(column_name="imd_band")
    age_band = TextField(column_name="age_band")
    num_of_prev_attempts = IntegerField(column_name="num_of_prev_attempts")
    studied_credits = IntegerField(column_name="studied_credits")
    disability = TextField(column_name="disability")
    final_request = TextField(column_name="final_request")

    class Meta:
        table_name = "studentinfo"


class StudentAssessment(DbModel):
    id_student = IntegerField(column_name="id_student", primary_key=True)
    id_assessment = IntegerField(column_name="id_assessment")
    date_submitted = IntegerField(column_name="date_submitted")
    is_banked = IntegerField(column_name="is_banked")
    score = IntegerField(column_name="score")

    class Meta:
        table_name = "studentassessment"


class Assessment(DbModel):
    code_module = TextField(column_name="code_module")
    code_presentation = TextField(column_name="code_presentation")
    id_assessment = IntegerField(column_name="id_assessment", primary_key=True)
    assessment_type = TextField(column_name="assessment_type")
    dt = IntegerField(column_name="dt")
    weight = DoubleField(column_name="weight")

    class Meta:
        table_name = "assessments"


class Vle(DbModel):
    id_site = IntegerField(column_name="id_site", primary_key=True)
    code_module = TextField(column_name="code_module")
    code_presentation = TextField(column_name="code_presentation")
    activity_type = TextField(column_name="activity_type")
    week_from = IntegerField(column_name="week_from")
    week_to = IntegerField(column_name="week_to")

    class Meta:
        table_name = "vle"


class GraduateStudents(ExtDbModel):
    id_student = IntegerField(column_name="id_student", primary_key=True)
    graduateinfo = JSONField(column_name="graduateinfo")

    class Meta:
        table_name = "graduatestudents"


def selectWhere():
    query = StudentInfo.select().where(
        StudentInfo.id_student <= 10000
    )  # 3 strings in result
    return query


def selectOrder():
    query = Assessment.select().order_by(Assessment.dt)
    return query


def selectAvgLastWeek():
    query = Vle.select(Vle.activity_type, fn.AVG(Vle.week_to)).group_by(
        Vle.activity_type
    )
    return query


def selectHaving():
    query = (
        StudentInfo.select(StudentInfo.id_student, StudentInfo.region)
        .having(StudentInfo.gender == "F")
        .group_by(StudentInfo.id_student)
        .limit(20)
    )
    return query


def selectBetween():
    query = StudentInfo.select(StudentInfo.id_student).where(
        StudentInfo.id_student.between("10000", "20000")
    )
    return query


# Чтение из JSON (Который находится в БД)
def readFromJSON():
    query = GraduateStudents.select(GraduateStudents.graduateinfo).where(
        GraduateStudents.graduateinfo["studytime"] == "4"
    )
    return query


def updateJSON():
    query = GraduateStudents.update(
        graduateinfo={"firstname": "Karim", "lastname": "Akhmetov", "studytime": 4}
    ).where(GraduateStudents.graduateinfo["firstname"] == "Karim")
    return query


def insertJSON():
    query = GraduateStudents.insert(
        id_student=8, graduateinfo={"firstname": "a", "lastname": "b", "studytime": 1}
    )
    return query


# 3 Задание
def selectThird():
    query = (
        StudentInfo.select(StudentInfo.id_student, StudentInfo.disability)
        .where(StudentInfo.gender == "F")
        .limit(10)
    )
    return query


def selectTwoTable():
    query = (
        StudentInfo.select(
            StudentInfo.id_student,
            StudentAssessment.score,
            StudentAssessment.date_submitted,
        )
        .join(
            StudentAssessment,
            on=(StudentAssessment.id_student == StudentInfo.id_student),
        )
        .where(StudentAssessment.score > 80)
        .group_by(
            StudentAssessment.id_student,
            StudentInfo.id_student,
            StudentAssessment.score,
            StudentAssessment.date_submitted,
        )
        .limit(5)
    )
    return query


# 3.3.1:
def insertValue():
    query = Vle.insert(
        id_site=1222222,
        code_module="ABC",
        code_presentation="2020W",
        activity_type="Site",
        week_from=0,
        week_to=15,
    )
    return query


# 3.3.2:
def updateValue():
    query = Vle.update(code_module="Dca").where(Vle.id_site == 1222222)
    return query


# 3.3.3:
def deleteValue():
    query = Vle.delete().where(Vle.id_site == 1222222)
    return query


# 3.4
def callProcedure(curs):
    #curs.callproc("get_avg")
    curs.execute("call drop_table_like()")
    return "Success"

# def requestPgQuery(choice):
    
#     if (choice == 1):
#             query = selectWhere()
#     elif choice == 2:
#         query = selectOrder()
#     elif choice == 3:
#        query = selectAvgLastWeek()
#     elif choice == 4:
#         query = selectHaving()
#     elif choice == 5:
#         query = selectBetween()
#     elif choice == 6:
#         query = readFromJSON()
#     elif choice == 7:
#         query = updateJSON()
#     elif choice == 8:
#         query = insertJSON()
#     elif choice == 9:
#         query = selectThird()
#     elif choice == 10:
#         query = selectTwoTable()
#     elif choice == 11:
#         query = insertValue()
#     elif choice == 12:
#         query = updateValue()
#     elif choice == 13:
#         query = deleteValue()
#     print("Результирующий запрос:")
#     print(query)

# def main():
#     print(menu)
#     a = int(input())
#     while a:
#         requestPgQuery(a)
#         print(menu)
#         a = int(input())
   

# if __name__ == "__main__":
#     main()
print("Select + where:")
print(selectWhere())
print()

print("Select + order:")
print(selectOrder())
print()

print("Select + avgLastWeek:")
print(selectAvgLastWeek())
print()

print("Select + Having:")
print(selectHaving())
print()

print("Select + Having:")
print(selectBetween())
print()

print("Read from Json:")
print(readFromJSON())
print()

print("Update JSON:")
print(updateJSON())
print()

print("Insert JSON:")
print(insertJSON())
print()

print("Select one table:")
print(selectThird())
print()

print("Select two table:")
print(selectTwoTable())
print()

print("Insert row:")
print(insertValue())
print()

print("Update row:")
print(updateValue())
print()

print("Delete row:")
print(deleteValue())
print()

print("Call procedure row:")
print(callProcedure(curs))

curs.close()
db.close()