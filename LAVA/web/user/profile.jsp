<%-- 
    Document   : profile
    Created on : Mar 10, 2026, 8:34:38 PM
    Author     : DELL
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, model.Order, model.OrderItem, java.util.List" %>
<%
    String path       = request.getContextPath();
    User   loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) { response.sendRedirect(path + "/auth?action=loginForm"); return; }

    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
    if (recentOrders == null) recentOrders = new java.util.ArrayList<>();

    String profileSuccess = (String) session.getAttribute("profileSuccess");
    session.removeAttribute("profileSuccess");
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>My Profile – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            .profile-wrap{
                max-width:860px;
                margin:48px auto;
                padding:0 24px
            }
            .profile-card{
                display:flex;
                gap:32px;
                align-items:flex-start;
                background:#fafafa;
                border:1px solid #eee;
                padding:32px;
                margin-bottom:32px
            }
            .avatar-circle{
                width:80px;
                height:80px;
                border-radius:50%;
                background:#111;
                color:#fff;
                font-size:32px;
                font-weight:700;
                display:flex;
                align-items:center;
                justify-content:center;
                flex-shrink:0
            }
            .profile-info{
                flex:1
            }
            .profile-info h2{
                font-size:20px;
                font-weight:700;
                margin-bottom:4px
            }
            .username-tag{
                font-size:13px;
                color:#888;
                margin-bottom:16px
            }
            .info-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px 32px
            }
            .info-row .label{
                font-size:11px;
                text-transform:uppercase;
                letter-spacing:.5px;
                color:#aaa;
                font-weight:600;
                margin-bottom:2px
            }
            .info-row .value{
                font-size:14px;
                color:#333;
                font-weight:500
            }
            .profile-actions{
                display:flex;
                flex-direction:column;
                gap:10px;
                flex-shrink:0
            }
            .btn-action{
                display:inline-block;
                padding:10px 20px;
                font-size:12px;
                letter-spacing:1px;
                text-decoration:none;
                text-align:center;
                white-space:nowrap;
                cursor:pointer;
                border:none;
                font-family:inherit
            }
            .btn-dark{
                background:#111;
                color:#fff
            }
            .btn-dark:hover{
                background:#333
            }
            .btn-outline-dark{
                background:none;
                border:1px solid #111;
                color:#111
            }
            .btn-outline-dark:hover{
                background:#111;
                color:#fff
            }
            .alert-success{
                background:#d4edda;
                color:#155724;
                border:1px solid #c3e6cb;
                padding:12px 16px;
                font-size:14px;
                margin-bottom:24px
            }
            .section-header{
                display:flex;
                justify-content:space-between;
                align-items:center;
                margin-bottom:16px
            }
            .section-title{
                font-size:16px;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:1px
            }
            .link-all{
                font-size:13px;
                color:#888;
                text-decoration:none
            }
            .link-all:hover{
                color:#111
            }
            .orders-table{
                width:100%;
                border-collapse:collapse
            }
            .orders-table th{
                font-size:11px;
                text-transform:uppercase;
                color:#aaa;
                font-weight:600;
                padding:0 0 10px;
                border-bottom:1px solid #eee;
                text-align:left
            }
            .orders-table th:last-child{
                text-align:right
            }
            .orders-table td{
                padding:14px 0;
                border-bottom:1px solid #f5f5f5;
                font-size:13px;
                vertical-align:middle
            }
            .orders-table td:last-child{
                text-align:right
            }
            .order-thumbs{
                display:flex;
                gap:4px
            }
            .order-thumb{
                width:36px;
                height:46px;
                object-fit:cover;
                background:#f0f0f0
            }
            .status-badge{
                display:inline-block;
                padding:3px 10px;
                font-size:11px;
                font-weight:600;
                border-radius:20px
            }
            .status-pending{
                background:#fff3cd;
                color:#856404
            }
            .status-processing{
                background:#cce5ff;
                color:#004085
            }
            .status-shipped{
                background:#d4edda;
                color:#155724
            }
            .status-delivered{
                background:#d1e7dd;
                color:#0f5132
            }
            .status-cancelled{
                background:#f8d7da;
                color:#721c24
            }
            .btn-view{
                font-size:11px;
                color:#111;
                text-decoration:none;
                border:1px solid #ddd;
                padding:4px 10px
            }
            .btn-view:hover{
                background:#111;
                color:#fff
            }
            .empty-box{
                text-align:center;
                padding:40px;
                color:#aaa;
                border:1px dashed #ddd
            }
            .toast{
                position:fixed;
                bottom:28px;
                right:28px;
                padding:14px 24px;
                background:#27ae60;
                color:#fff;
                font-size:14px;
                z-index:9999;
                opacity:0;
                transition:opacity .3s
            }
            .toast.show{
                opacity:1
            }
        </style>
    </head>
    <body>

        <% if (profileSuccess != null) { %>
        <div id="toast" class="toast"><i class="fa-solid fa-circle-check"></i> <%= profileSuccess %></div>
        <% } %>

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
                <span style="font-size:14px;color:#555;">Hi, <strong><%= loggedUser.getDisplayName() %></strong></span>
                <span>|</span>
                <a href="<%= path %>/order-history" class="icon">My Orders</a>
                <span>|</span>
                <% if (loggedUser.isAdmin()) { %><a href="<%= path %>/admin" class="icon">Admin</a><span>|</span><% } %>
                <a href="<%= path %>/auth?action=logout" class="icon">Sign Out</a>
                <a href="<%= path %>/cart" class="cart"><i class="fa-solid fa-basket-shopping fa-xl"></i></a>
            </div>
        </header>
        <div id="overlay" class="overlay" onclick="closeMenu()"></div>
        <div id="sideMenu" class="side-menu">
            <div class="close-btn" onclick="closeMenu()">✕</div>
            <a href="<%= path %>/home">Home</a>
            <a href="<%= path %>/products">Products</a>
            <a href="<%= path %>/profile">My Profile</a>
            <a href="<%= path %>/order-history">My Orders</a>
            <a href="<%= path %>/auth?action=logout">Sign Out</a>
        </div>

        <div class="profile-wrap">

            <div class="profile-card">
                <div class="avatar-circle"><%= loggedUser.getDisplayName().substring(0,1).toUpperCase() %></div>
                <div class="profile-info">
                    <h2><%= loggedUser.getFullName() != null && !loggedUser.getFullName().isEmpty() ? loggedUser.getFullName() : loggedUser.getUsername() %></h2>
                    <div class="username-tag">@<%= loggedUser.getUsername() %>
                        <% if (loggedUser.isAdmin()) { %>&nbsp;<span style="background:#111;color:#fff;font-size:10px;padding:2px 7px;">ADMIN</span><% } %>
                    </div>
                    <div class="info-grid">
                        <div class="info-row">
                            <div class="label">Email</div>
                            <div class="value"><%= loggedUser.getEmail() != null ? loggedUser.getEmail() : "—" %></div>
                        </div>
                        <div class="info-row">
                            <div class="label">Phone</div>
                            <div class="value"><%= loggedUser.getPhone() != null && !loggedUser.getPhone().isEmpty() ? loggedUser.getPhone() : "—" %></div>
                        </div>
                        <div class="info-row">
                            <div class="label">Member Since</div>
                            <div class="value"><%= loggedUser.getCreatedAt() != null ? loggedUser.getCreatedAt().toLocalDate().toString() : "—" %></div>
                        </div>
                        <div class="info-row">
                            <div class="label">Recent Orders</div>
                            <div class="value"><%= recentOrders.size() %><%= recentOrders.size() == 5 ? "+" : "" %></div>
                        </div>
                    </div>
                </div>
                <div class="profile-actions">
                    <a href="<%= path %>/edit-profile" class="btn-action btn-dark"><i class="fa-solid fa-pen-to-square fa-xs"></i> Edit Profile</a>
                    <a href="<%= path %>/auth?action=changeForm" class="btn-action btn-outline-dark"><i class="fa-solid fa-lock fa-xs"></i> Change Password</a>
                    <a href="<%= path %>/order-history" class="btn-action btn-outline-dark"><i class="fa-solid fa-clock-rotate-left fa-xs"></i> All Orders</a>
                </div>
            </div>

            <div class="section-header">
                <div class="section-title">Recent Orders</div>
                <a href="<%= path %>/order-history" class="link-all">View all →</a>
            </div>

            <% if (recentOrders.isEmpty()) { %>
            <div class="empty-box">
                <i class="fa-solid fa-box-open"></i>
                <p style="margin-top:10px;">No orders yet. <a href="<%= path %>/products" style="color:#111;">Start shopping →</a></p>
            </div>
            <% } else { %>
            <table class="orders-table">
                <thead><tr><th>Order ID</th><th>Items</th><th>Date</th><th>Total</th><th>Status</th><th></th></tr></thead>
                <tbody>
                    <% for (Order o : recentOrders) { %>
                    <tr>
                        <td><strong>#<%= o.getOrderId() %></strong></td>
                        <td>
                            <div class="order-thumbs">
                                <% if (o.getItems() != null) { int shown=0; for (OrderItem item : o.getItems()) { if(shown++>=4) break; %>
                                <img class="order-thumb" src="<%= path %>/<%= item.getProduct().getDisplayImage() %>"
                                     alt="<%= item.getProduct().getProductName() %>"
                                     title="<%= item.getProduct().getProductName() %> – Size <%= item.getSize() %>">
                                <% } } %>
                                <% if (o.getItems() != null && o.getItems().size() > 4) { %>
                                <div style="width:36px;height:46px;background:#f0f0f0;display:flex;align-items:center;justify-content:center;font-size:11px;color:#888;">+<%= o.getItems().size()-4 %></div>
                                <% } %>
                            </div>
                        </td>
                        <td><%= o.getFormattedDate() %></td>
                        <td><strong><%= o.getFormattedTotal() %></strong></td>
                        <td><span class="status-badge <%= o.getStatusClass() %>"><%= o.getStatus() %></span></td>
                        <td><a href="<%= path %>/order-history" class="btn-view">View</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
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
                document.getElementById("overlay").classList.add("active")
            }
            function closeMenu() {
                document.getElementById("sideMenu").style.left = "-280px";
                document.getElementById("overlay").classList.remove("active")
            }
            var t = document.getElementById("toast");
            if (t) {
                t.classList.add("show");
                setTimeout(function () {
                    t.classList.remove("show")
                }, 3000)
            }
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
