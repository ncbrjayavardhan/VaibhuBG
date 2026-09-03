package com.iglsupport.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.iglsupport.config.DBConnection;

public class UserDAO {

    public static boolean validateUser(String userId, String pwd) {
        boolean status = false;
        
        // Note: `user` is a reserved keyword in MySQL, so wrap table name in backticks
        String sql = "SELECT * FROM `user` WHERE userId = ? AND pwd = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setString(1, userId);
            pst.setString(2, pwd);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    status = true;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return status;
    }
}