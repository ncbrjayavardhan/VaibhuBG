package com.vaibhutrans.dao;

import com.vaibhutrans.config.DBConnection;
import com.vaibhutrans.model.BomTransaction;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;


public class BomTransactionDAO {

    public void saveBatch(List<BomTransaction> transactions) throws Exception {
        String sql = "INSERT INTO BOM_TRANSACTIONS " +
                "(TRANSACTION_DATE, TRANSACTION_TYPE, PARTICULARS, UTR_NO, REF_NO, " +
                "DEBIT_AMOUNT, CREDIT_AMOUNT, BALANCE, CHANNEL, BENEFICIARY_NAME, " +
                "IFSC_CODE, ACCOUNT_NO, BANK_NAME) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            conn.setAutoCommit(false);

            for (BomTransaction tx : transactions) {
                ps.setString(1, sanitize(tx.getTxDate(), 20, "N/A"));
                ps.setString(2, sanitize(tx.getType(), 50, "DEBIT"));
                ps.setString(3, sanitize(tx.getParticulars(), 1000, "N/A"));
                ps.setString(4, sanitize(tx.getUtrNo(), 100, "N/A"));
                ps.setString(5, sanitize(tx.getRefNo(), 100, "N/A"));
                ps.setDouble(6, tx.getDebit());
                ps.setDouble(7, tx.getCredit());
                ps.setDouble(8, tx.getBalance());
                ps.setString(9, sanitize(tx.getChannel(), 100, "EXCEL_UPLOAD"));
                ps.setString(10, sanitize(tx.getBeneficiaryName(), 255, "N/A"));
                ps.setString(11, sanitize(tx.getIfscCode(), 20, "N/A"));
                ps.setString(12, sanitize(tx.getAccountNo(), 30, "N/A"));
                ps.setString(13, sanitize(tx.getBankName(), 50, "BOM"));

                ps.addBatch();
            }

            ps.executeBatch();
            conn.commit();
        }
    }

    
