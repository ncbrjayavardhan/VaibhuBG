package com.iglsupport.servlet;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.iglsupport.dao.PortionDetailsDAO;
import com.iglsupport.model.PortionDetailsDTO;

@WebServlet("/PortionDetailsServlet")
public class PortionDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Fetch all portion details and forward to the JSP view
        List<PortionDetailsDTO> list = PortionDetailsDAO.getAllPortionDetails();
        request.setAttribute("portionList", list);
        request.getRequestDispatcher("viewPortionDetails.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String vidStr = request.getParameter("vid");
        String state = request.getParameter("state");
        String city = request.getParameter("city");
        String ga = request.getParameter("ga");
        String pidStr = request.getParameter("pid");
        String totalDataStr = request.getParameter("totalData");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        if (pidStr != null && !pidStr.trim().isEmpty()) {
            try {
                int vid = (vidStr != null && !vidStr.trim().isEmpty()) ? Integer.parseInt(vidStr.trim()) : 1;
                int pid = Integer.parseInt(pidStr.trim());
                Integer totalData = (totalDataStr != null && !totalDataStr.trim().isEmpty()) 
                                    ? Integer.parseInt(totalDataStr.trim()) : null;
                LocalDate startDate = (startDateStr != null && !startDateStr.trim().isEmpty()) 
                                      ? LocalDate.parse(startDateStr.trim()) : null;
                LocalDate endDate = (endDateStr != null && !endDateStr.trim().isEmpty()) 
                                    ? LocalDate.parse(endDateStr.trim()) : null;

                PortionDetailsDTO dto = new PortionDetailsDTO(vid, state, city, ga, pid, totalData, startDate, endDate);
                boolean success = PortionDetailsDAO.saveOrUpdate(dto);

                if (success) {
                    response.sendRedirect("PortionDetailsServlet?msg=success");
                } else {
                    response.sendRedirect("PortionDetailsServlet?msg=error");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("PortionDetailsServlet?msg=error");
            }
        } else {
            response.sendRedirect("PortionDetailsServlet");
        }
    }
}