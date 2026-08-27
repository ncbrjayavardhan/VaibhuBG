package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.BomTransactionDAO;
import com.vaibhutrans.service.SbiStatementParser;
import com.vaibhutrans.model.BomTransaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

@WebServlet("/uploadSbiStatement")
@MultipartConfig
public class SbiUploadServlet extends HttpServlet {

    private final BomTransactionDAO dao = new BomTransactionDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Part filePart = request.getPart("file");
        if (filePart != null && filePart.getSize() > 0) {
            try {
                // Read uploaded file bytes
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                try (InputStream is = filePart.getInputStream()) {
                    int nRead;
                    byte[] data = new byte[8192];
                    while ((nRead = is.read(data, 0, data.length)) != -1) {
                        buffer.write(data, 0, nRead);
                    }
                }
                byte[] fileBytes = buffer.toByteArray();

                // Parse SBI Statement
                List<BomTransaction> txList;
                try (InputStream is = new ByteArrayInputStream(fileBytes)) {
                    txList = SbiStatementParser.parse(is);
                }

                if (txList == null || txList.isEmpty()) {
                    request.setAttribute("error", "No valid transactions found in the SBI statement file.");
                    request.getRequestDispatcher("sbi_upload.jsp").forward(request, response);
                    return;
                }

                // Save or merge into Oracle table BOM_TRANSACTIONS
                dao.saveOrMergeTransactions(txList);

                // Set success message and redirect
                request.getSession().setAttribute("successMessage", txList.size() + " SBI records processed and saved successfully!");
                response.sendRedirect("sbiReport");
                return;

            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Error processing SBI Statement: " + e.getMessage());
                request.getRequestDispatcher("sbi_upload.jsp").forward(request, response);
                return;
            }
        }
        
        request.setAttribute("error", "Please select an SBI file to upload.");
        request.getRequestDispatcher("sbi_upload.jsp").forward(request, response);
    }
}