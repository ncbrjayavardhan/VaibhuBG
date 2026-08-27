package com.viipl.uppcl;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class PuvvnlLookupServlet
 */
@WebServlet("/puvvnlLookup")
public class PuvvnlLookupServlet extends HttpServlet {
	
	 private static final long serialVersionUID = 1L;

	    // DB connection details
	    private static final String DB_URL = "jdbc:oracle:thin:@192.168.0.69:1521:orcl";
	    private static final String DB_USER = "uppcltest";
	    private static final String DB_PASSWORD = "uppcltest";
  
    /**
     * @see HttpServlet#HttpServlet()
     */
    public PuvvnlLookupServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
//		response.getWriter().append("Served at: ").append(request.getContextPath());
		doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest req, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
//		doGet(request, response);
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

                    ps = conn.prepareStatement("SELECT * FROM consumers_data WHERE acct_id = ?");
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
        RequestDispatcher rd = req.getRequestDispatcher("/puvvnl_result.jsp");
        rd.forward(req, response);
    
	}

}
