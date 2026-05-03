<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection" %>
<%@ page import="Servlets.PasswordUtils, Servlets.HtmlUtils" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String message = "";
    boolean redirecting = false;

    String identifier = request.getParameter("username") != null ? request.getParameter("username").trim() : "";
    String password = request.getParameter("password") != null ? request.getParameter("password").trim() : "";

    String userId = null;
    String role = null;
    String userName = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (identifier.isEmpty() || password.isEmpty()) {
            message = "Username/email and password are required.";
        } else {
            try {
                MongoDatabase db = MongoDBConnection.getDatabase();

                // Find user by identifier only (not password)
                MongoCollection<Document> users = db.getCollection("users");
                Document user = users.find(Filters.or(
                    Filters.eq("email", identifier),
                    Filters.eq("user_name", identifier)
                )).first();

                if (user != null) {
                    String storedPassword = user.getString("password");
                    boolean authenticated = false;

                    if (PasswordUtils.isHashed(storedPassword)) {
                        // Password is already hashed — verify against hash
                        authenticated = PasswordUtils.verifyPassword(password, storedPassword);
                    } else {
                        // Legacy plaintext password — verify and migrate to hash
                        if (password.equals(storedPassword)) {
                            authenticated = true;
                            // Migrate: replace plaintext with hash
                            String hashed = PasswordUtils.hashPassword(password);
                            users.updateOne(
                                Filters.eq("_id", user.getObjectId("_id")),
                                Updates.set("password", hashed)
                            );
                        }
                    }

                    if (authenticated) {
                        userId = user.getObjectId("_id").toHexString();
                        userName = user.getString("user_name");
                        role = user.getString("role");

                        // Invalidate old sessions in DB
                        MongoCollection<Document> sessions = db.getCollection("sessions");
                        sessions.updateMany(
                            Filters.eq("user_id", userId),
                            Updates.set("is_active", false)
                        );

                        // Invalidate HTTP session if exists
                        if (session != null) session.invalidate();

                        // Create new HTTP session
                        session = request.getSession(true);
                        String sessionToken = java.util.UUID.randomUUID().toString();

                        session.setAttribute("userId", userId);
                        session.setAttribute("userType", role);
                        session.setAttribute("username", userName);
                        session.setAttribute("sessionToken", sessionToken);
                        session.setAttribute("usernameOrEmail", identifier);

                        // Store new session in MongoDB
                        Document sessionDoc = new Document("user_id", userId)
                                .append("role", role)
                                .append("session_token", sessionToken)
                                .append("is_active", true)
                                .append("login_time", new java.util.Date());
                        sessions.insertOne(sessionDoc);

                        redirecting = true;

                        if ("buyer".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/buyer/buyer_dashboard.html");
                        } else if ("seller".equalsIgnoreCase(role)) {
                            session.setAttribute("seller_id", userId);
                            response.sendRedirect(request.getContextPath() + "/seller/seller_home.jsp");
                        } else if ("admin".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
                        } else {
                            message = "Unknown role. Contact administrator.";
                        }
                    } else {
                        message = "Invalid credentials.";
                    }
                } else {
                    message = "Invalid credentials.";
                }

            } catch (Exception e) {
                e.printStackTrace();
                message = "A login error occurred. Please try again later.";
            }
        }
    }

    if (redirecting) return;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Login to AgriBridge - Your trusted agricultural marketplace connecting farmers, buyers, and sellers.">
    <title>AgriBridge | Login</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{margin:0;padding:0;box-sizing:border-box}
        :root{
            --primary:#2ecc71;--primary-dark:#27ae60;--primary-deeper:#1e8449;
            --accent-orange:#ff8c00;--dark:#1a1a2e;--dark-secondary:#2c3e50;
            --text:#333;--text-light:#666;--text-muted:#999;
            --bg:#f8faf9;--bg-section:#f0f4f1;--white:#ffffff;
            --border:#e8ede9;--radius:12px;--radius-sm:8px;
            --error-bg:#FFF0F0;--error-text:#D93025;--error-border:#FECACA;
            --shadow-sm:0 2px 8px rgba(0,0,0,.06);--shadow-md:0 4px 16px rgba(0,0,0,.1);
            --transition:all .3s cubic-bezier(.4,0,.2,1);
        }
        html{font-size:16px;-webkit-font-smoothing:antialiased}
        body{font-family:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;min-height:100vh;display:flex;background:var(--bg)}

        .login-page{display:flex;width:100%;min-height:100vh}

        /* === Brand Panel === */
        .brand-panel{flex:1;background:linear-gradient(160deg,var(--dark) 0%,var(--dark-secondary) 40%,var(--primary-deeper) 100%);display:flex;flex-direction:column;justify-content:center;align-items:center;padding:3rem;position:relative;overflow:hidden}
        .brand-panel::before{content:'';position:absolute;top:-30%;left:-20%;width:500px;height:500px;background:radial-gradient(circle,rgba(255,140,0,.12) 0%,transparent 70%);border-radius:50%;animation:pulseGlow 6s ease-in-out infinite alternate}
        .brand-panel::after{content:'';position:absolute;bottom:-25%;right:-15%;width:400px;height:400px;background:radial-gradient(circle,rgba(46,204,113,.15) 0%,transparent 70%);border-radius:50%;animation:pulseGlow 8s ease-in-out infinite alternate-reverse}
        @keyframes pulseGlow{0%{transform:scale(1);opacity:.6}100%{transform:scale(1.2);opacity:1}}

        .float-el{position:absolute;border-radius:50%;opacity:.07;background:#fff}
        .float-el:nth-child(1){width:80px;height:80px;top:12%;left:15%;animation:floatAnim 8s ease-in-out infinite}
        .float-el:nth-child(2){width:50px;height:50px;top:60%;left:70%;animation:floatAnim 10s ease-in-out infinite 2s}
        .float-el:nth-child(3){width:30px;height:30px;top:35%;left:80%;animation:floatAnim 7s ease-in-out infinite 4s}
        .float-el:nth-child(4){width:60px;height:60px;top:75%;left:25%;animation:floatAnim 9s ease-in-out infinite 1s}
        @keyframes floatAnim{0%,100%{transform:translateY(0) rotate(0)}50%{transform:translateY(-30px) rotate(10deg)}}

        .brand-content{position:relative;z-index:2;text-align:center;color:#fff;max-width:420px}
        .brand-logo{font-size:2.2rem;font-weight:800;letter-spacing:-.5px;margin-bottom:1.5rem;color:var(--white)}
        .brand-logo span{color:var(--primary)}
        .brand-tagline{font-size:2rem;font-weight:700;line-height:1.25;margin-bottom:1rem}
        .brand-desc{font-size:1rem;line-height:1.7;color:rgba(255,255,255,.65);margin-bottom:2.5rem}
        .trust-badges{display:flex;gap:2rem;justify-content:center}
        .trust-badge .badge-num{display:block;font-size:1.6rem;font-weight:800;color:var(--accent-orange)}
        .trust-badge .badge-lbl{font-size:.75rem;color:rgba(255,255,255,.55);text-transform:uppercase;letter-spacing:1px}

        /* === Form Panel === */
        .form-panel{flex:1;display:flex;flex-direction:column;justify-content:center;align-items:center;padding:2.5rem;background:var(--bg);overflow-y:auto}
        .login-card{width:100%;max-width:440px;animation:slideUp .6s cubic-bezier(.16,1,.3,1)}
        @keyframes slideUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}

        .mobile-logo{display:none;font-size:1.5rem;font-weight:800;color:var(--dark);margin-bottom:1.5rem}
        .mobile-logo span{color:var(--primary)}
        .back-link{display:inline-flex;align-items:center;gap:.4rem;color:var(--text-muted);font-size:.85rem;text-decoration:none;margin-bottom:2rem;transition:var(--transition)}
        .back-link:hover{color:var(--primary)}

        .card-header{margin-bottom:2rem}
        .card-header h1{font-size:1.75rem;font-weight:700;color:var(--dark);margin-bottom:.4rem}
        .card-header p{color:var(--text-light);font-size:.95rem}

        /* Form */
        .form-group{margin-bottom:1.4rem}
        .form-group label{display:block;font-size:.85rem;font-weight:600;color:var(--text);margin-bottom:.45rem}
        .input-wrapper{position:relative}
        .input-wrapper .input-icon{position:absolute;left:14px;top:50%;transform:translateY(-50%);font-size:1.1rem;color:var(--text-muted);pointer-events:none;transition:color .3s}
        .input-wrapper input{width:100%;padding:.85rem 1rem .85rem 2.8rem;border:2px solid var(--border);border-radius:var(--radius-sm);font-size:.95rem;font-family:inherit;color:var(--text);background:var(--white);transition:var(--transition);outline:none}
        .input-wrapper input::placeholder{color:var(--text-muted)}
        .input-wrapper input:focus{border-color:var(--primary);box-shadow:0 0 0 3px rgba(46,204,113,.12)}
        .input-wrapper input:focus ~ .input-icon{color:var(--primary)}
        .password-toggle{position:absolute;right:14px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;font-size:1.1rem;color:var(--text-muted);transition:color .3s;padding:4px}
        .password-toggle:hover{color:var(--text)}

        /* Submit */
        .btn-login{width:100%;padding:.9rem;background:var(--primary);color:var(--white);font-family:inherit;font-size:1rem;font-weight:600;border:none;border-radius:var(--radius-sm);cursor:pointer;position:relative;overflow:hidden;transition:var(--transition);margin-top:.5rem;box-shadow:0 4px 15px rgba(46,204,113,.3)}
        .btn-login:hover{background:var(--primary-dark);transform:translateY(-2px);box-shadow:0 6px 20px rgba(46,204,113,.4)}
        .btn-login:active{transform:translateY(0)}

        /* Error */
        .error-message{background:var(--error-bg);border:1px solid var(--error-border);color:var(--error-text);padding:.85rem 1rem;border-radius:var(--radius-sm);font-size:.9rem;text-align:center;margin-bottom:1.2rem;animation:shake .4s ease-in-out}
        @keyframes shake{0%,100%{transform:translateX(0)}25%{transform:translateX(-6px)}75%{transform:translateX(6px)}}

        .divider{display:flex;align-items:center;margin:1.8rem 0;gap:1rem}
        .divider::before,.divider::after{content:'';flex:1;height:1px;background:var(--border)}
        .divider span{font-size:.8rem;color:var(--text-muted);text-transform:uppercase;letter-spacing:1px}

        .form-footer{text-align:center;margin-top:1.8rem;font-size:.9rem;color:var(--text-light)}
        .form-footer a{color:var(--primary-dark);font-weight:600;text-decoration:none;transition:var(--transition)}
        .form-footer a:hover{color:var(--primary-deeper);text-decoration:underline}

        /* === Responsive === */
        @media(max-width:1024px){.brand-panel{flex:.8;padding:2rem}.brand-tagline{font-size:1.6rem}}
        @media(max-width:768px){
            body{overflow:auto}.login-page{flex-direction:column}
            .brand-panel{flex:none;padding:2.5rem 2rem 2rem;min-height:auto}
            .brand-tagline{font-size:1.4rem}.brand-desc{display:none}
            .form-panel{flex:none;padding:2rem 1.5rem 3rem}
            .login-card{max-width:100%}.mobile-logo{display:block}.back-link{margin-bottom:1.5rem}
        }
        @media(max-width:480px){
            .brand-panel{padding:1.8rem 1.2rem 1.5rem}.brand-logo{font-size:1.6rem}.brand-tagline{font-size:1.2rem}
            .trust-badges{gap:1rem}.trust-badge .badge-num{font-size:1.3rem}
            .form-panel{padding:1.5rem 1.2rem 2.5rem}.card-header h1{font-size:1.4rem}
            .input-wrapper input{padding:.75rem 1rem .75rem 2.5rem;font-size:.9rem}
        }
        @media(max-width:360px){
            .brand-panel{padding:1.2rem 1rem}.brand-logo{font-size:1.3rem;margin-bottom:.8rem}
            .brand-tagline{font-size:1rem}.form-panel{padding:1.2rem 1rem 2rem}.card-header h1{font-size:1.25rem}
        }
    </style>
</head>
<body>

<div class="login-page">
    <div class="brand-panel">
        <div class="float-el"></div><div class="float-el"></div><div class="float-el"></div><div class="float-el"></div>
        <div class="brand-content">
            <div class="brand-logo">AGRI<span>BRIDGE</span></div>
            <h2 class="brand-tagline">Farm Fresh, Delivered With Trust.</h2>
            <p class="brand-desc">Join thousands of farmers and buyers across Africa trading fresh agricultural produce on a platform built for trust and transparency.</p>
            <div class="trust-badges">
                <div class="trust-badge"><span class="badge-num">2K+</span><span class="badge-lbl">Farmers</span></div>
                <div class="trust-badge"><span class="badge-num">50+</span><span class="badge-lbl">Products</span></div>
                <div class="trust-badge"><span class="badge-num">99%</span><span class="badge-lbl">Satisfaction</span></div>
            </div>
        </div>
    </div>

    <div class="form-panel">
        <div class="login-card">
            <a href="home.jsp" class="back-link">&#8592; Back to Home</a>
            <div class="mobile-logo">AGRI<span>BRIDGE</span></div>
            <div class="card-header">
                <h1>Welcome Back</h1>
                <p>Sign in to continue to your account</p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="error-message"><%= HtmlUtils.escape(message) %></div>
            <% } %>

            <form method="post" id="loginForm">
                <div class="form-group">
                    <label for="username">Username or Email</label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#128100;</span>
                        <input type="text" id="username" name="username" placeholder="Enter your username or email" required />
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <span class="input-icon">&#128274;</span>
                        <input type="password" id="password" name="password" placeholder="Enter your password" required />
                        <button type="button" class="password-toggle" onclick="togglePassword()" aria-label="Toggle password visibility" id="toggleBtn">&#128065;</button>
                    </div>
                </div>

                <button type="submit" class="btn-login" id="loginBtn">Sign In</button>
            </form>

            <div class="divider"><span>or</span></div>

            <div class="form-footer">
                Don't have an account? <a href="register.jsp">Create one now</a>
            </div>
        </div>
    </div>
</div>

<script>
    function togglePassword() {
        var pwdField = document.getElementById('password');
        var btn = document.getElementById('toggleBtn');
        if (pwdField.type === 'password') {
            pwdField.type = 'text';
            btn.innerHTML = '&#128064;';
        } else {
            pwdField.type = 'password';
            btn.innerHTML = '&#128065;';
        }
    }
</script>

</body>
</html>
