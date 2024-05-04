module cli.cli;

import std.stdio;
import d2sqlite3;

import cli.model.user;

int main(string[] args) {
    if (args.length < 2)
    {
        writefln ("synopsis: %s command [parameters]", args[0]);
        writefln ("\tpossible commands: [start, addAdmin]");
        return 1;
    }

    switch (args[1]) {
        case "start":
            startCommand();
            break;
        case "addAdmin":
            if (args.length < 5) {
                writefln ("synopsis: %s %s username email password", args[0], args[1]);
                return 1;
            }
            addAdminCommand(args[2], args[3], args[4]);
            break;
        default:
            writeln("No such command: " ~ args[1]);
            return 1;
    }

    return 0;
}

void startCommand() {
    auto db = Database("vibed.db");

    // db.run("DROP TABLE if exists user");
    db.run("CREATE TABLE if not exists user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
    )");

    // db.run("DROP TABLE if exists user_roles");
    db.run("CREATE TABLE if not exists user_roles (
        uid INTEGER PRIMARY KEY,
        role INTEGER NOT NULL
    )");

    // db.run("DROP TABLE if exists session");
    db.run("CREATE TABLE if not exists session (
        session_id TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL,
        PRIMARY KEY(session_id)
    )");

    // sdb.run("DROP TABLE if exists products");
    db.run("CREATE TABLE if not exists products (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status INTEGER NOT NULL,
        price INTEGER NOT NULL,
        img_path TEXT NOT NULL
    )");

    db.run("DROP TABLE if exists cart");
    db.run("CREATE TABLE if not exists cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid INTEGER NOT NULL
    )");

    db.run("DROP TABLE if exists cart_items");
    db.run("CREATE TABLE if not exists cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cart_id INTEGER,
        product_id TEXT NOT NULL,
        quantity TEXT NOT NULL
    )");
}

void addAdminCommand(string username, string email, string password) {
    User.createAdmin(username, email, password);
    
    writeln("User " ~ username ~ " was successfully added as admin\n");
}