//    public void saveOrMergeTransactions(List<BomTransaction> transactions) throws Exception {
//        // Oracle MERGE query mapped to your complete BOM_TRANSACTIONS schema
//        String mergeSql = "MERGE INTO UPPCLTEST.BOM_TRANSACTIONS target "
//                + "USING (SELECT ? AS ACCOUNT_NO, ? AS BANK_NAME, ? AS TRANSACTION_DATE, ? AS TRANSACTION_TYPE, "
//                + "              ? AS PARTICULARS, ? AS UTR_NO, ? AS REF_NO, ? AS DEBIT_AMOUNT, "
//                + "              ? AS CREDIT_AMOUNT, ? AS BALANCE, ? AS CHANNEL, ? AS BENEFICIARY_NAME, "
//                + "              ? AS IFSC_CODE FROM DUAL) src "
//                + "ON (NVL(target.ACCOUNT_NO, 'X') = NVL(src.ACCOUNT_NO, 'X') "
//                + "    AND target.TRANSACTION_DATE = src.TRANSACTION_DATE "
//                + "    AND NVL(target.REF_NO, 'X') = NVL(src.REF_NO, 'X') "
//                + "    AND NVL(target.UTR_NO, 'X') = NVL(src.UTR_NO, 'X') "
//                + "    AND target.DEBIT_AMOUNT = src.DEBIT_AMOUNT "
//                + "    AND target.CREDIT_AMOUNT = src.CREDIT_AMOUNT) "
//                + "WHEN MATCHED THEN "
//                + "  UPDATE SET target.PARTICULARS = src.PARTICULARS, "
//                + "             target.BALANCE = src.BALANCE, "
//                + "             target.CHANNEL = src.CHANNEL, "
//                + "             target.BENEFICIARY_NAME = src.BENEFICIARY_NAME, "
//                + "             target.IFSC_CODE = src.IFSC_CODE, "
//                + "             target.BANK_NAME = src.BANK_NAME "
//                + "WHEN NOT MATCHED THEN "
//                + "  INSERT (ACCOUNT_NO, BANK_NAME, TRANSACTION_DATE, TRANSACTION_TYPE, PARTICULARS, "
//                + "          UTR_NO, REF_NO, DEBIT_AMOUNT, CREDIT_AMOUNT, BALANCE, CHANNEL, BENEFICIARY_NAME, IFSC_CODE) "
//                + "  VALUES (src.ACCOUNT_NO, src.BANK_NAME, src.TRANSACTION_DATE, src.TRANSACTION_TYPE, src.PARTICULARS, "
//                + "          src.UTR_NO, src.REF_NO, src.DEBIT_AMOUNT, src.CREDIT_AMOUNT, src.BALANCE, src.CHANNEL, src.BENEFICIARY_NAME, src.IFSC_CODE)";
//
//        try (Connection conn = DBConnection.getConnection();
//             PreparedStatement ps = conn.prepareStatement(mergeSql)) {
//
//            conn.setAutoCommit(false);
//
//            for (BomTransaction tx : transactions) {
//                ps.setString(1, tx.getAccountNo());        // ACCOUNT_NO
//                ps.setString(2, tx.getBankName());         // BANK_NAME
//                ps.setString(3, tx.getTxDate());          // TRANSACTION_DATE
//                ps.setString(4, tx.getType());            // TRANSACTION_TYPE
//                ps.setString(5, tx.getParticulars());     // PARTICULARS
//                ps.setString(6, tx.getUtrNo());           // UTR_NO
//                ps.setString(7, tx.getRefNo());           // REF_NO
//                ps.setDouble(8, tx.getDebit());           // DEBIT_AMOUNT
//                ps.setDouble(9, tx.getCredit());          // CREDIT_AMOUNT
//                ps.setDouble(10, tx.getBalance());        // BALANCE
//                ps.setString(11, tx.getChannel());        // CHANNEL
//                ps.setString(12, tx.getBeneficiaryName());// BENEFICIARY_NAME
//                ps.setString(13, tx.getIfscCode());       // IFSC_CODE
//
//                ps.addBatch();
//            }
//
//            ps.executeBatch();
//            conn.commit();
//        }
//    }
    
    public void saveOrMergeTransactions(List<BomTransaction> transactions) throws Exception {
        String mergeSql = "MERGE INTO UPPCLTEST.BOM_TRANSACTIONS target "
                + "USING (SELECT ? AS ACCOUNT_NO, ? AS BANK_NAME, ? AS TRANSACTION_DATE, ? AS TRANSACTION_TYPE, "
                + "              ? AS PARTICULARS, ? AS UTR_NO, ? AS REF_NO, ? AS DEBIT_AMOUNT, "
                + "              ? AS CREDIT_AMOUNT, ? AS BALANCE, ? AS CHANNEL, ? AS BENEFICIARY_NAME, "
                + "              ? AS IFSC_CODE FROM DUAL) src "
                + "ON (NVL(target.ACCOUNT_NO, 'X') = NVL(src.ACCOUNT_NO, 'X') "
                + "    AND target.TRANSACTION_DATE = src.TRANSACTION_DATE "
                + "    AND NVL(target.REF_NO, 'X') = NVL(src.REF_NO, 'X') "
                + "    AND NVL(target.UTR_NO, 'X') = NVL(src.UTR_NO, 'X') "
                + "    AND target.DEBIT_AMOUNT = src.DEBIT_AMOUNT "
                + "    AND target.CREDIT_AMOUNT = src.CREDIT_AMOUNT) "
                + "WHEN MATCHED THEN "
                + "  UPDATE SET target.PARTICULARS = src.PARTICULARS, "
                + "             target.BALANCE = src.BALANCE, "
                + "             target.CHANNEL = src.CHANNEL, "
                + "             target.BENEFICIARY_NAME = src.BENEFICIARY_NAME, "
                + "             target.IFSC_CODE = src.IFSC_CODE, "
                + "             target.BANK_NAME = src.BANK_NAME "
                + "WHEN NOT MATCHED THEN "
                + "  INSERT (ACCOUNT_NO, BANK_NAME, TRANSACTION_DATE, TRANSACTION_TYPE, PARTICULARS, "
                + "          UTR_NO, REF_NO, DEBIT_AMOUNT, CREDIT_AMOUNT, BALANCE, CHANNEL, BENEFICIARY_NAME, IFSC_CODE) "
                + "  VALUES (src.ACCOUNT_NO, src.BANK_NAME, src.TRANSACTION_DATE, src.TRANSACTION_TYPE, src.PARTICULARS, "
                + "          src.UTR_NO, src.REF_NO, src.DEBIT_AMOUNT, src.CREDIT_AMOUNT, src.BALANCE, src.CHANNEL, src.BENEFICIARY_NAME, src.IFSC_CODE)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(mergeSql)) {

            conn.setAutoCommit(false);

            for (BomTransaction tx : transactions) {
                ps.setString(1, sanitize(tx.getAccountNo(), 30, "N/A"));
                
                // AUTOMATED BANK NAME HANDLING:
                // Since tx.getBankName() is set to "SBI" by SbiStatementParser 
                // and "BOM" by BomStatementParser, it will dynamically insert whichever bank parsed the file.
                ps.setString(2, sanitize(tx.getBankName(), 50, "BOM")); // Fallback to BOM only if bankName is completely missing
                
                ps.setString(3, sanitize(tx.getTxDate(), 20, "N/A"));
                ps.setString(4, sanitize(tx.getType(), 50, "DEBIT"));
                ps.setString(5, sanitize(tx.getParticulars(), 1000, "N/A"));
                ps.setString(6, sanitize(tx.getUtrNo(), 100, "N/A"));
                ps.setString(7, sanitize(tx.getRefNo(), 100, "N/A"));
                ps.setDouble(8, tx.getDebit());
                ps.setDouble(9, tx.getCredit());
                ps.setDouble(10, tx.getBalance());
                ps.setString(11, sanitize(tx.getChannel(), 100, "ONLINE"));
                ps.setString(12, sanitize(tx.getBeneficiaryName(), 255, "N/A"));
                ps.setString(13, sanitize(tx.getIfscCode(), 20, "N/A"));

                ps.addBatch();
            }

            ps.executeBatch();
            conn.commit();
        }
    }
    
