<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <title>BG Report</title>
  <style>
    /* Base page body styling */
    body { 
      margin: 0;
      padding: 0;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
      background: #f5f7fb; 
      color: #333;
    }

    /* Outer wrapper */
    .report-wrapper {
      padding: 20px;
    }

    /* Container card */
    .report-container { 
      max-width: 1380px; 
      margin: 0 auto; 
      background: #fff; 
      padding: 24px; 
      border-radius: 8px; 
      box-shadow: 0 2px 10px rgba(0,0,0,.06); 
      box-sizing: border-box;
    }

    .report-container * {
      box-sizing: border-box;
    }

    .report-container h1 { 
      text-align: center; 
      color: #2c3e50; 
      margin-top: 0;
      margin-bottom: 20px; 
      font-size: 24px;
    }

    /* Filter Form Alignment */
    .filter-card {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 16px;
      margin-bottom: 20px;
    }

    .filter-form {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
      align-items: flex-end;
    }

    .filter-group {
      display: flex;
      flex-direction: column;
      gap: 6px;
      position: relative;
    }

    .filter-group label {
      font-size: 13px;
      font-weight: 600;
      color: #475569;
    }

    .filter-group input, 
    .filter-group select {
      padding: 8px 12px;
      border: 1px solid #cbd5e1;
      border-radius: 4px;
      font-size: 14px;
      height: 38px;
      min-width: 180px;
      background-color: #fff;
    }

    .filter-group input:focus, 
    .filter-group select:focus {
      outline: none;
      border-color: #2f6fdb;
      box-shadow: 0 0 0 2px rgba(47, 111, 219, 0.15);
    }

    .filter-actions {
      display: flex;
      gap: 8px;
      align-items: center;
      height: 38px;
    }

    .btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 0 16px;
      height: 38px;
      border-radius: 4px;
      font-weight: 600;
      font-size: 14px;
      text-decoration: none;
      border: none;
      cursor: pointer;
      transition: background-color 0.2s ease;
    }

    .btn-primary { background: #2f6fdb; color: #fff; }
    .btn-primary:hover { background: #1e58be; }

    .btn-danger { background: #ef4444; color: #fff; }
    .btn-danger:hover { background: #dc2626; }

    .btn-excel { background: #10b981; color: #fff; }
    .btn-excel:hover { background: #059669; }

    .btn-pdf { background: #f43f5e; color: #fff; }
    .btn-pdf:hover { background: #e11d48; }

    .btn-print { background: #0284c7; color: #fff; }
    .btn-print:hover { background: #0369a1; }

    /* Toolbar bar */
    .toolbar-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      flex-wrap: wrap;
      gap: 12px;
    }

    .export-controls {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    /* Alignment Utility Classes */
    .text-left { text-align: left !important; }
    .text-center { text-align: center !important; }
    .text-right { text-align: right !important; }

    /* Table Formatting & Sorting/Filter Styles */
    .report-table { 
      width: 100%; 
      border-collapse: collapse; 
      margin-top: 8px;
      font-size: 14px;
    }

    .report-table thead th { 
      background: #2f6fdb; 
      color: #fff; 
      padding: 10px; 
      font-weight: 600;
      border: 1px solid #255ec0;
      user-select: none;
      vertical-align: middle;
    }

    .report-table thead th.sortable {
      cursor: pointer;
    }

    .report-table thead th.sortable:hover {
      background: #1e58be;
    }

    .sort-icon {
      display: inline-block;
      margin-left: 4px;
      font-size: 11px;
      opacity: 0.6;
    }

    .report-table thead tr.filter-row th {
      background: #eef2ff;
      border-color: #cbd5e1;
      padding: 6px 4px;
    }

    .column-filter {
      width: 100%;
      padding: 4px 6px;
      font-size: 12px;
      border: 1px solid #cbd5e1;
      border-radius: 3px;
      background: #fff;
      color: #333;
      box-sizing: border-box;
    }

    .column-filter:focus {
      outline: none;
      border-color: #2f6fdb;
    }

    .report-table tbody td { 
      padding: 10px; 
      border-bottom: 1px solid #e2e8f0; 
      vertical-align: middle; 
    }

    .report-table tbody tr:nth-child(even) { 
      background: #f8fafc; 
    }

    .report-table tbody tr:hover { 
      background: #f1f5f9; 
    }

    /* Edit Hyperlink Styling */
    .edit-link {
      color: #2f6fdb;
      text-decoration: none;
      font-weight: 600;
    }

    .edit-link:hover {
      text-decoration: underline;
      color: #1e58be;
    }

    /* Badges */
    .expired { color: #dc2626; font-weight: bold; }
    .warning { color: #d97706; font-weight: bold; }
    .ok { color: #16a34a; font-weight: 600; }
    .no-data { text-align: center; color: #64748b; padding: 40px 0; font-size: 16px; }

    /* Pagination */
    .pagination-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 16px;
      padding-top: 12px;
      border-top: 1px solid #e2e8f0;
      font-size: 14px;
      color: #64748b;
    }

    .pagination-links {
      display: flex;
      gap: 6px;
      align-items: center;
    }

    .page-btn {
      padding: 6px 12px;
      border: 1px solid #cbd5e1;
      border-radius: 4px;
      text-decoration: none;
      color: #334155;
      background: #fff;
    }

    .page-btn:hover { background: #f1f5f9; }
    .page-btn.disabled { color: #94a3b8; border-color: #e2e8f0; cursor: default; background: #f8fafc; }

    @media print {
      .no-print { display: none !important; }
      body { background: white; }
      .report-wrapper { padding: 0; }
      .report-container { box-shadow: none; margin: 0; padding: 0; max-width: 100%; }
      .report-table { border: 1px solid #ccc; }
      .report-table th, .report-table td { border: 1px solid #ccc; }
      .filter-row { display: none !important; }
      table { page-break-inside: auto; }
      tr { page-break-inside: avoid; page-break-after: auto; }
    }
  </style>
</head>
<body>

<jsp:include page="navbar.jsp"/>

<div class="report-wrapper">
  <div class="report-container">
    <h1>BG Master Report</h1>

    <!-- Filters Section -->
    <div class="filter-card no-print">
      <form method="GET" action="BGServlet" class="filter-form">
        <input type="hidden" name="action" value="viewReport" />
        <input type="hidden" name="page" value="1" id="pageInput" />

        <div class="filter-group">
          <label>Department</label>
          <select name="reportDepartment">
            <option value="">-- All Departments --</option>
            <c:forEach var="dept" items="${departments}">
              <option value="${dept}" <c:if test="${dept == selectedDepartment}">selected</c:if>>${dept}</option>
            </c:forEach>
          </select>
        </div>

        <div class="filter-group">
          <label>PO Number</label>
          <input type="text" name="reportPoNumber" value="${selectedPoNumber}" placeholder="Search PO Number" autocomplete="off" />
        </div>

        <div class="filter-group">
          <label>BG Number</label>
          <input type="text" name="reportBgNumber" value="${selectedBgNumber}" placeholder="Search BG Number" />
        </div>

        <div class="filter-actions">
          <button type="submit" class="btn btn-primary">Filter</button>
          <a href="BGServlet?action=viewReport&clearFilters=1" class="btn btn-danger">Clear</a>
        </div>
      </form>
    </div>

    <!-- Toolbar Bar: Exports & Top Pagination -->
    <div class="toolbar-bar no-print">
      <div class="export-controls">
        <span style="font-weight:600; color:#475569;">Export:</span>
        <a href="BGServlet?action=exportExcel&reportDepartment=${selectedDepartment}&reportPoNumber=${selectedPoNumber}&reportBgNumber=${selectedBgNumber}" class="btn btn-excel">📊 Excel</a>
        <a href="BGServlet?action=exportPdf&reportDepartment=${selectedDepartment}&reportPoNumber=${selectedPoNumber}&reportBgNumber=${selectedBgNumber}" class="btn btn-pdf">📄 PDF</a>
        <a href="javascript:window.print();" class="btn btn-print">🖨️ Print</a>
      </div>

      <c:if test="${not empty totalPages and totalPages gt 1}">
        <div class="pagination-links">
          <c:choose>
            <c:when test="${currentPage gt 1}">
              <a href="BGServlet?action=viewReport&page=${currentPage - 1}&pageSize=${pageSize}&reportDepartment=${selectedDepartment}&reportPoNumber=${selectedPoNumber}&reportBgNumber=${selectedBgNumber}" class="page-btn">&laquo; Prev</a>
            </c:when>
            <c:otherwise><span class="page-btn disabled">&laquo; Prev</span></c:otherwise>
          </c:choose>
          <span>Page <strong>${currentPage}</strong> of <strong>${totalPages}</strong></span>
          <c:choose>
            <c:when test="${currentPage lt totalPages}">
              <a href="BGServlet?action=viewReport&page=${currentPage + 1}&pageSize=${pageSize}&reportDepartment=${selectedDepartment}&reportPoNumber=${selectedPoNumber}&reportBgNumber=${selectedBgNumber}" class="page-btn">Next &raquo;</a>
            </c:when>
            <c:otherwise><span class="page-btn disabled">Next &raquo;</span></c:otherwise>
          </c:choose>
        </div>
      </c:if>
    </div>

    <!-- Auto-suggest script for PO Numbers -->
    <script>
      (function(){
        var poInput = document.querySelector('input[name="reportPoNumber"]');
        if (!poInput) return;
        var list = document.createElement('div');
        list.style.position = 'absolute';
        list.style.background = '#fff';
        list.style.border = '1px solid #cbd5e1';
        list.style.borderRadius = '0 0 4px 4px';
        list.style.boxShadow = '0 4px 6px -1px rgba(0,0,0,0.1)';
        list.style.display = 'none';
        list.style.maxHeight = '200px';
        list.style.overflowY = 'auto';
        list.style.zIndex = 1000;
        poInput.parentNode.appendChild(list);

        var timeout = null;
        poInput.addEventListener('input', function(){
          var v = this.value.trim();
          if (timeout) clearTimeout(timeout);
          if (!v) { list.style.display='none'; return; }
          timeout = setTimeout(function(){
            fetch('BGServlet?action=poSuggest&term=' + encodeURIComponent(v))
              .then(function(res){ return res.json(); })
              .then(function(items){
                list.innerHTML = '';
                if (!items || items.length === 0) { list.style.display='none'; return; }
                items.slice(0,50).forEach(function(it){
                  var r = document.createElement('div');
                  r.style.padding='8px 12px';
                  r.style.cursor='pointer';
                  r.style.fontSize='14px';
                  r.textContent = it;
                  r.addEventListener('mouseover', function(){ this.style.background='#f1f5f9'; });
                  r.addEventListener('mouseout', function(){ this.style.background='#fff'; });
                  r.addEventListener('click', function(){ poInput.value = it; list.style.display='none'; });
                  list.appendChild(r);
                });
                list.style.left = poInput.offsetLeft + 'px';
                list.style.top = (poInput.offsetTop + poInput.offsetHeight) + 'px';
                list.style.width = poInput.offsetWidth + 'px';
                list.style.display = 'block';
              }).catch(function(){ list.style.display='none'; });
          }, 250);
        });
        document.addEventListener('click', function(e){ if (!poInput.contains(e.target) && !list.contains(e.target)) list.style.display='none'; });
      })();
    </script>

    <c:if test="${empty bgList}">
      <div class="no-data">No BG records found<c:if test="${not empty selectedDepartment}"> for ${selectedDepartment} department</c:if>.</div>
    </c:if>

    <c:if test="${not empty bgList}">
      <c:set var="today" value="<%= new java.util.Date() %>" />

      <table class="report-table" id="reportTable">
        <thead>
            <tr>
              <th class="text-left sortable" data-col="0" data-type="text">Department <span class="sort-icon">▲▼</span></th>
              <th class="text-center sortable" data-col="1" data-type="text">BG Type <span class="sort-icon">▲▼</span></th>
              <th class="text-left">Work Description</th>
              <th class="text-left sortable" data-col="3" data-type="text">BG Number <span class="sort-icon">▲▼</span></th>
              <th class="text-left sortable" data-col="4" data-type="text">PO Number <span class="sort-icon">▲▼</span></th>
              <th class="text-right sortable" data-col="5" data-type="number">PO Amount <span class="sort-icon">▲▼</span></th>
              <th class="text-center sortable" data-col="6" data-type="date">BG Date <span class="sort-icon">▲▼</span></th>
              <th class="text-center">Expiry Date</th>
              <th class="text-center">Period</th>
              <th class="text-center sortable" data-col="9" data-type="text">Status <span class="sort-icon">▲▼</span></th>
            </tr>
            <!-- Inline Auto Filters Row -->
            <tr class="filter-row no-print">
              <th><select class="column-filter" data-col="0"><option value="">All</option></select></th>
              <th><select class="column-filter" data-col="1"><option value="">All</option></select></th>
              <th></th> <!-- Work Description skipped -->
              <th><select class="column-filter" data-col="3"><option value="">All</option></select></th>
              <th><select class="column-filter" data-col="4"><option value="">All</option></select></th>
              <th><select class="column-filter" data-col="5"><option value="">All</option></select></th>
              <th><select class="column-filter" data-col="6"><option value="">All</option></select></th>
              <th></th>
              <th></th>
              <th><select class="column-filter" data-col="9"><option value="">All</option></select></th>
            </tr>
        </thead>
        <tbody>
          <c:forEach var="bg" items="${bgList}">
            <c:choose>
              <c:when test="${not empty bg.bgExpiryDate}">
                <fmt:formatNumber var="daysRemaining" 
                    value="${(bg.bgExpiryDate.time - today.time) / 86400000}" 
                    maxFractionDigits="0" />
              </c:when>
              <c:otherwise>
                <c:set var="daysRemaining" value="" />
              </c:otherwise>
            </c:choose>

            <tr>
              <td class="text-left">${bg.department}</td>
              <td class="text-center">
                <c:choose>
                  <c:when test="${not empty bg.bgType}">${bg.bgType}</c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </td>
              <td class="text-left">${bg.bgWorkdesc}</td>
              <!-- Hyperlink for BG Number -->
              <td class="text-left">
                <a href="BGServlet?action=editBG&bgId=${bg.bgId}" class="edit-link" title="Click to edit">${bg.bgNumber}</a>
              </td>
              <!-- Hyperlink for PO Number -->
              <td class="text-left">
                <c:choose>
                  <c:when test="${not empty bg.poNumber}">
                    <a href="BGServlet?action=editBG&bgId=${bg.bgId}" class="edit-link" title="Click to edit">${bg.poNumber}</a>
                  </c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </td>
              <td class="text-right" data-value="${bg.poAmount}">
                <c:choose>
                  <c:when test="${not empty bg.poAmount}">
                    <fmt:formatNumber value="${bg.poAmount}" type="number" minFractionDigits="2" maxFractionDigits="2" />
                  </c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </td>
              <td class="text-center" data-value="<fmt:formatDate value='${bg.bgDate}' pattern='yyyy-MM-dd'/>">
                <c:choose>
                  <c:when test="${not empty bg.bgDate}">
                    <fmt:formatDate value="${bg.bgDate}" pattern="dd-MMM-yyyy" />
                  </c:when>
                  <c:otherwise>N/A</c:otherwise>
                </c:choose>
              </td>
              <td class="text-center">
                <c:choose>
                  <c:when test="${not empty bg.bgExpiryDate}">
                    <fmt:formatDate value="${bg.bgExpiryDate}" pattern="dd-MMM-yyyy" />
                  </c:when>
                  <c:otherwise>N/A</c:otherwise>
                </c:choose>
              </td>
              <td class="text-center">${bg.bgPeriod}</td>
              <td class="text-center">
                <c:choose>
                  <c:when test="${daysRemaining == ''}">
                    N/A
                  </c:when>
                  <c:when test="${daysRemaining lt 0}">
                    <span class="expired">Expired</span>
                  </c:when>
                  <c:when test="${daysRemaining le 30}">
                    <span class="warning">${daysRemaining} days</span>
                  </c:when>
                  <c:otherwise>
                    <span class="ok">${daysRemaining} days</span>
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>

      <!-- Bottom Pagination Bar -->
      <div class="pagination-bar no-print">
        <div>Showing total <strong id="recordCount">${totalRows}</strong> records</div>
        <c:if test="${not empty totalPages and totalPages gt 1}">
          <div class="pagination-links">
            <c:choose>
              <c:when test="${currentPage gt 1}">
                <a href="BGServlet?action=viewReport&page=${currentPage - 1}&pageSize=${pageSize}&reportDepartment=${selectedDepartment}&reportPoNumber=${selectedPoNumber}&reportBgNumber=${selectedBgNumber}" class="page-btn">&laquo; Prev</a>
              </c:when>
              <c:otherwise><span class="page-btn disabled">&laquo; Prev</span></c:otherwise>
            </c:choose>
            <span>Page <strong>${currentPage}</strong> of <strong>${totalPages}</strong></span>
            <c:choose>
              <c:when test="${currentPage lt totalPages}">
                <a href="BGServlet?action=viewReport&page=${currentPage + 1}&pageSize=${pageSize}&reportDepartment=${selectedDepartment}&reportPoNumber=${selectedPoNumber}&reportBgNumber=${selectedBgNumber}" class="page-btn">Next &raquo;</a>
              </c:when>
              <c:otherwise><span class="page-btn disabled">Next &raquo;</span></c:otherwise>
            </c:choose>
          </div>
        </c:if>
      </div>
    </c:if>
  </div>
</div>

<!-- Sorting & Auto-Filtering Script -->
<script>
document.addEventListener('DOMContentLoaded', function() {
  const table = document.getElementById('reportTable');
  if (!table) return;

  const tbody = table.querySelector('tbody');
  const rows = Array.from(tbody.querySelectorAll('tr'));
  const filterSelects = table.querySelectorAll('.column-filter');

  // Populate Dropdown Auto Filters with Unique Cell Values
  filterSelects.forEach(select => {
    const colIdx = parseInt(select.getAttribute('data-col'));
    const uniqueValues = new Set();

    rows.forEach(row => {
      const cell = row.children[colIdx];
      if (cell) {
        const text = cell.textContent.trim();
        if (text && text !== '-' && text !== 'N/A') {
          uniqueValues.add(text);
        }
      }
    });

    Array.from(uniqueValues).sort().forEach(val => {
      const opt = document.createElement('option');
      opt.value = val;
      opt.textContent = val;
      select.appendChild(opt);
    });

    select.addEventListener('change', applyFilters);
  });

  // Apply Auto-Filtering across rows
  function applyFilters() {
    let visibleCount = 0;

    rows.forEach(row => {
      let isVisible = true;

      filterSelects.forEach(select => {
        const colIdx = parseInt(select.getAttribute('data-col'));
        const filterVal = select.value.toLowerCase();
        const cellText = row.children[colIdx] ? row.children[colIdx].textContent.trim().toLowerCase() : '';

        if (filterVal && cellText !== filterVal) {
          isVisible = false;
        }
      });

      row.style.display = isVisible ? '' : 'none';
      if (isVisible) visibleCount++;
    });

    const countElem = document.getElementById('recordCount');
    if (countElem) countElem.textContent = visibleCount;
  }

  // Column Auto-Sorting Handler
  const headers = table.querySelectorAll('th.sortable');
  let currentSortCol = -1;
  let isAscending = true;

  headers.forEach(header => {
    header.addEventListener('click', function() {
      const colIdx = parseInt(this.getAttribute('data-col'));
      const dataType = this.getAttribute('data-type');

      if (currentSortCol === colIdx) {
        isAscending = !isAscending;
      } else {
        currentSortCol = colIdx;
        isAscending = true;
      }

      // Update indicators
      headers.forEach(h => {
        const icon = h.querySelector('.sort-icon');
        if (icon) icon.textContent = '▲▼';
      });
      const currentIcon = this.querySelector('.sort-icon');
      if (currentIcon) currentIcon.textContent = isAscending ? '▲' : '▼';

      rows.sort((a, b) => {
        let valA = getCellValue(a.children[colIdx], dataType);
        let valB = getCellValue(b.children[colIdx], dataType);

        if (valA < valB) return isAscending ? -1 : 1;
        if (valA > valB) return isAscending ? 1 : -1;
        return 0;
      });

      rows.forEach(row => tbody.appendChild(row));
    });
  });

  function getCellValue(cell, dataType) {
    if (!cell) return '';

    if (dataType === 'number') {
      const dataVal = cell.getAttribute('data-value');
      if (dataVal !== null && dataVal !== '') return parseFloat(dataVal);
      const cleaned = cell.textContent.replace(/[^0-9.-]+/g, '');
      return cleaned ? parseFloat(cleaned) : -Infinity;
    }

    if (dataType === 'date') {
      const dataVal = cell.getAttribute('data-value');
      if (dataVal) return dataVal;
      return cell.textContent.trim();
    }

    return cell.textContent.trim().toLowerCase();
  }
});
</script>

</body>
</html>