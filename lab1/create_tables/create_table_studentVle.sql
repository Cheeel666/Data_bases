CREATE TABLE studentVle(
      code_module VARCHAR,
      code_presentation VARCHAR,
      id_student INTEGER,
      id_site INTEGER,
      dt INTEGER,
      sum_click INTEGER,
      FOREIGN KEY(id_student) REFERENCES  studentInfo(id_student),
      FOREIGN KEY(id_site) REFERENCES vle(id_site)
);
