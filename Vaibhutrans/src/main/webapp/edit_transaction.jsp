<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.vaibhutrans.model.Transaction" %>
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
    <title>Edit Transaction - Vaibhutrans</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: #1e293b;
            padding-bottom: 40px;
        }
        .form-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px);
            border-radius: 20px;
            padding: 32px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            max-width: 800px;
            margin: 40px auto;
        }
    </style>
</head>
<body>
<jsp:include page="navbar.jsp" />

<div class="container">
    <div class="form-card">
        <h3 class="mb-4"><i class="fa fa-pencil-square me-2 text-primary"></i>Edit Transaction</h3>
        
        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>

        <form action="editTransaction" method="post">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label fw-bold">UTR No</label>
                    <input type="text" name="utrNo" class="form-control" value="${transaction.utrNo}" readonly />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Transaction Date</label>
                    <input type="date" name="transactionDate" class="form-control" value="${transaction.transactionDate}" required />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Debit Account</label>
                    <input type="text" name="debitAccount" class="form-control" value="${transaction.debitAccount}" required />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Beneficiary Account</label>
                    <input type="text" name="benfAccount" class="form-control" value="${transaction.benfAccount}" />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Amount</label>
                    <input type="number" step="0.01" name="amount" class="form-control" value="${transaction.amount}" required />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Payment Mode</label>
                    <input type="text" name="paymentMode" class="form-control" value="${transaction.paymentMode}" />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Status</label>
                    <input type="text" name="status" class="form-control" value="${transaction.status}" />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Tally Ledger</label>
                    <input type="text" name="tallyledger" class="form-control" value="${transaction.tallyledger}" />
                </div>
                <div class="col-md-6">
                    <label class="form-label fw-bold">Project</label>
                    <input type="text" name="project" class="form-control" value="${transaction.project}" />
                </div>
                <div class="col-md-12">
                    <label class="form-label fw-bold">Narration</label>
                    <textarea name="narration" class="form-control" rows="3">${transaction.narration}</textarea>
                </div>
                <div class="col-md-12 d-flex justify-content-end gap-2 mt-4">
                    <a href="report" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </div>
        </form>
    </div>
</div>
</body>
</html>