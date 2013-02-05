part of demo_client;

abstract class FileEventListener {
  
}

abstract class FileCopyEventListener extends FileEventListener {
  onFileAdded(File f);
}

abstract class FileStatusEventListener extends FileEventListener {
  onFileEntry(String fileName, int size);
}