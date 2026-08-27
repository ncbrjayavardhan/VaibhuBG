<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vaibhutrans.model.BankDetail" %>
<%
    // Prevent caching of this page so browser back button won't show it after logout
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    BankDetail bd = (BankDetail) request.getAttribute("bankDetail");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Bank Details - Vaibhutrans</title>
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
            --border-color: #cbd5e1;
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

        .form-card { 
            padding: 32px; 
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 20px; 
            box-shadow: var(--card-shadow);
            border: 1px solid rgba(255, 255, 255, 0.3);
            max-width: 600px;
            margin: 40px auto 0 auto;
        }

        .header-title-container {
            border-bottom: 2px dashed #e2e8f0;
            padding-bottom: 20px;
            margin-bottom: 28px;
        }

        .form-title { 
            font-weight: 800; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 26px;
            letter-spacing: -0.8px;
        }

        /* Floating form controls */
        .form-floating > .form-control {
            height: calc(3.5rem + 2px);
            padding: 1rem 0.75rem;
            font-size: 14px;
            font-weight: 500;
            border-radius: 10px;
            border: 1px solid #cbd5e1;
        }

        .form-floating > .form-control:read-only {
            background-color: #f1f5f9;
            color: #475569;
            font-weight: 600;
            cursor: not-allowed;
        }

        .form-floating > label {
            padding: 1rem 0.75rem;
            font-size: 12.5px;
            color: #64748b;
        }

        .form-control:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
        }

        /* Button styling */
        .btn { 
            border-radius: 8px; 
            font-weight: 600; 
            border: none; 
            padding: 10px 20px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            font-size: 14px;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        .btn-gradient-primary { 
            background: var(--primary-gradient); 
            color: white; 
        }

        .btn-light { 
            background: #f1f5f9; 
            color: #475569; 
            border: 1px solid #cbd5e1; 
        }

        .btn-light:hover { 
            background: #e2e8f0; 
        }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <div class="container px-3">
        <div class="form-card">
            
            <!-- Header Section -->
            <div class="d-flex align-items-center gap-3 header-title-container">
                <div class="p-3 bg-light rounded-3 text-primary border">
                    <i class="fa fa-pen-to-square fa-2x"></i>
                </div>
                <div>
                    <h3 class="form-title mb-0">Edit Bank Details</h3>
                    <p class="text-muted small mb-0">Update beneficiary information and account details</p>
                </div>
            </div>

            <!-- Form -->
            <form action="editBankDetail" method="post" class="d-flex flex-column gap-3">
                
                <!-- Beneficiary Account (Read-only) -->
                <div class="form-floating">
                    <input type="text" id="benfAccount" name="benfAccount" class="form-control" 
                           value="<%= bd != null ? bd.getBenfAccount() : "" %>" readonly />
                    <label for="benfAccount"><i class="fa fa-credit-card me-1"></i> Beneficiary Account (Read-only)</label>
                </div>

                <!-- Beneficiary Name -->
                <div class="form-floating">
                    <input type="text" id="benfName" name="benfName" class="form-control" 
                           value="<%= bd != null && bd.getBenfName() != null ? bd.getBenfName() : "" %>" required placeholder="Beneficiary Name" />
                    <label for="benfName"><i class="fa fa-user me-1"></i> Beneficiary Name</label>
                </div>

                <!-- IFSC Code -->
                <div class="form-floating">
                    <input type="text" id="benfIfsc" name="benfIfsc" class="form-control" 
                           value="<%= bd != null && bd.getBenfIfsc() != null ? bd.getBenfIfsc() : "" %>" required placeholder="IFSC Code" />
                    <label for="benfIfsc"><i class="fa fa-code me-1"></i> IFSC Code</label>
                </div>

                <!-- Branch Name -->
                <div class="form-floating">
                    <input type="text" id="benfBranch" name="benfBranch" class="form-control" 
                           value="<%= bd != null && bd.getBenfBranch() != null ? bd.getBenfBranch() : "" %>" required placeholder="Branch Name" />
                    <label for="benfBranch"><i class="fa fa-code-branch me-1"></i> Branch Name</label>
                </div>

                <!-- Bank Name -->
                <div class="form-floating">
                    <input type="text" id="benfBank" name="benfBank" class="form-control" 
                           value="<%= bd != null && bd.getBenfBank() != null ? bd.getBenfBank() : "" %>" required placeholder="Bank Name" />
                    <label for="benfBank"><i class="fa fa-building-columns me-1"></i> Bank Name</label>
                </div>

                <!-- Actions -->
                <div class="d-flex align-items-center justify-content-end gap-2 mt-3">
                    <a href="bankReport" class="btn btn-light">
                        <i class="fa fa-arrow-left me-1"></i> Cancel
                    </a>
                    <button type="submit" class="btn btn-gradient-primary">
                        <i class="fa fa-check me-1"></i> Update Bank Detail
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>