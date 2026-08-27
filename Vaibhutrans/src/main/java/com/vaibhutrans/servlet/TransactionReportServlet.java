package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.TransactionDAO;
import com.vaibhutrans.model.Transaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/report")
public class TransactionReportServlet extends HttpServlet {
    private TransactionDAO dao = new TransactionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<Transaction> list = dao.getAllTransactionsWithBankDetails();
            request.setAttribute("transactions", list);
            request.getRequestDispatcher("report.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to load report.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        }
    }
}