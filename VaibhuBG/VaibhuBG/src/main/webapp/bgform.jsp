<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><c:choose><c:when test="${not empty bg}">Edit BG Details</c:when><c:otherwise>Add BG Details</c:otherwise></c:choose></title>
    <style>
        /* Base page styling */
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        /* Wrapper to separate form layout from fixed/top navbar */
        .form-wrapper {
            padding: 20px;
        }
        
        /* Form container */
        .bg-form-container {
            max-width: 600px;
            margin: 30px auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            box-sizing: border-box;
        }

        .bg-form-container * {
            box-sizing: border-box;
        }
        
        .bg-form-container h1 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .bg-form-container label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: bold;
        }
        
        .bg-form-container input[type="text"],
        .bg-form-container input[type="number"],
        .bg-form-container input[type="date"],
        .bg-form-container select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 1em;
            transition: border-color 0.3s;
            background-color: #fff;
        }
        
        .bg-form-container input[type="text"]:focus,
        .bg-form-container input[type="number"]:focus,
        .bg-form-container input[type="date"]:focus,
        .bg-form-container select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 5px rgba(102, 126, 234, 0.3);
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }
        
        .bg-form-container button {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-size: 1em;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .submit-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
        
        .reset-btn {
            background: #f0f0f0;
            color: #333;
            border: 1px solid #ddd;
        }
        
        .reset-btn:hover {
            background: #e0e0e0;
        }
        
        .back-link {
            display: inline-block;
            margin-top: 15px;
            color: #667eea;
            text-decoration: none;
            font-weight: bold;
        }
        
        .back-link:hover {
            text-decoration: underline;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp"/>

<div class="form-wrapper">
    <div class="bg-form-container">
        <h1>
            <c:choose>
                <c:when test="${not empty bg}">Edit BG Details</c:when>
                <c:otherwise>Add BG Details</c:otherwise>
            </c:choose>
        </h1>
        
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">${successMessage}</div>
        </c:if>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">${errorMessage}</div>
        </c:if>
        
        <form method="POST" action="BGServlet" id="bgForm">
            <!-- Dynamic Action & ID -->
            <c:choose>
                <c:when test="${not empty bg}">
                    <input type="hidden" name="action" value="updateBG">
                    <input type="hidden" name="bgId" value="${bg.bgId}">
                </c:when>
                <c:otherwise>
                    <input type="hidden" name="action" value="saveBG">
                </c:otherwise>
            </c:choose>
            
            <div class="form-group">
                <label for="department">Department <span style="color: red;">*</span></label>
                <select id="department" name="department" required>
                    <option value="">-- Select Department --</option>
                    <c:forEach var="dept" items="${departments}">
                        <option value="${dept}" <c:if test="${not empty bg and bg.department == dept}">selected</c:if>>${dept}</option>
                    </c:forEach>
                </select>
            </div>

            <!-- BG Type Dropdown -->
            <div class="form-group">
                <label for="bgType">BG Type <span style="color: red;">*</span></label>
                <select id="bgType" name="bgType" required>
                    <option value="">-- Select BG Type --</option>
                    <option value="PBG" <c:if test="${not empty bg and bg.bgType == 'PBG'}">selected</c:if>>PBG</option>
                    <option value="EMD" <c:if test="${not empty bg and bg.bgType == 'EMD'}">selected</c:if>>EMD</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="bgNumber">BG Number <span style="color: red;">*</span></label>
                <input type="text" id="bgNumber" name="bgNumber" placeholder="Enter BG Number" value="${bg.bgNumber}" required>
            </div>
            
            <div class="form-group">
                <label for="bgWorkdesc">Work Description <span style="color: red;">*</span></label>
                <input type="text" id="bgWorkdesc" name="bgWorkdesc" placeholder="Enter Work Description" value="${bg.bgWorkdesc}" required>
            </div>
            
            <div class="form-group">
                <label for="poNumber">PO Number</label>
                <input type="text" id="poNumber" name="poNumber" placeholder="Enter PO Number (optional)" value="${bg.poNumber}">
            </div>

            <div class="form-group">
                <label for="poAmount">PO Amount</label>
                <input type="number" id="poAmount" name="poAmount" placeholder="Enter PO Amount (optional)" step="0.01" min="0" value="${bg.poAmount}">
            </div>
            
            <div class="form-group">
                <label for="bgDate">BG Date <span style="color: red;">*</span></label>
                <fmt:formatDate var="formattedBgDate" value="${bg.bgDate}" pattern="yyyy-MM-dd" />
                <input type="date" id="bgDate" name="bgDate" value="${formattedBgDate}" required>
            </div>
            
            <div class="form-group">
                <label for="bgPeriod">BG Period <span style="color: red;">*</span></label>
                <input type="text" id="bgPeriod" name="bgPeriod" placeholder="e.g., 1 year, 6 months, 90 days" value="${bg.bgPeriod}" required>
            </div>
            
            <div class="form-group">
                <label for="bgExpiryDate">BG Expiry Date <span style="color: red;">*</span></label>
                <fmt:formatDate var="formattedExpiryDate" value="${bg.bgExpiryDate}" pattern="yyyy-MM-dd" />
                <input type="date" id="bgExpiryDate" name="bgExpiryDate" value="${formattedExpiryDate}" required>
            </div>
            
            <div class="button-group">
                <button type="submit" class="submit-btn">
                    <c:choose>
                        <c:when test="${not empty bg}">Update BG Details</c:when>
                        <c:otherwise>Save BG Details</c:otherwise>
                    </c:choose>
                </button>
                <button type="reset" class="reset-btn">Clear</button>
            </div>
        </form>
        
        <a href="BGServlet?action=viewReport" class="back-link">← Back to Report</a>
    </div>
</div>

<script>
  const bgDateInput = document.getElementById('bgDate');
  const bgPeriodInput = document.getElementById('bgPeriod');
  const bgExpiryDateInput = document.getElementById('bgExpiryDate');

  function parseDateInput(val) {
    if (!val || val.trim() === '') return null;
    const parts = val.split('-');
    if (parts.length !== 3) return null;
    const y = parseInt(parts[0], 10);
    const m = parseInt(parts[1], 10);
    const d = parseInt(parts[2], 10);
    if (isNaN(y) || isNaN(m) || isNaN(d)) return null;
    const result = new Date(y, m - 1, d);
    return isNaN(result.getTime()) ? null : result;
  }

  function formatDateForInput(dt) {
    if (!dt || isNaN(dt.getTime())) return '';
    const y = dt.getFullYear();
    const m = String(dt.getMonth() + 1).padStart(2, '0');
    const d = String(dt.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  }

  function calculateExpiryDate(showAlert = false) {
    const bgDateVal = bgDateInput.value;
    const bgPeriodVal = (bgPeriodInput.value || '').trim();

    // 1. If BG Expiry Date is already filled, treat form as valid
    if (bgExpiryDateInput.value) {
      return true;
    }

    if (!bgDateVal) {
      if (showAlert) alert('Please select BG Date first');
      return false;
    }

    if (!bgPeriodVal) {
      if (showAlert) alert('Please enter BG Period');
      return false;
    }

    const startDate = parseDateInput(bgDateVal);
    if (!startDate) {
      if (showAlert) alert('Invalid BG Date');
      return false;
    }

    // 2. Updated Regex: allow multiple words/spaces in period string
    const periodMatch = bgPeriodVal.match(/^(\d+)\s*([a-zA-Z\s]+)?$/i);
    if (!periodMatch) {
      if (showAlert) alert('Invalid BG Period format.\nExamples: "1 year", "6 months", "90 days", or "90"');
      return false;
    }

    const qty = parseInt(periodMatch[1], 10);
    const unit = (periodMatch[2] || '').trim().toLowerCase();

    const expiryDate = new Date(startDate.getTime());

    if (!unit) {
      expiryDate.setDate(expiryDate.getDate() + qty);
    } else if (['year', 'years', 'yr', 'yrs', 'y'].some(u => unit.includes(u))) {
      expiryDate.setFullYear(expiryDate.getFullYear() + qty);
    } else if (['month', 'months', 'mon', 'mons', 'm'].some(u => unit.includes(u))) {
      expiryDate.setMonth(expiryDate.getMonth() + qty);
    } else if (['day', 'days', 'd'].some(u => unit.includes(u))) {
      expiryDate.setDate(expiryDate.getDate() + qty);
    } else {
      expiryDate.setDate(expiryDate.getDate() + qty);
    }

    if (isNaN(expiryDate.getTime())) {
      if (showAlert) alert('Could not calculate expiry date from period');
      return false;
    }

    bgExpiryDateInput.value = formatDateForInput(expiryDate);
    return true;
  }

  bgDateInput.addEventListener('change', () => calculateExpiryDate(false));
  bgPeriodInput.addEventListener('input', () => calculateExpiryDate(false));
  bgPeriodInput.addEventListener('blur', () => calculateExpiryDate(false));

  document.getElementById('bgForm').addEventListener('submit', function (e) {
    // Attempt auto-calculation if expiry date field is empty
    if (!bgExpiryDateInput.value) {
      calculateExpiryDate(false);
    }

    // Final check on submission
    if (!bgExpiryDateInput.value) {
      e.preventDefault();
      alert('Please select or enter a valid BG Expiry Date');
      return;
    }

    const d1 = parseDateInput(bgDateInput.value);
    const d2 = parseDateInput(bgExpiryDateInput.value);

    if (d1 && d2 && d2 < d1) {
      e.preventDefault();
      alert('BG Expiry Date cannot be before BG Date');
    }
  });
</script>
</body>
</html>