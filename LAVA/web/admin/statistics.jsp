<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.User,java.util.Map,java.util.List,java.text.NumberFormat,java.util.Locale" %>
<%
    String path = request.getContextPath();
    User   me   = (User) session.getAttribute("loggedUser");
    if (me == null || !me.isAdmin()) { response.sendRedirect(path + "/home"); return; }

    int selectedYear  = (Integer) request.getAttribute("selectedYear");
    int selectedMonth = (Integer) request.getAttribute("selectedMonth");
    int currentYear   = (Integer) request.getAttribute("currentYear");

    Map<Integer,Double>  revenueByMonth    = (Map<Integer,Double>)  request.getAttribute("revenueByMonth");
    Map<Integer,Double>  revenueByDay      = (Map<Integer,Double>)  request.getAttribute("revenueByDay");
    List<Object[]>       topSelling        = (List<Object[]>)       request.getAttribute("topSelling");
    List<Object[]>       topRated          = (List<Object[]>)       request.getAttribute("topRated");
    List<Object[]>       productByCategory = (List<Object[]>)       request.getAttribute("productByCategory");
    Map<Integer,Integer> newCustomers      = (Map<Integer,Integer>) request.getAttribute("newCustomers");
    Map<String,Integer>  orderByStatus     = (Map<String,Integer>)  request.getAttribute("orderByStatus");
    double totalRevYear  = (Double) request.getAttribute("totalRevYear");
    double totalRevMonth = (Double) request.getAttribute("totalRevMonth");

    NumberFormat nf = NumberFormat.getInstance(Locale.US);
    String[] monthNames = {"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

    // Build JSON arrays for Chart.js
    StringBuilder monthLabels = new StringBuilder("[");
    StringBuilder monthData   = new StringBuilder("[");
    for (int m = 1; m <= 12; m++) {
        monthLabels.append("'").append(monthNames[m]).append("'").append(m<12?",":"");
        monthData.append(String.format("%.2f", revenueByMonth.getOrDefault(m,0.0))).append(m<12?",":"");
    }
    monthLabels.append("]"); monthData.append("]");

    StringBuilder dayLabels = new StringBuilder("[");
    StringBuilder dayData   = new StringBuilder("[");
    int dayCount = 0;
    for (Map.Entry<Integer,Double> e : revenueByDay.entrySet()) {
        if (e.getValue() > 0 || true) { // show all days
            dayLabels.append(dayCount>0?",":"").append(e.getKey());
            dayData.append(dayCount>0?",":"").append(String.format("%.2f", e.getValue()));
            dayCount++;
        }
    }
    dayLabels.append("]"); dayData.append("]");

    StringBuilder custLabels = new StringBuilder("[");
    StringBuilder custData   = new StringBuilder("[");
    for (int m = 1; m <= 12; m++) {
        custLabels.append("'").append(monthNames[m]).append("'").append(m<12?",":"");
        custData.append(newCustomers.getOrDefault(m,0)).append(m<12?",":"");
    }
    custLabels.append("]"); custData.append("]");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Statistics – LAVA Admin</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/admin.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
        <style>
            .stats-grid {
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:24px;
                margin-bottom:24px;
            }
            .stats-grid-4 {
                display:grid;
                grid-template-columns:repeat(4,1fr);
                gap:20px;
                margin-bottom:28px;
            }
            .chart-wrap {
                background:#fff;
                border:1px solid #eee;
                padding:24px;
            }
            .chart-title {
                font-size:13px;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:.5px;
                margin-bottom:18px;
                color:#111;
            }
            .chart-canvas {
                position:relative;
                height:220px;
            }
            .filter-bar {
                background:#fff;
                border:1px solid #eee;
                padding:16px 20px;
                margin-bottom:24px;
                display:flex;
                align-items:center;
                gap:16px;
                flex-wrap:wrap;
            }
            .filter-bar label {
                font-size:12px;
                font-weight:600;
                text-transform:uppercase;
                color:#555;
            }
            .filter-bar select {
                padding:8px 12px;
                border:1px solid #ddd;
                font-size:13px;
                font-family:inherit;
                outline:none;
            }
            .filter-bar select:focus {
                border-color:#111;
            }
            .rev-highlight {
                font-size:22px;
                font-weight:700;
                color:#111;
            }
            .rev-sub {
                font-size:12px;
                color:#888;
                margin-top:2px;
            }
            .stars {
                color:#f39c12;
                font-size:13px;
            }
            .rank-num {
                width:28px;
                height:28px;
                border-radius:50%;
                background:#111;
                color:#fff;
                font-size:12px;
                font-weight:700;
                display:inline-flex;
                align-items:center;
                justify-content:center;
            }
            .rank-num.gold   {
                background:#f1c40f;
                color:#111;
            }
            .rank-num.silver {
                background:#bdc3c7;
                color:#fff;
            }
            .rank-num.bronze {
                background:#cd7f32;
                color:#fff;
            }
            .cat-bar-wrap {
                background:#f0f0f0;
                border-radius:2px;
                height:8px;
                margin-top:6px;
            }
            .cat-bar {
                background:#111;
                height:8px;
                border-radius:2px;
                transition:width .4s;
            }
            .section-gap {
                margin-bottom:24px;
            }
        </style>
    </head>
    <body>
        <%@ include file="sidebar.jspf" %>
        <div class="admin-main">
            <div class="admin-topbar">
                <div class="page-title">Statistics</div>
                <div class="topbar-right" style="font-size:12px;color:#888;">Year: <%= selectedYear %> &nbsp;|&nbsp; Month: <%= monthNames[selectedMonth] %></div>
            </div>
            <div class="admin-content">

                <!-- ── FILTER ── -->
                <form method="GET" action="<%= path %>/admin/statistics" class="filter-bar">
                    <label>Year</label>
                    <select name="year">
                        <% for (int y = currentYear; y >= currentYear-4; y--) { %>
                        <option value="<%= y %>" <%= y==selectedYear?"selected":"" %>><%= y %></option>
                        <% } %>
                    </select>
                    <label>Month</label>
                    <select name="month">
                        <% for (int m = 1; m <= 12; m++) { %>
                        <option value="<%= m %>" <%= m==selectedMonth?"selected":"" %>><%= monthNames[m] %></option>
                        <% } %>
                    </select>
                    <button type="submit" class="btn btn-primary btn-sm"><i class="fa-solid fa-filter"></i> Apply</button>
                </form>

                <!-- ── REVENUE SUMMARY CARDS ── -->
                <div class="stats-grid-4 section-gap">
                    <div class="stat-card">
                        <div class="stat-icon green"><i class="fa-solid fa-dollar-sign"></i></div>
                        <div class="stat-info">
                            <div class="stat-val" style="font-size:18px;">$<%= String.format("%,.2f", totalRevYear) %></div>
                            <div class="stat-lbl">Revenue <%= selectedYear %></div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon blue"><i class="fa-solid fa-calendar-day"></i></div>
                        <div class="stat-info">
                            <div class="stat-val" style="font-size:18px;">$<%= String.format("%,.2f", totalRevMonth) %></div>
                            <div class="stat-lbl"><%= monthNames[selectedMonth] %> <%= selectedYear %></div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orange"><i class="fa-solid fa-users"></i></div>
                        <div class="stat-info">
                            <div class="stat-val" style="font-size:18px;">
                                <%= newCustomers.values().stream().mapToInt(Integer::intValue).sum() %>
                            </div>
                            <div class="stat-lbl">New Users <%= selectedYear %></div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon purple"><i class="fa-solid fa-box"></i></div>
                        <div class="stat-info">
                            <div class="stat-val" style="font-size:18px;">
                                <%= orderByStatus.values().stream().mapToInt(Integer::intValue).sum() %>
                            </div>
                            <div class="stat-lbl">Total Orders</div>
                        </div>
                    </div>
                </div>

                <!-- ── CHARTS ROW 1 ── -->
                <div class="stats-grid section-gap">
                    <!-- Monthly Revenue Chart -->
                    <div class="chart-wrap">
                        <div class="chart-title"><i class="fa-solid fa-chart-bar fa-xs"></i> Monthly Revenue <%= selectedYear %></div>
                        <div class="chart-canvas"><canvas id="chartMonthlyRev"></canvas></div>
                    </div>
                    <!-- Daily Revenue Chart -->
                    <div class="chart-wrap">
                        <div class="chart-title"><i class="fa-solid fa-chart-line fa-xs"></i> Daily Revenue — <%= monthNames[selectedMonth] %> <%= selectedYear %></div>
                        <div class="chart-canvas"><canvas id="chartDailyRev"></canvas></div>
                    </div>
                </div>

                <!-- ── CHARTS ROW 2 ── -->
                <div class="stats-grid section-gap">
                    <!-- New Customers Chart -->
                    <div class="chart-wrap">
                        <div class="chart-title"><i class="fa-solid fa-user-plus fa-xs"></i> New Customers per Month <%= selectedYear %></div>
                        <div class="chart-canvas"><canvas id="chartCustomers"></canvas></div>
                    </div>
                    <!-- Order Status Doughnut -->
                    <div class="chart-wrap">
                        <div class="chart-title"><i class="fa-solid fa-chart-pie fa-xs"></i> Orders by Status</div>
                        <div class="chart-canvas"><canvas id="chartOrderStatus"></canvas></div>
                    </div>
                </div>

                <!-- ── TABLES ROW ── -->
                <div class="stats-grid section-gap">

                    <!-- Top Selling -->
                    <div class="admin-panel">
                        <div class="panel-header">
                            <span class="panel-title"><i class="fa-solid fa-fire fa-xs"></i> Top 5 Best Selling</span>
                            <span style="font-size:11px;color:#aaa;">by units sold (Delivered orders)</span>
                        </div>
                        <div class="panel-body">
                            <table class="admin-table">
                                <thead><tr><th>#</th><th>Product</th><th>Category</th><th>Units</th><th>Revenue</th></tr></thead>
                                <tbody>
                                    <% if (topSelling == null || topSelling.isEmpty()) { %>
                                    <tr><td colspan="5" style="text-align:center;color:#aaa;padding:24px;">No data yet.</td></tr>
                                    <% } else { int rank=0; for (Object[] row : topSelling) { rank++; %>
                                    <tr>
                                        <td>
                                            <span class="rank-num <%= rank==1?"gold":rank==2?"silver":rank==3?"bronze":"" %>"><%= rank %></span>
                                        </td>
                                        <td>
                                            <% if (row[5] != null) { %>
                                            <img src="<%= path %>/<%= row[5] %>" style="width:32px;height:40px;object-fit:cover;vertical-align:middle;margin-right:8px;">
                                            <% } %>
                                            <strong><%= row[1] %></strong>
                                        </td>
                                        <td><%= row[2] %></td>
                                        <td><strong><%= row[3] %></strong> units</td>
                                        <td>$<%= String.format("%,.2f", (Double)row[4]) %></td>
                                    </tr>
                                    <% } } %>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Top Rated -->
                    <div class="admin-panel">
                        <div class="panel-header">
                            <span class="panel-title"><i class="fa-solid fa-star fa-xs"></i> Top 5 Highest Rated</span>
                            <span style="font-size:11px;color:#aaa;">by average review score</span>
                        </div>
                        <div class="panel-body">
                            <table class="admin-table">
                                <thead><tr><th>#</th><th>Product</th><th>Category</th><th>Rating</th><th>Reviews</th></tr></thead>
                                <tbody>
                                    <% if (topRated == null || topRated.isEmpty()) { %>
                                    <tr><td colspan="5" style="text-align:center;color:#aaa;padding:24px;">No reviews yet.</td></tr>
                                    <% } else { int rank=0; for (Object[] row : topRated) { rank++;
                                           double avg = (Double) row[3];
                                           int fullStars = (int) avg;
                                           boolean halfStar = (avg - fullStars) >= 0.5; %>
                                    <tr>
                                        <td>
                                            <span class="rank-num <%= rank==1?"gold":rank==2?"silver":rank==3?"bronze":"" %>"><%= rank %></span>
                                        </td>
                                        <td>
                                            <% if (row[5] != null) { %>
                                            <img src="<%= path %>/<%= row[5] %>" style="width:32px;height:40px;object-fit:cover;vertical-align:middle;margin-right:8px;">
                                            <% } %>
                                            <strong><%= row[1] %></strong>
                                        </td>
                                        <td><%= row[2] %></td>
                                        <td>
                                            <span class="stars">
                                                <% for(int s=1;s<=5;s++) { %>
                                                <% if(s<=fullStars) { %>★<% } else if(s==fullStars+1 && halfStar) { %>½<% } else { %><span style="color:#ddd;">★</span><% } %>
                                                <% } %>
                                            </span>
                                            <strong style="margin-left:4px;"><%= String.format("%.1f", avg) %></strong>
                                        </td>
                                        <td><%= row[4] %> reviews</td>
                                    </tr>
                                    <% } } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ── BOTTOM ROW ── -->
                <div class="stats-grid section-gap">

                    <!-- Products by Category -->
                    <div class="admin-panel">
                        <div class="panel-header">
                            <span class="panel-title"><i class="fa-solid fa-tags fa-xs"></i> Products by Category</span>
                        </div>
                        <div class="panel-body" style="padding:20px;">
                            <% if (productByCategory == null || productByCategory.isEmpty()) { %>
                            <p style="color:#aaa;text-align:center;">No data.</p>
                            <% } else {
                                int maxCat = 1;
                                for (Object[] r : productByCategory) if((Integer)r[2] > maxCat) maxCat = (Integer)r[2];
                                for (Object[] row : productByCategory) {
                                    int total  = (Integer) row[2];
                                    int active = (Integer) row[1];
                                    int pct    = maxCat > 0 ? (int)((double)total/maxCat*100) : 0; %>
                            <div style="margin-bottom:14px;">
                                <div style="display:flex;justify-content:space-between;font-size:13px;">
                                    <span><strong><%= row[0] %></strong></span>
                                    <span style="color:#888;"><%= active %> active / <%= total %> total</span>
                                </div>
                                <div class="cat-bar-wrap"><div class="cat-bar" style="width:<%= pct %>%;"></div></div>
                            </div>
                            <% } } %>
                        </div>
                    </div>

                    <!-- New Customers Table -->
                    <div class="admin-panel">
                        <div class="panel-header">
                            <span class="panel-title"><i class="fa-solid fa-user-plus fa-xs"></i> New Customers <%= selectedYear %></span>
                        </div>
                        <div class="panel-body">
                            <table class="admin-table">
                                <thead><tr><th>Month</th><th>New Users</th><th>Trend</th></tr></thead>
                                <tbody>
                                    <% int prevCust = 0;
                                       for (int m = 1; m <= 12; m++) {
                                           int cnt = newCustomers.getOrDefault(m, 0);
                                           String trend = cnt > prevCust ? "▲" : cnt < prevCust && prevCust>0 ? "▼" : "–";
                                           String trendColor = cnt > prevCust ? "#27ae60" : cnt < prevCust && prevCust>0 ? "#e74c3c" : "#aaa"; %>
                                    <tr>
                                        <td><%= monthNames[m] %></td>
                                        <td><strong><%= cnt %></strong></td>
                                        <td style="color:<%= trendColor %>;font-weight:700;"><%= trend %></td>
                                    </tr>
                                    <% prevCust = cnt; } %>
                                    <tr style="background:#fafafa;font-weight:700;">
                                        <td>TOTAL</td>
                                        <td><%= newCustomers.values().stream().mapToInt(Integer::intValue).sum() %></td>
                                        <td></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div><!-- /admin-content -->
        </div><!-- /admin-main -->

        <script src="<%= path %>/assets/js/admin.js"></script>
        <script>
            const CHART_DEFAULTS = {
                responsive: true, maintainAspectRatio: false,
                plugins: {legend: {display: false}},
                scales: {
                    x: {grid: {display: false}, ticks: {font: {size: 11}}},
                    y: {grid: {color: '#f0f0f0'}, ticks: {font: {size: 11}}}
                }
            };

            // 1. Monthly Revenue Bar
            new Chart(document.getElementById('chartMonthlyRev'), {
                type: 'bar',
                data: {
                    labels: <%= monthLabels %>,
                    datasets: [{
                            label: 'Revenue ($)',
                            data: <%= monthData %>,
                            backgroundColor: 'rgba(17,17,17,0.85)',
                            borderRadius: 3
                        }]
                },
                options: {...CHART_DEFAULTS,
                    plugins: {legend: {display: false},
                        tooltip: {callbacks: {label: ctx => '$' + ctx.parsed.y.toFixed(2)}}
                    }
                }
            });

            // 2. Daily Revenue Line
            new Chart(document.getElementById('chartDailyRev'), {
                type: 'line',
                data: {
                    labels: [<%= dayLabels.toString().replaceAll("[\\[\\]]","") %>],
                    datasets: [{
                            label: 'Revenue ($)',
                            data: [<%= dayData.toString().replaceAll("[\\[\\]]","") %>],
                            borderColor: '#111', backgroundColor: 'rgba(17,17,17,0.08)',
                            borderWidth: 2, pointRadius: 3, fill: true, tension: 0.3
                        }]
                },
                options: {...CHART_DEFAULTS,
                    plugins: {legend: {display: false},
                        tooltip: {callbacks: {label: ctx => '$' + ctx.parsed.y.toFixed(2)}}
                    }
                }
            });

            // 3. New Customers Bar
            new Chart(document.getElementById('chartCustomers'), {
                type: 'bar',
                data: {
                    labels: <%= custLabels %>,
                    datasets: [{
                            data: [<%= custData.toString().replaceAll("[\\[\\]]","") %>],
                            backgroundColor: 'rgba(39,174,96,0.8)', borderRadius: 3
                        }]
                },
                options: {...CHART_DEFAULTS}
            });

            // 4. Order Status Doughnut
            <%
            StringBuilder statusLabels = new StringBuilder("[");
            StringBuilder statusData   = new StringBuilder("[");
            String[]      statusColors  = {"#fff3cd","#cce5ff","#d4edda","#d1e7dd","#f8d7da"};
            String[] allStatuses = {"Pending","Processing","Shipped","Delivered","Cancelled"};
            for (int si=0; si<allStatuses.length; si++) {
                String s = allStatuses[si];
                int cnt  = orderByStatus.getOrDefault(s, 0);
                statusLabels.append("'").append(s).append("'").append(si<allStatuses.length-1?",":"");
                statusData.append(cnt).append(si<allStatuses.length-1?",":"");
            }
            statusLabels.append("]"); statusData.append("]");
            %>
            new Chart(document.getElementById('chartOrderStatus'), {
                type: 'doughnut',
                data: {
                    labels: <%= statusLabels %>,
                    datasets: [{
                            data: <%= statusData %>,
                            backgroundColor: ['#f39c12', '#3498db', '#2ecc71', '#27ae60', '#e74c3c'],
                            borderWidth: 2, borderColor: '#fff'
                        }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: {
                        legend: {position: 'bottom', labels: {font: {size: 11}, padding: 12}}
                    }
                }
            });
        </script>
        
    </body>
</html>
