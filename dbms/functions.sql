-- Finding all the students of a facility given license number of the facility
CREATE OR REPLACE FUNCTION find_student(lic text)
RETURNS TABLE (
	first_name text ,
	last_name text ,
	id int 
) 
AS $$
BEGIN
    RETURN QUERY
	select student.first_name, student.last_name, student.id from student where student.license_no = lic ;
END;
$$ LANGUAGE plpgsql;

-- select find_student() ;
-- select * from find_student() where id = ? ; -- Part B

-- Adding a new student
-- 0 if unable to add
-- 1 if added successfully 
CREATE OR REPLACE FUNCTION add_student(first_name text,last_name text,dob date,allergies text,licenseno text,class_type integer,parent_id integer, consent_form integer, week_enrolled integer)
RETURNS integer	
AS $$
DECLARE
cnt integer := 0;
BEGIN
	select count(*) into cnt from public.student where student.classtype = class_type and student.license_no = licenseno ;
	RAISE NOTICE 'ok' ;
	if class_type = 1 and cnt >= 8 then 
		return 0 ;
	elsif class_type = 2 and cnt >= 12 then 
		return 0 ;
	elsif class_type = 3 and cnt >= 16 then 
		return 0;
	elsif class_type = 4 and cnt >= 18 then 
		return 0;
	elsif class_type = 5 and cnt >= 20 then
		return 0;
	else 
	insert into public.student(first_name,last_name,dob,allergies,license_no,classtype,parent_id,consent_form,week_enrolled) values(first_name,last_name,dob,allergies,licenseno,class_type,parent_id,consent_form,week_enrolled);
	return 1;
	end if ;
END;
$$ LANGUAGE plpgsql;

-- select * from facility ;
-- select * from student ;
-- select * from add_student('A','B','2003-09-02','ok','lc1',1,2,1,3);

-- Used to get Password of the user who has logged in
CREATE OR REPLACE FUNCTION get_password(idd integer,role text)
RETURNS text	
AS $$
DECLARE 
ret_text text := NULL ;
BEGIN
	IF role = 'System' then
		SELECT system_admin.password INTO ret_text FROM system_admin WHERE system_admin.id = idd;
	ELSEIF role = 'Teacher' THEN
		SELECT teacher.password INTO ret_text FROM teacher WHERE teacher.id = idd;
	ELSEIF role = 'Facility' THEN
		SELECT facility_admin.password INTO ret_text FROM facility_admin WHERE facility_admin.id = idd;
	ELSEIF role = 'Parent' THEN
		SELECT parent.password INTO ret_text FROM parent WHERE parent.id = idd;
	end if ;
	return ret_text ;
END;
$$ LANGUAGE plpgsql;

-- Given student id deleteing the student
-- delete from students where students.id = ?;

-- -- Adding Teachers to facility
-- insert into teacher(first_name,last_name,dob,address,phone,mail,hourly_salary,license_no,availability,password) values(?,?,?,?,?,?,?,?,1,?); 

-- query for returning no. of students in a classtype of a given facility licenseno
-- select count(*) from student where license_no = ? and classtype = ? ; 

-- This function assigns teacher to a classroom based on the Following checks
-- 1) Is the teacher free for assignment
-- 2) Do we have enough number of teachers or do we need to assign a new one
-- Return - 1 => Success
-- Return - 2 => Teacher unavailable
-- Return - 3 => Sufficient number of teachers already there
CREATE OR REPLACE FUNCTION assign_teacher(teacherid integer,classtype_i integer,license_no_i text)
RETURNS integer	
AS $$
declare 
	curr_students integer := 0;
	curr_teachers integer := 0;
	classid integer := 0;
	students_for_one_teacher integer := 0;
	teacher_availability integer:=0;
