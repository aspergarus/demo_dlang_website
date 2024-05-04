module manager.session_manager;

import std.random : uniform, randomSample;
import std.string : format;
import std.json;
import std.conv;
import std.stdio;

import vibe.vibe;

import model.session;

enum cookieName = "UBER_SESSION";

struct SessionManager {
    string sessionId;
    HTTPServerResponse m_res;

    static SessionManager construct(HTTPServerRequest req, HTTPServerResponse res) {
        string tempSessionId = req.cookies.get(cookieName, "");
        if (tempSessionId.length == 0) {
            tempSessionId = generateRandomString(32);
        }

        SessionManager.createSessionIfNotExists(tempSessionId);

        return SessionManager(tempSessionId, res);
    }

    static void createSessionIfNotExists(string sessionId) {
        string jsonString = SessionModel.get(sessionId);
        writefln("Session value when creating session manager: %s", jsonString);
        if (jsonString.length == 0) {
            SessionModel.set(sessionId, "{}");
        }
    }

    /**
     * Save into session value of type T. T can be simple types, like int, string, bool, not structs or classes. 
     */ 
    void set(T)(string key, T value) {
        string jsonString = SessionModel.get(sessionId);
        JSONValue parsedValue = unserializeJsonToAssociativeArray(jsonString);
        writefln("Value before set to object: %s", value);
        parsedValue.object[key] = value;
        writefln("Writing json to DB: %s", parsedValue.toString);
        SessionModel.set(sessionId, serializeAssociativeArrayToJson(parsedValue));
    }

    T get(T)(string key, T byDefault = T.init) {
        string sessionVal = SessionModel.get(sessionId);
        JSONValue value = unserializeJsonToAssociativeArray(sessionVal);

        if (key !in value) {
            value.object[key] = byDefault;
        }

        return value[key].get!T;
    }

    void save() {
        m_res.setCookie(cookieName, sessionId);
    }
}

string generateRandomString(size_t length)
{
    // Define characters that can be used in the random string
    string characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    // Initialize an empty string to hold the random string
    string randomString;

    // Generate random characters and append them to the random string
    foreach (i; 0 .. length)
    {
        char randomChar = characters[uniform(0, characters.length)];
        randomString ~= randomChar;
    }

    return randomString;
}

string serializeAssociativeArrayToJson(JSONValue data)
{
    return data.toString;
}


JSONValue unserializeJsonToAssociativeArray(string jsonString)
{
    return parseJSON(jsonString);
}
