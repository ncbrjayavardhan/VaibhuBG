<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map, java.util.Set, java.util.LinkedHashSet, java.util.Iterator" %>
<%!
// simple escaper for JSP values
public String esc(String s) {
    if (s == null) return "";
    return s.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>PuVVNL Lookup Results</title>
<style>
/* Desktop table styling (shown on >= 720px) */
.container { max-width: 1200px; margin: 12px auto; padding: 10px; font-family: Arial, Helvetica, sans-serif; }
.serverMsg { margin: 8px 0; font-weight:600; }
.table-wrapper { width: 100%; overflow: auto; border: 1px solid #e3e6ea; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); background: #fff; }
.results-table { border-collapse: collapse; width: 100%; min-width: 480px; table-layout: fixed; }
.results-table th, .results-table td { padding: 12px 14px; border-bottom: 1px solid #f1f5f8; vertical-align: top; }
.results-table thead th { background: linear-gradient(180deg,#fff,#f8fafc); font-weight:700; border-bottom:2px solid #e8eef4; }
.results-table tbody tr:nth-child(even) { background: #fbfdff; }
.results-table tbody tr:hover { background: #eef6ff; }
.results-table th:first-child, .results-table td:first-child { position: sticky; left: 0; background: #fff; z-index: 3; box-shadow: 2px 0 4px rgba(0,0,0,0.03); }
.results-table thead th:first-child { top: 0; z-index: 4; }
.results-table thead th { position: sticky; top: 0; }
.header-record { text-align: center; }
.value-cell { word-break: break-word; }
.back-link { display:inline-block; margin-top:12px; color:#2b6cb0; text-decoration:none; }
.back-link:hover { text-decoration:underline; }
.no-data { color: #c0392b; font-weight:600; }

/* Mobile compact card view (shown on <720px) */
.cards-wrapper { display:none; }
.card { background:#fff; border-radius:8px; padding:10px; margin-bottom:10px; box-shadow:0 2px 6px rgba(0,0,0,0.04); }
.card .summary { display:flex; gap:8px; align-items:center; justify-content:space-between; }
.card .summary-left { display:flex; gap:10px; align-items:center; }
.card .field-primary { font-weight:700; color:#1f2937; font-size:15px; }
.card .field-sub { color:#4b5563; font-size:13px; }
.card .toggle { background:transparent;border:none;color:#2563eb;font-weight:600;cursor:pointer;padding:6px 8px;border-radius:6px }
.card .details { margin-top:8px; display:none; }
.card.expanded .details { display:block; }
.card .row { display:flex; gap:10px; padding:4px 0; }
.card .label { min-width:110px; color:#374151; font-weight:600; font-size:13px }
.card .value { color:#111827; font-size:13px; word-break:break-word }

/* very compact adjustments */
.card.compact { padding:8px }
.card.compact .field-primary { font-size:14px }
.card.compact .label { min-width:100px; font-size:12px }
.card.compact .value { font-size:13px }

/* show appropriate view depending on viewport */
@media (max-width: 719px) {
  .table-wrapper { display:none }
  .cards-wrapper { display:block }
}
@media (min-width: 720px) {
  .cards-wrapper { display:none }
  .table-wrapper { display:block }
}
</style>
</head>
<body>
<div class="container">
<%
    String serverMsg = (String) request.getAttribute("serverMsg");
    List<Map<String,String>> rows = (List<Map<String,String>>) request.getAttribute("rows");
%>
<p class="serverMsg"><%= esc(serverMsg) %></p>

<% if (rows != null && !rows.isEmpty()) {
     // Build an ordered set of all headers (friendly labels) across rows preserving first-seen order
     Set<String> headers = new LinkedHashSet<String>();
     for (Map<String,String> r : rows) { headers.addAll(r.keySet()); }
     int recordCount = rows.size();
%>
<!-- Desktop transposed table -->
<div class="table-wrapper">
  <table class="results-table" role="table">
    <thead>
      <tr>
        <% for (String h : headers) { %>
          <th scope="col"><%= esc(h) %></th>
        <% } %>
      </tr>
    </thead>
    <tbody>
      <% for (Map<String,String> r : rows) { %>
        <tr>
          <% for (String h : headers) { %>
            <td><%= esc(r.get(h)) %></td>
          <% } %>
        </tr>
      <% } %>
    </tbody>
  </table>
</div>

<!-- Mobile compact cards (one card per record) -->
<div class="cards-wrapper">
  <% int idx=0; for (Map<String,String> r : rows) { idx++; %>
    <div class="card compact" data-idx="<%=idx%>">
      <div class="summary">
        <div class="summary-left">
          <%-- Primary fields: try Account ID, Name, Mobile in that order --%>
          <div>
            <div class="field-primary">
              <% String primary = "";
                 if (r.containsKey("Account ID")) primary = r.get("Account ID");
                 else if (r.containsKey("acct_id")) primary = r.get("acct_id");
                 else if (r.containsKey("Account")) primary = r.get("Account");
                 else if (r.containsKey("Name")) primary = r.get("Name");
                 else if (r.containsKey("Consumer Name")) primary = r.get("Consumer Name");
                 else if (r.size() > 0) { java.util.Iterator<String> it = r.keySet().iterator(); if (it.hasNext()) primary = r.get(it.next()); }
              %>
              <%= esc(primary) %>
            </div>
            <div class="field-sub">
              <% String sub = "";
                 if (r.containsKey("Mobile")) sub = r.get("Mobile");
                 else if (r.containsKey("mobile")) sub = r.get("mobile");
                 else if (r.containsKey("Phone")) sub = r.get("Phone");
                 else if (r.containsKey("phone")) sub = r.get("phone");
              %>
              <%= esc(sub) %>
            </div>
          </div>
        </div>
        <div>
          <button class="toggle" aria-expanded="false">Show more</button>
        </div>
      </div>
      <div class="details" aria-hidden="true">
        <%-- show all label:value rows compactly --%>
        <% for (Map.Entry<String,String> e : r.entrySet()) { %>
          <div class="row">
            <div class="label"><%= esc(e.getKey()) %></div>
            <div class="value"><%= esc(e.getValue()) %></div>
          </div>
        <% } %>
      </div>
    </div>
  <% } %>
</div>

<% } else { %>
  <p class="no-data"><%= esc(serverMsg) %></p>
<% } %>

<p><a class="back-link" href="puvvnl_action.jsp">&larr; Back to search</a></p>
</div>

<script>
// Toggle show more/less in compact cards
(function(){
  var toggles = document.querySelectorAll('.card .toggle');
  toggles.forEach(function(btn){
    btn.addEventListener('click', function(){
      var card = this.closest('.card');
      var expanded = card.classList.toggle('expanded');
      this.setAttribute('aria-expanded', expanded ? 'true' : 'false');
      var details = card.querySelector('.details');
      if (details) details.setAttribute('aria-hidden', expanded ? 'false' : 'true');
      this.textContent = expanded ? 'Show less' : 'Show more';
    });
  });
})();
</script>

</body>
</html>