<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.User, model.Order, java.util.List" %>
<%
    String path = request.getContextPath();
    User   me   = (User) session.getAttribute("loggedUser");
    if (me == null || !me.isAdmin()) { response.sendRedirect(path + "/home"); return; }

    List<Order> orders = (List<Order>) request.getAttribute("orders");
    int currentPage    = (Integer)    request.getAttribute("currentPage");
    int totalPages     = (Integer)    request.getAttribute("totalPages");
    if (orders == null) orders = new java.util.ArrayList<>();

    String ok  = (String) session.getAttribute("adminSuccess");
    String err = (String) session.getAttribute("adminError");
    session.removeAttribute("adminSuccess"); session.removeAttribute("adminError");

    String[] statuses = {"Pending","Processing","Shipped","Delivered","Cancelled"};
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8"><title>Orders – LAVA Admin</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/admin.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <style>
            .status-select {
                padding:5px 10px;
                border:1px solid #ddd;
                font-size:12px;
                font-family:inherit;
                cursor:pointer;
                outline:none;
            }
            .status-select:focus {
                border-color:#111;
            }
        </style>
    </head>
    <body>
        <%@ include file="sidebar.jspf" %>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="page-title">Order Management</div>
                <div class="topbar-right">
                    <span style="font-size:12px;color:#888;"><%= orders.size() %> orders on this page</span>
                </div>
            </div>
            <div class="admin-content">
                <% if (ok  != null) { %><div class="alert alert-success" id="adminToast"><i class="fa-solid fa-circle-check"></i> <%= ok %></div><% } %>
                <% if (err != null) { %><div class="alert alert-error"   id="adminToast"><i class="fa-solid fa-circle-exclamation"></i> <%= err %></div><% } %>

                <div class="admin-panel">
                    <div class="panel-header">
                        <span class="panel-title">All Orders</span>
                    </div>
                    <div class="panel-body">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>#</th><th>Customer</th><th>Address</th>
                                    <th>Total</th><th>Payment</th><th>Pay Status</th>
                                    <th>Date</th><th>Status</th><th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (orders.isEmpty()) { %>
                                <tr><td colspan="9" style="text-align:center;color:#aaa;padding:40px;">No orders yet.</td></tr>
                                <% } else { for (Order o : orders) { %>
                                <tr>
                                    <td><strong>#<%= o.getOrderId() %></strong></td>
                                    <td>
                                        <strong><%= o.getReceiverName() %></strong>
                                        <% if (o.getReceiverPhone() != null) { %>
                                        <br><small style="color:#aaa;"><%= o.getReceiverPhone() %></small>
                                        <% } %>
                                    </td>
                                    <td style="font-size:12px;max-width:160px;"><%= o.getShippingAddress() %></td>
                                    <td><strong><%= o.getFormattedTotal() %></strong></td>
                                    <td><%= o.getPaymentMethod() %></td>
                                    <td>
                                        <form method="POST" action="<%= path %>/admin/order-update" style="display:inline;">
                                            <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                            <% if ("Paid".equalsIgnoreCase(o.getPaymentStatus())) { %>
                                            <input type="hidden" name="action" value="markUnpaid">
                                            <button type="submit" class="badge badge-active"
                                                    style="border:none;cursor:pointer;font-family:inherit;"
                                                    title="Click to mark Unpaid">
                                                ✓ Paid
                                            </button>
                                            <% } else { %>
                                            <input type="hidden" name="action" value="markPaid">
                                            <button type="submit" class="badge badge-inactive"
                                                    style="border:none;cursor:pointer;font-family:inherit;"
                                                    title="Click to mark Paid">
                                                Unpaid →
                                            </button>
                                            <% } %>
                                        </form>
                                    </td>
                                    <td style="font-size:12px;color:#888;"><%= o.getFormattedDate() %></td>
                                    <td>
                                        <span class="badge badge-<%= o.getStatus().toLowerCase() %>"><%= o.getStatus() %></span>
                                    </td>
                                    <td style="white-space:nowrap;">
                                        <!-- Update Status -->
                                        <% if (!"Cancelled".equalsIgnoreCase(o.getStatus()) && !"Delivered".equalsIgnoreCase(o.getStatus())) { %>
                                        <form method="POST" action="<%= path %>/admin/order-update" style="display:inline;margin-right:4px;">
                                            <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                            <input type="hidden" name="action"  value="updateStatus">
                                            <select name="status" class="status-select"
                                                    onchange="onStatusChange(this)"
                                                    style="background:<%= getStatusColor(o.getStatus()) %>">
                                                <% for (String s : statuses) { %>
                                                <option value="<%= s %>" <%= s.equals(o.getStatus()) ? "selected" : "" %>><%= s %></option>
                                                <% } %>
                                            </select>
                                            <button type="submit" class="btn btn-primary btn-sm" style="margin-left:4px;"
                                                    title="Update status">
                                                <i class="fa-solid fa-check"></i>
                                            </button>
                                        </form>
                                        <% } else { %>
                                        <span style="font-size:12px;color:#aaa;"><%= o.getStatus() %></span>
                                        <% } %>

                                        <!-- Delete (only Pending + Unpaid) -->
                                        <% if ("Pending".equalsIgnoreCase(o.getStatus()) && "Unpaid".equalsIgnoreCase(o.getPaymentStatus())) { %>
                                        <form method="POST" action="<%= path %>/admin/order-update" style="display:inline;">
                                            <input type="hidden" name="orderId" value="<%= o.getOrderId() %>">
                                            <input type="hidden" name="action"  value="delete">
                                            <button type="button" class="btn btn-danger btn-sm"
                                                    onclick="confirmDelete(this.form, 'Delete order #<%= o.getOrderId() %>? This cannot be undone.')"
                                                    title="Delete order">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>

                        <!-- PAGINATION -->
                        <% if (totalPages > 1) { %>
                        <div class="pagination">
                            <% if (currentPage > 1) { %>
                            <a href="?page=<%= currentPage-1 %>"><i class="fa-solid fa-chevron-left"></i></a>
                            <% } else { %><span class="disabled"><i class="fa-solid fa-chevron-left"></i></span><% } %>
                                <% for (int i = 1; i <= totalPages; i++) { %>
                            <a href="?page=<%= i %>" class="<%= i==currentPage ? "current" : "" %>"><%= i %></a>
                            <% } %>
                            <% if (currentPage < totalPages) { %>
                            <a href="?page=<%= currentPage+1 %>"><i class="fa-solid fa-chevron-right"></i></a>
                            <% } else { %><span class="disabled"><i class="fa-solid fa-chevron-right"></i></span><% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
        <script src="<%= path %>/assets/js/admin.js"></script>
        <script>
        // Init colors on page load
                                                    document.querySelectorAll(".status-select").forEach(function (s) {
                                                        onStatusChange(s);
                                                    });
        </script>
       
    </body>
</html>
<%!
    private String getStatusColor(String status) {
        if (status == null) return "#fff";
        switch (status) {
            case "Pending":    return "#fff3cd";
            case "Processing": return "#cce5ff";
            case "Shipped":    return "#d4edda";
            case "Delivered":  return "#d1e7dd";
            case "Cancelled":  return "#f8d7da";
            default:           return "#fff";
        }
    }
%>
