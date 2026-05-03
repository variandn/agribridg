<%@ page import="com.mongodb.client.*, com.mongodb.client.model.*, org.bson.Document, org.bson.types.ObjectId, Servlets.MongoDBConnection, com.mongodb.MongoWriteException" %>
<%@ page import="Servlets.PasswordUtils, Servlets.HtmlUtils" %>
<%@ page import="jakarta.servlet.*, jakarta.servlet.http.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Register for AgriBridge - Join Africa's trusted agricultural marketplace.">
    <title>AgriBridge | Register</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: hsl(145, 63%, 49%);
            --primary-light: hsl(145, 63%, 65%);
            --primary-dark: hsl(145, 63%, 35%);
            --accent: hsl(33, 100%, 50%);
            --dark: hsl(240, 30%, 15%);
            --dark-soft: hsl(240, 20%, 25%);
            --white: #ffffff;
            --bg: hsl(150, 20%, 98%);
            --text: hsl(240, 10%, 20%);
            --text-light: hsl(240, 10%, 45%);
            --border: hsl(150, 10%, 90%);
            --radius: 16px;
            --radius-sm: 10px;
            --shadow: 0 10px 30px -10px rgba(0,0,0,0.1);
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --error: #ff4757;
            --success: #2ed573;
        }

        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--text);
            line-height: 1.6;
            overflow-x: hidden;
            min-height: 100vh;
        }

        .register-container {
            display: grid;
            grid-template-columns: 45% 55%;
            min-height: 100vh;
            width: 100%;
        }

        /* Brand Section */
        .brand-section {
            background: linear-gradient(135deg, var(--dark) 0%, var(--dark-soft) 100%);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 4rem;
            position: relative;
            color: var(--white);
            overflow: hidden;
        }

        .brand-section::after {
            content: '';
            position: absolute;
            top: -20%;
            right: -20%;
            width: 60%;
            height: 60%;
            background: radial-gradient(circle, hsla(145, 63%, 49%, 0.15) 0%, transparent 70%);
            z-index: 1;
        }

        .brand-content { position: relative; z-index: 2; text-align: center; }
        .brand-logo { font-size: 2.5rem; font-weight: 800; margin-bottom: 1.5rem; letter-spacing: -1px; }
        .brand-logo span { color: var(--primary); }
        .brand-tagline { font-size: 1.8rem; font-weight: 700; margin-bottom: 1rem; line-height: 1.2; }
        .brand-desc { opacity: 0.7; font-size: 1rem; max-width: 400px; margin: 0 auto 2.5rem; }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
            margin-top: 2rem;
        }
        .stat-item h3 { font-size: 1.8rem; color: var(--accent); margin-bottom: 0.2rem; }
        .stat-item p { font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1px; opacity: 0.6; }

        /* Form Section */
        .form-section {
            padding: 3rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background: var(--bg);
        }

        .form-card {
            width: 100%;
            max-width: 580px;
            background: var(--white);
            padding: 3rem;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            position: relative;
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .form-header { margin-bottom: 2.5rem; }
        .form-header h1 { font-size: 2rem; font-weight: 800; color: var(--dark); margin-bottom: 0.5rem; }
        .form-header p { color: var(--text-light); }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.2rem;
        }
        .full-width { grid-column: span 2; }

        .input-group { margin-bottom: 1.5rem; position: relative; }
        .input-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--dark-soft);
            margin-bottom: 0.5rem;
            transition: var(--transition);
        }
        .input-group input, 
        .input-group select, 
        .input-group textarea {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 2px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 0.95rem;
            transition: var(--transition);
            background: var(--bg);
        }

        .input-group input:focus, 
        .input-group select:focus, 
        .input-group textarea:focus {
            outline: none;
            border-color: var(--primary);
            background: var(--white);
            box-shadow: 0 0 0 4px hsla(145, 63%, 49%, 0.1);
        }

        /* Real-time validation styles */
        .input-group.valid input { border-color: var(--success); }
        .input-group.invalid input { border-color: var(--error); }
        .error-msg {
            color: var(--error);
            font-size: 0.75rem;
            margin-top: 0.3rem;
            height: 0;
            overflow: hidden;
            transition: var(--transition);
            opacity: 0;
        }
        .input-group.invalid .error-msg { height: auto; opacity: 1; margin-top: 0.5rem; }

        /* Password Strength */
        .pw-strength-container { margin-top: 0.5rem; }
        .pw-strength-bar {
            height: 6px;
            background: var(--border);
            border-radius: 3px;
            overflow: hidden;
            display: flex;
            gap: 2px;
        }
        .pw-strength-segment { flex: 1; height: 100%; transition: var(--transition); background: transparent; }
        .pw-text { font-size: 0.75rem; margin-top: 0.4rem; font-weight: 600; }

        /* File Upload */
        .file-upload-wrapper {
            border: 2px dashed var(--border);
            padding: 1.5rem;
            border-radius: var(--radius-sm);
            text-align: center;
            cursor: pointer;
            transition: var(--transition);
            background: var(--bg);
        }
        .file-upload-wrapper:hover { border-color: var(--primary); background: hsla(145, 63%, 49%, 0.05); }
        .file-upload-wrapper i { font-size: 1.5rem; color: var(--primary); display: block; margin-bottom: 0.5rem; }
        .file-upload-input { display: none; }

        /* Custom Checkbox */
        .checkbox-group {
            display: flex;
            align-items: flex-start;
            gap: 0.8rem;
            margin: 1.5rem 0;
            cursor: pointer;
        }
        .checkbox-group input { display: none; }
        .checkbox-custom {
            width: 20px;
            height: 20px;
            border: 2px solid var(--border);
            border-radius: 4px;
            flex-shrink: 0;
            transition: var(--transition);
            position: relative;
        }
        .checkbox-group input:checked + .checkbox-custom {
            background: var(--primary);
            border-color: var(--primary);
        }
        .checkbox-group input:checked + .checkbox-custom::after {
            content: '✓';
            color: white;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 12px;
        }
        .checkbox-label { font-size: 0.85rem; color: var(--text-light); }
        .checkbox-label a { color: var(--primary); text-decoration: none; font-weight: 600; }

        /* Submit Button */
        .btn-submit {
            width: 100%;
            padding: 1rem;
            background: var(--primary);
            color: var(--white);
            border: none;
            border-radius: var(--radius-sm);
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.8rem;
            box-shadow: 0 4px 15px hsla(145, 63%, 49%, 0.3);
        }
        .btn-submit:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px hsla(145, 63%, 49%, 0.4);
        }
        .btn-submit:disabled { background: var(--text-light); cursor: not-allowed; transform: none; }

        /* Spinner */
        .spinner {
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,0.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 0.8s linear infinite;
            display: none;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* Message Styles */
        .msg {
            padding: 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.9rem;
            text-align: center;
            margin-bottom: 2rem;
            animation: slideDown 0.4s ease-out;
        }
        @keyframes slideDown { from { opacity:0; transform: translateY(-10px); } to { opacity:1; transform: translateY(0); } }
        .msg.error { background: #fff5f5; border: 1px solid #feb2b2; color: #c53030; }
        .msg.success { background: #f0fff4; border: 1px solid #9ae6b4; color: #276749; }

        /* Shake animation for invalid */
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-8px); }
            75% { transform: translateX(8px); }
        }
        .shake { animation: shake 0.4s ease-in-out; }

        /* Responsive */
        @media (max-width: 1024px) {
            .register-container { grid-template-columns: 1fr; }
            .brand-section { padding: 3rem 2rem; }
            .form-section { padding: 2rem 1.5rem; }
        }
        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .full-width { grid-column: span 1; }
            .form-card { padding: 2rem 1.5rem; }
        }
    </style>
