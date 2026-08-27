<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Status</title>
    <link rel="stylesheet" href="/UppclVerifysts/resources/css/app.css">
</head>
<body>

<div class="container">
  <main class="material-card" role="main" aria-labelledby="pageTitle">
    <div class="hero">
      <div class="logo-rect" aria-hidden="true">VS</div>
      <div>
        <div id="pageTitle" class="title">Verify Meter Status</div>
        <div class="subtitle">Quickly check DVVNL and PuVVNL verification status — secure and fast.</div>
      </div>
    </div>

    <p class="small-muted" style="margin-top:12px">Choose a utility below to start. You will be redirected to the respective verification page.</p>

    <div class="actions-grid">
      <a href="/UppclVerifysts/puvvnl_action.jsp" class="action-tile" title="PuVVNL Verification">
        <div class="action-left">
          <div class="action-icon">P</div>
          <div>
            <div class="action-label">PuVVNL</div>
            <div class="action-sub">PuVVNL meter verification and details</div>
          </div>
        </div>
        <div style="color:var(--muted);font-size:0.95rem">Open →</div>
      </a>

      <a href="/UppclVerifysts/dvvnl_action.jsp" class="action-tile" title="DVVNL Verification">
        <div class="action-left">
          <div class="action-icon">D</div>
          <div>
            <div class="action-label">DVVNL</div>
            <div class="action-sub">DVVNL meter verification and details</div>
          </div>
        </div>
        <div style="color:var(--muted);font-size:0.95rem">Open →</div>
      </a>
    </div>
  </main>

  <aside class="side-card" aria-hidden="false">
    <h3>Info</h3>
    <p>Designed with a Material-inspired look. Use the buttons to navigate. The verification forms work on both mobile and web.</p>
  </aside>
</div>

</body>
</html>