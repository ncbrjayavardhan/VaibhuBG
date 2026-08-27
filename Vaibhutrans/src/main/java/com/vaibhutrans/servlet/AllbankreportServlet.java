package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.BomTransactionDAO;
import com.vaibhutrans.model.BomTransaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/AllbankreportServlet")
public class AllbankreportServlet extends HttpServlet {

    // 1. Instantiate the DAO object
    private final BomTransactionDAO dao = new BomTransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 2. Fetch transactions and account list using the DAO instance
            List<BomTransaction> list = dao.getAllTransactions();
            List<String> accountList = dao.getUniqueAccountNumbers();
            
            // 3. Set attributes for JSP rendering
            request.setAttribute("bomTransactions", list);
            request.setAttribute("accountList", accountList);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error fetching BOM records: " + e.getMessage());
        }

        // 4. Forward to JSP
        request.getRequestDispatcher("allbank.jsp").forward(request, response);
    }
}