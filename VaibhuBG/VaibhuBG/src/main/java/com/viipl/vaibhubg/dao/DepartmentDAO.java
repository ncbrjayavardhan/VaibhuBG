package com.viipl.vaibhubg.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.viipl.vaibhubg.DBUtil;

/* Requires DBUtil.getConnection() in your project */
public class DepartmentDAO {
    private static final String SQL_SELECT = "SELECT DEPT_NAME FROM BG_DEPT ORDER BY DEPT_NAME";

    public static List<String> getDepartments() {
        List<String> departments = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_SELECT);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                departments.add(rs.getString("DEPT_NAME"));
            }
        } catch (SQLException e) {
            // log or rethrow as needed in your project
            e.printStackTrace();
        }
        return departments;
    }
}
