<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Dashboard</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #eef2f5;
        margin: 0;
        padding: 20px;
    }
    .navbar {
        background-color: #343a40;
        color: white;
        padding: 15px 25px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-radius: 6px;
    }
    .navbar h1 {
        margin: 0;
        font-size: 20px;
    }
    .nav-links {
        display: flex;
        align-items: center;
        gap: 15px;
    }
    .navbar a {
        text-decoration: none;
        font-weight: bold;
    }
    .nav-link {
        color: #ffffff;
        padding: 6px 12px;
        background-color: #1f4e78;
        border-radius: 4px;
        transition: background-color 0.2s;
    }
    .nav-link:hover {
        background-color: #163654;
    }
    .logout-link {
        color: #ffc107;
    }
    .content-card {
        background: white;
        margin-top: 20px;
        padding: 25px;
        border-radius: 6px;
        box-shadow: 0 2px 6px rgba(0,0,0,0.08);
    }
    .quick-actions {
        margin-top: 20px;
        display: flex;
        gap: 15px;
    }
    .action-card {
        border: 1px solid #dee2e6;
        border-radius: 6px;
        padding: 15px 20px;
        background-color: #f8f9fa;
        text-decoration: none;
        color: #333;
        display: inline-block;
        transition: box-shadow 0.2s, border-color 0.2s;
    }
    .action-card:hover {
        border-color: #1f4e78;
        box-shadow: 0 2px 8px rgba(31, 78, 120, 0.15);
    }
    .action-card strong {
        color: #1f4e78;
        display: block;
        margin-bottom: 5px;
    }
</style>
</head>
<body>
<%
    // Session validation: Prevent unauthorized direct URL access
    String currentUser = (String) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("loginpage.jsp");
        return;
    }
%>
<div class="navbar">
    <h1>Application Dashboard</h1>
    <div class="nav-links">
        <a href="ReportServlet" class="nav-link">Daily Progress Report</a>
        <span>Welcome, <strong><%= currentUser %></strong></span> | 
        <a href="LogoutServlet" class="logout-link">Logout</a>
    </div>
</div>

<div class="content-card">
    <h2>Welcome to your workspace</h2>
    <p>You have successfully authenticated via MySQL database.</p>
    
    <div class="quick-actions">
        <a href="ReportServlet" class="action-card">
            <strong>Daily Progress Report &rarr;</strong>
            <span>View GA & portion reading and invoice reconciliation</span>
        </a>
        <a href="PortionDetailsServlet" class="action-card">
            <strong>Portion Details &rarr;</strong>
            <span>Manage portion information and settings</span>
        </a>
    </div>
    
    
</div>


<!-- <a href="PortionDetailsServlet" class="nav-link">Portion Setup</a> -->

</body>
</html>