CREATE TABLE studentAssessment(
      id_assessment INTEGER,
      id_student INTEGER,
      date_submitted INTEGER,
      is_banked INTEGER,
      score INTEGER,
      FOREIGN KEY(id_student) REFERENCES studentInfo(id_student),
      FOREIGN KEY (id_assessment) REFERENCES Assessments(id_assessment)
);
