----------------------------------------------------------------------------
-- (c) Copyright IBM Corp. 2008 All rights reserved.
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
-- SOURCE FILE NAME: wlmtierstimerons.db2
--
-- SAMPLE: This script sets up a DB2 Workload Manager (WLM) tiered service
--         class configuration for a database. Use this tiered service class
--         configuration to implement priority aging to help improve database 
--         throughput. Priority aging decreases the priority of incoming
--         activities in response to the processing time used (CPU).
--         This script also demonstrates the use of service classes, workloads, 
--         work action sets and thresholds. This script differs from 
--         wlmtiersdefault.db2 in that the estimated cost is taken into account 
--         when initially mapping DML activities to service classes.
--
--     *************************************************************************
--     NOTE: This script enables WLM Dispatcher and CPU Shares for the instance.
--     *************************************************************************
--
--     Actions performed by this script:
--
--     1.  Create the service superclass WLM_TIERS and three service subclasses
--         within it, WLM_SHORT, WLM_MEDIUM and WLM_LONG.
--
--     2.  Create threshold WLM_TIERS_REMAP_SHORT_TO_MEDIUM to remap
--         activities from service subclass WLM_SHORT to WLM_MEDIUM after
--         activities consume a certain amount of processor time in WLM_SHORT.
--         Create threshold WLM_TIERS_REMAP_MEDIUM_TO_LONG to remap
--         activities from service subclass WLM_MEDIUM to WLM_LONG after
--         activities consume a certain amount of processor time in WLM_MEDIUM.
--         For activities that cannot be remapped using a CPUTIMEINSC threshold
--         are mapped to the WLM_MEDIUM service subclass.  These activities
--         will stay in the WLM_MEDIUM service subclass and will not get 
--         remapped.
--
--     3.  Create work class set WLM_TIERS_WCS to differentiate DML activities 
--         with small, medium and large estimated costs in timerons.
--
--     4.  Create work action set WLM_TIERS_WAS to map the work classes in
--         WLM_TIERS_WCS to service classes WLM_SHORT, WLM_MEDIUM and
--         WLM_LONG.
--
--     5.  Set the service class properties for the service classes created.
--         For service class properties and instructions on how to modify these
--         properties to suit your environment, see the next section.
--
--     6.  Set the threshold properties for the thresholds created. For
--         threshold properties and instructions on how to modify these
--         properties to suit your environment, see the next section.
--
--     7.  Set work class properties for the work class set created. For
--         work class set properties and instructions on how to customize the
--         threshold properties to suit your environment, see the next section.
--
--     8.  Alter the the default user workload SYSDEFAULTUSERWORKLOAD to map
--         incoming connections to service class WLM_TIERS. Any connection that
--         does not belong to a user defined workload is placed in
--         SYSDEFAULTUSERWORKLOAD.
--
-- With this configuration, DML activities are evaluated based on their
-- estimated cost and placed into service class WLM_SHORT, WLM_MEDIUM or
-- WLM_LONG accordingly. Service class WLM_SHORT has higher resource priority
-- settings than WLM_MEDIUM, which has higher resource priority settings than
-- WLM_LONG. Non-DML activities enter service class WLM_SHORT. Short activities
-- will complete in WLM_SHORT unless they exceed the maximum amount of processor
-- time specified in threshold WLM_TIERS_REMAP_SHORT_TO_MEDIUM. Longer
-- activities are remapped to WLM_MEDIUM where they will complete unless they
-- exceed the maximum amount of CPU time specified in threshold
-- WLM_TIERS_REMAP_MEDIUM_TO_LONG. The longest running activities are remapped
-- to WLM_LONG, where they will execute until they complete.
-----------------------------------------------------------------------------
--
-- WLM TIERS SERVICE CLASS, THRESHOLD AND WORK CLASS SET PROPERTIES
--
-- Following are the service class, threshold and work class set properties set
-- by this script. You can customize these properties to better fit your
-- environment; search for the '#PROPERTY#' tag in this script to identify where
-- service class, threshold and work class set properties are set. Update the
-- properties and rerun this script for your new properties to take effect.
--
-- Note: Repeat runs of this script will return the SQL0601N message for the
-- CREATE SERVICE CLASS, CREATE THRESHOLD and CREATE WORK CLASS SET DDL
-- statements. Repeat runs will also return the SQL4704N message for the CREATE
-- WORK ACTION SET statement. This is expected because these WLM objects are
-- already created.
--
-- Service class properties:
--
--    Service Class    CPU Shares   Prefetch Priority
--                     (hard)
--    -----------------------------------------------
--    WLM_SHORT        6000         High
--    WLM_MEDIUM       3000         Medium
--    WLM_LONG         1000         Low
--    Default System   default      High
--    Default Maint.   default      Low
--
-- Threshold properties:
--
--   Threshold                         CPU Time Used in Service
--                                     Class Before Remap
--   ----------------------------------------------------------
--   WLM_TIERS_REMAP_SHORT_TO_MEDIUM   10 seconds
--   WLM_TIERS_REMAP_MEDIUM_TO_LONG    10 seconds
--
-- Work class set properties:
--
--   Work Class        Estimated Cost in
--                     Timerons (From/To)
--   ------------------------------------
--   WLM_SHORT_DML_WC         0/1000
--   WLM_MEDIUM_DML_WC    >1000/100000
--   WLM_LONG_DML_WC    >100000/infinity
--   WLM_CALL_WC        *see note below*
--   WLM_OTHER_WC       *see note below*
--
--   Note:
--   Work classes WLM_CALL_WC and WLM_OTHER_WC contain CALL activities and other
--   activities that do not have cost estimates.  Estimated cost is available
--   only for DML statements. Non-DML activities such as DDL and LOAD will fall
--   under the WLM_OTHER_WC work class. Activities grouped under WLM_CALL_WC are
--   mapped to service class WLM_SHORT initially.  Activities grouped under
--   WLM_OTHER_WC are mapped to service class WLM_MEDIUM and will not get
--   remapped.
-----------------------------------------------------------------------------
--
-- USAGE
--
--    1. Connect to your database at the catalog partition. You must connect
--       at the catalog partition for this script to run successfully.
--       You must have DBADM or WLMADM authority.
--
--    2. In order to capture threshold violation events, create WLM event
--       monitors using the wlmevmon.ddl script in sqllib/misc directory.
--
--    3. Use the following command to execute this script. This sample uses
--       @ as the delimiting character.
--
--          db2 -td@ -vf wlmtierstimerons.db2
--
--    4. Reset the connection.
--
-----------------------------------------------------------------------------
--
-- For more information about the command line processor (CLP) scripts,
-- see the README file.
--
-- For information on the SQL statements, see the SQL Reference.
--
-- For the latest information on programming, building, and running DB2
-- applications, visit the DB2 application development website:
--     http://www.software.ibm.com/data/db2/udb/ad
-----------------------------------------------------------------------------

