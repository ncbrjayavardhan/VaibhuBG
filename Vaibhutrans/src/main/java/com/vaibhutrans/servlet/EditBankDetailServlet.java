package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.BankDetailDAO;
import com.vaibhutrans.model.BankDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/editBankDetail")
public class EditBankDetailServlet extends HttpServlet {
    private BankDetailDAO dao = new BankDetailDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String acc = request.getParameter("acc");
        try {
            BankDetail bd = dao.getBankDetailByAccount(acc);
            request.setAttribute("bankDetail", bd);
            request.getRequestDispatcher("edit_bank_detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("bankReport");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String benfAccount = request.getParameter("benfAccount");
            String benfName = request.getParameter("benfName");
            String benfIfsc = request.getParameter("benfIfsc");
            String benfBranch = request.getParameter("benfBranch");
            String benfBank = request.getParameter("benfBank");

            BankDetail bd = new BankDetail(benfAccount, benfName, benfIfsc, benfBranch, benfBank);
            dao.updateBankDetail(bd);

            response.sendRedirect("bankReport");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to update bank detail.");
            request.getRequestDispatcher("edit_bank_detail.jsp").forward(request, response);
        }
    }
}