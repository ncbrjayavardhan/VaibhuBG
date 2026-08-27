package com.vaibhutrans.service;

import com.vaibhutrans.model.BomTransaction;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.regex.*;

public class SbiStatementParser {

    public static List<BomTransaction> parse(InputStream inputStream) throws IOException {
        List<BomTransaction> transactions = new ArrayList<>();

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            String accountNo = "";
            String ifscCode = "";
            boolean isHeaderFound = false;

            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty()) continue;

                // 1. Extract metadata from top header block
                if (line.contains("Account Number")) {
                    accountNo = extractHeaderValue(line).replaceAll("^_+", "");
                } else if (line.contains("IFS Code")) {
                    ifscCode = extractHeaderValue(line);
                } 
                // 2. Identify transaction table start
                else if (line.contains("Txn Date") && line.contains("Description")) {
                    isHeaderFound = true;
                    continue; // Skip column header row
                }

                // 3. Process records
                if (isHeaderFound) {
                    String[] cols = line.split("\t");
                    if (cols.length >= 8) {
                        BomTransaction tx = new BomTransaction();
                        tx.setAccountNo(accountNo);
                        tx.setBankName("SBI");
                        tx.setIfscCode(ifscCode);

                        String txDate = cols[0].trim();
                        String description = cols[2].trim();
                        String refNo = cols[3].trim();
                        double debit = parseAmount(cols[5]);
                        double credit = parseAmount(cols[6]);
                        double balance = parseAmount(cols[7]);

                        tx.setTxDate(txDate);
                        tx.setParticulars(description);
                        tx.setRefNo(refNo);
                        tx.setDebit(debit);
                        tx.setCredit(credit);
                        tx.setBalance(balance);
                        tx.setType(debit > 0 ? "DEBIT" : "CREDIT");

                        tx.setChannel(extractChannel(description));
                        tx.setUtrNo(extractUtr(description, refNo));
                        tx.setBeneficiaryName(extractBeneficiary(description, refNo));

                        transactions.add(tx);
                    }
                }
            }
        }
        return transactions;
    }

    private static String extractHeaderValue(String line) {
        String[] parts = line.split(":");
        return parts.length > 1 ? parts[1].trim() : "";
    }

    private static double parseAmount(String val) {
        if (val == null || val.trim().isEmpty()) return 0.0;
        try {
            return Double.parseDouble(val.trim().replace(",", ""));
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }

    private static String extractChannel(String desc) {
        String upperDesc = desc.toUpperCase();
        if (upperDesc.contains("CMPNEFT") || upperDesc.contains("NEFT")) return "NEFT";
        if (upperDesc.contains("RTGS")) return "RTGS";
        if (upperDesc.contains("UPI")) return "UPI";
        if (upperDesc.contains("ACH") || upperDesc.contains("NACH")) return "ACH";
        if (upperDesc.contains("CLEARING")) return "CLEARING";
        if (upperDesc.contains("INB")) return "INB";
        if (upperDesc.contains("CHEQUE") || upperDesc.contains("CASH")) return "CASH/CHEQUE";
        return "ONLINE";
    }

    private static String extractUtr(String desc, String ref) {
        // Pattern 1: UTR NO: <UTR>
        Matcher m = Pattern.compile("UTR NO:\\s*([A-Z0-9]+)", Pattern.CASE_INSENSITIVE).matcher(desc);
        if (m.find()) return m.group(1);

        // Pattern 2: NEFT*IFSC*UTR*...
        m = Pattern.compile("NEFT\\*[A-Z0-9]+\\*([A-Z0-9]+)", Pattern.CASE_INSENSITIVE).matcher(desc);
        if (m.find()) return m.group(1);

        // Pattern 3: UPI/<CR|DR>/<UTR>/...
        m = Pattern.compile("UPI/(?:CR|DR)/([0-9]{12})", Pattern.CASE_INSENSITIVE).matcher(desc);
        if (m.find()) return m.group(1);

        // Pattern 4: CMPNEFT/<REF>/...
        m = Pattern.compile("CMPNEFT/([A-Z0-9]+)", Pattern.CASE_INSENSITIVE).matcher(desc);
        if (m.find()) return m.group(1);

        // Fallback to INB reference prefixes or ref number
        if (ref.startsWith("CT0") || ref.startsWith("CR0") || ref.startsWith("CNA")) {
            return ref.split("\\s+")[0];
        }
        return ref.replace("/", "").trim();
    }

    private static String extractBeneficiary(String desc, String ref) {
        // 1. UPI descriptions: UPI/CR/1234567890/NAME/...
        if (desc.toUpperCase().contains("UPI/")) {
            String[] parts = desc.split("/");
            if (parts.length >= 4 && !parts[3].trim().isEmpty()) {
                return parts[3].trim();
            }
        }

        // 2. CMPNEFT / CMPRTGS descriptions: CMPNEFT/SBIF400015822001/NAME--
        if (desc.toUpperCase().contains("CMPNEFT/") || desc.toUpperCase().contains("CMPRTGS/")) {
            String[] parts = desc.split("/");
            if (parts.length >= 3) {
                String name = parts[2].replace("--", "").trim();
                if (!name.isEmpty()) return name;
            }
        }

        // 3. NEFT standard formatted pattern: NEFT*IFSC*UTR*BENEFICIARY*
        if (desc.toUpperCase().contains("NEFT*")) {
            String[] parts = desc.split("\\*");
            if (parts.length >= 4) {
                String ben = parts[3].replace("--", "").trim();
                if (!ben.isEmpty()) return ben;
            }
        }

        // 4. ACH / NACH pattern: ACHDr NACH00000000002900 INDUSINDBUSINE--
        if (desc.toUpperCase().contains("NACH")) {
            Matcher m = Pattern.compile("NACH\\d+\\s+(.+)").matcher(desc.replace("--", ""));
            if (m.find()) {
                return m.group(1).trim();
            }
        }

        // 5. Check description after '--' if present and not a numeric cheque/ref number
        if (desc.contains("--")) {
            String[] parts = desc.split("--");
            if (parts.length > 1) {
                String ben = parts[1].trim();
                if (!ben.isEmpty() && !ben.matches("\\d+")) {
                    return ben;
                }
            }
        }

        // 6. Check ref column for 'TRANSFER TO' or 'TRANSFER FROM'
        for (String key : new String[]{"TRANSFER TO", "TRANSFER FROM"}) {
            if (ref.toUpperCase().contains(key)) {
                String[] parts = ref.split("(?i)" + key);
                if (parts.length > 1) {
                    String ben = parts[1].replaceAll("^[0-9\\s]+", "").replace("/", "").trim();
                    if (!ben.isEmpty()) return ben;
                }
            }
        }

        return "";
    }
}