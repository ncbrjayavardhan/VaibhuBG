package com.iglsupport.servlet;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.iglsupport.dao.ReportDAO;
import com.iglsupport.model.ReportDTO;

@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<ReportDTO> reportList = ReportDAO.getDailyReport();
        
        if (reportList != null && !reportList.isEmpty()) {
            request.setAttribute("reportList", reportList);
            request.setAttribute("hasData", true);
        } else {
            request.setAttribute("hasData", false);
            request.setAttribute("message", "No portions found with inv_status = 1. Report cannot be generated.");
        }
        
        request.getRequestDispatcher("report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}