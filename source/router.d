module router;

import vibe.d;

import controllers.home_controller;
import controllers.user_controller;
import controllers.admin;
import controllers.cart;

static URLRouter getRouter() {
    auto router = new URLRouter();

	addPublicRoutes(router);
	addLoggedInRoutes(router);
	addRestrictedRoutes(router);

    return router;
}

void addPublicRoutes(ref URLRouter router) {
	router.get("*", serveStaticFiles("./public/"));
	
	router.get("/", &home);
	router.get("/test/:first/:second", &test);
	router.get("/testSession", &testSession);
	router.get("/login", &loginPage);
	router.post("/login", &login);
	router.get("/logout", &logout);

	router.get("/register", staticTemplate!"content/register.html");
	router.post("/register", &registerUser);
}

void addLoggedInRoutes(ref URLRouter router) {
	router.any("*", &checkLoggedIn);
	router.get("/cart", &cartPage);
	router.get("/cart/add/:productId", &addProductToCartPage);
	router.get("/cart/inc/:cartItemId", &increaseQuantity);
	router.get("/cart/dec/:cartItemId", &decreaseQuantity);
	router.get("/cart/remove/:cartItemId", &removeCartItem);
	router.get("/cart/clean/:cartId", &cleanCart);
}

// Made redirect to home page if user doesn't have admin access for the following routes.
void addRestrictedRoutes(ref URLRouter router) {
	router.any("*", &checkAdminAccess);

	router.get("/admin", &listProductsAdminPage);
    router.get("/admin/", &listProductsAdminPage);

    router.get("/admin/add", &addProductPage);
	router.post("/admin/add", &addProduct);

    router.get("/admin/edit/:productId", &editProductPage);
	router.post("/admin/edit/:productId", &editProduct);

    router.get("/admin/delete/:productId", &deleteProductPage);
	router.post("/admin/delete/:productId", &deleteProduct);

	router.get("/admin/status/:productId", &hideProduct);
}
