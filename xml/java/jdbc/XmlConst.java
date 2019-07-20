//***************************************************************************
// (c) Copyright IBM Corp. 2007 All rights reserved.
// 
// The following sample of source code ("Sample") is owned by International 
// Business Machines Corporation or one of its subsidiaries ("IBM") and is 
// copyrighted and licensed, not sold. You may use, copy, modify, and 
// distribute the Sample in any form without payment to IBM, for the purpose of 
// assisting you in the development of your applications.
// 
// The Sample code is provided to you on an "AS IS" basis, without warranty of 
// any kind. IBM HEREBY EXPRESSLY DISCLAIMS ALL WARRANTIES, EITHER EXPRESS OR 
// IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Some jurisdictions do 
// not allow for the exclusion or limitation of implied warranties, so the above 
// limitations or exclusions may not apply to you. IBM shall not be liable for 
// any damages you suffer as a result of using, copying, modifying or 
// distributing the Sample, even if IBM has been advised of the possibility of 
// such damages.
//***************************************************************************
//
// SOURCE FILE NAME: XmlConst.java
//
// SAMPLE: How to create UNIQUE index on XML columns
//
// SQL Statements USED:
//         SELECT
//
// JAVA 2 CLASSES USED:
//         Statement
//         PreparedStatement
//         ResultSet
//
// Classes used from Util.java are:
//         Db
//         Data
//         JdbcException
//
// OUTPUT FILE: XmlConst.out (available in the online documentation)
// Output will vary depending on the JDBC driver connectivity used.
//
// NOTE: Primary key, unique constraint, or unique index are not supported 
//       for XML column in the Database Partitioning Feature available with 
//       DB2 Enterprise Server Edition for Linux, UNIX, and Windows.
//
//***************************************************************************
//
// For more information on the sample programs, see the README file.
//
// For information on developing JDBC applications, see the Application
// Development Guide.
//
// For the latest information on programming, compiling, and running DB2
// applications, visit the DB2 application development website at
//     http://www.software.ibm.com/data/db2/udb/ad
//**************************************************************************/

import java.lang.*;
import java.sql.*;

class XmlConst 
{
  public static void main(String argv[])
  {
    Connection con=null;

    try
    {
      Db db = new Db(argv);
       
      System.out.println("THIS SAMPLE SHOWS HOW TO CREATE UNIQUE INDEX. \n");   

      // Connect to sample database
      db.connect();
       
      TbIndexUniqueConstraint1(db.con);
      dropall(db.con);
      TbIndexUniqueConstraint2(db.con);
      dropall(db.con);
      TbIndexVarcharConstraint(db.con);    
      dropall(db.con);
      TbIndexVarcharConstraint1(db.con);
 
      // disconnect from sample database
      db.disconnect();
    }
    catch (SQLException sqle)
    {
      System.out.println("Error Msg: "+ sqle.getMessage());
      System.out.println("SQLState: "+sqle.getSQLState());
      System.out.println("SQLError: "+sqle.getErrorCode());
      System.out.println("Rollback the transaction and quit the program");
      System.out.println();
      try { con.rollback(); }
      catch (Exception e)
      {
      }
      System.exit(1);
    }
    catch(Exception e)
    {}
  }

