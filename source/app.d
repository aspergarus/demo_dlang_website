import vibe.vibe;
import vibe.d;

import std.stdio;

import router;
import controllers.error_controller;

void main() {
	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	settings.errorPageHandler = toDelegate(&errorPage);
	settings.sessionStore = new MemorySessionStore;

    auto router = getRouter();
        
    auto listener = listenHTTP(settings, router);
    
    scope (exit)
	{
		listener.stopListening();
    }  

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
	runApplication();
}