BEGIN
	select classroom_type.students_per_teacher into students_for_one_teacher from classroom_type where classroom_type.id = classtype_i ;
	select count(*) into curr_students from student where license_no = license_no_i and classtype = classtype_i;
	select classroom.id into classid from classroom where license_no = license_no_i and classtype = classtype_i;
	select count(*) into curr_teachers from class_assignments where teacher_id = teacherid and class_id = classid;
	
	select teacher.availability into teacher_availability from teacher where teacher.id = teacherid ;
	raise notice '%',curr_students;
	raise notice '%',curr_teachers;
	raise notice '%',students_for_one_teacher;
	raise notice '%',teacher_availability;
	if teacher_availability = 1 then 
	raise notice 'okkkkk' ;
	raise notice '%, %', curr_students < students_for_one_teacher,curr_teachers = 0 ;
	
		if curr_students > students_for_one_teacher and curr_teachers = 1 then 
		raise notice 'hiii' ;
		insert into class_assignments(teacher_id, class_id) values(teacherid,classid) ;
		UPDATE teacher set availability = 0 where id = teacherid;
		return 1;
		
		ELSEIF curr_students <students_for_one_teacher and curr_teachers = 0 then 
		raise notice 'hiii' ;
		insert into class_assignments(teacher_id, class_id) values(teacherid,classid);
		UPDATE teacher set availability = 0 where id = teacherid;
		return 1;
		
		ELSEIF curr_students > students_for_one_teacher and curr_teachers = 0 then 
		raise notice 'hiii3' ;
		insert into class_assignments(teacher_id, class_id) values(teacherid,classid);
		UPDATE teacher set availability = 0 where id = teacherid;
		return 1;
		
		ELSEIF curr_students < students_for_one_teacher and curr_teachers = 1 then 
		
		return 0;
		
		ELSEIF curr_students >students_for_one_teacher and curr_teachers = 2 then 
		
		return 0;
		
		end if ;
       else return 0 ;
	   end if ;
	   return 1;
END;
$$ LANGUAGE plpgsql;

select assign_teacher(5,1,'lic2') ;
select * from student ;
-- Function to update out time when the user signs out
CREATE OR REPLACE FUNCTION update_outtime(outtime timestamp, type_i text, idi integer)
RETURNS integer	
AS $$
BEGIN
	update attendance set
	out_time = outtime where user_type = type_i and id = idi;
	return 1;
END;
$$ LANGUAGE plpgsql;

-- Returning password of the user for checking validity of the given password
CREATE OR REPLACE FUNCTION get_password(idd integer,role text)
RETURNS text	
AS $$
DECLARE 
ret_text text := NULL ;
BEGIN
	IF role = 'System' then
		SELECT system_admin.password INTO ret_text FROM system_admin WHERE system_admin.id = idd;
	ELSEIF role = 'Teacher' THEN
		SELECT teacher.password INTO ret_text FROM teacher WHERE teacher.id = idd;
	ELSEIF role = 'Facility' THEN
		SELECT facility_admin.password INTO ret_text FROM facility_admin WHERE facility_admin.id = idd;
	ELSEIF role = 'Parent' THEN
		SELECT parent.password INTO ret_text FROM parent WHERE parent.id = idd;
	end if ;
	return ret_text ;
END;
$$ LANGUAGE plpgsql;


-- Finding Teacher in a faciltiy 
CREATE OR REPLACE FUNCTION find_staff(lic text)
RETURNS TABLE(first_name text, last_name text, id integer) 
AS $$
BEGIN
    RETURN QUERY
	select teacher.first_name,teacher.last_name,teacher.id from teacher where teacher.license_no = lic ;
END;
$$ LANGUAGE plpgsql;

-- 	Function for adding new Facility
CREATE OR REPLACE FUNCTION add_facility(namei text, addressi text, contacti text, lici text, gmail text, namee text, contact text, pass text)
RETURNS INTEGER
AS $$
DECLARE
ret INTEGER := 0 ;
BEGIN
	select count(*) into ret from facility where facility.license_no = lici ;
	IF ret = 1 then 
		return 0 ;
	else  
  	INSERT INTO facility VALUES(namei, addressi, contacti, lici) ;
	insert into facility_admin(email, name, contact, license_no, password) VALUES(gmail,namei,contacti, lici, pass);
		INSERT INTO classroom(license_no,classtype) values(lici, 1) ;
		INSERT INTO classroom(license_no,classtype) values(lici, 2) ;
		INSERT INTO classroom(license_no,classtype) values(lici, 3) ;
		INSERT INTO classroom(license_no,classtype) values(lici, 4) ;
		INSERT INTO classroom(license_no,classtype) values(lici, 5) ;
		return 1;
	end if;
	
