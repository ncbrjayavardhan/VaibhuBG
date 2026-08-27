<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, com.vaibhutrans.model.BankDetail" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
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
    <title>Bank Details Master Report - Vaibhutrans</title>
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
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --card-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -2px rgba(0, 0, 0, 0.01);
            --glass-bg: rgba(255, 255, 255, 0.95);
            --border-color: #cbd5e1;
        }

        * { 
            transition: all 0.15s ease-in-out;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }

        body { 
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            color: #1e293b;
            padding-bottom: 15px;
        }

        .report-card { 
            padding: 16px; 
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 12px; 
            box-shadow: 0 15px 30px -10px rgba(0, 0, 0, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-top: 10px;
        }

        .header-title-container {
            border-bottom: 1px dashed #cbd5e1;
            padding-bottom: 10px;
            margin-bottom: 12px;
        }

        .report-title { 
            font-weight: 800; 
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 22px;
            letter-spacing: -0.5px;
        }

        /* Compact Filters styling */
        .filters-panel { 
            background: #f8fafc;
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
        }

        .form-floating > .form-control {
            height: calc(2.5rem + 2px);
            padding: 0.6rem 0.6rem;
            font-size: 12.5px;
            font-weight: 500;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
        }

        .form-floating > label {
            padding: 0.5rem 0.6rem;
            font-size: 11px;
            color: #64748b;
        }

        .form-control:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
        }

        /* Compact Actions Bar */
        .actions-bar {
            background: #ffffff;
            padding: 8px 14px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        /* Compact Button styling */
        .btn { 
            border-radius: 6px; 
            font-weight: 600; 
            border: none; 
            padding: 5px 12px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 12px;
        }
        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
        }
        
        .btn-gradient-primary { background: var(--primary-gradient); color: white; }
        .btn-gradient-success { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; }
        .btn-gradient-danger { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; }
        .btn-gradient-info { background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); color: white; }
        .btn-dark { background: #0f172a; color: white; }
        .btn-light { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-light:hover { background: #e2e8f0; }

        /* COMPACT TABLE STYLING */
        .table-responsive { 
            margin-top: 10px;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: var(--card-shadow);
            border: 1.5px solid var(--border-color);
        }
        
        .table-bordered-custom {
            margin-bottom: 0;
            border-collapse: collapse !important;
            background: #ffffff;
            width: 100%;
        }
        
        .table-bordered-custom th,
        .table-bordered-custom td {
            border: 1px solid var(--border-color) !important;
            padding: 6px 10px;
            font-size: 12.5px;
            vertical-align: middle;
        }

        .table-bordered-custom thead th.sticky { 
            position: sticky; 
            top: 0; 
            z-index: 5;
            background: #1e293b;
            color: #f8fafc;
            border: 1px solid #334155 !important;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 10.5px;
            letter-spacing: 0.5px;
            padding: 8px 10px;
        }
        
         /* Sticky Table Header */
        .table-bordered-custom thead th { 
            position: sticky;
            top: 0;
            z-index: 10;
            background: #1e293b;
            color: #f8fafc;
            border: 1px solid #334155 !important;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 10px;
            letter-spacing: 0.5px;
            text-align: left;
        }

        .table-bordered-custom tbody tr:hover {
            background-color: #f1f5f9;
        }

        .account-badge {
            background: #e0e7ff;
            color: #3730a3;
            font-family: monospace;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 11.5px;
            font-weight: 600;
            border: 1px solid #c7d2fe;
        }

        /* Compact Pagination Controls */
        .pagination-container {
            margin-top: 12px;
            padding: 8px 14px;
            background: #f8fafc;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .badge-total {
            background: var(--primary-gradient);
            padding: 5px 12px;
            font-weight: 700;
            border-radius: 20px;
            color: white;
            font-size: 12px;
        }

        /* Action Buttons */
        .action-btn { 
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 11px;
        }
        .btn-warning { background: #f59e0b; color: #ffffff; }
        .btn-warning:hover { background: #d97706; color: #ffffff; }

        /* Modal Enhancements */
        .modal-content {
            border-radius: 12px;
            border: none;
            box-shadow: 0 10px 20px -5px rgba(0, 0, 0, 0.1);
        }
        
        .modal-header {
            background: var(--primary-gradient);
            color: white;
            padding: 12px 16px;
        }

        .list-group-item {
            border: 1px solid #e2e8f0;
            border-radius: 6px !important;
            margin-bottom: 4px;
            background: #ffffff;
            padding: 8px 12px;
        }

        .drag-handle {
            cursor: grab;
            color: #94a3b8;
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <jsp:include page="navbar.jsp" />

    <div class="container-fluid px-3 mt-2">
        <div class="report-card">
            
            <!-- Header section -->
            <div class="d-flex flex-wrap justify-content-between align-items-center header-title-container gap-2">
                <div class="d-flex align-items-center gap-2">
                    <div class="p-2 bg-light rounded-3 text-primary border">
                        <i class="fa fa-university fa-lg"></i>
                    </div>
                    <div>
                        <h3 class="report-title mb-0">Bank Details Master Report</h3>
                        <p class="text-muted small mb-0" style="font-size: 11px;">Manage, filter, and export beneficiary bank details</p>
                    </div>
                </div>
            </div>

            <!-- Interactive Filters -->
            <div class="filters-panel mb-2">
                <div class="row g-2 align-items-center">
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="text" id="filterBenfAcc" class="form-control" oninput="applyFilters()" placeholder="Beneficiary Account" />
                            <label for="filterBenfAcc"><i class="fa fa-credit-card me-1"></i> Beneficiary Account</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="text" id="filterBenf" class="form-control" oninput="applyFilters()" placeholder="Beneficiary Name" />
                            <label for="filterBenf"><i class="fa fa-user me-1"></i> Beneficiary Name</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-floating">
                            <input type="text" id="filterBank" class="form-control" oninput="applyFilters()" placeholder="Bank Name" />
                            <label for="filterBank"><i class="fa fa-building-columns me-1"></i> Bank Name</label>
                        </div>
                    </div>
                    <div class="col-md-3 d-flex justify-content-end">
                        <button type="button" class="btn btn-light py-2 w-100 justify-content-center" onclick="clearFilters()" title="Reset all filters">
                            <i class="fa fa-rotate-right me-1"></i> Reset Filters
                        </button>
                    </div>
                </div>
            </div>

            <!-- Data Export Toolbar -->
            <div class="actions-bar d-flex flex-wrap align-items-center justify-content-between mb-2 gap-2">
                <span class="text-muted small fw-semibold" style="font-size: 11px;"><i class="fa fa-download me-1"></i> Quick Export Options</span>
                <div class="d-flex gap-1.5">
                    <button type="button" class="btn btn-gradient-primary btn-sm" data-bs-toggle="modal" data-bs-target="#customExportModal">
                        <i class="fa fa-sliders"></i> Custom Export
                    </button>
                    <button type="button" class="btn btn-gradient-info btn-sm" onclick="exportCsv()">
                        <i class="fa fa-file-csv"></i> CSV
                    </button>
                    <button type="button" class="btn btn-gradient-primary btn-sm" onclick="exportPdf()">
                        <i class="fa fa-file-pdf"></i> PDF
                    </button>
                    <button type="button" class="btn btn-dark btn-sm" onclick="printReport()">
                        <i class="fa fa-print"></i> Print
                    </button>
                </div>
            </div>

            <!-- Main Data Table -->
            <div class="table-responsive">
                <table class="table table-bordered-custom table-hover align-middle mb-0" id="bankTable">
                    <thead>
                        <tr>
                            <th class="sticky">Beneficiary Account</th>
                            <th class="sticky">Beneficiary Name</th>
                            <th class="sticky">IFSC Code</th>
                            <th class="sticky">Branch</th>
                            <th class="sticky">Bank Name</th>
                            <th class="sticky text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            List<BankDetail> list = (List<BankDetail>) request.getAttribute("bankList");
                            if (list != null && !list.isEmpty()) {
                                for (BankDetail bd : list) {
                        %>
                        <tr class="data-row">
                            <td>
                                <span class="account-badge">
                                    <%= bd.getBenfAccount() != null ? bd.getBenfAccount() : "" %>
                                </span>
                            </td>
                            <td class="fw-semibold"><%= bd.getBenfName() != null ? bd.getBenfName() : "" %></td>
                            <td><code class="text-secondary"><%= bd.getBenfIfsc() != null ? bd.getBenfIfsc() : "" %></code></td>
                            <td><%= bd.getBenfBranch() != null ? bd.getBenfBranch() : "" %></td>
                            <td><%= bd.getBenfBank() != null ? bd.getBenfBank() : "" %></td>
                            <td class="text-center">
                                <a class="btn btn-sm btn-warning action-btn" href="${ctx}/editBankDetail?acc=<%= bd.getBenfAccount() %>" title="Edit">
                                    <i class="fa fa-edit me-1"></i> Edit
                                </a>
                            </td>
                        </tr>
                        <% 
                                }
                            } else {
                        %>
                        <tr id="emptyRow">
                            <td colspan="6" class="text-center py-4 text-muted">
                                <i class="fa fa-folder-open fa-2x mb-2 text-secondary opacity-50 d-block"></i> No bank details found.
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Pagination section -->
            <div id="paginationControls" class="pagination-container d-flex flex-wrap align-items-center justify-content-between gap-2">
                <div class="d-flex align-items-center gap-1.5">
                    <button class="btn btn-light btn-sm" onclick="prevPage()"><i class="fa fa-chevron-left"></i> Prev</button>
                    <span id="pageInfo" class="badge bg-white text-dark border px-2.5 py-1.5">Page 1 of 1</span>
                    <button class="btn btn-light btn-sm" onclick="nextPage()">Next <i class="fa fa-chevron-right"></i></button>
                </div>
                
                <div class="d-flex align-items-center gap-1.5">
                    <label for="gotoPage" class="small text-muted mb-0" style="font-size: 11px;">Jump to:</label>
                    <input type="number" id="gotoPage" class="form-control form-control-sm text-center py-0" style="width:55px; height: 26px;" min="1" value="1" />
                    <button class="btn btn-dark btn-sm py-0.5" onclick="jumpToPage()">Go</button>
                </div>

                <div>
                    <span id="totalBadge" class="badge-total">Total Records: 0</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Custom Export Options Modal -->
    <div class="modal fade" id="customExportModal" tabindex="-1" aria-labelledby="customExportModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h6 class="modal-title font-semibold mb-0" id="customExportModalLabel"><i class="fa fa-sliders me-2"></i>Custom Export Options</h6>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body p-3">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <p class="text-muted small mb-0" style="font-size: 11px;">Select columns to export and adjust display hierarchy:</p>
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-outline-primary py-0 px-2" onclick="selectAllExcelCols(true)">Select All</button>
                    <button type="button" class="btn btn-outline-secondary py-0 px-2" onclick="selectAllExcelCols(false)">Deselect All</button>
                </div>
            </div>
            
            <ul class="list-group" id="columnOrderList">
              <li class="list-group-item d-flex justify-content-between align-items-center" data-col-index="0" data-col-key="Beneficiary Account">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-2 col-checkbox" type="checkbox" checked id="col_acc">
                  <label class="form-check-label fw-semibold" for="col_acc" style="font-size: 12px;">Beneficiary Account</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" data-col-index="1" data-col-key="Beneficiary Name">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-2 col-checkbox" type="checkbox" checked id="col_benf">
                  <label class="form-check-label fw-semibold" for="col_benf" style="font-size: 12px;">Beneficiary Name</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" data-col-index="2" data-col-key="IFSC Code">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-2 col-checkbox" type="checkbox" checked id="col_ifsc">
                  <label class="form-check-label fw-semibold" for="col_ifsc" style="font-size: 12px;">IFSC Code</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" data-col-index="3" data-col-key="Branch">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-2 col-checkbox" type="checkbox" checked id="col_branch">
                  <label class="form-check-label fw-semibold" for="col_branch" style="font-size: 12px;">Branch</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
              <li class="list-group-item d-flex justify-content-between align-items-center" data-col-index="4" data-col-key="Bank Name">
                <div class="d-flex align-items-center">
                  <i class="fa fa-grip-vertical drag-handle"></i>
                  <input class="form-check-input me-2 col-checkbox" type="checkbox" checked id="col_bank">
                  <label class="form-check-label fw-semibold" for="col_bank" style="font-size: 12px;">Bank Name</label>
                </div>
                <div>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, -1)"><i class="fa fa-arrow-up text-muted"></i></button>
                  <button type="button" class="btn btn-sm btn-light border py-0 px-1.5" onclick="moveColumn(this, 1)"><i class="fa fa-arrow-down text-muted"></i></button>
                </div>
              </li>
            </ul>
          </div>
          <div class="modal-footer bg-light justify-content-between py-2">
            <button type="button" class="btn btn-light border btn-sm" data-bs-dismiss="modal">Cancel</button>
            <div class="d-flex gap-1.5">
                <button type="button" class="btn btn-gradient-success btn-sm" onclick="downloadCustomExcel()">
                    <i class="fa fa-file-excel me-1"></i> Excel
                </button>
                <button type="button" class="btn btn-gradient-danger btn-sm" onclick="downloadCustomPdf()">
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
        var currentPage = 1;
        var pageSize = 50; 
        var totalPages = 1;

        function applyFilters() {
            currentPage = 1;
            var benfAcc = document.getElementById('filterBenfAcc').value.trim().toLowerCase();
            var benf = document.getElementById('filterBenf').value.trim().toLowerCase();
            var bank = document.getElementById('filterBank').value.trim().toLowerCase();

            var rows = document.querySelectorAll('#bankTable tbody tr.data-row');
            
            rows.forEach(function(r) {
                var benfAccText = (r.cells[0].innerText || r.cells[0].textContent).toLowerCase();
                var benfText = (r.cells[1].innerText || r.cells[1].textContent).toLowerCase();
                var bankText = (r.cells[4].innerText || r.cells[4].textContent).toLowerCase();

                var show = true;
                if (benfAcc && benfAccText.indexOf(benfAcc) === -1) show = false;
                if (benf && benfText.indexOf(benf) === -1) show = false;
                if (bank && bankText.indexOf(bank) === -1) show = false;

                r.dataset.matched = show ? '1' : '0';
                r.style.display = 'none';
            });
            
            updatePagination();
        }

        function clearFilters() {
            document.getElementById('filterBenfAcc').value = '';
            document.getElementById('filterBenf').value = '';
            document.getElementById('filterBank').value = '';
            applyFilters();
        }

        function updatePagination() {
            var rows = document.querySelectorAll('#bankTable tbody tr.data-row');
            var matched = [];
            
            rows.forEach(function(r) {
                if (r.dataset.matched === '1') matched.push(r);
                r.style.display = 'none';
            });

            totalPages = Math.max(1, Math.ceil(matched.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;

            var start = (currentPage - 1) * pageSize;
            var end = Math.min(matched.length, start + pageSize);
            
            for (var j = start; j < end; j++) {
                matched[j].style.display = '';
            }
            
            renderPaginationControls(matched.length);
        }

        function initializeReport() {
            var rows = document.querySelectorAll('#bankTable tbody tr.data-row');
            rows.forEach(function(r) {
                r.dataset.matched = '1';
                r.style.display = 'none';
            });
            currentPage = 1;
            updatePagination();
        }

        document.addEventListener('DOMContentLoaded', function() {
            initializeReport();
        });

        function renderPaginationControls(totalItems) {
            var info = document.getElementById('pageInfo');
            info.textContent = 'Page ' + currentPage + ' of ' + totalPages;
            var totalBadge = document.getElementById('totalBadge');
            if (totalBadge) totalBadge.textContent = 'Total Records: ' + totalItems;
            var goto = document.getElementById('gotoPage');
            if (goto) goto.value = currentPage;
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
                        colIndex: parseInt(li.getAttribute('data-col-index'), 10)
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

            var rows = document.querySelectorAll('#bankTable tbody tr.data-row');

            rows.forEach(function(r) {
                if (r.dataset.matched === '1') {
                    var rowData = [];
                    selectedColumns.forEach(function(col) {
                        var cellText = (r.cells[col.colIndex].innerText || r.cells[col.colIndex].textContent).trim();
                        rowData.push(cellText);
                    });
                    excelData.push(rowData);
                }
            });

            var worksheet = XLSX.utils.aoa_to_sheet(excelData);
            var workbook = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(workbook, worksheet, "Bank Details");

            var colWidths = headers.map(function(h) { return { wch: Math.max(h.length + 5, 18) }; });
            worksheet['!cols'] = colWidths;

            XLSX.writeFile(workbook, "bank_details_custom_report.xlsx");

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

            var rows = document.querySelectorAll('#bankTable tbody tr.data-row');

            var win = window.open('', '_blank');
            var html = '<!doctype html><html><head><title>Bank Details Custom Report</title>' +
                '<style>body{font-family:"Plus Jakarta Sans",Arial,sans-serif;margin:20px}table{width:100%;border-collapse:collapse}th,td{border:1px solid #cbd5e1;padding:8px;text-align:left;font-size:11px}th{background:#f1f5f9;color:#0f172a}</style>' +
                '</head><body>';
            html += '<h3 style="color:#0f172a;">Bank Details Custom Report</h3>';
            html += '<table><thead><tr>' + selectedColumns.map(function(col){ return '<th>' + col.key + '</th>'; }).join('') + '</tr></thead><tbody>';

            rows.forEach(function(r) {
                if (r.dataset.matched === '1') {
                    html += '<tr>';
                    selectedColumns.forEach(function(col) {
                        var cellText = (r.cells[col.colIndex].innerText || r.cells[col.colIndex].textContent).trim();
                        html += '<td>' + cellText + '</td>';
                    });
                    html += '</tr>';
                }
            });

            html += '</tbody></table></body></html>';
            win.document.write(html);
            win.document.close();

            var modalElement = document.getElementById('customExportModal');
            var modal = bootstrap.Modal.getInstance(modalElement);
            if (modal) modal.hide();

            setTimeout(function(){ win.print(); }, 500);
        }

        function getVisibleRowsData() {
            var table = document.getElementById('bankTable');
            var rows = table.querySelectorAll('tbody tr.data-row');
            var data = [];
            
            var headers = [];
            var ths = table.tHead.rows[0].cells;
            for (var h = 0; h < ths.length - 1; h++) {
                headers.push(ths[h].innerText.trim());
            }
            data.push(headers);

            rows.forEach(function(r) {
                if (r.style.display !== 'none') {
                    var rowData = [];
                    for (var c = 0; c < r.cells.length - 1; c++) {
                        rowData.push((r.cells[c].innerText || r.cells[c].textContent).trim());
                    }
                    data.push(rowData);
                }
            });
            return data;
        }

        function exportCsv() {
            var data = getVisibleRowsData();
            if (data.length <= 1) {
                alert('No visible records to export!');
                return;
            }
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
            a.download = 'bank_details_report.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        function exportPdf() {
            var data = getVisibleRowsData();
            if (data.length <= 1) {
                alert('No visible records to print/export!');
                return;
            }
            var win = window.open('', '_blank');
            var html = '<!doctype html><html><head><title>Bank Details Master Report</title>' +
                '<style>body{font-family:"Plus Jakarta Sans",Arial,sans-serif;margin:20px}table{width:100%;border-collapse:collapse}th,td{border:1px solid #cbd5e1;padding:8px;text-align:left;font-size:11px}th{background:#f1f5f9;color:#0f172a}</style>' +
                '</head><body>';
            html += '<h3 style="color:#0f172a;">Bank Details Master Report</h3>';
            html += '<table><thead><tr>' + data[0].map(function(h){return '<th>'+h+'</th>'}).join('') + '</tr></thead><tbody>';
            for (var i = 1; i < data.length; i++) {
                html += '<tr>' + data[i].map(function(cell){
                    return '<td>'+cell+'</td>';
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