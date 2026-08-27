<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Department - Vaibhu BG Details</title>
    <style>
        :root {
            --primary-bg: #f4f7f6;
            --card-bg: #ffffff;
            --text-main: #333333;
            --text-muted: #777777;
            --accent-color: #0056b3;
            --success-color: #28a745;
            --error-color: #dc3545;
        }

        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--primary-bg);
            color: var(--text-main);
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        :root {
            --navbar-height: 64px;
        }

        .container {
            max-width: 600px;
            width: 100%;
            margin: 40px auto;
            padding: 0 20px;
            flex: 1 1 auto;
            box-sizing: border-box;
        }

        .page-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .page-header h1 {
            margin: 0 0 10px 0;
            color: var(--accent-color);
            font-size: 24px;
        }

        .page-header p {
            color: var(--text-muted);
            margin-top: 5px;
            font-size: 14px;
        }

        .form-card {
            background-color: var(--card-bg);
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border: 1px solid #e0e0e0;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            color: var(--text-main);
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-group input[type="text"],
        .form-group textarea {
            width: 100%;
            padding: 10px 12px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 14px;
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            box-sizing: border-box;
            transition: border-color 0.2s ease;
        }

        .form-group input[type="text"]:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 8px rgba(0,86,179,0.2);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }

        .btn {
            flex: 1;
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }

        .btn-primary {
            background-color: var(--accent-color);
            color: white;
        }

        .btn-primary:hover {
            background-color: #004085;
            box-shadow: 0 4px 12px rgba(0,86,179,0.3);
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
        }

        .message {
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
            border: 1px solid transparent;
        }

        .message.success {
            background-color: #d4edda;
            color: #155724;
            border-color: #c3e6cb;
        }

        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border-color: #f5c6cb;
        }

        .form-hint {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 4px;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: var(--accent-color);
            text-decoration: none;
            font-size: 14px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        @media (max-width: 600px) {
            .container {
                margin: 20px auto;
                padding: 0 15px;
            }

            .form-card {
                padding: 20px;
            }

            .page-header h1 {
                font-size: 20px;
            }

            .button-group {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <div class="container">
        <a href="index.jsp" class="back-link">← Back to Dashboard</a>

        <div class="page-header">
            <h1>Add New Department</h1>
            <p>Enter the Department details to add a new Department to the system</p>
        </div>

        <!-- Display Message if any -->
        <c:if test="${not empty message}">
            <div class="message ${messageType}">
                ${message}
            </div>
        </c:if>

        <div class="form-card">
            <form action="AddDeptServlet" method="POST" onsubmit="return validateForm();">
                <div class="form-group">
                    <label for="deptName">Department Name <span style="color: red;">*</span></label>
                    <input type="text" id="deptName" name="deptName" placeholder="Enter Department name" 
                           maxlength="100" required>
                    <div class="form-hint">Department name will be assigned an auto-incremented ID</div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-primary">Add Department</button>
                    <a href="index.jsp" class="btn btn-secondary">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function validateForm() {
            const bankName = document.getElementById('deptName').value.trim();
            
            if (bankName === '') {
                alert('Please enter a Department name.');
                return false;
            }
            
            if (bankName.length < 2) {
                alert('Department name must be at least 2 characters long.');
                return false;
            }
            
            return true;
        }

        // Auto-focus on the input field
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('deptName').focus();
        });
    </script>
</body>
</html>
