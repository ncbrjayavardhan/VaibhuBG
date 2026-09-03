package com.iglsupport.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import com.iglsupport.config.DBConnection;

public class UserDAO {

    public static class UserSessionInfo {
        private String role;
        private Integer gid;

        public UserSessionInfo(String role, Integer gid) {
            this.role = role;
            this.gid = gid;
        }

        public String getRole() { return role; }
        public Integer getGid() { return gid; }
    }

    public static boolean validateUser(String userId, String pwd) {
        boolean status = false;
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
    
    public static UserSessionInfo getUserInfo(String userId, String pwd) {
        UserSessionInfo userInfo = null;
        String sql = "SELECT role, gid FROM `user` WHERE userId = ? AND pwd = ? AND status = 'Active'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql)) {

            pst.setString(1, userId);
            pst.setString(2, pwd);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    int gid = rs.getInt("gid");
                    Integer gidObj = rs.wasNull() ? null : gid;
                    userInfo = new UserSessionInfo(role, gidObj);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return userInfo;
    }
}