</head>
<body>

<%
    String message = "";
    String messageClass = "";
    boolean registrationSuccess = false;

    // Use a flag to check if we should process multipart
    boolean isMultipart = request.getContentType() != null && request.getContentType().startsWith("multipart/form-data");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            String username, role, firstname, lastname, email, phone, gender, country, password, confirmpassword, language;
            
            if (isMultipart) {
                // Handling multipart manually or assuming multipart-config is enabled in web.xml
                // For now, let's use getParameter if available, but if it's null, we'd need getPart().getParameter() equivalent
                // In Jakarta EE 10, if <multipart-config> is in web.xml, getParameter() still works!
                username = request.getParameter("username");
                role = request.getParameter("userType");
                firstname = request.getParameter("firstname");
                lastname = request.getParameter("lastname");
                email = request.getParameter("email");
                phone = request.getParameter("phone");
                gender = request.getParameter("gender");
                country = request.getParameter("country");
                password = request.getParameter("password");
                confirmpassword = request.getParameter("confirm_password");
                language = request.getParameter("language");
            } else {
                username = request.getParameter("username");
                role = request.getParameter("userType");
                firstname = request.getParameter("firstname");
                lastname = request.getParameter("lastname");
                email = request.getParameter("email");
                phone = request.getParameter("phone");
                gender = request.getParameter("gender");
                country = request.getParameter("country");
                password = request.getParameter("password");
                confirmpassword = request.getParameter("confirm_password");
                language = request.getParameter("language");
            }

            if (username != null && email != null && password != null && password.equals(confirmpassword)) {
                MongoDatabase db = MongoDBConnection.getDatabase();
                MongoCollection<Document> users = db.getCollection("users");
                String hashedPassword = PasswordUtils.hashPassword(password);

                Document newUser = new Document("role", role)
                        .append("user_name", username)
                        .append("first_name", firstname)
                        .append("last_name", lastname)
                        .append("email", email)
                        .append("phone", phone)
                        .append("gender", gender)
                        .append("country", country)
                        .append("language", language)
                        .append("password", hashedPassword)
                        .append("created_at", new java.util.Date());

                users.insertOne(newUser);
                registrationSuccess = true;
                message = "Registration successful! Redirecting to login...";
                messageClass = "success";
            } else {
                message = "All fields are required and passwords must match.";
                messageClass = "error";
            }
        } catch (MongoWriteException e) {
            messageClass = "error";
            if (e.getCode() == 11000) {
                String errorMsg = e.getMessage();
                if (errorMsg.contains("user_name")) message = "Username already exists.";
                else if (errorMsg.contains("email")) message = "Email already registered.";
                else message = "Account details already exist.";
            } else {
                message = "A registration error occurred.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "An unexpected error occurred: " + e.getMessage();
            messageClass = "error";
        }
    }
