<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.util.Arrays" %>
<%!
    // Guaranteed Indian Number Formatter (e.g., 94,82,226.00 and 94,82,226)
    public String formatIndianNumber(double value, int decimals) {
        String s = (decimals > 0) ? String.format("%." + decimals + "f", value) : String.format("%.0f", value);
        String intPart = s;
        String decPart = "";
        
        int dotIndex = s.indexOf('.');
        if (dotIndex != -1) {
            intPart = s.substring(0, dotIndex);
            decPart = s.substring(dotIndex);
        }

        if (intPart.length() <= 3) {
            return intPart + decPart;
        }

        String lastThree = intPart.substring(intPart.length() - 3);
        String remaining = intPart.substring(0, intPart.length() - 3);

        StringBuilder formatted = new StringBuilder();
        while (remaining.length() > 2) {
            formatted.insert(0, "," + remaining.substring(remaining.length() - 2));
            remaining = remaining.substring(0, remaining.length() - 2);
        }
        if (remaining.length() > 0) {
            formatted.insert(0, remaining);
        }

        return formatted.toString() + "," + lastThree + decPart;
    }
%>
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
    <title>Pay Register Report - Vaibhutrans</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- SheetJS for Client-Side Excel Export -->
    <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
    <!-- JSZip for Multiple Excel Archive Download -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --icici-gradient: linear-gradient(135deg, #f97316 0%, #c2410c 100%);
            --bom-gradient: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
            --card-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.01);
            --glass-bg: rgba(255, 255, 255, 0.96);
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

        .report-card {
            padding: 20px 24px;
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 16px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin-top: 14px;
        }

        .header-title-container {
            border-bottom: 2px dashed #e2e8f0;
        }

        .report-title {
            font-weight: 800;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: -0.5px;
        }

        /* Metric Cards styling */
        .metric-card-1 {
            background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
            border: 1px solid #c7d2fe;
            border-radius: 10px;
        }

        .metric-card-2 {
            background: linear-gradient(135deg, rgb(237, 222, 251) 0%, rgb(245, 247, 246) 100%);
            border: 1px solid #a7f3d0;
            border-radius: 10px;
        }

        .metric-label {
            font-size: 10.5px;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            font-weight: 700;
            color: #475569;
        }

        .metric-val {
            font-size: 14px;
            font-weight: 800;
            color: #0f172a;
        }

        /* Filter Panel Single-Line Responsive Styling */
        .filters-panel {
            background: #f8fafc;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            padding: 8px 10px;
        }

        .filter-row-nowrap {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 6px;
        }

        .filter-item-cluster { flex: 1 1 110px; min-width: 100px; max-width: 130px; }
        .filter-item-multi   { flex: 1 1 120px; min-width: 110px; }
        .filter-item-month   { flex: 0 0 78px; min-width: 74px; }
        .filter-item-year    { flex: 0 0 78px; min-width: 74px; }
        .filter-item-actions { flex: 0 0 auto; display: flex; align-items: center; gap: 4px; }

        .filters-panel .form-select-sm, .bank-card .form-select-sm {
            height: 32px;
            font-size: 11px;
            padding: 3px 6px;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
        }

        /* Multi-Select Checkbox Dropdown Styling */
        .custom-multiselect-dropdown {
            max-height: 250px;
            overflow-y: auto;
            min-width: 200px;
            padding: 6px 8px;
            border-radius: 8px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }

        .multiselect-btn {
            height: 32px;
            font-size: 11px;
            border-radius: 6px;
            border: 1px solid #cbd5e1;
            background: #ffffff;
            color: #1e293b;
            font-weight: 600;
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            text-align: left;
            padding: 3px 6px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .multiselect-btn:focus, .multiselect-btn:hover {
            background: #f8fafc;
            border-color: #6366f1;
            box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
        }

        .multiselect-option {
            font-size: 11.5px;
            cursor: pointer;
            padding: 3px 5px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            user-select: none;
        }

        .multiselect-option:hover {
            background: #f1f5f9;
        }

        .multiselect-actions {
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 4px;
            margin-bottom: 4px;
            display: flex;
            justify-content: space-between;
            font-size: 10.5px;
        }

        /* Bank Card styling */
        .bank-card {
            background: linear-gradient(135deg, #f0fdf4 0%, #e0f2fe 100%);
            border-radius: 10px;
            border: 1px solid #bae6fd;
        }

        /* Actions Bar */
        .actions-bar {
            background: #ffffff;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        /* Button styling */
        .btn {
            border-radius: 6px;
            font-weight: 600;
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
            font-size: 11px;
            white-space: nowrap;
        }

        .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.15);
        }

        .btn-gradient-primary { background: var(--primary-gradient); color: white; }
        .btn-gradient-success { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; }
        .btn-gradient-info { background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); color: white; }
        .btn-gradient-icici { background: var(--icici-gradient); color: white; }
        .btn-gradient-bom { background: var(--bom-gradient); color: white; }
        .btn-dark { background: #0f172a; color: white; }
        .btn-light { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-light:hover { background: #e2e8f0; color: #0f172a; }

        /* Table styling */
        .table-responsive {
            margin-top: 10px;
            border-radius: 8px;
            overflow-x: auto;
            max-height: 560px;
            box-shadow: var(--card-shadow);
            border: 1.5px solid var(--border-color);
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
            padding: 7px 10px;
            font-size: 12px;
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
            font-size: 10.5px;
            letter-spacing: 0.5px;
        }

        .table-bordered-custom tbody tr:hover {
            background-color: #f1f5f9;
        }

        /* Status Badges */
        .status-badge {
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 4px;
            font-size: 10.5px;
            display: inline-block;
        }
        .status-badge-allow { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
        .status-badge-hold  { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .status-badge-paid  { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
        .status-badge-other { background: #fdf8f4; color: #9a3412; border: 1px solid #fed7aa; }

        .pagination-container {
            margin-top: 12px;
            padding: 10px 16px;
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
            font-size: 11.5px;
        }

        .code-badge {
            background: #eef2ff;
            color: #4338ca;
            font-family: monospace;
            padding: 2px 5px;
            border-radius: 4px;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <!-- Navbar -->
    <jsp:include page="navbar.jsp" />

    <div class="container-fluid px-4 mt-2">
        <div class="report-card">

            <!-- Header Section -->
            <div class="d-flex flex-wrap justify-content-between align-items-center header-title-container pb-2 mb-2 gap-2">
                <div class="d-flex align-items-center gap-2">
                    <div class="p-2 bg-light rounded-3 text-primary border">
                        <i class="fa fa-money-check-alt"></i>
                    </div>
                    <div>
                        <h4 class="report-title mb-0" style="font-size: 19px;">Pay Register Report</h4>
                        <p class="text-muted small mb-0" style="font-size: 11px;">Filter by Cluster, Zone, Circle, Division, Designation, DB Status & Month/Year</p>
                    </div>
                </div>

                <% if (request.getAttribute("message") != null) { %>
                    <div class="alert alert-success py-1 px-3 mb-0 small">
                        <i class="fa fa-check-circle me-1"></i> <%= request.getAttribute("message") %>
                    </div>
                <% } %>
            </div>

            <!-- Metric Summary Cards -->
            <%
                Map<String, Double> summary = (Map<String, Double>) request.getAttribute("summaryMap");
                double sumCtc1 = (summary != null && summary.get("SUM_CTC1_ACT") != null) ? summary.get("SUM_CTC1_ACT") : 0.0;
                double sumCtc = (summary != null && summary.get("SUM_CTC_ACT") != null) ? summary.get("SUM_CTC_ACT") : 0.0;
                double sumTcs = (summary != null && summary.get("SUM_TOTAL_TCS_ACT") != null) ? summary.get("SUM_TOTAL_TCS_ACT") : 0.0;
                double sumNet = (summary != null && summary.get("SUM_NET_AMT_PAYABLE") != null) ? summary.get("SUM_NET_AMT_PAYABLE") : 0.0;
                double sumTotalSalary = sumTcs + sumNet;

                double sumTotBilled = (summary != null && summary.get("SUM_TOTAL_BILLED_ACT") != null) ? summary.get("SUM_TOTAL_BILLED_ACT") : 0.0;
                double sumManBilled = (summary != null && summary.get("SUM_MANNUAL_BILLED_ACT") != null) ? summary.get("SUM_MANNUAL_BILLED_ACT") : 0.0;
                double sumProbeBilled = (summary != null && summary.get("SUM_PROBE_BILLED_ACT") != null) ? summary.get("SUM_PROBE_BILLED_ACT") : 0.0;
                double sumAutoOcr = (summary != null && summary.get("SUM_AUTO_OCR_ACT") != null) ? summary.get("SUM_AUTO_OCR_ACT") : 0.0;
            %>

            <!-- First Card: Currency Figures in Indian Number Format (₹ 94,82,226.00) -->
            <div class="metric-card-1 p-2 mb-2">
                <div class="row text-center g-1 align-items-center">
                    <div class="col border-end">
                        <div class="metric-label">CTC1 Act</div>
                        <div class="metric-val text-primary">&#8377;<%= formatIndianNumber(sumCtc1, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">CTC Act</div>
                        <div class="metric-val text-primary">&#8377;<%= formatIndianNumber(sumCtc, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">Total TCS Act</div>
                        <div class="metric-val text-danger">&#8377;<%= formatIndianNumber(sumTcs, 2) %></div>
                    </div>
                    <div class="col border-end">
                        <div class="metric-label">Net Payable</div>
                        <div class="metric-val text-success">&#8377;<%= formatIndianNumber(sumNet, 2) %></div>
                    </div>
                    <div class="col">
                        <div class="metric-label">Total Salary Amount</div>
                        <div class="metric-val text-dark">&#8377;<%= formatIndianNumber(sumTotalSalary, 2) %></div>
                    </div>
                </div>
            </div>

            <!-- Second Card: Quantity / Count Figures in Indian Number Format (94,82,226) -->
            <div class="metric-card-2 p-2 mb-2">
                <div class="row text-center g-1 align-items-center">
                    <div class="col-3 border-end">
                        <div class="metric-label">Total Billed Act</div>
                        <div class="metric-val text-dark"><%= formatIndianNumber(sumTotBilled, 0) %></div>
                    </div>
                    <div class="col-3 border-end">
                        <div class="metric-label">Manual Billed</div>
                        <div class="metric-val text-secondary"><%= formatIndianNumber(sumManBilled, 0) %></div>
                    </div>
                    <div class="col-3 border-end">
                        <div class="metric-label">Probe Billed</div>
                        <div class="metric-val text-info"><%= formatIndianNumber(sumProbeBilled, 0) %></div>
                    </div>
                    <div class="col-3">
                        <div class="metric-label">Auto OCR Act</div>
                        <div class="metric-val text-success"><%= formatIndianNumber(sumAutoOcr, 0) %></div>
                    </div>
                </div>
            </div>

            <!-- Single-Line Compact Filter Form with Multi-Select Checkboxes -->
            <%
                String selCluster = request.getAttribute("selectedCluster") != null ? String.valueOf(request.getAttribute("selectedCluster")) : "";
                List<String> selZones = (List<String>) request.getAttribute("selectedZones");
                List<String> selCircles = (List<String>) request.getAttribute("selectedCircles");
                List<String> selDivisions = (List<String>) request.getAttribute("selectedDivisions");
                List<String> selDesignations = (List<String>) request.getAttribute("selectedDesignations");
                List<String> selDbStatuses = (List<String>) request.getAttribute("selectedDbStatuses");
                String selMonth = request.getAttribute("selectedMonth") != null ? String.valueOf(request.getAttribute("selectedMonth")) : "";
                String selYear = request.getAttribute("selectedYear") != null ? String.valueOf(request.getAttribute("selectedYear")) : "";

                List<String> zoneList = (List<String>) request.getAttribute("zoneList");
                List<String> circleList = (List<String>) request.getAttribute("circleList");
                List<String> divisionList = (List<String>) request.getAttribute("divisionList");
                List<String> designationList = (List<String>) request.getAttribute("designationList");
                List<String> dbStatusList = (List<String>) request.getAttribute("dbStatusList");
                List<Map<String, String>> companyBankList = (List<Map<String, String>>) request.getAttribute("companyBankList");
            %>
            <div class="filters-panel mb-2">
                <form id="filterForm" action="pay-register" method="get">
                    <div class="filter-row-nowrap">
                        
                        <!-- 1) Cluster -->
                        <div class="filter-item-cluster">
                            <select name="cluster" id="filterCluster" class="form-select form-select-sm fw-semibold w-100" onchange="onClusterFilterChange(this)">
                                <option value="" <%= "".equals(selCluster) ? "selected" : "" %>>1. All Clusters</option>
                                <option value="8" <%= "8".equals(selCluster) ? "selected" : "" %>>Cluster-8</option>
                                <option value="9" <%= "9".equals(selCluster) ? "selected" : "" %>>Cluster-9</option>
                                <option value="12" <%= "12".equals(selCluster) ? "selected" : "" %>>Cluster-12</option>
                                <option value="5" <%= "5".equals(selCluster) ? "selected" : "" %>>Cluster-5</option>
                            </select>
                        </div>

                        <!-- 2) Zone -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="zoneDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="zoneBtnLabel">2. All Zones</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="zoneDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('zoneCheckbox', true, 'zone')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('zoneCheckbox', false, 'zone')">Deselect</a>
                                    </div>
                                    <%
                                        if (zoneList != null && !zoneList.isEmpty()) {
                                            for (String z : zoneList) {
                                                boolean isChecked = (selZones != null && selZones.contains(z));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="zone" value="<%= z %>" class="form-check-input me-2 zoneCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('zone')">
                                            <span><%= z %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No zones available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 3) Circle -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="circleDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="circleBtnLabel">3. All Circles</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="circleDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('circleCheckbox', true, 'circle')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('circleCheckbox', false, 'circle')">Deselect</a>
                                    </div>
                                    <%
                                        if (circleList != null && !circleList.isEmpty()) {
                                            for (String c : circleList) {
                                                boolean isChecked = (selCircles != null && selCircles.contains(c));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="circle" value="<%= c %>" class="form-check-input me-2 circleCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('circle')">
                                            <span><%= c %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No circles available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 4) Division -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="divisionDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="divisionBtnLabel">4. All Divisions</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="divisionDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('divisionCheckbox', true, 'division')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('divisionCheckbox', false, 'division')">Deselect</a>
                                    </div>
                                    <%
                                        if (divisionList != null && !divisionList.isEmpty()) {
                                            for (String d : divisionList) {
                                                boolean isChecked = (selDivisions != null && selDivisions.contains(d));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="division" value="<%= d %>" class="form-check-input me-2 divisionCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('division')">
                                            <span><%= d %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No divisions available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 5) Designation -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="designationDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="designationBtnLabel">5. All Designations</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="designationDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('designationCheckbox', true, 'designation')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('designationCheckbox', false, 'designation')">Deselect</a>
                                    </div>
                                    <%
                                        if (designationList != null && !designationList.isEmpty()) {
                                            for (String desig : designationList) {
                                                boolean isChecked = (selDesignations != null && selDesignations.contains(desig));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="designation" value="<%= desig %>" class="form-check-input me-2 designationCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('designation')">
                                            <span><%= desig %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No designations available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 6) DB Status -->
                        <div class="filter-item-multi">
                            <div class="dropdown">
                                <button class="multiselect-btn dropdown-toggle" type="button" id="dbStatusDropdownBtn" data-bs-toggle="dropdown" aria-expanded="false">
                                    <span id="dbStatusBtnLabel">6. All DB Status</span>
                                </button>
                                <div class="dropdown-menu custom-multiselect-dropdown shadow" aria-labelledby="dbStatusDropdownBtn" onclick="event.stopPropagation()">
                                    <div class="multiselect-actions">
                                        <a href="javascript:void(0)" class="text-primary text-decoration-none fw-bold" onclick="toggleSelectAll('dbStatusCheckbox', true, 'dbStatus')">Select All</a>
                                        <a href="javascript:void(0)" class="text-danger text-decoration-none fw-bold" onclick="toggleSelectAll('dbStatusCheckbox', false, 'dbStatus')">Deselect</a>
                                    </div>
                                    <%
                                        if (dbStatusList != null && !dbStatusList.isEmpty()) {
                                            for (String status : dbStatusList) {
                                                boolean isChecked = (selDbStatuses != null && selDbStatuses.contains(status));
                                    %>
                                        <label class="multiselect-option">
                                            <input type="checkbox" name="dbStatus" value="<%= status %>" class="form-check-input me-2 dbStatusCheckbox" <%= isChecked ? "checked" : "" %> onchange="onCheckboxSelectionChanged('dbStatus')">
                                            <span><%= status %></span>
                                        </label>
                                    <%
                                            }
                                        } else {
                                    %>
                                        <div class="text-muted small px-1 py-1">No status available</div>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <!-- 7) Month -->
                        <div class="filter-item-month">
                            <select name="month" id="filterMonth" class="form-select form-select-sm fw-semibold w-100">
                                <option value="">Month</option>
                                <%
                                    String[] months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
                                    for (String m : months) {
                                %>
                                    <option value="<%=m%>" <%= m.equalsIgnoreCase(selMonth) ? "selected" : "" %>><%=m%></option>
                                <% } %>
                            </select>
                        </div>

                        <!-- 8) Year -->
                        <div class="filter-item-year">
                            <select name="year" id="filterYear" class="form-select form-select-sm fw-semibold w-100">
                                <option value="">Year</option>
                                <%
                                    int currYear = java.time.Year.now().getValue();
                                    for (int y = currYear; y >= currYear - 5; y--) {
                                %>
                                    <option value="<%=y%>" <%= String.valueOf(y).equals(selYear) ? "selected" : "" %>><%=y%></option>
                                <% } %>
                            </select>
                        </div>

                        <!-- Filter & Reset Buttons -->
                        <div class="filter-item-actions ms-auto">
                            <button type="submit" class="btn btn-gradient-primary btn-sm px-2" style="height: 32px;" title="Apply selected filters">
                                <i class="fa fa-filter"></i> Filter
                            </button>
                            <button type="button" class="btn btn-light btn-sm px-2 border" style="height: 32px;" onclick="clearAllFilters()" title="Reset all filters">
                                <i class="fa fa-rotate-right"></i> Reset
                            </button>
                        </div>

                    </div>
                </form>
            </div>

            <!-- Company Bank Details Filter Card -->
            <div class="bank-card p-2 mb-2">
                <div class="row g-2 align-items-center">
                    <div class="col-md-4">
                        <select id="companySelect" class="form-select form-select-sm fw-semibold" onchange="onCompanyChange()">
                            <option value="">-- Select Company --</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <select id="bankSelect" class="form-select form-select-sm fw-semibold" onchange="onBankChange()">
                            <option value="">-- Select Bank --</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <select id="accountNumberSelect" class="form-select form-select-sm fw-semibold">
                            <option value="">-- Select Account No --</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Client-side Quick Search Filter -->
            <div class="row g-2 mb-2">
                <div class="col-md-4">
                    <div class="input-group input-group-sm">
                        <span class="input-group-text bg-white border-end-0 py-1"><i class="fa fa-search text-muted"></i></span>
                        <input type="text" id="tableSearch" class="form-control border-start-0 py-1" placeholder="Search Code, Name, Account, Status..." onkeyup="filterTableSearch()">
                    </div>
                </div>
            </div>

            <!-- Export Toolbar -->
            <div class="actions-bar d-flex flex-wrap align-items-center justify-content-between mb-2 py-1 px-3 gap-2">
                <span class="text-muted small fw-semibold" style="font-size: 11.5px;"><i class="fa fa-download me-1"></i> Export Options</span>
                <div class="d-flex flex-wrap gap-2">
                    <button type="button" class="btn btn-gradient-primary btn-sm py-1 px-3" onclick="downloadMaster()">
                        <i class="fa fa-file-excel"></i> Download Master
                    </button>
                    <button type="button" class="btn btn-gradient-bom btn-sm py-1 px-3" onclick="exportBomTxtFormat()">
                        <i class="fa fa-university"></i> BOM Format
                    </button>
                    <button type="button" class="btn btn-gradient-icici btn-sm py-1 px-3" onclick="exportIciciFormat()">
                        <i class="fa fa-university"></i> ICICI Format
                    </button>
                    <button type="button" class="btn btn-gradient-success btn-sm py-1 px-3" onclick="exportExcel()">
                        <i class="fa fa-file-excel"></i> Excel
                    </button>
                    <button type="button" class="btn btn-gradient-info btn-sm py-1 px-3" onclick="exportCsv()">
                        <i class="fa fa-file-csv"></i> CSV
                    </button>
                    <button type="button" class="btn btn-dark btn-sm py-1 px-3" onclick="window.print()">
                        <i class="fa fa-print"></i> Print
                    </button>
                </div>
            </div>

            <!-- Main Data Table: Explicit 45 Target Columns including DB Status -->
            <%
                List<Map<String, Object>> records = (List<Map<String, Object>>) request.getAttribute("records");
                
                String[][] displayColumns = {
                    {"SN", "SN"},
                    {"CODE", "Code"},
                    {"EMP_NAME", "Name"},
                    {"DOJ", "DOJ"},
                    {"BANK_NAME", "Bank Name"},
                    {"BANK_BRANCH", "Bank Branch"},
                    {"IFSC", "IFSC"},
                    {"ACCOUNT_NO", "A/c No"},
                    {"AADHAAR", "Aadhaar"},
                    {"UAN", "UAN"},
                    {"ESI_NO", "ESI No"},
                    {"BRANCH", "Zone"},
                    {"CATEGORY", "Circle"},
                    {"DESIGNATION", "Designation"},
                    {"DEPARTMENT", "Division"},
                    {"DB_STATUS", "DB Status"},
                    {"MOBILE", "Mobile"},
                    {"FATHER_HUSBAND_NAME", "Father Name"},
                    {"TOTAL_DAYS", "Total Days"},
                    {"WK_OFF", "Wk Off"},
                    {"HOLIDAY", "Holiday"},
                    {"MAX_WORK_DAYS", "Max Work Days"},
                    {"MAX_PAYABLE_DAYS", "Max Payable Days"},
                    {"ABS_LWP", "Abs./LWP"},
                    {"NET_PAID_DAYS_ACT", "NET PAID DAYS [Actual]"},
                    {"BASIC_SALARY", "BASIC SALARY"},
                    {"CONVEYANCE", "CONVEYANCE ALLOWANCE"},
                    {"HRA", "HRA"},
                    {"GROSS_EARNING", "Gross Earning"},
                    {"PF", "PF"},
                    {"ESI", "ESI"},
                    {"PROFESSIONAL_TAX", "PROFESSIONAL TAX"},
                    {"GROSS_DEDUCTION", "Gross Deduction"},
                    {"NET_AMT_PAYABLE", "Net Amt Payable"},
                    {"TOTAL_TCS_ACT", "TOTAL TCS"},
                    {"GROSS_EARNING_2", "GROSS EARNING"},
                    {"PENSION_CONT", "PENSION CONT."},
                    {"EPF_DIFF", "EPF DIFF."},
                    {"EMPLOYER_PF_CONT", "TOTAL EMPLOYER'S PF CONT."},
                    {"EMPLOYER_ESI_CONT", "EMPLOYER'S ESI CONT."},
                    {"PF_EDLI_CHARGES", "PF EDLI CHARGES"},
                    {"TOTAL_CTC_SALARY", "TOTAL CTC SALARY"},
                    {"SIGNATURE", "Sign."},
                    {"REMARK", "Remark"},
                    {"CLUSTER_NAME", "Cluster name"},
                    {"PAY_MONTH", "pay month"},
                    {"PAY_YEAR", "pay year"}
                };
            %>
            <div class="table-responsive">
                <table id="payRegisterTable" class="table table-bordered-custom table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <% for (String[] col : displayColumns) { %>
                                <th data-col-name="<%= col[0] %>"><%= col[1] %></th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (records != null && !records.isEmpty()) {
                                for (Map<String, Object> record : records) {
                                    String dbStatus = (record.get("DB_STATUS") != null) ? record.get("DB_STATUS").toString().trim() : "";
                        %>
                            <tr data-db-status="<%= dbStatus %>">
                                <%
                                    for (String[] col : displayColumns) {
                                        String colKey = col[0];
                                        Object val = record.get(colKey);
                                        String strVal = (val != null) ? val.toString() : "";
                                        boolean isCode = "CODE".equalsIgnoreCase(colKey);
                                        boolean isStatus = "DB_STATUS".equalsIgnoreCase(colKey);
                                %>
                                    <td>
                                        <% if (isCode) { %>
                                            <span class="code-badge"><%= strVal %></span>
                                        <% } else if (isStatus) { 
                                            String badgeClass = "status-badge-other";
                                            if ("allow".equalsIgnoreCase(strVal)) badgeClass = "status-badge-allow";
                                            else if ("left".equalsIgnoreCase(strVal) || "hold".equalsIgnoreCase(strVal)) badgeClass = "status-badge-hold";
                                            else if ("paid".equalsIgnoreCase(strVal)) badgeClass = "status-badge-paid";
                                        %>
                                            <span class="status-badge <%= badgeClass %>"><%= strVal.isEmpty() ? "-" : strVal %></span>
                                        <% } else { %>
                                            <%= strVal %>
                                        <% } %>
                                    </td>
                                <% } %>
                            </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="<%= displayColumns.length %>" class="text-center py-5 text-muted">
                                    <i class="fa fa-folder-open fa-3x mb-3 text-secondary opacity-50 d-block"></i>
                                    No records found for the selected filters.
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Pagination Section -->
            <div id="paginationControls" class="pagination-container d-flex flex-wrap align-items-center justify-content-between gap-3">
                <div class="d-flex align-items-center gap-2">
                    <button class="btn btn-light btn-sm" onclick="prevPage()"><i class="fa fa-chevron-left"></i> Prev</button>
                    <span id="pageInfo" class="badge bg-white text-dark border px-3 py-1" style="font-size: 11px;">Page 1 of 1</span>
                    <button class="btn btn-light btn-sm" onclick="nextPage()">Next <i class="fa fa-chevron-right"></i></button>
                </div>

                <div>
                    <span id="totalBadge" class="badge-total">Total Records: <%= records != null ? records.size() : 0 %></span>
                </div>
            </div>

        </div>
    </div>

    <!-- Pass Data to JavaScript -->
    <script>
        var selectedCluster = "<%= selCluster %>";
        var selectedMonth = "<%= selMonth %>";
        var selectedYear = "<%= selYear %>";

        var rawBankDetails = [];
        <%
            if (companyBankList != null) {
                for (Map<String, String> b : companyBankList) {
        %>
            rawBankDetails.push({
                company: "<%= b.get("company_name").replace("\"", "\\\"") %>",
                bank: "<%= b.get("bank").replace("\"", "\\\"") %>",
                account: "<%= b.get("account_number").replace("\"", "\\\"") %>"
            });
        <%
                }
            }
        %>

        function onClusterFilterChange(selectElem) {
            selectElem.form.submit();
        }

        function toggleSelectAll(className, selectAll, type) {
            var checkboxes = document.querySelectorAll('.' + className);
            checkboxes.forEach(function(cb) {
                cb.checked = selectAll;
            });
            updateDropdownButtonLabel(type);
        }

        function onCheckboxSelectionChanged(type) {
            updateDropdownButtonLabel(type);
        }

        function updateDropdownButtonLabel(type) {
            var checkboxes = document.querySelectorAll('.' + type + 'Checkbox:checked');
            var labelSpan = document.getElementById(type + 'BtnLabel');
            if (!labelSpan) return;

            var defaultPrefix = type === 'zone' ? '2. All Zones' 
                              : (type === 'circle' ? '3. All Circles' 
                              : (type === 'division' ? '4. All Divisions' 
                              : (type === 'designation' ? '5. All Designations' 
                              : '6. All DB Status')));
            var pluralName = type === 'zone' ? 'Zones' 
                           : (type === 'circle' ? 'Circles' 
                           : (type === 'division' ? 'Divisions' 
                           : (type === 'designation' ? 'Designations' 
                           : 'Statuses')));

            if (checkboxes.length === 0) {
                labelSpan.textContent = defaultPrefix;
            } else if (checkboxes.length === 1) {
                labelSpan.textContent = checkboxes[0].value;
            } else {
                labelSpan.textContent = checkboxes.length + ' ' + pluralName + ' Selected';
            }
        }
    </script>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function initCompanyBankDropdowns() {
            var companySelect = document.getElementById('companySelect');
            if (!companySelect) return;

            var companies = Array.from(new Set(rawBankDetails.map(function(item) { return item.company; }))).filter(Boolean);
            companies.sort();

            companySelect.innerHTML = '<option value="">-- Select Company --</option>';
            companies.forEach(function(c) {
                var opt = document.createElement('option');
                opt.value = c;
                opt.textContent = c;
                companySelect.appendChild(opt);
            });

            if (companies.length > 0) {
                var defaultCompany = companies.find(function(c) {
                    return c.trim().toUpperCase() === "VIIPL" || c.trim().toUpperCase().includes("VIIPL");
                }) || companies[0];

                companySelect.value = defaultCompany;
                onCompanyChange();
            }
        }

        function onCompanyChange() {
            var selectedCompany = document.getElementById('companySelect').value;
            var bankSelect = document.getElementById('bankSelect');
            var accountSelect = document.getElementById('accountNumberSelect');

            bankSelect.innerHTML = '<option value="">-- Select Bank --</option>';
            accountSelect.innerHTML = '<option value="">-- Select Account No --</option>';

            if (!selectedCompany) return;

            var filtered = rawBankDetails.filter(function(item) { return item.company === selectedCompany; });
            var banks = Array.from(new Set(filtered.map(function(item) { return item.bank; }))).filter(Boolean);
            banks.sort();

            banks.forEach(function(b) {
                var opt = document.createElement('option');
                opt.value = b;
                opt.textContent = b;
                bankSelect.appendChild(opt);
            });

            if (banks.length > 0) {
                bankSelect.value = banks[0];
                onBankChange();
            }
        }

        function onBankChange() {
            var selectedCompany = document.getElementById('companySelect').value;
            var selectedBank = document.getElementById('bankSelect').value;
            var accountSelect = document.getElementById('accountNumberSelect');

            accountSelect.innerHTML = '<option value="">-- Select Account No --</option>';

            if (!selectedCompany || !selectedBank) return;

            var filtered = rawBankDetails.filter(function(item) {
                return item.company === selectedCompany && item.bank === selectedBank;
            });

            var accounts = Array.from(new Set(filtered.map(function(item) { return item.account; }))).filter(Boolean);
            accounts.sort();

            accounts.forEach(function(acc) {
                var opt = document.createElement('option');
                opt.value = acc;
                opt.textContent = acc;
                accountSelect.appendChild(opt);
            });

            if (accounts.length > 0) {
                accountSelect.value = accounts[0];
            }
        }

        function getValidatedDebitAccount(expectedBankKeyword, bankDisplayName) {
            var companySelect = document.getElementById('companySelect');
            var bankSelect = document.getElementById('bankSelect');
            var accountSelect = document.getElementById('accountNumberSelect');

            if (!companySelect || !companySelect.value) {
                alert("Please select a Company Name from the Company Debit Account card.");
                if (companySelect) companySelect.focus();
                return null;
            }

            if (!bankSelect || !bankSelect.value) {
                alert("Please select " + bankDisplayName + " from the Bank dropdown.");
                if (bankSelect) bankSelect.focus();
                return null;
            }

            if (expectedBankKeyword) {
                var selectedBankUpper = bankSelect.value.toUpperCase();
                var matchesExpected = false;

                if (expectedBankKeyword === "BOM") {
                    matchesExpected = selectedBankUpper.includes("BOM") || selectedBankUpper.includes("MAHARASHTRA");
                } else if (expectedBankKeyword === "ICICI") {
                    matchesExpected = selectedBankUpper.includes("ICICI");
                }

                if (!matchesExpected) {
                    alert("Please select a " + bankDisplayName + " account from the Company Debit Account card (currently selected: " + bankSelect.value + ").");
                    bankSelect.focus();
                    return null;
                }
            }

            if (!accountSelect || !accountSelect.value || accountSelect.value.trim() === '') {
                alert("Please select an Account Number for " + bankDisplayName + ".");
                if (accountSelect) accountSelect.focus();
                return null;
            }

            return accountSelect.value.trim();
        }

        var currentPage = 1;
        var pageSize = 50;
        var totalPages = 1;

        function updatePagination() {
            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) return;

            var rows = table.tBodies[0].rows;
            if (rows.length === 1 && rows[0].cells.length === 1) return;

            var matched = [];
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].dataset.matched !== '0') matched.push(rows[i]);
            }

            totalPages = Math.max(1, Math.ceil(matched.length / pageSize));
            if (currentPage > totalPages) currentPage = totalPages;

            for (var i = 0; i < rows.length; i++) rows[i].style.display = 'none';

            var start = (currentPage - 1) * pageSize;
            var end = Math.min(matched.length, start + pageSize);
            for (var j = start; j < end; j++) matched[j].style.display = '';

            document.getElementById('pageInfo').textContent = 'Page ' + currentPage + ' of ' + totalPages;
            document.getElementById('totalBadge').textContent = 'Total Records: ' + matched.length;
        }

        function filterTableSearch() {
            currentPage = 1;
            var query = document.getElementById('tableSearch').value.toLowerCase().trim();
            var table = document.getElementById('payRegisterTable');
            var rows = table.tBodies[0].rows;

            if (rows.length === 1 && rows[0].cells.length === 1) return;

            for (var i = 0; i < rows.length; i++) {
                var text = (rows[i].innerText || rows[i].textContent).toLowerCase();
                rows[i].dataset.matched = (query === '' || text.indexOf(query) > -1) ? '1' : '0';
            }
            updatePagination();
        }

        function clearAllFilters() {
            window.location.href = 'pay-register';
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

        function getExportData() {
            var table = document.getElementById('payRegisterTable');
            var data = [];
            var headerRow = [];
            var ths = table.tHead.rows[0].cells;
            for (var h = 0; h < ths.length; h++) headerRow.push(ths[h].innerText.trim());
            data.push(headerRow);

            var rows = table.tBodies[0].rows;
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].dataset.matched === '0' || (rows.length === 1 && rows[i].cells.length === 1)) continue;
                var rowData = [];
                for (var c = 0; c < rows[i].cells.length; c++) {
                    rowData.push((rows[i].cells[c].innerText || rows[i].cells[c].textContent).trim());
                }
                data.push(rowData);
            }
            return data;
        }

        function exportExcel() {
            var data = getExportData();
            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();

            var ws = XLSX.utils.aoa_to_sheet(data);
            var wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "PayRegister");
            XLSX.writeFile(wb, "PayRegister_Report_" + dd + "-" + mm + "-" + yyyy + ".xlsx");
        }

        function exportCsv() {
            var data = getExportData();
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
            a.download = 'PayRegister_Report.csv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        /* Companion Transfer Summary Excel Sheet */
        function generateCompanionExcel(debitAccNo, pymtDate, formatName) {
            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) return;

            var rows = table.tBodies[0].rows;
            if (rows.length === 1 && rows[0].cells.length === 1) return;

            var colIndexMap = {};
            var ths = table.tHead.rows[0].cells;
            for (var c = 0; c < ths.length; c++) {
                var colName = ths[c].getAttribute('data-col-name');
                if (colName) {
                    colIndexMap[colName.toUpperCase()] = c;
                }
            }

            function getCellVal(row, colKey) {
                var idx = colIndexMap[colKey];
                if (idx !== undefined && row.cells[idx]) {
                    return (row.cells[idx].innerText || row.cells[idx].textContent).trim();
                }
                return "";
            }

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();

            var companionHeaders = [
                'EMP_CODE',
                'DOJ',
                'Designation',
                'AADHAR_NO',
                'EMP_NAME',
                'FATHER_NAME',
                'MOBILE',
                'CLUSTER',
                'ZONE',
                'CIRCLE',
                'DIV',
                'ACCOUNT_NO',
                'IFSC',
                'BRANCH_NAME',
                'BANK_NAME',
                'DB_STATUS',
                'NET_PAY',
                'TOTAL_TCS',
                'SALARY_STATUS',
                'TRANSFER_DATE',
                'DEBIT_ACCOUNT'
            ];

            var summaryRows = [companionHeaders];

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];
                if (r.dataset.matched === '0') continue;

                var dbStatus = (r.getAttribute('data-db-status') || '').trim().toLowerCase();
                if (dbStatus !== 'allow') {
                    continue;
                }

                var empCode = getCellVal(r, 'CODE');
                var doj = getCellVal(r, 'DOJ');
                var designation = getCellVal(r, 'DESIGNATION');
                var aadhar = getCellVal(r, 'AADHAAR');
                var empName = getCellVal(r, 'EMP_NAME');
                var fatherName = getCellVal(r, 'FATHER_HUSBAND_NAME');
                var mobile = getCellVal(r, 'MOBILE');
                var cluster = getCellVal(r, 'CLUSTER_NAME') || selectedCluster;
                var zone = getCellVal(r, 'BRANCH');
                var circle = getCellVal(r, 'CATEGORY');
                var div = getCellVal(r, 'DEPARTMENT');
                var accNo = getCellVal(r, 'ACCOUNT_NO');
                var ifsc = getCellVal(r, 'IFSC');
                var branchName = getCellVal(r, 'BANK_BRANCH');
                var bankName = getCellVal(r, 'BANK_NAME');
                var rowStatus = (r.getAttribute('data-db-status') || '').trim();
                var netAmt = parseFloat(getCellVal(r, 'NET_AMT_PAYABLE').replace(/,/g, '')) || 0;
                var totalTcs = parseFloat(getCellVal(r, 'TOTAL_TCS_ACT').replace(/,/g, '')) || 0;

                summaryRows.push([
                    empCode,
                    doj,
                    designation,
                    aadhar,
                    empName,
                    fatherName,
                    mobile,
                    cluster,
                    zone,
                    circle,
                    div,
                    accNo,
                    ifsc,
                    branchName,
                    bankName,
                    rowStatus,
                    netAmt,
                    totalTcs,
                    "",
                    "",
                    ""
                ]);
            }

            var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
            var monthLabel = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "ALL";
            var yearYY = (selectedYear && selectedYear.length >= 2) ? selectedYear.substring(selectedYear.length - 2) : "";

            var ws = XLSX.utils.aoa_to_sheet(summaryRows);
            ws['!cols'] = [
                { wch: 14 }, { wch: 12 }, { wch: 20 }, { wch: 16 }, { wch: 25 },
                { wch: 22 }, { wch: 14 }, { wch: 12 }, { wch: 18 }, { wch: 20 },
                { wch: 20 }, { wch: 20 }, { wch: 14 }, { wch: 18 }, { wch: 18 },
                { wch: 14 }, { wch: 14 }, { wch: 14 }, { wch: 16 }, { wch: 15 }, { wch: 18 }
            ];

            var wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, "Salary_Summary");

            var companionFileName = formatName + "_SUMMARY_DETAILS_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx";

            setTimeout(function() {
                XLSX.writeFile(wb, companionFileName);
            }, 600);
        }

        /* Download Master: Always fetches and downloads all records of the cluster from backend */
        async function downloadMaster() {
            var bankSelect = document.getElementById('bankSelect');
            var selectedBank = bankSelect ? bankSelect.value.trim() : "";
            var debitAccNo = getValidatedDebitAccount(null, selectedBank ? selectedBank : "Selected Bank");
            if (!debitAccNo) {
                return;
            }

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();
            var pymtDate = dd + '-' + mm + '-' + yyyy;

            var companionHeaders = [
                'EMP_CODE',
                'DOJ',
                'Designation',
                'AADHAR_NO',
                'EMP_NAME',
                'FATHER_NAME',
                'MOBILE',
                'CLUSTER',
                'ZONE',
                'CIRCLE',
                'DIV',
                'ACCOUNT_NO',
                'IFSC',
                'BRANCH_NAME',
                'BANK_NAME',
                'DB_STATUS',
                'NET_PAY',
                'TOTAL_TCS',
                'SALARY_STATUS',
                'TRANSFER_DATE',
                'DEBIT_ACCOUNT'
            ];

            var masterRows = [companionHeaders];

            try {
                var fetchUrl = 'pay-register?action=getMasterData' +
                               '&cluster=' + encodeURIComponent(selectedCluster || '') +
                               '&month=' + encodeURIComponent(selectedMonth || '') +
                               '&year=' + encodeURIComponent(selectedYear || '');

                var response = await fetch(fetchUrl);
                if (!response.ok) {
                    throw new Error("HTTP error " + response.status);
                }

                var allClusterRecords = await response.json();

                if (!allClusterRecords || allClusterRecords.length === 0) {
                    alert('No master records found for the selected Cluster.');
                    return;
                }

                for (var i = 0; i < allClusterRecords.length; i++) {
                    var r = allClusterRecords[i];

                    var empCode = r.CODE || r.EMP_CODE || '';
                    var doj = r.DOJ || '';
                    var designation = r.DESIGNATION || '';
                    var aadhar = r.AADHAAR || r.AADHAR || '';
                    var empName = r.EMP_NAME || '';
                    var fatherName = r.FATHER_HUSBAND_NAME || '';
                    var mobile = r.MOBILE || '';
                    var cluster = r.CLUSTER_NAME || selectedCluster || '';
                    var zone = r.BRANCH || r.ZONE || '';
                    var circle = r.CATEGORY || r.CIRCLE || '';
                    var div = r.DEPARTMENT || r.DIV || '';
                    var accNo = r.ACCOUNT_NO || '';
                    var ifsc = r.IFSC || '';
                    var branchName = r.BANK_BRANCH || r.BRANCH_NAME || '';
                    var bankName = r.BANK_NAME || '';
                    var dbStatus = r.DB_STATUS || '';
                    var netAmt = parseFloat(String(r.NET_AMT_PAYABLE || 0).replace(/,/g, '')) || 0;
                    var totalTcs = parseFloat(String(r.TOTAL_TCS_ACT || 0).replace(/,/g, '')) || 0;

                    masterRows.push([
                        empCode,
                        doj,
                        designation,
                        aadhar,
                        empName,
                        fatherName,
                        mobile,
                        cluster,
                        zone,
                        circle,
                        div,
                        accNo,
                        ifsc,
                        branchName,
                        bankName,
                        dbStatus,
                        netAmt,
                        totalTcs,
                        "",
                        "",
                        ""
                    ]);
                }

                var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
                var monthLabel = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "ALL";
                var yearYY = (selectedYear && selectedYear.length >= 2) ? selectedYear.substring(selectedYear.length - 2) : "";

                var ws = XLSX.utils.aoa_to_sheet(masterRows);
                ws['!cols'] = [
                    { wch: 14 }, { wch: 12 }, { wch: 20 }, { wch: 16 }, { wch: 25 },
                    { wch: 22 }, { wch: 14 }, { wch: 12 }, { wch: 18 }, { wch: 20 },
                    { wch: 20 }, { wch: 20 }, { wch: 14 }, { wch: 18 }, { wch: 18 },
                    { wch: 14 }, { wch: 14 }, { wch: 14 }, { wch: 16 }, { wch: 15 }, { wch: 18 }
                ];

                var wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Master_Details");

                var bankPrefix = selectedBank ? selectedBank.replace(/[^a-zA-Z0-9_-]/g, '_') + "_" : "";
                var masterFileName = "MASTER_DETAILS_" + bankPrefix + clusterLabel + "_" + monthLabel + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx";

                XLSX.writeFile(wb, masterFileName);

            } catch (err) {
                console.error("Error downloading master:", err);
                alert("Failed to download master data: " + err.message);
            }
        }

        /* ICICI Bank Format Multi-Excel */
        async function exportIciciFormat() {
            var debitAccNo = getValidatedDebitAccount("ICICI", "ICICI Bank");
            if (!debitAccNo) {
                return;
            }

            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) {
                alert('No table data found.');
                return;
            }

            var rows = table.tBodies[0].rows;
            if (rows.length === 1 && rows[0].cells.length === 1) {
                alert('No records available to export for the selected filters.');
                return;
            }

            var colIndexMap = {};
            var ths = table.tHead.rows[0].cells;
            for (var c = 0; c < ths.length; c++) {
                var colName = ths[c].getAttribute('data-col-name');
                if (colName) {
                    colIndexMap[colName.toUpperCase()] = c;
                }
            }

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();
            var pymtDate = dd + '-' + mm + '-' + yyyy;

            var yearYY = "";
            if (selectedYear && selectedYear.length >= 2) {
                yearYY = selectedYear.substring(selectedYear.length - 2);
            } else {
                yearYY = String(yyyy).substring(2);
            }

            var narrMonth = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "";
            var creditNarr = ("SALARY " + narrMonth + " " + yearYY).replace(/\s+/g, ' ').trim();

            var iciciHeaders = [
                'PYMT_PROD_TYPE_CODE',
                'PYMT_MODE',
                'DEBIT_ACC_NO',
                'BNF_NAME',
                'BENE_ACC_NO',
                'BENE_IFSC',
                'AMOUNT',
                'CREDIT_NARR',
                'PYMT_DATE',
                'MOBILE_NUM',
                'EMAIL_ID',
                'REMARK',
                'REF_NO'
            ];

            var generatedRows = [];

            function getCellVal(row, colKey) {
                var idx = colIndexMap[colKey];
                if (idx !== undefined && row.cells[idx]) {
                    return (row.cells[idx].innerText || row.cells[idx].textContent).trim();
                }
                return "";
            }

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];

                if (r.dataset.matched === '0') {
                    continue;
                }

                var dbStatus = (r.getAttribute('data-db-status') || '').trim().toLowerCase();
                if (dbStatus !== 'allow') {
                    continue;
                }

                var empName = getCellVal(r, 'EMP_NAME')
                    .replace(/\./g, ' ')
                    .replace(/[^a-zA-Z0-9\s]/g, '')
                    .replace(/\s+/g, ' ')
                    .trim();

                var ifsc = getCellVal(r, 'IFSC');
                var accNo = getCellVal(r, 'ACCOUNT_NO');
                var totalTcs = getCellVal(r, 'TOTAL_TCS_ACT');
                var netAmt = getCellVal(r, 'NET_AMT_PAYABLE');
                var mobile = "";
                var email = "";
                var remark = "";

                var pymtMode = "NEFT";
                if (ifsc && ifsc.toUpperCase().startsWith("ICIC")) {
                    pymtMode = "FT";
                }

                var amt1 = parseFloat(totalTcs.replace(/,/g, '')) || 0;
                if (amt1 > 0) {
                    generatedRows.push([
                        "PAB_VENDOR",
                        pymtMode,
                        debitAccNo,
                        empName,
                        accNo,
                        ifsc,
                        amt1,
                        creditNarr,
                        pymtDate,
                        mobile,
                        email,
                        remark,
                        ""
                    ]);
                }

                var amt2 = parseFloat(netAmt.replace(/,/g, '')) || 0;
                if (amt2 > 0) {
                    generatedRows.push([
                        "PAB_VENDOR",
                        pymtMode,
                        debitAccNo,
                        empName,
                        accNo,
                        ifsc,
                        amt2,
                        creditNarr,
                        pymtDate,
                        mobile,
                        email,
                        remark,
                        ""
                    ]);
                }
            }

            if (generatedRows.length === 0) {
                alert('No valid records with DB_STATUS = "Allow" found for the active filters.');
                return;
            }

            var maxRecordsPerSheet = 199;
            var totalFiles = Math.ceil(generatedRows.length / maxRecordsPerSheet);

            var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
            var monthLabel = narrMonth !== "" ? narrMonth : "ALL";

            if (totalFiles === 1) {
                var sheetData = [iciciHeaders].concat(generatedRows);
                var ws = XLSX.utils.aoa_to_sheet(sheetData);
                ws['!cols'] = [
                    { wch: 22 }, { wch: 12 }, { wch: 18 }, { wch: 26 },
                    { wch: 20 }, { wch: 15 }, { wch: 12 }, { wch: 24 },
                    { wch: 14 }, { wch: 15 }, { wch: 25 }, { wch: 15 }, { wch: 12 }
                ];
                var wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, "Split 1");
                XLSX.writeFile(wb, "ICICI_SAL_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx");
            } else {
                var zip = new JSZip();

                for (var fileIdx = 0; fileIdx < totalFiles; fileIdx++) {
                    var start = fileIdx * maxRecordsPerSheet;
                    var end = Math.min(generatedRows.length, start + maxRecordsPerSheet);
                    var chunk = generatedRows.slice(start, end);

                    var sheetData = [iciciHeaders].concat(chunk);
                    var ws = XLSX.utils.aoa_to_sheet(sheetData);

                    ws['!cols'] = [
                        { wch: 22 }, { wch: 12 }, { wch: 18 }, { wch: 26 },
                        { wch: 20 }, { wch: 15 }, { wch: 12 }, { wch: 24 },
                        { wch: 14 }, { wch: 15 }, { wch: 25 }, { wch: 15 }, { wch: 12 }
                    ];

                    var wb = XLSX.utils.book_new();
                    XLSX.utils.book_append_sheet(wb, ws, "Split " + (fileIdx + 1));

                    var wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
                    var excelFileName = "ICICI_SAL_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_Part" + (fileIdx + 1) + "_of_" + totalFiles + "_" + dd + "-" + mm + "-" + yyyy + ".xlsx";

                    zip.file(excelFileName, wbout);
                }

                var zipBlob = await zip.generateAsync({ type: "blob" });
                var zipFileName = "ICICI_SAL_" + clusterLabel + "_" + monthLabel + "_" + yearYY + "_AllParts (" + totalFiles + " Files)_" + dd + "-" + mm + "-" + yyyy + ".zip";

                var link = document.createElement("a");
                link.href = URL.createObjectURL(zipBlob);
                link.download = zipFileName;
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                URL.revokeObjectURL(link.href);
            }

            generateCompanionExcel(debitAccNo, pymtDate, "ICICI");
        }

        /* BOM Bank Pipe-Delimited (.txt) Export Implementation */
        function exportBomTxtFormat() {
            var debitAccNo = getValidatedDebitAccount("BOM", "Bank of Maharashtra (BOM)");
            if (!debitAccNo) {
                return;
            }

            var table = document.getElementById('payRegisterTable');
            if (!table || !table.tBodies || !table.tBodies[0]) {
                alert('No table data found.');
                return;
            }

            var rows = table.tBodies[0].rows;
            if (rows.length === 1 && rows[0].cells.length === 1) {
                alert('No records available to export for the selected filters.');
                return;
            }

            var colIndexMap = {};
            var ths = table.tHead.rows[0].cells;
            for (var c = 0; c < ths.length; c++) {
                var colName = ths[c].getAttribute('data-col-name');
                if (colName) {
                    colIndexMap[colName.toUpperCase()] = c;
                }
            }

            var now = new Date();
            var dd = String(now.getDate()).padStart(2, '0');
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var yyyy = now.getFullYear();
            var pymtDate = dd + '-' + mm + '-' + yyyy;

            var yearYY = "";
            if (selectedYear && selectedYear.length >= 2) {
                yearYY = selectedYear.substring(selectedYear.length - 2);
            } else {
                yearYY = String(yyyy).substring(2);
            }

            var narrMonth = selectedMonth && selectedMonth.trim() !== "" ? selectedMonth.trim() : "";
            var creditNarr = ("SALARY " + narrMonth + " " + yearYY).replace(/\s+/g, ' ').trim();

            var clusterLabel = selectedCluster ? "CL" + selectedCluster : "ALL_CLUSTERS";
            var monthLabel = narrMonth !== "" ? narrMonth : "ALL";
            var divisionLabel = (document.querySelectorAll('.divisionCheckbox:checked').length === 1)
                ? document.querySelector('.divisionCheckbox:checked').value.replace(/[^a-zA-Z0-9_-]/g, '_')
                : "ALL_DIVISIONS";
            var txtFileName = "BOM_SAL_" + clusterLabel + "_" + divisionLabel + "_" + monthLabel + "_" + yearYY + "_" + dd + "-" + mm + "-" + yyyy + ".txt";

            var bomHeaders = [
                'Debit Account No',
                'Mode of Payment',
                'Benf Account No',
                'Benf Name',
                'Amount',
                'Benf Add1',
                'Benf Add2',
                'Benf Add3',
                'Benf PinCode',
                'Benf Mobile No',
                'Benf email ID',
                'DD Payable At',
                'Benf IFSC',
                'Branch Name',
                'Bank Name',
                'Benf Account Type',
                'Narration1',
                'Narration2',
                'Payment Ref No'
            ];

            var textLines = [];
            textLines.push(bomHeaders.join('|'));

            function getCellVal(row, colKey) {
                var idx = colIndexMap[colKey];
                if (idx !== undefined && row.cells[idx]) {
                    return (row.cells[idx].innerText || row.cells[idx].textContent).trim();
                }
                return "";
            }

            var recordCounter = 1;

            for (var i = 0; i < rows.length; i++) {
                var r = rows[i];

                if (r.dataset.matched === '0') {
                    continue;
                }

                var dbStatus = (r.getAttribute('data-db-status') || '').trim().toLowerCase();
                if (dbStatus !== 'allow') {
                    continue;
                }

                var empName = getCellVal(r, 'EMP_NAME')
                    .replace(/\./g, ' ')
                    .replace(/[^a-zA-Z0-9\s]/g, '')
                    .replace(/\s+/g, ' ')
                    .trim();

                var ifsc = getCellVal(r, 'IFSC');
                var accNo = getCellVal(r, 'ACCOUNT_NO');
                var totalTcs = getCellVal(r, 'TOTAL_TCS_ACT');
                var netAmt = getCellVal(r, 'NET_AMT_PAYABLE');
                var bankName = getCellVal(r, 'BANK_NAME');
                var branchName = getCellVal(r, 'BANK_BRANCH');

                var benfAdd1 = "";
                var benfAdd2 = "";
                var benfAdd3 = "";
                var benfPinCode = "";
                var benfMobile = "";
                var benfEmail = "";
                var ddPayableAt = "";
                var benfAccountType = "SA";
                var narration2 = "";

                var pymtMode = "N";
                if (ifsc && ifsc.toUpperCase().startsWith("MAHB")) {
                    pymtMode = "I";
                }

                var amt1 = parseFloat(totalTcs.replace(/,/g, '')) || 0;
                if (amt1 > 0) {
                    var refNo1 = clusterLabel + '/' + pymtDate + '/' + recordCounter++;
                    textLines.push([
                        debitAccNo,
                        pymtMode,
                        accNo,
                        empName,
                        amt1,
                        benfAdd1,
                        benfAdd2,
                        benfAdd3,
                        benfPinCode,
                        benfMobile,
                        benfEmail,
                        ddPayableAt,
                        ifsc,
                        branchName,
                        bankName,
                        benfAccountType,
                        creditNarr,
                        narration2,
                        refNo1
                    ].join('|'));
                }

                var amt2 = parseFloat(netAmt.replace(/,/g, '')) || 0;
                if (amt2 > 0) {
                    var refNo2 = clusterLabel + '/' + pymtDate + '/' + recordCounter++;
                    textLines.push([
                        debitAccNo,
                        pymtMode,
                        accNo,
                        empName,
                        amt2,
                        benfAdd1,
                        benfAdd2,
                        benfAdd3,
                        benfPinCode,
                        benfMobile,
                        benfEmail,
                        ddPayableAt,
                        ifsc,
                        branchName,
                        bankName,
                        benfAccountType,
                        creditNarr,
                        narration2,
                        refNo2
                    ].join('|'));
                }
            }

            if (textLines.length <= 1) {
                alert('No valid records with DB_STATUS = "Allow" found for the active filters.');
                return;
            }

            var blob = new Blob([textLines.join('\r\n')], { type: 'text/plain;charset=utf-8;' });
            var link = document.createElement("a");
            link.href = URL.createObjectURL(blob);
            link.download = txtFileName;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(link.href);

            generateCompanionExcel(debitAccNo, pymtDate, "BOM");
        }

        document.addEventListener('DOMContentLoaded', function() {
            initCompanyBankDropdowns();
            updateDropdownButtonLabel('zone');
            updateDropdownButtonLabel('circle');
            updateDropdownButtonLabel('division');
            updateDropdownButtonLabel('designation');
            updateDropdownButtonLabel('dbStatus');
            updatePagination();
        });
    </script>
</body>
</html>