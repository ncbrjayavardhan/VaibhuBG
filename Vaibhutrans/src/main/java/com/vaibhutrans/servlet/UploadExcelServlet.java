package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.BankDetailDAO;
import com.vaibhutrans.dao.TransactionDAO;
import com.vaibhutrans.model.BankDetail;
import com.vaibhutrans.model.Transaction;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.InputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/uploadExcel")
@MultipartConfig
public class UploadExcelServlet extends HttpServlet {
    private BankDetailDAO bankDAO = new BankDetailDAO();
    private TransactionDAO txDAO = new TransactionDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Part filePart = request.getPart("excelFile");
        Map<String, BankDetail> bankMap = new HashMap<>();
        List<Transaction> transactions = new ArrayList<>();
        List<Integer> skippedRows = new ArrayList<>(); // track rows skipped due to missing/invalid date
        List<String> skippedInfo = new ArrayList<>(); // detailed reason/info for skipped rows (debug)

        InputStream inputStream = null;
        Workbook workbook = null;
        try {
            inputStream = filePart.getInputStream();
            // Use WorkbookFactory to create a Workbook that is compatible with multiple POI versions
            // (avoids relying on XSSFWorkbook(InputStream) constructor which may be absent in older jars)
            workbook = WorkbookFactory.create(inputStream);

            Sheet sheet = workbook.getSheetAt(0);
            DataFormatter formatter = new DataFormatter();
            // Accept multiple possible date string formats found in Excel files
            final String[] datePatterns = new String[]{"yyyy-MM-dd", "dd/MM/yyyy", "dd-MM-yyyy", "dd/MM/yy", "d/M/yyyy", "MM/dd/yyyy"};

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                // Col 0: TRANSACTION DATE
                Cell dateCell = row.getCell(0);
                java.sql.Date txDate = null;
                if (dateCell != null) {
                    try {
                        // Only call getDateCellValue when the cell is numeric (dates are stored as numeric in Excel)
                        // This avoids IllegalStateException: "Cannot get a numeric value from a text cell"
                        int cellType = dateCell.getCellType();
                        if (cellType == Cell.CELL_TYPE_NUMERIC) {
                            if (DateUtil.isCellDateFormatted(dateCell)) {
                                txDate = new java.sql.Date(dateCell.getDateCellValue().getTime());
                            } else {
                                // Numeric cell but no date format string: likely an Excel serial date
                                // (e.g. 46237.0). Convert using POI's DateUtil.getJavaDate.
                                try {
                                    double numeric = dateCell.getNumericCellValue();
                                    java.util.Date d = DateUtil.getJavaDate(numeric);
                                    txDate = new java.sql.Date(d.getTime());
                                } catch (Exception ex) {
                                    // Fallback: treat as text and try parsing known patterns
                                    String strDate = formatter.formatCellValue(dateCell);
                                    if (strDate != null && !strDate.trim().isEmpty()) {
                                        txDate = tryParseDateString(strDate.trim(), datePatterns);
                                    }
                                }
                            }
                        } else {
                            // Fallback: treat cell as text and try multiple date formats
                            String strDate = formatter.formatCellValue(dateCell);
                            if (strDate != null && !strDate.trim().isEmpty()) {
                                txDate = tryParseDateString(strDate.trim(), datePatterns);
                            }
                        }
                    } catch (IllegalStateException ise) {
                        // In case POI throws an IllegalStateException when trying to read date as numeric,
                        // fall back to reading string value and parsing with multiple formats.
                        String strDate = formatter.formatCellValue(dateCell);
                        if (strDate != null && !strDate.trim().isEmpty()) {
                            txDate = tryParseDateString(strDate.trim(), datePatterns);
                        }
                    }
                }

                // Col 1 to 11 extraction
//                String debitAcc = formatter.formatCellValue(row.getCell(1));
//                String benfAcc = formatter.formatCellValue(row.getCell(2));
//                String benfName = formatter.formatCellValue(row.getCell(3));
                
                String debitAcc = getCellValueAsString(row.getCell(1), formatter);
                String benfAcc  = getCellValueAsString(row.getCell(2), formatter);
                String benfName = formatter.formatCellValue(row.getCell(3)).trim();
                
                String strAmount = formatter.formatCellValue(row.getCell(4)).replaceAll(",", "").trim();
                double amount = 0.0;
                if (!strAmount.isEmpty()) {
                    try {
                        amount = Double.parseDouble(strAmount);
                    } catch (NumberFormatException nfe) {
                        // fallback: remove any non-digit (except dot and minus) and try again
                        String cleaned = strAmount.replaceAll("[^0-9.-]", "");
                        if (!cleaned.isEmpty()) {
                            try {
                                amount = Double.parseDouble(cleaned);
                            } catch (NumberFormatException nfe2) {
                                amount = 0.0;
                            }
                        }
                    }
                }

                String benfIfsc = formatter.formatCellValue(row.getCell(5));
                String benfBranch = formatter.formatCellValue(row.getCell(6));
                String benfBank = formatter.formatCellValue(row.getCell(7));
                String utrNo = formatter.formatCellValue(row.getCell(8));
                String paymentMode = formatter.formatCellValue(row.getCell(9));
                String status = formatter.formatCellValue(row.getCell(10));
//                String remark = formatter.formatCellValue(row.getCell(11));
                String narration = formatter.formatCellValue(row.getCell(11));
                String tallyledger = formatter.formatCellValue(row.getCell(12));
                String project = formatter.formatCellValue(row.getCell(13));

                if (utrNo == null || utrNo.trim().isEmpty()) continue;

                // Collect bank details if present
                if (!benfAcc.isEmpty() && !bankMap.containsKey(benfAcc)) {
                    BankDetail bd = new BankDetail(benfAcc, benfName, benfIfsc, benfBranch, benfBank);
                    bankMap.put(benfAcc, bd);
                }

                // If transaction date is required by the DB (NOT NULL), skip rows with missing date
                if (txDate == null) {
                    skippedRows.add(i + 1); // use 1-based Excel row number for easier debugging
                    // collect debug info: cell type, formatted text, and cell style format if available
                    try {
                        String cellTypeStr = (dateCell == null) ? "NULL" : String.valueOf(dateCell.getCellType());
                        String formatted = (dateCell == null) ? "" : formatter.formatCellValue(dateCell);
                        String fmt = "";
                        if (dateCell != null && dateCell.getCellStyle() != null) {
                            try {
                                fmt = dateCell.getCellStyle().getDataFormatString();
                            } catch (Exception ignored) {
                                fmt = "(unknown)";
                            }
                        }
                        skippedInfo.add("row=" + (i + 1) + " type=" + cellTypeStr + " formatted='" + formatted + "' style='" + fmt + "'");
                    } catch (Exception ex) {
                        skippedInfo.add("row=" + (i + 1) + " (failed to collect debug info: " + ex.getMessage() + ")");
                    }
                    continue;
                }

                Transaction tx = new Transaction(utrNo, txDate, debitAcc, benfAcc, amount, paymentMode, status, narration, tallyledger, project);
                transactions.add(tx);
            }

