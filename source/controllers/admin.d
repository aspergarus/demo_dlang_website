module controllers.admin;

import vibe.vibe;
import vibe.d;
import std.stdio;

import manager.session_manager;
import model.user;
import model.product;
import service.file_manager;

void listProductsAdminPage(HTTPServerRequest req, HTTPServerResponse res) {
    // get product list
    Product[] products = Product.getAll();
    
    SessionManager manager = SessionManager.construct(req, res);
	string message = manager.get!string("messages", "");
	manager.set!string("messages", "");

    string[string] common;
    common["message"] = message;
    common["email"] = manager.get!string("email", "");
	common["isAdmin"] = User.isAdmin(common["email"]) ? "true" : "false";

    // show it on template
    render!("admin/list.dt", common, products)(res);
}

void addProductPage(HTTPServerRequest req, HTTPServerResponse res)
{
    string[string] common;
    SessionManager manager = SessionManager.construct(req, res);
    common["email"] = manager.get!string("email", "");
	common["isAdmin"] = User.isAdmin(common["email"]) ? "true" : "false";

	render!("admin/add.dt", common)(res);
}

void addProduct(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP("title" in req.form, HTTPStatus.badRequest, "Missing title field.");
	enforceHTTP("description" in req.form, HTTPStatus.badRequest, "Missing description field.");
    enforceHTTP("price" in req.form, HTTPStatus.badRequest, "Missing price field.");
    enforceHTTP(isNumeric(req.form["price"]), HTTPStatus.badRequest, "Price is not a number.");
    enforceHTTP("image" in req.files, HTTPStatus.badRequest, "Missing image field.");

    auto imageFile = req.files.get("image");

    string uploadedFileName = handleFile(imageFile);
    
    Product.create(req.form["title"], req.form["description"], req.form["price"].to!ulong, uploadedFileName);
	
    res.redirect("/admin");
}

void editProductPage(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["productId"]), HTTPStatus.badRequest, "Product id is not a number.");

    Product product = Product.find(req.params["productId"].to!ulong);

    SessionManager manager = SessionManager.construct(req, res);
	string message = manager.get!string("messages", "");
	manager.set!string("messages", "");

    string[string] common;
    common["message"] = message;
    common["email"] = manager.get!string("email", "");
	common["isAdmin"] = User.isAdmin(common["email"]) ? "true" : "false";

	render!("admin/edit.dt", common, product)(res);
}

void editProduct(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP("title" in req.form, HTTPStatus.badRequest, "Missing title field.");
	enforceHTTP("description" in req.form, HTTPStatus.badRequest, "Missing description field.");
    enforceHTTP("price" in req.form, HTTPStatus.badRequest, "Missing price field.");
    enforceHTTP(isNumeric(req.form["price"]), HTTPStatus.badRequest, "Price is not a number.");
    enforceHTTP(isNumeric(req.params["productId"]), HTTPStatus.badRequest, "Product id is not a number.");

    Product product = Product.find(req.params["productId"].to!ulong);
    product.title = req.form["title"];
    product.price = req.form["price"].to!ulong;
    product.description = req.form["description"];

    if ("image" in req.files) {
        cleanFile(product.img_path);
        auto imageFile = req.files.get("image");
        product.img_path = handleFile(imageFile);
    }

    product.save();
    
    SessionManager manager = SessionManager.construct(req, res);
	manager.set("messages", format("Product(%d) has been updated", product.id));
    
    res.redirect("/admin");
}

void deleteProductPage(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["productId"]), HTTPStatus.badRequest, "Product id is not a number.");

    Product product = Product.find(req.params["productId"].to!ulong);

    string[string] common;
    SessionManager manager = SessionManager.construct(req, res);
    common["email"] = manager.get!string("email", "");
	common["isAdmin"] = User.isAdmin(common["email"]) ? "true" : "false";

    render!("admin/delete.dt", common, product)(res);
}

void deleteProduct(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["productId"]), HTTPStatus.badRequest, "Product id is not a number.");

    Product product = Product.find(req.params["productId"].to!ulong);
    product.remove();

    cleanFile(product.img_path);

    SessionManager manager = SessionManager.construct(req, res);
	manager.set("messages", format("Product(%d) has been deleted", product.id));

    res.redirect("/admin");
}

void hideProduct(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["productId"]), HTTPStatus.badRequest, "Product id is not a number.");

    Product product = Product.find(req.params["productId"].to!ulong);
    product.status = (!product.status).to!uint;
    product.save();

    res.redirect("/admin");
}

void checkAdminAccess(HTTPServerRequest req, HTTPServerResponse res) {
    SessionManager manager = SessionManager.construct(req, res);

    string userEmail = manager.get!string("email");

    if (!User.isAdmin(userEmail)) {
        manager.set("messages", "Access denied");
        res.redirect("/");
    }
}