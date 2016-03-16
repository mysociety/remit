# Helper method to sign up for a new account
def sign_up_for_an_account(email, name)
  visit "/"
  click_link "Sign In or Sign Up"
  click_link "Sign up"
  fill_in "Email", with: email
  fill_in "Name", with: name
  fill_in "Password", with: "password"
  fill_in "Password confirmation", with: "password"
  click_button "Sign up"
end

# Helper method to sign in an account
def sign_in_account(email, password = "password")
  visit "/"
  click_link "Sign In or Sign Up"
  fill_in "Email", with: email
  fill_in "Password", with: password
  click_button "Log in"
end

def sign_out
  click_link "Sign Out"
end
