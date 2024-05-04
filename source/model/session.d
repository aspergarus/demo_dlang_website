module model.session;

import std.stdio;
import std.format;
import std.exception;
import core.exception;
import d2sqlite3;

struct SessionModel
{
    static string get(string key) {
        Database db = Database("vibed.db");

        string query = "SELECT value FROM session WHERE session_id = ?";
        
        auto statement = db.prepare(query);
        statement.bindAll(key);

        auto result = statement.execute();

        if (result.empty) {
            return "";
        }

        return result.oneValue!string;
    }

    static void set(string key, string value) {    
        Database db = Database("vibed.db");

        auto statement = db.prepare("REPLACE INTO session (session_id, value) VALUES (?,?)");
        statement.inject(key, value);
    }
}
