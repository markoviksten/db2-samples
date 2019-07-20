--********************************************************************/
--                                                                   */
--          IBM InfoSphere Replication Server                        */
--      Version 10.5 FPs for Linux, UNIX AND Windows                 */
--                                                                   */
--     Sample SQL Replication migration script for UNIX AND NT       */
--     Licensed Materials - Property of IBM                          */
--                                                                   */
--     (C) Copyright IBM Corp. 2015. All Rights Reserved             */
--                                                                   */
--     US Government Users Restricted Rights - Use, duplication      */
--     or disclosure restricted by GSA ADP Schedule Contract         */
--     with IBM Corp.                                                */
--                                                                   */
--********************************************************************/
-- Script to migrate SQL Capture control tables from V10.5 Fixpak 7 to the latest
-- fixpack.
--
-- IMPORTANT:
-- * Please refer to the SQL Rep migration doc before attempting this migration.
--
-- Prior to running this script, customize it to your existing 
-- SQL Capture server environment:
-- (1) Locate and change all occurrences of the string !capschema! 
--     to the name of the SQL Capture schema applicable to your
--     environment.
-- (2) Locate and change all occurrences of the string !captablespace! 
--     to the name of the tablespace where your SQL Capture control tables
--     are created.   
--
--***********************************************************

