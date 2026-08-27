package com.viipl.vaibhubg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBUtil {
    private static final Logger LOGGER = Logger.getLogger(DBUtil.class.getName());
    
    private static final String DB_URL = "jdbc:oracle:thin:@192.168.0.69:1521/orcl";
    private static final String DB_USER = "uppcltest";
    private static final String DB_PASSWORD = "uppcltest";
    private static final String DRIVER_CLASS = "oracle.jdbc.driver.OracleDriver";
    
    static {
        try {
            Class.forName(DRIVER_CLASS);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Oracle JDBC Driver not found", e);
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
    
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing database connection", e);
            }
        }
    }
}
