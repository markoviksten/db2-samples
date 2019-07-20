-- Script to migrate Q Capture control tables from V8.2 to V9.1.
--
-- Prior to running this script, customize it to your existing 
-- Q Capture server environment:
-- (1) Locate and change all occurrences of the string !capschema! 
--     to the name of the Q Capture schema applicable to your
--     environment
-- (2) update <TS>  with the tablespace name.
--
-- (3) Run the script to migrate control tables into V9.
--

ALTER TABLE !capschema!.IBMQREP_CAPPARMS VOLATILE CARDINALITY;
ALTER TABLE !capschema!.IBMQREP_SENDQUEUES VOLATILE CARDINALITY;
ALTER TABLE !capschema!.IBMQREP_SUBS VOLATILE CARDINALITY;
ALTER TABLE !capschema!.IBMQREP_SRC_COLS VOLATILE CARDINALITY;
ALTER TABLE !capschema!.IBMQREP_SIGNAL VOLATILE CARDINALITY;
ALTER TABLE !capschema!.IBMQREP_CAPMON VOLATILE CARDINALITY;
ALTER TABLE !capschema!.IBMQREP_CAPQMON VOLATILE CARDINALITY;
ALTER TABLE !capschema!.IBMQREP_ADMINMSG VOLATILE CARDINALITY;

ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_STARTMODE;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_MEMORY_LIMIT;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_COMMIT_INTERVAL;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_AUTOSTOP;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_MON_INTERVAL;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_MON_LIMIT;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_TRACE_LIMT;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_SIGNAL_LIMIT;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_PRUNE_INTERVAL;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_LOGREUSE;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_LOGSTDOUT;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_TERM;
ALTER TABLE !capschema!.IBMQREP_CAPPARMS DROP CHECK CC_SLEEP_INTERVAL;
  
ALTER TABLE !capschema!.IBMQREP_CAPPARMS
  ADD COLUMN COMPATIBILITY CHAR(4) NOT NULL WITH DEFAULT '0901';
    
ALTER TABLE !capschema!.IBMQREP_CAPPARMS
  ALTER COLUMN ARCH_LEVEL SET DEFAULT '0901'
  ALTER COLUMN MONITOR_INTERVAL SET DEFAULT 300000;  
  
ALTER TABLE !capschema!.IBMQREP_SENDQUEUES DROP CHECK CC_MSG_FORMAT;
ALTER TABLE !capschema!.IBMQREP_SENDQUEUES DROP CHECK CC_MSG_CONT_TYPE;
ALTER TABLE !capschema!.IBMQREP_SENDQUEUES DROP CHECK CC_SENDQ_STATE;
ALTER TABLE !capschema!.IBMQREP_SENDQUEUES DROP CHECK CC_QERRORACTION;
ALTER TABLE !capschema!.IBMQREP_SENDQUEUES DROP CHECK CC_HTBEAT_INTERVAL;

ALTER TABLE !capschema!.IBMQREP_SENDQUEUES
  ADD COLUMN MESSAGE_CODEPAGE INTEGER ;  
  
ALTER TABLE !capschema!.IBMQREP_SUBS DROP CHECK CC_SUBTYPE;
ALTER TABLE !capschema!.IBMQREP_SUBS DROP CHECK CC_ALL_CHGD_ROWS;
ALTER TABLE !capschema!.IBMQREP_SUBS DROP CHECK CC_BEFORE_VALUES;
ALTER TABLE !capschema!.IBMQREP_SUBS DROP CHECK CC_CHGD_COLS_ONLY;
ALTER TABLE !capschema!.IBMQREP_SUBS DROP CHECK CC_HAS_LOADPHASE;
ALTER TABLE !capschema!.IBMQREP_SUBS DROP CHECK CC_SUBS_STATE;
ALTER TABLE !capschema!.IBMQREP_SUBS DROP CHECK CC_SUPPRESS_DELS;

ALTER TABLE !capschema!.IBMQREP_SRC_COLS
  ADD COLUMN COL_OPTIONS_FLAG CHAR(10) NOT NULL WITH DEFAULT 'NNNNNNNNNN';
  
ALTER TABLE !capschema!.IBMQREP_CAPMON
  ADD COLUMN LAST_EOL_TIME TIMESTAMP;  

ALTER TABLE !capschema!.IBMQREP_SIGNAL DROP CHECK CC_SIGNAL_TYPE;
ALTER TABLE !capschema!.IBMQREP_SIGNAL DROP CHECK CC_SIGNAL_STATE;
ALTER TABLE !capschema!.IBMQREP_SIGNAL DROP PRIMARY KEY;


UPDATE !capschema!.IBMQREP_CAPPARMS SET ARCH_LEVEL = '0901';

UPDATE !capschema!.IBMQREP_CAPPARMS SET COMPATIBILITY = '0802';

--
-- Starting V9.1, the values in the MONITOR_INTERVAL column
-- are interpreted as milliseconds. They were interpreted
-- as seconds in Version 8.
-- The following UPDATE statement is to change the unit
-- from second to millisecond by multiplying the current
-- values by 1000 during the migration of the control
-- tables from Version 8 to Version 9.1.

UPDATE !capschema!.IBMQREP_CAPPARMS
  SET MONITOR_INTERVAL = MONITOR_INTERVAL * 1000;

UPDATE !capschema!.IBMQREP_SUBS SET TARGET_TYPE = 1 
      WHERE TARGET_TYPE=3;

UPDATE !capschema!.IBMQREP_SRC_COLS SET COL_OPTIONS_FLAG= 'YNNNNNNNNN' 
   WHERE SUBNAME IN (SELECT A.SUBNAME FROM !capschema!.IBMQREP_SRC_COLS A, !capschema!.IBMQREP_SUBS B WHERE A.SUBNAME= B.SUBNAME AND B.BEFORE_VALUES='Y' );
   
UPDATE !capschema!.IBMQREP_SRC_COLS SET COL_OPTIONS_FLAG= 'YNNNNNNNNN'
   WHERE IS_KEY IN (SELECT A.IS_KEY FROM !capschema!.IBMQREP_SRC_COLS A, !capschema!.IBMQREP_SUBS B WHERE A.SUBNAME= B.SUBNAME AND B.BEFORE_VALUES='N' AND A.IS_KEY > 0 );

CREATE TABLE !capschema!.IBMQREP_IGNTRAN
(
 AUTHID CHARACTER(128),
 AUTHTOKEN CHARACTER(30),
 PLANNAME CHARACTER(8)
)
 IN <TS>;

CREATE TABLE !capschema!.IBMQREP_IGNTRANTRC
(
 IGNTRAN_TIME TIMESTAMP NOT NULL WITH DEFAULT CURRENT TIMESTAMP,
 AUTHID CHARACTER(128),
 AUTHTOKEN CHARACTER(30),
 PLANNAME CHARACTER(8),
 TRANSID CHARACTER(10) FOR BIT DATA NOT NULL,
 COMMITLSN CHARACTER(10) FOR BIT DATA NOT NULL
)
 IN <TS>;


