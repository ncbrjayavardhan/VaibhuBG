package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.BankDetailDAO;
import com.vaibhutrans.model.BankDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/bankReport")
public class BankReportServlet extends HttpServlet {
	private BankDetailDAO dao = new BankDetailDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String filterAcc = request.getParameter("filterAccount");
            String filterName = request.getParameter("filterName");
            String filterBank = request.getParameter("filterBank");

            List<BankDetail> list = dao.searchBankDetails(filterAcc, filterName, filterBank);
            
            request.setAttribute("bankList", list);
            request.setAttribute("filterAccount", filterAcc != null ? filterAcc : "");
            request.setAttribute("filterName", filterName != null ? filterName : "");
            request.setAttribute("filterBank", filterBank != null ? filterBank : "");

            request.getRequestDispatcher("bank_report.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to load bank details report.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        }
    }
}