END;
$$ LANGUAGE plpgsql;

-- select * from add_facility(?,?,?,?) as A;

-- Function to insert into today table
CREATE OR REPLACE FUNCTION add_today(dayi integer, weeki integer, yeari integer)
	RETURNS INTEGER
	AS $$
	DECLARE
	ret INTEGER := 0 ;
r record ;
BEGIN
	select count(*) into ret from today where today.year = yeari and today.week_no = weeki and today.day = dayi ;
	IF ret = 1 then 
	raise notice 'okkk' ;
		return 0 ;
	else  
  	INSERT INTO today(year,week_no,day) VALUES(yeari, weeki,dayi) ;
	end if ;
	for r in select * from student LOOP
		INSERT INTO attendance(day,year,week,present,user_type,id) values(dayi, yeari,weeki, 0, 'student',r.id) ;
	end loop ;

	for r in select * from teacher LOOP
		INSERT INTO attendance(day,year,week,present,user_type,id) values(dayi, yeari,weeki, 0, 'teacher',r.id) ;
	end loop ;
	return 1;
END;
$$ LANGUAGE plpgsql;

-- select * from add_today(?,?,?) as A;

-- Payment status change from 0 to 1
CREATE OR REPLACE FUNCTION change_payment_status(studentidi integer, weeki integer, yeari integer)
RETURNS INTEGER
AS $$
DECLARE
BEGIN
	UPDATE ledger set payment_status = 1 where ledger.week_no = weeki and ledger.year = yeari and ledger.student_id = studentidi; 
	return 1;
END;
$$ LANGUAGE plpgsql;

-- select * from change_payment_status(?,?,?) as A;

-- Teacher information tracking function for a week
CREATE OR REPLACE FUNCTION teacher_info_for_a_week(teacheridi integer, weeki integer, yeari integer)
RETURNS TABLE(attendance_op integer, day_op text,intime_op timestamp, outime_op timestamp, hours_worked_op integer, money_earned_that_day_op integer)
AS $$
DECLARE
money_per_day integer := 0 ;
r record ;
BEGIN
	select teacher.hourly_salary into money_per_day from teacher where teacher.id = teacheridi ;
	for r in select * from attendance where attendance.year = yeari and attendance.week = weeki and attendance.user_type = 'teacher' and attendance.present = 1 and attendance.id = teacheridi loop
			attendance_op = r.present ;
			
			intime_op = r.in_time ;
			RAISE NOTICE '%',intime_op;
			outime_op = r.out_time ;
			
			hours_worked_op = (date_part('hour', outime_op - intime_op  ))::int ;
			money_earned_that_day_op = hours_worked_op * money_per_day ;
			if r.day = 1 then 
				day_op = 'Monday' ;
			elsif r.day = 2 then 
				day_op = 'Tuesday' ;
			elsif r.day = 3 then 
				day_op = 'Wednesday' ;
			elsif r.day = 4 then 
				day_op = 'Thursday' ;
			elsif r.day = 5 then 
				day_op = 'Friday' ;
			end if ;
			return next ;
		end loop;
END;
$$ LANGUAGE plpgsql;

-- select * from teacher_info_for_a_week(?,?,?) as A;
-- Adding Parents to application
CREATE OR REPLACE FUNCTION add_parent(namei text, contacti text, addressi text, maili text, passwordi text)
RETURNS INTEGER
AS $$
DECLARE
ret INTEGER := 0 ;
BEGIN
	select count(*) into ret from parent where parent.mail_id = maili ;
	IF ret = 1 then 
		return 0 ;
	else  
  	INSERT INTO parent(name,contact,address,mail_id,password) VALUES(namei, contacti, addressi, maili, passwordi) ;
		return 1;
	end if;
END;
$$ LANGUAGE plpgsql;

-- select * from add_parent(?,?,?,?,?) as A;

