<apply template="base">


    <bind tag="heading">
      <link rel="stylesheet" type="text/css" href="/css/nav_left.css" />
    </bind>


    <bind tag="above">

    </bind>

    <bind tag="navbar">
    		<div id="navbarcontents1">
    			<div id="sel_signup"></div>
    			<a href="/login" id="login"></a>
    			<a href="/about" id="about"></a>
    		</div>
    		<div-async name="signup-box" id="navbarcontents2">
    			<div id="subnav">
    				<div id="subnav_signup"></div>
    			</div>
    			<div id="subnav3"><p>Reset your password</p></div>
    			<form-async method="POST" id="signupform">
            <div class="field">
      				<p>Password:</p>
              <div class="errors"><password-errors><error/> </password-errors></div>
              <input type="password" name="password" class="suform" value="" />
            </div>
            <div class="field">
    				  <p>Confirm Password:</p>
    				  <div class="errors"><confirm-errors><error/> </confirm-errors></div>
    				  <input type="password" name="confirm" class="suform" value="" />
    				</div>
     				<button type="submit" id="suform_submit" />
    			</form-async>
    		</div-async>
    </bind>
</apply>