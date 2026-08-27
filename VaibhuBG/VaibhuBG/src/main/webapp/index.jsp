<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BG Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .container {
            text-align: center;
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            max-width: 500px;
            width: 100%;
        }
        
        h1 {
            color: #333;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        
        .button-group {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-top: 30px;
        }
        
        a {
            display: inline-block;
            padding: 15px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 1.1em;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        a:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
        
        .info {
            margin-top: 30px;
            padding: 20px;
            background: #f0f0f0;
            border-radius: 5px;
            text-align: left;
        }
        
        .info h3 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .info ul {
            list-style-position: inside;
            color: #666;
            line-height: 1.8;
        }
    </style>
</head>
<body>

    <div class="container">
        <h1>BG Management System</h1>
        
        <div class="button-group">
            <a href="BGServlet">Add BG Details</a>
            <a href="BGServlet?action=viewReport">View BG Report</a>
            <a href="adddept.jsp">Add Department</a>
        </div>
        
        <div class="info">
            <h3>Features:</h3>
            <ul>
                <li>Add new Bank Guarantee details</li>
                <li>View BG records by Department</li>
                <li>Track BG expiry dates</li>
                <li>Secure data storage in Oracle Database</li>
            </ul>
        </div>
    </div>
</body>
</html>
