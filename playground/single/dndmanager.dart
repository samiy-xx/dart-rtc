part of demo_client;

class DndManager implements FileCopyEventListener{
  Element _e;
  FileManager _f;
  String _selected;
  
  set fm(FileManager f) => setFileManager(f);
  
  DndManager() {
    _e = query("#filecontainer_left");
    
    document.onDragEnter.listen(onDragEnter);
    document.onDragLeave.listen(onDragLeave);
    document.onDrop.listen(onDrop);
    document.onDragOver.listen(onDragOver);
    
    _e.onDragEnter.listen(onDragEnter);
    _e.onDragLeave.listen(onDragLeave);
    _e.onDrop.listen(onDrop);
    _e.onDragOver.listen(onDragOver);
   
    (query("#copy_from_filesystem") as InputElement).onChange.listen((Event e) {
      _f.addFiles((query("#copy_from_filesystem") as InputElement).files);
    });
  }
  
  void setFileManager(FileManager fm) {
    _f = fm;
    _f.subscribe(this);
  }
  
  void onDragStart(MouseEvent e) {
    print(e.target);
    
  }
  
  void onDragEnter(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  }
  
  void onDragLeave(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
  }
  
  void onDrop(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    
    if (e.target == _e) {
      _f.addFiles(e.dataTransfer.files);
    } else {
      
    }
  }
  
  void onDragOver(MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    
    e.dataTransfer.dropEffect = e.target == _e ? "copy" : "move";
    
  }
  
  void onFileAdded(File f) {
    _e.append(createNewFileNode(f));
  }
  
  Element createNewFileNode(File f) {
    DivElement node = new DivElement();
    node.classes.add("fileEntry");
    
    SpanElement spanName = new SpanElement();
    spanName.appendText(f.name);
    spanName.id = "span_1_${f.name}";
    
    SpanElement spanSize = new SpanElement();
    spanSize.appendText(FileSizeConverter.convert(f.size));
    spanSize.id = "span_2_${f.name}";
    
    SpanElement spanType = new SpanElement();
    spanType.appendText(f.type);
    spanType.id = "span_3_${f.name}";
    
    node.append(spanName);
    node.append(spanSize);
    node.append(spanType);
    
    node.id = "div_${f.name}";
    node.style.cursor = "pointer";
    
    node.onDragStart.listen(onDragStart);
    return node;
  }
}




