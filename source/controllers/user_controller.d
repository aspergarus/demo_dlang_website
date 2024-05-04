module controllers.user_controller;

import vibe.vibe;
import std.stdio;
import std.conv;
import std.regex;

import model.user;
import manager.session_manager;

void loginPage(HTTPServerRequest req, HTTPServerResponse res) {
	SessionManager manager = SessionManager.construct(req, res);

	string message = manager.get!string("messages", "");
	
	manager.set!string("messages", "");

	string[string] common;
	common["message"] = message;

	render!("content/login.dt", common)(res);
}

void login(HTTPServerRequest req, HTTPServerResponse res) {
	enforceHTTP("name" in req.form, HTTPStatus.badRequest, "Missing user or email field.");
	enforceHTTP("password" in req.form, HTTPStatus.badRequest, "Missing password field.");

	SessionManager manager = SessionManager.construct(req, res);
	
	string userName = req.form["name"];
	string password = req.form["password"];

	auto ctr = ctRegex!(`^.*@{1}.*$`);
	UserType userType;

	if (matchFirst(userName, ctr)) {
		userType = UserType.EMAIL;
	} else {
		userType = UserType.NAME;
	}

	writeln(userName, userType);
	User u = User.find(userName, userType);

	if (u.checkPassword(password)) {
		manager.set!string("email", u.email);
		res.redirect("/");
	} else {
		manager.set("messages", format("User(%s) or password is not found", userName));
		res.redirect("/login");
	}
}

void registerUser(HTTPServerRequest req, HTTPServerResponse res) {
	enforceHTTP("name" in req.form, HTTPStatus.badRequest, "Missing name field.");
	enforceHTTP("email" in req.form, HTTPStatus.badRequest, "Missing email field.");
	enforceHTTP("password" in req.form, HTTPStatus.badRequest, "Missing password field.");
	enforceHTTP("confirm_password" in req.form, HTTPStatus.badRequest, "Missing confirm password field.");
	enforceHTTP(req.form["password"] == req.form["confirm_password"], HTTPStatus.badRequest, "Passwords don't match.");

	User.create(req.form["name"], req.form["email"], req.form["password"]);
	res.redirect("/");
}

void logout(HTTPServerRequest req, HTTPServerResponse res) {
	SessionManager manager = SessionManager.construct(req, res);
	manager.set!string("email", "");
	res.redirect("/");
}

void checkLoggedIn(HTTPServerRequest req, HTTPServerResponse res) {
	SessionManager manager = SessionManager.construct(req, res);

    string userEmail = manager.get!string("email");

	if (userEmail.length == 0) {
        manager.set("messages", "User is not logged in");
        res.redirect("/");
    }
}