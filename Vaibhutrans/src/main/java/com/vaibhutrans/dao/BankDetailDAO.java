package com.vaibhutrans.dao;

import com.vaibhutrans.config.DBConnection;
import com.vaibhutrans.model.BankDetail;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BankDetailDAO {

    // Existing Batch MERGE method for Excel Upload
    public void saveOrUpdateBankDetails(List<BankDetail> bankDetailsList) throws SQLException {
        String sql = "MERGE INTO bank_details b " +
                     "USING DUAL ON (b.benf_account = ?) " +
                     "WHEN MATCHED THEN " +
                     "  UPDATE SET b.benf_name = ?, b.benf_ifsc = ?, b.benf_branch = ?, b.benf_bank = ? " +
                     "WHEN NOT MATCHED THEN " +
                     "  INSERT (benf_account, benf_name, benf_ifsc, benf_branch, benf_bank) " +
                     "  VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            conn.setAutoCommit(false);
            for (BankDetail bd : bankDetailsList) {
                ps.setString(1, bd.getBenfAccount());
                
                // Update Bindings
                ps.setString(2, bd.getBenfName());
                ps.setString(3, bd.getBenfIfsc());
                ps.setString(4, bd.getBenfBranch());
                ps.setString(5, bd.getBenfBank());

                // Insert Bindings
                ps.setString(6, bd.getBenfAccount());
                ps.setString(7, bd.getBenfName());
                ps.setString(8, bd.getBenfIfsc());
                ps.setString(9, bd.getBenfBranch());
                ps.setString(10, bd.getBenfBank());

                ps.addBatch();
            }
            ps.executeBatch();
            conn.commit();
        }
    }

    // NEW METHOD: Fetch all records for bank_report.jsp
    public List<BankDetail> getAllBankDetails() throws SQLException {
        List<BankDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM bank_details ORDER BY benf_name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                BankDetail bd = new BankDetail(
                    rs.getString("benf_account"),
                    rs.getString("benf_name"),
                    rs.getString("benf_ifsc"),
                    rs.getString("benf_branch"),
                    rs.getString("benf_bank")
                );
                list.add(bd);
            }
        }
        return list;
    }

    // NEW METHOD: Fetch single record for edit_bank_detail.jsp
    public BankDetail getBankDetailByAccount(String benfAccount) throws SQLException {
        String sql = "SELECT * FROM bank_details WHERE benf_account = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, benfAccount);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new BankDetail(
                        rs.getString("benf_account"),
                        rs.getString("benf_name"),
                        rs.getString("benf_ifsc"),
                        rs.getString("benf_branch"),
                        rs.getString("benf_bank")
                    );
                }
            }
        }
        return null;
    }

    // NEW METHOD: Save changes submitted from edit_bank_detail.jsp
    public boolean updateBankDetail(BankDetail bd) throws SQLException {
        String sql = "UPDATE bank_details SET benf_name=?, benf_ifsc=?, benf_branch=?, benf_bank=? WHERE benf_account=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, bd.getBenfName());
            ps.setString(2, bd.getBenfIfsc());
            ps.setString(3, bd.getBenfBranch());
            ps.setString(4, bd.getBenfBank());
            ps.setString(5, bd.getBenfAccount());

            return ps.executeUpdate() > 0;
        }
    }
    
 // Add to BankDetailDAO.java

    public List<BankDetail> searchBankDetails(String account, String name, String bank) throws SQLException {
        List<BankDetail> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM bank_details WHERE 1=1");

        if (account != null && !account.trim().isEmpty()) {
            sql.append(" AND LOWER(benf_account) LIKE LOWER(?)");
        }
        if (name != null && !name.trim().isEmpty()) {
            sql.append(" AND LOWER(benf_name) LIKE LOWER(?)");
        }
        if (bank != null && !bank.trim().isEmpty()) {
            sql.append(" AND LOWER(benf_bank) LIKE LOWER(?)");
        }

        sql.append(" ORDER BY benf_name ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (account != null && !account.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + account.trim() + "%");
            }
            if (name != null && !name.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + name.trim() + "%");
            }
            if (bank != null && !bank.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + bank.trim() + "%");
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new BankDetail(
                        rs.getString("benf_account"),
                        rs.getString("benf_name"),
                        rs.getString("benf_ifsc"),
                        rs.getString("benf_branch"),
                        rs.getString("benf_bank")
                    ));
                }
            }
        }
        return list;
    }
}