  static void TbIndexUniqueConstraint1(Connection con)
  {
    Statement stmt = null;
    try
    {
      System.out.println();
      System.out.println(
          "-------------------------------------------------\n" +
          "USE JAVA 2 CLASS: \n" +
          "statement \n" +
          "To execute a query. ");

      stmt = con.createStatement();

      //execute the query

      System.out.println();
      System.out.println(
         "Execute Statement:" +
         " CREATE TABLE COMPANY(id INT, docname VARCHAR(20), doc XML)");

      String create = "CREATE TABLE COMPANY(id INT, docname VARCHAR(20), doc XML)";
      stmt.executeUpdate(create);

      System.out.println("create unique index on XML column \n");

      System.out.println("CREATE UNIQUE INDEX empindex on company(doc)" +
                    "GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                    "AS SQL  DOUBLE\n");
    
      stmt = con.createStatement();
      stmt.executeUpdate("CREATE UNIQUE INDEX empindex on company(doc)" + 
			"GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                        "AS SQL  DOUBLE ");
    
      System.out.println("Insert row1 into table \n");

      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"31201\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))\n");

      stmt = con.createStatement();
      stmt.executeUpdate(
                 "INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"31201\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))");

      stmt = con.createStatement();
      System.out.println("Insert row2 into table \n");
      System.out.println("Unique violation error because of id=\"31201\"");
      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse " +
                  "(document '<company name=\"Company1\"> <emp id=\"31201\""+
                  " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                  " <name><first>Laura </first><last>Brown</last></name>" +
                  " <dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                  " </company>'))\n");  
 
      stmt.executeUpdate(
                 "INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"31201\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 " <dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 " </company>'))");
      stmt.close();
    }
    catch (SQLException sqle)
    {
      System.out.println("Error Msg: "+ sqle.getMessage());
      System.out.println("SQLState: "+sqle.getSQLState());
      System.out.println("SQLError: "+sqle.getErrorCode());
      System.out.println("Rollback the transaction and quit the program");
      System.out.println();
    }
    catch(Exception e)
    {}
  }

  static void TbIndexUniqueConstraint2(Connection con)
  {
    Statement stmt = null;
    try
    {
      System.out.println();
      System.out.println(
          "-------------------------------------------------\n" +
          "USE JAVA 2 CLASS: \n" +
          "statement \n" +
          "To execute a query. ");

      stmt = con.createStatement();

      //execute the query

      System.out.println();
      System.out.println(
         "Execute Statement:" +
         " CREATE TABLE COMPANY(ID int, DOCNAME VARCHAR(20), DOC XML)");

      String create = "CREATE TABLE COMPANY(ID int, DOCNAME VARCHAR(20), DOC XML)";
      stmt.executeUpdate(create);

      System.out.println("create unique index on XML column \n");
      System.out.println("CREATE UNIQUE INDEX empindex on company(doc)" +
                       "GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                        "AS SQL  DOUBLE\n");
      stmt = con.createStatement();
      stmt.executeUpdate("CREATE UNIQUE INDEX empindex on company(doc)" + 
			"GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                        "AS SQL  DOUBLE ");

      stmt = con.createStatement();
      System.out.println("Insert row3 into table \n");
      System.out.print("No index entry is inserted because \"ABCDE\"");
      System.out.println("cannot be cast to the DOUBLE data type.");  
      System.out.println();
      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse" +
                " (document '<company name=\"Company1\"><emp id=\"ABCDEFGHIJ\""+
                " salary=\"60000\" gender=\"Female\"><name><first>" +
                " Laura </first><last>Brown</last></name><dept id=\"M25\">" +
                " Finance</dept></emp></company>'))");
 
      stmt.executeUpdate(
                "INSERT INTO company values (1, 'doc1', xmlparse" +
                " (document '<company name=\"Company1\"><emp id=\"ABCDEFGHIJ\""+
                " salary=\"60000\" gender=\"Female\"><name><first>" +
                " Laura </first><last>Brown</last></name><dept id=\"M25\">" +
                " Finance</dept></emp></company>'))");

      stmt = con.createStatement();
      System.out.println("Insert row4 into table \n");
      System.out.print("The insert succeeds because no index entry is inserted"); 
      System.out.println("since \"ABCDE\" cannot be cast to the DOUBLE data type.");
      System.out.println();
      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse "+
               " (document '<company name=\"Company1\"><emp id=\"ABCDE"+
               "\" salary=\"60000\""+
               "gender=\"Female\"><name><first>Laura </first><last>Brown"+
               "</last></name> <dept id=\"M25\"> Finance</dept>"+
               "</emp></company>'))\n"); 

      stmt.executeUpdate(
               "INSERT INTO company values (1, 'doc1', xmlparse "+
               " (document '<company name=\"Company1\"><emp id=\"ABCDE\""+
               " salary=\"60000\" gender=\"Female\"><name><first>" +
               " Laura </first><last>Brown</last></name> <dept id=\"M25\">" +
               " Finance</dept></emp></company>'))");

      stmt.close();
    }
    catch (SQLException sqle)
    {
      System.out.println("Error Msg: "+ sqle.getMessage());
      System.out.println("SQLState: "+sqle.getSQLState());
      System.out.println("SQLError: "+sqle.getErrorCode());
      System.out.println("Rollback the transaction and quit the program");
      System.out.println();
    }
    catch(Exception e)
   {}
  }

  static void TbIndexVarcharConstraint(Connection con)
  {
    Statement stmt = null;
    try
    {
      System.out.println();
      System.out.println(
          "-------------------------------------------------\n" +
          "USE JAVA 2 CLASS: \n" +
          "statement \n" +
          "To execute a query. ");

      stmt = con.createStatement();

      //execute the query

      System.out.println();
      System.out.println(
         "Execute Statement:" +
         " CREATE TABLE COMPANY(ID int, DOCNAME VARCHAR(20), DOC XML)");

      String create = "CREATE TABLE COMPANY(id INT, docname VARCHAR(20), doc XML)";
      stmt.executeUpdate(create);

      System.out.println("create unique index on XML column \n");
      System.out.println("CREATE INDEX empindex on company(doc)" +
                    "GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                    "AS SQL VARCHAR(4)\n");
      stmt = con.createStatement();
      stmt.executeUpdate("CREATE INDEX empindex on company(doc)" +
                        "GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                        "AS SQL VARCHAR(4)");

      System.out.println("Insert row5 into table \n");
      System.out.println("Insert statement succeeds because the length of \"312\" < 4");
      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse " +
                   "(document '<company name=\"Company1\"> <emp id=\"312\""+
                   " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                   " <name><first>Laura </first><last>Brown</last></name>" +
                   "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                   "</company>'))\n");
                  
      stmt = con.createStatement();
      stmt.executeUpdate(
                 "INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"312\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))");

      System.out.println("Insert row6 into table \n");
      System.out.println("Insert statement fails because the length of \"31202\" > 4.");
      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"31202\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))\n");

      stmt = con.createStatement();
      stmt.executeUpdate(
                 "INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"31202\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))");
      stmt.close();
    }
    catch (SQLException sqle)
    {
      System.out.println("Error Msg: "+ sqle.getMessage());
      System.out.println("SQLState: "+sqle.getSQLState());
      System.out.println("SQLError: "+sqle.getErrorCode());
      System.out.println("Rollback the transaction and quit the program");
      System.out.println();
    }
    catch(Exception e)
   {}
  }

