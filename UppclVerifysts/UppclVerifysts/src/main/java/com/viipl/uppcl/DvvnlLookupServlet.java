package com.viipl.uppcl;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/dvvnlLookup")
public class DvvnlLookupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // DB connection details
    private static final String DB_URL = "jdbc:oracle:thin:@192.168.0.69:1521:orcl";
    private static final String DB_USER = "uppcltest";
    private static final String DB_PASSWORD = "uppcltest";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String mobile = req.getParameter("mobileNumber");
        String serverMsg = null;
        List<Map<String, String>> rows = new ArrayList<>();

        if (mobile == null) {
            serverMsg = "No acct_id provided.";
        } else {
            mobile = mobile.trim();
            if (!mobile.matches("[0-9]{10,11}")) {
                serverMsg = "Error: number must be 10 or 11 digits (only numbers).";
            } else {
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                try {
                    Class.forName("oracle.jdbc.driver.OracleDriver");
                    conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

                    ps = conn.prepareStatement("SELECT * FROM dvvnl_consumers_data WHERE acct_id = ?");
                    ps.setString(1, mobile);
                    rs = ps.executeQuery();

                    ResultSetMetaData md = rs.getMetaData();
                    int cols = md.getColumnCount();

                    // Friendly label map (lowercase column name -> label)
                    Map<String, String> labelMap = new HashMap<>();
                    labelMap.put("acct_id", "Account ID");
                    labelMap.put("consumer_name", "Consumer Name");
                    labelMap.put("name", "Name");
                    labelMap.put("address", "Address");
                    labelMap.put("mobile", "Mobile");
                    labelMap.put("phone", "Phone");
                    labelMap.put("email", "Email");

                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        for (int i = 1; i <= cols; i++) {
                            String colName = md.getColumnName(i);
                            if ("CONSUMERS_DATA_ID".equalsIgnoreCase(colName) || "LOCAL_DATE_TIME".equalsIgnoreCase(colName)) {
                                continue; // skip internal columns
                            }
                            String label = labelMap.getOrDefault(colName.toLowerCase(), colName);
                            Object val = rs.getObject(i);
                            row.put(label, val == null ? "" : val.toString());
                        }
                        rows.add(row);
                    }

                    if (rows.isEmpty()) {
                        serverMsg = "No records found for acct_id = " + mobile;
                    } else {
                        serverMsg = "Success: Records found for acct_id = " + mobile;
                    }

                } catch (Exception e) {
                    serverMsg = "DB Error: " + e.getMessage();
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                    try { if (ps != null) ps.close(); } catch (Exception ignored) {}
                    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
                }
            }
        }

        req.setAttribute("serverMsg", serverMsg);
        req.setAttribute("rows", rows);
        RequestDispatcher rd = req.getRequestDispatcher("/dvvnl_result.jsp");
        rd.forward(req, resp);
    }
}
