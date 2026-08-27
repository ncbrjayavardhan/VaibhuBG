package com.vaibhutrans.servlet;

import com.vaibhutrans.config.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/updateEmployee")
public class UpdateEmployeeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print("{\"success\":false,\"message\":\"GET method not supported. Use POST.\"}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        
        PrintWriter out = response.getWriter();

        String empCode = request.getParameter("empCode");
        String empName = request.getParameter("empName");
        String fatherName = request.getParameter("fatherName");
        String doj = request.getParameter("doj");
        String designation = request.getParameter("designation");
        String aadharNo = request.getParameter("aadharNo");
        String mobile = request.getParameter("mobile");
        String cluName = request.getParameter("cluName");
        String zone = request.getParameter("zone");
        String circle = request.getParameter("circle");
        String div = request.getParameter("div");
        String bankName = request.getParameter("bankName");
        String branchName = request.getParameter("branchName");
        String accountNo = request.getParameter("accountNo");
        String ifsc = request.getParameter("ifsc");
        String dbStatus = request.getParameter("dbStatus");

        if (empCode == null || empCode.trim().isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Employee Code is required.\"}");
            return;
        }

        String sql = "UPDATE EMPLOYEE_MASTER SET "
                   + "EMP_NAME = ?, "
                   + "FATHER_NAME = ?, "
                   + "DOJ = ?, "
                   + "DESIGNATION = ?, "
                   + "AADHAR_NO = ?, "
                   + "MOBILE = ?, "
                   + "CLU_NAME = ?, "
                   + "ZONE = ?, "
                   + "CIRCLE = ?, "
                   + "DIV = ?, "
                   + "BANK_NAME = ?, "
                   + "BRANCH_NAME = ?, "
                   + "ACCOUNT_NO = ?, "
                   + "IFSC = ?, "
                   + "DB_STATUS = ? "
                   + "WHERE TRIM(UPPER(EMP_CODE)) = TRIM(UPPER(?))";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, empName != null ? empName.trim() : null);
            ps.setString(2, fatherName != null ? fatherName.trim() : null);
            ps.setString(3, doj != null ? doj.trim() : null);
            ps.setString(4, designation != null ? designation.trim() : null);
            ps.setString(5, aadharNo != null ? aadharNo.trim() : null);
            ps.setString(6, mobile != null ? mobile.trim() : null);
            ps.setString(7, cluName != null ? cluName.trim() : null);
            ps.setString(8, zone != null ? zone.trim() : null);
            ps.setString(9, circle != null ? circle.trim() : null);
            ps.setString(10, div != null ? div.trim() : null);
            ps.setString(11, bankName != null ? bankName.trim() : null);
            ps.setString(12, branchName != null ? branchName.trim() : null);
            ps.setString(13, accountNo != null ? accountNo.trim() : null);
            ps.setString(14, ifsc != null ? ifsc.trim() : null);
            ps.setString(15, dbStatus != null ? dbStatus.trim() : null);
            ps.setString(16, empCode.trim());

            int updated = ps.executeUpdate();
            if (updated > 0) {
                out.print("{\"success\":true,\"message\":\"Employee record updated successfully.\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"No employee record found for code: " + escapeJson(empCode) + "\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage() != null ? escapeJson(e.getMessage()) : "Database error during update.";
            out.print("{\"success\":false,\"message\":\"" + errorMsg + "\"}");
        }
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}