<%-- 
    Document   : forgot-password
    Created on : Mar 10, 2026, 8:34:11 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Forgot Password – LAVA</title>

        <style>
            *{
                margin:0;
                padding:0;
                box-sizing:border-box;
                font-family: Arial, Helvetica, sans-serif;
            }
            body{
                background:#f5f5f5;
            }

            /* HEADER */
            .header{
                padding:25px 60px;
                border-bottom:1px solid #ccc;
                background:white;
            }
            .logo{
                font-size:48px;
                font-weight:900;
                text-decoration:none;
                color:black;
            }

            /* FORM */
            .forgot-container{
                width:500px;
                margin:120px auto;
            }
            .forgot-container h2{
                font-size:22px;
                letter-spacing:2px;
                margin-bottom:20px;
            }
            .forgot-container > p{
                margin-bottom:25px;
                line-height:1.6;
                color:#555;
                font-size:14px;
            }

            /* Alert */
            .alert-error{
                background:#fff0f0;
                border:1px solid #f5c6c6;
                color:#c0392b;
                padding:12px 16px;
                margin-bottom:20px;
                font-size:14px;
            }
            .alert-success{
                background:#f0fff4;
                border:1px solid #b2dfdb;
                color:#1a7a4a;
                padding:14px 16px;
                margin-bottom:20px;
                font-size:14px;
                line-height:1.6;
            }

            /* INPUT */
            form input[type="email"]{
                width:100%;
                padding:18px;
                margin-bottom:20px;
                border:1px solid #999;
                font-size:14px;
                background:white;
                outline:none;
            }
            form input[type="email"]:focus{
                border-color:black;
            }

            /* BUTTON */
            button{
                width:100%;
                padding:18px;
                background:black;
                color:white;
                border:none;
                font-size:16px;
                letter-spacing:1px;
                cursor:pointer;
            }
            button:hover{
                opacity:0.9;
            }

            /* BACK LINK */
            .back-link{
                display:block;
                text-align:center;
                margin-top:20px;
                font-size:14px;
                color:black;
                text-decoration:underline;
            }

            /* FOOTER */
            .footer{
                background:black;
                color:white;
                padding:60px 80px;
                margin-top:120px;
            }
            .footer-container{
                display:flex;
                justify-content:space-between;
            }
            .footer-col{
                width:25%;
            }
            .footer-col h3{
                margin-bottom:15px;
            }
            .footer-col ul{
                list-style:none;
            }
            .footer-col ul li{
                margin-bottom:8px;
            }
            .footer-col p{
                margin-bottom:10px;
            }
            .footer hr{
                margin:40px 0;
                border:0.5px solid #444;
            }
            .copyright{
                text-align:center;
                font-size:14px;
            }
        </style>
    </head>

    <body>

        <!-- HEADER -->
        <div class="header">
            <a class="logo" href="${pageContext.request.contextPath}/home">LAVA</a>
        </div>

        <!-- FORGOT PASSWORD -->
        <div class="forgot-container">

            <h2>FORGOT YOUR PASSWORD?</h2>

            <p>
                Enter your email address below and we will send you a link
                to reset your password. The link will expire in <strong>30 minutes</strong>.
            </p>

            <%-- Thông báo lỗi / thành công từ server --%>
            <%
                String error   = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
            %>
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-error"><%= error %></div>
            <% } %>
            <% if (success != null && !success.isEmpty()) { %>
            <div class="alert-success"><%= success %></div>
            <% } %>

            <%-- Chỉ hiển thị form nếu chưa gửi thành công --%>
            <% if (success == null) { %>
            <form action="${pageContext.request.contextPath}/auth" method="post">
                <input type="hidden" name="action" value="forgotPassword">

                <input type="email"
                       name="email"
                       placeholder="Your email address"
                       value="<%= request.getAttribute("lastEmail") != null ? request.getAttribute("lastEmail") : "" %>"
                       required>

                <button type="submit">SEND RESET LINK</button>
            </form>
            <% } %>

            <a href="${pageContext.request.contextPath}/auth?action=loginForm" class="back-link">
                ← Back to Sign In
            </a>

        </div>

        <!-- FOOTER -->
        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col">
                    <h3>LAVA</h3>
                    <p>Discover timeless fashion inspired by elegance and modern luxury.</p>
                </div>
                <div class="footer-col">
                    <h3>Navigation</h3>
                    <ul><li>Home</li><li>Shop</li><li>Collection</li><li>About</li></ul>
                </div>
                <div class="footer-col">
                    <h3>Products</h3>
                    <ul><li>Featured</li><li>New</li><li>Best Sellers</li></ul>
                </div>
                <div class="footer-col">
                    <h3>Contact</h3>
                    <ul>
                        <li>Email: hungg8746@gmail.com</li>
                        <li>Phone: 0702285883</li>
                    </ul>
                </div>
            </div>
            <hr>
            <p class="copyright">© 2026 LAVA Fashion. All rights reserved.</p>
        </footer>
       
    </body>
</html>
