<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.vaibhutrans.config.DBConnection" %>
<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Set<String> clusters = new TreeSet<>();
    Set<String> zones = new TreeSet<>();
    Set<String> circles = new TreeSet<>();
    Set<String> divisions = new TreeSet<>();
    Set<String> designations = new TreeSet<>();
    Set<String> dbStatuses = new TreeSet<>();

    Connection conn = null;
    Statement st = null;
    ResultSet rs = null;

    try {
        conn = DBConnection.getConnection();
        if (conn != null) {
            st = conn.createStatement();
            
            rs = st.executeQuery("SELECT DISTINCT CLU_NAME FROM EMPLOYEE_MASTER WHERE CLU_NAME IS NOT NULL ORDER BY CLU_NAME");
            while (rs.next()) { if (rs.getString(1) != null && !rs.getString(1).trim().isEmpty()) clusters.add(rs.getString(1).trim()); }
            rs.close();

            rs = st.executeQuery("SELECT DISTINCT ZONE FROM EMPLOYEE_MASTER WHERE ZONE IS NOT NULL ORDER BY ZONE");
            while (rs.next()) { if (rs.getString(1) != null && !rs.getString(1).trim().isEmpty()) zones.add(rs.getString(1).trim()); }
            rs.close();

            rs = st.executeQuery("SELECT DISTINCT CIRCLE FROM EMPLOYEE_MASTER WHERE CIRCLE IS NOT NULL ORDER BY CIRCLE");
            while (rs.next()) { if (rs.getString(1) != null && !rs.getString(1).trim().isEmpty()) circles.add(rs.getString(1).trim()); }
            rs.close();

            rs = st.executeQuery("SELECT DISTINCT DIV FROM EMPLOYEE_MASTER WHERE DIV IS NOT NULL ORDER BY DIV");
            while (rs.next()) { if (rs.getString(1) != null && !rs.getString(1).trim().isEmpty()) divisions.add(rs.getString(1).trim()); }
            rs.close();

            rs = st.executeQuery("SELECT DISTINCT DESIGNATION FROM EMPLOYEE_MASTER WHERE DESIGNATION IS NOT NULL ORDER BY DESIGNATION");
            while (rs.next()) { if (rs.getString(1) != null && !rs.getString(1).trim().isEmpty()) designations.add(rs.getString(1).trim()); }
            rs.close();

            rs = st.executeQuery("SELECT DISTINCT DB_STATUS FROM EMPLOYEE_MASTER WHERE DB_STATUS IS NOT NULL ORDER BY DB_STATUS");
            while (rs.next()) { if (rs.getString(1) != null && !rs.getString(1).trim().isEmpty()) dbStatuses.add(rs.getString(1).trim()); }
            rs.close();
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (st != null) try { st.close(); } catch (Exception ignore) {}
        if (conn != null) try { conn.close(); } catch (Exception ignore) {}
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Master Report - Vaibhutrans</title>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- SheetJS for Client-Side Excel Export -->
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
    <!-- jsPDF & AutoTable -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>

    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --card-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
            --glass-bg: rgba(255, 255, 255, 0.96);
            --border-color: #cbd5e1;
        }

        * { 
            font-family: 'Plus Jakarta Sans', sans-serif; 
            box-sizing: border-box;
        }

        body { 
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            color: #1e293b;
            padding-bottom: 30px;
        }

        #loadingOverlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 23, 42, 0.7);
            backdrop-filter: blur(4px);
            z-index: 99999;
            display: none;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: #ffffff;
        }
		/* Blue / Cyan for Paid */
		.status-badge-paid {
		    background: #eff6ff;
		    color: #1d4ed8;
		    border: 1px solid #bfdbfe;
		}
        .spinner-custom {
            width: 3.2rem;
            height: 3.2rem;
            border: 4px solid rgba(255, 255, 255, 0.2);
            border-top: 4px solid #6366f1;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .report-card { 
            padding: 18px 22px; 
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 14px; 
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.3);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-top: 12px;
        }

        .header-title-container {
            border-bottom: 2px dashed #e2e8f0;
            padding-bottom: 10px;
            margin-bottom: 12px;
        }

        .report-title { 
            font-weight: 800; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 20px;
            letter-spacing: -0.5px;
        }

        .filters-panel { 
            background: #f8fafc;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            padding: 8px 10px;
        }

        .filters-panel .form-select-sm, .filters-panel .form-control-sm {
            height: 32px;
            font-size: 11.5px;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
        }

        .actions-bar {
            background: #ffffff;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            padding: 6px 12px;
        }

        .btn { 
            border-radius: 6px; 
            font-weight: 600; 
            border: none; 
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            font-size: 11.5px;
            white-space: nowrap;
        }
        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.12);
        }
        
        .btn-gradient-primary { background: var(--primary-gradient); color: white; }
        .btn-gradient-success { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; }
        .btn-gradient-info { background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); color: white; }
        .btn-gradient-danger { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; }
        .btn-dark { background: #0f172a; color: white; }
        .btn-light { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-light:hover { background: #e2e8f0; color: #0f172a; }

        .table-responsive { 
            margin-top: 8px;
            border-radius: 8px;
            overflow-x: auto; 
            max-height: 65vh;
            box-shadow: var(--card-shadow);
            border: 1px solid var(--border-color);
        }
        
        .table-bordered-custom {
            margin-bottom: 0;
            border-collapse: separate !important;
            border-spacing: 0;
            background: #ffffff;
            width: 100%;
        }
        
        .table-bordered-custom th,
        .table-bordered-custom td {
            border: 1px solid var(--border-color) !important;
            padding: 6px 9px;
            font-size: 11.5px;
            vertical-align: middle;
            white-space: nowrap;
        }

        .table-bordered-custom thead th { 
            position: sticky;
            top: 0;
            z-index: 2;
            background: #0f172a;
            color: #f8fafc;
            border: 1px solid #334155 !important;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 10px;
            letter-spacing: 0.5px;
        }

        .table-bordered-custom tbody tr:hover {
            background-color: #f1f5f9;
        }

        .code-badge {
            background: #eef2ff;
            color: #4338ca;
            font-family: monospace;
            padding: 2px 5px;
            border-radius: 4px;
            font-weight: 700;
        }

        /* Status Badges */
        .status-badge {
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 4px;
            font-size: 10.5px;
            display: inline-block;
        }

        /* 1. Green for Allow */
        .status-badge-allow {
            background: #ecfdf5;
            color: #047857;
            border: 1px solid #a7f3d0;
        }

        /* 2. Red for Left or Hold */
        .status-badge-hold {
            background: #fef2f2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }

        /* 3. Light Brown for Any Other Status */
        .status-badge-other {
            background: #fdf8f4;
            color: #9a3412;
            border: 1px solid #fed7aa;
        }

        .btn-action-edit {
            padding: 3px 8px;
            font-size: 11px;
            border-radius: 4px;
            background: #e0e7ff;
            color: #3730a3;
            border: 1px solid #c7d2fe;
            transition: all 0.15s ease-in-out;
        }

        .btn-action-edit:hover {
            background: #4f46e5;
            color: #ffffff;
            border-color: #4338ca;
        }

        .pagination-container {
            margin-top: 10px;
            padding: 8px 14px;
            background: #f8fafc;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .badge-total {
            background: var(--primary-gradient);
            padding: 4px 10px;
            font-weight: 700;
            border-radius: 16px;
            color: white;
            font-size: 11px;
        }

        .modal-content {
            border-radius: 12px;
            border: none;
            overflow: hidden;
        }

        .modal-header {
            background: var(--primary-gradient);
            color: white;
            padding: 10px 14px;
        }
    </style>
</head>
<body>

    <!-- Full-Screen Loading Overlay -->
    <div id="loadingOverlay">
        <div class="spinner-custom mb-3"></div>
        <div class="fw-bold fs-6" id="loadingText">Loading Data, Please Wait...</div>
        <small class="text-white-50">Fetching employee records from Employee Master</small>
    </div>

    <!-- Include Navbar -->
    <jsp:include page="navbar.jsp" />

    <div class="container-fluid px-3 mt-1">
        <div class="report-card">
            
            <!-- Header Section -->
            <div class="d-flex flex-wrap justify-content-between align-items-center header-title-container gap-2">
                <div class="d-flex align-items-center gap-2">
                    <div class="p-2 bg-light rounded-3 text-primary border">
                        <i class="fa fa-users fa-lg"></i>
                    </div>
                    <div>
                        <h4 class="report-title mb-0">Employee Master Report</h4>
                        <p class="text-muted small mb-0" style="font-size: 11px;">View, filter, edit, upload and export records from EMPLOYEE_MASTER</p>
                    </div>
                </div>

                <div class="d-flex gap-1">
                    <button type="button" class="btn btn-gradient-primary btn-sm py-1 px-3" data-bs-toggle="modal" data-bs-target="#uploadModal">
                        <i class="fa fa-cloud-arrow-up"></i> Upload Excel
                    </button>
                </div>
            </div>

            <!-- Client Feedback Message -->
            <div id="clientAlert" class="alert py-1 px-3 mb-2 small alert-dismissible fade show d-none" role="alert">
                <span id="clientAlertText"></span>
                <button type="button" class="btn-close" onclick="document.getElementById('clientAlert').classList.add('d-none')"></button>
            </div>

            <!-- Filters Panel -->
            <div class="filters-panel mb-2">
                <div class="row g-1 align-items-center">
                    <div class="col-6 col-sm-4 col-md-2">
                        <select id="filterCluster" class="form-select form-select-sm fw-semibold" onchange="applyFilters()">
                            <option value="">1. All Clusters</option>
                            <% for (String c : clusters) { %><option value="<%= c %>"><%= c %></option><% } %>
                        </select>
                    </div>

                    <div class="col-6 col-sm-4 col-md-2">
                        <select id="filterZone" class="form-select form-select-sm fw-semibold" onchange="applyFilters()">
                            <option value="">2. All Zones</option>
                            <% for (String z : zones) { %><option value="<%= z %>"><%= z %></option><% } %>
                        </select>
                    </div>

                    <div class="col-6 col-sm-4 col-md-2">
                        <select id="filterCircle" class="form-select form-select-sm fw-semibold" onchange="applyFilters()">
                            <option value="">3. All Circles</option>
                            <% for (String cr : circles) { %><option value="<%= cr %>"><%= cr %></option><% } %>
                        </select>
                    </div>

                    <div class="col-6 col-sm-4 col-md-2">
                        <select id="filterDivision" class="form-select form-select-sm fw-semibold" onchange="applyFilters()">
                            <option value="">4. All Divisions</option>
                            <% for (String d : divisions) { %><option value="<%= d %>"><%= d %></option><% } %>
                        </select>
                    </div>

                    <div class="col-6 col-sm-4 col-md-2">
                        <select id="filterDesignation" class="form-select form-select-sm fw-semibold" onchange="applyFilters()">
                            <option value="">5. All Designations</option>
                            <% for (String dg : designations) { %><option value="<%= dg %>"><%= dg %></option><% } %>
                        </select>
                    </div>

                    <div class="col-6 col-sm-4 col-md-2">
                        <select id="filterDbStatus" class="form-select form-select-sm fw-semibold" onchange="applyFilters()">
                            <option value="">6. All DB Status</option>
                            <% for (String s : dbStatuses) { %><option value="<%= s %>"><%= s %></option><% } %>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Export Toolbar & Search -->
            <div class="actions-bar d-flex flex-wrap align-items-center justify-content-between mb-2 gap-2">
                <div class="col-12 col-md-4">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-light border-end-0 py-1"><i class="fa fa-search text-muted"></i></span>
                        <input type="text" id="tableSearch" class="form-control border-start-0 py-1" placeholder="Search Emp Code, Name, Aadhar, Account, Status..." onkeyup="filterTableSearch()">
                    </div>
                </div>
                <div class="d-flex flex-wrap gap-1">
                    <button type="button" class="btn btn-gradient-primary btn-sm" data-bs-toggle="modal" data-bs-target="#customExportModal">
                        <i class="fa fa-sliders"></i> Custom Export
                    </button>
                    <button type="button" class="btn btn-gradient-success btn-sm" onclick="exportExcel()">
                        <i class="fa fa-file-excel"></i> Excel
                    </button>
                    <button type="button" class="btn btn-gradient-info btn-sm" onclick="exportCsv()">
                        <i class="fa fa-file-csv"></i> CSV
                    </button>
                    <button type="button" class="btn btn-gradient-danger btn-sm" onclick="exportPdf()">
                        <i class="fa fa-file-pdf"></i> PDF
                    </button>
                    <button type="button" class="btn btn-dark btn-sm" onclick="window.print()">
                        <i class="fa fa-print"></i> Print
                    </button>
                </div>
            </div>

            <!-- Main Data Table -->
            <div class="table-responsive">
                <table class="table table-bordered-custom table-hover align-middle mb-0" id="empMasterTable">
                    <thead>
                        <tr>
                            <th class="text-center" style="width: 60px;">Action</th>
                            <th>Emp Code</th>
                            <th>DOJ</th>
                            <th>Designation</th>
                            <th>Aadhar No</th>
                            <th>Emp Name</th>
                            <th>Father Name</th>
                            <th>Mobile</th>
                            <th>Cluster</th>
                            <th>Zone</th>
                            <th>Circle</th>
                            <th>Div</th>
                            <th>Account No</th>
                            <th>IFSC</th>
                            <th>Branch Name</th>
                            <th>Bank Name</th>
                            <th>DB Status</th>
                        </tr>
                    </thead>
                    <tbody id="empTableBody">
                        <tr>
                            <td colspan="17" class="text-center py-4 text-muted">
                                <i class="fa fa-spinner fa-spin me-2"></i> Loading employee records...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Pagination section -->
            <div id="paginationControls" class="pagination-container d-flex flex-wrap align-items-center justify-content-between gap-2">
                <div class="d-flex align-items-center gap-1">
                    <button class="btn btn-light btn-sm" onclick="prevPage()"><i class="fa fa-chevron-left"></i> Prev</button>
                    <span id="pageInfo" class="badge bg-white text-dark border px-2 py-1">Page 1 of 1</span>
                    <button class="btn btn-light btn-sm" onclick="nextPage()">Next <i class="fa fa-chevron-right"></i></button>
                </div>

                <div class="d-flex align-items-center gap-1">
                    <label for="gotoPage" class="small text-muted mb-0">Jump to:</label>
                    <input type="number" id="gotoPage" class="form-control form-control-sm text-center py-0" style="width:55px; height: 24px;" min="1" />
                    <button class="btn btn-dark btn-sm py-1" onclick="jumpToPage()">Go</button>
                </div>

                <div>
                    <span id="totalBadge" class="badge-total">Total Records: 0</span>
                </div>
            </div>

        </div>
    </div>

    <!-- Edit Employee Modal -->
    <div class="modal fade" id="editEmployeeModal" tabindex="-1" aria-labelledby="editEmployeeModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fs-6 fw-bold text-white" id="editEmployeeModalLabel">
                        <i class="fa fa-user-pen me-2"></i>Edit Employee Details
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="editEmployeeForm" onsubmit="submitEmployeeUpdate(event)">
                    <div class="modal-body p-3">
                        <div class="row g-2">
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Emp Code</label>
                                <input type="text" id="edit_empCode" name="empCode" class="form-control form-control-sm bg-light fw-bold text-primary" readonly required />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Emp Name</label>
                                <input type="text" id="edit_empName" name="empName" class="form-control form-control-sm" required />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Father Name</label>
                                <input type="text" id="edit_fatherName" name="fatherName" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">DOJ (Date of Joining)</label>
                                <input type="text" id="edit_doj" name="doj" class="form-control form-control-sm" placeholder="DD-MM-YYYY / YYYY-MM-DD" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Designation</label>
                                <input type="text" id="edit_designation" name="designation" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Aadhar No</label>
                                <input type="text" id="edit_aadharNo" name="aadharNo" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Mobile No</label>
                                <input type="text" id="edit_mobile" name="mobile" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Cluster</label>
                                <input type="text" id="edit_cluName" name="cluName" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Zone</label>
                                <input type="text" id="edit_zone" name="zone" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Circle</label>
                                <input type="text" id="edit_circle" name="circle" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Division</label>
                                <input type="text" id="edit_div" name="div" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Bank Name</label>
                                <input type="text" id="edit_bankName" name="bankName" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Branch Name</label>
                                <input type="text" id="edit_branchName" name="branchName" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">Account No</label>
                                <input type="text" id="edit_accountNo" name="accountNo" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">IFSC Code</label>
                                <input type="text" id="edit_ifsc" name="ifsc" class="form-control form-control-sm" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label small fw-bold mb-1">DB Status</label>
                                <select id="edit_dbStatus" name="dbStatus" class="form-select form-select-sm fw-semibold">
                                    <option value="Allow">Allow</option>
                                    <option value="Hold">Hold</option>
                                    <option value="Left">Left</option>
                                    <option value="Paid">Paid</option>
                                    <option value="Pending">Pending</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light p-2">
                        <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-gradient-primary btn-sm" id="btnSaveEmployee">
                            <i class="fa fa-check me-1"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Upload Modal -->
    <div class="modal fade" id="uploadModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fs-6 fw-bold text-white" id="uploadModalLabel"><i class="fa fa-cloud-arrow-up me-2"></i>Upload Employee Excel</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/uploadEmployees" method="post" enctype="multipart/form-data" onsubmit="showLoading('Uploading and Merging Employee Records...')">
                    <div class="modal-body p-3">
                        <p class="text-muted small mb-2" style="font-size: 11px;">
                            Upload <code>.xlsx</code> or <code>.xls</code> matching the 16 columns:
                            <br><strong>EMP_CODE, DOJ, DESIGNATION, AADHAR_NO, EMP_NAME, FATHER_NAME, MOBILE, CLU_NAME, ZONE, CIRCLE, DIV, ACCOUNT_NO, IFSC, BRANCH_NAME, BANK_NAME, DB_STATUS</strong>
                        </p>
                        <div class="mb-2">
                            <label class="form-label small fw-bold mb-1">Select Excel File</label>
                            <input type="file" name="excelFile" class="form-control form-control-sm" accept=".xlsx, .xls" required>
                        </div>
                    </div>
                    <div class="modal-footer bg-light p-2">
                        <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-gradient-primary btn-sm"><i class="fa fa-upload me-1"></i> Upload & Merge</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Custom Export Modal -->
    <div class="modal fade" id="customExportModal" tabindex="-1" aria-labelledby="customExportModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fs-6 fw-bold text-white" id="customExportModalLabel"><i class="fa fa-sliders me-2"></i>Custom Column Export</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-3">
                    <div class="mb-2">
                        <label class="form-label small fw-bold mb-1">Export Format</label>
                        <select id="customExportFormat" class="form-select form-select-sm">
                            <option value="xlsx">Excel (.xlsx)</option>
                            <option value="pdf">PDF (.pdf)</option>
                        </select>
                    </div>
                    <label class="form-label small fw-bold mb-1">Select Columns to Include</label>
                    <div class="row g-1" id="columnCheckboxes"></div>
                </div>
                <div class="modal-footer bg-light p-2">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-gradient-primary btn-sm" onclick="exportCustom()">Export Now</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        var contextPath = "${pageContext.request.contextPath}";
        var allRecords = [];
        var filteredRecords = [];
        var currentPage = 1;
        var pageSize = 50;
        var totalPages = 1;

        var tableHeaders = [
            "Emp Code", "DOJ", "Designation", "Aadhar No", "Emp Name", 
            "Father Name", "Mobile", "Cluster", "Zone", "Circle", 
            "Div", "Account No", "IFSC", "Branch Name", "Bank Name", "DB Status"
        ];

        document.addEventListener('DOMContentLoaded', function() {
            initCustomColumnModal();
            fetchEmployeeData();
        });

        function showLoading(msg) {
            var overlay = document.getElementById('loadingOverlay');
            var textEl = document.getElementById('loadingText');
            if (overlay) {
                if (msg && textEl) textEl.textContent = msg;
                overlay.style.display = 'flex';
            }
        }

        function hideLoading() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'none';
        }

        function showClientAlert(msg, isSuccess) {
            var alertBox = document.getElementById('clientAlert');
            var alertText = document.getElementById('clientAlertText');
            if (alertBox && alertText) {
                alertBox.className = 'alert py-1 px-3 mb-2 small alert-dismissible fade show ' + (isSuccess ? 'alert-success' : 'alert-danger');
                alertText.innerHTML = '<i class="fa ' + (isSuccess ? 'fa-check-circle' : 'fa-triangle-exclamation') + ' me-1"></i> ' + msg;
                alertBox.classList.remove('d-none');
                setTimeout(function() { alertBox.classList.add('d-none'); }, 5000);
            }
        }

        function initCustomColumnModal() {
            var container = document.getElementById('columnCheckboxes');
            if (!container) return;
            container.innerHTML = "";
            for (var idx = 0; idx < tableHeaders.length; idx++) {
                var h = tableHeaders[idx];
                var col = document.createElement('div');
                col.className = 'col-6';
                col.innerHTML = '<div class="form-check">' +
                    '<input class="form-check-input custom-col-cb" type="checkbox" value="' + idx + '" id="col_cb_' + idx + '" checked>' +
                    '<label class="form-check-label small" for="col_cb_' + idx + '">' + h + '</label>' +
                    '</div>';
                container.appendChild(col);
            }
        }

        function fetchEmployeeData() {
            var clu = document.getElementById('filterCluster').value;
            var zone = document.getElementById('filterZone').value;
            var circle = document.getElementById('filterCircle').value;
            var div = document.getElementById('filterDivision').value;
            var desig = document.getElementById('filterDesignation').value;
            var dbStatus = document.getElementById('filterDbStatus').value;

            var progressMsg = clu ? ("Loading " + clu + " Data...") : "Fetching Employee Records...";
            showLoading(progressMsg);

            var url = contextPath + '/getEmployeeData?cluName=' + encodeURIComponent(clu) +
                      '&zone=' + encodeURIComponent(zone) +
                      '&circle=' + encodeURIComponent(circle) +
                      '&div=' + encodeURIComponent(div) +
                      '&designation=' + encodeURIComponent(desig) +
                      '&dbStatus=' + encodeURIComponent(dbStatus);

            fetch(url)
                .then(function(res) {
                    if (!res.ok) throw new Error("HTTP error " + res.status);
                    return res.json();
                })
                .then(function(json) {
                    allRecords = json.data || [];
                    applyFiltersLocally();
                    hideLoading();
                })
                .catch(function(err) {
                    console.error("Error fetching data:", err);
                    hideLoading();
                    document.getElementById('empTableBody').innerHTML = 
                        '<tr><td colspan="17" class="text-center py-4 text-danger">' +
                        '<i class="fa fa-triangle-exclamation me-1"></i> Failed to load data from server.' +
                        '</td></tr>';
                });
        }

        function applyFilters() {
            fetchEmployeeData();
        }

        function clearFilters() {
            document.getElementById('filterCluster').value = "";
            document.getElementById('filterZone').value = "";
            document.getElementById('filterCircle').value = "";
            document.getElementById('filterDivision').value = "";
            document.getElementById('filterDesignation').value = "";
            document.getElementById('filterDbStatus').value = "";
            document.getElementById('tableSearch').value = "";
            fetchEmployeeData();
        }

        function filterTableSearch() {
            applyFiltersLocally();
        }

        function applyFiltersLocally() {
            var query = (document.getElementById('tableSearch').value || "").toLowerCase().trim();

            if (!query) {
                filteredRecords = allRecords.slice();
            } else {
                filteredRecords = allRecords.filter(function(r) {
                    return Object.keys(r).some(function(k) {
                        return (r[k] || "").toString().toLowerCase().indexOf(query) !== -1;
                    });
                });
            }

            currentPage = 1;
            renderTablePage();
        }

        /* Helper to get formatted status badge based on DB_STATUS value */
        function getDbStatusBadge(status) {
		    if (!status || status.trim() === '') {
		        return '<span class="status-badge status-badge-other">-</span>';
		    }
		    var s = status.trim();
		    var lower = s.toLowerCase();
		
		    if (lower === 'allow') {
		        return '<span class="status-badge status-badge-allow">' + s + '</span>';
		    } else if (lower === 'left' || lower === 'hold') {
		        return '<span class="status-badge status-badge-hold">' + s + '</span>';
		    } else if (lower === 'paid') {
		        return '<span class="status-badge status-badge-paid">' + s + '</span>';
		    } else {
		        return '<span class="status-badge status-badge-other">' + s + '</span>';
		    }
		}
        function renderTablePage() {
            var tbody = document.getElementById('empTableBody');
            totalPages = Math.max(1, Math.ceil(filteredRecords.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;

            document.getElementById('pageInfo').innerText = 'Page ' + currentPage + ' of ' + totalPages;
            document.getElementById('totalBadge').innerText = 'Total Records: ' + filteredRecords.length;
            var gotoInput = document.getElementById('gotoPage');
            if (gotoInput) gotoInput.value = currentPage;

            if (filteredRecords.length === 0) {
                tbody.innerHTML = '<tr><td colspan="17" class="text-center py-4 text-muted">' +
                    '<i class="fa fa-folder-open fa-2x mb-2 text-secondary opacity-50 d-block"></i>' +
                    'No employee records found.</td></tr>';
                return;
            }

            var start = (currentPage - 1) * pageSize;
            var end = Math.min(filteredRecords.length, start + pageSize);
            var pageData = filteredRecords.slice(start, end);

            var html = "";
            for (var i = 0; i < pageData.length; i++) {
                var r = pageData[i];
                var empCodeSafe = (r.empCode || '').replace(/'/g, "\\'");
                html += '<tr>' +
                    '<td class="text-center">' +
                        '<button type="button" class="btn btn-action-edit" onclick="openEditModal(\'' + empCodeSafe + '\')" title="Edit Employee">' +
                            '<i class="fa fa-pencil"></i>' +
                        '</button>' +
                    '</td>' +
                    '<td><span class="code-badge">' + (r.empCode || '') + '</span></td>' +
                    '<td>' + (r.doj || '') + '</td>' +
                    '<td class="fw-semibold">' + (r.designation || '') + '</td>' +
                    '<td>' + (r.aadharNo || '') + '</td>' +
                    '<td class="fw-bold">' + (r.empName || '') + '</td>' +
                    '<td>' + (r.fatherName || '') + '</td>' +
                    '<td>' + (r.mobile || '') + '</td>' +
                    '<td><span class="badge bg-light text-dark border">' + (r.cluName || '') + '</span></td>' +
                    '<td>' + (r.zone || '') + '</td>' +
                    '<td>' + (r.circle || '') + '</td>' +
                    '<td>' + (r.div || '') + '</td>' +
                    '<td>' + (r.accountNo || '') + '</td>' +
                    '<td><code>' + (r.ifsc || '') + '</code></td>' +
                    '<td>' + (r.branchName || '') + '</td>' +
                    '<td>' + (r.bankName || '') + '</td>' +
                    '<td>' + getDbStatusBadge(r.dbStatus) + '</td>' +
                    '</tr>';
            }
            tbody.innerHTML = html;
        }

        function openEditModal(empCode) {
            var emp = allRecords.find(function(item) {
                return (item.empCode || '').trim() === (empCode || '').trim();
            });

            if (!emp) {
                alert("Employee record not found for code: " + empCode);
                return;
            }

            document.getElementById('edit_empCode').value = emp.empCode || '';
            document.getElementById('edit_empName').value = emp.empName || '';
            document.getElementById('edit_fatherName').value = emp.fatherName || '';
            document.getElementById('edit_doj').value = emp.doj || '';
            document.getElementById('edit_designation').value = emp.designation || '';
            document.getElementById('edit_aadharNo').value = emp.aadharNo || '';
            document.getElementById('edit_mobile').value = emp.mobile || '';
            document.getElementById('edit_cluName').value = emp.cluName || '';
            document.getElementById('edit_zone').value = emp.zone || '';
            document.getElementById('edit_circle').value = emp.circle || '';
            document.getElementById('edit_div').value = emp.div || '';
            document.getElementById('edit_bankName').value = emp.bankName || '';
            document.getElementById('edit_branchName').value = emp.branchName || '';
            document.getElementById('edit_accountNo').value = emp.accountNo || '';
            document.getElementById('edit_ifsc').value = emp.ifsc || '';

            // Set DB_STATUS in select dropdown or fallback to value
            var dbStatusSelect = document.getElementById('edit_dbStatus');
            var currStatus = emp.dbStatus || 'Allow';
            var matchedOption = false;
            for (var optIdx = 0; optIdx < dbStatusSelect.options.length; optIdx++) {
                if (dbStatusSelect.options[optIdx].value.toLowerCase() === currStatus.toLowerCase()) {
                    dbStatusSelect.selectedIndex = optIdx;
                    matchedOption = true;
                    break;
                }
            }
            if (!matchedOption && currStatus) {
                var newOpt = document.createElement('option');
                newOpt.value = currStatus;
                newOpt.textContent = currStatus;
                newOpt.selected = true;
                dbStatusSelect.appendChild(newOpt);
            }

            var editModal = new bootstrap.Modal(document.getElementById('editEmployeeModal'));
            editModal.show();
        }

        function submitEmployeeUpdate(event) {
            event.preventDefault();

            var form = document.getElementById('editEmployeeForm');
            var formData = new FormData(form);
            var params = new URLSearchParams(formData);

            var saveBtn = document.getElementById('btnSaveEmployee');
            saveBtn.disabled = true;
            saveBtn.innerHTML = '<i class="fa fa-spinner fa-spin me-1"></i> Saving...';

            fetch(contextPath + '/updateEmployee', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                body: params.toString()
            })
            .then(function(res) {
                if (!res.ok) throw new Error("HTTP error " + res.status);
                return res.json();
            })
            .then(function(data) {
                saveBtn.disabled = false;
                saveBtn.innerHTML = '<i class="fa fa-check me-1"></i> Save Changes';

                if (data.success) {
                    var modalEl = document.getElementById('editEmployeeModal');
                    var modal = bootstrap.Modal.getInstance(modalEl);
                    if (modal) modal.hide();

                    showClientAlert(data.message, true);

                    var updatedCode = document.getElementById('edit_empCode').value.trim();
                    var recordIdx = allRecords.findIndex(function(r) { return (r.empCode || '').trim() === updatedCode; });
                    if (recordIdx !== -1) {
                        allRecords[recordIdx].empName = document.getElementById('edit_empName').value.trim();
                        allRecords[recordIdx].fatherName = document.getElementById('edit_fatherName').value.trim();
                        allRecords[recordIdx].doj = document.getElementById('edit_doj').value.trim();
                        allRecords[recordIdx].designation = document.getElementById('edit_designation').value.trim();
                        allRecords[recordIdx].aadharNo = document.getElementById('edit_aadharNo').value.trim();
                        allRecords[recordIdx].mobile = document.getElementById('edit_mobile').value.trim();
                        allRecords[recordIdx].cluName = document.getElementById('edit_cluName').value.trim();
                        allRecords[recordIdx].zone = document.getElementById('edit_zone').value.trim();
                        allRecords[recordIdx].circle = document.getElementById('edit_circle').value.trim();
                        allRecords[recordIdx].div = document.getElementById('edit_div').value.trim();
                        allRecords[recordIdx].bankName = document.getElementById('edit_bankName').value.trim();
                        allRecords[recordIdx].branchName = document.getElementById('edit_branchName').value.trim();
                        allRecords[recordIdx].accountNo = document.getElementById('edit_accountNo').value.trim();
                        allRecords[recordIdx].ifsc = document.getElementById('edit_ifsc').value.trim();
                        allRecords[recordIdx].dbStatus = document.getElementById('edit_dbStatus').value.trim();
                    }

                    applyFiltersLocally();
                } else {
                    alert("Update Failed: " + (data.message || "Unknown error"));
                }
            })
            .catch(function(err) {
                saveBtn.disabled = false;
                saveBtn.innerHTML = '<i class="fa fa-check me-1"></i> Save Changes';
                console.error("Update error:", err);
                alert("Network/Server error occurred while updating the employee record: " + err.message);
            });
        }

        function prevPage() {
            if (currentPage > 1) { currentPage--; renderTablePage(); }
        }

        function nextPage() {
            if (currentPage < totalPages) { currentPage++; renderTablePage(); }
        }

        function jumpToPage() {
            var val = parseInt(document.getElementById('gotoPage').value);
            if (!isNaN(val) && val >= 1 && val <= totalPages) {
                currentPage = val;
                renderTablePage();
            }
        }

        /* Export Utilities */
        function getExportRows(selectedIndices) {
            if (!selectedIndices) {
                selectedIndices = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
            }
            var headers = selectedIndices.map(function(idx) { return tableHeaders[idx]; });
            var rows = filteredRecords.map(function(r) {
                var fullRow = [
                    r.empCode || '', r.doj || '', r.designation || '', r.aadharNo || '',
                    r.empName || '', r.fatherName || '', r.mobile || '', r.cluName || '',
                    r.zone || '', r.circle || '', r.div || '', r.accountNo || '',
                    r.ifsc || '', r.branchName || '', r.bankName || '', r.dbStatus || ''
                ];
                return selectedIndices.map(function(idx) { return fullRow[idx]; });
            });
            return { headers: headers, rows: rows };
        }

        function exportExcel() {
            if (filteredRecords.length === 0) { alert("No data available to export."); return; }
            var exp = getExportRows();
            var sheetData = [exp.headers].concat(exp.rows);
            var ws = XLSX.utils.aoa_to_sheet(sheetData);
            var wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Employees");
            XLSX.writeFile(wb, "Employee_Master_Report.xlsx");
        }

        function exportCsv() {
            if (filteredRecords.length === 0) { alert("No data available to export."); return; }
            var exp = getExportRows();
            var sheetData = [exp.headers].concat(exp.rows);
            var ws = XLSX.utils.aoa_to_sheet(sheetData);
            var csv = XLSX.utils.sheet_to_csv(ws);
            var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            var link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = "Employee_Master_Report.csv";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        function exportPdf() {
            if (filteredRecords.length === 0) { alert("No data available to export."); return; }
            var jsPDF = window.jspdf.jsPDF;
            var doc = new jsPDF({ orientation: "landscape" });
            var exp = getExportRows();

            doc.setFontSize(14);
            doc.text("Employee Master Report", 14, 14);

            doc.autoTable({
                head: [exp.headers],
                body: exp.rows,
                startY: 18,
                styles: { fontSize: 7.5 },
                headStyles: { fillColor: [15, 23, 42] }
            });

            doc.save("Employee_Master_Report.pdf");
        }

        function exportCustom() {
            if (filteredRecords.length === 0) { alert("No data available to export."); return; }
            var cbs = document.querySelectorAll('.custom-col-cb:checked');
            var selectedIndices = Array.prototype.map.call(cbs, function(cb) { return parseInt(cb.value); });

            if (selectedIndices.length === 0) {
                alert("Please select at least one column.");
                return;
            }

            var format = document.getElementById('customExportFormat').value;
            var exp = getExportRows(selectedIndices);

            if (format === 'pdf') {
                var jsPDF = window.jspdf.jsPDF;
                var doc = new jsPDF({ orientation: "landscape" });
                doc.setFontSize(14);
                doc.text("Custom Employee Master Report", 14, 14);
                doc.autoTable({
                    head: [exp.headers],
                    body: exp.rows,
                    startY: 18,
                    styles: { fontSize: 8 },
                    headStyles: { fillColor: [15, 23, 42] }
                });
                doc.save("Custom_Employee_Report.pdf");
            } else {
                var sheetData = [exp.headers].concat(exp.rows);
                var ws = XLSX.utils.aoa_to_sheet(sheetData);
                var wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "CustomEmployees");
                XLSX.writeFile(wb, "Custom_Employee_Report.xlsx");
            }

            var modalEl = document.getElementById('customExportModal');
            var modal = bootstrap.Modal.getInstance(modalEl);
            if (modal) modal.hide();
        }
    </script>
</body>
</html>