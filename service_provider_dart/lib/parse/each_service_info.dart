// 每一个接口服务对应的信息
class EachServiceInfo {
  final String interfaceStr;
  final String implStr;
  final List<String> importList;

  EachServiceInfo(
    this.importList,
    this.interfaceStr,
    this.implStr,
  );
}
