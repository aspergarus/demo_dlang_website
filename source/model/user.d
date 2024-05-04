module model.user;

import std.stdio;
import std.conv;
import std.format;
import std.exception;
import core.exception;

import d2sqlite3;
import vibe.http.auth.digest_auth;

enum UserType {
    EMAIL,
    NAME
}

enum realm = "vibe-app";

struct User
{
    long id;
    string name;
    string email;
    string password;

    void save() {
        writeln("Save current user in DB");
    }

    string asString() {
        return format("%d: %s %s %s", this.id, this.name, this.email, this.password);
    }

    void debugUser() {
        writeln(this.asString());
    }

    static User find(string nameOrEmail, UserType type) {
        if (type == UserType.EMAIL) {
            return findByEmail(nameOrEmail);
        }
        if (type == UserType.NAME) {
            return findByName(nameOrEmail);
        }

        throw new Exception("Unknown userType");
    }

    static User findByEmail(string email) {
        User user = User.findExec("SELECT id, username, email, password FROM user WHERE email = ?", email);
        return user;
    }

    static User findByName(string name) {
        User user = User.findExec("SELECT id, username, email, password FROM user WHERE username = ?", name);

        return user;
    }

    static User findExec(string query, string param) {
        auto db = Database("vibed.db");

        auto statement = db.prepare(query);
        statement.bindAll(param);

        auto resultSet = statement.execute();
        if (resultSet.empty) {
            return User();
        }

        auto row = resultSet.front;
        auto user = row.as!User();
        return user;
    }

    bool checkPassword(string password) {
        string pass = createDigestPassword(realm, email, password);
        return pass == this.password;
    }

    static void create(string username, string email, string password) {
        auto db = Database("vibed.db");
    
        string pass = createDigestPassword(realm, email, password);

        auto statement = db.prepare("INSERT INTO user (username, email, password) VALUES (?,?,?)");
        statement.inject(username, email, pass);

        statement = db.prepare(
            "SELECT id FROM user WHERE username = ? AND email = ? and password = ?"
        );
        statement.bindAll(username, email, pass);
        auto uid = statement.execute().oneValue!long;
        statement.reset();

        statement = db.prepare("INSERT INTO user_roles (uid, role) VALUES (?,?)");
        statement.inject(uid, 0);
    }

    static bool isAdmin(string email) {
        auto db = Database("vibed.db");

        auto statement = db.prepare(
            "
                SELECT id
                FROM user u
                JOIN user_roles ur ON u.id = ur.uid
                WHERE email = ? AND ur.role = 1
            ");
        statement.bindAll(email);
        
        return !statement.execute().empty;
    }
}

