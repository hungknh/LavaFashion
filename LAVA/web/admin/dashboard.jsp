<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.User, model.Order, java.util.List" %>
<%
    String path = request.getContextPath();
    User   me   = (User) session.getAttribute("loggedUser");
    if (me == null || !me.isAdmin()) { response.sendRedirect(path + "/home"); return; }

    int totalProducts = (Integer) request.getAttribute("totalProducts");
    int totalUsers    = (Integer) request.getAttribute("totalUsers");
    int totalOrders   = (Integer) request.getAttribute("totalOrders");
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
    if (recentOrders == null) recentOrders = new java.util.ArrayList<>();

    String ok  = (String) session.getAttribute("adminSuccess");
    String err = (String) session.getAttribute("adminError");
    session.removeAttribute("adminSuccess"); session.removeAttribute("adminError");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><title>Dashboard – LAVA Admin</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/admin.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
    </head>
    <body>
        <%@ include file="sidebar.jspf" %>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="page-title">Dashboard</div>
                <div class="topbar-right">
                    <a href="<%= path %>/home"><i class="fa-solid fa-store fa-xs"></i> View Store</a>
                </div>
            </div>
            <div class="admin-content">
                <% if (ok  != null) { %><div class="alert alert-success" id="adminToast"><i class="fa-solid fa-circle-check"></i> <%= ok %></div><% } %>
                <% if (err != null) { %><div class="alert alert-error"  id="adminToast"><i class="fa-solid fa-circle-exclamation"></i> <%= err %></div><% } %>

                <!-- STAT CARDS -->
                <div class="stat-grid">
                    <div class="stat-card">
                        <div class="stat-icon blue"><i class="fa-solid fa-shirt"></i></div>
                        <div class="stat-info">
                            <div class="stat-val"><%= totalProducts %></div>
                            <div class="stat-lbl">Total Products</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green"><i class="fa-solid fa-box"></i></div>
                        <div class="stat-info">
                            <div class="stat-val"><%= totalOrders %></div>
                            <div class="stat-lbl">Total Orders</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orange"><i class="fa-solid fa-users"></i></div>
                        <div class="stat-info">
                            <div class="stat-val"><%= totalUsers %></div>
                            <div class="stat-lbl">Registered Users</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon purple"><i class="fa-solid fa-chart-line"></i></div>
                        <div class="stat-info">
                            <div class="stat-val"><a href="<%= path %>/admin/statistics" style="color:inherit;text-decoration:none;">Stats →</a></div>
                            <div class="stat-lbl">View Statistics</div>
                        </div>
                    </div>
                </div>

                <!-- RECENT ORDERS -->
                <div class="admin-panel">
                    <div class="panel-header">
                        <span class="panel-title">Recent Orders</span>
                        <a href="<%= path %>/admin/orders" class="btn btn-outline btn-sm">View All</a>
                    </div>
                    <div class="panel-body">
                        <table class="admin-table">
                            <thead><tr><th>#</th><th>Customer</th><th>Total</th><th>Payment</th><th>Status</th><th>Date</th></tr></thead>
                            <tbody>
                                <% if (recentOrders.isEmpty()) { %>
                                <tr><td colspan="6" style="text-align:center;color:#aaa;padding:28px;">No orders yet.</td></tr>
                                <% } else { for (Order o : recentOrders) { %>
                                <tr>
                                    <td><strong>#<%= o.getOrderId() %></strong></td>
                                    <td><%= o.getReceiverName() %></td>
                                    <td><strong><%= o.getFormattedTotal() %></strong></td>
                                    <td><%= o.getPaymentMethod() %></td>
                                    <td><span class="badge badge-<%= o.getStatus().toLowerCase() %>"><%= o.getStatus() %></span></td>
                                    <td><%= o.getFormattedDate() %></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <script src="<%= path %>/assets/js/admin.js"></script>
       
    </body>
</html>
