module controllers.error_controller;

import vibe.vibe;
import std.stdio;
import manager.session_manager;
import model.user;

void errorPage(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	SessionManager manager = SessionManager.construct(req, res);

	string[string] common;
	common["email"] = manager.get!string("email", "");
	common["isAdmin"] = User.isAdmin(common["email"]).to!string;

	res.render!("error.dt", error, common);
}