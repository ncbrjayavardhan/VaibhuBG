<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Prevent client-side caching of authenticated pages
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String currentUser = (String) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("loginpage.jsp?msg=session_expired");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portion Details Management</title>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            margin: 0; padding: 30px; background-color: #f4f6f9; color: #333333;
        }
        .container { max-width: 1300px; margin: 0 auto; }
        .card {
            background-color: #ffffff; border-radius: 10px; padding: 24px 28px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06); border: 1px solid #e9ecef;
        }
        .header-bar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 22px; padding-bottom: 16px; border-bottom: 1px solid #edf2f7; flex-wrap: wrap; gap: 12px;
        }
        .header-title-group h2 { margin: 0; color: #1f4e78; font-size: 21px; font-weight: 700; }
        .header-title-group p { margin: 4px 0 0 0; font-size: 13px; color: #6c757d; }
        .action-buttons { display: flex; gap: 8px; align-items: center; }
        .btn {
            padding: 8px 16px; color: white; text-decoration: none; border-radius: 6px;
            font-size: 13px; font-weight: 600; display: inline-flex; align-items: center;
            justify-content: center; border: none; cursor: pointer; transition: all 0.2s;
        }
        .btn-dash { background-color: #6c757d; }
        .btn-report { background-color: #1f4e78; }
        .btn-edit-icon {
            background-color: #e8f0fe; color: #007bff; border: 1px solid #cce0ff;
            border-radius: 6px; width: 32px; height: 32px; display: inline-flex;
            align-items: center; justify-content: center; cursor: pointer; padding: 0; transition: all 0.2s;
        }
        .btn-edit-icon:hover { background-color: #007bff; color: #ffffff; border-color: #007bff; }
        .btn-edit-icon svg { width: 15px; height: 15px; fill: currentColor; }
        .alert-success { background-color: #d4edda; color: #155724; padding: 12px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 13.5px; }
        .alert-danger { background-color: #f8d7da; color: #721c24; padding: 12px 18px; border-radius: 6px; margin-bottom: 20px; font-size: 13.5px; }
        .table-responsive { overflow-x: auto; border-radius: 8px; border: 1px solid #c8d1dc; background: #ffffff; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; text-align: center; }
        th, td { border: 1px solid #e2e8f0; padding: 10px 14px; white-space: nowrap; text-align: center; }
        th { background-color: #1f4e78; color: #ffffff; font-weight: 600; vertical-align: middle; }
        tbody tr:nth-child(even) { background-color: #f8fafc; }
        tbody tr:hover { background-color: #edf5fc; }
        
        /* Centered & Merged Hierarchy Cells */
        .ga-cell, .city-cell, .state-cell { font-weight: 600; color: #2d3748; text-align: center; }
        td.merged-cell {
            text-align: center;
            vertical-align: middle;
            font-weight: 700;
            color: #1f4e78;
            background-color: #ffffff !important;
        }
        
        .filter-header-cell { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 6px; }
        .filter-label { font-size: 13px; font-weight: 600; color: #ffffff; }
        .pill-select {
            background-color: #ffffff; color: #1f4e78; border: 1px solid #ffffff;
            border-radius: 16px; padding: 3px 10px; font-size: 11px; font-weight: 700;
            outline: none; cursor: pointer; max-width: 120px; text-align: center;
        }
        .pid-pill { background-color: #e8f0fe; color: #1f4e78; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 12px; border: 1px solid #cce0ff; display: inline-block; }
        .pid-pill-unset { background-color: #fde8e8; color: #dc3545; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 12px; border: 1px solid #f8b4b4; display: inline-block; }
        
        /* Modal Styles */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(15, 23, 42, 0.55); display: none; align-items: center; justify-content: center; z-index: 1000; padding: 20px; }
        .modal-overlay.active { display: flex; }
        .modal-card { background: #ffffff; border-radius: 10px; width: 100%; max-width: 480px; padding: 24px 28px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.15); }
        .modal-header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #eef2f5; padding-bottom: 12px; margin-bottom: 18px; }
        .modal-header h3 { margin: 0; color: #1f4e78; font-size: 18px; font-weight: 700; }
        .close-btn { background: none; border: none; font-size: 20px; color: #a0aec0; cursor: pointer; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; margin-bottom: 6px; font-size: 13px; font-weight: 600; color: #495057; }
        .form-group input { width: 100%; padding: 8px 12px; border: 1px solid #ced4da; border-radius: 5px; font-size: 13px; outline: none; }
        .form-group input[readonly] { background-color: #e9ecef; cursor: not-allowed; }
        .modal-footer { display: flex; justify-content: flex-end; gap: 10px; margin-top: 22px; padding-top: 14px; border-top: 1px solid #edf2f7; }
        .btn-save { background-color: #28a745; color: white; }
        .btn-cancel { background-color: #6c757d; color: white; }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <div class="header-bar">
            <div class="header-title-group">
                <h2>Portion Details Management</h2>
                <p>Configure schedules, target volumes, and billing periods</p>
            </div>
            <div class="action-buttons">
                <a href="dashboard.jsp" class="btn btn-dash">Dashboard</a>
                <a href="ReportServlet" class="btn btn-report">View Report</a>
            </div>
        </div>

        <c:if test="${param.msg eq 'success'}"><div class="alert-success">&#10003; Record updated successfully!</div></c:if>
        <c:if test="${param.msg eq 'error'}"><div class="alert-danger">Failed to save changes. Please verify inputs.</div></c:if>

        <div class="table-responsive">
            <table id="portionTable">
                <thead>
                    <tr>
                        <!-- State Dropdown -->
                        <th>
                            <div class="filter-header-cell">
                                <span class="filter-label">State</span>
                                <select id="stateFilter" class="pill-select" onchange="onStateChange()">
                                    <option value="ALL">All States</option>
                                </select>
                            </div>
                        </th>
                        <!-- City Dropdown -->
                        <th>
                            <div class="filter-header-cell">
                                <span class="filter-label">City</span>
                                <select id="cityFilter" class="pill-select" onchange="onCityChange()">
                                    <option value="ALL">All Cities</option>
                                </select>
                            </div>
                        </th>
                        <!-- GA Dropdown -->
                        <th>
                            <div class="filter-header-cell">
                                <span class="filter-label">GA</span>
                                <select id="gaFilter" class="pill-select" onchange="onGaChange()">
                                    <option value="ALL">All GA</option>
                                </select>
                            </div>
                        </th>
                        <!-- Portion ID (PID) Dropdown -->
                        <th>
                            <div class="filter-header-cell">
                                <span class="filter-label">Portion ID (PID)</span>
                                <select id="portionFilter" class="pill-select" onchange="applyFilters()">
                                    <option value="ALL">All</option>
                                </select>
                            </div>
                        </th>

                        <th>Total Data</th>
                        <th>Start Date</th>
                        <th>End Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${portionList}">
                        <tr class="data-row" 
                            data-vid="${p.vid}"
                            data-state="${p.state != null ? p.state : '-'}"
                            data-city="${p.city != null ? p.city : '-'}"
                            data-ga="${p.ga != null ? p.ga : '-'}" 
                            data-portion="${p.pid}"
                            data-totaldata="${p.totalData != null ? p.totalData : ''}"
                            data-startdate="${p.startDate != null ? p.startDate : ''}"
                            data-enddate="${p.endDate != null ? p.endDate : ''}">
                            
                            <td class="state-cell">${p.state != null ? p.state : '-'}</td>
                            <td class="city-cell">${p.city != null ? p.city : '-'}</td>
                            <td class="ga-cell">${p.ga != null ? p.ga : '-'}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${p.invStatus eq 1}"><span class="pid-pill">${p.pid}</span></c:when>
                                    <c:otherwise><span class="pid-pill-unset" title="inv_status is not set">${p.pid}</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>${p.totalData != null ? p.totalData : '<span style="color:#a0aec0;">Not Set</span>'}</td>
                            <td>${p.startDate != null ? p.startDate : '<span style="color:#a0aec0;">Not Set</span>'}</td>
                            <td>${p.endDate != null ? p.endDate : '<span style="color:#a0aec0;">Not Set</span>'}</td>
                            <td>
                                <button type="button" class="btn-edit-icon" title="Edit Portion ${p.pid}"
                                        onclick="openEditModal('${p.vid}', '${p.state}', '${p.city}', '${p.ga}', '${p.pid}', '${p.totalData}', '${p.startDate}', '${p.endDate}')">
                                    <svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal Popup Dialog for Editing -->
<div id="editModal" class="modal-overlay" onclick="if(event.target===this)closeEditModal();">
    <div class="modal-card">
        <div class="modal-header">
            <h3 id="modalTitle">Edit Portion Details</h3>
            <button type="button" class="close-btn" onclick="closeEditModal()">&times;</button>
        </div>
        
        <form id="editForm" action="PortionDetailsServlet" method="post">
            <input type="hidden" id="modalVid" name="vid" />
            <input type="hidden" id="modalState" name="state" />
            <input type="hidden" id="modalCity" name="city" />
            <input type="hidden" id="modalGa" name="ga" />

            <div class="form-group">
                <label for="modalPid">Portion ID (PID)</label>
                <input type="number" id="modalPid" name="pid" readonly />
            </div>
            <div class="form-group">
                <label for="modalTotalData">Total Data (Target Count)</label>
                <input type="number" id="modalTotalData" name="totalData" placeholder="e.g. 1500" min="0" />
            </div>
            <div class="form-group">
                <label for="modalStartDate">Start Date</label>
                <input type="date" id="modalStartDate" name="startDate" required />
            </div>
            <div class="form-group">
                <label for="modalEndDate">End Date</label>
                <input type="date" id="modalEndDate" name="endDate" required />
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-cancel" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn btn-save">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<script>
var allRows = [];

function initFilters() {
    allRows = Array.from(document.querySelectorAll(".data-row")).map(function(row) {
        return {
            element: row,
            vid: (row.getAttribute("data-vid") || "").trim(),
            state: (row.getAttribute("data-state") || "").trim(),
            city: (row.getAttribute("data-city") || "").trim(),
            ga: (row.getAttribute("data-ga") || "").trim(),
            portion: (row.getAttribute("data-portion") || "").trim()
        };
    });

    updateStateDropdown();
    updateCityDropdown();
    updateGaDropdown();
    updatePortionDropdown();
    applyFilters();
}

function onStateChange() {
    document.getElementById("cityFilter").value = "ALL";
    document.getElementById("gaFilter").value = "ALL";
    document.getElementById("portionFilter").value = "ALL";

    updateCityDropdown();
    updateGaDropdown();
    updatePortionDropdown();
    applyFilters();
}

function onCityChange() {
    document.getElementById("gaFilter").value = "ALL";
    document.getElementById("portionFilter").value = "ALL";

    updateGaDropdown();
    updatePortionDropdown();
    applyFilters();
}

function onGaChange() {
    document.getElementById("portionFilter").value = "ALL";

    updatePortionDropdown();
    applyFilters();
}

function updateStateDropdown() {
    var stateSelect = document.getElementById("stateFilter");
    var currentState = stateSelect.value;
    var uniqueStates = Array.from(new Set(allRows.map(r => r.state).filter(s => s && s !== "-"))).sort();
    
    stateSelect.innerHTML = '<option value="ALL">All States</option>';
    uniqueStates.forEach(function(st) {
        var opt = document.createElement("option");
        opt.value = st;
        opt.textContent = st;
        stateSelect.appendChild(opt);
    });
    if (uniqueStates.includes(currentState)) {
        stateSelect.value = currentState;
    }
}

function updateCityDropdown() {
    var selectedState = document.getElementById("stateFilter").value;
    var citySelect = document.getElementById("cityFilter");
    var currentCity = citySelect.value;

    var validRows = allRows.filter(function(r) {
        return (selectedState === "ALL" || r.state === selectedState);
    });

    var uniqueCities = Array.from(new Set(validRows.map(r => r.city).filter(c => c && c !== "-"))).sort();
    
    citySelect.innerHTML = '<option value="ALL">All Cities</option>';
    uniqueCities.forEach(function(city) {
        var opt = document.createElement("option");
        opt.value = city;
        opt.textContent = city;
        citySelect.appendChild(opt);
    });

    if (uniqueCities.includes(currentCity)) {
        citySelect.value = currentCity;
    } else {
        citySelect.value = "ALL";
    }
}

function updateGaDropdown() {
    var selectedState = document.getElementById("stateFilter").value;
    var selectedCity = document.getElementById("cityFilter").value;
    var gaSelect = document.getElementById("gaFilter");
    var currentGa = gaSelect.value;

    var validRows = allRows.filter(function(r) {
        return (selectedState === "ALL" || r.state === selectedState) &&
               (selectedCity === "ALL" || r.city === selectedCity);
    });

    var uniqueGAs = Array.from(new Set(validRows.map(r => r.ga).filter(g => g && g !== "-"))).sort();
    
    gaSelect.innerHTML = '<option value="ALL">All GA</option>';
    uniqueGAs.forEach(function(ga) {
        var opt = document.createElement("option");
        opt.value = ga;
        opt.textContent = ga;
        gaSelect.appendChild(opt);
    });

    if (uniqueGAs.includes(currentGa)) {
        gaSelect.value = currentGa;
    } else {
        gaSelect.value = "ALL";
    }
}

function updatePortionDropdown() {
    var selectedState = document.getElementById("stateFilter").value;
    var selectedCity = document.getElementById("cityFilter").value;
    var selectedGa = document.getElementById("gaFilter").value;
    var portionSelect = document.getElementById("portionFilter");
    var currentPortion = portionSelect.value;

    var validRows = allRows.filter(function(r) {
        return (selectedState === "ALL" || r.state === selectedState) &&
               (selectedCity === "ALL" || r.city === selectedCity) &&
               (selectedGa === "ALL" || r.ga === selectedGa);
    });

    var uniquePortions = Array.from(new Set(validRows.map(r => r.portion).filter(Boolean)))
                              .sort(function(a, b) { return a - b; });

    portionSelect.innerHTML = '<option value="ALL">All</option>';
    uniquePortions.forEach(function(p) {
        var opt = document.createElement("option");
        opt.value = p;
        opt.textContent = p;
        portionSelect.appendChild(opt);
    });

    if (uniquePortions.includes(currentPortion)) {
        portionSelect.value = currentPortion;
    } else {
        portionSelect.value = "ALL";
    }
}

/**
 * Dynamically merges consecutive rows sharing identical State, City, and GA values
 */
function mergeHierarchyCells() {
    var visibleRows = allRows.map(r => r.element).filter(el => el.style.display !== "none");
    
    // Reset all cells first
    allRows.forEach(function(r) {
        for (var c = 0; c < 3; c++) {
            var cell = r.element.cells[c];
            if (cell) {
                cell.rowSpan = 1;
                cell.style.display = "";
                cell.classList.remove("merged-cell");
            }
        }
    });

    // Merge State (col 0), City (col 1), and GA (col 2)
    // 1. Merge State
    var i = 0;
    while (i < visibleRows.length) {
        var firstRow = visibleRows[i];
        var currentState = firstRow.getAttribute("data-state");
        var spanCount = 1;

        var j = i + 1;
        while (j < visibleRows.length && visibleRows[j].getAttribute("data-state") === currentState) {
            visibleRows[j].cells[0].style.display = "none";
            spanCount++;
            j++;
        }
        if (spanCount > 1) {
            firstRow.cells[0].rowSpan = spanCount;
            firstRow.cells[0].classList.add("merged-cell");
        }
        i = j;
    }

    // 2. Merge City (within same state group)
    i = 0;
    while (i < visibleRows.length) {
        var firstRow = visibleRows[i];
        var currentState = firstRow.getAttribute("data-state");
        var currentCity = firstRow.getAttribute("data-city");
        var spanCount = 1;

        var j = i + 1;
        while (j < visibleRows.length && 
               visibleRows[j].getAttribute("data-state") === currentState && 
               visibleRows[j].getAttribute("data-city") === currentCity) {
            visibleRows[j].cells[1].style.display = "none";
            spanCount++;
            j++;
        }
        if (spanCount > 1) {
            firstRow.cells[1].rowSpan = spanCount;
            firstRow.cells[1].classList.add("merged-cell");
        }
        i = j;
    }

    // 3. Merge GA (within same city group)
    i = 0;
    while (i < visibleRows.length) {
        var firstRow = visibleRows[i];
        var currentCity = firstRow.getAttribute("data-city");
        var currentGa = firstRow.getAttribute("data-ga");
        var spanCount = 1;

        var j = i + 1;
        while (j < visibleRows.length && 
               visibleRows[j].getAttribute("data-city") === currentCity && 
               visibleRows[j].getAttribute("data-ga") === currentGa) {
            visibleRows[j].cells[2].style.display = "none";
            spanCount++;
            j++;
        }
        if (spanCount > 1) {
            firstRow.cells[2].rowSpan = spanCount;
            firstRow.cells[2].classList.add("merged-cell");
        }
        i = j;
    }
}

function applyFilters() {
    var vState = document.getElementById("stateFilter").value;
    var vCity = document.getElementById("cityFilter").value;
    var vGa = document.getElementById("gaFilter").value;
    var vPortion = document.getElementById("portionFilter").value;

    allRows.forEach(function(row) {
        var matchState = (vState === "ALL" || row.state === vState);
        var matchCity = (vCity === "ALL" || row.city === vCity);
        var matchGa = (vGa === "ALL" || row.ga === vGa);
        var matchPortion = (vPortion === "ALL" || row.portion === vPortion);

        if (matchState && matchCity && matchGa && matchPortion) {
            row.element.style.display = "";
        } else {
            row.element.style.display = "none";
        }
    });

    mergeHierarchyCells();
}

function openEditModal(vid, state, city, ga, pid, totalData, startDate, endDate) {
    document.getElementById("modalTitle").innerText = "Edit Portion: " + pid + " (" + ga + ")";
    document.getElementById("modalVid").value = vid;
    document.getElementById("modalState").value = state;
    document.getElementById("modalCity").value = city;
    document.getElementById("modalGa").value = ga;
    document.getElementById("modalPid").value = pid;
    document.getElementById("modalTotalData").value = (totalData === 'null' || !totalData) ? '' : totalData;
    document.getElementById("modalStartDate").value = (startDate === 'null' || !startDate) ? '' : startDate;
    document.getElementById("modalEndDate").value = (endDate === 'null' || !endDate) ? '' : endDate;

    document.getElementById("editModal").classList.add("active");
}

function closeEditModal() {
    document.getElementById("editModal").classList.remove("active");
}

document.addEventListener("DOMContentLoaded", function() {
    if (document.getElementById("portionTable")) {
        initFilters();
    }
});
</script>

</body>
</html>