%>

<div class="register-container">
    <div class="brand-section">
        <div class="brand-content">
            <div class="brand-logo">AGRI<span>BRIDGE</span></div>
            <h2 class="brand-tagline">Join Africa's Most Trusted Agricultural Network</h2>
            <p class="brand-desc">Connect with verified farmers, buyers, and suppliers. Real data, real trust, real growth.</p>
            
            <div class="stats-grid">
                <div class="stat-item">
                    <h3>2K+</h3>
                    <p>Farmers</p>
                </div>
                <div class="stat-item">
                    <h3>50+</h3>
                    <p>Products</p>
                </div>
                <div class="stat-item">
                    <h3>99%</h3>
                    <p>Satisfaction</p>
                </div>
            </div>
        </div>
    </div>

    <div class="form-section">
        <div class="form-card" id="formCard">
            <a href="home.jsp" style="display:inline-block; margin-bottom:1.5rem; color:var(--text-light); text-decoration:none; font-size:0.85rem;">← Back to Home</a>
            
            <div class="form-header">
                <h1>Create Account</h1>
                <p>Enter your details to start your journey</p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="msg <%= HtmlUtils.escape(messageClass) %>"><%= HtmlUtils.escape(message) %></div>
            <% } %>

            <form method="post" action="register.jsp" id="registerForm" enctype="multipart/form-data">
                <div class="form-grid">
                    <div class="input-group full-width">
                        <label for="userType">I am a</label>
                        <select id="userType" name="userType" required>
                            <option value="">Choose Role...</option>
                            <option value="buyer">Buyer</option>
                            <option value="seller">Seller</option>
                        </select>
                    </div>

                    <div class="input-group">
                        <label for="firstname">First Name</label>
                        <input type="text" id="firstname" name="firstname" placeholder="John" required>
                        <div class="error-msg">First name is required</div>
                    </div>

                    <div class="input-group">
                        <label for="lastname">Last Name</label>
                        <input type="text" id="lastname" name="lastname" placeholder="Doe" required>
                        <div class="error-msg">Last name is required</div>
                    </div>

                    <div class="input-group full-width">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username" placeholder="johndoe24" required>
                        <div class="error-msg">Username must be at least 4 characters</div>
                    </div>

                    <div class="input-group full-width">
                        <label for="email">Email Address</label>
                        <input type="email" id="email" name="email" placeholder="john@example.com" required>
                        <div class="error-msg">Please enter a valid email address</div>
                    </div>

                    <div class="input-group full-width">
                        <label for="phone">Phone Number</label>
                        <input type="tel" id="phone" name="phone" placeholder="+256 700 000000" required>
                        <div class="error-msg">Valid phone number required</div>
                    </div>

                    <div class="input-group">
                        <label>Gender</label>
                        <div class="radio-group" style="display:flex; gap:1rem; margin-top:0.5rem;">
                            <label style="display:flex; align-items:center; gap:0.5rem; font-weight:normal; cursor:pointer;">
                                <input type="radio" name="gender" value="male" checked> Male
                            </label>
                            <label style="display:flex; align-items:center; gap:0.5rem; font-weight:normal; cursor:pointer;">
                                <input type="radio" name="gender" value="female"> Female
                            </label>
                        </div>
                    </div>

                    <div class="input-group">
                        <label for="language">Language</label>
                        <select id="language" name="language">
                            <option value="english">English</option>
                            <option value="luganda">Luganda</option>
                            <option value="swahili">Swahili</option>
                            <option value="french">French</option>
                        </select>
                    </div>

                    <div class="input-group full-width">
                        <label for="country">Country</label>
                        <select id="country" name="country" required>
                            <option value="">Select Country...</option>
                            <option value="uganda">Uganda</option>
                            <option value="kenya">Kenya</option>
                            <option value="nigeria">Nigeria</option>
                            <option value="india">India</option>
                        </select>
                    </div>

                    <div class="input-group full-width">
                        <label>Profile Picture</label>
                        <div class="file-upload-wrapper" onclick="document.getElementById('profilePic').click()">
                            <i style="font-style:normal; font-size:1.5rem; color:var(--primary); display:block; margin-bottom:0.5rem;">↑</i>
                            <span id="fileName">Click to upload image (JPG, PNG)</span>
                            <input type="file" id="profilePic" name="profilePic" class="file-upload-input" accept=".jpg,.jpeg,.png" onchange="updateFileName(this)">
                        </div>
                        <div class="error-msg" id="fileError">Invalid file type or size</div>
                    </div>

                    <div class="input-group">
                        <label for="password">Password</label>
                        <input type="password" id="password" name="password" placeholder="••••••••" required>
                        <div class="pw-strength-container">
                            <div class="pw-strength-bar" id="pwBar">
                                <div class="pw-strength-segment"></div>
                                <div class="pw-strength-segment"></div>
                                <div class="pw-strength-segment"></div>
                                <div class="pw-strength-segment"></div>
                            </div>
                            <div class="pw-text" id="pwText">Strength: <span style="color:var(--text-light)">None</span></div>
                        </div>
                    </div>

                    <div class="input-group">
                        <label for="confirm_password">Confirm</label>
                        <input type="password" id="confirm_password" name="confirm_password" placeholder="••••••••" required>
                        <div class="error-msg">Passwords do not match</div>
                    </div>
                </div>

                <label class="checkbox-group">
                    <input type="checkbox" name="terms" id="terms" required>
                    <div class="checkbox-custom"></div>
                    <span class="checkbox-label">I agree to the <a href="#">Terms of Use</a> and <a href="#">Privacy Policy</a></span>
                </label>

                <button type="submit" class="btn-submit" id="submitBtn">
                    <span class="spinner" id="spinner"></span>
                    <span id="btnText">Create Account</span>
                </button>
            </form>

            <div style="text-align:center; margin-top:2rem; font-size:0.9rem; color:var(--text-light)">
                Already have an account? <a href="Login.jsp" style="color:var(--primary); font-weight:700; text-decoration:none;">Sign In</a>
            </div>
        </div>
    </div>
