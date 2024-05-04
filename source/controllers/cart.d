module controllers.cart;

import vibe.vibe;
import vibe.d;

import model.product;
import model.cart;
import model.user;
import manager.session_manager;

void cartPage(HTTPServerRequest req, HTTPServerResponse res) {
    SessionManager manager = SessionManager.construct(req, res);
	
    string userEmail = manager.get!string("email");
    User user = User.findByEmail(userEmail);
    Cart cart = Cart.getUserCart(user.id);

    string[string] common;
    common["message"] = "";
    common["email"] = manager.get!string("email", "");
	common["isAdmin"] = User.isAdmin(common["email"]) ? "true" : "false";


    ulong total = 0;
    foreach (item; cart.items)
    {
        total += item.price * item.quantity;
    }

    render!("content/cart.dt", common, cart, total)(res);
}

void addProductToCartPage(HTTPServerRequest req, HTTPServerResponse res)
{
    enforceHTTP(isNumeric(req.params["productId"]), HTTPStatus.badRequest, "Product id is not a number.");

    SessionManager manager = SessionManager.construct(req, res);
	
    string userEmail = manager.get!string("email");
    User user = User.findByEmail(userEmail);
    Cart cart = Cart.getUserCart(user.id);

    Product product = Product.find(req.params["productId"].to!ulong);
    cart.addItem(product.id);

    manager.set!string("messages", "Product '" ~ product.title ~ "' has been added to the cart");

    res.redirect("/");
}

void increaseQuantity(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["cartItemId"]), HTTPStatus.badRequest, "Cart Item id is not a number.");

    CartItem.inc(req.params["cartItemId"].to!ulong);

    res.redirect("/cart");
}

void decreaseQuantity(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["cartItemId"]), HTTPStatus.badRequest, "Cart Item id is not a number.");
    
    CartItem.dec(req.params["cartItemId"].to!ulong);
    
    res.redirect("/cart");
}

void removeCartItem(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["cartItemId"]), HTTPStatus.badRequest, "Cart Item id is not a number.");
    
    CartItem.remove(req.params["cartItemId"].to!ulong);
    
    res.redirect("/cart");
}

void cleanCart(HTTPServerRequest req, HTTPServerResponse res) {
    enforceHTTP(isNumeric(req.params["cartId"]), HTTPStatus.badRequest, "Cart Item id is not a number.");
    
    Cart.clean(req.params["cartId"].to!ulong);
    
    res.redirect("/");
}
