class NodeItem {
  String nodeId = '';
  String nodeName = '';

  NodeItem(this.nodeId, this.nodeName);
}

class NodeGroup {
  List<NodeItem> nodes = <NodeItem>[];
  String nodeGroupName = '';
}
