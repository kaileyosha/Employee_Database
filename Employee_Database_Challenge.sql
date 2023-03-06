--  Data is from https://github.com/vrajmohan/pgsql-sample-data/tree/master/employee
-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
  dept_no VARCHAR(4) NOT NULL,
  dept_name VARCHAR(40) NOT NULL,
  PRIMARY KEY (dept_no),
  UNIQUE (dept_name)
);

CREATE TABLE employees (
  emp_no INT NOT NULL,
  birth_date DATE NOT NULL,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  gender VARCHAR NOT NULL,
  hire_date DATE NOT NULL,
  PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(50) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, from_date)
);

--Check import for departments table
SELECT * FROM departments;

--Check imports for subsequent tables 
SELECT * FROM employees;

SELECT * FROM dept_emp;

SELECT * FROM dept_manager;

SELECT * FROM salaries; 

SELECT * FROM titles;

--Challenge Code: Deliverable One 
--Part one, retrieve emp_no, first name, last name from employees table 
SELECT employees.emp_no,
	employees.first_name,
	employees.last_name,
	employees.birth_date, --getting this and adding it to the retirement_employees table to use as a filter and later drop 
	--because my other solutions kept running errors 
	--and get the title, from_date, and to_date from titles
	titles.title,
	titles.from_date,
	titles.to_date
--make a new table
INTO retirement_employees
FROM employees
--joined on the primary key
INNER JOIN titles 
ON employees.emp_no = titles.emp_no
ORDER BY employees.emp_no

--Check that that worked
SELECT * FROM retirement_employees


--Now filter based on birthdates 
SELECT retirement_employees.emp_no,
	retirement_employees.first_name,
	retirement_employees.last_name,
	retirement_employees.title,
	retirement_employees.from_date,
	retirement_employees.to_date
INTO retirement_titles 
FROM retirement_employees 
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
ORDER BY retirement_employees.emp_no	

--check it worked
SELECT * FROM retirement_titles

--it did. so now we're going to export it as a csv 
	--exported. to refresh on mac control click tables, then hit refresh so all new tables are visible. 
	
--next, copy code from the starter code file
	--using distinct on to remove duplicates 
SELECT DISTINCT ON (emp_no) retirement_titles.emp_no,      --this says to select the first instance of the employee number 
	retirement_titles.first_name,
	retirement_titles.last_name,                 --and then it pulls the corresponding names and titles
	retirement_titles.title
INTO unique_titles
FROM retirement_titles
WHERE (to_date = '9999-01-01')         --filtering out those that have already left 
ORDER BY retirement_titles.emp_no, retirement_titles.to_date DESC;    --ordering by employee number and then descending by to_date 

--check it worked 
SELECT * FROM unique_titles 

--now export  unique_titles table 

--get title counts and put them into a table. 

SELECT COUNT(unique_titles.title), title  --this pulls the count of each title in unique_titles as well as the title itself
INTO retiring_titles
FROM unique_titles
GROUP BY unique_titles.title --this groups it by title
ORDER BY COUNT DESC;  --this orders the retiring_titles table in descending order based on the count

--check it worked 
SELECT * FROM retiring_titles

--it did, export. 


--Deliverable Two: Mentorship Eligibility 
SELECT DISTINCT ON (emp_no) employees.emp_no, --select first iteration of employee number and pull
	employees.first_name,
	employees.last_name,
	employees.birth_date, 
	dept_emp.from_date,
	dept_emp.to_date, 
	titles.title
INTO mentorship_eligibility --put into an other table 
FROM employees --from this table 
LEFT JOIN dept_emp --join matching data from this table 
ON employees.emp_no = dept_emp.emp_no --where these are equal
LEFT JOIN titles 
ON employees.emp_no = titles.emp_no
WHERE dept_emp.to_date = '9999-01-01' --specification of current employees 
	AND employees.birth_date BETWEEN '1965-01-01' AND '1965-12-31' --and embedded specification of DOB
ORDER BY employees.emp_no --put in order based on employee number 

--check it worked 
select * from mentorship_eligibility

--it did. export. 
