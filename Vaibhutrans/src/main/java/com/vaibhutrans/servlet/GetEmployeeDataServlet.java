package com.vaibhutrans.servlet;

import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.google.gson.Gson;
import com.vaibhutrans.config.DBConnection;

@WebServlet("/getEmployeeData")
public class GetEmployeeDataServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws java.io.IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String cluName = request.getParameter("cluName");
        String zone = request.getParameter("zone");
        String circle = request.getParameter("circle");
        String div = request.getParameter("div");
        String designation = request.getParameter("designation");
        String dbStatus = request.getParameter("dbStatus");

        StringBuilder query = new StringBuilder("SELECT * FROM EMPLOYEE_MASTER WHERE 1=1 ");
        List<String> params = new ArrayList<>();

        if (cluName != null && !cluName.trim().isEmpty()) {
            query.append("AND CLU_NAME = ? ");
            params.add(cluName.trim());
        }
        if (zone != null && !zone.trim().isEmpty()) {
            query.append("AND ZONE = ? ");
            params.add(zone.trim());
        }
        if (circle != null && !circle.trim().isEmpty()) {
            query.append("AND CIRCLE = ? ");
            params.add(circle.trim());
        }
        if (div != null && !div.trim().isEmpty()) {
            query.append("AND DIV = ? ");
            params.add(div.trim());
        }
        if (designation != null && !designation.trim().isEmpty()) {
            query.append("AND DESIGNATION = ? ");
            params.add(designation.trim());
        }
        if (dbStatus != null && !dbStatus.trim().isEmpty()) {
            query.append("AND DB_STATUS = ? ");
            params.add(dbStatus.trim());
        }

        List<Map<String, String>> data = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("empCode", rs.getString("EMP_CODE"));
                row.put("empName", rs.getString("EMP_NAME"));
                row.put("fatherName", rs.getString("FATHER_NAME"));
                row.put("designation", rs.getString("DESIGNATION"));
                row.put("doj", rs.getString("DOJ"));
                row.put("mobile", rs.getString("MOBILE"));
                row.put("aadharNo", rs.getString("AADHAR_NO"));
                row.put("cluName", rs.getString("CLU_NAME"));
                row.put("zone", rs.getString("ZONE"));
                row.put("circle", rs.getString("CIRCLE"));
                row.put("div", rs.getString("DIV"));
                row.put("bankName", rs.getString("BANK_NAME"));
                row.put("branchName", rs.getString("BRANCH_NAME"));
                row.put("accountNo", rs.getString("ACCOUNT_NO"));
                row.put("ifsc", rs.getString("IFSC"));
                row.put("dbStatus", rs.getString("DB_STATUS"));
                data.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        Map<String, Object> result = new HashMap<>();
        result.put("data", data);
        out.print(new Gson().toJson(result));
    }
}