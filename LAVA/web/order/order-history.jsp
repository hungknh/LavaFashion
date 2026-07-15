<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Order, model.OrderItem, model.User, java.util.List" %>
<%
    String path = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    if (orders == null) orders = new java.util.ArrayList<>();
    String cancelled = request.getParameter("cancelled");
%>
<!DOCTYPE html>
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>My Orders – LAVA</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
            .history-wrap {
                max-width: 960px;
                margin: 48px auto;
                padding: 0 24px;
            }
            .history-title {
                font-size: 22px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                margin-bottom: 32px;
            }

            /* ── ORDER TABLE ── */
            .orders-table {
                width: 100%;
                border-collapse: collapse;
            }
            .orders-table th {
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: #888;
                font-weight: 600;
                padding: 0 0 12px;
                border-bottom: 1px solid #eee;
                text-align: left;
            }
            .orders-table td {
                padding: 16px 0;
                border-bottom: 1px solid #f0f0f0;
                font-size: 14px;
                vertical-align: middle;
            }
            .orders-table th:last-child, .orders-table td:last-child {
                text-align: right;
            }

            .status-badge {
                display: inline-block;
                padding: 4px 12px;
                font-size: 11px;
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

            .btn-detail {
                background: none;
                border: 1px solid #ddd;
                padding: 6px 14px;
                font-size: 12px;
                cursor: pointer;
                letter-spacing: .5px;
            }
            .btn-detail:hover {
                background: #111;
                color: #fff;
                border-color: #111;
            }

            /* ── EXPAND DETAIL ── */
            .order-detail-row {
                display: none;
            }
            .order-detail-row.open {
                display: table-row;
            }
            .order-detail-inner {
                background: #fafafa;
                padding: 20px 24px;
            }
            .detail-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 8px 32px;
                margin-bottom: 16px;
            }
            .detail-info {
                font-size: 13px;
            }
            .detail-info .label {
                color: #888;
                margin-right: 6px;
            }
            .detail-items-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 8px;
                table-layout: fixed;
            }
            .detail-items-table th {
                font-size: 11px;
                text-transform: uppercase;
                color: #888;
                font-weight: 600;
                padding: 8px 8px 8px 0;
                border-bottom: 1px solid #eee;
                text-align: left;
            }
            .detail-items-table th:nth-child(1) {
                width: 45%;
            }
            .detail-items-table th:nth-child(2) {
                width: 10%;
                text-align: center;
            }
            .detail-items-table th:nth-child(3) {
                width: 10%;
                text-align: center;
            }
            .detail-items-table th:nth-child(4) {
                width: 17%;
                text-align: right;
            }
            .detail-items-table th:nth-child(5) {
                width: 18%;
                text-align: right;
            }
            .detail-items-table td {
                padding: 10px 8px 10px 0;
                border-bottom: 1px solid #f0f0f0;
                font-size: 13px;
                vertical-align: middle;
            }
            .detail-items-table td:nth-child(2) {
                text-align: center;
            }
            .detail-items-table td:nth-child(3) {
                text-align: center;
            }
            .detail-items-table td:nth-child(4) {
                text-align: right;
            }
            .detail-items-table td:nth-child(5) {
                text-align: right;
                font-weight: 700;
            }
            .d-item-img {
                width: 40px;
                height: 50px;
                object-fit: cover;
                background: #eee;
                margin-right: 10px;
                flex-shrink: 0;
            }
            .d-item-cell {
                display: flex;
                align-items: center;
            }
            .detail-total {
                display: flex;
                justify-content: flex-end;
                font-size: 15px;
                font-weight: 700;
                padding-top: 12px;
            }

            /* Cancel button */
            .btn-cancel-order {
                background: none;
                border: 1px solid #e74c3c;
                color: #e74c3c;
                padding: 5px 12px;
                font-size: 12px;
                cursor: pointer;
                letter-spacing: .5px;
                margin-top: 12px;
            }
            .btn-cancel-order:hover {
                background: #e74c3c;
                color: #fff;
            }

            /* Cancel Modal */
            .modal-overlay {
                display:none;
                position:fixed;
                inset:0;
                background:rgba(0,0,0,.45);
                z-index:1000;
                justify-content:center;
                align-items:center;
            }
            .modal-overlay.open {
                display:flex;
            }
            .modal-box {
                background:#fff;
                width:440px;
                padding:32px;
                position:relative;
            }
            .modal-title {
                font-size:16px;
                font-weight:700;
                margin-bottom:6px;
            }
            .modal-sub {
                font-size:13px;
                color:#888;
                margin-bottom:20px;
            }
            .modal-reasons {
                display:flex;
                flex-direction:column;
                gap:8px;
                margin-bottom:16px;
            }
            .modal-reason {
                display:flex;
                align-items:center;
                gap:10px;
                padding:10px 14px;
                border:1px solid #eee;
                cursor:pointer;
                font-size:13px;
            }
            .modal-reason input {
                width:15px;
                height:15px;
                cursor:pointer;
                flex-shrink:0;
            }
            .modal-reason.selected {
                border-color:#111;
                background:#fafafa;
            }
            .modal-other {
                width:100%;
                padding:9px 12px;
                border:1px solid #ddd;
                font-size:13px;
                margin-bottom:16px;
                font-family:inherit;
                display:none;
            }
            .modal-other.visible {
                display:block;
            }
            .modal-actions {
                display:flex;
                gap:12px;
                justify-content:flex-end;
            }
            .modal-btn-confirm {
                padding:10px 24px;
                background:#e74c3c;
                color:#fff;
                border:none;
                font-size:13px;
                cursor:pointer;
            }
            .modal-btn-confirm:hover {
                background:#c0392b;
            }
            .modal-btn-cancel  {
                padding:10px 24px;
                background:none;
                border:1px solid #ddd;
                font-size:13px;
                cursor:pointer;
            }
            .modal-btn-cancel:hover {
                background:#f5f5f5;
            }

            /* Empty state */
            .empty-orders {
                text-align: center;
                padding: 80px 0;
                color: #888;
            }
            .empty-orders i {
                font-size: 48px;
                color: #ddd;
                margin-bottom: 16px;
            }
            .empty-orders p {
                font-size: 16px;
                margin-bottom: 20px;
            }
            .btn-shop {
                display: inline-block;
                padding: 12px 32px;
                background: #111;
                color: #fff;
                text-decoration: none;
                font-size: 13px;
                letter-spacing: 1px;
            }
            .btn-shop:hover {
                background: #333;
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

        <!-- Toast cancelled -->
        <% if ("1".equals(cancelled)) { %>
        <div id="toast" style="position:fixed;bottom:28px;right:28px;padding:14px 24px;background:#e74c3c;color:#fff;font-size:14px;z-index:9999;opacity:0;transition:opacity .3s;">
            Order has been cancelled and stock restored.
        </div>
        <% } %>

        <div class="history-wrap">
            <h2 class="history-title">My Orders (<%= orders.size() %>)</h2>

            <% if (orders.isEmpty()) { %>
            <div class="empty-orders">
                <i class="fa-solid fa-box-open"></i>
                <p>You haven't placed any orders yet.</p>
                <a href="<%= path %>/products" class="btn-shop">Start Shopping</a>
            </div>

            <% } else { %>
            <table class="orders-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>Date</th>
                        <th>Items</th>
                        <th>Total</th>
                        <th>Payment</th>
                        <th>Status</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <% int idx = 0; for (Order order : orders) { idx++; %>

                    <!-- Order row -->
                    <tr>
                        <td><strong>#<%= order.getOrderId() %></strong></td>
                        <td><%= order.getFormattedDate() %></td>
                        <td><%= order.getItems() != null ? order.getItems().size() : 0 %> item(s)</td>
                        <td><strong><%= order.getFormattedTotal() %></strong></td>
                        <td style="font-size:12px;color:#555;"><%= order.getPaymentMethod() %></td>
                        <td><span class="status-badge <%= order.getStatusClass() %>"><%= order.getStatus() %></span></td>
                        <td>
                            <button class="btn-detail" onclick="toggleDetail(<%= idx %>)">
                                View Details <i class="fa-solid fa-chevron-down fa-xs"></i>
                            </button>
                        </td>
                    </tr>

                    <!-- Expandable detail row -->
                    <tr id="detail-<%= idx %>" class="order-detail-row">
                        <td colspan="7" style="padding: 0;">
                            <div class="order-detail-inner">

                                <!-- Shipping info -->
                                <div class="detail-grid">
                                    <div class="detail-info">
                                        <span class="label">Receiver:</span>
                                        <%= order.getReceiverName() %> · <%= order.getReceiverPhone() %>
                                    </div>
                                    <div class="detail-info">
                                        <span class="label">Payment:</span><%= order.getPaymentMethod() %>
                                    </div>
                                    <div class="detail-info" style="grid-column:1/-1;">
                                        <span class="label">Address:</span><%= order.getShippingAddress() %>
                                    </div>
                                    <% if (order.getNote() != null && !order.getNote().isEmpty()) { %>
                                    <div class="detail-info" style="grid-column:1/-1;">
                                        <span class="label">Note:</span><%= order.getNote() %>
                                    </div>
                                    <% } %>
                                    <% if ("Cancelled".equals(order.getStatus()) && order.getCancelReason() != null && !order.getCancelReason().isEmpty()) { %>
                                    <div class="detail-info" style="grid-column:1/-1; color:#e74c3c;">
                                        <span class="label" style="color:#e74c3c;">Cancel Reason:</span><%= order.getCancelReason() %>
                                    </div>
                                    <% } %>
                                </div>

                                <!-- Items -->
                                <% if (order.getItems() != null && !order.getItems().isEmpty()) { %>
                                <table class="detail-items-table">
                                    <thead>
                                        <tr>
                                            <th>Product</th>
                                            <th>Size</th>
                                            <th>Qty</th>
                                            <th>Unit Price</th>
                                            <th>Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (OrderItem item : order.getItems()) { %>
                                        <tr>
                                            <td>
                                                <div class="d-item-cell">
                                                    <img class="d-item-img"
                                                         src="<%= path %>/<%= item.getProduct().getDisplayImage() %>"
                                                         alt="<%= item.getProduct().getProductName() %>">
                                                    <div>
                                                        <div style="font-weight:600"><%= item.getProduct().getProductName() %></div>
                                                        <div style="font-size:11px;color:#888"><%= item.getProduct().getColor() %></div>
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
                                <div class="detail-total">
                                    Total: &nbsp;<span><%= order.getFormattedTotal() %></span>
                                </div>
                                <% } %>

                                <!-- Cancel button — chỉ hiện khi Pending + Unpaid -->
                                <% if (order.isCancellable()) { %>
                                <div style="text-align:right; margin-top:12px;">
                                    <button class="btn-cancel-order"
                                            onclick="openCancelModal(<%= order.getOrderId() %>)">
                                        <i class="fa-solid fa-xmark"></i> Cancel Order
                                    </button>
                                </div>
                                <% } %>
                            </div>
                        </td>
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

        <!-- ==================== CANCEL MODAL ==================== -->
        <div id="cancelModal" class="modal-overlay">
            <div class="modal-box">
                <div class="modal-title">Cancel Order</div>
                <div class="modal-sub">Please select a reason for cancellation:</div>

                <form id="cancelForm" method="POST" action="<%= path %>/order-history">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="orderId" id="cancelOrderId" value="">
                    <input type="hidden" name="cancelReason" id="cancelReasonInput" value="">

                    <div class="modal-reasons">
                        <% String[] reasons = {
                            "I want to update the shipping address",
                            "I changed my mind / no longer need this",
                            "I found a better price elsewhere",
                            "Ordered by mistake",
                            "Other reason"
                        };
                        for (int i = 0; i < reasons.length; i++) { %>
                        <label class="modal-reason" id="reason-<%= i %>">
                            <input type="radio" name="reasonChoice" value="<%= reasons[i] %>"
                                   onchange="selectReason('<%= reasons[i] %>', <%= i %>, <%= i == reasons.length-1 %>)">
                            <%= reasons[i] %>
                        </label>
                        <% } %>
                    </div>

                    <textarea id="otherReasonText" class="modal-other"
                              placeholder="Please describe your reason..."
                              oninput="syncOther(this.value)"></textarea>

                    <div class="modal-actions">
                        <button type="button" class="modal-btn-cancel" onclick="closeCancelModal()">Keep Order</button>
                        <button type="button" class="modal-btn-confirm" id="btnConfirmCancel"
                                disabled onclick="submitCancel()">Confirm Cancel</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openMenu() {
                document.getElementById("sideMenu").style.left = "0";
                document.getElementById("overlay").classList.add("active");
            }
            function closeMenu() {
                document.getElementById("sideMenu").style.left = "-280px";
                document.getElementById("overlay").classList.remove("active");
            }

            function toggleDetail(idx) {
                var row = document.getElementById("detail-" + idx);
                if (row.classList.contains("open")) {
                    row.classList.remove("open");
                } else {
                    document.querySelectorAll(".order-detail-row.open").forEach(function (r) {
                        r.classList.remove("open");
                    });
                    row.classList.add("open");
                }
            }

            // ── Cancel modal ──────────────────────────────────────────────────────
            function openCancelModal(orderId) {
                document.getElementById("cancelOrderId").value = orderId;
                document.getElementById("cancelReasonInput").value = "";
                document.getElementById("otherReasonText").value = "";
                document.getElementById("otherReasonText").classList.remove("visible");
                document.getElementById("btnConfirmCancel").disabled = true;
                document.querySelectorAll(".modal-reason").forEach(function (el) {
                    el.classList.remove("selected");
                });
                document.querySelectorAll(".modal-reason input").forEach(function (el) {
                    el.checked = false;
                });
                document.getElementById("cancelModal").classList.add("open");
            }

            function closeCancelModal() {
                document.getElementById("cancelModal").classList.remove("open");
            }

            var isOther = false;

            function submitCancel() {
                var reasonInput = document.getElementById("cancelReasonInput");
                var otherText = document.getElementById("otherReasonText");

                // Nếu chọn "Other", lấy từ textarea
                if (isOther) {
                    var val = otherText.value.trim();
                    if (!val) {
                        alert("Please describe your reason.");
                        return;
                    }
                    reasonInput.value = val;
                }

                if (!reasonInput.value || reasonInput.value.trim() === "") {
                    alert("Please select a reason.");
                    return;
                }

                document.getElementById("cancelForm").submit();
            }

            function selectReason(value, idx, other) {
                isOther = other;
                document.querySelectorAll(".modal-reason").forEach(function (el) {
                    el.classList.remove("selected");
                });
                document.getElementById("reason-" + idx).classList.add("selected");
                var otherBox = document.getElementById("otherReasonText");
                if (other) {
                    otherBox.classList.add("visible");
                    document.getElementById("cancelReasonInput").value = "";
                    document.getElementById("btnConfirmCancel").disabled = true;
                } else {
                    otherBox.classList.remove("visible");
                    document.getElementById("cancelReasonInput").value = value;
                    document.getElementById("btnConfirmCancel").disabled = false;
                }
            }

            function syncOther(val) {
                document.getElementById("cancelReasonInput").value = val.trim();
                document.getElementById("btnConfirmCancel").disabled = val.trim() === "";
            }

            // Close modal when clicking outside
            document.getElementById("cancelModal").addEventListener("click", function (e) {
                if (e.target === this)
                    closeCancelModal();
            });

            // Toast cancelled
            var toast = document.getElementById("toast");
            if (toast) {
                toast.style.opacity = "1";
                setTimeout(function () {
                    toast.style.opacity = "0";
                }, 3500);
            }
        </script>
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>
    </body>
</html>
