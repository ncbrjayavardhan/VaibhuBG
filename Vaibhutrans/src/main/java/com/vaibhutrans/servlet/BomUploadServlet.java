package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.BomTransactionDAO;
import com.vaibhutrans.service.BomStatementParser;
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

@WebServlet("/uploadBomStatement")
@MultipartConfig
public class BomUploadServlet extends HttpServlet {

    private final BomTransactionDAO dao = new BomTransactionDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        Part filePart = request.getPart("file");
        if (filePart != null && filePart.getSize() > 0) {
            try {
                // Java 8 compatible stream reading
                ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                try (InputStream is = filePart.getInputStream()) {
                    int nRead;
                    byte[] data = new byte[8192];
                    while ((nRead = is.read(data, 0, data.length)) != -1) {
                        buffer.write(data, 0, nRead);
                    }
                }
                byte[] fileBytes = buffer.toByteArray();

                String filePreview = new String(fileBytes, 0, Math.min(fileBytes.length, 2048));

                List<BomTransaction> txList;
                boolean isSbi = false;

                // 1. Auto-detect if file is SBI or BOM
//                if (filePreview.contains("Account Number") && filePreview.contains("IFS Code")) {
//                    isSbi = true;
//                    try (InputStream is = new ByteArrayInputStream(fileBytes)) {
//                        txList = SbiStatementParser.parse(is);
//                    }
//                } else {
                    try (InputStream is = new ByteArrayInputStream(fileBytes)) {
                        txList = BomStatementParser.parseBomStatement(is);
                    }
//                }

                if (txList == null || txList.isEmpty()) {
                    request.setAttribute("error", "No valid transactions found in the file.");
                    request.getRequestDispatcher("bom_upload.jsp").forward(request, response);
                    return;
                }

                // 2. Save or merge transactions into BOM_TRANSACTIONS
                dao.saveOrMergeTransactions(txList);

                // 3. Store success message in session so it survives response.sendRedirect()
                request.getSession().setAttribute("successMessage", txList.size() + " records processed and saved successfully!");

                // 4. Dynamic Redirect based on Bank
                if (isSbi) {
                    response.sendRedirect("sbiReport");
                } else {
                    response.sendRedirect("bomReport");
                }
                return;

            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Error processing Statement: " + e.getMessage());
                request.getRequestDispatcher("bom_upload.jsp").forward(request, response);
                return;
            }
        }
        
        request.setAttribute("error", "Please select a file to upload.");
        request.getRequestDispatcher("bom_upload.jsp").forward(request, response);
    }
}