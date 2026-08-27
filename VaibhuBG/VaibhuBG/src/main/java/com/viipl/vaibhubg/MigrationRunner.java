package com.viipl.vaibhubg;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

/**
 * Simple migration helper that adds PO_NUMBER, PO_AMOUNT, and BG_WORKDESC to BG_MASTER in Oracle
 * if they do not already exist. It uses the existing DBUtil class for connection.
 *
 * Usage:
 * - Run from Eclipse as Java application (add ojdbc jar to project classpath) OR
 * - Compile and run from terminal providing ojdbc jar and compiled classes on classpath.
 */
public class MigrationRunner {
    public static void main(String[] args) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            boolean poNumberExists = columnExists(conn, "BG_MASTER", "PO_NUMBER");
            boolean poAmountExists = columnExists(conn, "BG_MASTER", "PO_AMOUNT");
            boolean bgWorkdescExists = columnExists(conn, "BG_MASTER", "BG_WORKDESC");

            if (poNumberExists && poAmountExists && bgWorkdescExists) {
                System.out.println("Columns PO_NUMBER, PO_AMOUNT, and BG_WORKDESC already exist on BG_MASTER. No action taken.");
                return;
            }

            String alterSql = "ALTER TABLE BG_MASTER ADD (PO_NUMBER VARCHAR2(255), PO_AMOUNT NUMBER(15,2), BG_WORKDESC VARCHAR2(255))";
            try (Statement st = conn.createStatement()) {
                st.execute(alterSql);
                System.out.println("Successfully added PO_NUMBER, PO_AMOUNT, and BG_WORKDESC to BG_MASTER.");
            }

        } catch (Exception e) {
            System.err.println("Migration failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    private static boolean columnExists(Connection conn, String tableName, String columnName) throws Exception {
        String sql = "SELECT COUNT(*) FROM USER_TAB_COLUMNS WHERE TABLE_NAME = ? AND COLUMN_NAME = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName.toUpperCase());
            ps.setString(2, columnName.toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int count = rs.getInt(1);
                    return count > 0;
                }
            }
        }
        return false;
    }
}
