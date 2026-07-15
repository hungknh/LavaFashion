<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.CartItem, model.User, java.util.List" %>
<%
    String path = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    double cartTotal = cartItems != null ? cartItems.stream().mapToDouble(CartItem::getSubtotal).sum() : 0;
    if (cartItems == null) cartItems = new java.util.ArrayList<>();
    String error         = (String) request.getAttribute("error");
    String receiverName  = (String) request.getAttribute("receiverName");
    String receiverPhone = (String) request.getAttribute("receiverPhone");
    String shippingAddr  = (String) request.getAttribute("shippingAddress");
    if (receiverName  == null) receiverName  = "";
    if (receiverPhone == null) receiverPhone = "";
    if (shippingAddr  == null) shippingAddr  = "";
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>Checkout – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            .checkout-wrap {
                max-width: 1100px;
                margin: 48px auto;
                padding: 0 24px;
                display: flex;
                gap: 40px;
                align-items: flex-start;
            }

            /* ── FORM ── */
            .checkout-form {
                flex: 1;
            }
            .checkout-form h2 {
                font-size: 20px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 28px;
            }
            .form-section {
                margin-bottom: 32px;
            }
            .form-section h3 {
                font-size: 13px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #888;
                margin-bottom: 16px;
                border-bottom: 1px solid #eee;
                padding-bottom: 8px;
            }
            .form-row {
                display: flex;
                gap: 16px;
            }
            .form-group {
                display: flex;
                flex-direction: column;
                margin-bottom: 16px;
                flex: 1;
            }
            .form-group label {
                font-size: 12px;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: .5px;
                color: #555;
                margin-bottom: 6px;
            }
            .form-group input, .form-group textarea, .form-group select {
                padding: 10px 14px;
                border: 1px solid #ddd;
                font-size: 14px;
                outline: none;
                font-family: inherit;
            }
            .form-group input:focus, .form-group textarea:focus {
                border-color: #111;
            }
            .form-group textarea {
                resize: vertical;
                height: 80px;
            }

            /* Payment */
            .payment-options {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }
            .payment-option {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 14px 16px;
                border: 1px solid #ddd;
                cursor: pointer;
            }
            .payment-option input[type=radio] {
                width: 16px;
                height: 16px;
                cursor: pointer;
            }
            .payment-option .pay-label {
                font-size: 14px;
                font-weight: 600;
            }
            .payment-option .pay-desc  {
                font-size: 12px;
                color: #888;
                margin-top: 2px;
            }
            .payment-option.selected {
                border-color: #111;
                background: #fafafa;
            }

            .btn-place-order {
                width: 100%;
                padding: 16px;
                background: #111;
                color: #fff;
                border: none;
                font-size: 14px;
                letter-spacing: 2px;
                cursor: pointer;
                margin-top: 8px;
            }
            .btn-place-order:hover {
                background: #333;
            }

            .error-msg {
                background: #fff3f3;
                border: 1px solid #ffcccc;
                color: #cc0000;
                padding: 12px 16px;
                font-size: 14px;
                margin-bottom: 20px;
            }

            /* ── ORDER SUMMARY ── */
            .checkout-summary {
                flex: 0 0 340px;
                background: #fafafa;
                border: 1px solid #eee;
                padding: 28px;
            }
            .summary-title {
                font-size: 13px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 20px;
            }
            .summary-item {
                display: flex;
                gap: 12px;
                margin-bottom: 16px;
                align-items: flex-start;
            }
            .summary-item img {
                width: 60px;
                height: 75px;
                object-fit: cover;
                background: #f0f0f0;
                flex-shrink: 0;
            }
            .summary-item-info .item-name {
                font-size: 13px;
                font-weight: 600;
                margin-bottom: 3px;
            }
            .summary-item-info .item-meta {
                font-size: 12px;
                color: #888;
            }
            .summary-item-price {
                font-size: 13px;
                font-weight: 700;
                margin-left: auto;
                white-space: nowrap;
            }
            .summary-divider {
                border: none;
                border-top: 1px solid #eee;
                margin: 16px 0;
            }
            .summary-row {
                display: flex;
                justify-content: space-between;
                font-size: 13px;
                color: #555;
                margin-bottom: 8px;
            }
            .summary-total {
                display: flex;
                justify-content: space-between;
                font-size: 16px;
                font-weight: 700;
                margin-top: 12px;
            }
        </style>
    </head>
    <body>

        <header class="header">
            <div class="menu-left">
                <i class="fa-solid fa-bars fa-xl menu-icon" onclick="openMenu()"></i>
                <a href="<%= path %>/home">Home</a>
                <a href="<%= path %>/products">Products</a>
            </div>
            <div class="logo">
                <a href="<%= path %>/home" style="text-decoration:none;color:black;">
                    <i class="fa-brands fa-atlassian fa-xl"></i>
                </a>
            </div>
            <div class="menu-right">
                <% if (loggedUser != null) { %>
                <span style="font-size:14px;color:#555;">Hi, <strong><%= loggedUser.getDisplayName() %></strong></span>
                <span>|</span>
                <a href="<%= path %>/order-history" class="icon">My Orders</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=logout" class="icon">Sign Out</a>
                <% } %>
                <a href="<%= path %>/cart" class="cart"><i class="fa-solid fa-basket-shopping fa-xl"></i></a>
            </div>
        </header>
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>
        <div id="sideMenu" class="side-menu">
            <div class="close-btn" onclick="closeMenu()">✕</div>
            <a href="<%= path %>/home">Home</a>
            <a href="<%= path %>/products">Products</a>
            <a href="<%= path %>/cart">Shopping Cart</a>
        </div>

        <div class="checkout-wrap">

            <!-- ── FORM ── -->
            <div class="checkout-form">
                <h2>Checkout</h2>

                <% if (error != null) { %>
                <div class="error-msg"><i class="fa-solid fa-circle-exclamation"></i> <%= error %></div>
                <% } %>

                <form method="POST" action="<%= path %>/checkout">

                    <!-- Shipping Info -->
                    <div class="form-section">
                        <h3>Shipping Information</h3>
                        <div class="form-row">
                            <div class="form-group">
                                <label>Full Name *</label>
                                <input type="text" name="receiverName" value="<%= receiverName %>"
                                       placeholder="Enter receiver's name" required>
                            </div>
                            <div class="form-group">
                                <label>Phone Number *</label>
                                <input type="text" name="receiverPhone" value="<%= receiverPhone %>"
                                       placeholder="Enter phone number" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Shipping Address *</label>
                            <textarea name="shippingAddress" placeholder="Street, District, City..." required><%= shippingAddr %></textarea>
                        </div>
                        <div class="form-group">
                            <label>Note (optional)</label>
                            <input type="text" name="note" placeholder="Leave a note for the seller...">
                        </div>
                    </div>

                    <!-- Payment Method -->
                    <div class="form-section">
                        <h3>Payment Method</h3>
                        <div class="payment-options">
                            <label class="payment-option selected" id="opt-cod">
                                <input type="radio" name="paymentMethod" value="COD" checked
                                       onchange="selectPayment('opt-cod')">
                                <div>
                                    <div class="pay-label"><i class="fa-solid fa-truck"></i> Cash on Delivery (COD)</div>
                                    <div class="pay-desc">Pay when you receive your order</div>
                                </div>
                            </label>
                            <label class="payment-option" id="opt-bank">
                                <input type="radio" name="paymentMethod" value="Bank Transfer"
                                       onchange="selectPayment('opt-bank')">
                                <div>
                                    <div class="pay-label"><i class="fa-solid fa-building-columns"></i> Bank Transfer</div>
                                    <div class="pay-desc">Transfer to our bank account before shipping</div>
                                </div>
                            </label>
                        </div>
                    </div>

                    <button type="submit" class="btn-place-order">PLACE ORDER</button>
                </form>
            </div>

            <!-- ── ORDER SUMMARY ── -->
            <div class="checkout-summary">
                <div class="summary-title">Order Summary (<%= cartItems.size() %> items)</div>

                <% for (CartItem item : cartItems) { %>
                <div class="summary-item">
                    <img src="<%= path %>/<%= item.getProduct().getDisplayImage() %>"
                         alt="<%= item.getProduct().getProductName() %>">
                    <div class="summary-item-info">
                        <div class="item-name"><%= item.getProduct().getProductName() %></div>
                        <div class="item-meta">Size: <%= item.getSize() %> · Qty: <%= item.getQuantity() %></div>
                    </div>
                    <div class="summary-item-price"><%= item.getFormattedSubtotal() %></div>
                </div>
                <% } %>

                <hr class="summary-divider">
                <div class="summary-row"><span>Subtotal</span><span>$<%= String.format("%.2f", cartTotal) %></span></div>
                <div class="summary-row"><span>Shipping</span><span>Free</span></div>
                <div class="summary-total"><span>Total</span><span>$<%= String.format("%.2f", cartTotal) %></span></div>
            </div>

        </div>

        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col"><h3 class="footer-logo">LUXURY FASHION</h3></div>
                <div class="footer-col">
                    <h4>Navigation</h4>
                    <ul><li><a href="<%= path %>/home">Home</a></li><li><a href="<%= path %>/products">Shop</a></li></ul>
                </div>
                <div class="footer-col">
                    <h4>Contact</h4>
                    <p>Email: hungg8746@gmail.com</p>
                </div>
            </div>
            <div class="footer-bottom"><p>© 2026 Luxury Fashion. All rights reserved.</p></div>
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
            function selectPayment(selectedId) {
                document.querySelectorAll(".payment-option").forEach(function (el) {
                    el.classList.remove("selected");
                });
                document.getElementById(selectedId).classList.add("selected");
            }
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
