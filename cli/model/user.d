module cli.model.user;

import std.stdio;
import std.conv;
import std.format;
import std.exception;
import core.exception;

import d2sqlite3;
import vibe.http.auth.digest_auth;

enum realm = "vibe-app";

struct User
{
    static void createAdmin(string username, string email, string password) {
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
        statement.inject(uid, 1);

        writeln("Saved into DB user with " ~ username ~ " and id " ~ to!string(uid));
    }
}

