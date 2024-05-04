module controllers.home_controller;

import vibe.vibe;
import std.stdio;

import manager.session_manager;
import model.product;
import model.user;
import model.cart;

void home(HTTPServerRequest req, HTTPServerResponse res)
{
	SessionManager manager = SessionManager.construct(req, res);

	int counter = manager.get!int("counterInt");
	counter++;	
	manager.set!int("counterInt", counter);
	manager.save();

	string message = manager.get!string("messages", "");
	manager.set!string("messages", "");

	string userEmail = manager.get!string("email");
	if (userEmail.length > 0) {
	    User user = User.findByEmail(userEmail);
		Cart cart = Cart.getUserCart(user.id);
		writeln(user.email, cart);
	}

	Product[] products = Product.getAllActive();

	string[string] common;
	common["counter"] = counter.to!string;
	common["message"] = message;
	common["email"] = userEmail;
	common["isAdmin"] = User.isAdmin(common["email"]).to!string;

	render!("content/index.dt", common, products)(res);
}

void test(HTTPServerRequest req, HTTPServerResponse res) {
	string response = "";
	auto first = req.params["first"] ? req.params["first"] : "";
	auto second = req.params["second"] ? req.params["second"] : "";

	response = first ~ " " ~ second;

	res.writeBody("just debug" ~ response);
}

void testSession(HTTPServerRequest req, HTTPServerResponse res) {
	auto session = req.session;
	if (!session) {
		session = res.startSession();
	}
	
	auto counter = session.get!int("counter");
	session.set("counter", counter + 1);
	res.writeBody("counter" ~ counter.to!string);
}
