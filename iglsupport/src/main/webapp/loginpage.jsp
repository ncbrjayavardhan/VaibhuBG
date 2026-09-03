<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f6f9;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
    }
    .login-card {
        background: #ffffff;
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        width: 320px;
    }
    .login-card h2 {
        margin-top: 0;
        text-align: center;
        color: #333;
    }
    .form-group {
        margin-bottom: 16px;
    }
    .form-group label {
        display: block;
        margin-bottom: 6px;
        color: #555;
        font-size: 14px;
    }
    .form-group input {
        width: 100%;
        padding: 9px;
        box-sizing: border-box;
        border: 1px solid #ccc;
        border-radius: 4px;
    }
    .btn-submit {
        width: 100%;
        padding: 10px;
        background-color: #007bff;
        border: none;
        color: #fff;
        font-size: 15px;
        font-weight: bold;
        border-radius: 4px;
        cursor: pointer;
    }
    .btn-submit:hover {
        background-color: #0056b3;
    }
    .error-msg {
        background-color: #ffe6e6;
        color: #d93025;
        padding: 10px;
        border-radius: 4px;
        margin-bottom: 15px;
        font-size: 13px;
        text-align: center;
        border: 1px solid #f5c6cb;
    }
</style>
</head>
<body>

<div class="login-card">
    <h2>Sign In</h2>
    
    <%
        String msg = request.getParameter("msg");
        if ("logged_out".equals(msg)) {
    %>
        <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 13px; text-align: center; border: 1px solid #c3e6cb;">
            You have successfully logged out.
        </div>
    <%
        } else if ("session_expired".equals(msg)) {
    %>
        <div style="background-color: #fff3cd; color: #856404; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 13px; text-align: center; border: 1px solid #ffeeba;">
            Your session has expired due to inactivity. Please log in again.
        </div>
    <%
        }
    %>

    <%-- Error message display --%>
    <%
        String errorMessage = (String) request.getAttribute("errorMessage");
        if (errorMessage != null && !errorMessage.isEmpty()) {
    %>
        <div class="error-msg"><%= errorMessage %></div>
    <%
        }
    %>

    <form action="LoginServlet" method="POST">
        <div class="form-group">
            <label for="userId">User ID</label>
            <input type="text" id="userId" name="userId" required autocomplete="off" />
        </div>

        <div class="form-group">
            <label for="pwd">Password</label>
            <input type="password" id="pwd" name="pwd" required />
        </div>

        <button type="submit" class="btn-submit">Login</button>
    </form>
</div>

</body>
</html>