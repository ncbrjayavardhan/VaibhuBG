package com.vaibhutrans.dao;

import com.vaibhutrans.config.DBConnection;
import com.vaibhutrans.model.Transaction;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    public void saveTransactionsBatch(List<Transaction> list) throws SQLException {
        String sql = "MERGE INTO transactions t USING DUAL ON (t.utr_no = ?) " +
                     "WHEN MATCHED THEN UPDATE SET t.transaction_date=?, t.debit_account=?, t.benf_account=?, " +
                     "t.amount=?, t.payment_mode=?, t.status=?, t.narration=?, t.tallyledger=?, t.project=? " +
                     "WHEN NOT MATCHED THEN INSERT (utr_no, transaction_date, debit_account, benf_account, " +
                     "amount, payment_mode, status, narration, tallyledger, project) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            conn.setAutoCommit(false);
            for (Transaction tx : list) {
                // 1. ON Clause Parameter
                ps.setString(1, tx.getUtrNo());
                
                // UPDATE Bindings (2 - 10)
                ps.setDate(2, tx.getTransactionDate());
                ps.setString(3, tx.getDebitAccount());
                ps.setString(4, tx.getBenfAccount());
                ps.setDouble(5, tx.getAmount());
                ps.setString(6, tx.getPaymentMode());
                ps.setString(7, tx.getStatus());
                ps.setString(8, tx.getNarration());
                ps.setString(9, tx.getTallyledger());
                ps.setString(10, tx.getProject());

                // INSERT Bindings (11 - 20)
                ps.setString(11, tx.getUtrNo());
                ps.setDate(12, tx.getTransactionDate());
                ps.setString(13, tx.getDebitAccount());
                ps.setString(14, tx.getBenfAccount());
                ps.setDouble(15, tx.getAmount());
                ps.setString(16, tx.getPaymentMode());
                ps.setString(17, tx.getStatus());
                ps.setString(18, tx.getNarration());
                ps.setString(19, tx.getTallyledger());
                ps.setString(20, tx.getProject());

                ps.addBatch();
            }
            ps.executeBatch();
            conn.commit();
        }
    }

    public List<Transaction> getAllTransactionsWithBankDetails() throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = "SELECT t.*, b.benf_name, b.benf_ifsc, b.benf_branch, b.benf_bank " +
                     "FROM transactions t LEFT JOIN bank_details b ON t.benf_account = b.benf_account " +
                     "ORDER BY t.transaction_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Transaction tx = new Transaction(
                    rs.getString("utr_no"),
                    rs.getDate("transaction_date"),
                    rs.getString("debit_account"),
                    rs.getString("benf_account"),
                    rs.getDouble("amount"),
                    rs.getString("payment_mode"),
                    rs.getString("status"),
                    rs.getString("narration"),
                    rs.getString("tallyledger"),
                    rs.getString("project")
                );
                tx.setBenfName(rs.getString("benf_name"));
                tx.setBenfIfsc(rs.getString("benf_ifsc"));
                tx.setBenfBranch(rs.getString("benf_branch"));
                tx.setBenfBank(rs.getString("benf_bank"));
                list.add(tx);
            }
        }
        return list;
    }

    public Transaction getTransactionByUtr(String utrNo) throws SQLException {
        String sql = "SELECT t.*, b.benf_name, b.benf_ifsc, b.benf_branch, b.benf_bank " +
                     "FROM transactions t LEFT JOIN bank_details b ON t.benf_account = b.benf_account " +
                     "WHERE t.utr_no = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, utrNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Transaction tx = new Transaction(
                        rs.getString("utr_no"),
                        rs.getDate("transaction_date"),
                        rs.getString("debit_account"),
                        rs.getString("benf_account"),
                        rs.getDouble("amount"),
                        rs.getString("payment_mode"),
                        rs.getString("status"),
                        rs.getString("narration"),
                        rs.getString("tallyledger"),
                        rs.getString("project")
                    );
                    tx.setBenfName(rs.getString("benf_name"));
                    tx.setBenfIfsc(rs.getString("benf_ifsc"));
                    tx.setBenfBranch(rs.getString("benf_branch"));
                    tx.setBenfBank(rs.getString("benf_bank"));
                    return tx;
                }
            }
        }
        return null;
    }

    public boolean updateTransaction(Transaction tx) throws SQLException {
        String sql = "UPDATE transactions SET transaction_date=?, debit_account=?, benf_account=?, " +
                     "amount=?, payment_mode=?, status=?, narration=?, tallyledger=?, project=? WHERE utr_no=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, tx.getTransactionDate());
            ps.setString(2, tx.getDebitAccount());
            ps.setString(3, tx.getBenfAccount());
            ps.setDouble(4, tx.getAmount());
            ps.setString(5, tx.getPaymentMode());
            ps.setString(6, tx.getStatus());
            ps.setString(7, tx.getNarration());
            ps.setString(8, tx.getTallyledger());
            ps.setString(9, tx.getProject());
            ps.setString(10, tx.getUtrNo());

            return ps.executeUpdate() > 0;
        }
    }
}