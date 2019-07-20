-----------------------------------------------------------------------------
-- (c) Copyright IBM Corp. 2007 All rights reserved.
-- 
-- The following sample of source code ("Sample") is owned by International 
-- Business Machines Corporation or one of its subsidiaries ("IBM") and is 
-- copyrighted and licensed, not sold. You may use, copy, modify, and 
-- distribute the Sample in any form without payment to IBM, for the purpose of 
-- assisting you in the development of your applications.
-- 
-- The Sample code is provided to you on an "AS IS" basis, without warranty of 
-- any kind. IBM HEREBY EXPRESSLY DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR 
-- IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Some jurisdictions do 
-- not allow for the exclusion or limitation of implied warranties, so the above 
-- limitations or exclusions may not apply to you. IBM shall not be liable for 
-- any damages you suffer as a result of using, copying, modifying or 
-- distributing the Sample, even if IBM has been advised of the possibility of 
-- such damages.
-----------------------------------------------------------------------------
--
-- SOURCE FILE NAME: join.db2
--    
-- SAMPLE: How to OUTER JOIN tables 
--
-- SQL STATEMENT USED:
--         SELECT 
--
-- OUTPUT FILE: join.out (available in the online documentation)
-----------------------------------------------------------------------------
--
-- For more information about the command line processor (CLP) scripts, 
-- see the README file.
--
-- For information on using SQL statements, see the SQL Reference.
--
-- For the latest information on programming, building, and running DB2 
-- applications, visit the DB2 application development website: 
--     http://www.software.ibm.com/data/db2/udb/ad
-----------------------------------------------------------------------------

WITH 
 DEPT_MGR AS
  ( SELECT DEPTNO, DEPTNAME, EMPNO, LASTNAME, FIRSTNME, PHONENO
     FROM DEPARTMENT D, EMPLOYEE E
      WHERE D.MGRNO=E.EMPNO AND E.JOB='MANAGER'
  ),

 DEPT_NO_MGR AS
  ( SELECT DEPTNO, DEPTNAME, MGRNO AS EMPNO
      FROM DEPARTMENT
   EXCEPT ALL
    SELECT DEPTNO, DEPTNAME, EMPNO
      FROM DEPT_MGR
  ),

 MGR_NO_DEPT (DEPTNO, EMPNO, LASTNAME, FIRSTNME, PHONENO) AS
  ( SELECT WORKDEPT, EMPNO, LASTNAME, FIRSTNME, PHONENO
      FROM EMPLOYEE
       WHERE JOB='MANAGER'
   EXCEPT ALL
    SELECT DEPTNO,EMPNO, LASTNAME, FIRSTNME, PHONENO
      FROM DEPT_MGR
  )

SELECT DEPTNO, DEPTNAME, EMPNO, LASTNAME, FIRSTNME, PHONENO 
  FROM DEPT_MGR
UNION ALL
SELECT DEPTNO, DEPTNAME, EMPNO,
       CAST(NULL AS VARCHAR(15)) AS LASTNAME,
       CAST(NULL AS VARCHAR(12)) AS FIRSTNME,
       CAST(NULL AS CHAR(4)) AS PHONENO
  FROM DEPT_NO_MGR
UNION ALL
SELECT DEPTNO,
       CAST(NULL AS VARCHAR(29)) AS DEPTNAME,
       EMPNO, LASTNAME, FIRSTNME, PHONENO
  FROM MGR_NO_DEPT
ORDER BY 4;