</div>

<% if (registrationSuccess) { %>
<script>setTimeout(function(){window.location.href='Login.jsp';},2000);</script>
<% } %>

<script>
    function updateFileName(input) {
        const fileName = input.files[0] ? input.files[0].name : "Click to upload image (JPG, PNG)";
        document.getElementById('fileName').textContent = fileName;
        
        if (input.files[0]) {
            const ext = fileName.split('.').pop().toLowerCase();
            const validExts = ['jpg', 'jpeg', 'png'];
            const fileGroup = input.closest('.input-group');
            if (!validExts.includes(ext)) {
                fileGroup.classList.add('invalid');
                document.getElementById('fileError').textContent = "Only JPG and PNG are allowed";
                input.value = '';
            } else {
                fileGroup.classList.remove('invalid');
            }
        }
    }

    const form = document.getElementById('registerForm');
    const inputs = form.querySelectorAll('input, select');
    
    inputs.forEach(input => {
        input.addEventListener('input', () => validateInput(input));
        input.addEventListener('blur', () => validateInput(input));
    });

    function validateInput(input) {
        const group = input.closest('.input-group');
        if (!group) return true;

        let isValid = true;
        if (input.required && !input.value) isValid = false;
        else if (input.type === 'email' && input.value) {
            isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input.value);
        } else if (input.id === 'username' && input.value) {
            isValid = input.value.length >= 4;
        } else if (input.id === 'password') {
            updatePasswordStrength(input.value);
            isValid = input.value.length >= 6;
        } else if (input.id === 'confirm_password') {
            isValid = input.value === document.getElementById('password').value;
        } else if (input.id === 'phone' && input.value) {
            isValid = /^\+?[\d\s-]{10,}$/.test(input.value);
        }

        if (isValid) {
            group.classList.remove('invalid');
            if(input.value) group.classList.add('valid');
        } else {
            group.classList.remove('valid');
            group.classList.add('invalid');
        }
        return isValid;
    }

    function updatePasswordStrength(pw) {
        const bar = document.getElementById('pwBar');
        const segments = bar.querySelectorAll('.pw-strength-segment');
        const text = document.getElementById('pwText').querySelector('span');
        
        let strength = 0;
        if (pw.length >= 6) strength++;
        if (pw.length >= 10) strength++;
        if (/[A-Z]/.test(pw)) strength++;
        if (/[0-9]/.test(pw)) strength++;
        if (/[^A-Za-z0-9]/.test(pw)) strength++;

        const colors = ['#ff4757', '#ffa502', '#2ed573', '#2ed573'];
        const labels = ['Weak', 'Fair', 'Good', 'Strong'];
        
        segments.forEach((seg, i) => {
            seg.style.background = (i < strength) ? colors[Math.min(strength - 1, 3)] : 'var(--border)';
        });

        if (strength > 0) {
            text.textContent = labels[Math.min(strength - 1, 3)];
            text.style.color = colors[Math.min(strength - 1, 3)];
        } else {
            text.textContent = 'None';
            text.style.color = 'var(--text-light)';
        }
    }

    form.addEventListener('submit', function(e) {
        let isFormValid = true;
        inputs.forEach(input => {
            if (!validateInput(input)) isFormValid = false;
        });

        if (!isFormValid) {
            e.preventDefault();
            const card = document.getElementById('formCard');
            card.classList.add('shake');
            setTimeout(() => card.classList.remove('shake'), 400);
            return;
        }

        document.getElementById('submitBtn').disabled = true;
        document.getElementById('spinner').style.display = 'block';
        document.getElementById('btnText').textContent = 'Processing...';
    });
</script>
</body>
</html>
