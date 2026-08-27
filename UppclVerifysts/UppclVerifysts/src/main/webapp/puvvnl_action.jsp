<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>PuVVNL — Account Lookup</title>
<link rel="stylesheet" href="/UppclVerifysts/resources/css/app.css">
</head>
<body>

<a class="skip" href="#numericInput">Skip to input</a>
<div class="container">
  <main class="material-card">
    <div class="hero">
      <div class="logo-rect" aria-hidden="true">P</div>
      <div>
        <div class="title">PuVVNL Account Lookup</div>
        <div class="subtitle">Quickly check your account — mobile and desktop friendly.</div>
      </div>
    </div>

    <form id="numForm" method="post" action="puvvnlLookup" novalidate>
      <div class="field">
        <input
           id="numericInput"
           name="mobileNumber"
           type="tel"
           inputmode="numeric"
           pattern="^[0-9]{10,11}$"
           minlength="10"
           maxlength="11"
           placeholder=" "
           oninvalid="this.setCustomValidity('Please enter only digits — length must be 10 or 11 digits.')"
           oninput="this.setCustomValidity('')"
           required
           autocomplete="off"
        />
        <label for="numericInput">Account ID (10–11 digits)</label>
      </div>

      <div class="row">
        <button type="submit" class="btn-primary">Search</button>
        <a href="index.jsp" class="btn-ghost">Home</a>
      </div>

      <div id="clientError" class="error" role="alert" aria-live="polite"></div>
    </form>
  </main>

  <aside class="side-card">
    <h3>Quick tips</h3>
    <p>Make sure you've got the correct 10–11 digit account ID. The input accepts only digits and will trim other characters automatically.</p>
    <p style="opacity:0.9">Need help? Contact your distribution office for account-specific queries.</p>
  </aside>
</div>

<script>
// Client-side: allow only digits as user types and enforce max length
(function(){
    var input = document.getElementById('numericInput');
    var form = document.getElementById('numForm');
    var clientError = document.getElementById('clientError');

    input.addEventListener('input', function () {
        // remove all non-digit characters
        var cleaned = this.value.replace(/\D/g, '');
        // limit to maxlength (11)
        if (cleaned.length > 11) cleaned = cleaned.slice(0, 11);
        if (this.value !== cleaned) this.value = cleaned;
        // live feedback
        if (cleaned.length > 0 && (cleaned.length < 10 || cleaned.length > 11)) {
            clientError.textContent = 'Number must be 10 or 11 digits.';
        } else {
            clientError.textContent = '';
        }
    });

    form.addEventListener('submit', function (e) {
        var v = input.value.trim();
        if (!/^[0-9]{10,11}$/.test(v)) {
            e.preventDefault();
            clientError.textContent = 'Please enter only numbers — length must be 10 or 11 digits.';
            input.focus();
            return false;
        }
        // allow submit
        return true;
    });
})();
</script>

<script>
// Keep a simple Home link behavior; do not push history/popstate in mobile/WebView
(function(){
  var backLink = document.getElementById('backHome');
  if (backLink) {
    backLink.addEventListener('click', function (e) {
      // normal navigation to index.jsp
      // using location.replace avoids creating an extra history entry if desired
      e.preventDefault();
      window.location.href = 'index.jsp';
    });
  }
})();
</script>

<script>
// Ensure focused input scrolls into view on mobile so keyboard doesn't hide it
(function(){
  var input = document.getElementById('numericInput');
  if (!input) return;
  function onFocus() {
    // wait a tick for the keyboard to appear then scroll
    setTimeout(function(){
      try { input.scrollIntoView({behavior:'smooth', block: 'center'}); } catch (e) { input.scrollIntoView(); }
    }, 300);
  }
  input.addEventListener('focus', onFocus);
  // also handle orientation change / resize
  window.addEventListener('orientationchange', function(){ setTimeout(function(){ input.scrollIntoView({block:'center'}); }, 500); }, false);
})();
</script>

</body>
</html>
