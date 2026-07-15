<%-- 
    Document   : order-success
    Created on : Mar 10, 2026, 8:36:30 PM
    Author     : DELL
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Order, model.OrderItem, model.User, java.util.List" %>
<%
    String path = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");
    Order order = (Order) request.getAttribute("order");
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>Order Placed – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            .success-wrap {
                max-width: 680px;
                margin: 64px auto;
                padding: 0 24px;
                text-align: center;
            }
            .success-icon {
                font-size: 64px;
                color: #27ae60;
                margin-bottom: 20px;
            }
            .success-title {
                font-size: 26px;
                font-weight: 700;
                margin-bottom: 8px;
            }
            .success-sub {
                color: #666;
                font-size: 15px;
                margin-bottom: 32px;
            }
            .order-card {
                background: #fafafa;
                border: 1px solid #eee;
                padding: 28px;
                text-align: left;
                margin-bottom: 28px;
            }
            .order-card-title {
                font-size: 12px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #888;
                margin-bottom: 16px;
            }
            .order-info-row {
                display: flex;
                justify-content: space-between;
                padding: 8px 0;
                border-bottom: 1px solid #f0f0f0;
                font-size: 14px;
            }
            .order-info-row:last-child {
                border-bottom: none;
            }
            .order-info-row .label {
                color: #888;
            }
            .order-info-row .value {
                font-weight: 600;
            }
            .status-badge {
                display: inline-block;
                padding: 3px 10px;
                font-size: 12px;
                font-weight: 600;
                border-radius: 20px;
            }
            .status-pending    {
                background:#fff3cd;
                color:#856404;
            }
            .status-processing {
                background:#cce5ff;
                color:#004085;
            }
            .status-shipped    {
                background:#d4edda;
                color:#155724;
            }
            .status-delivered  {
                background:#d1e7dd;
                color:#0f5132;
            }
            .status-cancelled  {
                background:#f8d7da;
                color:#721c24;
            }
            .order-items-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 8px;
            }
            .order-items-table th {
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #888;
                font-weight: 600;
                padding: 0 0 10px;
                border-bottom: 1px solid #eee;
                text-align: left;
            }
            .order-items-table th:last-child {
                text-align: right;
            }
            .order-items-table td {
                padding: 12px 0;
                border-bottom: 1px solid #f5f5f5;
                font-size: 13px;
                vertical-align: middle;
            }
            .order-items-table td:last-child {
                text-align: right;
                font-weight: 700;
            }
            .item-img {
                width: 48px;
                height: 60px;
                object-fit: cover;
                background: #f0f0f0;
                margin-right: 12px;
            }
            .item-cell {
                display: flex;
                align-items: center;
            }
            .item-cell .info .name {
                font-weight: 600;
                margin-bottom: 2px;
            }
            .item-cell .info .meta {
                font-size: 11px;
                color: #888;
            }
            .order-total-row {
                display: flex;
                justify-content: space-between;
                font-size: 16px;
                font-weight: 700;
                padding-top: 14px;
                margin-top: 4px;
            }
            .btn-group {
                display: flex;
                gap: 16px;
                justify-content: center;
            }
            .btn-primary {
                display: inline-block;
                padding: 14px 32px;
                background: #111;
                color: #fff;
                text-decoration: none;
                font-size: 13px;
                letter-spacing: 1px;
            }
            .btn-primary:hover {
                background: #333;
            }
            .btn-outline {
                display: inline-block;
                padding: 14px 32px;
                border: 1px solid #111;
                color: #111;
                text-decoration: none;
                font-size: 13px;
                letter-spacing: 1px;
            }
            .btn-outline:hover {
                background: #111;
                color: #fff;
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
                <a href="<%= path %>/home" style="text-decoration:none;color:black;"><i class="fa-brands fa-atlassian fa-xl"></i></a>
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
            <a href="<%= path %>/order-history">My Orders</a>
            <a href="<%= path %>/auth?action=logout">Sign Out</a>
        </div>

        <div class="success-wrap">
            <div class="success-icon"><i class="fa-solid fa-circle-check"></i></div>
            <h1 class="success-title">Order Placed Successfully! 🎉</h1>
            <p class="success-sub">Thank you for your order. We'll process it shortly.</p>

            <% if (order != null) { %>

            <!-- Order Info -->
            <div class="order-card">
                <div class="order-card-title">Order Information</div>
                <div class="order-info-row">
                    <span class="label">Order ID</span>
                    <span class="value">#<%= order.getOrderId() %></span>
                </div>
                <div class="order-info-row">
                    <span class="label">Date</span>
                    <span class="value"><%= order.getFormattedDate() %></span>
                </div>
                <div class="order-info-row">
                    <span class="label">Receiver</span>
                    <span class="value"><%= order.getReceiverName() %> · <%= order.getReceiverPhone() %></span>
                </div>
                <div class="order-info-row">
                    <span class="label">Shipping Address</span>
                    <span class="value"><%= order.getShippingAddress() %></span>
                </div>
                <div class="order-info-row">
                    <span class="label">Payment</span>
                    <span class="value"><%= order.getPaymentMethod() %></span>
                </div>
                <div class="order-info-row">
                    <span class="label">Status</span>
                    <span class="value"><span class="status-badge <%= order.getStatusClass() %>"><%= order.getStatus() %></span></span>
                </div>
                <% if (order.getNote() != null && !order.getNote().isEmpty()) { %>
                <div class="order-info-row">
                    <span class="label">Note</span>
                    <span class="value"><%= order.getNote() %></span>
                </div>
                <% } %>
            </div>

            <!-- Order Items -->
            <% if (order.getItems() != null && !order.getItems().isEmpty()) { %>
            <div class="order-card">
                <div class="order-card-title">Items Ordered</div>
                <table class="order-items-table">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Size</th>
                            <th>Qty</th>
                            <th>Price</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (OrderItem item : order.getItems()) { %>
                        <tr>
                            <td>
                                <div class="item-cell">
                                    <img class="item-img"
                                         src="<%= path %>/<%= item.getProduct().getDisplayImage() %>"
                                         alt="<%= item.getProduct().getProductName() %>">
                                    <div class="info">
                                        <div class="name"><%= item.getProduct().getProductName() %></div>
                                        <div class="meta"><%= item.getProduct().getColor() %></div>
                                    </div>
                                </div>
                            </td>
                            <td><%= item.getSize() %></td>
                            <td><%= item.getQuantity() %></td>
                            <td><%= item.getFormattedPrice() %></td>
                            <td><%= item.getFormattedSubtotal() %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <div class="order-total-row">
                    <span>Total</span>
                    <span><%= order.getFormattedTotal() %></span>
                </div>
            </div>
            <% } %>

            <% } %>

            <div class="btn-group">
                <a href="<%= path %>/order-history" class="btn-primary">View My Orders</a>
                <a href="<%= path %>/home" class="btn-outline">Continue Shopping</a>
            </div>
        </div>

        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col"><h3 class="footer-logo">LUXURY FASHION</h3></div>
                <div class="footer-col"><h4>Navigation</h4><ul><li><a href="<%= path %>/home">Home</a></li><li><a href="<%= path %>/products">Shop</a></li></ul></div>
                <div class="footer-col"><h4>Contact</h4><p>Email: hungg8746@gmail.com</p></div>
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
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
