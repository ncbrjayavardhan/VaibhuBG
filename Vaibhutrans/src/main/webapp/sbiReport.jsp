<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.vaibhutrans.model.BomTransaction" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
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
    <title>SBI Bank Statement Report - Vaibhutrans</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- SheetJS Library for Client-Side Excel Export -->
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>

    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #0284c7 0%, #2563eb 100%);
            --card-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --border-color: #cbd5e1;
        }

        * { 
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        body { 
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #0369a1 100%);
            min-height: 100vh;
            color: #1e293b;
            padding-bottom: 40px;
        }

        .report-card { 
            padding: 32px; 
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 20px; 
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-top: 24px;
        }

        .header-title-container {
            border-bottom: 2px dashed #e2e8f0;
            padding-bottom: 24px;
            margin-bottom: 24px;
        }

        .report-title { 
            font-weight: 800; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 30px;
            letter-spacing: -0.8px;
        }

        /* KPI Visual Summaries */
        .kpi-card {
            background: #ffffff;
            border-radius: 12px;
            padding: 14px 20px;
            border: 1px solid var(--border-color);
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
        }
        
        .kpi-title {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.5px;
        }

        .kpi-value {
            font-size: 18px;
            font-weight: 700;
            color: #0f172a;
        }

        /* Filters styling */
        .filters-panel { 
            background: #f8fafc;
            padding: 24px;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
        }

        .form-floating > .form-control,
        .form-floating > .form-select {
            height: calc(3.2rem + 2px);
            padding: 1rem 0.75rem;
            font-size: 13.5px;
            font-weight: 500;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
        }

        .form-floating > label {
            padding: 0.8rem 0.75rem;
            font-size: 12px;
            color: #64748b;
        }

        .form-control:focus, .form-select:focus {
            border-color: #0284c7;
            box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.15);
        }

        /* Actions Bar */
        .actions-bar {
            background: #ffffff;
            padding: 12px 20px;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
        }

        /* Button styling */
        .btn { 
            border-radius: 8px; 
            font-weight: 600; 
            border: none; 
            padding: 8px 16px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }
        
        .btn-gradient-primary { 
            background: var(--primary-gradient); 
            color: white; 
        }
        .btn-gradient-success { 
            background: linear-gradient(135deg, #10b981 0%, #059669 100%); 
            color: white; 
        }
        .btn-gradient-danger { 
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); 
            color: white; 
        }
        .btn-gradient-info { 
            background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); 
            color: white; 
        }
        .btn-dark { background: #0f172a; color: white; }
        .btn-light { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-light:hover { background: #e2e8f0; }

        /* TABLE STYLING */
        .table-responsive { 
            margin-top: 20px;
            border-radius: 12px;
            overflow-x: auto; 
            overflow-y: visible;
            box-shadow: var(--card-shadow);
            border: 2px solid var(--border-color);
        }
        
        .table-bordered-custom {
            margin-bottom: 0;
            border-collapse: separate !important;
            border-spacing: 0;
            background: #ffffff;
            width: 100%;
            min-width: 1200px;
        }
        
        .table-bordered-custom th,
        .table-bordered-custom td {
            border: 1px solid var(--border-color) !important;
            padding: 12px 14px;
            font-size: 13px;
            vertical-align: middle;
            white-space: nowrap;
        }
        
        .table-bordered-custom td.text-wrap {
            white-space: normal;
            min-width: 220px;
        }

        .table-bordered-custom thead th { 
            background: #0f172a;
            color: #f8fafc;
            border: 1px solid #334155 !important;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 11px;
            letter-spacing: 0.8px;
            text-align: left;
        }

        .table-bordered-custom tbody tr:hover {
            background-color: #f1f5f9;
        }

        .debit-amount { color: #dc2626; font-weight: 600; }
        .credit-amount { color: #16a34a; font-weight: 600; }
        .balance-amount { font-weight: 700; color: #0f172a; }

        .utr-badge {
            background: #e0f2fe;
            color: #0369a1;
            font-family: monospace;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            border: 1px solid #bae6fd;
        }

        .pagination-container {
            margin-top: 24px;
            padding: 16px 24px;
            background: #f8fafc;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
        }

        .badge-total {
            background: var(--primary-gradient);
            padding: 8px 16px;
            font-weight: 700;
            border-radius: 30px;
            color: white;
            font-size: 13px;
        }

        .modal-content {
            border-radius: 16px;
            border: none;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .modal-header {
            background: var(--primary-gradient);
            color: white;
            border-bottom: none;
            padding: 20px 24px;
        }

        /* Drag and Drop Visual Feedback */
        .list-group-item {
            border: 1px solid #e2e8f0;
            border-radius: 8px !important;
            margin-bottom: 8px;
            background: #ffffff;
            padding: 12px 16px;
            user-select: none;
            transition: transform 0.15s ease, background-color 0.15s ease, box-shadow 0.15s ease;
        }

        .drag-handle {
            cursor: grab;
            color: #94a3b8;
            margin-right: 12px;
            padding: 4px 6px;
        }

        .drag-handle:active {
            cursor: grabbing;
        }

        .list-group-item.dragging {
            opacity: 0.5;
            background-color: #e0f2fe;
            border: 2px dashed #0284c7;
        }

        .list-group-item.drag-over {
            border-top: 3px solid #0284c7;
            background-color: #f1f5f9;
        }
    </style>
</head>
<body>
<jsp:include page="navbar.jsp" />
    <div class="container-fluid px-4 mt-4">
        <div class="report-card">
            
            <!-- Header section -->
            <div class="d-flex flex-wrap justify-content-between align-items-center header-title-container gap-3">
                <div class="d-flex align-items-center gap-3">
                    <div class="p-3 bg-light rounded-3 text-primary border">
                        <i class="fa fa-university fa-2x"></i>
                    </div>
                    <div>
                        <h3 class="report-title mb-0">SBI Bank Statement</h3>
                        <p class="text-muted small mb-0">Manage, filter, and export State Bank of India transaction reports</p>
                    </div>
                </div>
            </div>

            <!-- KPI Summary Bar -->
            <div class="row g-3 mb-4">
                <div class="col-12 col-md-4">
                    <div class="kpi-card">
                        <div class="kpi-title">Total Debits</div>
                        <div class="kpi-value text-danger" id="kpiTotalDebit">₹0.00</div>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="kpi-card">
                        <div class="kpi-title">Total Credits</div>
                        <div class="kpi-value text-success" id="kpiTotalCredit">₹0.00</div>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="kpi-card">
                        <div class="kpi-title">Filtered Balance</div>
                        <div class="kpi-value text-primary" id="kpiNetBalance">₹0.00</div>
                    </div>
                </div>
            </div>

            <!-- Interactive Filters -->
            <div class="filters-panel mb-4">
                <div class="row g-3">
                    <div class="col-md-3">
                        <div class="form-floating">
                            <select id="filterAccountNo" class="form-select" onchange="applyFilters()">
                                <option value="">All Accounts of SBI</option>
                            </select>
                            <label for="filterAccountNo"><i class="fa fa-wallet me-1"></i> Account No</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="text" id="filterUtr" class="form-control" oninput="applyFilters()" placeholder="UTR / Ref No" />
                            <label for="filterUtr"><i class="fa fa-search me-1"></i> UTR or Ref No</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="text" id="filterBenf" class="form-control" oninput="applyFilters()" placeholder="Beneficiary name" />
                            <label for="filterBenf"><i class="fa fa-user me-1"></i> Beneficiary Name</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="date" id="filterDateFrom" class="form-control" onchange="applyFilters()" />
                            <label for="filterDateFrom">From Date</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="date" id="filterDateTo" class="form-control" onchange="applyFilters()" />
                            <label for="filterDateTo">To Date</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="number" id="filterAmtMin" class="form-control" oninput="applyFilters()" step="0.01" placeholder="Min Amount" />
                            <label for="filterAmtMin">Min Amount (₹)</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="number" id="filterAmtMax" class="form-control" oninput="applyFilters()" step="0.01" placeholder="Max Amount" />
                            <label for="filterAmtMax">Max Amount (₹)</label>
                        </div>
                    </div>
                    <div class="col-md-3 d-flex align-items-center justify-content-end gap-2">
                        <button type="button" class="btn btn-light py-3 px-4 w-100" onclick="clearFilters()" title="Reset all filters">
                            <i class="fa fa-rotate-right me-1"></i> Reset Filters
                        </button>
                    </div>
                </div>
            </div>

            <!-- Data Export Toolbar (5 Export Options) -->
            <div class="actions-bar d-flex flex-wrap align-items-center justify-content-between mb-3 gap-2">
                <span class="text-muted small fw-semibold"><i class="fa fa-download me-1"></i> Quick Export Options</span>
                <div class="d-flex gap-2">
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
                    <button type="button" class="btn btn-dark btn-sm" onclick="printReport()">
                        <i class="fa fa-print"></i> Print
                    </button>
                </div>
            </div>

            <!-- Main Data Table -->
            <div class="table-responsive">
                <table class="table table-bordered-custom table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Particulars</th>
                            <th>UTR No</th>
                            <th>Beneficiary</th>
                            <th>IFSC</th>
                            <th>Ref No</th>
                            <th class="text-end">Debit</th>
                            <th class="text-end">Credit</th>
                            <th class="text-end">Balance</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            List<BomTransaction> list = (List<BomTransaction>) request.getAttribute("sbiTransactions");
                            if (list == null) {
                                list = (List<BomTransaction>) request.getAttribute("bomTransactions");
                            }
                            int sbiCount = 0;
                            if (list != null && !list.isEmpty()) {
                                for (BomTransaction tx : list) {
                                    String bankName = tx.getBankName();
                                    if (bankName == null || !"SBI".equalsIgnoreCase(bankName.trim())) {
                                        continue;
                                    }
                                    sbiCount++;
                                    String utr = tx.getUtrNo();
                                    boolean hasValidUtr = (utr != null && !utr.trim().isEmpty() && !utr.startsWith("KEY_") && !utr.startsWith("NO_UTR_"));
                                    String accNo = tx.getAccountNo() != null ? tx.getAccountNo().trim() : "";
                        %>
                        <tr data-account-no="<%= accNo %>">
                            <td class="fw-medium text-nowrap"><%= tx.getTxDate() != null ? tx.getTxDate() : "" %></td>
                            <td><span class="badge bg-light text-dark border"><%= tx.getType() != null ? tx.getType() : "" %></span></td>
                            <td class="text-wrap" style="max-width:260px"><%= tx.getParticulars() != null ? tx.getParticulars() : "" %></td>
                            <td>
                                <% if(hasValidUtr) { %>
                                    <span class="utr-badge"><%= utr %></span>
                                <% } %>
                            </td>
                            <td class="fw-semibold"><%= tx.getBeneficiaryName() != null ? tx.getBeneficiaryName() : "" %></td>
                            <td><code class="text-secondary"><%= tx.getIfscCode() != null ? tx.getIfscCode() : "" %></code></td>
                            <td><small class="text-muted"><%= tx.getRefNo() != null ? tx.getRefNo() : "" %></small></td>
                            <td class="text-end debit-amount"><%= String.format("%.2f", tx.getDebit()) %></td>
                            <td class="text-end credit-amount"><%= String.format("%.2f", tx.getCredit()) %></td>
                            <td class="text-end balance-amount"><%= String.format("%.2f", tx.getBalance()) %></td>
                        </tr>
                        <% 
                                }
                            }
                            if (sbiCount == 0) {
                        %>
                        <tr>
                            <td colspan="10" class="text-center py-5 text-muted">
                                <i class="fa fa-folder-open fa-3x mb-3 text-secondary opacity-50 d-block"></i>
                                No State Bank of India (SBI) transactions found.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Pagination section -->
            <div id="paginationControls" class="pagination-container d-flex flex-wrap align-items-center justify-content-between gap-3">
                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-light btn-sm" onclick="prevPage()"><i class="fa fa-chevron-left"></i> Prev</button>
                    <span id="pageInfo" class="badge bg-white text-dark border px-3 py-2">Page 1 of 1</span>
                    <button class="btn btn-light btn-sm" onclick="nextPage()">Next <i class="fa fa-chevron-right"></i></button>
                </div>
                
                <div class="d-flex align-items-center gap-2">
                    <label for="gotoPage" class="small text-muted mb-0">Jump to:</label>
                    <input type="number" id="gotoPage" class="form-control form-control-sm text-center" style="width:70px" min="1" />
                    <button class="btn btn-dark btn-sm" onclick="jumpToPage()">Go</button>
                </div>

                <div>
                    <span id="totalBadge" class="badge-total">Total Records: 0</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Custom Export Modal -->
    <div class="modal fade" id="customExportModal" tabindex="-1" aria-labelledby="customExportModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title font-semibold" id="customExportModalLabel"><i class="fa fa-sliders me-2"></i>Custom Export Options</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body p-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <p class="text-muted small mb-0">Select columns and drag or use arrows to rearrange column position:</p>
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-outline-primary" onclick="selectAllExcelCols(true)">Select All</button>
                    <button type="button" class="btn btn-outline-secondary" onclick="selectAllExcelCols(false)">Deselect All</button>
                </div>
            </div>
            
            <ul class="list-group" id="columnOrderList">
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="0" data-col-key="Date">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_date">
                  <label class="form-check-label fw-semibold" for="col_date">Date</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="1" data-col-key="Type">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_type">
                  <label class="form-check-label fw-semibold" for="col_type">Type</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="2" data-col-key="Particulars">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_particulars">
                  <label class="form-check-label fw-semibold" for="col_particulars">Particulars</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="3" data-col-key="UTR No">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_utr">
                  <label class="form-check-label fw-semibold" for="col_utr">UTR No</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="4" data-col-key="Beneficiary Name">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_benf">
                  <label class="form-check-label fw-semibold" for="col_benf">Beneficiary Name</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="5" data-col-key="IFSC">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_ifsc">
                  <label class="form-check-label fw-semibold" for="col_ifsc">IFSC</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="6" data-col-key="Ref No">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_ref">
                  <label class="form-check-label fw-semibold" for="col_ref">Ref No</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="7" data-col-key="Debit">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_debit">
                  <label class="form-check-label fw-semibold" for="col_debit">Debit</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="8" data-col-key="Credit">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_credit">
                  <label class="form-check-label fw-semibold" for="col_credit">Credit</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-index="9" data-col-key="Balance">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_balance">
                  <label class="form-check-label fw-semibold" for="col_balance">Balance</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" draggable="true" data-col-key="Amount">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-3 col-checkbox" type="checkbox" checked id="col_amt">
                  <label class="form-check-label fw-semibold" for="col_amt">Amount (Max Debit/Credit)</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-2" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
            </ul>
          </div>
          <div class="modal-footer bg-light justify-content-between">
            <button type="button" class="btn btn-light border" data-bs-dismiss="modal">Cancel</button>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-gradient-success" onclick="downloadCustomExcel()">
                    <i class="fa fa-file-excel me-1"></i> Excel
                </button>
                <button type="button" class="btn btn-gradient-danger" onclick="downloadCustomPdf()">
                    <i class="fa fa-file-pdf me-1"></i> PDF
                </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function parseDateString(s) {
            if (!s) return null;
            s = s.trim();

            var dmy = /^(\d{2})[\/\-](\d{2})[\/\-](\d{4})$/;
            var iso = /^(\d{4})[\/\-](\d{2})[\/\-](\d{2})$/;

            var d = null;

            if (dmy.test(s)) {
                var match = s.match(dmy);
                var day = parseInt(match[1], 10);
                var month = parseInt(match[2], 10) - 1; 
                var year = parseInt(match[3], 10);
                d = new Date(year, month, day);
            } else if (iso.test(s)) {
                var match = s.match(iso);
                d = new Date(parseInt(match[1], 10), parseInt(match[2], 10) - 1, parseInt(match[3], 10));
            } else {
                d = new Date(s);
            }

            if (!d || isNaN(d.getTime())) return null;
            d.setHours(0, 0, 0, 0);
            return d;
        }

        var currentPage = 1;
        var pageSize = 50;
        var totalPages = 1;

        function updateKPIMetrics(matchedRows) {
            var totalDebit = 0;
            var totalCredit = 0;

            matchedRows.forEach(function(r) {
                var debitText = (r.cells[7].innerText || r.cells[7].textContent).replace(/,/g, '').trim();
                var creditText = (r.cells[8].innerText || r.cells[8].textContent).replace(/,/g, '').trim();
                totalDebit += parseFloat(debitText) || 0;
                totalCredit += parseFloat(creditText) || 0;
            });

            document.getElementById('kpiTotalDebit').textContent = '₹' + totalDebit.toLocaleString('en-IN', {minimumFractionDigits: 2});
            document.getElementById('kpiTotalCredit').textContent = '₹' + totalCredit.toLocaleString('en-IN', {minimumFractionDigits: 2});
            document.getElementById('kpiNetBalance').textContent = '₹' + (totalCredit - totalDebit).toLocaleString('en-IN', {minimumFractionDigits: 2});
        }

        function populateSbiAccountDropdown() {
            var select = document.getElementById('filterAccountNo');
            if (!select) return;

            select.options.length = 1;

            var rows = document.querySelectorAll('table tbody tr');
            var accountSet = new Set();

            rows.forEach(function(r) {
                var acc = r.dataset.accountNo ? r.dataset.accountNo.trim() : '';
                if (acc && acc !== 'N/A' && acc !== 'UNKNOWN' && acc !== '') {
                    accountSet.add(acc);
                }
            });

            accountSet.forEach(function(accNo) {
                var opt = document.createElement('option');
                opt.value = accNo;
                opt.textContent = accNo;
                select.appendChild(opt);
            });
        }

        function applyFilters() {
            currentPage = 1;

            var selectedAccount = (document.getElementById('filterAccountNo') ? document.getElementById('filterAccountNo').value : '').trim();
            var utr = document.getElementById('filterUtr').value.trim().toLowerCase();
            var benf = document.getElementById('filterBenf').value.trim().toLowerCase();
            var dateFromVal = document.getElementById('filterDateFrom').value;
            var dateToVal = document.getElementById('filterDateTo').value;
            var amtMin = parseFloat(document.getElementById('filterAmtMin').value);
            var amtMax = parseFloat(document.getElementById('filterAmtMax').value);

            var dateFrom = null;
            if (dateFromVal) {
                var pFrom = dateFromVal.split('-');
                dateFrom = new Date(parseInt(pFrom[0], 10), parseInt(pFrom[1], 10) - 1, parseInt(pFrom[2], 10));
                dateFrom.setHours(0, 0, 0, 0);
            }

            var dateTo = null;
            if (dateToVal) {
                var pTo = dateToVal.split('-');
                dateTo = new Date(parseInt(pTo[0], 10), parseInt(pTo[1], 10) - 1, parseInt(pTo[2], 10));
                dateTo.setHours(23, 59, 59, 999);
            }

            var table = document.querySelector('table');
            if (!table || !table.tBodies || !table.tBodies[0]) return;
            
            var rows = table.tBodies[0].rows;

            if (rows.length === 1 && rows[0].cells.length === 1) return;

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                
                var rowAccount = r.dataset.accountNo ? r.dataset.accountNo.trim() : '';
                var dateText = r.cells[0].innerText || r.cells[0].textContent;
                var utrText = (r.cells[3].innerText || r.cells[3].textContent).toLowerCase();
                var benfText = (r.cells[4].innerText || r.cells[4].textContent).toLowerCase();
                var refText = (r.cells[6].innerText || r.cells[6].textContent).toLowerCase();
                
                var debitText = (r.cells[7].innerText || r.cells[7].textContent).replace(/,/g, '').trim();
                var creditText = (r.cells[8].innerText || r.cells[8].textContent).replace(/,/g, '').trim();
                
                var debitAmt = parseFloat(debitText) || 0;
                var creditAmt = parseFloat(creditText) || 0;
                var txAmt = Math.max(debitAmt, creditAmt);

                var show = true;

                if (selectedAccount.length > 0 && rowAccount !== selectedAccount) show = false;
                if (show && utr && utr.length > 0 && utrText.indexOf(utr) === -1 && refText.indexOf(utr) === -1) show = false;
                if (show && benf && benf.length > 0 && benfText.indexOf(benf) === -1) show = false;
                if (show && (dateFrom || dateTo)) {
                    var d = parseDateString(dateText);
                    if (!d) {
                        show = false;
                    } else {
                        if (dateFrom && d < dateFrom) show = false;
                        if (dateTo && d > dateTo) show = false;
                    }
                }
                if (show && !isNaN(amtMin) && txAmt < amtMin) show = false;
                if (show && !isNaN(amtMax) && txAmt > amtMax) show = false;

                r.dataset.matched = show ? '1' : '0';
                r.style.display = 'none';
            }

            updatePagination();
        }

        function clearFilters() {
            var accSelect = document.getElementById('filterAccountNo');
            if (accSelect) accSelect.value = '';

            document.getElementById('filterUtr').value = '';
            document.getElementById('filterBenf').value = '';
            document.getElementById('filterDateFrom').value = '';
            document.getElementById('filterDateTo').value = '';
            document.getElementById('filterAmtMin').value = '';
            document.getElementById('filterAmtMax').value = '';

            applyFilters();
        }

        function updatePagination() {
            var table = document.querySelector('table');
            var rows = table.tBodies[0].rows;
            var matched = [];
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].dataset.matched === '1') matched.push(rows[i]);
            }
            
            updateKPIMetrics(matched);

            totalPages = Math.max(1, Math.ceil(matched.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;

            for (var i = 0; i < rows.length; i++) {
                rows[i].style.display = 'none';
            }
            var start = (currentPage - 1) * pageSize;
            var end = Math.min(matched.length, start + pageSize);
            for (var j = start; j < end; j++) {
                matched[j].style.display = '';
            }
            renderPaginationControls(matched.length);
        }

        function initializeReport() {
            var table = document.querySelector('table');
            if (!table) return;
            var rows = table.tBodies[0].rows;
            for (var i = 0; i < rows.length; i++) {
                rows[i].dataset.matched = '1';
                rows[i].style.display = 'none';
            }
            currentPage = 1;
            updatePagination();
        }

        function enableDragAndDrop() {
            const list = document.getElementById('columnOrderList');
            let draggedItem = null;

            list.querySelectorAll('.list-group-item').forEach(item => {
                item.addEventListener('dragstart', function (e) {
                    draggedItem = this;
                    setTimeout(() => this.classList.add('dragging'), 0);
                });

                item.addEventListener('dragend', function () {
                    draggedItem = null;
                    this.classList.remove('dragging');
                    list.querySelectorAll('.list-group-item').forEach(i => i.classList.remove('drag-over'));
                });

                item.addEventListener('dragover', function (e) {
                    e.preventDefault();
                    if (this !== draggedItem) {
                        this.classList.add('drag-over');
                    }
                });

                item.addEventListener('dragleave', function () {
                    this.classList.remove('drag-over');
                });

                item.addEventListener('drop', function (e) {
                    e.preventDefault();
                    this.classList.remove('drag-over');
                    
                    if (draggedItem && this !== draggedItem) {
                        const items = Array.from(list.children);
                        const draggedIndex = items.indexOf(draggedItem);
                        const targetIndex = items.indexOf(this);

                        if (draggedIndex < targetIndex) {
                            list.insertBefore(draggedItem, this.nextSibling);
                        } else {
                            list.insertBefore(draggedItem, this);
                        }
                    }
                });
            });
        }

        document.addEventListener('DOMContentLoaded', function() {
            initializeReport();
            populateSbiAccountDropdown();
            enableDragAndDrop();
        });

        function renderPaginationControls(totalItems) {
            var info = document.getElementById('pageInfo');
            info.textContent = 'Page ' + currentPage + ' of ' + totalPages;
            var totalBadge = document.getElementById('totalBadge');
            if (totalBadge) totalBadge.textContent = 'Total Records: ' + totalItems;
            var goto = document.getElementById('gotoPage');
            goto.value = currentPage;
        }

        function prevPage() {
            if (currentPage > 1) {
                currentPage--;
                updatePagination();
            }
        }

        function nextPage() {
            if (currentPage < totalPages) {
                currentPage++;
                updatePagination();
            }
        }

        function jumpToPage() {
            var v = parseInt(document.getElementById('gotoPage').value);
            if (!isNaN(v) && v >= 1 && v <= totalPages) {
                currentPage = v;
                updatePagination();
            }
        }

        function moveColumn(btn, direction) {
            var item = btn.closest('li');
            if (direction === -1 && item.previousElementSibling) {
                item.parentNode.insertBefore(item, item.previousElementSibling);
            } else if (direction === 1 && item.nextElementSibling) {
                item.parentNode.insertBefore(item.nextElementSibling, item);
            }
        }

        function selectAllExcelCols(status) {
            var checkboxes = document.querySelectorAll('#columnOrderList .col-checkbox');
            checkboxes.forEach(function(cb) {
                cb.checked = status;
            });
        }

        function getCustomSelectedColumns() {
            var listItems = document.querySelectorAll('#columnOrderList li');
            var selectedColumns = [];

            listItems.forEach(function(li) {
                var checkbox = li.querySelector('.col-checkbox');
                if (checkbox.checked) {
                    selectedColumns.push({
                        key: li.getAttribute('data-col-key'),
                        colIndex: li.hasAttribute('data-col-index') ? parseInt(li.getAttribute('data-col-index'), 10) : null
                    });
                }
            });

            return selectedColumns;
        }

        function downloadCustomExcel() {
            var selectedColumns = getCustomSelectedColumns();

            if (selectedColumns.length === 0) {
                alert('Please select at least one column to export.');
                return;
            }

            var excelData = [];
            var headers = selectedColumns.map(function(col) { return col.key; });
            excelData.push(headers);

            var table = document.querySelector('table');
            var rows = table.tBodies[0].rows;

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                if (r.dataset.matched !== '1' || (rows.length === 1 && r.cells.length === 1)) continue;

                var rowData = [];
                selectedColumns.forEach(function(col) {
                    if (col.key === 'Amount') {
                        var debitStr = (r.cells[7].innerText || r.cells[7].textContent).replace(/,/g, '').trim();
                        var creditStr = (r.cells[8].innerText || r.cells[8].textContent).replace(/,/g, '').trim();
                        var debit = parseFloat(debitStr) || 0;
                        var credit = parseFloat(creditStr) || 0;
                        rowData.push(Math.max(debit, credit));
                    } else if (col.colIndex !== null) {
                        var cellText = (r.cells[col.colIndex].innerText || r.cells[col.colIndex].textContent).trim();
                        if (col.key === 'Debit' || col.key === 'Credit' || col.key === 'Balance') {
                            var numVal = parseFloat(cellText.replace(/,/g, ''));
                            rowData.push(isNaN(numVal) ? cellText : numVal);
                        } else {
                            rowData.push(cellText);
                        }
                    }
                });

                excelData.push(rowData);
            }

            var worksheet = XLSX.utils.aoa_to_sheet(excelData);
            var workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, "SBI Statement");

            var colWidths = headers.map(function(h) { return { wch: Math.max(h.length + 5, 18) }; });
            worksheet['!cols'] = colWidths;

            XLSX.writeFile(workbook, "sbi_transactions_custom_report.xlsx");

            var modalElement = document.getElementById('customExportModal');
            var modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) modal.hide();
        }

        function downloadCustomPdf() {
            var selectedColumns = getCustomSelectedColumns();

            if (selectedColumns.length === 0) {
                alert('Please select at least one column to export.');
                return;
            }

            var table = document.querySelector('table');
            var rows = table.tBodies[0].rows;

            var win = window.open('', '_blank');
            var html = '<!doctype html><html><head><title>SBI Custom Report</title>' +
                '<style>body{font-family:"Plus Jakarta Sans",Arial,sans-serif;margin:20px}table{width:100%;border-collapse:collapse}th,td{border:1px solid #cbd5e1;padding:8px;text-align:left;font-size:11px}th{background:#f1f5f9;color:#0f172a}.text-end{text-align:right}</style>' +
                '</head><body>';
            html += '<h3 style="color:#0f172a;">SBI Custom Transactions Report</h3>';
            html += '<table><thead><tr>' + selectedColumns.map(function(col){ return '<th>' + col.key + '</th>'; }).join('') + '</tr></thead><tbody>';

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                if (r.dataset.matched !== '1' || (rows.length === 1 && r.cells.length === 1)) continue;

                html += '<tr>';
                selectedColumns.forEach(function(col) {
                    var alignClass = (col.key === 'Debit' || col.key === 'Credit' || col.key === 'Balance' || col.key === 'Amount') ? ' class="text-end"' : '';
                    if (col.key === 'Amount') {
                        var debitStr = (r.cells[7].innerText || r.cells[7].textContent).replace(/,/g, '').trim();
                        var creditStr = (r.cells[8].innerText || r.cells[8].textContent).replace(/,/g, '').trim();
                        var debit = parseFloat(debitStr) || 0;
                        var credit = parseFloat(creditStr) || 0;
                        html += '<td' + alignClass + '>' + Math.max(debit, credit).toFixed(2) + '</td>';
                    } else if (col.colIndex !== null) {
                        var cellText = (r.cells[col.colIndex].innerText || r.cells[col.colIndex].textContent).trim();
                        html += '<td' + alignClass + '>' + cellText + '</td>';
                    }
                });
                html += '</tr>';
            }

            html += '</tbody></table></body></html>';
            win.document.write(html);
            win.document.close();

            var modalElement = document.getElementById('customExportModal');
            var modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) modal.hide();

            setTimeout(function(){ win.print(); }, 500);
        }

        function getAllMatchedRowsData() {
            var table = document.querySelector('table');
            var rows = table.tBodies[0].rows;
            var data = [];
            var headers = [];
            var ths = table.tHead.rows[0].cells;
            for (var h = 0; h < ths.length; h++) headers.push(ths[h].innerText.trim());
            data.push(headers);
            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                if (r.dataset.matched !== '1' || (rows.length === 1 && r.cells.length === 1)) continue;
                var rowData = [];
                for (var c = 0; c < r.cells.length; c++) {
                    rowData.push((r.cells[c].innerText || r.cells[c].textContent).trim());
                }
                data.push(rowData);
            }
            return data;
        }

        function exportExcel() {
            var data = getAllMatchedRowsData();
            var ws = XLSX.utils.aoa_to_sheet(data);
            var wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "SBI Statement");
            XLSX.writeFile(wb, "sbi_transactions_report.xlsx");
        }

        function exportCsv() {
            var data = getAllMatchedRowsData();
            var csv = data.map(function(row) {
                return row.map(function(cell) {
                    if (cell == null) return '';
                    var s = String(cell).replace(/"/g, '""');
                    if (s.search(/[,"\n]/) >= 0) s = '"' + s + '"';
                    return s;
                }).join(',');
            }).join('\n');

            var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'sbi_transactions_report.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        function exportPdf() {
            var data = getAllMatchedRowsData();
            var win = window.open('', '_blank');
            var html = '<!doctype html><html><head><title>SBI Transactions Report</title>' +
                '<style>body{font-family:"Plus Jakarta Sans",Arial,sans-serif;margin:20px}table{width:100%;border-collapse:collapse}th,td{border:1px solid #cbd5e1;padding:8px;text-align:left;font-size:11px}th{background:#f1f5f9;color:#0f172a} td.text-end{text-align:right}</style>' +
                '</head><body>';
            html += '<h3 style="color:#0f172a;">SBI Transactions Report</h3>';
            html += '<table><thead><tr>' + data[0].map(function(h){return '<th>'+h+'</th>'}).join('') + '</tr></thead><tbody>';
            for (var i = 1; i < data.length; i++) {
                html += '<tr>' + data[i].map(function(cell, idx){
                    var alignClass = (idx >= 7) ? ' class="text-end"' : '';
                    return '<td' + alignClass + '>'+cell+'</td>';
                }).join('') + '</tr>';
            }
            html += '</tbody></table></body></html>';
            win.document.write(html);
            win.document.close();
            setTimeout(function(){ win.print(); }, 500);
        }

        function printReport() {
            exportPdf();
        }
    </script>
</body>
</html>