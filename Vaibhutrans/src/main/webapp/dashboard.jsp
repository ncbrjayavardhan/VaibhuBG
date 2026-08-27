<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Prevent caching of this page so browser back button won't show it after logout
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Vaibhutrans</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --card-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            --glass-bg: rgba(255, 255, 255, 0.95);
        }

        * { 
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        body { 
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            color: #1e293b;
            padding-bottom: 40px;
        }

        .welcome-container { 
            padding: 40px 20px; 
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .welcome-card { 
            padding: 40px; 
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 20px; 
            box-shadow: var(--card-shadow);
            border: 1px solid rgba(255, 255, 255, 0.3);
            max-width: 650px;
            width: 100%;
            text-align: center;
        }

        .welcome-title { 
            font-weight: 800; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 32px;
            letter-spacing: -0.8px;
        }

        .logo-container {
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 24px 0;
        }

        .logo-img {
            height: 220px; /* Increased height */
            width: auto;   /* Maintains natural aspect ratio */
            max-width: 100%;
            object-fit: contain;
            border-radius: 16px; /* Box corner radius */
            box-shadow: 0 10px 25px -5px rgba(79, 70, 229, 0.3);
            border: 3px solid #ffffff;
        }

        .logo-img:hover {
            transform: scale(1.03);
            box-shadow: 0 15px 30px -5px rgba(79, 70, 229, 0.4);
        }

        .welcome-text {
            color: #475569;
            font-size: 16px;
            line-height: 1.6;
        }

        .user-badge {
            background: rgba(79, 70, 229, 0.1);
            color: #4f46e5;
            padding: 2px 10px;
            border-radius: 6px;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <!-- Include Navbar Component -->
    <jsp:include page="navbar.jsp" />

    <div class="welcome-container">
        <div class="welcome-card">
            <h1 class="welcome-title mb-2">Welcome to Vaibhutrans</h1>
            
            <!-- Centered Image Container -->
            <div class="logo-container">
                <img alt="Vaibhu Trans Logo" src="Vaibhu.jpg" class="logo-img">
            </div>
            
            <p class="welcome-text mb-0">
                Hello, <span class="user-badge"><%= session.getAttribute("user") %></span>! Use the top navigation menu to manage reports, upload statements, or manage bank details.
            </p>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>