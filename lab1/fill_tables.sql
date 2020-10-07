COPY assessments FROM '/Users/ilchel/Downloads/anonymisedData/assessments.csv' DELIMITER ',' CSV HEADER;

COPY courses FROM '/Users/ilchel/Downloads/anonymisedData/courses.csv' DELIMITER ',' CSV HEADER;

COPY studentAssessment FROM '/Users/ilchel/Downloads/anonymisedData/studentAssessment.csv' DELIMITER ',' CSV HEADER;

COPY studentInfo FROM '/Users/ilchel/Downloads/anonymisedData/studentInfo.csv' DELIMITER ',' CSV HEADER;

COPY studentRegistration FROM '/Users/ilchel/Downloads/anonymisedData/studentRegistration.csv' DELIMITER ',' CSV HEADER;

COPY studentVle FROM '/Users/ilchel/Downloads/anonymisedData/studentVle.csv' DELIMITER ',' CSV HEADER;

COPY vle FROM '/Users/ilchel/Downloads/anonymisedData' DELIMITER ',' CSV HEADER;
