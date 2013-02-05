part of demo_client;

class FileManager extends GenericEventTarget<FileEventListener>{
  FileSystem _fs;
  List<File> _files;
  List<File> get files => getAllFiles();
  
  FileManager() {
    _files = new List<File>();
    window.requestFileSystem(Window.TEMPORARY, 1024*1024*1024, _onFileSystemAccess, _onFileSystemAccessError);
  }
  
  void addFiles(List<File> f) {
    _files.addAll(f);
    
    for (int i = 0; i < f.length; i++) {
      File file = f[i];
      
      _fs.root.getFile(
          file.name,
          options : {'create': true, 'exclusive': true},
          successCallback: (FileEntry e) {
            e.createWriter((FileWriter fw) {
              fw.write(file);
              notifyFileListeners(file);
            }, _onFileSystemAccessError);
          },
          errorCallback: _onFileSystemAccessError
      );
    }
    
  }
  
  List<File> getAllFiles() {
    return _files;
  }
  void notifyFileListeners(File f) {
    
    listeners.where((l) => l is FileCopyEventListener).forEach((FileCopyEventListener l)  {
      l.onFileAdded(f);
    });
  }
  
  void writeFile(FileWriter fw, File f) {
    fw.write(f);
  }
  
  void _onFileSystemAccess(FileSystem root) {
    _fs = root;
    print ("got access");
    
    /*_fs.root.getDirectory(
        'SamiUberTest',
        options: {'create': true},
        successCallback: _onDirectoryAccess,
        errorCallback: _onFileSystemAccessError
    );*/
  }
  
  void _onDirectoryAccess(DirectoryEntry de) {
    
  }
  void _onFileSystemAccessError(FileError error) {
    String e = "Not set error";
    
    switch (error.code) {
      case FileError.ABORT_ERR:
        e = "Aborted";
        break;
      case FileError.ENCODING_ERR:
        e = "Encoding error";
        break;
      case FileError.INVALID_MODIFICATION_ERR:
        e = "Invalid modification";
        break;
      case FileError.INVALID_STATE_ERR:
        e = "Invalid state";
        break;
      case FileError.NO_MODIFICATION_ALLOWED_ERR:
        e = "No modification allowed";
        break;
      case FileError.NOT_FOUND_ERR:
        e = "Not found";
        break;
      case FileError.NOT_READABLE_ERR:
        e = "Not readable";
        break;
      case FileError.PATH_EXISTS_ERR:
        e = "Path exists error";
        break;
      case FileError.QUOTA_EXCEEDED_ERR:
        e = "Quota";
        break;
      case FileError.SECURITY_ERR:
        e = "Security";
        break;
      case FileError.SYNTAX_ERR:
        e = "Syntax error";
        break;
      case FileError.TYPE_MISMATCH_ERR:
        e = "Type mismatch error";
        break;
      default:
        e = "Unknown error";
        break;
    }
    print(e);
  }
}

