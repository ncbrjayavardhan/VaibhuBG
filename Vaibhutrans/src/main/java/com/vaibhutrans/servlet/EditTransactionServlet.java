package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.TransactionDAO;
import com.vaibhutrans.model.Transaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;

@WebServlet("/editTransaction")
public class EditTransactionServlet extends HttpServlet {

    private TransactionDAO transactionDAO;

    @Override
    public void init() throws ServletException {
        transactionDAO = new TransactionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String utr = request.getParameter("utr");
        
        try {
            if (utr != null && !utr.trim().isEmpty()) {
                Transaction tx = transactionDAO.getTransactionByUtr(utr);
                if (tx != null) {
                    request.setAttribute("transaction", tx);
                    request.getRequestDispatcher("edit_transaction.jsp").forward(request, response);
                    return;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect("report");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            String utrNo = request.getParameter("utrNo");
            String debitAcc = request.getParameter("debitAccount");
            String benfAcc = request.getParameter("benfAccount");
            String benfName = request.getParameter("benfName");
            String benfIfsc = request.getParameter("benfIfsc");
            String benfBank = request.getParameter("benfBank");
            String benfBranch = request.getParameter("benfBranch");
            
            double amount = 0.0;
            String amtStr = request.getParameter("amount");
            if (amtStr != null && !amtStr.trim().isEmpty()) {
                amount = Double.parseDouble(amtStr.trim());
            }

            String paymentMode = request.getParameter("paymentMode");
            String status = request.getParameter("status");
            String narration = request.getParameter("narration");
            String tallyledger = request.getParameter("tallyledger");
            String project = request.getParameter("project");

            // --- DATE CONVERSION FIX HERE ---
            String dateStr = request.getParameter("transactionDate");
            java.sql.Date sqlTransactionDate = null;
            if (dateStr != null && !dateStr.trim().isEmpty()) {
                // Option A: Convert via SimpleDateFormat
                java.util.Date parsedDate = new SimpleDateFormat("yyyy-MM-dd").parse(dateStr);
                sqlTransactionDate = new java.sql.Date(parsedDate.getTime());
                
                // Option B (Simpler): Since HTML input date format is always yyyy-MM-dd, 
                // java.sql.Date.valueOf(dateStr) also works directly!
            }

            Transaction tx = new Transaction();
            tx.setUtrNo(utrNo);
            tx.setTransactionDate(sqlTransactionDate); // Now correctly passes java.sql.Date
            tx.setDebitAccount(debitAcc);
            tx.setBenfAccount(benfAcc);
            tx.setBenfName(benfName);
            tx.setBenfIfsc(benfIfsc);
            tx.setBenfBank(benfBank);
            tx.setBenfBranch(benfBranch);
            tx.setAmount(amount);
            tx.setPaymentMode(paymentMode);
            tx.setStatus(status);
            tx.setNarration(narration);
            tx.setTallyledger(tallyledger);
            tx.setProject(project);

            transactionDAO.updateTransaction(tx);

            response.sendRedirect("report");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to update record: " + e.getMessage());
            request.getRequestDispatcher("edit_transaction.jsp").forward(request, response);
        }
    }
}