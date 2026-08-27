<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <!-- Essential for mobile responsiveness -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vaibhutrans - Login</title>
     <!-- PWA Manifest Link -->
    <link rel="manifest" href="${pageContext.request.contextPath}/manifest.json">
    <meta name="theme-color" content="#007bff">
    <style>
        * {
            box-sizing: border-box;
        }

        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%); 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            min-height: 100vh; /* Handles dynamic height better on mobile */
            margin: 0; 
            padding: 20px; /* Prevents card touching screen edges on small screens */
        }

        .login-card { 
            background: white; 
            padding: 30px; 
            border-radius: 8px; 
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); 
            width: 100%; 
            max-width: 380px; /* Adapts flexibly from mobile up to desktop max width */
        }

        .form-group { 
            margin-bottom: 15px; 
        }

        .form-group label { 
            display: block; 
            margin-bottom: 5px; 
            font-weight: bold; 
        }

        .form-group input { 
            width: 100%; 
            padding: 10px; 
            border: 1px solid #ccc; 
            border-radius: 4px; 
            font-size: 16px; /* Prevents auto-zoom on iOS when tapping input */
        }

        button { 
            width: 100%; 
            padding: 12px; 
            background: #007bff; 
            color: white; 
            border: none; 
            border-radius: 4px; 
            font-size: 16px; 
            cursor: pointer; 
            transition: background-color 0.2s ease;
        }

        button:hover { 
            background: #0056b3; 
        }

        .error { 
            color: red; 
            margin-bottom: 15px; 
            font-size: 14px; 
            text-align: center; 
        }
    </style>
</head>
<body>
    <div class="login-card">
        <h2 style="text-align: center; margin-top: 0; margin-bottom: 20px;">Vaibhutrans</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        <form action="login" method="post">
            <div class="form-group">
                <label for="username">User ID</label>
                <input type="text" id="username" name="username" required />
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required />
            </div>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>