            // Save details to database
            bankDAO.saveOrUpdateBankDetails(new ArrayList<>(bankMap.values()));
            txDAO.saveTransactionsBatch(transactions);

            StringBuilder msg = new StringBuilder();
            msg.append("Success! Uploaded ").append(transactions.size()).append(" records successfully.");
            if (!skippedRows.isEmpty()) {
                msg.append(" Skipped ").append(skippedRows.size()).append(" rows with missing/invalid date: ");
                msg.append(skippedRows.toString());
                // include debug info for first few skipped rows
                int limit = Math.min(skippedInfo.size(), 10);
                if (limit > 0) {
                    msg.append(". Examples: ");
                    for (int k = 0; k < limit; k++) {
                        if (k > 0) msg.append("; ");
                        msg.append(skippedInfo.get(k));
                    }
                    if (skippedInfo.size() > limit) msg.append("; ...");
                }
            }
            request.setAttribute("message", msg.toString());

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to upload file: " + e.getMessage());
        } finally {
            // explicitly close workbook and input stream because older POI jars here may not
            // implement AutoCloseable for Workbook or provide the same constructor signatures
            // Try to close workbook if possible. Some older POI versions don't expose a close()
            // method on the Workbook interface, so use reflection to call it when present.
            if (workbook != null) {
                try {
                    java.lang.reflect.Method closeMethod = workbook.getClass().getMethod("close");
                    if (closeMethod != null) {
                        closeMethod.invoke(workbook);
                    }
                } catch (NoSuchMethodException nsme) {
                    // close() not available on this POI version; ignore
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            try {
                if (inputStream != null) {
                    inputStream.close();
                }
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }
        }

        request.getRequestDispatcher("upload.jsp").forward(request, response);
    }

    // Try parsing a date string using multiple possible patterns. Returns null if none match.
    private java.sql.Date tryParseDateString(String str, String[] patterns) {
        if (str == null) return null;
        for (String p : patterns) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat(p);
                sdf.setLenient(false);
                java.util.Date d = sdf.parse(str);
                return new java.sql.Date(d.getTime());
            } catch (java.text.ParseException pe) {
                // try next pattern
            }
        }
        return null;
    }
    
    private String getCellValueAsString(Cell cell, DataFormatter formatter) {
        if (cell == null) {
            return "";
        }
        if (cell.getCellType() == Cell.CELL_TYPE_NUMERIC && !DateUtil.isCellDateFormatted(cell)) {
            // Prevent scientific notation (e.g. 6.0043560238E10 -> 60043560238)
            double doubleVal = cell.getNumericCellValue();
            long longVal = (long) doubleVal;
            if (doubleVal == longVal) {
                return String.valueOf(longVal);
            } else {
                return String.format("%.2f", doubleVal);
            }
        }
        return formatter.formatCellValue(cell).trim();
    }
}