-- Function to output students who did not pay fees in the current week
CREATE OR REPLACE FUNCTION fee_unpaid(licensenoi text,weeki integer, yeari integer)
RETURNS TABLE(student_id_op INTEGER, first_name_op text, last_name_op text)
AS $$
DECLARE
BEGIN
RETURN QUERY
	select student.id, student.first_name, student.last_name from ledger join student on ledger.student_id = student.id where ledger.week_no = weeki and ledger.year = yeari and ledger.payment_status = 0 and student.license_no = licensenoi ;
END;
$$ LANGUAGE plpgsql;

-- select * from fee_unpaid(?,?,?) as A;
select * from parent ;
--Function to mark attendance for teacher and student
-- flag = 0 - intime
-- flag = 1 - outime
-- typei = student 
-- typei = teacher 
CREATE OR REPLACE FUNCTION mark_attendance(idi integer,typei text,yr integer, we integer,da integer, flag integer)
RETURNS INTEGER
AS $$
DECLARE
BEGIN
    RAISE NOTICE '%',flag;
	RAISE NOTICE '%',idi;
	RAISE NOTICE '%',typei;
	RAISE NOTICE '%',yr;
	RAISE NOTICE '%',we;
	RAISE NOTICE '%',da;
	
	RAISE NOTICE '%',current_timestamp;
	
	if typei = 'teacher' then 
		raise notice 'jhfsjofsdfsfsd';
	end if ;

	if flag = 0 then
	RAISE NOTICE 'hii';
	update attendance set present = 1 where attendance.user_type = typei and attendance.id = idi and attendance.year = yr and attendance.day = da and attendance.week = we ;
	update attendance set in_time = current_timestamp where user_type = typei and id = idi and year = yr and day = da and week = we ;
	RAISE NOTICE 'hii';
	elsif flag = 1 then 
	RAISE NOTICE 'hii2';
	update attendance set out_time = current_timestamp where user_type = typei and id = idi and year = yr and day = da and week = we ;
	end if;
	return 1;
END;
$$ LANGUAGE plpgsql;

-- select * from mark_attendance(?,?,?) as A;

-- Calculate money earned by teacher in the week
CREATE OR REPLACE FUNCTION cal_money_per_week(teacheridi integer, weeki integer, yeari integer)
RETURNS INTEGER
AS $$
DECLARE
total integer := 0;
r record ;
temp integer := 0;
BEGIN
	select count(*) into temp from teacher_info_for_a_week(teacheridi, weeki, yeari) as A ;
	if(temp <> 0 ) then 
	select sum(A.money_earned_that_day_op) into total from teacher_info_for_a_week(teacheridi, weeki, yeari) as A ;
	raise notice '%',total ;
	end if ;
	return total ;
END;
$$ LANGUAGE plpgsql;

-- select * from cal_money_per_week(?,?,?) as A;

-- List if students under the teacher whose attendance is not marked yet
CREATE OR REPLACE FUNCTION unmarked_students(teacheridi integer, dayi integer ,weeki integer, yeari integer)
RETURNS TABLE(student_id_op INTEGER, first_name_op text, last_name_op text)
AS $$
DECLARE
classid integer := 0;
licenseno text ;
class_type integer := 0;
BEGIN
	select class_assignments.class_id into classid from class_assignments where class_assignments.teacher_id = teacheridi;
	select classroom.license_no, classroom.classtype into licenseno, class_type from classroom where classroom.id  = classid ;
	RETURN QUERY 
	select student.id, student.first_name, student.last_name from attendance join student on attendance.id = student.id where attendance.week = weeki and attendance.day=dayi and student.license_no = licenseno and student.classtype = class_type and attendance.year = yeari and attendance.present = 0 and attendance.user_type = 'student' ; 
END;
$$ LANGUAGE plpgsql;

-- select * from unmarked_students(?,?,?,?) as A;

-- Given Parent id get info about his children
CREATE OR REPLACE FUNCTION get_children(parentidi integer)
RETURNS TABLE(student_id_op integer, first_name_op text, last_name_op text)
AS $$
DECLARE
BEGIN
	RETURN QUERY
	select student.id, student.first_name, student.last_name from student where student.parent_id = parentidi ; 
