package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.BomTransactionDAO;
import com.vaibhutrans.model.BomTransaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/sbiReport")
public class SbiReportServlet extends HttpServlet {

    private final BomTransactionDAO dao = new BomTransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            // Retrieve all transactions
            List<BomTransaction> allTransactions = dao.getAllTransactions();

            // Filter for SBI transactions
            List<BomTransaction> sbiTransactions = allTransactions.stream()
                    .filter(tx -> "SBI".equalsIgnoreCase(tx.getBankName()))
                    .collect(Collectors.toList());

            List<String> accountList = dao.getUniqueAccountNumbers();

            request.setAttribute("sbiTransactions", sbiTransactions);
            request.setAttribute("accountList", accountList);

            request.getRequestDispatcher("sbiReport.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error loading SBI report: " + e.getMessage());
            request.getRequestDispatcher("sbiReport.jsp").forward(request, response);
        }
    }
}