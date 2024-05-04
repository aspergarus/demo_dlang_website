module service.file_manager;

import std.stdio;
import vibe.vibe;

struct Destination {
    string fullPath;
    string fileName;
}

enum imagesDest = "./public/media/images/";

string handleFile(const(FilePart) imageFile) {
    Destination d = findPossibleDest(imagesDest, imageFile.filename);

    try {
        moveFile(imageFile.tempPath.toString(), d.fullPath);
    } catch(Exception e) {
        copyFile(imageFile.tempPath.toString(), d.fullPath);
    }
   
    return d.fileName;
}

Destination findPossibleDest(string path, NativePath.Segment imageSegment) {
    auto newFileName = imageSegment.name.to!string;
    string destination = path ~ newFileName;

    writefln("Destination: %s", destination);

    uint numOfCopy = 0;


    if (existsFile(destination)) {
        do {
            numOfCopy++;
            newFileName = imageSegment.withoutExtension.to!string 
                ~ numOfCopy.to!string
                ~ imageSegment.extension.to!string;

            writefln("Newfilename: %s", newFileName);
            destination = path ~ newFileName;
            writefln("Destination: %s", destination);
        } while (existsFile(destination));
    }

    return Destination(destination, newFileName);
}

void cleanFile(string path) {
    string destination = imagesDest ~ path;

    if (existsFile(destination)) {
        removeFile(destination);
    }
}