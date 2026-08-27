package com.vaibhutrans.servlet;

import com.vaibhutrans.config.DBConnection;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

@WebServlet("/uploadEmployees")
@MultipartConfig(
    maxFileSize = 20 * 1024 * 1024,
    maxRequestSize = 25 * 1024 * 1024
)
public class UploadEmployeeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private String getCellValue(Row row, int cellIndex, DataFormatter formatter) {
        if (row == null) return "";
        Cell cell = row.getCell(cellIndex);
        if (cell == null) return "";
        String val = formatter.formatCellValue(cell);
        return (val != null) ? val.trim() : "";
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String message = "";
        Part filePart = request.getPart("excelFile");

        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("employeeReport.jsp?msg=" + java.net.URLEncoder.encode("Please select an Excel file to upload.", "UTF-8"));
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || (!fileName.toLowerCase().endsWith(".xlsx") && !fileName.toLowerCase().endsWith(".xls"))) {
            response.sendRedirect("employeeReport.jsp?msg=" + java.net.URLEncoder.encode("Please upload a valid Excel file (.xlsx or .xls).", "UTF-8"));
            return;
        }

        String mergeSql = "MERGE INTO EMPLOYEE_MASTER target " +
                          "USING (SELECT ? AS EMP_CODE FROM dual) src " +
                          "ON (target.EMP_CODE = src.EMP_CODE) " +
                          "WHEN MATCHED THEN UPDATE SET " +
                          "  DOJ = ?, DESIGNATION = ?, AADHAR_NO = ?, EMP_NAME = ?, FATHER_NAME = ?, MOBILE = ?, " +
                          "  CLU_NAME = ?, ZONE = ?, CIRCLE = ?, DIV = ?, ACCOUNT_NO = ?, IFSC = ?, BRANCH_NAME = ?, BANK_NAME = ?, DB_STATUS = ? " +
                          "WHEN NOT MATCHED THEN INSERT " +
                          "  (EMP_CODE, DOJ, DESIGNATION, AADHAR_NO, EMP_NAME, FATHER_NAME, MOBILE, " +
                          "   CLU_NAME, ZONE, CIRCLE, DIV, ACCOUNT_NO, IFSC, BRANCH_NAME, BANK_NAME, DB_STATUS) " +
                          "  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        int processedCount = 0;

        try (InputStream is = filePart.getInputStream();
             Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(mergeSql)) {

            Workbook workbook = WorkbookFactory.create(is);
            Sheet sheet = workbook.getSheetAt(0);
            DataFormatter formatter = new DataFormatter();
            conn.setAutoCommit(false);

            int lastRowNum = sheet.getLastRowNum();

            for (int i = 1; i <= lastRowNum; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                String empCode = getCellValue(row, 0, formatter);
                if (empCode.isEmpty()) continue;

                String doj = getCellValue(row, 1, formatter);
                String designation = getCellValue(row, 2, formatter);
                String aadhar = getCellValue(row, 3, formatter);
                String empName = getCellValue(row, 4, formatter);
                String fatherName = getCellValue(row, 5, formatter);
                String mobile = getCellValue(row, 6, formatter);
                String cluName = getCellValue(row, 7, formatter);
                String zone = getCellValue(row, 8, formatter);
                String circle = getCellValue(row, 9, formatter);
                String div = getCellValue(row, 10, formatter);
                String accNo = getCellValue(row, 11, formatter);
                String ifsc = getCellValue(row, 12, formatter);
                String branch = getCellValue(row, 13, formatter);
                String bank = getCellValue(row, 14, formatter);
                String dbStatus = getCellValue(row, 15, formatter);

                // 1. Merge Condition
                ps.setString(1, empCode);

                // 2. Update Set
                ps.setString(2, doj);
                ps.setString(3, designation);
                ps.setString(4, aadhar);
                ps.setString(5, empName);
                ps.setString(6, fatherName);
                ps.setString(7, mobile);
                ps.setString(8, cluName);
                ps.setString(9, zone);
                ps.setString(10, circle);
                ps.setString(11, div);
                ps.setString(12, accNo);
                ps.setString(13, ifsc);
                ps.setString(14, branch);
                ps.setString(15, bank);
                ps.setString(16, dbStatus);

                // 3. Insert Values
                ps.setString(17, empCode);
                ps.setString(18, doj);
                ps.setString(19, designation);
                ps.setString(20, aadhar);
                ps.setString(21, empName);
                ps.setString(22, fatherName);
                ps.setString(23, mobile);
                ps.setString(24, cluName);
                ps.setString(25, zone);
                ps.setString(26, circle);
                ps.setString(27, div);
                ps.setString(28, accNo);
                ps.setString(29, ifsc);
                ps.setString(30, branch);
                ps.setString(31, bank);
                ps.setString(32, dbStatus);

                ps.addBatch();
                processedCount++;

                if (processedCount % 500 == 0) {
                    ps.executeBatch();
                }
            }

            ps.executeBatch();
            conn.commit();
            message = processedCount + " employee records uploaded and merged successfully!";

        } catch (Exception e) {
            e.printStackTrace();
            message = "Error uploading employee file: " + e.getMessage();
        }

        response.sendRedirect("employeeReport.jsp?msg=" + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}