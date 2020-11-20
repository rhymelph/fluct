class StringCommendEntity {
  final int start;
  final int end;
  //要忽略的number
  final int ignoreNumber;
  //是否有r开头
  final bool isPrefixR;

  StringCommendEntity(this.start, this.end, this.ignoreNumber,
      [this.isPrefixR = false]);
}
