package com.vaibhutrans.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:oracle:thin:@192.168.0.69:1521:ORCL"; // Replace ORCL with your Oracle SID / Service Name
    private static final String USER = "uppcltest";
    private static final String PASSWORD = "uppcltest";

    static {
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}

//package com.vaibhutrans.config;
//
//import java.sql.Connection;
//import java.sql.DriverManager;
//import java.sql.SQLException;
//
//public class DBConnection {
//
////	private static final String URL = "jdbc:postgresql://localhost:5432/vaibhu_db";
//    private static final String URL = "jdbc:postgresql://jay.spoorthy.net:5432/vaibhu_db";
//    private static final String USER = "jay";
//    private static final String PASSWORD = "jay@123";
//
//    static {
//        try {
//            Class.forName("org.postgresql.Driver");
//        } catch (ClassNotFoundException e) {
//            e.printStackTrace();
//        }
//    }
//
//    public static Connection getConnection() throws SQLException {
//        return DriverManager.getConnection(URL, USER, PASSWORD);
//    }
//}