  static void TbIndexVarcharConstraint1(Connection con)
  {
    Statement stmt = null;
    try
    {
      System.out.println();
      System.out.println(
          "-------------------------------------------------\n" +
          "USE JAVA 2 CLASS: \n" +
          "statement \n" +
          "To execute a query. ");

      stmt = con.createStatement();

      //execute the query

      System.out.println();
      System.out.println(
         "Execute Statement:" +
         " CREATE TABLE COMPANY(ID int, DOCNAME VARCHAR(20), DOC XML)");

      String create = "CREATE TABLE COMPANY(id INT, docname VARCHAR(20), doc XML)";
      stmt.executeUpdate(create);
    
      System.out.println("Insert row7 into table \n");
      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse " +
                   "(document '<company name=\"Company1\"> <emp id=\"312\""+
                   " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                   " <name><first>Laura </first><last>Brown</last></name>" +
                   "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                   "</company>'))\n");

      stmt = con.createStatement();
      stmt.executeUpdate(
                 "INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"312\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))");

      System.out.println("Insert row8 into table \n");
      System.out.println("INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"31202\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))\n");

      stmt = con.createStatement();
      stmt.executeUpdate(
                 "INSERT INTO company values (1, 'doc1', xmlparse " +
                 "(document '<company name=\"Company1\"> <emp id=\"31202\""+
                 " salary=\"60000\" gender=\"Female\" DOB=\"10-10-80\">" +
                 " <name><first>Laura </first><last>Brown</last></name>" +
                 "<dept id=\"M25\">Finance</dept><!-- good --></emp>" +
                 "</company>'))");

      System.out.println("create index with Varchar constraint fails " +
                       "because the length of \"31202\" > 4");
      System.out.println("CREATE INDEX empindex on company(doc)" +
                    "GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                    "AS SQL VARCHAR(4)\n");
      stmt = con.createStatement();
      stmt.executeUpdate("CREATE INDEX empindex on company(doc)" +
                        "GENERATE KEY USING XMLPATTERN '/company/emp/@id'" +
                        "AS SQL VARCHAR(4)");   

      stmt.close();
    }
    catch (SQLException sqle)
    {
      System.out.println("Error Msg: "+ sqle.getMessage());
      System.out.println("SQLState: "+sqle.getSQLState());
      System.out.println("SQLError: "+sqle.getErrorCode());
      System.out.println("Rollback the transaction and quit the program");
      System.out.println();
      try { con.rollback(); }
      catch (Exception e)
      {
      }
      System.exit(1);
    }
    catch(Exception e)
   {}
  }

  static void dropall(Connection con)
  {
    Statement stmt = null;
    try
    {
      System.out.println("drop index and table \n");
      stmt = con.createStatement();
      stmt.executeUpdate("DROP INDEX \"EMPINDEX\"");
      stmt.executeUpdate("DROP TABLE \"COMPANY\"");
      stmt.close();
    }
    catch (SQLException sqle)
    {
      System.out.println("Error Msg: "+ sqle.getMessage());
      System.out.println("SQLState: "+sqle.getSQLState());
      System.out.println("SQLError: "+sqle.getErrorCode());
      System.out.println("Rollback the transaction and quit the program");
      System.out.println();
      try { con.rollback(); }
      catch (Exception e)
      {
      }
      System.exit(1);
    }
    catch(Exception e)
   {}
  }
}
