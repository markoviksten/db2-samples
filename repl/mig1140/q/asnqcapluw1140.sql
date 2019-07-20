--********************************************************************/
--                                                                   */
--          IBM InfoSphere Replication Server                        */
--      Version 11.4.0 for Linux, UNIX AND Windows                   */
--                                                                   */
--     Sample Q Replication migration script for UNIX AND Windows    */
--     Licensed Materials - Property of IBM                          */
--                                                                   */
--     (C) Copyright IBM Corp. 2019. All Rights Reserved             */
--                                                                   */
--     US Government Users Restricted Rights - Use, duplication      */
--     or disclosure restricted by GSA ADP Schedule Contract         */
--     with IBM Corp.                                                */
--                                                                   */
--********************************************************************/
-- Q Capture Migration script (asnqcapluwv1140.sql)

-- Script to migrate Q Capture control tables from V11.1 to V11.5 or higher.
--
-- Prior to running this script, customize it to your existing 
-- Q Capture server environment:
--
-- (1) Locate and change all occurrences of the string !CAPSCHEMA! 
--     to the name of the Q Capture schema applicable to your
--     environment.
-- (2) Locate and change all occurrences of the string !CAPTABLESPACE! if exists
--     to the name of the tablespace where your Q Capture control tables
--     are created.
-- (3) Run the script to migrate control tables into V11.5
--
-- (4) Do not update the compatibility to 1140 unless all the Q apply instances are migrated to 1140.

ALTER TABLE !CAPSCHEMA!.IBMQREP_SENDQUEUES ADD COLUMN HAS_FILESEND CHARACTER(1) WITH DEFAULT 'N';
ALTER TABLE !CAPSCHEMA!.IBMQREP_SENDQUEUES ADD COLUMN APPLY_LEVEL VARCHAR(10) WITH DEFAULT NULL;
REORG TABLE !CAPSCHEMA!.IBMQREP_SENDQUEUES;

UPDATE !CAPSCHEMA!.IBMQREP_SENDQUEUES SET APPLY_LEVEL = (SELECT COMPATIBILITY FROM !CAPSCHEMA!.IBMQREP_CAPPARMS);

UPDATE !CAPSCHEMA!.IBMQREP_CAPPARMS SET ARCH_LEVEL = '1140';

--UPDATE !CAPSCHEMA!.IBMQREP_CAPPARMS SET COMPATIBILITY = '1140';

UPDATE  !CAPSCHEMA!.IBMQREP_CAPPARMS SET LOGRDBUFSZ = 512 WHERE LOGRDBUFSZ = 256;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN IN_MEM_FILTER_EVAL CHARACTER(1) NOT NULL WITH DEFAULT 'Y';
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN USE_CAPCMD_TABLE CHARACTER(1) NOT NULL WITH DEFAULT 'N';
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN CAPCMD_INTERVAL INTEGER NOT NULL WITH DEFAULT 3000 ;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN MAX_CAPSTARTS_INTLOAD INTEGER NOT NULL WITH DEFAULT 0 ;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN MQTHREAD_BUFSZ INTEGER NOT NULL WITH DEFAULT 4096 ;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN PARALLEL_MQTHREAD CHARACTER(1) NOT NULL WITH DEFAULT 'N';
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN POSSIBLE_LEVEL VARCHAR(10) WITH DEFAULT NULL;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN CURRENT_LEVEL VARCHAR(10) WITH DEFAULT '1140.101';
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPPARMS ADD COLUMN CONTROL_TABLES_LEVEL VARCHAR(10) WITH DEFAULT '1140.101';

ALTER TABLE !CAPSCHEMA!.IBMQREP_SRC_COLS ADD COLUMN IS_PART_KEY SMALLINT NOT NULL WITH DEFAULT 0 ;

ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPMON ADD COLUMN PARALLEL_PUBLISH_WAIT INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPMON ADD COLUMN NUM_MQCMITS INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPMON ADD COLUMN NUM_LOGREAD_NO_PROG INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPMON ADD COLUMN NUM_LOGREAD_ERRORS INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPMON ADD COLUMN NUM_STMTFILES INTEGER;

ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPQMON ADD COLUMN TRANS_STREAMING INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPQMON ADD COLUMN TRANS_STREAM_BEGIN INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPQMON ADD COLUMN TRANS_STREAM_COMMIT INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPQMON ADD COLUMN TRANS_STREAM_ROLLBACK INTEGER;
ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPQMON ADD COLUMN STREAM_CHUNKS_PUBLISHED INTEGER;


