module model.product;

import std.stdio;
import std.conv;
import std.format;
import std.exception;
import core.exception;

import d2sqlite3;
import vibe.http.auth.digest_auth;

struct Product
{
    ulong id;
    string title;
    string description;
    uint status;
    ulong price;
    string img_path;

    static void create(string title, string description, ulong price, string uploadedFileName) {
        auto db = Database("vibed.db");
    
        auto query = "
            INSERT INTO products (title, status, description, price, img_path) 
            VALUES (?,?,?,?,?)";
        auto statement = db.prepare(query);
        statement.inject(title, 1, description, price, uploadedFileName);
    }

    string asString() {
        return format(
            "%d: %s %s %d %d %s", 
            this.id, this.title, this.description, this.price, this.status, this.img_path
        );
    }

    static Product[] getAll() {
        auto db = Database("vibed.db");
        auto query = "SELECT * FROM products";
        auto statement = db.prepare(query);

        return Product.getMultipleProducts(statement);
    }

    static Product[] getAllActive() {
        auto db = Database("vibed.db");
        auto query = "SELECT * FROM products WHERE status = ?";
        auto statement = db.prepare(query);
        statement.bindAll(1);
        
        return Product.getMultipleProducts(statement);
    }

    static Product[] getMultipleProducts(Statement statement) {
        Product[] products = [];
        
        auto resultSet = statement.execute();
        if (resultSet.empty) {
            return products;
        }

        foreach (Row row; resultSet) {
            auto product = row.as!Product();
            products ~= product;
        }

        return products;
    }

    static Product find(ulong id) {
        Product product = Product.findExec("SELECT * FROM products WHERE id = ?", id);

        return product;
    }

    static Product findExec(string query, long param) {
        auto db = Database("vibed.db");

        auto statement = db.prepare(query);
        statement.bindAll(param);

        auto resultSet = statement.execute();
        if (resultSet.empty) {
            return Product();
        }

        auto row = resultSet.front;
        auto user = row.as!Product();
        return user;
    }

    void remove() {
        auto db = Database("vibed.db");
    
        auto query = "
            DELETE FROM products
            WHERE id = ?";
        auto statement = db.prepare(query);
        statement.inject(id);
    }

    void save() {
        auto db = Database("vibed.db");
    
        auto query = "
            UPDATE products
            SET title = ?, status = ?, description = ?, price = ?, img_path = ?
            WHERE id = ?";
        auto statement = db.prepare(query);
        statement.inject(title, status, description, price, img_path, id);
    }
}

