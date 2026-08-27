package com.viipl.vaibhubg;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;



/**
 * Servlet implementation class AddDeptServlet
 */
@WebServlet("/AddDeptServlet")
public class AddDeptServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final Logger LOGGER = Logger.getLogger(AddDeptServlet.class.getName());  
    
	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		request.getRequestDispatcher("adddept.jsp").forward(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
//		doGet(request, response);
		
		String deptName = request.getParameter("deptName");
        String message = "";
        String messageType = "error";

        // Validate input
        if (deptName == null || deptName.trim().isEmpty()) {
            message = "Dept Name name is required.";
            request.setAttribute("message", message);
            request.setAttribute("messageType", messageType);
            request.getRequestDispatcher("adddept.jsp").forward(request, response);
            return;
        }

        deptName = deptName.trim();

        Connection connection = null;
        try {
            connection = DBUtil.getConnection();

            // Get the next sequence value for BANK_ID (using Oracle sequence)
            String getSeqSql = "SELECT MAX (dept_id) as nextId FROM BG_DEPT";
            int nextBankId = 0;

            try (PreparedStatement seqStmt = connection.prepareStatement(getSeqSql)) {
                try (ResultSet seqRs = seqStmt.executeQuery()) {
                    if (seqRs.next()) {
                        nextBankId = seqRs.getInt("nextId");
                        nextBankId++; // Increment to get the next ID
                    }
                }
            }

            if (nextBankId == 0) {
                throw new SQLException("Failed to get next sequence value for DEPT_ID");
            }

            // Insert the new bank into the database
            String insertSql = "INSERT INTO BG_DEPT (DEPT_ID, DEPT_NAME,CREATED_AT) VALUES (?, ?,?)";

            try (PreparedStatement insertStmt = connection.prepareStatement(insertSql)) {
                insertStmt.setInt(1, nextBankId);
                insertStmt.setString(2, deptName);
//                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss.SSSSSS");
//
//             // 2. Get current local date-time formatted as a string
//             String formattedDateTime = LocalDateTime.now().format(formatter);
//                insertStmt.setTimestamp(3, formattedDateTime);
                insertStmt.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now()));

                int rowsInserted = insertStmt.executeUpdate();

                if (rowsInserted > 0) {
                    message = "Department '" + deptName + "' added successfully with ID: " + nextBankId;
                    messageType = "success";
                    LOGGER.log(Level.INFO, "Bank added: " + deptName + " (ID: " + nextBankId + ")");
                } else {
                    message = "Failed to add bank. Please try again.";
                    messageType = "error";
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error while adding Department: " + e.getMessage(), e);
            message = "A database error occurred: " + e.getMessage();
            messageType = "error";
        } finally {
            DBUtil.closeConnection(connection);
        }

        // Set attributes for JSP
        request.setAttribute("message", message);
        request.setAttribute("messageType", messageType);

        // Forward back to the form
        request.getRequestDispatcher("adddept.jsp").forward(request, response);
    }
	

}
