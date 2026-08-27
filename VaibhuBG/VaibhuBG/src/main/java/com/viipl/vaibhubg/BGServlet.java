package com.viipl.vaibhubg;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.viipl.vaibhubg.dao.DepartmentDAO;

@WebServlet("/BGServlet")
public class BGServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(BGServlet.class.getName());
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null || action.isEmpty()) {
            displayForm(request, response);
        } else if ("loadDepartments".equals(action)) {
            loadDepartments(request, response);
        } else if ("poSuggest".equals(action)) {
            suggestPoNumbers(request, response);
        } else if ("editBG".equals(action)) {
            editBG(request, response);
        } else if ("viewReport".equals(action)) {
            viewReport(request, response);
        } else if ("exportExcel".equals(action)) {
            exportReportToExcel(request, response);
        } else if ("exportPdf".equals(action)) {
            exportReportToPdf(request, response);
        } else {
            displayForm(request, response);
        }
    }

    private void suggestPoNumbers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String term = request.getParameter("term");
        response.setContentType("application/json");
        if (term == null || term.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }
        term = term.trim();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            String sql = "SELECT DISTINCT PO_NUMBER FROM BG_MASTER WHERE PO_NUMBER LIKE ? AND PO_NUMBER IS NOT NULL ORDER BY BG_ID ASC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, "%" + term + "%");
                try (ResultSet rs = ps.executeQuery()) {
                    StringBuilder sb = new StringBuilder("[");
                    boolean first = true;
                    while (rs.next()) {
                        String val = rs.getString(1);
                        if (val == null) continue;
                        if (!first) sb.append(',');
                        sb.append('"').append(val.replace("\"","\\\"")).append('"');
                        first = false;
                    }
                    sb.append(']');
                    response.getWriter().write(sb.toString());
                }
            }
        } catch (Exception e) {
            response.getWriter().write("[]");
        } finally {
            DBUtil.closeConnection(conn);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("saveBG".equals(action)) {
            saveBG(request, response);
        } else if ("updateBG".equals(action)) {
            updateBG(request, response);
        } else if ("viewReport".equals(action)) {
            viewReport(request, response);
        } else {
            displayForm(request, response);
        }
    }
    
    private void displayForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<String> departments = getDepartments();
            request.setAttribute("departments", departments);
            request.getRequestDispatcher("/bgform.jsp").forward(request, response);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading departments", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading data");
        }
    }
    
    private void loadDepartments(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        try {
            List<String> departments = getDepartments();
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < departments.size(); i++) {
                json.append("\"").append(departments.get(i)).append("\"");
                if (i < departments.size() - 1) json.append(",");
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            response.getWriter().write("[]");
        }
    }
    
    private List<String> getDepartments() throws Exception {
        try {
            return DepartmentDAO.getDepartments();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching departments from DAO", e);
            throw e;
        }
    }

    private void editBG(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bgIdStr = request.getParameter("bgId");
        if (bgIdStr == null || bgIdStr.trim().isEmpty()) {
            displayForm(request, response);
            return;
        }

        Connection conn = null;
        try {
            long bgId = Long.parseLong(bgIdStr.trim());
            conn = DBUtil.getConnection();
            String sql = "SELECT BG_ID, DEPARTMENT, BG_NUMBER, BG_DATE, BG_EXPIRY_DATE, BG_PERIOD, PO_NUMBER, PO_AMOUNT, BG_WORKDESC, BG_TYPE FROM BG_MASTER WHERE BG_ID = ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, bgId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String dept = rs.getString("DEPARTMENT");
                        String bgNum = rs.getString("BG_NUMBER");
                        Date bgDateSql = rs.getDate("BG_DATE");
                        Date bgExpiryDateSql = rs.getDate("BG_EXPIRY_DATE");
                        String bgPeriod = rs.getString("BG_PERIOD");
                        String poNum = rs.getString("PO_NUMBER");
                        java.math.BigDecimal poAmount = rs.getBigDecimal("PO_AMOUNT");
                        String bgWorkdesc = rs.getString("BG_WORKDESC");
                        String bgType = rs.getString("BG_TYPE");

                        Date bgDate = (bgDateSql != null) ? new Date(bgDateSql.getTime()) : null;
                        Date bgExpiryDate = (bgExpiryDateSql != null) ? new Date(bgExpiryDateSql.getTime()) : null;

                        BGPojo bg = new BGPojo(bgId, dept, bgNum, bgDate, bgExpiryDate, bgPeriod, poNum, poAmount, bgWorkdesc, bgType);
                        request.setAttribute("bg", bg);
                    }
                }
            }

            List<String> departments = getDepartments();
            request.setAttribute("departments", departments);
            request.getRequestDispatcher("/bgform.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error loading BG record for editing", e);
            request.setAttribute("errorMessage", "Error loading record: " + e.getMessage());
            displayForm(request, response);
        } finally {
            DBUtil.closeConnection(conn);
        }
    }
    
    private void saveBG(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String department = request.getParameter("department");
        String bgType = request.getParameter("bgType");
        String bgNumber = request.getParameter("bgNumber");
        String bgPeriod = request.getParameter("bgPeriod");
        String poNumber = request.getParameter("poNumber");
        String poAmountStr = request.getParameter("poAmount");
        String bgWorkdesc = request.getParameter("bgWorkdesc");

        String bgDateStr = request.getParameter("bgDate");
        String bgExpiryDateStr = request.getParameter("bgExpiryDate");
        
        if (department == null || department.isEmpty() || 
            bgType == null || bgType.isEmpty() ||
            bgNumber == null || bgNumber.isEmpty() ||
            bgDateStr == null || bgDateStr.isEmpty() || 
            bgExpiryDateStr == null || bgExpiryDateStr.isEmpty()) {
            request.setAttribute("errorMessage", "All required fields must be filled.");
            displayForm(request, response);
            return;
        }
        
        Connection conn = null;
        try {
            LocalDate bgDate = LocalDate.parse(bgDateStr);
            LocalDate bgExpiryDate = LocalDate.parse(bgExpiryDateStr);
            
            if (bgExpiryDate.isBefore(bgDate)) {
                request.setAttribute("errorMessage", "BG Expiry Date cannot be before BG Date");
                displayForm(request, response);
                return;
            }
            
            conn = DBUtil.getConnection();
            String sql = "INSERT INTO BG_MASTER (DEPARTMENT, BG_TYPE, BG_NUMBER, BG_WORKDESC, BG_DATE, BG_PERIOD, BG_EXPIRY_DATE, PO_NUMBER, PO_AMOUNT) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, department);
                pstmt.setString(2, bgType);
                pstmt.setString(3, bgNumber);
                pstmt.setString(4, bgWorkdesc);
                pstmt.setDate(5, java.sql.Date.valueOf(bgDate));
                pstmt.setString(6, bgPeriod);
                pstmt.setDate(7, java.sql.Date.valueOf(bgExpiryDate));

                if (poNumber != null && !poNumber.trim().isEmpty()) {
                    pstmt.setString(8, poNumber.trim());
                } else {
                    pstmt.setNull(8, java.sql.Types.VARCHAR);
                }

                if (poAmountStr != null && !poAmountStr.trim().isEmpty()) {
                    try {
                        java.math.BigDecimal poAmount = new java.math.BigDecimal(poAmountStr.trim());
                        pstmt.setBigDecimal(9, poAmount);
                    } catch (NumberFormatException nfe) {
                        request.setAttribute("errorMessage", "Invalid PO Amount format");
                        displayForm(request, response);
                        return;
                    }
                } else {
                    pstmt.setNull(9, java.sql.Types.DECIMAL);
                }

                int rowsInserted = pstmt.executeUpdate();
                if (rowsInserted > 0) {
                    request.setAttribute("successMessage", "BG Details saved successfully!");
                    LOGGER.log(Level.INFO, "BG Details saved for department: " + department + ", BG Number: " + bgNumber + ", Type: " + bgType);
                } else {
                    request.setAttribute("errorMessage", "Failed to save BG Details");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error saving BG details", e);
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        } finally {
            DBUtil.closeConnection(conn);
        }
        displayForm(request, response);
    }

    private void updateBG(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bgIdStr = request.getParameter("bgId");
        String department = request.getParameter("department");
        String bgType = request.getParameter("bgType");
        String bgNumber = request.getParameter("bgNumber");
        String bgPeriod = request.getParameter("bgPeriod");
        String poNumber = request.getParameter("poNumber");
        String poAmountStr = request.getParameter("poAmount");
        String bgWorkdesc = request.getParameter("bgWorkdesc");

        String bgDateStr = request.getParameter("bgDate");
        String bgExpiryDateStr = request.getParameter("bgExpiryDate");

        if (bgIdStr == null || bgIdStr.trim().isEmpty() ||
            department == null || department.isEmpty() || 
            bgType == null || bgType.isEmpty() ||
            bgNumber == null || bgNumber.isEmpty() ||
            bgDateStr == null || bgDateStr.isEmpty() || 
            bgExpiryDateStr == null || bgExpiryDateStr.isEmpty()) {
            request.setAttribute("errorMessage", "All required fields must be filled.");
            editBG(request, response);
            return;
        }

        Connection conn = null;
        try {
            long bgId = Long.parseLong(bgIdStr.trim());
            LocalDate bgDate = LocalDate.parse(bgDateStr);
            LocalDate bgExpiryDate = LocalDate.parse(bgExpiryDateStr);

            if (bgExpiryDate.isBefore(bgDate)) {
                request.setAttribute("errorMessage", "BG Expiry Date cannot be before BG Date");
                editBG(request, response);
                return;
            }

            conn = DBUtil.getConnection();
            String sql = "UPDATE BG_MASTER SET DEPARTMENT = ?, BG_TYPE = ?, BG_NUMBER = ?, BG_WORKDESC = ?, BG_DATE = ?, BG_PERIOD = ?, BG_EXPIRY_DATE = ?, PO_NUMBER = ?, PO_AMOUNT = ? WHERE BG_ID = ?";

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, department);
                pstmt.setString(2, bgType);
                pstmt.setString(3, bgNumber);
                pstmt.setString(4, bgWorkdesc);
                pstmt.setDate(5, java.sql.Date.valueOf(bgDate));
                pstmt.setString(6, bgPeriod);
                pstmt.setDate(7, java.sql.Date.valueOf(bgExpiryDate));

                if (poNumber != null && !poNumber.trim().isEmpty()) {
                    pstmt.setString(8, poNumber.trim());
                } else {
                    pstmt.setNull(8, java.sql.Types.VARCHAR);
                }

                if (poAmountStr != null && !poAmountStr.trim().isEmpty()) {
                    try {
                        java.math.BigDecimal poAmount = new java.math.BigDecimal(poAmountStr.trim());
                        pstmt.setBigDecimal(9, poAmount);
                    } catch (NumberFormatException nfe) {
                        request.setAttribute("errorMessage", "Invalid PO Amount format");
                        editBG(request, response);
                        return;
                    }
                } else {
                    pstmt.setNull(9, java.sql.Types.DECIMAL);
                }

                pstmt.setLong(10, bgId);

                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                    request.setAttribute("successMessage", "BG Details updated successfully!");
                    LOGGER.log(Level.INFO, "BG Details updated for BG ID: " + bgId);
                } else {
                    request.setAttribute("errorMessage", "Failed to update BG Details");
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating BG details", e);
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        } finally {
            DBUtil.closeConnection(conn);
        }

        // Re-display the updated form
        editBG(request, response);
    }
    
    private void viewReport(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String department = request.getParameter("reportDepartment");
        String filterPoNumber = request.getParameter("reportPoNumber");
        String filterBgNumber = request.getParameter("reportBgNumber");

        department = (department != null) ? department.trim() : "";
        filterPoNumber = (filterPoNumber != null) ? filterPoNumber.trim() : "";
        filterBgNumber = (filterBgNumber != null) ? filterBgNumber.trim() : "";

        int page = 1;
        int pageSize = 50;
        try {
            String pageStr = request.getParameter("page");
            String pageSizeStr = request.getParameter("pageSize");
            if (pageStr != null) page = Math.max(1, Integer.parseInt(pageStr));
            if (pageSizeStr != null) pageSize = Math.max(1, Integer.parseInt(pageSizeStr));
        } catch (NumberFormatException nfe) {
            // keep defaults
        }

        List<BGPojo> bgList = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBUtil.getConnection();

            StringBuilder where = new StringBuilder();
            List<Object> params = new ArrayList<>();

            if (!department.isEmpty()) {
                where.append(" WHERE DEPARTMENT = ?");
                params.add(department);
            }
            if (!filterPoNumber.isEmpty()) {
                where.append(params.isEmpty() ? " WHERE PO_NUMBER LIKE ?" : " AND PO_NUMBER LIKE ?");
                params.add("%" + filterPoNumber + "%");
            }
            if (!filterBgNumber.isEmpty()) {
                where.append(params.isEmpty() ? " WHERE BG_NUMBER LIKE ?" : " AND BG_NUMBER LIKE ?");
                params.add("%" + filterBgNumber + "%");
            }

            String countSql = "SELECT COUNT(*) FROM BG_MASTER" + where.toString();
            int totalRows = 0;
            try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                for (int i = 0; i < params.size(); i++) {
                    psCount.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = psCount.executeQuery()) {
                    if (rs.next()) totalRows = rs.getInt(1);
                }
            }

            int totalPages = (int) Math.ceil((double) totalRows / pageSize);
            if (page > totalPages && totalPages > 0) page = totalPages;

            int offset = (page - 1) * pageSize + 1;
            int limit = offset + pageSize - 1;