CREATE TABLE !CAPSCHEMA!.IBMQREP_CAPCMD
(
 CMD_ID BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY(START WITH 1
 INCREMENT BY 1 ),
 CMD_INPUT_TIME TIMESTAMP NOT NULL WITH DEFAULT CURRENT TIMESTAMP,
 CMD_ORIGINATOR VARCHAR(128) NOT NULL WITH DEFAULT USER,
 CMD_TEXT VARCHAR(1024) NOT NULL,
 CMD_STATE CHARACTER(1) NOT NULL WITH DEFAULT 'P',
 CMD_RESULT_MSG VARCHAR(1024) WITH DEFAULT NULL,
 CMD_STATE_TIME TIMESTAMP NOT NULL WITH DEFAULT CURRENT TIMESTAMP,
 CMD_RESULT_RC INTEGER WITH DEFAULT NULL
)
ORGANIZE BY ROW
 IN !CAPTABLESPACE!;


ALTER TABLE !CAPSCHEMA!.IBMQREP_CAPCMD
 VOLATILE CARDINALITY;


CREATE INDEX !CAPSCHEMA!.IX1CAPCMD ON !CAPSCHEMA!.IBMQREP_CAPCMD
(
 CMD_ID
);


CREATE TABLE !CAPSCHEMA!.IBMQREP_CAPCMDOUT
(
 CMD_ID BIGINT NOT NULL,
 CMD_SEQUENCE SMALLINT NOT NULL,
 CMD_OUTPUT VARCHAR(4000) NOT NULL
)
ORGANIZE BY ROW
 IN !CAPTABLESPACE!;


CREATE INDEX !CAPSCHEMA!.IX1CAPCMDOUT ON !CAPSCHEMA!.IBMQREP_CAPCMDOUT
(
 CMD_ID,
 CMD_SEQUENCE
);


CREATE TABLE !CAPSCHEMA!.IBMQREP_FILE_SENDERS
(
 QMAPNAME VARCHAR(128) NOT NULL,
 FILESEND_PATH VARCHAR(1040),
 FILESEND_QUEUE VARCHAR(48) NOT NULL,
 FILESEND_ACK_QUEUE VARCHAR(48) NOT NULL,
 FILESEND_PARALLEL_DEGREE SMALLINT NOT NULL WITH DEFAULT 1 ,
 FILESEND_PRUNE_LIMIT INTEGER NOT NULL WITH DEFAULT 1440
)
ORGANIZE BY ROW
 IN !CAPTABLESPACE!;

CREATE UNIQUE INDEX !CAPSCHEMA!.IX1FILESENDERS ON !CAPSCHEMA!.IBMQREP_FILE_SENDERS
(
 QMAPNAME
);


CREATE TABLE !CAPSCHEMA!.IBMQREP_FILES_SENT
(
 FILE_ID VARBINARY(16) NOT NULL,
 QMAPNAME VARCHAR(128) NOT NULL,
 SUB_ID INTEGER NOT NULL,
 UOW VARBINARY(12),
 FILENAME VARCHAR(1040) NOT NULL,
 STATUS CHARACTER(1) NOT NULL,
 RC INTEGER,
 RC_TEXT VARCHAR(128),
 TOTAL_FILE_SIZE BIGINT,
 LAST_BYTE_SENT BIGINT,
 FIRST_MSG_TIME TIMESTAMP NOT NULL,
 LAST_MSG_TIME TIMESTAMP,
 LAST_MSG_SIZE BIGINT,
 LAST_MSG_ID BINARY(24),
 COORD_MSG_ID BINARY(24)
)
ORGANIZE BY ROW
 IN !CAPTABLESPACE!;


CREATE UNIQUE INDEX !CAPSCHEMA!.IX1FILESSENT ON !CAPSCHEMA!.IBMQREP_FILES_SENT
(
 FILE_ID,
 QMAPNAME,
 SUB_ID
);


CREATE TABLE !CAPSCHEMA!.IBMQREP_FILESEND_MON
(
 MONITOR_TIME TIMESTAMP NOT NULL,
 QMAPNAME VARCHAR(128) NOT NULL,
 BYTES BIGINT,
 MESSAGES INTEGER NOT NULL,
 XMITQDEPTH INTEGER NOT NULL,
 FILES_STARTED INTEGER NOT NULL,
 FILES_COMPLETED INTEGER NOT NULL,
 FILES_DELETED INTEGER NOT NULL,
 FILES_FAILED INTEGER NOT NULL,
 FILES_ACKS INTEGER NOT NULL,
 MQPUT_TIME INTEGER NOT NULL
)
ORGANIZE BY ROW
 IN !CAPTABLESPACE!;

CREATE UNIQUE INDEX !CAPSCHEMA!.IX1FILESENDMON ON !CAPSCHEMA!.IBMQREP_FILESEND_MON
(
 MONITOR_TIME,
 QMAPNAME
);