-- Enable WLM Dispatcher and CPU Shares
UPDATE DBM CFG USING WLM_DISPATCHER YES WLM_DISP_CPU_SHARES YES@


-- Create service superclass WLM_TIERS
CREATE SERVICE CLASS WLM_TIERS@


-- Create service subclasses WLM_SHORT, WLM_MEDIUM, WLM_LONG
CREATE SERVICE CLASS WLM_SHORT UNDER WLM_TIERS@

CREATE SERVICE CLASS WLM_MEDIUM UNDER WLM_TIERS@

CREATE SERVICE CLASS WLM_LONG UNDER WLM_TIERS@


-- Create thresholds to remap activities from WLM_SHORT to WLM_MEDIUM
-- to WLM_LONG service subclasses based on processor time used in service class
CREATE THRESHOLD WLM_TIERS_REMAP_SHORT_TO_MEDIUM FOR
  SERVICE CLASS WLM_SHORT UNDER WLM_TIERS ACTIVITIES
  ENFORCEMENT DATABASE PARTITION WHEN
  CPUTIMEINSC > 10 SECONDS CHECKING EVERY 5 SECONDS
  REMAP ACTIVITY TO WLM_MEDIUM@

CREATE THRESHOLD WLM_TIERS_REMAP_MEDIUM_TO_LONG FOR
  SERVICE CLASS WLM_MEDIUM UNDER WLM_TIERS ACTIVITIES
  ENFORCEMENT DATABASE PARTITION WHEN
  CPUTIMEINSC > 10 SECONDS CHECKING EVERY 5 SECONDS
  REMAP ACTIVITY TO WLM_LONG@


-- Create work class set WLM_TIERS_WCS
CREATE WORK CLASS SET WLM_TIERS_WCS
  ( WORK CLASS WLM_SHORT_DML_WC WORK TYPE DML,
    WORK CLASS WLM_MEDIUM_DML_WC WORK TYPE DML,
    WORK CLASS WLM_LONG_DML_WC WORK TYPE DML,
    WORK CLASS WLM_CALL_WC WORK TYPE CALL,
    WORK CLASS WLM_OTHER_WC WORK TYPE ALL)@