END;
$$ LANGUAGE plpgsql;

-- select * from unmarked_students(?,?,?,?) as A;

-- View weekly and attedance for student
CREATE OR REPLACE FUNCTION student_info_for_a_week(studentidi integer, weeki integer, yeari integer)
RETURNS TABLE(attendance_op text, day_op text)
AS $$
DECLARE
r record ;
BEGIN
	for r in select * from attendance where attendance.year = yeari and attendance.week = weeki and attendance.id=studentidi and attendance.user_type='student' loop 
	if r.present = 1 then 
		attendance_op = 'Present' ;
	elsif r.present = 0 then
		attendance_op = 'Absent' ;
	end if ;
		if r.day = 1 then 
			day_op = 'Monday' ;
		elsif r.day = 2 then 
			day_op = 'Tuesday' ;
		elsif r.day = 3 then 
			day_op = 'Wednesday' ;
		elsif r.day = 4 then 
			day_op = 'Thursday' ;
		elsif r.day = 5 then 
			day_op = 'Friday' ;
		end if ;
		return next ;
		end loop;
END;
$$ LANGUAGE plpgsql;

-- select student_info_for_a_week(?,?,?) as A;

-- Given child id give all pending payments
 CREATE OR REPLACE FUNCTION pending_payments(studentidi integer)
RETURNS TABLE(year_op integer,weeknumber_op integer, money_to_be_paid_op integer)
AS $$
DECLARE
mone INTEGER := 0;
clasint integer := 0;
r record ;
BEGIN
	select student.classtype into clasint from student where student.id = studentidi ;

	if clasint = 1 then
		mone = 300 ;
	elsif clasint = 2 then
		mone = 275 ;
	elsif clasint = 3 then
		mone = 250 ;
	elsif clasint = 4 then
		mone = 225 ;
	elsif clasint = 5 then
		mone = 200 ;
	end if ;

	for r in select * from ledger where ledger.student_id = studentidi loop
		money_to_be_paid_op = mone;
		weeknumber_op = r.week_no ;
		year_op = r.year ;
		return next ;
	end loop ;

END;
$$ LANGUAGE plpgsql;

-- select * from teacher_info_for_a_week(?) as A;

-- Call this when facility insert is done
 CREATE OR REPLACE FUNCTION create_facility(namei text, addressi text, contacti text, license_noi text)
RETURNS integer
AS $$
DECLARE
BEGIN
	insert into facility VALUES(namei,addressi,contacti,license_noi);
	insert into classroom (license_no,classtype) values (license_noi,1);
	insert into classroom (license_no,classtype) values (license_noi,2);
	insert into classroom (license_no,classtype) values (license_noi,3);
	insert into classroom (license_no,classtype) values (license_noi,4);
	insert into classroom (license_no,classtype) values (license_noi,5);
END;
$$ LANGUAGE plpgsql;

-- select * from create_facility(?,?,?,?) as A;

-- For updating allergies 
-- update student set allergies = ? where id = ? ;

-- Delete a child
-- Returns 0 for Error
-- Returns 1 for Correct Deletion
 CREATE OR REPLACE FUNCTION delete_student(studentidi integer)
RETURNS integer
AS $$
DECLARE
cnt integer := 0;
BEGIN
	select count(*) into cnt from ledger where student_id = studentidi ;
	if cnt <> 0 then
		delete from ledger where student_id = studentidi ;
		cnt := 0;
	end if;
	SELECT count(*) into cnt from attendance where id = studentidi and user_type='student' ;
	if cnt <> 0 then
		delete from attendance where id = studentidi and user_type='student' ;
		cnt := 0;
	end if;
	select count(*) into cnt from student where id = studentidi ;
	if cnt <> 0 then
		delete from student where id = studentidi ;
		return 1;
	else return 0;
	end if ;
END;
$$ LANGUAGE plpgsql;

-- select * from delete_student(?) as A;