//            String dataSql = "SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY BG_DATE DESC) rn, BG_ID, DEPARTMENT, BG_NUMBER, BG_DATE, BG_EXPIRY_DATE, BG_PERIOD, PO_NUMBER, PO_AMOUNT, BG_WORKDESC, BG_TYPE FROM BG_MASTER"
//                    + where.toString() + ") WHERE rn BETWEEN " + offset + " AND " + limit;
            String dataSql = "SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY  BG_expiry_DATE asc) rn, BG_ID, DEPARTMENT, BG_NUMBER, BG_DATE, BG_EXPIRY_DATE, BG_PERIOD, PO_NUMBER, PO_AMOUNT, BG_WORKDESC, BG_TYPE FROM BG_MASTER"
                    + where.toString() + ") WHERE rn BETWEEN " + offset + " AND " + limit;

            try (PreparedStatement pstmt = conn.prepareStatement(dataSql)) {
                int idx = 1;
                for (Object p : params) {
                    pstmt.setObject(idx++, p);
                }

                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        long bgId = rs.getLong("BG_ID");
                        String dept = rs.getString("DEPARTMENT");
                        String bgNum = rs.getString("BG_NUMBER");
                        Date bgDateSql = rs.getDate("BG_DATE");
                        Date bgExpiryDateSql = rs.getDate("BG_EXPIRY_DATE");
                        String bgPeriod = rs.getString("BG_PERIOD");
                        String poNum = rs.getString("PO_NUMBER");
                        java.math.BigDecimal poAmount = rs.getBigDecimal("PO_AMOUNT");
                        String bgWorkdesc = rs.getString("BG_WORKDESC");
                        String bgType = rs.getString("BG_TYPE");

                        Date bgDate = (bgDateSql != null) ? new Date(bgDateSql.getTime()) : null;
                        Date bgExpiryDate = (bgExpiryDateSql != null) ? new Date(bgExpiryDateSql.getTime()) : null;

                        bgList.add(new BGPojo(bgId, dept, bgNum, bgDate, bgExpiryDate, bgPeriod, poNum, poAmount, bgWorkdesc, bgType));
                    }
                }
            }

            List<String> departments = getDepartments();
            request.setAttribute("departments", departments);
            request.setAttribute("selectedDepartment", department);
            request.setAttribute("selectedPoNumber", filterPoNumber);
            request.setAttribute("selectedBgNumber", filterBgNumber);
            request.setAttribute("bgList", bgList);
            request.setAttribute("currentPage", page);
            request.setAttribute("pageSize", pageSize);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRows", totalRows);

            request.getRequestDispatcher("/bgreport.jsp").forward(request, response);

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error fetching BG report", e);
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        } finally {
            DBUtil.closeConnection(conn);
        }
    }

    private void exportReportToExcel(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<BGPojo> bgList = fetchReportData(request);
            byte[] excelData = ExcelExporter.generateExcel(bgList);
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment;filename=BG_Report.xls");
            response.setContentLength(excelData.length);
            response.getOutputStream().write(excelData);
            response.getOutputStream().flush();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error exporting to Excel", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error exporting to Excel: " + e.getMessage());
        }
    }

    private void exportReportToPdf(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<BGPojo> bgList = fetchReportData(request);
            byte[] pdfData = PdfExporter.generatePdf(bgList);
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "inline;filename=BG_Report.pdf");
            response.setContentLength(pdfData.length);
            response.getOutputStream().write(pdfData);
            response.getOutputStream().flush();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error exporting to PDF", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error exporting to PDF: " + e.getMessage());
        }
    }
    
    private List<BGPojo> fetchReportData(HttpServletRequest request) throws Exception {
        String department = request.getParameter("reportDepartment");
        String filterPoNumber = request.getParameter("reportPoNumber");
        String filterBgNumber = request.getParameter("reportBgNumber");

        department = (department != null) ? department.trim() : "";
        filterPoNumber = (filterPoNumber != null) ? filterPoNumber.trim() : "";
        filterBgNumber = (filterBgNumber != null) ? filterBgNumber.trim() : "";

        List<BGPojo> bgList = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            StringBuilder where = new StringBuilder();
            List<Object> params = new ArrayList<>();

            if (!department.isEmpty()) {
                where.append(" WHERE DEPARTMENT = ?");
                params.add(department);
            }
            if (!filterPoNumber.isEmpty()) {
                where.append(params.isEmpty() ? " WHERE PO_NUMBER LIKE ?" : " AND PO_NUMBER LIKE ?");
                params.add("%" + filterPoNumber + "%");
            }
            if (!filterBgNumber.isEmpty()) {
                where.append(params.isEmpty() ? " WHERE BG_NUMBER LIKE ?" : " AND BG_NUMBER LIKE ?");
                params.add("%" + filterBgNumber + "%");
            }
            
            String sql = "SELECT BG_ID, DEPARTMENT, BG_NUMBER, BG_DATE, BG_EXPIRY_DATE, BG_PERIOD, PO_NUMBER, PO_AMOUNT, BG_WORKDESC, BG_TYPE FROM BG_MASTER" + where.toString() + " ORDER BY  BG_expiry_DATE ASC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                int idx = 1;
                for (Object p : params) {
                    ps.setObject(idx++, p);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        long bgId = rs.getLong("BG_ID");
                        String dept = rs.getString("DEPARTMENT");
                        String bgNum = rs.getString("BG_NUMBER");
                        Date bgDateSql = rs.getDate("BG_DATE");
                        Date bgExpiryDateSql = rs.getDate("BG_EXPIRY_DATE");
                        String bgPeriod = rs.getString("BG_PERIOD");
                        String poNum = rs.getString("PO_NUMBER");
                        java.math.BigDecimal poAmount = rs.getBigDecimal("PO_AMOUNT");
                        String bgWorkdesc = rs.getString("BG_WORKDESC");
                        String bgType = rs.getString("BG_TYPE");

                        Date bgDate = (bgDateSql != null) ? new Date(bgDateSql.getTime()) : null;
                        Date bgExpiryDate = (bgExpiryDateSql != null) ? new Date(bgExpiryDateSql.getTime()) : null;

                        bgList.add(new BGPojo(bgId, dept, bgNum, bgDate, bgExpiryDate, bgPeriod, poNum, poAmount, bgWorkdesc, bgType));
                    }
                }
            }
        } finally {
            DBUtil.closeConnection(conn);
        }
        return bgList;
    }
}