-- Create work action set WLM_TIERS_WAS to map activities grouped under
-- each work class in work class set WLM_TIERS_WCS to the corresponding
-- service subclass.
CREATE WORK ACTION SET WLM_TIERS_WAS FOR SERVICE CLASS WLM_TIERS
  USING WORK CLASS SET WLM_TIERS_WCS
  ( WORK ACTION WLM_SHORT_DML_WA ON WORK CLASS WLM_SHORT_DML_WC
      MAP ACTIVITY TO WLM_SHORT,
    WORK ACTION WLM_MEDIUM_DML_WA ON WORK CLASS WLM_MEDIUM_DML_WC
      MAP ACTIVITY TO WLM_MEDIUM,
    WORK ACTION WLM_LONG_DML_WA ON WORK CLASS WLM_LONG_DML_WC
      MAP ACTIVITY TO WLM_LONG,
    WORK ACTION WLM_CALL_WA ON WORK CLASS WLM_CALL_WC
      MAP ACTIVITY TO WLM_SHORT,
    WORK ACTION WLM_OTHER_WA ON WORK CLASS WLM_OTHER_WC
      MAP ACTIVITY TO WLM_MEDIUM )@


-- #PROPERTY# Set CPU shares for service classes.
ALTER SERVICE CLASS WLM_SHORT UNDER WLM_TIERS CPU SHARES 6000@

ALTER SERVICE CLASS WLM_MEDIUM UNDER WLM_TIERS CPU SHARES 3000@

ALTER SERVICE CLASS WLM_LONG UNDER WLM_TIERS CPU SHARES 1000@


-- #PROPERTY# Set prefetch priority for service classes. Valid values for
-- prefetch priority are HIGH, MEDIUM, LOW or DEFAULT (MEDIUM).
ALTER SERVICE CLASS SYSDEFAULTSYSTEMCLASS PREFETCH PRIORITY HIGH@

ALTER SERVICE CLASS SYSDEFAULTMAINTENANCECLASS PREFETCH PRIORITY LOW@

ALTER SERVICE CLASS WLM_SHORT UNDER WLM_TIERS PREFETCH PRIORITY HIGH@

ALTER SERVICE CLASS WLM_MEDIUM UNDER WLM_TIERS PREFETCH PRIORITY MEDIUM@

ALTER SERVICE CLASS WLM_LONG UNDER WLM_TIERS PREFETCH PRIORITY LOW@


-- #PROPERTY# Set the maximum in service class processor time before 
-- remapping and the checking period.  The maximum in service class processor 
-- time determines how much processor time an activity can consume in
-- a service class before being remapped to the target service class.
-- For example, if you want an activity to remain in service class
-- WLM_SHORT for a shorter period before being remapped to WLM_MEDIUM,
-- decrease the CPUTIMEINSC threshold value for WLM_TIERS_REMAP_SHORT_TO_MEDIUM.
-- The checking period determines how long to wait between checks for threshold
-- violation.  For serial ESE instances, set the checking period to be
-- the same as the processor time before remap.  For DPF or SMP instances,
-- set a lower value for the checking period than the processor time
-- before remap.
--
-- When one of these thresholds is violated and an activity is remapped
-- to the next service subclass, an event monitor record is written to
-- the threshold violations event monitor.  This way, you can see
-- how many activities are moved between the tiers service subclasses.
-- Logging an event monitor record incurs a small performance cost.  Once
-- the system is tuned and the threshold violation event monitor records
-- are no longer needed, simply remove the 'LOG EVENT MONITOR RECORD'
-- clause from the ALTER THRESHOLD statements.
ALTER THRESHOLD WLM_TIERS_REMAP_SHORT_TO_MEDIUM WHEN
  CPUTIMEINSC > 10 SECONDS CHECKING EVERY 5 SECONDS
  REMAP ACTIVITY TO WLM_MEDIUM LOG EVENT MONITOR RECORD@

ALTER THRESHOLD WLM_TIERS_REMAP_MEDIUM_TO_LONG WHEN
  CPUTIMEINSC > 10 SECONDS CHECKING EVERY 5 SECONDS
  REMAP ACTIVITY TO WLM_LONG LOG EVENT MONITOR RECORD@


-- #PROPERTY# Set work class properties for work class set WLM_TIERS_WCS.
-- This setting determines the initial mapping of DML activites to the
-- service subclasses based on estimated cost. For example, if you want
-- DML activities with a higher estimated cost to map to service class
-- WLM_SHORT instead of WLM_MEDIUM initially, increase the TO value of
-- WLM_SHORT_DML_WC and decrease the corresponding FROM value of WLM_MEDIUM_DML_WC.
ALTER WORK CLASS SET WLM_TIERS_WCS
  ALTER WORK CLASS WLM_SHORT_DML_WC FOR TIMERONCOST FROM 0 TO 1000
  ALTER WORK CLASS WLM_MEDIUM_DML_WC FOR TIMERONCOST FROM 1000 TO 100000
  ALTER WORK CLASS WLM_LONG_DML_WC FOR TIMERONCOST FROM 100000 TO UNBOUNDED@


-- Alter SYSDEFAULTUSERWORKLOAD to map workload to WLM_TIERS service class
ALTER WORKLOAD SYSDEFAULTUSERWORKLOAD SERVICE CLASS WLM_TIERS@
