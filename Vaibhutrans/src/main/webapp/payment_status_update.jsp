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
    <meta charset="UTF-8">
    <title>Update Payment Status - Vaibhutrans</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            font-family: 'Plus Jakarta Sans', sans-serif;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            margin: 0;
        }

        .page-content-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 1rem;
        }

        .upload-card {
            background: rgba(255, 255, 255, 0.96);
            backdrop-filter: blur(12px);
            border-radius: 18px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 35px;
            width: 100%;
            max-width: 540px;
        }

        .upload-card h3 {
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 8px;
            text-align: center;
            letter-spacing: -0.5px;
        }

        .form-floating > .form-control,
        .form-floating > .form-select {
            height: calc(3.2rem + 2px);
            padding: 1rem 0.75px;
            font-size: 13.5px;
            font-weight: 600;
            border-radius: 10px;
            border: 1px solid #cbd5e1;
        }

        .form-floating > label {
            padding: 0.8rem 0.75rem;
            font-size: 12px;
            color: #64748b;
        }

        .form-control:focus, .form-select:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
        }

        .file-drop-area {
            border: 2px dashed #6366f1;
            border-radius: 12px;
            padding: 24px;
            text-align: center;
            background-color: #f8fafc;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .file-drop-area:hover {
            background-color: #eef2ff;
            border-color: #4f46e5;
        }

        .file-drop-area i {
            font-size: 38px;
            color: #6366f1;
            margin-bottom: 8px;
        }

        .btn-upload {
            background: linear-gradient(135deg, #059669 0%, #10b981 100%);
            border: none;
            color: white;
            font-weight: 700;
            padding: 12px 20px;
            border-radius: 10px;
            width: 100%;
            font-size: 14px;
            box-shadow: 0 4px 14px rgba(16, 185, 129, 0.4);
        }

        .btn-upload:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.5);
            color: #fff;
        }
    </style>
</head>
<body>

    <!-- Navbar -->
    <jsp:include page="navbar.jsp" />

    <!-- Main Content -->
    <div class="page-content-wrapper">
        <div class="upload-card">
            <h3><i class="fa fa-sync-alt text-success me-2"></i> Update Payment Status</h3>
            

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger py-2 mb-3 small" role="alert">
                    <i class="fa fa-exclamation-circle me-1"></i> <%= request.getAttribute("error") %>
                </div>
            <% } %>
            <% if (request.getAttribute("message") != null) { %>
                <div class="alert alert-success py-2 mb-3 small" role="alert">
                    <i class="fa fa-check-circle me-1"></i> <%= request.getAttribute("message") %>
                </div>
            <% } %>

            <form action="pay-register" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="updateStatus">

                <!-- Cluster Selection -->
                <div class="form-floating mb-3">
                    <select name="uploadCluster" id="uploadCluster" class="form-select" required>
                        <option value="">-- Select Cluster --</option>
                        <option value="8">Cluster-8</option>
                        <option value="9">Cluster-9</option>
                        <option value="12">Cluster-12</option>
                        <option value="5">Cluster-5</option>
                    </select>
                    <label for="uploadCluster"><i class="fa fa-layer-group me-1"></i> Target Cluster</label>
                </div>

                <!-- Month & Year Row -->
                <div class="row g-2 mb-3">
                    <div class="col-6">
                        <div class="form-floating">
                            <select name="uploadMonth" id="uploadMonth" class="form-select" required>
                                <option value="">-- Month --</option>
                                <option value="JAN">JAN</option>
                                <option value="FEB">FEB</option>
                                <option value="MAR">MAR</option>
                                <option value="APR">APR</option>
                                <option value="MAY">MAY</option>
                                <option value="JUN">JUN</option>
                                <option value="JUL">JUL</option>
                                <option value="AUG">AUG</option>
                                <option value="SEP">SEP</option>
                                <option value="OCT">OCT</option>
                                <option value="NOV">NOV</option>
                                <option value="DEC">DEC</option>
                            </select>
                            <label for="uploadMonth"><i class="fa fa-calendar-alt me-1"></i> Target Month</label>
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="form-floating">
                            <select name="uploadYear" id="uploadYear" class="form-select" required>
                                <option value="">-- Year --</option>
                                <%
                                    int currY = java.time.Year.now().getValue();
                                    for (int y = currY; y >= currY - 5; y--) {
                                %>
                                    <option value="<%=y%>"><%=y%></option>
                                <% } %>
                            </select>
                            <label for="uploadYear"><i class="fa fa-calendar me-1"></i> Target Year</label>
                        </div>
                    </div>
                </div>

                <!-- File Drop Area -->
                <div class="file-drop-area mb-3" onclick="document.getElementById('fileInput').click();">
                    <i class="fa fa-file-excel d-block text-success"></i>
                    <p class="mb-1 fw-bold text-dark small">Click or drag Status Excel file here</p>
                    <span class="text-muted small">Headers must contain "code" / "empcode" and "db_status" / "status"</span>
                    <input type="file" id="fileInput" name="excelFile" accept=".xlsx,.xls" class="d-none" onchange="showFileName(this)" required>
                    <div id="fileNameDisplay" class="mt-2 text-success fw-bold small"></div>
                </div>

                <button type="submit" class="btn btn-upload">
                    <i class="fa fa-check-double me-1"></i> Update Statuses
                </button>
            </form>
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