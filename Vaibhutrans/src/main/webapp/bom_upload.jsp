<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Upload BOM Statement - Vaibhutrans</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column; /* Allows navbar to sit on top and content below */
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
        }

        /* Container to center the card on the screen below navbar */
        .page-content-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px 1rem;
        }

        .upload-card {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            padding: 35px;
            width: 100%;
            max-width: 500px;
        }

        .upload-card h3 {
            color: #333;
            font-weight: 700;
            margin-bottom: 20px;
            text-align: center;
        }

        .file-drop-area {
            border: 2px dashed #667eea;
            border-radius: 8px;
            padding: 30px;
            text-align: center;
            background-color: #f8f9fa;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }

        .file-drop-area:hover {
            background-color: #eef2ff;
        }

        .file-drop-area i {
            font-size: 40px;
            color: #667eea;
            margin-bottom: 10px;
        }

        .btn-upload {
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            font-weight: 600;
            padding: 10px 20px;
            border-radius: 6px;
            width: 100%;
            margin-top: 20px;
        }

        .btn-upload:hover {
            opacity: 0.95;
            color: #fff;
        }
    </style>
</head>
<body>

    <!-- Navbar placed at top -->
    <jsp:include page="navbar.jsp" />

    <!-- Main Content Area -->
    <div class="page-content-wrapper">
        <div class="upload-card">
            <h3><i class="fa fa-university text-primary"></i> Upload BOM Statement</h3>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger py-2 mb-3" role="alert">
                    <i class="fa fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <form action="uploadBomStatement" method="post" enctype="multipart/form-data">
                <div class="file-drop-area" onclick="document.getElementById('fileInput').click();">
                    <i class="fa fa-cloud-upload-alt"></i>
                    <p class="mb-1 fw-bold text-secondary">Click or drag Bank Statement here</p>
                    <span class="text-muted small">Supports .xls or .xlsx formats</span>
                    <input type="file" id="fileInput" name="file" accept=".xls,.xlsx" class="d-none" onchange="showFileName(this)" required>
                    <div id="fileNameDisplay" class="mt-2 text-primary fw-bold small"></div>
                </div>

                <button type="submit" class="btn btn-upload">
                    <i class="fa fa-cogs"></i> Process & Save Statement
                </button>
            </form>
            
            <div class="text-center mt-3">
                <!-- <a href="reports.jsp" class="text-decoration-none text-muted small"><i class="fa fa-arrow-left"></i> Back to Dashboard</a> -->
            </div>
        </div>
    </div>

<script>
    function showFileName(input) {
        var display = document.getElementById('fileNameDisplay');
        if (input.files && input.files[0]) {
            display.innerText = "Selected File: " + input.files[0].name;
        } else {
            display.innerText = "";
        }
    }
</script>

</body>
</html>