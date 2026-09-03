package com.iglsupport.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.iglsupport.dao.UserDAO;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String userId = request.getParameter("userId");
        String pwd = request.getParameter("pwd");

        // Validate inputs are not blank
        if (userId == null || userId.trim().isEmpty() || pwd == null || pwd.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please enter both User ID and Password.");
            request.getRequestDispatcher("loginpage.jsp").forward(request, response);
            return;
        }

        HttpSession session2 = request.getSession();
        String userCaptchaStr = request.getParameter("captcha");
        Integer expectedCaptcha = (Integer) session2.getAttribute("expectedCaptcha");

        if (expectedCaptcha == null || userCaptchaStr == null || Integer.parseInt(userCaptchaStr) != expectedCaptcha) {
            // CAPTCHA failed
            request.setAttribute("errorMessage", "Invalid CAPTCHA answer. Please try again.");
            request.getRequestDispatcher("loginpage.jsp").forward(request, response);
            return;
        }

        // Clear the captcha session attribute so it cannot be reused
        session2.removeAttribute("expectedCaptcha");
        // Authenticate against database via UserDAO
        boolean isValid = UserDAO.validateUser(userId.trim(), pwd.trim());

        if (isValid) {
            // Invalidate any existing old sessions for security
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            // Create a fresh session and assign attributes
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", userId.trim());
            
            // Set session inactivity timeout to 15 minutes (900 seconds)
            session.setMaxInactiveInterval(15 * 60);
            
            // Redirect to dashboard on success
            response.sendRedirect("dashboard.jsp");
        } else {
            // Send back error message on authentication failure
            request.setAttribute("errorMessage", "Invalid User ID or Password. Please try again.");
            request.getRequestDispatcher("loginpage.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Direct GET requests to login page
        response.sendRedirect("loginpage.jsp");
    }
}