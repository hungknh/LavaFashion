<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.CartItem, model.User, java.util.List" %>
<%
    String path = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    double cartTotal = cartItems != null
        ? cartItems.stream().mapToDouble(CartItem::getSubtotal).sum() : 0;
    if (cartItems == null) cartItems = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>Shopping Cart – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            .cart-wrap {
                max-width: 1100px;
                margin: 48px auto;
                padding: 0 24px;
                display: flex;
                gap: 40px;
                align-items: flex-start;
            }

            /* ── CART TABLE ── */
            .cart-main {
                flex: 1;
            }
            .cart-title {
                font-size: 22px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 28px;
            }
            .cart-table {
                width: 100%;
                border-collapse: collapse;
            }
            .cart-table th {
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #888;
                font-weight: 600;
                padding: 0 0 12px;
                border-bottom: 1px solid #eee;
                text-align: left;
            }
            .cart-table th:last-child, .cart-table td:last-child {
                text-align: right;
            }
            .cart-table td {
                padding: 20px 0;
                border-bottom: 1px solid #f0f0f0;
                vertical-align: middle;
            }

            .cart-product {
                display: flex;
                align-items: center;
                gap: 16px;
            }
            .cart-product img {
                width: 80px;
                height: 100px;
                object-fit: cover;
                background: #f5f5f5;
                flex-shrink: 0;
            }
            .cart-product-info .name {
                font-size: 14px;
                font-weight: 600;
                margin-bottom: 4px;
            }
            .cart-product-info .meta {
                font-size: 12px;
                color: #888;
            }

            .cart-price {
                font-size: 14px;
                font-weight: 500;
                min-width: 80px;
            }

            /* Qty control */
            .qty-ctrl {
                display: flex;
                align-items: center;
                border: 1px solid #ddd;
                width: fit-content;
            }
            .qty-ctrl button {
                width: 32px;
                height: 32px;
                border: none;
                background: none;
                font-size: 16px;
                cursor: pointer;
                line-height: 1;
            }
            .qty-ctrl input {
                width: 40px;
                height: 32px;
                border: none;
                border-left: 1px solid #ddd;
                border-right: 1px solid #ddd;
                text-align: center;
                font-size: 13px;
                -moz-appearance: textfield;
            }
            .qty-ctrl input::-webkit-outer-spin-button,
            .qty-ctrl input::-webkit-inner-spin-button {
                -webkit-appearance: none;
            }

            .cart-subtotal {
                font-size: 14px;
                font-weight: 700;
                min-width: 80px;
            }

            .btn-remove {
                background: none;
                border: none;
                color: #bbb;
                cursor: pointer;
                font-size: 16px;
                padding: 4px;
            }
            .btn-remove:hover {
                color: #e74c3c;
            }

            /* ── EMPTY CART ── */
            .cart-empty {
                text-align: center;
                padding: 64px 0;
            }
            .cart-empty i {
                font-size: 48px;
                color: #ddd;
                margin-bottom: 20px;
            }
            .cart-empty p {
                color: #888;
                font-size: 16px;
                margin-bottom: 24px;
            }
            .btn-continue {
                display: inline-block;
                padding: 12px 32px;
                border: 1px solid #111;
                font-size: 13px;
                letter-spacing: 1px;
                text-decoration: none;
                color: #111;
            }
            .btn-continue:hover {
                background: #111;
                color: #fff;
            }

            /* ── ORDER SUMMARY ── */
            .cart-summary {
                flex: 0 0 320px;
                background: #fafafa;
                border: 1px solid #eee;
                padding: 28px;
            }
            .summary-title {
                font-size: 14px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 20px;
            }
            .summary-row {
                display: flex;
                justify-content: space-between;
                font-size: 14px;
                margin-bottom: 12px;
                color: #555;
            }
            .summary-divider {
                border: none;
                border-top: 1px solid #eee;
                margin: 16px 0;
            }
            .summary-total {
                display: flex;
                justify-content: space-between;
                font-size: 16px;
                font-weight: 700;
                margin-bottom: 24px;
            }
            .btn-checkout {
                display: block;
                width: 100%;
                padding: 14px;
                background: #111;
                color: #fff;
                border: none;
                font-size: 13px;
                letter-spacing: 1px;
                cursor: pointer;
                text-align: center;
                text-decoration: none;
            }
            .btn-checkout:hover {
                background: #333;
            }
            .btn-shop {
                display: block;
                text-align: center;
                margin-top: 12px;
                font-size: 13px;
                color: #888;
                text-decoration: none;
            }
            .btn-shop:hover {
                color: #111;
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
                <% if (loggedUser.isAdmin()) { %><a href="<%= path %>/admin" class="icon">Admin</a><span>|</span><% } %>
                <a href="<%= path %>/order-history" class="icon">My Orders</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=logout" class="icon">Sign Out</a>
                <% } else { %>
                <a href="<%= path %>/auth?action=loginForm" class="icon">Login</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=registerForm" class="icon">Register</a>
                <% } %>
                <a href="<%= path %>/cart" class="cart">
                    <i class="fa-solid fa-basket-shopping fa-xl"></i>
                    <% if (!cartItems.isEmpty()) { %>
                    <span class="cart-badge"><%= cartItems.size() %></span>
                    <% } %>
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

        <!-- ==================== CART CONTENT ==================== -->
        <div class="cart-wrap">

            <div class="cart-main">
                <h2 class="cart-title">Shopping Cart (<%= cartItems.size() %> items)</h2>

                <% if (cartItems.isEmpty()) { %>
                <div class="cart-empty">
                    <i class="fa-solid fa-basket-shopping"></i>
                    <p>Your cart is empty.</p>
                    <a href="<%= path %>/products" class="btn-continue">Continue Shopping</a>
                </div>

                <% } else { %>
                <table class="cart-table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Price</th>
                            <th>Quantity</th>
                            <th>Subtotal</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (CartItem item : cartItems) { %>
                        <tr>
                            <!-- Product info -->
                            <td>
                                <div class="cart-product">
                                    <img src="<%= path %>/<%= item.getProduct().getDisplayImage() %>"
                                         alt="<%= item.getProduct().getProductName() %>">
                                    <div class="cart-product-info">
                                        <div class="name">
                                            <a href="<%= path %>/product?id=<%= item.getProduct().getProductId() %>"
                                               style="text-decoration:none; color:inherit;">
                                                <%= item.getProduct().getProductName() %>
                                            </a>
                                        </div>
                                        <div class="meta">
                                            Size: <strong><%= item.getSize() %></strong>
                                            <% if (item.getProduct().getColor() != null && !item.getProduct().getColor().isEmpty()) { %>
                                            &nbsp;·&nbsp; Color: <%= item.getProduct().getColor() %>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <!-- Price -->
                            <td class="cart-price"><%= item.getProduct().getFormattedPrice() %></td>

                            <!-- Quantity -->
                            <td>
                                <div class="qty-ctrl">
                                    <button type="button"
                                            onclick="updateQty(<%= item.getCartItemId() %>, <%= item.getQuantity() - 1 %>)">−</button>
                                    <input type="number" id="qty_<%= item.getCartItemId() %>"
                                           value="<%= item.getQuantity() %>" min="1" max="<%= item.getProduct().getStock() %>"
                                           onchange="updateQty(<%= item.getCartItemId() %>, this.value)">
                                    <button type="button"
                                            onclick="updateQty(<%= item.getCartItemId() %>, <%= item.getQuantity() + 1 %>)">+</button>
                                </div>
                            </td>

                            <!-- Subtotal -->
                            <td class="cart-subtotal"><%= item.getFormattedSubtotal() %></td>

                            <!-- Remove -->
                            <td>
                                <form method="POST" action="<%= path %>/cart" style="display:inline;">
                                    <input type="hidden" name="action" value="remove">
                                    <input type="hidden" name="cartItemId" value="<%= item.getCartItemId() %>">
                                    <button type="submit" class="btn-remove" title="Remove">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>

                <div style="margin-top: 20px;">
                    <a href="<%= path %>/products" class="btn-continue">← Continue Shopping</a>
                </div>
                <% } %>
            </div>

            <!-- ── ORDER SUMMARY ── -->
            <% if (!cartItems.isEmpty()) { %>
            <div class="cart-summary">
                <div class="summary-title">Order Summary</div>

                <div class="summary-row">
                    <span>Subtotal (<%= cartItems.size() %> items)</span>
                    <span>$<%= String.format("%.2f", cartTotal) %></span>
                </div>
                <div class="summary-row">
                    <span>Shipping</span>
                    <span>Free</span>
                </div>

                <hr class="summary-divider">

                <div class="summary-total">
                    <span>Total</span>
                    <span>$<%= String.format("%.2f", cartTotal) %></span>
                </div>

                <a href="<%= path %>/checkout" class="btn-checkout">PROCEED TO CHECKOUT</a>
                <a href="<%= path %>/products" class="btn-shop">Continue Shopping</a>
            </div>
            <% } %>

        </div>

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

        <!-- Hidden update form -->
        <form id="updateForm" method="POST" action="<%= path %>/cart">
            <input type="hidden" name="action" value="update">
            <input type="hidden" id="updateItemId" name="cartItemId" value="">
            <input type="hidden" id="updateQty" name="quantity" value="">
        </form>

        <script>
            function openMenu() {
                document.getElementById("sideMenu").style.left = "0";
                document.getElementById("overlay").classList.add("active");
            }
            function closeMenu() {
                document.getElementById("sideMenu").style.left = "-280px";
                document.getElementById("overlay").classList.remove("active");
            }

            function updateQty(itemId, qty) {
                qty = parseInt(qty);
                if (isNaN(qty) || qty < 0)
                    return;
                document.getElementById("updateItemId").value = itemId;
                document.getElementById("updateQty").value = qty;
                document.getElementById("updateForm").submit();
            }
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
