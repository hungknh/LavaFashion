<%-- 
    Document   : login
    Created on : Mar 10, 2026, 8:33:55 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Login – LAVA</title>

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

            /* LOGIN FORM */
            .login-container{
                width:500px;
                margin:120px auto;
            }
            .login-container h2{
                font-size:18px;
                letter-spacing:2px;
                margin-bottom:30px;
                text-align:left;
            }

            /* Thông báo lỗi */
            .alert-error{
                background:#fff0f0;
                border:1px solid #f5c6c6;
                color:#c0392b;
                padding:12px 16px;
                margin-bottom:18px;
                font-size:14px;
            }

            /* Thông báo thành công (sau register, reset pw...) */
            .alert-success{
                background:#f0fff4;
                border:1px solid #b2dfdb;
                color:#1a7a4a;
                padding:12px 16px;
                margin-bottom:18px;
                font-size:14px;
            }

            form input[type="text"],
            form input[type="password"]{
                width:100%;
                padding:18px;
                margin-bottom:18px;
                border:1px solid #999;
                font-size:14px;
                background:white;
                outline:none;
            }

            form input[type="text"]:focus,
            form input[type="password"]:focus{
                border-color:black;
            }

            .options{
                display:flex;
                justify-content:space-between;
                align-items:center;
                font-size:14px;
                margin-bottom:25px;
                flex-wrap:wrap;
                gap:10px;
            }
            .options a{
                color:black;
                text-decoration:underline;
            }
            .remember{
                display:flex;
                align-items:center;
                gap:10px;
                white-space:nowrap;
            }
            .remember label{
                display:flex;
                align-items:center;
                gap:8px;
                cursor:pointer;
            }
            .remember input{
                width:16px;
                height:16px;
            }

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

            .register-link{
                margin-top:20px;
                text-align:center;
                font-size:15px;
            }
            .register-link a{
                color:black;
                text-decoration:underline;
                margin-left:5px;
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
                gap:40px;
            }
            .footer-col{
                width:25%;
            }
            .footer-col h2{
                margin-bottom:15px;
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

        <!-- LOGIN -->
        <div class="login-container">

            <h2>SIGN IN TO MY ACCOUNT</h2>

            <%-- Hiển thị thông báo lỗi từ server --%>
            <%
                String error   = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
                // Thông báo sau redirect
                if ("1".equals(request.getParameter("registered")))
                    success = "Registration successful! Please log in.";
                if ("1".equals(request.getParameter("reset")))
                    success = "Password reset successful! Please log in.";
            %>
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-error"><%= error %></div>
            <% } %>
            <% if (success != null && !success.isEmpty()) { %>
            <div class="alert-success"><%= success %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/auth" method="post">

                <input type="hidden" name="action" value="login">

                <input type="text"
                       name="username"
                       placeholder="Username"
                       value="<%= request.getAttribute("lastUsername") != null ? request.getAttribute("lastUsername") : "" %>"
                       required>

                <input type="password"
                       name="password"
                       placeholder="Password"
                       required>

                <div class="options">
                    <div class="remember">
                        <label>
                            <input type="checkbox" name="remember">
                            Remember me
                        </label>
                    </div>
                    <a href="${pageContext.request.contextPath}/auth?action=forgotForm">Forgot your password?</a>
                </div>

                <button type="submit">SIGN IN</button>

            </form>

            <div class="register-link">
                Don't have an account?
                <a href="${pageContext.request.contextPath}/auth?action=registerForm">Register here</a>
            </div>

        </div>

        <!-- FOOTER -->
        <footer class="footer">
            <div class="footer-container">
                <div class="footer-col">
                    <h2>LAVA</h2>
                    <p>Discover timeless fashion inspired by elegance and modern luxury.
                        Our collections are designed to bring confidence and style to every moment.</p>
                </div>
                <div class="footer-col">
                    <h3>Navigation</h3>
                    <ul>
                        <li>Home</li>
                        <li>Shop</li>
                        <li>Collection</li>
                        <li>About</li>
                    </ul>
                </div>
                <div class="footer-col">
                    <h3>Products</h3>
                    <ul>
                        <li>Featured</li>
                        <li>New</li>
                        <li>Best Sellers</li>
                    </ul>
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