-- Delete Teacher
-- Returns 0 for Error
-- Returns 1 for Correct Deletion
CREATE OR REPLACE FUNCTION delete_teacher(teacheridi integer)
RETURNS integer
AS $$
DECLARE
cnt integer := 0;
BEGIN
	select count(*) into cnt from class_assignments where teacher_id = teacheridi ;
	if cnt <> 0 then
		delete from class_assignments where teacher_id = teacheridi ;
		cnt := 0;
	end if;
	SELECT count(*) into cnt from attendance where id = teacheridi and user_type='teacher' ;
	if cnt <> 0 then
		delete from attendance where id = teacheridi and user_type='teacher' ;
		cnt := 0;
	end if;
	select count(*) into cnt from teacher where id = teacheridi ;
	if cnt <> 0 then
		delete from teacher where id = teacheridi ;
		return 1;
	else return 0;
	end if ;
END;
$$ LANGUAGE plpgsql;

-- select * from delete_teacher(?) as A;


-- Generate ledger
CREATE OR REPLACE FUNCTION generate_ledger(yeari integer, weeki integer, license_idi text)
RETURNS integer
AS $$
DECLARE
mone integer := 0;
r record ;
BEGIN

	for r in select * from student where license_no = license_idi LOOP
		if r.classtype = 1 then 
			mone := 300 ;
		elsif r.classtype = 2 then
			mone := 275  ;
		elsif r.classtype = 3 then
			mone := 250  ;
		elsif r.classtype = 4 then
			mone := 225  ;
		elsif r.classtype = 5 then
			mone := 200  ;
		end if ;
		INSERT into ledger(year,week_no,student_id,money_to_be_paid,payment_status) values(yeari,weeki,r.id,mone,0) ;
	end loop ;
	return 1;

END;
$$ LANGUAGE plpgsql;

-- select * from generate_ledger(?,?,?) as A;

-- Daily present students organised per classroom
CREATE OR REPLACE FUNCTION attendance_perclassroom(yeari integer, weeki integer, dayi integer,license_idi text,classtypei integer)
RETURNS table(student_id_op int, first_name text, last_name text)
AS $$
DECLARE
BEGIN
return query 
	select student.id, student.first_name, student.last_name from student join attendance on student.id = attendance.id where attendance.week = weeki and attendance.year = yeari and attendance.day = dayi and attendance.present = 1 and student.classtype = classtypei and student.license_no = license_idi and attendance.user_type = 'student' ;
END;
$$ LANGUAGE plpgsql;



-- Daily absense organised per classroom
CREATE OR REPLACE FUNCTION attendance_absense_perclassroom(yeari integer, weeki integer, dayi integer,license_idi text,classtypei integer)
RETURNS table(student_id_op int, first_name text, last_name text)
AS $$
DECLARE
BEGIN
return query 
	select student.id, student.first_name, student.last_name from student join attendance on student.id = attendance.id where attendance.week = weeki and attendance.year = yeari and attendance.day = dayi and attendance.present = 0 and student.classtype = classtypei and student.license_no = license_idi and attendance.user_type = 'student' ;

END;
$$ LANGUAGE plpgsql;

-- Total money earned during the week by enrollments
CREATE OR REPLACE FUNCTION money_earned(yeari integer, weeki integer,license_idi text)
RETURNS integer
AS $$
DECLARE
total integer := 0;
BEGIN
select sum(ledger.money_to_be_paid) into total from ledger join student on ledger.student_id = student.id where ledger.payment_status = 1 and ledger.year = yeari and ledger.week_no = weeki and student.license_no = license_idi  ;
return total ;
END;
$$ LANGUAGE plpgsql;

-- Total money billed during the week
CREATE OR REPLACE FUNCTION money_billed(yeari integer, weeki integer,license_idi text)
RETURNS integer
AS $$
DECLARE
r record ;
cnt integer := 0;
tmp integer := 0;
BEGIN

for r in select * from teacher where teacher.license_no = license_idi LOOP
	tmp := cal_money_per_week(r.id,weeki,yeari) ;
	raise notice '%', tmp ;
	cnt := cnt + tmp;	
	raise notice '%',cnt ;
end LOOP ;
	raise notice 'Total money billed: %',cnt ;
return cnt ;

END;
$$ LANGUAGE plpgsql;


