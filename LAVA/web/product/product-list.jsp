<%-- 
    Document   : product-list
    Created on : Mar 10, 2026, 8:35:20 PM
    Author     : DELL
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Product, model.Category, model.Brand, model.User" %>
<%
    String path = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");

    List<Product>  products   = (List<Product>)  request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand>    brands     = (List<Brand>)    request.getAttribute("brands");

    int    totalProducts = (int)    (request.getAttribute("totalProducts") != null ? request.getAttribute("totalProducts") : 0);
    int    totalPages    = (int)    (request.getAttribute("totalPages")    != null ? request.getAttribute("totalPages")    : 1);
    int    currentPage   = (int)    (request.getAttribute("currentPage")   != null ? request.getAttribute("currentPage")   : 1);
    String keyword       = (String) (request.getAttribute("keyword")  != null ? request.getAttribute("keyword")  : "");
    String sortBy        = (String) (request.getAttribute("sortBy")   != null ? request.getAttribute("sortBy")   : "");
    int    categoryId    = (int)    (request.getAttribute("categoryId") != null ? request.getAttribute("categoryId") : 0);
    int    brandId       = (int)    (request.getAttribute("brandId")   != null ? request.getAttribute("brandId")   : 0);
    String productType   = (String) (request.getAttribute("productType") != null ? request.getAttribute("productType") : "");
    String color         = (String) (request.getAttribute("color")       != null ? request.getAttribute("color")       : "");

    java.util.List<String> colors = (java.util.List<String>) request.getAttribute("colors");
    if (colors == null) colors = new java.util.ArrayList<>();

    if (products   == null) products   = new java.util.ArrayList<>();
    if (categories == null) categories = new java.util.ArrayList<>();
    if (brands     == null) brands     = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>Products – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            /* ── Product List Layout ── */
            .pl-wrapper {
                display: flex;
                gap: 0;
                min-height: 80vh;
                background: #f0f0ef;
            }

            /* ── Filter Sidebar ── */
            .pl-sidebar {
                width: 260px;
                flex-shrink: 0;
                padding: 40px 30px;
                background: white;
                border-right: 1px solid #e0e0e0;
            }
            .pl-sidebar h3 {
                font-size: 11px;
                letter-spacing: 2px;
                text-transform: uppercase;
                color: #999;
                margin: 0 0 20px 0;
            }
            .filter-section {
                margin-bottom: 30px;
            }
            .filter-section h4 {
                font-size: 13px;
                font-weight: 700;
                letter-spacing: 1px;
                text-transform: uppercase;
                margin: 0 0 12px 0;
                color: #222;
            }
            .filter-section select,
            .filter-section input[type="number"] {
                width: 100%;
                padding: 10px 12px;
                border: 1px solid #ccc;
                font-size: 13px;
                background: white;
                outline: none;
                margin-bottom: 8px;
                box-sizing: border-box;
            }
            .filter-section select:focus,
            .filter-section input:focus {
                border-color: black;
            }

            .price-row {
                display: flex;
                gap: 8px;
            }
            .price-row input {
                margin-bottom: 0;
            }

            .btn-apply {
                width: 100%;
                padding: 12px;
                background: black;
                color: white;
                border: none;
                font-size: 12px;
                letter-spacing: 2px;
                cursor: pointer;
                margin-top: 4px;
            }
            .btn-apply:hover {
                opacity: 0.85;
            }

            .btn-clear {
                display: block;
                width: 100%;
                padding: 10px;
                background: white;
                color: #555;
                border: 1px solid #ccc;
                font-size: 12px;
                letter-spacing: 1px;
                cursor: pointer;
                margin-top: 8px;
                text-align: center;
                text-decoration: none;
            }
            .btn-clear:hover {
                background: #f5f5f5;
            }

            /* ── Main Content ── */
            .pl-main {
                flex: 1;
                padding: 40px 50px;
            }

            /* ── Top bar: result count + sort ── */
            .pl-topbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
            }
            .pl-topbar h2 {
                font-size: 28px;
                font-weight: 900;
                letter-spacing: -1px;
                margin: 0;
            }
            .pl-topbar .result-count {
                font-size: 13px;
                color: #888;
                margin-top: 4px;
            }
            .sort-select {
                padding: 10px 14px;
                border: 1px solid #ccc;
                font-size: 13px;
                background: white;
                outline: none;
                cursor: pointer;
            }

            /* ── Search bar ── */
            .pl-search {
                display: flex;
                margin-bottom: 30px;
                border: 1px solid #ccc;
                background: white;
            }
            .pl-search input {
                flex: 1;
                padding: 14px 16px;
                border: none;
                outline: none;
                font-size: 14px;
                background: transparent;
            }
            .pl-search button {
                padding: 14px 20px;
                background: black;
                color: white;
                border: none;
                cursor: pointer;
                font-size: 14px;
            }
            .pl-search button:hover {
                opacity: 0.85;
            }

            /* ── Product Grid ── */
            .pl-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 24px;
            }

            .pl-card {
                background: white;
                cursor: pointer;
                transition: box-shadow 0.25s;
            }
            .pl-card:hover {
                box-shadow: 0 8px 28px rgba(0,0,0,0.14);
            }

            .pl-img-wrap {
                position: relative;
                overflow: hidden;
                background: #e8e8e8;
            }
            .pl-img-wrap img {
                width: 100%;
                height: 300px;
                object-fit: cover;
                display: block;
                transition: transform 0.35s ease;
            }
            .pl-card:hover .pl-img-wrap img {
                transform: scale(1.04);
            }

            .pl-add-btn {
                position: absolute;
                bottom: 10px;
                right: 10px;
                width: 36px;
                height: 36px;
                background: white;
                border: 1px solid #ddd;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                opacity: 0;
                transition: opacity 0.25s;
            }
            .pl-card:hover .pl-add-btn {
                opacity: 1;
            }
            .pl-add-btn:hover {
                background: black;
                color: white;
            }

            .pl-info {
                padding: 12px 14px;
            }
            .pl-category {
                font-size: 11px;
                color: #888;
                letter-spacing: 0.5px;
                display: block;
                margin-bottom: 4px;
            }
            .pl-row {
                display: flex;
                justify-content: space-between;
                align-items: baseline;
            }
            .pl-name {
                font-size: 13px;
                font-weight: 600;
                color: #111;
            }
            .pl-price {
                font-size: 13px;
                font-weight: 700;
                color: #111;
                white-space: nowrap;
                margin-left: 8px;
            }
            .pl-stock {
                font-size: 11px;
                color: #aaa;
                margin-top: 4px;
            }
            .out-of-stock .pl-img-wrap img {
                opacity: 0.5;
            }
            .out-of-stock .pl-stock {
                color: #e74c3c;
            }

            /* ── No results ── */
            .pl-empty {
                text-align: center;
                padding: 80px 0;
                color: #888;
            }
            .pl-empty i {
                font-size: 48px;
                margin-bottom: 16px;
                display: block;
            }

            /* ── Pagination ── */
            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 6px;
                margin-top: 50px;
            }
            .pagination a, .pagination span {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 38px;
                height: 38px;
                border: 1px solid #ccc;
                font-size: 13px;
                text-decoration: none;
                color: black;
                background: white;
                transition: 0.2s;
            }
            .pagination a:hover {
                background: #f0f0f0;
            }
            .pagination .active {
                background: black;
                color: white;
                border-color: black;
            }
            .pagination .disabled {
                color: #ccc;
                pointer-events: none;
            }
        </style>
    </head>
    <body>

        <!-- ==================== HEADER ==================== -->
        <header class="header">
            <div class="menu-left">
                <i class="fa-solid fa-bars fa-xl menu-icon" onclick="openMenu()"></i>
                <a href="<%= path %>/home">Home</a>
                <a href="<%= path %>/products">Products</a>
            </div>
            <div class="logo">
                <a href="<%= path %>/home" style="text-decoration:none; color:black;">
                    <i class="fa-brands fa-atlassian fa-xl"></i>
                </a>
            </div>
            <div class="menu-right">
                <% if (loggedUser != null) { %>
                <span style="font-size:14px; color:#555;">Hi, <strong><%= loggedUser.getDisplayName() %></strong></span>
                <span>|</span>
                <a href="<%= path %>/auth?action=logout" class="icon">Sign Out</a>
                <% } else { %>
                <a href="<%= path %>/auth?action=loginForm" class="icon">Login</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=registerForm" class="icon">Register</a>
                <% } %>
                <div class="search-wrap" style="margin-left:8px;">
                    <input type="text" id="searchInput" placeholder="Search..." autocomplete="off">
                    <i class="fa-solid fa-magnifying-glass search-icon"></i>
                    <div id="searchDropdown" class="search-dropdown"></div>
                </div>
                <a href="<%= path %>/cart" class="cart" style="position:relative;margin-left:8px;">
                    <i class="fa-solid fa-basket-shopping fa-xl"></i>
                    <span id="cartBadge" class="cart-badge">0</span>
                </a>
            </div>
        </header>

        <div id="overlay" class="overlay" onclick="closeMenu()"></div>
        <div id="sideMenu" class="side-menu">
            <div class="close-btn" onclick="closeMenu()">✕</div>
            <a href="<%= path %>/home">Home</a>
            <a href="<%= path %>/products">Products</a>
            <% if (loggedUser != null) { %>
            <a href="<%= path %>/profile">My Account</a>
            <a href="<%= path %>/auth?action=logout">Sign Out</a>
            <% } else { %>
            <a href="<%= path %>/auth?action=loginForm">Login</a>
            <% } %>
            <a href="<%= path %>/cart">Shopping Cart</a>
        </div>

        <!-- ==================== MAIN ==================== -->
        <div class="pl-wrapper">

            <!-- ── FILTER SIDEBAR ── -->
            <aside class="pl-sidebar">
                <h3>Filter</h3>

                <form action="<%= path %>/products" method="get" id="filterForm">
                    <!-- Keep keyword if exists -->
                    <% if (!keyword.isEmpty()) { %>
                    <input type="hidden" name="keyword" value="<%= keyword %>">
                    <% } %>
                    <% if (!sortBy.isEmpty()) { %>
                    <input type="hidden" name="sortBy" value="<%= sortBy %>">
                    <% } %>

                    <!-- Category -->
                    <div class="filter-section">
                        <h4>Category</h4>
                        <select name="categoryId">
                            <option value="0">All Categories</option>
                            <% for (Category cat : categories) { %>
                            <option value="<%= cat.getCategoryId() %>"
                                    <%= cat.getCategoryId() == categoryId ? "selected" : "" %>>
                                <%= cat.getCategoryName() %>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <!-- Brand -->
                    <div class="filter-section">
                        <h4>Brand</h4>
                        <select name="brandId">
                            <option value="0">All Brands</option>
                            <% for (Brand b : brands) { %>
                            <option value="<%= b.getBrandId() %>"
                                    <%= b.getBrandId() == brandId ? "selected" : "" %>>
                                <%= b.getBrandName() %>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <!-- Product Type -->
                    <div class="filter-section">
                        <h4>Product Type</h4>
                        <select name="productType">
                            <option value="">All Types</option>
                            <option value="featured"    <%= "featured".equals(productType)    ? "selected" : "" %>>Featured</option>
                            <option value="new"         <%= "new".equals(productType)         ? "selected" : "" %>>New Arrivals</option>
                            <option value="best_seller" <%= "best_seller".equals(productType) ? "selected" : "" %>>Best Sellers</option>
                        </select>
                    </div>

                    <!-- Color -->
                    <div class="filter-section">
                        <h4>Color</h4>
                        <select name="color">
                            <option value="">All Colors</option>
                            <% for (String c : colors) { %>
                            <option value="<%= c %>" <%= c.equals(color) ? "selected" : "" %>><%= c %></option>
                            <% } %>
                        </select>
                    </div>

                    <!-- Price Range -->
                    <div class="filter-section">
                        <h4>Price Range ($)</h4>
                        <div class="price-row">
                            <input type="number" name="minPrice" placeholder="Min"
                                   value="<%= request.getAttribute("minPrice") != null ? request.getAttribute("minPrice") : "" %>"
                                   min="0" step="1">
                            <input type="number" name="maxPrice" placeholder="Max"
                                   value="<%= request.getAttribute("maxPrice") != null ? request.getAttribute("maxPrice") : "" %>"
                                   min="0" step="1">
                        </div>
                    </div>

                    <button type="submit" class="btn-apply">APPLY FILTERS</button>
                    <a href="<%= path %>/products" class="btn-clear">Clear All</a>
                </form>
            </aside>

            <!-- ── MAIN CONTENT ── -->
            <main class="pl-main">

                <!-- Top bar -->
                <div class="pl-topbar">
                    <div>
                        <h2>ALL PRODUCTS</h2>
                        <div class="result-count">
                            <%= totalProducts %> item<%= totalProducts != 1 ? "s" : "" %>
                            <% if (!keyword.isEmpty()) { %> for "<%= keyword %>"<% } %>
                        </div>
                    </div>
                    <select class="sort-select" onchange="applySort(this.value)">
                        <option value=""          <%= "".equals(sortBy)          ? "selected" : "" %>>Newest First</option>
                        <option value="price_asc" <%= "price_asc".equals(sortBy) ? "selected" : "" %>>Price: Low to High</option>
                        <option value="price_desc"<%= "price_desc".equals(sortBy)? "selected" : "" %>>Price: High to Low</option>
                        <option value="name_asc"  <%= "name_asc".equals(sortBy)  ? "selected" : "" %>>Name: A–Z</option>
                    </select>
                </div>



                <!-- Product Grid -->
                <% if (products.isEmpty()) { %>
                <div class="pl-empty">
                    <i class="fa-solid fa-box-open"></i>
                    <p>No products found.</p>
                    <a href="<%= path %>/products" style="color:black; text-decoration:underline;">View all products</a>
                </div>
                <% } else { %>
                <div class="pl-grid">
                    <% for (Product p : products) { %>
                    <div class="pl-card <%= !p.isInStock() ? "out-of-stock" : "" %>">
                        <a href="<%= path %>/product?id=<%= p.getProductId() %>" style="text-decoration:none; color:inherit;">
                            <div class="pl-img-wrap">
                                <img src="<%= path %>/<%= p.getDisplayImage() %>" alt="<%= p.getProductName() %>">
                                <% if (p.isInStock()) { %>
                                <button class="pl-add-btn"
                                        onclick="event.preventDefault(); addToCart(<%= p.getProductId() %>)">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                                <% } %>
                            </div>
                            <div class="pl-info">
                                <span class="pl-category"><%= p.getCategoryName() %> · <%= p.getBrandName() %></span>
                                <div class="pl-row">
                                    <span class="pl-name"><%= p.getProductName() %></span>
                                    <span class="pl-price"><%= p.getFormattedPrice() %></span>
                                </div>
                                <div class="pl-stock">
                                    <% if (p.isInStock()) { %>
                                    In stock (<%= p.getStock() %>)
                                    <% } else { %>
                                    Out of stock
                                    <% } %>
                                </div>
                            </div>
                        </a>
                    </div>
                    <% } %>
                </div>

                <!-- ── Pagination ── -->
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <!-- Build base URL for pagination links -->
                    <%
                        String baseParams = "";
                        if (!keyword.isEmpty())     baseParams += "&keyword="     + java.net.URLEncoder.encode(keyword, "UTF-8");
                        if (!sortBy.isEmpty())      baseParams += "&sortBy="      + sortBy;
                        if (categoryId > 0)         baseParams += "&categoryId="  + categoryId;
                        if (brandId    > 0)         baseParams += "&brandId="     + brandId;
                        if (!productType.isEmpty()) baseParams += "&productType=" + productType;
                        if (!color.isEmpty())       baseParams += "&color="       + java.net.URLEncoder.encode(color, "UTF-8");
                        Object minP = request.getAttribute("minPrice");
                        Object maxP = request.getAttribute("maxPrice");
                        if (minP != null) baseParams += "&minPrice=" + minP;
                        if (maxP != null) baseParams += "&maxPrice=" + maxP;
                        final String bp = baseParams;
                    %>

                    <!-- Prev -->
                    <% if (currentPage > 1) { %>
                    <a href="<%= path %>/products?page=<%= currentPage-1 %><%= bp %>">‹</a>
                    <% } else { %>
                    <span class="disabled">‹</span>
                    <% } %>

                    <!-- Page numbers -->
                    <% for (int i = 1; i <= totalPages; i++) {
                        if (i == currentPage) { %>
                    <span class="active"><%= i %></span>
                    <% } else if (i == 1 || i == totalPages || Math.abs(i - currentPage) <= 2) { %>
                    <a href="<%= path %>/products?page=<%= i %><%= bp %>"><%= i %></a>
                    <% } else if (Math.abs(i - currentPage) == 3) { %>
                    <span>...</span>
                    <% }
                    } %>

                    <!-- Next -->
                    <% if (currentPage < totalPages) { %>
                    <a href="<%= path %>/products?page=<%= currentPage+1 %><%= bp %>">›</a>
                    <% } else { %>
                    <span class="disabled">›</span>
                    <% } %>
                </div>
                <% } %>
                <% } %>

            </main>
        </div>

        <!-- ==================== FOOTER ==================== -->
        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col">
                    <h3 class="footer-logo">LAVA FASHION</h3>
                    <p class="footer-text">Discover timeless fashion inspired by elegance and modern luxury.</p>
                </div>
                <div class="footer-col">
                    <h4>Navigation</h4>
                    <ul>
                        <li><a href="<%= path %>/home">Home</a></li>
                        <li><a href="<%= path %>/products">Shop</a></li>
                    </ul>
                </div>
                <div class="footer-col">
                    <h4>Contact</h4>
                    <p>Email: hungg8746@gmail.com</p>
                    <p>Phone: 0702285883</p>
                </div>
            </div>
            <div class="footer-bottom">
                <p>© 2026 LAVA Fashion. All rights reserved.</p>
            </div>
        </footer>

        <script>
            const BASE_URL = '<%= path %>';

            function addToCart(productId) {
                const user = '<%= loggedUser != null ? "yes" : "" %>';
                if (!user) {
                    window.location.href = BASE_URL + '/auth?action=loginForm';
                    return;
                }
                fetch(BASE_URL + '/cart', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'action=add&productId=' + productId + '&quantity=1'
                }).then(r => r.json()).then(data => {
                    alert(data.success ? 'Added to cart!' : (data.message || 'Failed.'));
                }).catch(() => alert('Error. Please try again.'));
            }

            function applySort(val) {
                const url = new URL(window.location.href);
                if (val)
                    url.searchParams.set('sortBy', val);
                else
                    url.searchParams.delete('sortBy');
                url.searchParams.set('page', '1');
                window.location.href = url.toString();
            }

            function openMenu() {
                document.getElementById("sideMenu").style.left = "0";
                document.getElementById("overlay").classList.add("active");
            }
            function closeMenu() {
                document.getElementById("sideMenu").style.left = "-280px";
                document.getElementById("overlay").classList.remove("active");
            }
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
