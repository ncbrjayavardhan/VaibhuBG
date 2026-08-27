<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!-- Ensure Tailwind styles are available even if the including page didn't load them -->
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" href="${ctx}/resources/css/navbar.css" />

<!-- Fallback styles: minimal CSS to ensure navbar is usable if Tailwind is blocked -->
<style>
    /* Basic reset for the navbar container */
    nav { box-sizing: border-box; }
    .container { max-width: 1200px; margin: 0 auto; padding: 0 1rem; }
    .flex { display: flex; }
    .items-center { align-items: center; }
    .justify-between { justify-content: space-between; }
    .flex-wrap { flex-wrap: wrap; }
    .text-white { color: #ffffff; }
    /* .bg-gradient-to-r { background: linear-gradient(90deg, #2563eb 0%, #1e40af 100%); } */
    .bg-gradient-to-r { background: linear-gradient(90deg, #1e293b 0%, #111827 100%); }
    .p-4 { padding: 1rem; }
    .rounded-b-lg { border-bottom-left-radius: 0.5rem; border-bottom-right-radius: 0.5rem; }
    .shadow-lg { box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05); }
    a { text-decoration: none; }
    .hidden { display: none; }
    .block { display: block; }
    .w-full { width: 100%; }
    .rounded-md { border-radius: 0.375rem; }
    .mr-8 { margin-right: 2rem; }
    .px-4 { padding-left: 1rem; padding-right: 1rem; }
    .py-2 { padding-top: 0.5rem; padding-bottom: 0.5rem; }
    .bg-blue-700 { background-color: #1d4ed8; }
    .bg-blue-800 { background-color: #1e40af; }
    .bg-blue-600 { background-color: #2563eb; }
    .text-2xl { font-size: 1.5rem; }
    .font-bold { font-weight: 700; }
    /* Small helper classes used by the JS toggles */
    .rotate-180 { transform: rotate(180deg); }
    .max-h-full { max-height: 100%; }
    /* Responsive fallbacks to emulate key Tailwind behaviors when CDN is unavailable */
    @media (min-width: 1024px) {
        /* class names with colons must be escaped in CSS selectors */
        .lg\:flex { display: flex !important; }
        .lg\:items-center { align-items: center !important; }
        .lg\:w-auto { width: auto !important; }
        .lg\:inline-block { display: inline-block !important; }
        .lg\:mt-0 { margin-top: 0 !important; }
    }

    /* Emulate group-hover:block when Tailwind not present */
    .group:hover .group-hover\:block { display: block !important; }
    /* Basic dropdown positioning fallback */
    .absolute { position: absolute; }
    .z-10 { z-index: 10; }
    /* Ensure desktop menu (hidden lg:flex) becomes visible at large widths even if Tailwind is missing */
    @media (min-width: 1024px) {
        #navbar-links-desktop { display: flex !important; }
        #navbar-links-desktop .text-lg { display: flex !important; align-items: center; }
        #navbar-links-desktop a { display: inline-block !important; }
    }
</style>

<nav class="bg-gradient-to-r from-slate-800 to-gray-900 p-4 shadow-lg rounded-b-lg w-full font-sans">
    <div class="container mx-auto flex justify-between items-center flex-wrap">
        <%-- The main brand/logo link, now points to the servlet --%>
        <a href="${ctx}/ChartDataServlet" class="text-white text-2xl font-bold tracking-wide rounded-md p-2 hover:bg-blue-700 transition duration-300 flex items-center">
            <%-- Corrected image path and added max-h-full for proper scaling --%>
            
            
        </a>

        <div class="block lg:hidden">
            <button id="menu-button" class="menu-button text-white focus:outline-none p-2 rounded-md hover:bg-blue-700 transition duration-300">
                <!-- <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7"></path>
                </svg> -->
            </button>
        </div>

        <div class="hidden lg:flex lg:items-center lg:w-auto w-full" id="navbar-links-desktop">
            <div class="text-lg lg:flex-grow flex items-center">
                <%-- Home link points to the servlet --%>
                <a href="${ctx}/index.jsp" class="block mt-4 lg:inline-block lg:mt-0 text-white hover:text-blue-200 mr-8 p-2 rounded-md hover:bg-blue-700 transition duration-300">
                    Home
                </a>
				<%-- Add BG Details link --%>
                <a href="BGServlet" class="block mt-4 lg:inline-block lg:mt-0 text-white hover:text-blue-200 mr-8 p-2 rounded-md hover:bg-blue-700 transition duration-300">
                    Add BG Details
                </a>
                
                <%-- Add Department link --%>
                <a href="AddDeptServlet" class="block mt-4 lg:inline-block lg:mt-0 text-white hover:text-blue-200 mr-8 p-2 rounded-md hover:bg-blue-700 transition duration-300">
                    Add Department
                </a>
                
                <%-- Add View Report link --%>
                <a href="BGServlet?action=viewReport" class="block mt-4 lg:inline-block lg:mt-0 text-white hover:text-blue-200 mr-8 p-2 rounded-md hover:bg-blue-700 transition duration-300">
                    View Report
                </a>
                            </div>
        </div>
    </div>

    <%-- Mobile Navigation --%>
    <div class="hidden lg:hidden w-full mt-4 bg-blue-700 rounded-md py-2" id="navbar-links-mobile">
        <%-- Mobile Home link points to the servlet --%>
        <a href="${ctx}/index.jsp" class="block px-4 py-2 text-white hover:bg-blue-600 rounded-md transition duration-300">Home</a>

        <%-- Mobile Add Department link --%>
        <a href="${ctx}/AddBankServlet" class="block px-4 py-2 text-white hover:bg-blue-600 rounded-md transition duration-300">Add Department</a>
    </div>
</nav>

<script>
try {
    // Robust navbar toggles: ensure mobile menu is shown/hidden even if Tailwind is not loaded
    const menuButton = document.getElementById('menu-button');
    const mobileMenu = document.getElementById('navbar-links-mobile');

    if (menuButton && mobileMenu) {
        // initialize visibility
        if (mobileMenu.classList.contains('hidden')) mobileMenu.style.display = 'none';
        else mobileMenu.style.display = 'block';

        menuButton.addEventListener('click', () => {
            mobileMenu.classList.toggle('hidden');
            if (mobileMenu.classList.contains('hidden')) mobileMenu.style.display = 'none';
            else mobileMenu.style.display = 'block';
        });

        // Ensure responsive behavior on resize
        window.addEventListener('resize', () => {
            if (window.innerWidth >= 1024) {
                mobileMenu.classList.add('hidden');
                mobileMenu.style.display = '';
            } else {
                if (mobileMenu.classList.contains('hidden')) mobileMenu.style.display = 'none';
            }
        });
    }

    // Mobile submenu toggles
    const mobileDashboardButton = document.getElementById('mobile-dashboard-button');
    const mobileDashboardSubmenu = document.getElementById('mobile-dashboard-submenu');
    if (mobileDashboardButton && mobileDashboardSubmenu) {
        mobileDashboardButton.addEventListener('click', () => {
            mobileDashboardSubmenu.classList.toggle('hidden');
            mobileDashboardSubmenu.style.display = mobileDashboardSubmenu.classList.contains('hidden') ? 'none' : 'block';
            mobileDashboardButton.querySelector('svg').classList.toggle('rotate-180');
        });
    }

    const mobileToolsButton = document.getElementById('mobile-tools-button');
    const mobileToolsSubmenu = document.getElementById('mobile-tools-submenu');
    if (mobileToolsButton && mobileToolsSubmenu) {
        mobileToolsButton.addEventListener('click', () => {
            mobileToolsSubmenu.classList.toggle('hidden');
            mobileToolsSubmenu.style.display = mobileToolsSubmenu.classList.contains('hidden') ? 'none' : 'block';
            mobileToolsButton.querySelector('svg').classList.toggle('rotate-180');
        });
    }

    // Desktop dropdowns: render as floating cloned menus appended to body to avoid being clipped by map or overflow
    (function() {
        function createFloatingMenu(originalUl, button) {
            // Remove any existing floating menu
            removeFloatingMenu(originalUl);

            const clone = originalUl.cloneNode(true);
            clone.id = originalUl.id + '-floating';
            clone.classList.remove('hidden');
            clone.style.position = 'absolute';
            clone.style.zIndex = '100000';
            clone.style.display = 'block';
            clone.style.minWidth = originalUl.offsetWidth + 'px';
            document.body.appendChild(clone);

            // Position it below the button
            const btnRect = button.getBoundingClientRect();
            const top = btnRect.bottom + window.scrollY;
            // align left with button; ensure it doesn't overflow viewport
            let left = btnRect.left + window.scrollX;
            const rightOverflow = left + clone.offsetWidth - (window.innerWidth + window.scrollX);
            if (rightOverflow > 0) left = Math.max(window.scrollX + 8, left - rightOverflow - 8);

            clone.style.top = top + 'px';
            clone.style.left = left + 'px';

            // Close on outside click
            function onDocClick(e) {
                if (!clone.contains(e.target) && !button.contains(e.target)) {
                    removeFloatingMenu(originalUl);
                    document.removeEventListener('click', onDocClick);
                }
            }
            setTimeout(() => document.addEventListener('click', onDocClick), 0);

            return clone;
        }

        function removeFloatingMenu(originalUl) {
            const existing = document.getElementById(originalUl.id + '-floating');
            if (existing) existing.remove();
        }

        // Dashboard
        const desktopDashboardButton = document.getElementById('dashboard-dropdown-button-desktop');
        const desktopDashboardSubmenu = document.getElementById('dashboard-submenu-desktop');
        if (desktopDashboardButton && desktopDashboardSubmenu) {
            desktopDashboardButton.addEventListener('click', (e) => {
                e.preventDefault();
                // Toggle floating clone
                const floating = document.getElementById(desktopDashboardSubmenu.id + '-floating');
                if (floating) {
                    removeFloatingMenu(desktopDashboardSubmenu);
                    desktopDashboardButton.querySelector('svg').classList.remove('rotate-180');
                } else {
                    createFloatingMenu(desktopDashboardSubmenu, desktopDashboardButton);
                    desktopDashboardButton.querySelector('svg').classList.add('rotate-180');
                }
            });
        }

        // Tools
        const desktopToolsButton = document.getElementById('tools-dropdown-button-desktop');
        const desktopToolsSubmenu = document.getElementById('tools-submenu-desktop');
        if (desktopToolsButton && desktopToolsSubmenu) {
            desktopToolsButton.addEventListener('click', (e) => {
                e.preventDefault();
                const floating = document.getElementById(desktopToolsSubmenu.id + '-floating');
                if (floating) {
                    removeFloatingMenu(desktopToolsSubmenu);
                    desktopToolsButton.querySelector('svg').classList.remove('rotate-180');
                } else {
                    createFloatingMenu(desktopToolsSubmenu, desktopToolsButton);
                    desktopToolsButton.querySelector('svg').classList.add('rotate-180');
                }
            });
        }
    })();
} catch (e) {
    console.error('Navbar script error:', e);
}
</script>