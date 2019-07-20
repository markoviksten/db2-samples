--********************************************************************/
--                                                                   */
--    IBM InfoSphere Replication Server                              */
--    Version 10 FPs for Linux, UNIX AND Windows                     */
--                                                                   */
--    Sample Q Replication migration script for UNIX AND NT          */
--    Licensed Materials - Property of IBM                           */
--                                                                   */
--    (C) Copyright IBM Corp. 1993, 2011. All Rights Reserved        */
--                                                                   */
--    US Government Users Restricted Rights - Use, duplication       */
--    or disclosure restricted by GSA ADP Schedule Contract          */
--    with IBM Corp.                                                 */
--                                                                   */
--********************************************************************/
-- File name: asnqappluworav10fp.sql
--
-- Script to migrate Q Apply control tables from V10GA to the latest
-- fixpack.
--
-- Prior to running this script, customize it to your existing
-- Q Apply server environment:
-- (1) Locate and change all occurrences of the string !server_name!
--     to the name of the federated Oracle data source
-- (2) Locate and change all occurrences of the string !remote_schema!
--     to the name of owner of the Oracle tables
-- (3) Locate and change all occurrences of the string !appschema!
--     to the name of the Q Apply schema applicable to your
--     environment
--
--********************************************************************/

ALTER TABLE !appschema!.IBMQREP_APPLYPARMS 
ADD COLUMN MULTI_ROW_INSERT CHARACTER(1) WITH DEFAULT 'Y'
ADD COLUMN EVENT_LIMIT INTEGER NOT NULL WITH DEFAULT 100080
ADD COLUMN EVENT_GEN CHARACTER(1) NOT NULL WITH DEFAULT 'N'
ADD COLUMN EVENT_INTERVAL INTEGER NOT NULL WITH DEFAULT 1000
ADD COLUMN EIF_HBINT INTEGER NOT NULL WITH DEFAULT 10000
ADD COLUMN EIF_CONN1 VARCHAR(291)
ADD COLUMN EIF_CONN2 VARCHAR(291);


DROP NICKNAME !appschema!.IBMQREP_RECVQUEUES; 
DROP NICKNAME !appschema!.IBMQREP_EXCEPTIONS; 


SET PASSTHRU !server_name!;


ALTER TABLE "!remote_schema!".IBMQREP_RECVQUEUES 
ADD 
(
  PARALLEL_SENDQS CHARACTER(1) DEFAULT 'N' NOT NULL
);

ALTER TABLE "!remote_schema!".IBMQREP_EXCEPTIONS 
ADD 
(
  SRC_INTENTSEQ RAW(48),
  AUTHID VARCHAR(128),
  AUTHTOKEN VARCHAR(30),
  PLANNAME VARCHAR(8)
);

COMMIT;

SET PASSTHRU RESET;


CREATE NICKNAME !appschema!.IBMQREP_RECVQUEUES FOR 
 !server_name!."!remote_schema!".IBMQREP_RECVQUEUES; 

ALTER NICKNAME !appschema!.IBMQREP_RECVQUEUES
 ALTER COLUMN NUM_APPLY_AGENTS LOCAL TYPE INTEGER
 ALTER COLUMN MEMORY_LIMIT LOCAL TYPE INTEGER
 ALTER COLUMN MAXAGENTS_CORRELID LOCAL TYPE INTEGER;
 

CREATE NICKNAME !appschema!.IBMQREP_EXCEPTIONS FOR 
 !server_name!."!remote_schema!".IBMQREP_EXCEPTIONS; 

ALTER NICKNAME !appschema!.IBMQREP_EXCEPTIONS
 ALTER COLUMN SQLCODE LOCAL TYPE INTEGER
 ALTER COLUMN TEXT LOCAL TYPE CLOB(32768);

