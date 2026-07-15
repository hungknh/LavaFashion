<%@ page contentType="text/html;charset=UTF-8" language="java" import="model.User" %>
<%
    String path = request.getContextPath();
    User loggedUser = (User) session.getAttribute("loggedUser");
%>
<!DOCTYPE html>
<!-- data-ctx truyền context path cho lava-ajax.js -->
<html data-ctx="<%= path %>">
    <head>
        <meta charset="UTF-8">
        <title>LAVA – Home</title>
        <link rel="stylesheet" href="<%= path %>/assets/css/style.css">
        <script src="https://kit.fontawesome.com/274aac91bf.js" crossorigin="anonymous"></script>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600&display=swap" rel="stylesheet">
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
                <a href="<%= path %>/home" style="text-decoration:none;color:black;">
                    <i class="fa-brands fa-atlassian fa-xl"></i>
                </a>
            </div>
            <div class="menu-right">
                <% if (loggedUser != null) { %>
                <span style="font-size:14px;color:#555;">Hi, <strong><%= loggedUser.getDisplayName() %></strong></span>
                <span>|</span>
                <% if (loggedUser.isAdmin()) { %>
                <a href="<%= path %>/admin" class="icon">Admin</a>
                <span>|</span>
                <% } %>
                <a href="<%= path %>/profile" class="icon">My Profile</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=logout" class="icon">Sign Out</a>
                <% } else { %>
                <a href="<%= path %>/auth?action=loginForm" class="icon">Login</a>
                <span>|</span>
                <a href="<%= path %>/auth?action=registerForm" class="icon">Register</a>
                <% } %>

                <!-- Search box với live dropdown -->
                <div class="search-wrap" style="margin-left:12px;">
                    <input type="text" id="searchInput" placeholder="Search products..." autocomplete="off">
                    <i class="fa-solid fa-magnifying-glass search-icon"></i>
                    <div id="searchDropdown" class="search-dropdown"></div>
                </div>

                <!-- Cart icon với badge số lượng -->
                <a href="<%= path %>/cart" class="cart" style="position:relative;margin-left:12px;">
                    <i class="fa-solid fa-basket-shopping fa-xl"></i>
                    <span id="cartBadge" class="cart-badge">0</span>
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
            <a href="<%= path %>/order-history">My Orders</a>
            <a href="<%= path %>/auth?action=logout">Sign Out</a>
            <% } else { %>
            <a href="<%= path %>/auth?action=loginForm">Login</a>
            <% } %>
            <a href="<%= path %>/cart">Shopping Cart</a>
        </div>

        <!-- ==================== HERO ==================== -->
        <div class="container">
            <div class="sidebar">
            </div>
            <div class="hero">
                <div class="hero-text">
                    <div class="hero-title">
                        <h1>NEW<br>COLLECTION</h1>
                        <p>Summer<br>2026</p>
                    </div>
                    <div class="hero-bottom">
                        <!-- "Go To Shop" → products page -->
                        <a href="<%= path %>/products" class="shop-btn">
                            <span>Go To Shop</span>
                            <span class="arrow"><i class="fa-solid fa-arrow-right-long"></i></span>
                        </a>
                    </div>
                </div>
                <div class="slider">
                    <button id="prev"><i class="fa-solid fa-angle-left fa-2xl"></i></button>
                    <div class="viewport">
                        <div class="slider-container" id="slider">
                            <!-- Ảnh hero → click dẫn đến products với filter category -->
                            <div class="product-image">
                                <a href="<%= path %>/products?categoryId=4">
                                    <img src="<%= path %>/assets/images/images6.jpg" alt="Jacket Collection">
                                </a>
                            </div>
                            <div class="product-image">
                                <a href="<%= path %>/products?categoryId=1">
                                    <img src="<%= path %>/assets/images/images3.jpg" alt="T-Shirt Collection">
                                </a>
                            </div>
                            <div class="product-image">
                                <a href="<%= path %>/products?categoryId=5">
                                    <img src="<%= path %>/assets/images/images4.jpg" alt="Pant Collection">
                                </a>
                            </div>
                            <div class="product-image">
                                <a href="<%= path %>/products?categoryId=2">
                                    <img src="<%= path %>/assets/images/images5.jpg" alt="Shirt Collection">
                                </a>
                            </div>
                        </div>
                    </div>
                    <button id="next"><i class="fa-solid fa-angle-left fa-rotate-180 fa-2xl"></i></button>
                </div>
            </div>
        </div>

        <!-- ==================== NEW THIS WEEK ==================== -->
        <section class="new-this-week">
            <div class="ntw-header">
                <h2 class="ntw-title">NEW THIS WEEK</h2>
                <a href="<%= path %>/products?productType=new" class="ntw-see-all">See All</a>
            </div>
            <div class="ntw-slider-wrap">
                <div class="ntw-grid" id="ntwGrid">

                    <div class="ntw-card">
                        <a href="<%= path %>/products?categoryId=1" style="text-decoration:none;color:inherit;">
                            <div class="ntw-img-wrap">
                                <img src="<%= path %>/assets/images/vnecktshirt.jpg" alt="V-Neck T-Shirt">
                                <button class="ntw-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=1'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="ntw-info">
                                <span class="ntw-type">V-Neck T-Shirt</span>
                                <div class="ntw-row">
                                    <span class="ntw-name">Embroidered Seersucker Shirt</span>
                                    <span class="ntw-price">$99</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="ntw-card">
                        <a href="<%= path %>/products?categoryId=1" style="text-decoration:none;color:inherit;">
                            <div class="ntw-img-wrap">
                                <img src="<%= path %>/assets/images/cottontshirt.jpg" alt="Cotton T-Shirt">
                                <button class="ntw-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=1'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="ntw-info">
                                <span class="ntw-type">Cotton T-Shirt</span>
                                <div class="ntw-row">
                                    <span class="ntw-name">Basic Slim Fit T-Shirt</span>
                                    <span class="ntw-price">$99</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="ntw-card">
                        <a href="<%= path %>/products?categoryId=1" style="text-decoration:none;color:inherit;">
                            <div class="ntw-img-wrap">
                                <img src="<%= path %>/assets/images/honleytshirt.jpg" alt="Honloy T-Shirt">
                                <button class="ntw-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=1'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="ntw-info">
                                <span class="ntw-type">Honloy T-Shirt</span>
                                <div class="ntw-row">
                                    <span class="ntw-name">Blurred Print T-Shirt</span>
                                    <span class="ntw-price">$99</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="ntw-card">
                        <a href="<%= path %>/products?categoryId=3" style="text-decoration:none;color:inherit;">
                            <div class="ntw-img-wrap">
                                <img src="<%= path %>/assets/images/crewtshirt.jpg" alt="Crewneck T-Shirt">
                                <button class="ntw-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=3'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="ntw-info">
                                <span class="ntw-type">Crewneck T-Shirt</span>
                                <div class="ntw-row">
                                    <span class="ntw-name">Full Sleeve Zipper</span>
                                    <span class="ntw-price">$99</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="ntw-card">
                        <a href="<%= path %>/products?categoryId=2" style="text-decoration:none;color:inherit;">
                            <div class="ntw-img-wrap">
                                <img src="<%= path %>/assets/images/polo.jpg" alt="Polo Shirt">
                                <button class="ntw-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=2'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="ntw-info">
                                <span class="ntw-type">Polo Shirt</span>
                                <div class="ntw-row">
                                    <span class="ntw-name">Classic Polo Shirt</span>
                                    <span class="ntw-price">$89</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="ntw-card">
                        <a href="<%= path %>/products?categoryId=2" style="text-decoration:none;color:inherit;">
                            <div class="ntw-img-wrap">
                                <img src="<%= path %>/assets/images/linen.jpg" alt="Linen Shirt">
                                <button class="ntw-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=2'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="ntw-info">
                                <span class="ntw-type">Linen Shirt</span>
                                <div class="ntw-row">
                                    <span class="ntw-name">Relaxed Linen Shirt</span>
                                    <span class="ntw-price">$109</span>
                                </div>
                            </div>
                        </a>
                    </div>

                </div>
            </div>
            <div class="ntw-arrows">
                <button id="ntwPrev"><i class="fa-solid fa-angle-left"></i></button>
                <button id="ntwNext"><i class="fa-solid fa-angle-right"></i></button>
            </div>
        </section>

        <!-- ==================== XIV COLLECTIONS ==================== -->
        <section class="collections-section">
            <h2 class="col-title">XIV COLLECTIONS<br>25-26</h2>
            <div class="col-slider-wrap">
                <div class="col-grid" id="colGrid">

                    <div class="col-card">
                        <a href="<%= path %>/products?categoryId=1" style="text-decoration:none;color:inherit;">
                            <div class="col-img-wrap">
                                <img src="<%= path %>/assets/images/cotton2.jpg" alt="Cotton T-Shirt">
                                <button class="col-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=1'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="col-info">
                                <span class="col-type">Cotton T-Shirt</span>
                                <div class="col-row">
                                    <span class="col-name">Basic Heavy Weight T-Shirt</span>
                                    <span class="col-price">$199</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col-card">
                        <a href="<%= path %>/products?categoryId=5" style="text-decoration:none;color:inherit;">
                            <div class="col-img-wrap">
                                <img src="<%= path %>/assets/images/jeans.jpg" alt="Jeans">
                                <button class="col-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=5'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="col-info">
                                <span class="col-type">Cotton Jeans</span>
                                <div class="col-row">
                                    <span class="col-name">Soft Wash Straight Fit Jeans</span>
                                    <span class="col-price">$199</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col-card">
                        <a href="<%= path %>/products?categoryId=1" style="text-decoration:none;color:inherit;">
                            <div class="col-img-wrap">
                                <img src="<%= path %>/assets/images/cotton3.jpg" alt="Cotton T-Shirt">
                                <button class="col-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=1'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="col-info">
                                <span class="col-type">Cotton T-Shirt</span>
                                <div class="col-row">
                                    <span class="col-name">Heavy Weight Graphic Tee</span>
                                    <span class="col-price">$199</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col-card">
                        <a href="<%= path %>/products?categoryId=4" style="text-decoration:none;color:inherit;">
                            <div class="col-img-wrap">
                                <img src="<%= path %>/assets/images/outerwear.jpg" alt="Jacket">
                                <button class="col-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=4'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="col-info">
                                <span class="col-type">Outerwear</span>
                                <div class="col-row">
                                    <span class="col-name">Relaxed Fit Wool Jacket</span>
                                    <span class="col-price">$299</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col-card">
                        <a href="<%= path %>/products?categoryId=5" style="text-decoration:none;color:inherit;">
                            <div class="col-img-wrap">
                                <img src="<%= path %>/assets/images/trouser.jpg" alt="Trousers">
                                <button class="col-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=5'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="col-info">
                                <span class="col-type">Trousers</span>
                                <div class="col-row">
                                    <span class="col-name">Tapered Chino Trousers</span>
                                    <span class="col-price">$149</span>
                                </div>
                            </div>
                        </a>
                    </div>

                    <div class="col-card">
                        <a href="<%= path %>/products?categoryId=4" style="text-decoration:none;color:inherit;">
                            <div class="col-img-wrap">
                                <img src="<%= path %>/assets/images/hoodie.jpg" alt="Hoodie">
                                <button class="col-add-btn" onclick="event.preventDefault();window.location = '<%= path %>/products?categoryId=4'">
                                    <i class="fa-solid fa-plus"></i>
                                </button>
                            </div>
                            <div class="col-info">
                                <span class="col-type">Hoodie</span>
                                <div class="col-row">
                                    <span class="col-name">Oversized Heavy Hoodie</span>
                                    <span class="col-price">$179</span>
                                </div>
                            </div>
                        </a>
                    </div>

                </div>
            </div>
            <div class="col-arrows">
                <button id="colPrev"><i class="fa-solid fa-angle-left"></i></button>
                <button id="colNext"><i class="fa-solid fa-angle-right"></i></button>
            </div>
        </section>

        <!-- ==================== OUR APPROACH ==================== -->
        <section class="approach-section">
            <div class="approach-text">
                <h2 class="approach-title">OUR APPROACH TO FASHION DESIGN</h2>
                <p class="approach-desc">
                    At LAVA, we blend creativity with craftsmanship to create fashion that
                    transcends trends and stands the test of time. Each design is meticulously
                    crafted, ensuring the highest quality and exquisite finish.
                </p>
                <a href="<%= path %>/products" class="shop-btn" style="margin-top:20px;display:inline-flex;">
                    <span>Shop All</span>
                    <span class="arrow"><i class="fa-solid fa-arrow-right-long"></i></span>
                </a>
            </div>
            <div class="approach-gallery">
                <!-- Ảnh gallery → click vào đẫn đến products -->
                <a href="<%= path %>/products?categoryId=4" class="ag-item ag-top">
                    <img src="<%= path %>/assets/images/alter.jpg" alt="Fashion">
                </a>
                <a href="<%= path %>/products?categoryId=2" class="ag-item ag-bottom">
                    <img src="<%= path %>/assets/images/alter2.jpg" alt="Fashion">
                </a>
                <a href="<%= path %>/products?categoryId=1" class="ag-item ag-top">
                    <img src="<%= path %>/assets/images/alter3.jpg" alt="Fashion">
                </a>
                <a href="<%= path %>/products?categoryId=5" class="ag-item ag-bottom">
                    <img src="<%= path %>/assets/images/alter4.jpg" alt="Fashion">
                </a>
            </div>
        </section>

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
                        <li><a href="<%= path %>/order-history">My Orders</a></li>
                        <li><a href="<%= path %>/auth?action=logout">Sign Out</a></li>
                            <% } else { %>
                        <li><a href="<%= path %>/auth?action=loginForm">Login</a></li>
                        <li><a href="<%= path %>/auth?action=registerForm">Register</a></li>
                            <% } %>
                    </ul>
                </div>
                <div class="footer-col">
                    <h4>Contact</h4>
                    <p>Email: hungg8746@gmail.com</p>
                    <p>Phone: 0702285883</p>
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

            document.addEventListener("DOMContentLoaded", function () {
                // Hero slider
                var slider = document.getElementById("slider");
                var index = 0, imageWidth = 300, maxIndex = slider.children.length - 3;
                document.getElementById("next").addEventListener("click", function () {
                    if (index < maxIndex) {
                        index++;
                        slider.style.transform = "translateX(-" + (index * imageWidth) + "px)";
                    }
                });
                document.getElementById("prev").addEventListener("click", function () {
                    if (index > 0) {
                        index--;
                        slider.style.transform = "translateX(-" + (index * imageWidth) + "px)";
                    }
                });

                // New This Week slider
                var grid = document.getElementById("ntwGrid"), ntwIndex = 0, NTW_GAP = 24;
                var ntwMax = grid.children.length - 3;
                function ntwStep() {
                    return grid.children[0].offsetWidth + NTW_GAP;
                }
                document.getElementById("ntwNext").addEventListener("click", function () {
                    if (ntwIndex < ntwMax) {
                        ntwIndex++;
                        grid.style.transform = "translateX(-" + (ntwIndex * ntwStep()) + "px)";
                    }
                });
                document.getElementById("ntwPrev").addEventListener("click", function () {
                    if (ntwIndex > 0) {
                        ntwIndex--;
                        grid.style.transform = "translateX(-" + (ntwIndex * ntwStep()) + "px)";
                    }
                });

                // XIV Collections slider
                var colGrid = document.getElementById("colGrid"), colIndex = 0, COL_GAP = 24;
                var colMax = colGrid.children.length - 3;
                function colStep() {
                    return colGrid.children[0].offsetWidth + COL_GAP;
                }
                document.getElementById("colNext").addEventListener("click", function () {
                    if (colIndex < colMax) {
                        colIndex++;
                        colGrid.style.transform = "translateX(-" + (colIndex * colStep()) + "px)";
                    }
                });
                document.getElementById("colPrev").addEventListener("click", function () {
                    if (colIndex > 0) {
                        colIndex--;
                        colGrid.style.transform = "translateX(-" + (colIndex * colStep()) + "px)";
                    }
                });
            });
        </script>

        <!-- AJAX: cart badge + live search -->
        <script src="<%= path %>/assets/js/lava-ajax.js"></script>

    </body>
</html>