//    public List<BomTransaction> getAllTransactions() throws Exception {
//        List<BomTransaction> list = new ArrayList<>();
//        String sql = "SELECT * FROM BOM_TRANSACTIONS ORDER BY Transaction_date asC";
//
//        try (Connection conn = DBConnection.getConnection();
//             PreparedStatement ps = conn.prepareStatement(sql);
//             ResultSet rs = ps.executeQuery()) {
//
//            while (rs.next()) {
//                BomTransaction tx = new BomTransaction();
//                tx.setTxDate(rs.getString("TRANSACTION_DATE"));
//                tx.setType(rs.getString("TRANSACTION_TYPE"));
//                tx.setParticulars(rs.getString("PARTICULARS"));
//                tx.setUtrNo(rs.getString("UTR_NO"));
//                tx.setRefNo(rs.getString("REF_NO"));
//                tx.setDebit(rs.getDouble("DEBIT_AMOUNT"));
//                tx.setCredit(rs.getDouble("CREDIT_AMOUNT"));
//                tx.setBalance(rs.getDouble("BALANCE"));
//                tx.setChannel(rs.getString("CHANNEL"));
//                tx.setBeneficiaryName(rs.getString("BENEFICIARY_NAME"));
//                tx.setIfscCode(rs.getString("IFSC_CODE"));
//                tx.setAccountNo(rs.getString("ACCOUNT_NO"));
//                tx.setBankName(rs.getString("BANK_NAME"));
//
//                list.add(tx);
//            }
//        }
//        return list;
//    }
//
//    public List<String> getUniqueAccountNumbers() throws Exception {
//        List<String> accountList = new ArrayList<>();
//        String sql = "SELECT DISTINCT ACCOUNT_NO FROM BOM_TRANSACTIONS WHERE ACCOUNT_NO IS NOT NULL AND ACCOUNT_NO != ''";
//
//        try (Connection conn = DBConnection.getConnection();
//             PreparedStatement ps = conn.prepareStatement(sql);
//             ResultSet rs = ps.executeQuery()) {
//
//            while (rs.next()) {
//                accountList.add(rs.getString("ACCOUNT_NO"));
//            }
//        }
//        return accountList;
//    }
    
    public List<BomTransaction> getAllTransactions() throws Exception {
        List<BomTransaction> list = new ArrayList<>();
        
        String sql = "SELECT "
                   + "  B.TRANSACTION_DATE, "
                   + "  B.TRANSACTION_TYPE, "
                   + "  B.PARTICULARS, "
                   + "  B.REF_NO, "
                   + "  B.DEBIT_AMOUNT, "
                   + "  B.CREDIT_AMOUNT, "
                   + "  B.BALANCE, "
                   + "  B.CHANNEL, "
                   + "  B.CREATED_AT, "
                   + "  B.BENEFICIARY_NAME, "
                   + "  B.IFSC_CODE, "
                   + "  B.BANK_NAME, "
                   + "  B.ACCOUNT_NO, "
                   + "  B.UTR_NO, "
                   + "  T.TALLYLEDGER,"
                   + "  T.NARRATION "
                   + "FROM BOM_TRANSACTIONS B "
                   + "LEFT JOIN TRANSACTIONS T ON TRIM(B.UTR_NO) = TRIM(T.UTR_NO) "
                   + "ORDER BY B.transaction_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                BomTransaction tx = new BomTransaction();
                tx.setTxDate(rs.getString("TRANSACTION_DATE"));
                tx.setType(rs.getString("TRANSACTION_TYPE"));
                tx.setParticulars(rs.getString("PARTICULARS"));
                tx.setRefNo(rs.getString("REF_NO"));
                tx.setDebit(rs.getDouble("DEBIT_AMOUNT"));
                tx.setCredit(rs.getDouble("CREDIT_AMOUNT"));
                tx.setBalance(rs.getDouble("BALANCE"));
                tx.setChannel(rs.getString("CHANNEL"));
                tx.setBeneficiaryName(rs.getString("BENEFICIARY_NAME"));
                tx.setIfscCode(rs.getString("IFSC_CODE"));
                tx.setBankName(rs.getString("BANK_NAME"));
                tx.setAccountNo(rs.getString("ACCOUNT_NO"));
                tx.setUtrNo(rs.getString("UTR_NO"));
                tx.setTallyLedger(rs.getString("TALLYLEDGER"));
                tx.setNarration(rs.getString("NARRATION"));

                list.add(tx);
            }
        }
        return list;
    }

    public List<String> getUniqueAccountNumbers() throws Exception {
        List<String> accountList = new ArrayList<>();
        String sql = "SELECT DISTINCT ACCOUNT_NO FROM BOM_TRANSACTIONS WHERE ACCOUNT_NO IS NOT NULL AND ACCOUNT_NO != ''";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                accountList.add(rs.getString("ACCOUNT_NO"));
            }
        }
        return accountList;
    }

    private String sanitize(String val, int maxLen, String defaultVal) {
        if (val == null || val.trim().isEmpty()) {
            return defaultVal;
        }
        String trimmed = val.trim();
        return trimmed.length() > maxLen ? trimmed.substring(0, maxLen) : trimmed;
    }
    
    public List<String> getTallyLedgerHeads() throws Exception {
        List<String> list = new ArrayList<>();
        String sql = "SELECT TALLY_HEAD FROM TALLYLEGDER_HEADS WHERE TALLY_HEAD IS NOT NULL ORDER BY ID ASC";
        //TALLYLEGDER_HEADS
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String head = rs.getString("TALLY_HEAD");
                if (head != null && !head.trim().isEmpty()) {
                    list.add(head.trim());
                }
            }
        }
        return list;
    }
    
//    public Map<String, String[]> getTransactionTallyLedgerMap() {
//        Map<String, String[]> map = new HashMap<>();
//        String sql = "SELECT UTR_NO, TALLYLEDGER, BENF_NAME FROM TRANSACTIONS WHERE UTR_NO IS NOT NULL AND UTR_NO != ''";
//        
//        try (Connection con = DBConnection.getConnection();
//             PreparedStatement ps = con.prepareStatement(sql);
//             ResultSet rs = ps.executeQuery()) {
//            
//            while (rs.next()) {
//                String utr = rs.getString("UTR_NO");
//                String tallyLedger = rs.getString("TALLYLEDGER");
//                String benfName = rs.getString("BENF_NAME");
//                
//                if (utr != null && !utr.trim().isEmpty()) {
//                    // map.put(utr, new String[]{ tallyLedger, benfName });
//                    map.put(utr.trim(), new String[]{
//                        tallyLedger != null ? tallyLedger.trim() : "",
//                        benfName != null ? benfName.trim() : ""
//                    });
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return map;
//    }
}