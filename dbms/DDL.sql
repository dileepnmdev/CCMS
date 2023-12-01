BEGIN;

CREATE TABLE IF NOT EXISTS public.system_admin
(
    id serial,
    name text,
    password text,
    PRIMARY KEY (id),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.classroom_type
(
    id serial,
    type text,
    max_students integer,
    students_per_teacher integer,
    PRIMARY KEY (type),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.facility
(
    name text,
    address text,
    contact text,
    license_no text,
    PRIMARY KEY (license_no)
);

CREATE TABLE IF NOT EXISTS public.facility_admin
(
    email text,
    name text,
    contact text,
    license_no text,
    id serial,
    password text,
    PRIMARY KEY (email),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.parent
(
    id serial,
    name text,
    contact text,
    address text,
    mail_id text,
    password text,
    PRIMARY KEY (mail_id),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.student
(
    first_name text,
    last_name text,
    dob date,
    allergies text,
    license_no text,
    classtype integer,
    parent_id integer,
    consent_form integer,
    week_enrolled integer,
    id serial,
    PRIMARY KEY (last_name, first_name, license_no, parent_id),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.teacher
(
    first_name text,
    last_name text,
    dob date,
    address text,
    phone text,
    mail text,
    hourly_salary integer,
    license_no text,
    availability integer,
    id serial,
    password text,
    PRIMARY KEY (mail),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.day
(
    id serial,
    day text,
    PRIMARY KEY (day),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.today
(
    year integer,
    week_no integer,
    day integer,
    issued timestamp without time zone DEFAULT current_timestamp,
    PRIMARY KEY (day, week_no, year)
);


CREATE TABLE IF NOT EXISTS public.classroom
(
    license_no text,
    classtype integer,
    id serial,
    PRIMARY KEY (license_no,classtype),
    UNIQUE (id)
);

CREATE TABLE IF NOT EXISTS public.class_assignments
(
    teacher_id integer,
    class_id integer
);

CREATE TABLE IF NOT EXISTS public.ledger
(
    year integer,
    week_no integer,
    student_id integer,
    money_to_be_paid integer,
    payment_status integer,
    PRIMARY KEY (year,week_no, student_id)
);

CREATE TABLE IF NOT EXISTS public.attendance
(
    year integer ,
    day integer,
    week integer,
    in_time timestamp without time zone DEFAULT current_timestamp,
    out_time timestamp without time zone DEFAULT current_timestamp,
    present integer,
    user_type text,
    id integer,
    PRIMARY KEY (year,week, day, user_type)
);

END;