<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Product, model.Review, model.User, java.util.List" %>
<%
    String path = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");
    Product p = (Product) request.getAttribute("product");
    List<Review>  reviews  = (List<Review>)  request.getAttribute("reviews");
    List<Product> similar  = (List<Product>) request.getAttribute("similar");
    boolean alreadyReviewed = Boolean.TRUE.equals(request.getAttribute("alreadyReviewed"));

    if (p == null) {
        response.sendRedirect(path + "/products");
        return;
    }
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title><%= p.getProductName() %> – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            /* ── DETAIL LAYOUT ── */
            .detail-wrap {
                max-width: 1100px;
                margin: 40px auto;
                padding: 0 24px;
                display: flex;
                gap: 48px;
            }
            .detail-gallery {
                flex: 0 0 460px;
            }
            .detail-main-img {
                width: 100%;
                aspect-ratio: 3/4;
                object-fit: cover;
                background: #f5f5f5;
            }
            .detail-thumbs {
                display: flex;
                gap: 10px;
                margin-top: 12px;
            }
            .detail-thumbs img {
                width: 72px;
                height: 90px;
                object-fit: cover;
                cursor: pointer;
                border: 2px solid transparent;
            }
            .detail-thumbs img.active {
                border-color: #111;
            }

            .detail-info {
                flex: 1;
            }
            .detail-breadcrumb {
                font-size: 13px;
                color: #888;
                margin-bottom: 16px;
            }
            .detail-breadcrumb a {
                color: #888;
                text-decoration: none;
            }
            .detail-breadcrumb a:hover {
                color: #111;
            }
            .detail-category {
                font-size: 13px;
                color: #888;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 8px;
            }
            .detail-name {
                font-size: 28px;
                font-weight: 700;
                margin-bottom: 8px;
            }
            .detail-brand {
                font-size: 14px;
                color: #666;
                margin-bottom: 16px;
            }
            .detail-rating {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 20px;
            }
            .stars {
                color: #f5a623;
                font-size: 15px;
            }
            .detail-rating span {
                font-size: 13px;
                color: #888;
            }
            .detail-price {
                font-size: 32px;
                font-weight: 700;
                margin-bottom: 24px;
            }
            .detail-meta {
                display: flex;
                flex-direction: column;
                gap: 8px;
                margin-bottom: 24px;
                font-size: 14px;
                color: #555;
            }
            .detail-meta span strong {
                color: #111;
            }
            .detail-stock {
                font-size: 13px;
                margin-bottom: 20px;
            }
            .in-stock {
                color: #27ae60;
            }
            .out-stock {
                color: #e74c3c;
            }

            .detail-add {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 32px;
            }
            .qty-wrap {
                display: flex;
                align-items: center;
                border: 1px solid #ddd;
            }
            .qty-wrap button {
                width: 36px;
                height: 44px;
                border: none;
                background: none;
                font-size: 18px;
                cursor: pointer;
            }
            .qty-wrap input {
                width: 50px;
                height: 44px;
                border: none;
                border-left: 1px solid #ddd;
                border-right: 1px solid #ddd;
                text-align: center;
                font-size: 15px;
            }
            .btn-add-cart {
                flex: 1;
                height: 44px;
                background: #111;
                color: #fff;
                border: none;
                font-size: 14px;
                letter-spacing: 1px;
                cursor: pointer;
            }
            .btn-add-cart:hover {
                background: #333;
            }
            .btn-add-cart:disabled {
                background: #ccc;
                cursor: not-allowed;
            }

            .detail-desc h4 {
                font-size: 14px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 8px;
            }
            .detail-desc p {
                font-size: 14px;
                color: #555;
                line-height: 1.7;
            }

            /* ── SIZE SELECTOR ── */
            .size-selector {
                margin-bottom: 20px;
            }
            .size-label {
                font-size: 14px;
                margin-bottom: 10px;
            }
            .size-options {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }
            .size-btn input {
                display: none;
            }
            .size-btn span {
                display: inline-block;
                min-width: 44px;
                height: 36px;
                line-height: 36px;
                text-align: center;
                border: 1px solid #ddd;
                font-size: 13px;
                cursor: pointer;
                padding: 0 8px;
            }
            .size-btn input:checked + span {
                border-color: #111;
                background: #111;
                color: #fff;
            }
            .size-btn span:hover {
                border-color: #111;
            }
            .size-soldout span {
                color: #ccc;
                border-color: #eee;
                cursor: not-allowed;
                text-decoration: line-through;
            }
            .size-soldout span:hover {
                border-color: #eee;
            }

            /* ── REVIEWS ── */
            .reviews-section {
                max-width: 1100px;
                margin: 48px auto;
                padding: 0 24px;
            }
            .reviews-section h3 {
                font-size: 18px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 24px;
                border-bottom: 1px solid #eee;
                padding-bottom: 12px;
            }
            .review-card {
                padding: 20px 0;
                border-bottom: 1px solid #f0f0f0;
            }
            .review-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 8px;
            }
            .review-user {
                font-weight: 600;
                font-size: 14px;
            }
            .review-date {
                font-size: 12px;
                color: #aaa;
            }
            .review-stars {
                color: #f5a623;
                font-size: 14px;
                margin-bottom: 6px;
            }
            .review-comment {
                font-size: 14px;
                color: #555;
                line-height: 1.6;
            }
            .no-reviews {
                color: #aaa;
                font-size: 14px;
            }

            /* ── WRITE REVIEW ── */
            .write-review {
                background: #fafafa;
                border: 1px solid #eee;
                padding: 24px;
                margin-top: 24px;
            }
            .write-review h4 {
                font-size: 15px;
                font-weight: 700;
                margin-bottom: 16px;
            }
            .star-select {
                display: flex;
                flex-direction: row-reverse;
                gap: 4px;
                margin-bottom: 14px;
            }
            .star-select input {
                display: none;
            }
            .star-select label {
                font-size: 28px;
                color: #ddd;
                cursor: pointer;
            }
            .star-select input:checked ~ label,
            .star-select label:hover,
            .star-select label:hover ~ label {
                color: #f5a623;
            }
            .write-review textarea {
                width: 100%;
                height: 90px;
                border: 1px solid #ddd;
                padding: 10px;
                font-size: 14px;
                resize: vertical;
                margin-bottom: 12px;
                box-sizing: border-box;
            }
            .btn-submit-review {
                background: #111;
                color: #fff;
                border: none;
                padding: 10px 28px;
                font-size: 13px;
                letter-spacing: 1px;
                cursor: pointer;
            }
            .btn-submit-review:hover {
                background: #333;
            }

            /* ── SIMILAR PRODUCTS ── */
            .similar-section {
                max-width: 1100px;
                margin: 48px auto 64px;
                padding: 0 24px;
            }
            .similar-section h3 {
                font-size: 18px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 24px;
                border-bottom: 1px solid #eee;
                padding-bottom: 12px;
            }
            .similar-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 24px;
            }
            .sim-card {
                text-decoration: none;
                color: inherit;
                display: block;
            }
            .sim-card img {
                width: 100%;
                aspect-ratio: 3/4;
                object-fit: cover;
                background: #f5f5f5;
            }
            .sim-card .sim-type {
                font-size: 12px;
                color: #888;
                margin: 8px 0 2px;
                text-transform: uppercase;
            }
            .sim-card .sim-name {
                font-size: 14px;
                font-weight: 600;
                margin-bottom: 4px;
            }
            .sim-card .sim-price {
                font-size: 14px;
                font-weight: 700;
            }
            .sim-card:hover img {
                opacity: 0.85;
            }

            /* ── TOAST ── */
            .toast {
                position:fixed;
                bottom:28px;
                right:28px;
                padding:14px 24px;
                font-size:14px;
                color:#fff;
                z-index:9999;
                border-radius:2px;
                opacity:0;
                transition:opacity .3s;
                pointer-events:none;
            }
            .toast.success {
                background:#27ae60;
            }
            .toast.error   {
                background:#e74c3c;
            }
            .toast.show    {
                opacity:1;
            }
        </style>
    </head>
    <body>
        <%
            String cartSuccess = request.getParameter("cartSuccess");
            String cartError   = request.getParameter("cartError");
        %>
        <% if ("1".equals(cartSuccess)) { %>
        <div id="toast" class="toast success">Added to cart successfully!</div>
        <% } else if (cartError != null && !cartError.isEmpty()) { %>
        <div id="toast" class="toast error"><%= cartError %></div>
        <% } %>

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
                <% if (loggedUser.isAdmin()) { %><a href="<%= path %>/admin" class="icon">Admin</a><span>|</span><% } %>
                <a href="<%= path %>/auth?action=logout" class="icon">Sign Out</a>
                <% } else { %>
                <a href="<%= path %>/auth?action=loginForm" class="icon">Login</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=registerForm" class="icon">Register</a>
                <% } %>
                <a href="<%= path %>/cart" class="cart"><i class="fa-solid fa-basket-shopping fa-xl"></i></a>
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

        <!-- ==================== PRODUCT DETAIL ==================== -->
        <div class="detail-wrap">

            <!-- Gallery -->
            <div class="detail-gallery">
                <%
                    List<String> imgs = p.getImages();
                    String mainImg = p.getDisplayImage();
                %>
                <img id="mainImg" class="detail-main-img" src="<%= path %>/<%= mainImg %>" alt="<%= p.getProductName() %>">
                <% if (imgs != null && imgs.size() > 1) { %>
                <div class="detail-thumbs">
                    <% for (int i = 0; i < imgs.size(); i++) { %>
                    <img src="<%= path %>/<%= imgs.get(i) %>"
                         class="<%= i == 0 ? "active" : "" %>"
                         onclick="switchImg(this, '<%= path %>/<%= imgs.get(i) %>')">
                    <% } %>
                </div>
                <% } %>
            </div>

            <!-- Info -->
            <div class="detail-info">
                <div class="detail-breadcrumb">
                    <a href="<%= path %>/home">Home</a> &rsaquo;
                    <a href="<%= path %>/products">Products</a> &rsaquo;
                    <%= p.getProductName() %>
                </div>

                <div class="detail-category"><%= p.getCategoryName() %></div>
                <div class="detail-name"><%= p.getProductName() %></div>
                <div class="detail-brand">Brand: <strong><%= p.getBrandName() %></strong></div>

                <div class="detail-rating">
                    <div class="stars">
                        <% for (int i = 1; i <= 5; i++) { %>
                        <i class="fa-<%= i <= Math.round(p.getRating()) ? "solid" : "regular" %> fa-star"></i>
                        <% } %>
                    </div>
                    <span><%= String.format("%.1f", p.getRating()) %> · <%= reviews != null ? reviews.size() : 0 %> reviews</span>
                </div>

                <div class="detail-price"><%= p.getFormattedPrice() %></div>

                <div class="detail-meta">
                    <span><strong>Color:</strong> <%= p.getColor() != null && !p.getColor().isEmpty() ? p.getColor() : "—" %></span>
                </div>

                <!-- SIZE SELECTOR -->
                <!-- Build sizeStocks & cartQty JSON for JS -->
                <%
                    java.util.LinkedHashMap<String, Integer> sizeStocks = p.getSizeStocks();

                    // Build cartQtyMap: how many of each size already in cart
                    java.util.Map<String, Integer> cartQtyMap = new java.util.HashMap<>();
                    @SuppressWarnings("unchecked")
                    java.util.List<model.CartItem> cartItemsForCheck =
                        (java.util.List<model.CartItem>) request.getAttribute("cartItemsForCheck");
                    if (cartItemsForCheck != null) {
                        for (model.CartItem ci : cartItemsForCheck) {
                            if (ci.getProduct().getProductId() == p.getProductId()) {
                                cartQtyMap.merge(ci.getSize(), ci.getQuantity(), Integer::sum);
                            }
                        }
                    }

                    StringBuilder sizeJson    = new StringBuilder("{");
                    StringBuilder cartQtyJson = new StringBuilder("{");
                    int firstStock = p.getStock();
                    String firstSize = "";
                    if (sizeStocks != null && !sizeStocks.isEmpty()) {
                        boolean firstEntry = true;
                        for (java.util.Map.Entry<String, Integer> e : sizeStocks.entrySet()) {
                            if (!firstEntry) { sizeJson.append(","); cartQtyJson.append(","); }
                            int inCart = cartQtyMap.getOrDefault(e.getKey(), 0);
                            int avail  = Math.max(0, e.getValue() - inCart);
                            sizeJson.append("\"").append(e.getKey()).append("\":").append(avail);
                            cartQtyJson.append("\"").append(e.getKey()).append("\":").append(inCart);
                            if (firstEntry) { firstStock = avail; firstSize = e.getKey(); }
                            firstEntry = false;
                        }
                    }
                    sizeJson.append("}");
                    cartQtyJson.append("}");
                %>
                <script>
                    var sizeStockMap = <%= sizeJson.toString() %>;
                    var cartQtyMap = <%= cartQtyJson.toString() %>;
                </script>

                <!-- Add to cart FORM — wraps size selector + qty + button -->
                <% if (p.isInStock()) { %>
                <form id="addCartForm" method="POST" action="<%= path %>/cart">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="productId" value="<%= p.getProductId() %>">

                    <!-- SIZE SELECTOR (inside form) -->
                    <% if (sizeStocks != null && !sizeStocks.isEmpty()) { %>
                    <div class="size-selector">
                        <p class="size-label"><strong>Size</strong></p>
                        <div class="size-options">
                            <% boolean firstAvail = true;
                               for (java.util.Map.Entry<String, Integer> entry : sizeStocks.entrySet()) {
                                   String sz  = entry.getKey();
                                   int sQty   = entry.getValue();
                                   boolean soldOut = (sQty <= 0);
                                   String checkedAttr = (!soldOut && firstAvail) ? "checked" : "";
                                   if (!soldOut && firstAvail) firstAvail = false;
                            %>
                            <label class="size-btn <%= soldOut ? "size-soldout" : "" %>">
                                <input type="radio" name="selectedSize" value="<%= sz %>"
                                       <%= checkedAttr %> <%= soldOut ? "disabled" : "" %>
                                       onchange="onSizeChange('<%= sz %>')">
                                <span><%= sz %></span>
                            </label>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <!-- STOCK DISPLAY (updates on size change) -->
                    <div class="detail-stock">
                        <span id="stockDisplay" class="in-stock">
                            <i class="fa-solid fa-circle-check"></i>
                            In stock (<span id="stockCount"><%= firstStock %></span>)
                        </span>
                    </div>

                    <!-- QTY + BUTTON -->
                    <div class="detail-add">
                        <div class="qty-wrap">
                            <button type="button" onclick="changeQty(-1)">−</button>
                            <input type="number" id="qtyInput" name="quantity" value="1" min="1" max="<%= firstStock %>">
                            <button type="button" onclick="changeQty(1)">+</button>
                        </div>
                        <% if (loggedUser != null) { %>
                        <button type="submit" class="btn-add-cart">ADD TO CART</button>
                        <% } else { %>
                        <button type="button" class="btn-add-cart"
                                onclick="window.location.href = '<%= path %>/auth?action=loginForm'">
                            LOGIN TO ADD TO CART
                        </button>
                        <% } %>
                    </div>
                </form>
                <% } else { %>
                <div class="detail-stock">
                    <span class="out-stock"><i class="fa-solid fa-circle-xmark"></i> Out of stock</span>
                </div>
                <button class="btn-add-cart" disabled>OUT OF STOCK</button>
                <% } %>

                <div class="detail-desc">
                    <h4>Description</h4>
                    <p><%= p.getDescription() != null && !p.getDescription().isEmpty()
                    ? p.getDescription() : "No description available." %></p>
                </div>
            </div>
        </div>

        <!-- ==================== REVIEWS ==================== -->
        <div class="reviews-section">
            <h3>Customer Reviews</h3>

            <% if (reviews == null || reviews.isEmpty()) { %>
            <p class="no-reviews">No reviews yet. Be the first to review this product!</p>
            <% } else {
        for (Review rv : reviews) { %>
            <div class="review-card">
                <div class="review-header">
                    <span class="review-user"><%= rv.getUsername() %></span>
                    <span class="review-date">
                        <%= rv.getCreatedAt() != null
                            ? rv.getCreatedAt().toLocalDate().toString()
                            : "" %>
                    </span>
                </div>
                <div class="review-stars">
                    <% for (int i = 1; i <= 5; i++) { %>
                    <i class="fa-<%= i <= rv.getRating() ? "solid" : "regular" %> fa-star"></i>
                    <% } %>
                </div>
                <div class="review-comment"><%= rv.getComment() %></div>
            </div>
            <% } } %>

            <!-- Write Review -->
            <% if (loggedUser != null && !alreadyReviewed) { %>
            <div class="write-review">
                <h4>Write a Review</h4>
                <form method="POST" action="<%= path %>/product">
                    <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                    <div class="star-select">
                        <input type="radio" name="rating" id="s5" value="5"><label for="s5">★</label>
                        <input type="radio" name="rating" id="s4" value="4"><label for="s4">★</label>
                        <input type="radio" name="rating" id="s3" value="3" checked><label for="s3">★</label>
                        <input type="radio" name="rating" id="s2" value="2"><label for="s2">★</label>
                        <input type="radio" name="rating" id="s1" value="1"><label for="s1">★</label>
                    </div>
                    <textarea name="comment" placeholder="Share your thoughts about this product..."></textarea>
                    <button type="submit" class="btn-submit-review">SUBMIT REVIEW</button>
                </form>
            </div>
            <% } else if (loggedUser != null && alreadyReviewed) { %>
            <p style="color:#888; font-size:14px; margin-top:16px;">You have already reviewed this product.</p>
            <% } else { %>
            <p style="font-size:14px; margin-top:16px;">
                <a href="<%= path %>/auth?action=loginForm" style="color:#111; font-weight:600;">Login</a>
                to write a review.
            </p>
            <% } %>
        </div>

        <!-- ==================== SIMILAR PRODUCTS ==================== -->
        <% if (similar != null && !similar.isEmpty()) { %>
        <div class="similar-section">
            <h3>You May Also Like</h3>
            <div class="similar-grid">
                <% for (Product sp : similar) { %>
                <a href="<%= path %>/product?id=<%= sp.getProductId() %>" class="sim-card">
                    <img src="<%= path %>/<%= sp.getDisplayImage() %>" alt="<%= sp.getProductName() %>">
                    <div class="sim-type"><%= sp.getCategoryName() %> · <%= sp.getBrandName() %></div>
                    <div class="sim-name"><%= sp.getProductName() %></div>
                    <div class="sim-price"><%= sp.getFormattedPrice() %></div>
                </a>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- ==================== FOOTER ==================== -->
        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col">
                    <h3 class="footer-logo">LUXURY FASHION</h3>
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
                    <h4>Account</h4>
                    <ul>
                        <% if (loggedUser != null) { %>
                        <li><a href="<%= path %>/profile">My Profile</a></li>
                        <li><a href="<%= path %>/auth?action=logout">Sign Out</a></li>
                            <% } else { %>
                        <li><a href="<%= path %>/auth?action=loginForm">Login</a></li>
                        <li><a href="<%= path %>/auth?action=registerForm">Register</a></li>
                            <% } %>
                    </ul>
                </div>
                <div class="footer-col">
                    <h4>Contact</h4>
                    <p>Email: hungg8746@gmail.com</p>
                    <p>Phone: 0702285883</p>
                </div>
            </div>
            <div class="footer-bottom">
                <p>© 2026 Luxury Fashion. All rights reserved.</p>
            </div>
        </footer>

        <script>
            function openMenu() {
                document.getElementById("sideMenu").style.left = "0";
                document.getElementById("overlay").classList.add("active");
            }
            function closeMenu() {
                document.getElementById("sideMenu").style.left = "-280px";
                document.getElementById("overlay").classList.remove("active");
            }

            function switchImg(el, src) {
                document.getElementById("mainImg").src = src;
                document.querySelectorAll(".detail-thumbs img").forEach(i => i.classList.remove("active"));
                el.classList.add("active");
            }

            function onSizeChange(size) {
                var avail = sizeStockMap[size] || 0;
                var stockDisplay = document.getElementById("stockDisplay");
                var qtyInput = document.getElementById("qtyInput");
                if (qtyInput) {
                    qtyInput.max = avail;
                    if (parseInt(qtyInput.value) > avail)
                        qtyInput.value = Math.max(1, avail);
                    if (avail <= 0)
                        qtyInput.value = 0;
                }
                if (stockDisplay) {
                    if (avail <= 0) {
                        stockDisplay.className = "out-stock";
                        stockDisplay.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> Out of stock';
                    } else {
                        stockDisplay.className = "in-stock";
                        stockDisplay.innerHTML = '<i class="fa-solid fa-circle-check"></i> In stock (<span id="stockCount">' + avail + '</span>)';
                    }
                }
            }

            function changeQty(delta) {
                var inp = document.getElementById("qtyInput");
                var val = parseInt(inp.value) + delta;
                var max = parseInt(inp.max);
                if (val < 1)
                    val = 1;
                if (val > max)
                    val = max;
                inp.value = val;
            }

            // Toast
            var toast = document.getElementById("toast");
            if (toast) {
                toast.classList.add("show");
                setTimeout(function () {
                    toast.classList.remove("show");
                }, 3000);
            }
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
