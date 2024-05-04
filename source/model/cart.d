module model.cart;

import std.stdio;
import std.conv;
import std.format;
import std.exception;
import core.exception;

import d2sqlite3;
import model.product;

struct Cart {
    ulong id;
    ulong uid;
    CartItem[] items;

    static Cart getUserCart(ulong userId) {
        auto db = Database("vibed.db");

        auto statement = db.prepare("
            SELECT
                c.id cid, c.uid uid,
                ci.id ciid, ci.quantity q, ci.product_id pid,
                p.title title, p.price price, p.img_path img_path 
            FROM cart c
            JOIN cart_items ci ON c.id = ci.cart_id  
            JOIN products p ON p.id = ci.product_id
            WHERE c.uid = ?
        ");
        statement.bindAll(userId);
        
        ResultRange resultSet = statement.execute();
        if (resultSet.empty) {
            writeln("Cart is empty. Creating new cart");
            return Cart.create(userId);
        }

        writeln("Cart is found");
        return Cart.hydrate(resultSet);
    }

    static Cart hydrate(ResultRange resultSet) {
        Cart cart = Cart(0, 0);

        foreach (Row row; resultSet) {
            if (cart.id == 0) {
                cart.id = row["cid"].as!ulong;
                cart.uid = row["uid"].as!ulong;
            }

            auto cartItemId = row["ciid"].as!ulong;
            auto quantity = row["q"].as!uint;
            auto productId = row["pid"].as!ulong;
            auto productTitle = row["title"].as!string;
            auto productPrice = row["price"].as!ulong;
            auto productImage = row["img_path"].as!string;
            CartItem ci = CartItem(cartItemId, cart.id, productId, productTitle, productImage, productPrice, quantity);

            cart.items ~= ci;
        }

        return cart;
    }

    static Cart create(ulong userId) {
        auto db = Database("vibed.db");
    
        auto statement = db.prepare("INSERT INTO cart (uid) VALUES (?)");
        statement.inject(userId);

        statement = db.prepare(
            "SELECT id, uid FROM cart WHERE uid = ?"
        );
        statement.bindAll(userId);

        auto resultSet = statement.execute();
        auto row = resultSet.front;
        Cart cart = Cart(row["id"].as!ulong, row["uid"].as!ulong);

        statement.reset();

        return cart;
    }

    void addItem(ulong productId) {
        auto db = Database("vibed.db");

        ulong existingCartItem = 0;
        foreach (CartItem item; items) {
            if (item.pid == productId) {
                existingCartItem = item.id;
                break;
            }
        }
    
        if (existingCartItem == 0) {
            auto statement = db.prepare("INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?,?,?)");
            statement.inject(id, productId, 1);
            return;
        }

        db.prepare("UPDATE cart_items SET quantity = quantity + 1 WHERE id = ?").inject(existingCartItem);
    }

    static void clean(ulong id) {
        auto db = Database("vibed.db");
        auto statement = db.prepare("DELETE FROM cart_items WHERE cart_id = ?");
        statement.inject(id);

        statement = db.prepare("DELETE FROM cart WHERE id = ?");
        statement.inject(id);
    }
}

struct CartItem {
    ulong id;
    ulong cart_id;
    ulong pid;
    string title;
    string img_path;
    ulong price;
    uint quantity;

    static void inc(ulong id) {
        auto db = Database("vibed.db");
        auto statement = db.prepare("UPDATE cart_items SET quantity = quantity + 1 WHERE id = ?");
        statement.inject(id);
    }

    static void dec(ulong id) {
        auto db = Database("vibed.db");

        auto statement = db.prepare("SELECT quantity FROM cart_items WHERE id = ?");
        statement.bindAll(id);
        auto resultSet = statement.execute();
        auto quantity = resultSet.oneValue!long;

        if (quantity <= 1) {
            db.prepare("UPDATE cart_items SET quantity = 1 WHERE id = ?").inject(id);
            return;
        }

        statement.reset();

        statement = db.prepare("UPDATE cart_items SET quantity = quantity - 1 WHERE id = ?");
        statement.inject(id);
    }

    static void remove(ulong id) {
        auto db = Database("vibed.db");
        auto statement = db.prepare("DELETE FROM cart_items WHERE id = ?");
        statement.inject(id);
    }
}