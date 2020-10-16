CREATE TABLE studentRegistration(
      code_module VARCHAR,
      code_presentation VARCHAR,
      id_student INTEGER,
      date_registration INTEGER,
      date_unregistration INTEGER,
      FOREIGN KEY(id_student) REFERENCES studentInfo(id_student)
);
