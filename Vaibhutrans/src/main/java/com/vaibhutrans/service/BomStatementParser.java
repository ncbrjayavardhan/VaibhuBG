package com.vaibhutrans.service;

import com.vaibhutrans.model.BomTransaction;
import org.apache.poi.ss.usermodel.*;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class BomStatementParser {

    private static final Pattern NEFT_RTGS_PATTERN = Pattern.compile(
            "(?i)(?:NEFT|RTGS)?\\s*([A-Z]{4}[A-Z0-9]{11,18})\\s+(.*?)\\s+([A-Z]{4}0[A-Z0-9]{6})"
    );

    private static final Pattern IMPS_PATTERN = Pattern.compile(
            "(?i)IMPS/\\d+/(\\d{12})/(?:\\*\\*\\d+/)?([^/]+)"
    );

    private static final Pattern GENERIC_UTR_PATTERN = Pattern.compile(
            "(?i)\\b([A-Z]{4}[A-Z0-9]{11,18}|\\d{12,22})\\b"
    );

    private static final Pattern IFSC_PATTERN = Pattern.compile("(?i)[A-Z]{4}0[A-Z0-9]{6}");

    public static List<BomTransaction> parseBomStatement(InputStream excelInputStream) throws Exception {
        List<BomTransaction> transactions = new ArrayList<>();
        DataFormatter formatter = new DataFormatter();

        try {
            Workbook workbook = WorkbookFactory.create(excelInputStream);
            Sheet sheet = workbook.getSheetAt(0);

            String accountNo = "60043560238";
            
            // Look for account number in header metadata (Rows 0 to 25)
            for (int r = 0; r < Math.min(25, sheet.getLastRowNum()); r++) {
                Row row = sheet.getRow(r);
                if (row == null) continue;
                String cellVal = getCellValueAsString(row.getCell(0), formatter).trim();
                if (cellVal.toUpperCase().contains("STATEMENT FOR ACCOUNT NO") || cellVal.toUpperCase().contains("ACCOUNT NO")) {
                    Matcher numMatcher = Pattern.compile("\\d{9,18}").matcher(cellVal);
                    if (numMatcher.find()) {
                        accountNo = numMatcher.group(0);
                        break;
                    }
                }
            }

            // Default header row index is 25 (Line 26 in Excel)
            int headerRowIndex = 25; 
            Row headerRow = sheet.getRow(headerRowIndex);
            if (headerRow != null) {
                String headerCol0 = getCellValueAsString(headerRow.getCell(0), formatter).trim();
                if (!headerCol0.equalsIgnoreCase("Date") && !headerCol0.equalsIgnoreCase("Txn Date")) {
                    for (int r = 0; r <= sheet.getLastRowNum(); r++) {
                        Row current = sheet.getRow(r);
                        if (current != null) {
                            String val = getCellValueAsString(current.getCell(0), formatter).trim();
                            if (val.equalsIgnoreCase("Date") || val.equalsIgnoreCase("Txn Date")) {
                                headerRowIndex = r;
                                break;
                            }
                        }
                    }
                }
            }

            // Data rows start directly at headerRowIndex + 1 (Index 26 = Line 27)
            for (int i = headerRowIndex + 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                String firstCellVal = getCellValueAsString(row.getCell(0), formatter).trim();

                // Stop execution when footer summary is encountered
                if (firstCellVal.toUpperCase().contains("ALL THE AMOUNTS IN THE STATEMENT ARE IN INR") 
                        || firstCellVal.toUpperCase().contains("SUMMARY FOR ACCOUNT NO")) {
                    break;
                }

                String particulars = getCellValueAsString(row.getCell(2), formatter).trim();

                // Skip completely blank separator rows
                if (firstCellVal.isEmpty() && particulars.isEmpty()) {
                    continue;
                }

                if (firstCellVal.contains(" ")) {
                    firstCellVal = firstCellVal.split(" ")[0].trim();
                }

                String refNo = getCellValueAsString(row.getCell(3), formatter).trim();
                if (refNo.isEmpty()) {
                    refNo = "N/A";
                }

                double debit = parseDouble(getCellValueAsString(row.getCell(4), formatter));
                double credit = parseDouble(getCellValueAsString(row.getCell(5), formatter));
                double balance = parseDouble(getCellValueAsString(row.getCell(6), formatter));

                BomTransaction tx = new BomTransaction();
                tx.setBankName("BOM");
                tx.setAccountNo(accountNo);
                tx.setTxDate(firstCellVal);
                tx.setType(getCellValueAsString(row.getCell(1), formatter).trim());
                tx.setParticulars(particulars);
                tx.setRefNo(refNo);
                tx.setDebit(debit);
                tx.setCredit(credit);
                tx.setBalance(balance);

                String channel = row.getLastCellNum() > 7 ? getCellValueAsString(row.getCell(7), formatter).trim() : "";
                tx.setChannel(channel.isEmpty() ? "EXCEL_UPLOAD" : channel);

                parseParticularsDetails(particulars, tx, i);

                transactions.add(tx);
            }
        } finally {
            if (excelInputStream != null) {
                try {
                    excelInputStream.close();
                } catch (Exception ignored) {}
            }
        }

        return transactions;
    }

    private static void parseParticularsDetails(String particulars, BomTransaction tx, int rowIndex) {
        if (particulars == null || particulars.trim().isEmpty()) {
            tx.setUtrNo(!tx.getRefNo().equals("N/A") ? tx.getRefNo() : "BOM_" + rowIndex);
            tx.setBeneficiaryName("N/A");
            tx.setIfscCode("N/A");
            return;
        }

        String cleanStr = particulars.replace("\r", " ").replace("\n", " ").replaceAll("\\s+", " ").trim();

        Matcher neftRtgsMatcher = NEFT_RTGS_PATTERN.matcher(cleanStr);
        if (neftRtgsMatcher.find()) {
            tx.setUtrNo(neftRtgsMatcher.group(1).trim());
            tx.setBeneficiaryName(neftRtgsMatcher.group(2).trim());
            tx.setIfscCode(neftRtgsMatcher.group(3).trim());
            return;
        }

        Matcher impsMatcher = IMPS_PATTERN.matcher(cleanStr);
        if (impsMatcher.find()) {
            tx.setUtrNo(impsMatcher.group(1).trim());
            tx.setBeneficiaryName(impsMatcher.group(2).trim());
            tx.setIfscCode("N/A");
            return;
        }

        tx.setBeneficiaryName(extractTransferBeneficiary(cleanStr));

        Matcher ifscMatcher = IFSC_PATTERN.matcher(cleanStr);
        if (ifscMatcher.find()) {
            tx.setIfscCode(ifscMatcher.group(0).trim());
        } else {
            tx.setIfscCode("N/A");
        }

        Matcher genericUtrMatcher = GENERIC_UTR_PATTERN.matcher(cleanStr);
        if (genericUtrMatcher.find()) {
            tx.setUtrNo(genericUtrMatcher.group(1).trim());
        } else if (tx.getRefNo() != null && !tx.getRefNo().trim().isEmpty() && !tx.getRefNo().equals("N/A")) {
            tx.setUtrNo(tx.getRefNo().trim());
        } else {
            tx.setUtrNo("BOM_" + rowIndex);
        }
    }

    private static String extractTransferBeneficiary(String cleanStr) {
        int lastToIdx = cleanStr.lastIndexOf(" TO ");
        if (lastToIdx != -1) {
            String candidate = cleanStr.substring(lastToIdx + 4).trim();
            if (!candidate.isEmpty() && !candidate.matches("^\\d+$") && !candidate.startsWith("TRANSFER")) {
                return candidate;
            }
        }

        int frmIdx = cleanStr.indexOf("FRM ");
        if (frmIdx != -1) {
            String candidate = cleanStr.substring(frmIdx + 4).trim();
            if (!candidate.isEmpty()) {
                return candidate;
            }
        }

        return "N/A";
    }

    private static String getCellValueAsString(Cell cell, DataFormatter formatter) {
        if (cell == null) return "";
        String val = formatter.formatCellValue(cell).trim();
        return val.replace("\u00a0", " ").trim();
    }

    private static double parseDouble(String val) {
        if (val == null || val.trim().isEmpty()) return 0.0;
        try {
            String clean = val.replaceAll("[^0-9.-]", "");
            return clean.isEmpty() ? 0.0 : Double.parseDouble(clean);
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
}